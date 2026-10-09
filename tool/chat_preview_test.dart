import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Render doctor messaging previews', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final font = FontLoader('Poppins');
      for (final file in ['Regular', 'SemiBold', 'Bold']) {
        font.addFont(rootBundle.load('assets/fonts/Poppins-$file.ttf'));
      }
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
    await tester.runAsync(() async {
      final context = tester.element(find.byType(MaterialApp));
      for (final asset in ['lib/data/Docteur1.png', 'lib/data/Docteur 2.png']) {
        if (context.mounted) await precacheImage(AssetImage(asset), context);
      }
    });
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
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

    await tester.drag(
      find.byKey(const PageStorageKey('home-scroll')),
      const Offset(0, -500),
    );
    await capture('medecins-messagerie');
    await tester.ensureVisible(find.byTooltip('Message à Dr Johnson Mike'));
    await tester.tap(find.byTooltip('Message à Dr Johnson Mike'));
    await capture('chat-medecin');
    await tester.tap(find.byTooltip('Message vocal'));
    await tester.pump(const Duration(seconds: 4));
    await capture('chat-vocal');
    await tester.tap(find.byTooltip('Annuler le vocal'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Appeler'));
    await capture('chat-menu-appels');
    await tester.tap(find.text('Appel audio'));
    await capture('chat-appel-audio');
    await tester.tap(find.byTooltip('Haut-parleur'));
    await capture('chat-appel-audio-haut-parleur');
    await tester.tap(find.byTooltip('Terminer l’appel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Appeler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appel vidéo'));
    await capture('chat-appel-video');
    await tester.tap(find.byTooltip('Terminer l’appel'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Options de la conversation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Afficher le contact'));
    await capture('chat-profil-medecin');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
