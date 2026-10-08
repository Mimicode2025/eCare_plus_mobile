import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/views/dashbord/home_page.dart';
import 'package:ecare_plus_mobile/views/onbording/onboarding_screen.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:ecare_plus_mobile/views/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(const ECarePlusApp());
  }

  testWidgets('Splash navigates to onboarding', (tester) async {
    await startApp(tester);
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home displays and opens the profile', (tester) async {
    await startApp(tester);
    final context = tester.element(find.byType(SplashScreen));
    Navigator.of(context).pushReplacementNamed('/home');
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Mes médecins'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('First profile save navigates to home', (tester) async {
    await startApp(tester);
    final context = tester.element(find.byType(SplashScreen));
    Navigator.of(context).pushReplacementNamed('/profile');
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Doe');
    await tester.enterText(fields.at(1), 'Jane');
    await tester.enterText(fields.at(2), '70');
    await tester.enterText(fields.at(3), '175');
    await tester.ensureVisible(find.text('Enregistrer'));
    await tester.tap(find.text('Enregistrer'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ProfilePage), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
