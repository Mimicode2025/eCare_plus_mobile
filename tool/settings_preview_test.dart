import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/routes/app_routes.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Preview settings, eCare presentation and practical help', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final fonts = FontLoader('Poppins');
      for (final weight in ['Regular', 'SemiBold', 'Bold']) {
        fonts.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
      }
      await fonts.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: boundary, child: const ECarePlusApp()),
    );
    final navigator = Navigator.of(tester.element(find.byType(SplashScreen)));
    await tester.runAsync(() async {
      final context = tester.element(find.byType(SplashScreen));
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      await Future.wait(
        manifest
            .listAssets()
            .where((path) => path.endsWith('.png'))
            .map((path) => precacheImage(AssetImage(path), context)),
      );
    });
    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final picture = await render.toImage(pixelRatio: 2);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts').create(recursive: true);
        await File(
          'artifacts/settings-$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
    }

    navigator.pushReplacementNamed(AppRoutes.home);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Paramètres'));
    await tester.pumpAndSettle();
    await capture('page');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    await capture('links');
    navigator.pushNamed(AppRoutes.about);
    await tester.pumpAndSettle();
    await capture('ecare');
    await tester.scrollUntilVisible(
      find.text('Ajouter et retrouver un document'),
      150,
    );
    await tester.tap(find.text('Ajouter et retrouver un document'));
    await tester.pumpAndSettle();
    await capture('help');
    navigator.pushNamed(AppRoutes.localData);
    await tester.pumpAndSettle();
    await capture('data');
    navigator.pushNamed(AppRoutes.about);
    tester.view.physicalSize = const Size(320, 740);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    await capture('small');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
