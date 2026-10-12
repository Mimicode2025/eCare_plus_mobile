import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/utils/app_colors.dart';
import 'package:ecare_plus_mobile/views/measurement/glucose_follow_up_page.dart';
import 'package:ecare_plus_mobile/views/measurement/blood_pressure_follow_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Example measurements are confined to this visual preview tool.
void main() {
  testWidgets('Render the two dedicated follow-up screens', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final fonts = FontLoader('Poppins');
      for (final weight in ['Regular', 'SemiBold', 'Bold']) {
        fonts.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
      }
      await fonts.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final data = CareData();
    final now = DateTime.now();
    for (var i = 0; i < 6; i++) {
      final date = DateTime(now.year, now.month, now.day - 6 + i, 8 + i * 2);
      data.addReading([112.0, 105.0, 118.0, 98.0, 102.0, 96.0][i], date: date);
      data.addBloodPressure(
        [128.0, 124.0, 130.0, 122.0, 120.0, 125.0][i],
        [84.0, 82.0, 86.0, 80.0, 78.0, 81.0][i],
        date: date,
      );
    }
    for (final pressure in [false, true]) {
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: ChangeNotifierProvider.value(
            value: data,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  primary: AppColors.primary,
                ),
                textTheme: ThemeData.light().textTheme.apply(
                  fontFamily: 'Poppins',
                ),
              ),
              home: pressure
                  ? const BloodPressureFollowUpPage()
                  : const GlucoseFollowUpPage(),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('lib/data/Icon_bon a savoir.png'),
          tester.element(find.byType(MaterialApp)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final picture = await render.toImage(pixelRatio: 2);
        final bytes = await picture.toByteData(format: ui.ImageByteFormat.png);
        await Directory('artifacts').create(recursive: true);
        await File(
          'artifacts/suivi-${pressure ? 'hypertension' : 'diabete'}-exemple.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        picture.dispose();
      });
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
