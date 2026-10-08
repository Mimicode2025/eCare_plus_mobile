import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/views/error/no_connection_page.dart';
import 'package:ecare_plus_mobile/views/error/page_not_found_page.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'No connection page invokes retry and prevents duplicate requests',
    (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: NoConnectionPage(
            onRetry: () async {
              attempts++;
              await Future<void>.delayed(const Duration(seconds: 1));
            },
          ),
        ),
      );
      expect(
        find.text('Aucune connexion internet\ndisponible'),
        findsOneWidget,
      );
      await tester.tap(find.text('Réessayer'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(attempts, 1);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Unavailable page remains usable after retry failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PageNotFoundPage(
          onRetry: () async {
            throw StateError('Unavailable');
          },
        ),
      ),
    );
    expect(find.text('Cette page n’est pas\ndisponible'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(
      find.text('La tentative a échoué. Vous pouvez réessayer.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Unknown routes display the unavailable page and return safely', (
    tester,
  ) async {
    await tester.pumpWidget(const ECarePlusApp());
    Navigator.of(
      tester.element(find.byType(SplashScreen)),
    ).pushNamed('/missing-page');
    await tester.pumpAndSettle();
    expect(find.byType(PageNotFoundPage), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(find.byType(PageNotFoundPage), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Both error pages fit a small screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final page in [const PageNotFoundPage(), const NoConnectionPage()]) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Réessayer'));
      expect(find.text('Réessayer').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
