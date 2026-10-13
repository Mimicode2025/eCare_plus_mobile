import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openDoctors(WidgetTester tester) async {
  await tester.pumpWidget(const ECarePlusApp());
  Navigator.of(
    tester.element(find.byType(SplashScreen)),
  ).pushReplacementNamed('/doctors');
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byTooltip('Message à Dr Johnson Mike'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Chat opens with clearly labelled examples without a demonstration banner',
    (tester) async {
      await openDoctors(tester);
      await tester.tap(find.byTooltip('Message à Dr Johnson Mike'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Mode démonstration'), findsNothing);
      expect(
        find.text('Bonjour, comment vous sentez-vous aujourd’hui ?'),
        findsNothing,
      );
      expect(find.text('Exemple de message'), findsNWidgets(2));
      expect(find.byTooltip('Prendre une photo'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 3));
    },
  );

  testWidgets('Empty composer stays compact on a phone with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openDoctors(tester);
    await tester.tap(find.byTooltip('Message à Dr Johnson Mike'));
    await tester.pumpAndSettle();
    final input = find.byType(TextField).last;
    final initialHeight = tester.getSize(input).height;
    expect(initialHeight, lessThanOrEqualTo(60));
    await tester.enterText(
      input,
      'Un message suffisamment long pour occuper plusieurs lignes dans la conversation.',
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(input).height, greaterThan(initialHeight));
    await tester.enterText(input, '');
    await tester.pumpAndSettle();
    expect(tester.getSize(input).height, initialHeight);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Contact profile and both call previews are reachable', (
    tester,
  ) async {
    await openDoctors(tester);
    await tester.tap(find.byTooltip('Message à Dr Johnson Mike'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Options de la conversation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Afficher le contact'));
    await tester.pumpAndSettle();
    expect(find.text('Profil du médecin'), findsOneWidget);
    expect(find.text('Prendre rendez-vous'), findsOneWidget);
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    for (final type in ['Appel audio', 'Appel vidéo']) {
      await tester.tap(find.byTooltip('Appeler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(type));
      await tester.pumpAndSettle();
      expect(
        find.text('Aperçu de l’interface · Aucun appel lancé'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byTooltip('Micro'));
      await tester.tap(find.byTooltip('Micro'));
      if (type == 'Appel vidéo') {
        await tester.ensureVisible(find.byTooltip('Caméra'));
        await tester.tap(find.byTooltip('Caméra'));
        await tester.pump();
        expect(find.text('Caméra désactivée'), findsOneWidget);
      }
      await tester.ensureVisible(find.byTooltip('Terminer l’appel'));
      await tester.tap(find.byTooltip('Terminer l’appel'));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Chat fits a narrow phone with keyboard and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openDoctors(tester);
    await tester.tap(find.byTooltip('Message à Dr Johnson Mike'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.enterText(
      find.byType(TextField).last,
      'Un message sur plusieurs lignes pour mon médecin.',
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Envoyer le message').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.resetViewInsets();
    await tester.tap(find.byTooltip('Options de la conversation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rechercher'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'aucun résultat');
    await tester.pumpAndSettle();
    expect(find.text('Aucun message trouvé'), findsOneWidget);
    await tester.tap(find.byTooltip('Fermer la recherche'));
    await tester.pumpAndSettle();
    expect(find.text('Exemple de message'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Doctor message button opens the selected conversation', (
    tester,
  ) async {
    await openDoctors(tester);
    await tester.tap(find.byTooltip('Message à Dr Johnson Mike'));
    await tester.pumpAndSettle();
    expect(find.text('Message'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Bonjour docteur');
    await tester.pump();
    await tester.tap(find.byTooltip('Envoyer le message'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour docteur'), findsOneWidget);
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Message à Dr Lawson Jennifer'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour docteur'), findsNothing);
    expect(find.text('Dr Lawson Jennifer'), findsOneWidget);
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Message à Dr Johnson Mike'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour docteur'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
