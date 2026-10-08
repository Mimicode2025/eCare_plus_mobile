import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/views/notification/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

Future<void> openNotifications(WidgetTester tester, CareData data) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: data,
      child: const MaterialApp(home: NotificationsPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Filters and notification cards fit enlarged text on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final data = CareData();
    data.addAppointment(
      CareAppointment(
        doctor: 'Dr André, consultation de suivi',
        date: DateTime(2026, 10, 12),
      ),
    );
    await openNotifications(tester, data);
    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Voir mes rendez-vous'), findsOneWidget);
  });

  testWidgets('Search combines with category and can be cleared', (
    tester,
  ) async {
    final data = CareData();
    data.addAppointment(
      CareAppointment(doctor: 'Dr André', date: DateTime(2026, 10, 12)),
    );
    data.addNotification(
      CareNotification(
        title: 'Prendre le traitement',
        message: 'Rappel du matin',
        date: DateTime(2026, 10, 8),
        category: NotificationCategory.medication,
      ),
    );
    await openNotifications(tester, data);
    await tester.enterText(find.byType(TextField), 'ANDRE');
    await tester.pumpAndSettle();
    expect(find.text('Dr André'), findsOneWidget);
    expect(find.text('Prendre le traitement'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Médicaments'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun résultat'), findsOneWidget);
    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(find.text('Prendre le traitement'), findsOneWidget);
    expect(find.text('Dr André'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Toutes'));
    await tester.pumpAndSettle();
    expect(find.text('Dr André'), findsOneWidget);
  });

  testWidgets('Every category filters its own notifications', (tester) async {
    final data = CareData();
    for (final category in NotificationCategory.values) {
      data.addNotification(
        CareNotification(
          title: 'Message ${category.name}',
          message: 'Information',
          date: DateTime(2026, 10, 8),
          category: category,
        ),
      );
    }
    await openNotifications(tester, data);
    for (final entry in {
      'Médicaments': NotificationCategory.medication,
      'Rendez-vous': NotificationCategory.appointment,
      'Constantes': NotificationCategory.measurement,
      'Alertes': NotificationCategory.alert,
    }.entries) {
      await tester.tap(find.widgetWithText(ChoiceChip, entry.key));
      await tester.pumpAndSettle();
      expect(find.text('Message ${entry.value.name}'), findsOneWidget);
      for (final other in NotificationCategory.values.where(
        (c) => c != entry.value,
      )) {
        expect(find.text('Message ${other.name}'), findsNothing);
      }
    }
    data.setReminders(false);
    await tester.pumpAndSettle();
    expect(find.text('Message alert'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Rendez-vous'));
    await tester.pumpAndSettle();
    expect(
      find.text('Les rappels de rendez-vous sont désactivés'),
      findsOneWidget,
    );
    expect(find.text('Message appointment'), findsNothing);
    data.clear();
    expect(data.notifications, isEmpty);
  });
}
