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

    await tester.runAsync(() async {
      final context = tester.element(find.byType(MaterialApp));
      await precacheImage(const AssetImage('lib/data/Docteur1.png'), context);
      if (!context.mounted) return;
      await precacheImage(const AssetImage('lib/data/Docteur 2.png'), context);
      for (final asset in [
        'lib/data/Profile.png',
        'lib/data/icon_suivi.png',
        'lib/data/icon_document.png',
        'lib/data/icon_medicament.png',
        'lib/data/Icon_medecin.png',
        'assets/branding/launcher_foreground.png',
      ]) {
        if (!context.mounted) return;
        await precacheImage(AssetImage(asset), context);
      }
    });
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
    await tester.tap(find.text('Paramètres').last);
    await tester.pumpAndSettle();
    await capture('parametres-mobile');
    final settingsScroll = find.ancestor(
      of: find.text('Votre espace, à votre rythme.'),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(settingsScroll, const Offset(0, -570));
    await tester.pumpAndSettle();
    await capture('parametres-preferences');
    await tester.tap(find.text('Rendez-vous').last);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(MaterialApp));
      await precacheImage(const AssetImage('lib/data/error_404.png'), context);
      if (!context.mounted) return;
      await precacheImage(
        const AssetImage('lib/data/error_pas de connection.png'),
        context,
      );
    });
    Navigator.of(
      tester.element(find.text('Mes rendez-vous')),
    ).pushNamed('/error/not-found');
    await tester.pumpAndSettle();
    await capture('erreur-page-indisponible');
    Navigator.of(
      tester.element(find.text('Info')),
    ).pushReplacementNamed('/error/no-connection');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Info'), findsOneWidget);
    expect(find.text('Réessayer').hitTestable(), findsOneWidget);
    await capture('erreur-sans-connexion');
    Navigator.of(
      tester.element(find.text('Info')),
    ).pushReplacementNamed('/login');
    await tester.pumpAndSettle();
    await capture('connexion-logo-ecare');
    Navigator.of(
      tester.element(find.text('Content de vous\nrevoir !')),
    ).pushNamed('/privacy-policy');
    await tester.pumpAndSettle();
    await capture('politique-confidentialite');
    Navigator.of(
      tester.element(find.text('Politique de confidentialité')),
    ).pushReplacementNamed('/terms-of-use');
    await tester.pumpAndSettle();
    await capture('conditions-utilisation');
    Navigator.of(
      tester.element(find.text('Conditions générales d’utilisation')),
    ).pushReplacementNamed('/register');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(Checkbox), 250,
      scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await capture('inscription-consentement');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
