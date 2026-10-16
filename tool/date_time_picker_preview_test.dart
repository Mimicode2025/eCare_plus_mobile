import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/widgets/care_date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Compact pickers select, cancel and fit a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      await (FontLoader(
        'Poppins',
      )..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))).load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final boundary = GlobalKey();
    DateTime? date;
    TimeOfDay? time;
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Poppins'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        date = await showCareDatePicker(
                          context: context,
                          initialDate: DateTime(2026, 10, 16),
                          firstDate: DateTime(2026, 10, 1),
                          lastDate: DateTime(2026, 12, 31),
                        );
                      },
                      child: const Text('Date'),
                    ),
                    TextButton(
                      onPressed: () async {
                        time = await showCareTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 14, minute: 30),
                        );
                      },
                      child: const Text('Heure'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final picture = await render.toImage(pixelRatio: 2);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        final file = File('artifacts/picker-$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
    }

    await tester.tap(find.text('Date'));
    await tester.pumpAndSettle();
    await capture('date');
    expect(
      tester.getSize(find.byType(CalendarDatePicker)).height,
      lessThan(400),
    );
    await tester.tap(find.text('20'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(date, DateTime(2026, 10, 20));
    await tester.tap(find.text('Heure'));
    await tester.pumpAndSettle();
    await capture('time');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(time, const TimeOfDay(hour: 14, minute: 30));
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    for (final label in ['Date', 'Heure']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      await capture('$label-small');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
    expect(date, isNull);
    expect(time, isNull);
    expect(tester.takeException(), isNull);
  });
}
