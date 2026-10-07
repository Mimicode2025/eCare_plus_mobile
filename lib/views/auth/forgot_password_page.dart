import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/auth_field.dart';
import '../../widgets/gradient_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: appel du service de réinitialisation
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  void _toLogin() => Navigator.pushNamedAndRemoveUntil(
      context, AppRoutes.login, (r) => false);

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Mot de passe\noublié ?',
      subtitle: 'Pas de panique, nous vous aidons à retrouver l\'accès.',
      headerHeight: 280,
      footer: _sent
          ? null
          : TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 14, color: AppColors.primary),
              label: Text('Retour à la connexion',
                  style: AppTextStyles.link
                      .copyWith(fontSize: 14.5, fontWeight: FontWeight.w700)),
            ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _sent
            ? _SentView(
                key: const ValueKey('sent'),
                target: _controller.text.trim(),
                onBack: _toLogin,
              )
            : Form(
                key: _formKey,
                child: Column(
                  key: const ValueKey('form'),
                  children: [
                    const _RoundIcon(
                        icon: Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        bg: Color(0xFFE8F1FD)),
                    const SizedBox(height: 18),
                    Text(
                      'Entrez votre adresse e-mail. Nous vous enverrons les instructions pour modifier votre mot de passe.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          height: 1.55,
                          color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 22),
                    AuthField(
                      label: 'Adresse e-mail',
                      controller: _controller,
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Ce champ est obligatoire';
                        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
                            ? null
                            : 'E-mail invalide';
                      },
                    ),
                    const SizedBox(height: 24),
                    GradientButton(
                      text: 'Envoyer les instructions',
                      onPressed: _send,
                      isLoading: _loading,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  const _RoundIcon({required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .6, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (_, v, child) => Transform.scale(scale: v, child: child),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 38),
      ),
    );
  }
}

class _SentView extends StatelessWidget {
  final String target;
  final VoidCallback onBack;
  const _SentView({super.key, required this.target, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _RoundIcon(
            icon: Icons.mark_email_read_rounded,
            color: AppColors.success,
            bg: Color(0xFFDCFCE7)),
        const SizedBox(height: 18),
        Text('E-mail envoyé !',
            style: AppTextStyles.heading1.copyWith(
                fontSize: 22,
                color: AppColors.primary,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'Les instructions ont été envoyées à\n',
            style: AppTextStyles.body.copyWith(
                fontSize: 14, height: 1.6, color: AppColors.textMuted),
            children: [
              TextSpan(
                text: target,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const TextSpan(
                  text: '\n\nPensez à vérifier vos courriers indésirables.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),
        GradientButton(text: 'Retour à la connexion', onPressed: onBack),
      ],
    );
  }
}
