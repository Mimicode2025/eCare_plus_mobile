import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/routes/app_routes.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Inspect the shared blue palette across patient and auth pages', (
    tester,
  ) async {
    // This script is a Flutter widget test outside the test directory.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
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
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final context = tester.element(find.byType(SplashScreen));
      await Future.wait(
        manifest
            .listAssets()
            .where((path) => path.endsWith('.png'))
            .map((path) => precacheImage(AssetImage(path), context)),
      );
    });
    for (final entry in {
      'home': AppRoutes.home,
      'connexion': AppRoutes.login,
      'suivi': AppRoutes.followUp,
      'profil': AppRoutes.profile,
      'medecins': AppRoutes.doctors,
    }.entries) {
      navigator.pushReplacementNamed(entry.value);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final picture = await render.toImage(pixelRatio: 2);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts').create(recursive: true);
        await File(
          'artifacts/palette-blue-${entry.key}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
