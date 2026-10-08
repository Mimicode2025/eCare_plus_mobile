import 'package:flutter/material.dart';
import 'error_page_layout.dart';

/// Display when a network request fails because connectivity is unavailable.
/// Pass the failed request as [onRetry]; this page does not detect connectivity.
class NoConnectionPage extends StatelessWidget {
  final Future<void> Function()? onRetry;
  const NoConnectionPage({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) => ErrorPageLayout(
    illustration: 'lib/data/error_pas de connection.png',
    message: 'Aucune connexion internet\ndisponible',
    onRetry: onRetry,
  );
}
