import 'package:ecare_plus_mobile/views/auth/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [1.0, 1.3, 2.0]) {
    testWidgets('Forgot password keeps subtitle above card at scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        const MaterialApp(home: ForgotPasswordPage()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final subtitle = tester.getRect(
        find.text("Pas de panique, nous vous aidons à retrouver l'accès."),
      );
      final card = tester.getRect(
        find.ancestor(of: find.byType(Form), matching: find.byType(Container)).first,
      );
      expect(subtitle.bottom, lessThanOrEqualTo(card.top));
      await tester.ensureVisible(find.text('Envoyer les instructions'));
      expect(tester.takeException(), isNull);
      expect(find.text('Envoyer les instructions').hitTestable(), findsOneWidget);
    });
  }
}
