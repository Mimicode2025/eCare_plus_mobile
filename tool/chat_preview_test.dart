import 'dart:io';
import '../test/chat_media_test.dart' show DeviceMedia;
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/data/doctor_catalog.dart';
import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/utils/app_colors.dart';
import 'package:ecare_plus_mobile/views/messaging/doctor_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Render classified emoji picker at mobile widths', (
    tester,
  ) async {
    // This tool is executed as a Flutter widget test.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.runAsync(() async {
      final fonts = FontLoader('Poppins');
      for (final weight in ['Regular', 'SemiBold', 'Bold']) {
        fonts.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
      }
      await fonts.load();
      await (FontLoader('Segoe UI Emoji')..addFont(
            File(
              'C:/Windows/Fonts/seguiemj.ttf',
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          ))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    final boundary = GlobalKey();
    final media = DeviceMedia();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: ChangeNotifierProvider(
          create: (_) => CareData(),
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
            home: DoctorChatPage(
              doctor: doctorCatalog.first,
              mediaService: media,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => precacheImage(
        AssetImage(doctorCatalog.first.imageAsset),
        tester.element(find.byType(DoctorChatPage)),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Bonjour docteur ');
    await tester.tap(find.byTooltip('Choisir un emoji'));
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
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

    await capture('chat-emojis');
    tester.view.physicalSize = const Size(320, 740);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    await tester.pumpAndSettle();
    await capture('chat-emojis-small');
    tester.view.physicalSize = const Size(390, 844);
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    await tester.pumpAndSettle();
    if (find.byTooltip('Afficher le clavier').evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip('Afficher le clavier'));
    }
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '');
    await tester.pump();
    await tester.tap(find.byTooltip('Message vocal'));
    await tester.pump();
    await tester.pump();
    for (final level in [
      -58.0,
      -47.0,
      -32.0,
      -15.0,
      -24.0,
      -7.0,
      -18.0,
      -35.0,
      -44.0,
      -19.0,
      -10.0,
      -24.0,
      -38.0,
      -13.0,
      -6.0,
      -28.0,
      -18.0,
      -37.0,
      -22.0,
      -12.0,
      -32.0,
      -48.0,
      -22.0,
      -8.0,
      -15.0,
      -30.0,
      -16.0,
      -40.0,
      -31.0,
      -10.0,
      -21.0,
      -35.0,
      -45.0,
      -19.0,
    ]) {
      media.levels.add(level);
      await tester.pump();
    }
    await tester.pump(const Duration(seconds: 40));
    await capture('chat-recording-waveform');
    tester.view.physicalSize = const Size(320, 740);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    await tester.pump();
    await capture('chat-recording-waveform-small');
    expect(find.byTooltip('Envoyer le vocal').hitTestable(), findsOneWidget);
    await tester.tap(find.byTooltip('Annuler le vocal'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byTooltip('Message vocal').hitTestable(), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
