import 'package:ecare_plus_mobile/data/doctor_catalog.dart';
import 'package:ecare_plus_mobile/views/messaging/doctor_call_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Video preview offers camera switching and camera disabling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: DoctorCallPage(doctor: doctorCatalog.first, video: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Votre caméra'), findsOneWidget);
    await tester.tap(find.byTooltip('Changer de caméra'));
    await tester.pump();
    expect(find.text('Arrière'), findsOneWidget);
    await tester.tap(find.byTooltip('Caméra'));
    await tester.pumpAndSettle();
    expect(find.text('Caméra désactivée'), findsOneWidget);
    expect(find.byTooltip('Changer de caméra').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Video preview stays usable on a small phone with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        home: DoctorCallPage(doctor: doctorCatalog.first, video: true),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Terminer l’appel'));
    expect(find.byTooltip('Terminer l’appel').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Audio call preview offers a transition to video', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: DoctorCallPage(doctor: doctorCatalog.first, video: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Aperçu de l’interface · Aucun appel lancé'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Micro'));
    await tester.pump();
    expect(find.byIcon(Icons.mic_off_outlined), findsOneWidget);
    await tester.tap(find.byTooltip('Haut-parleur'));
    await tester.pump();
    await tester.tap(find.byTooltip('Passer en vidéo'));
    await tester.pumpAndSettle();
    expect(find.text('Appel vidéo'), findsOneWidget);
    expect(find.text('Votre caméra'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Audio controls remain reachable with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        home: DoctorCallPage(doctor: doctorCatalog.first, video: false),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Terminer l’appel'));
    expect(find.byTooltip('Terminer l’appel').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
