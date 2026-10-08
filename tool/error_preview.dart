// Browser preview only: the retry actions switch between the two error designs.
import 'package:ecare_plus_mobile/utils/app_colors.dart';
import 'package:ecare_plus_mobile/views/error/no_connection_page.dart';
import 'package:ecare_plus_mobile/views/error/page_not_found_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const _ErrorPreview());

class _ErrorPreview extends StatelessWidget {
  const _ErrorPreview();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'eCARE+ — Aperçu des pages d’erreur',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary,
        primary: AppColors.primary, secondary: AppColors.primaryLight,
        surface: AppColors.scaffoldBackground),
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Poppins'),
      useMaterial3: true,
    ),
    builder: (context, child) => ColoredBox(
      color: AppColors.scaffoldBackground,
      child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430), child: child)),
    ),
    routes: {
      '/': (context) => NoConnectionPage(onRetry: () async {
        Navigator.pushReplacementNamed(context, '/not-found');
      }),
      '/not-found': (context) => PageNotFoundPage(onRetry: () async {
        Navigator.pushReplacementNamed(context, '/');
      }),
    },
  );
}
