import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:ecare_plus_mobile/views/auth/register_page.dart';
import 'package:ecare_plus_mobile/views/auth/registration_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openRoute(WidgetTester tester, String route) async {
  await tester.pumpWidget(const ECarePlusApp());
  Navigator.of(
    tester.element(find.byType(SplashScreen)),
  ).pushReplacementNamed(route);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Registration legal links open without accepting the checkbox', (
    tester,
  ) async {
    await openRoute(tester, '/register');
    await tester.enterText(find.byType(TextFormField).first, 'Dupont');
    await tester.scrollUntilVisible(
      find.byType(Checkbox),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await tester.tapOnText(
      find.textRange.ofSubstring('politique de confidentialité'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Données utilisées'), findsOneWidget);
    await tester.tap(find.byTooltip('Retour'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Dupont',
    );
    await tester.tapOnText(
      find.textRange.ofSubstring('conditions générales d’utilisation'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Objet de l’application'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Registration requires explicit consent with a valid form', (
    tester,
  ) async {
    await openRoute(tester, '/register');
    final values = [
      'Dupont',
      'Gloria',
      'gloria@example.com',
      '90123456',
      'Password123!',
      'Password123!',
    ];
    for (var i = 0; i < values.length; i++) {
      await tester.enterText(find.byType(TextFormField).at(i), values[i]);
    }
    await tester.scrollUntilVisible(
      find.text("S'inscrire"),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text("S'inscrire"));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterPage), findsOneWidget);
    expect(
      find.text('Cochez la case pour accepter ces documents et vous inscrire.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(
      find.text('Cochez la case pour accepter ces documents et vous inscrire.'),
      findsNothing,
    );
    await tester.ensureVisible(find.text("S'inscrire"));
    await tester.tap(find.text("S'inscrire"));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(RegistrationSuccessPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Both legal pages are reachable from settings on a narrow phone',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openRoute(tester, '/home');
      await tester.tap(find.text('Paramètres').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Politique de confidentialité'),
        400,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Politique de confidentialité'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byTooltip('Retour'));
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Conditions générales d’utilisation'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Conditions générales d’utilisation'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
