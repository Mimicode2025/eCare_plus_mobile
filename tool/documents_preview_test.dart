import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/main.dart';
import 'package:ecare_plus_mobile/models/medical_document.dart';
import 'package:ecare_plus_mobile/services/document_library.dart';
import 'package:ecare_plus_mobile/services/document_storage_io.dart';
import 'package:ecare_plus_mobile/views/dashbord/documents_page.dart';
import 'package:ecare_plus_mobile/views/onbording/splash_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Preview the health notebook, populated, empty and responsive', (
    tester,
  ) async {
    final root = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('ecare-notebook-preview-'),
    ))!;
    final library = DocumentLibrary(
      storage: LocalDocumentStorage(directory: root),
    );
    addTearDown(() async {
      library.dispose();
      await root.delete(recursive: true);
    });
    await tester.runAsync(() async {
      await library.load();
      await library.setConditions(MedicalCondition.values.toSet());
      final fonts = FontLoader('Poppins');
      for (final weight in ['Regular', 'SemiBold', 'Bold']) {
        fonts.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
      }
      await fonts.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: boundary, child: const ECarePlusApp()),
    );
    Navigator.of(tester.element(find.byType(SplashScreen))).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => DocumentsPage(library: library)),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts').create(recursive: true);
        await File(
          'artifacts/documents-$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('empty');
    await tester.runAsync(() async {
      for (final record in [
        (
          'Bilan HbA1c',
          DocumentCategory.results,
          {MedicalCondition.diabetes},
          DateTime(2026, 10, 14),
        ),
        (
          'Ordonnance de suivi',
          DocumentCategory.prescription,
          {MedicalCondition.diabetes, MedicalCondition.hypertension},
          DateTime(2026, 10, 10),
        ),
        (
          'Compte rendu de consultation',
          DocumentCategory.report,
          <MedicalCondition>{},
          DateTime(2026, 9, 28),
        ),
      ]) {
        await library.importFile(
          XFile.fromData(
            Uint8List.fromList('%PDF-1.4\n%%EOF'.codeUnits),
            path: 'document.pdf',
          ),
          title: record.$1,
          category: record.$2,
          conditions: record.$3,
          date: record.$4,
        );
      }
    });
    await tester.pumpAndSettle();
    await capture('notebook');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -370),
    );
    await tester.pumpAndSettle();
    await capture('list');
    tester.view.physicalSize = const Size(320, 740);
    await tester.pumpAndSettle();
    await capture('small');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 3));
  });
}
