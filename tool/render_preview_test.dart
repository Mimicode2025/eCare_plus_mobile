import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Render the mobile interface for visual inspection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final font = FontLoader('Poppins');
      font.addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'));
      font.addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'));
      font.addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
      await font.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: boundary, child: const ECarePlusApp()),
    );
    Navigator.of(
      tester.element(find.byType(SplashScreen)),
    ).pushReplacementNamed('/home');
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/images/ecareImage1.png'),
        tester.element(find.byType(MaterialApp)),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final picture = await render.toImage(pixelRatio: 2);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts').create(recursive: true);
        await File(
          'artifacts/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
    }

    await capture('accueil-mobile');
    await tester.drag(
      find.byKey(const PageStorageKey('home-scroll')),
      const Offset(0, -470),
    );
    await tester.pumpAndSettle();
    await capture('accueil-defilement');
    await tester.tap(find.text('Rendez-vous').last);
    await tester.pumpAndSettle();
    await capture('rendez-vous-mobile');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
