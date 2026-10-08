import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/views/dashbord/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> openSettings(WidgetTester tester, CareData data) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: data,
      child: MaterialApp(
        home: const Scaffold(body: SettingsPage()),
        routes: {'/login': (_) => const Scaffold(body: Text('Connexion'))},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Agenda preference updates while other alerts remain available', (
    tester,
  ) async {
    final data = CareData();
    data.addNotification(
      CareNotification(
        title: 'Information',
        message: 'Dossier',
        date: DateTime.now(),
        category: NotificationCategory.alert,
      ),
    );
    await openSettings(tester, data);
    expect(find.text('Votre espace, à votre rythme.'), findsOneWidget);
    await tester.scrollUntilVisible(find.byType(Switch), 250);
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(Switch)).label,
      contains('Rappels de rendez-vous'),
    );
    semantics.dispose();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(data.remindersEnabled, isFalse);
    expect(data.notifications.single.category, NotificationCategory.alert);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Logout cancellation preserves data and confirmation clears it', (
    tester,
  ) async {
    final data = CareData()..addReading(98);
    await openSettings(tester, data);
    await tester.scrollUntilVisible(find.text('Se déconnecter'), 300);
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rester'));
    await tester.pumpAndSettle();
    expect(data.readings, hasLength(1));
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Se déconnecter'));
    await tester.pumpAndSettle();
    expect(data.readings, isEmpty);
    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets('Settings fit small phones with enlarged text', (tester) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openSettings(tester, CareData());
    expect(tester.takeException(), isNull);
    for (var i = 0; i < 5; i++) {
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
