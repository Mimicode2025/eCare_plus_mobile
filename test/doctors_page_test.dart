import 'package:ecare_plus_mobile/views/dashbord/doctors_page.dart';
import 'package:ecare_plus_mobile/views/messaging/doctor_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/views/messaging/doctor_chat_page.dart';

void main() {
  testWidgets('Search filters doctors and clearing restores the directory', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DoctorsPage()));
    expect(find.text('Tous'), findsNothing);
    expect(find.text('Suivi personnalisé'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Cardiologue');
    await tester.pumpAndSettle();
    expect(find.text('Dr Lawson Jennifer'), findsOneWidget);
    expect(find.text('Dr Johnson Mike'), findsNothing);
    await tester.enterText(find.byType(TextField), 'inconnu');
    await tester.pumpAndSettle();
    expect(find.text('Aucun résultat'), findsOneWidget);
    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(find.text('Dr Johnson Mike'), findsOneWidget);
  });

  testWidgets('Doctor card opens the selected profile', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DoctorsPage()));
    await tester.tap(find.text('Dr Johnson Mike').first);
    await tester.pumpAndSettle();
    expect(find.byType(DoctorContactPage), findsOneWidget);
    expect(find.text('Dr Johnson Mike'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('The blue message button opens chat instead of the profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CareData(),
        child: const MaterialApp(home: DoctorsPage()),
      ),
    );
    await tester.tap(find.text('Message').first);
    await tester.pumpAndSettle();
    expect(find.byType(DoctorChatPage), findsOneWidget);
    expect(find.byType(DoctorContactPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'Doctor cards remain usable on a narrow phone at scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (_) => CareData(),
            child: const MaterialApp(home: DoctorsPage()),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Ajouter à mon agenda').first);
        await tester.tap(find.text('Ajouter à mon agenda').first);
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
