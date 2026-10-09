import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/data/doctor_catalog.dart';
import 'package:ecare_plus_mobile/views/messaging/doctor_contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aperçu du profil médecin', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final font = FontLoader('Poppins');
      for (final file in ['Regular', 'SemiBold', 'Bold']) {
        font.addFont(rootBundle.load('assets/fonts/Poppins-$file.ttf'));
      }
      await font.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
    });
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF159EE7),
            ),
          ),
          home: DoctorContactPage(doctor: doctorCatalog.first),
        ),
      ),
    );
    await tester.runAsync(() async {
      final context = tester.element(find.byType(DoctorContactPage));
      await precacheImage(AssetImage(doctorCatalog.first.imageAsset), context);
    });
    Future<void> capture(String name) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final picture = await render.toImage(pixelRatio: 2);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts').create(recursive: true);
        await File(
          'artifacts/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
    }

    await capture('profil-medecin-flo');
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -650),
    );
    await capture('profil-medecin-parcours');
    expect(tester.takeException(), isNull);
  });
}
