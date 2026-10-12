import 'package:ecare_plus_mobile/data/doctor_catalog.dart';
import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/views/dashbord/appointments_page.dart';
import 'package:ecare_plus_mobile/views/dashbord/doctors_page.dart';
import 'package:ecare_plus_mobile/views/dashbord/home_page.dart';
import 'package:ecare_plus_mobile/views/messaging/doctor_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Saving an appointment keeps the user on the appointments page', (
    tester,
  ) async {
    final data = CareData();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: data,
        child: const MaterialApp(
          home: AppointmentsPage(initialDoctor: 'Dr Test'),
        ),
      ),
    );
    await tester.tap(find.text('Choisir une date'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await tester.enterText(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextFormField),
      ),
      '${tomorrow.month}/${tomorrow.day}/${tomorrow.year}',
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Choisir une heure'));
    await tester.tap(find.text('Choisir une heure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enregistrer dans mon agenda'));
    await tester.tap(find.text('Enregistrer dans mon agenda'));
    await tester.pumpAndSettle();
    expect(data.appointments.single.doctor, 'Dr Test');
    expect(find.text('Mes rendez-vous'), findsOneWidget);
    expect(find.text('Dr Test'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final entry in <String, Widget>{
    'Planifier': const HomePage(),
    'Ajouter à mon agenda': const DoctorsPage(),
    'Prendre rendez-vous': DoctorContactPage(doctor: doctorCatalog.first),
  }.entries) {
    testWidgets('${entry.key} opens appointments with the selected doctor', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CareData(),
          child: MaterialApp(home: Scaffold(body: entry.value)),
        ),
      );
      final button = find.text(entry.key).first;
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Mes rendez-vous'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .controller!
            .text,
        doctorCatalog.first.name,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Adding an appointment uses the form inside the appointments page',
    (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CareData(),
          child: const MaterialApp(home: AppointmentsPage()),
        ),
      );
      await tester.tap(find.text('Ajouter un rendez-vous'));
      await tester.pumpAndSettle();
      expect(find.text('Mes rendez-vous'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      await tester.ensureVisible(find.text('Enregistrer dans mon agenda'));
      await tester.tap(find.text('Enregistrer dans mon agenda'));
      await tester.pumpAndSettle();
      expect(find.text('Indiquez le nom du médecin'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
