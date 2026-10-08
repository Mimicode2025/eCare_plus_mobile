import 'package:flutter/material.dart';
import 'error_page_layout.dart';

class PageNotFoundPage extends StatelessWidget {
  final Future<void> Function()? onRetry;
  const PageNotFoundPage({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) => ErrorPageLayout(
    illustration: 'lib/data/error_404.png',
    message: 'Cette page n’est pas\ndisponible',
    onRetry: onRetry,
  );
}
