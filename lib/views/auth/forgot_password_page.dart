import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/underline_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _sendResetLink() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // TODO: Appel service de réinitialisation
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Décoration haut (dégradé)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 190,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF3BBFF3)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mot de passe oublié',
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        'Nous vous enverrons un lien de réinitialisation',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withAlpha(200),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenu
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 160),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(20),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _emailSent
                            ? _SuccessView(
                                email: _emailController.text,
                                onBackToLogin: () => Navigator.pushNamedAndRemoveUntil(
                                    context, AppRoutes.login, (r) => false),
                              )
                            : Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icône centrale
                                    Center(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLighter,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.lock_reset_rounded,
                                          color: AppColors.primary,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Description
                                    Text(
                                      'Entrez votre adresse email ou votre numéro de téléphone pour recevoir un lien de réinitialisation.',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.body.copyWith(
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                    const SizedBox(height: 28),

                                    // Email ou téléphone
                                    UnderlineTextField(
                                      label: 'Email ou téléphone',
                                      isRequired: true,
                                      controller: _emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      hintText: 'exemple@email.com',
                                      prefixIcon: const Icon(
                                          Icons.email_outlined,
                                          color: AppColors.textHint,
                                          size: 20),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Ce champ est obligatoire';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 36),

                                    // Bouton
                                    PrimaryButton(
                                      text: 'Envoyer le lien',
                                      onPressed: _sendResetLink,
                                      isLoading: _isLoading,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Retour connexion
                  if (!_emailSent)
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Retour à la connexion',
                            style: AppTextStyles.link.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget affiché quand le mail a été envoyé avec succès
class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;

  const _SuccessView({required this.email, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icône succès
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Email envoyé !',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Un lien de réinitialisation a été envoyé à\n',
            style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.6),
            children: [
              TextSpan(
                text: email,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              TextSpan(
                text: '\n\nVérifiez votre boîte mail et suivez les instructions.',
                style: AppTextStyles.body.copyWith(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onBackToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Retour à la connexion',
                style: AppTextStyles.button),
          ),
        ),
      ],
    );
  }
}
