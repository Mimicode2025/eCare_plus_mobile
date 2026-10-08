import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/gradient_button.dart';

/// Shared presentation for recoverable errors. The caller owns the reload.
class ErrorPageLayout extends StatefulWidget {
  final String illustration;
  final String message;
  final Future<void> Function()? onRetry;

  const ErrorPageLayout({
    super.key,
    required this.illustration,
    required this.message,
    this.onRetry,
  });

  @override
  State<ErrorPageLayout> createState() => _ErrorPageLayoutState();
}

class _ErrorPageLayoutState extends State<ErrorPageLayout> {
  bool _loading = false;

  Future<void> _retry() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (widget.onRetry != null) {
        await widget.onRetry!();
      } else {
        final returned = await Navigator.maybePop(context);
        if (!returned && mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (_) => false,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La tentative a échoué. Vous pouvez réessayer.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageSize = math.min(300.0, constraints.maxWidth - 48);
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0, constraints.maxHeight - 48),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    widget.illustration,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Info',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 24,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      width: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: GradientButton(
                          text: 'Réessayer',
                          onPressed: _retry,
                          isLoading: _loading,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
