import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';

class RegistrationSuccessPage extends StatelessWidget {
  const RegistrationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cercle de succès
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 70,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Inscription réussie !',
                style: AppTextStyles.heading2.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Votre compte eCARE+ a été créé avec succès.\nVous pouvez maintenant vous connecter et commencer à suivre votre santé.',
                style: AppTextStyles.body.copyWith(height: 1.7, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              PrimaryButton(
                text: 'Se connecter',
                onPressed: () => Navigator.pushReplacementNamed(
                    context, AppRoutes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
