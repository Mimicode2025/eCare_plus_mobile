import 'dart:io';
import 'dart:ui' as ui;
import 'package:ecare_plus_mobile/models/care_data.dart';
import 'package:ecare_plus_mobile/widgets/main_shell.dart';
import 'package:ecare_plus_mobile/widgets/raised_navigation_bar.dart';
import 'package:ecare_plus_mobile/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Render the raised navigation in the application', (
    tester,
  ) async {
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
    final boundary = GlobalKey();
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
            home: const MainShell(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final context = tester.element(find.byType(MainShell));
      await Future.wait(
        manifest
            .listAssets()
            .where((asset) => asset.toLowerCase().endsWith('.png'))
            .map((asset) => precacheImage(AssetImage(asset), context)),
      );
    });
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

    await capture('dashboard-v3-accueil');
    await tester.tap(find.byTooltip('Ajouter mes constantes'));
    await tester.pumpAndSettle();
    await capture('dashboard-v3-ajout');
    Navigator.of(tester.element(find.text('Ajouter une constante'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Articles').last);
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => precacheImage(
        const AssetImage('assets/images/ecareImage1.png'),
        tester.element(find.byType(MainShell)),
      ),
    );
    await tester.pumpAndSettle();
    await capture('dashboard-v3-articles');
    await tester.tap(find.text('Paramètres').last);
    await tester.pumpAndSettle();
    await capture('dashboard-v3-parametres');
    expect(find.byType(RaisedNavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
