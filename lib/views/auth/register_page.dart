import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/underline_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez accepter les conditions d\'utilisation.',
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.required,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      setState(() => _isLoading = true);
      // TODO: Appel service d'inscription
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(
            context, AppRoutes.registrationSuccess);
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
                      // Bouton retour
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
                        'Créer un compte',
                        style: AppTextStyles.heading1.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'Rejoignez eCARE+ dès aujourd\'hui',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withAlpha(200),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Formulaire
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
                        padding: const EdgeInsets.all(24),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Prénom + Nom (en ligne)
                              Row(
                                children: [
                                  Expanded(
                                    child: UnderlineTextField(
                                      label: 'Prénom',
                                      isRequired: true,
                                      controller: _firstNameController,
                                      hintText: 'Jean',
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'Obligatoire'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: UnderlineTextField(
                                      label: 'Nom',
                                      isRequired: true,
                                      controller: _lastNameController,
                                      hintText: 'Dupont',
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'Obligatoire'
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),

                              // Email
                              UnderlineTextField(
                                label: 'Email',
                                isRequired: true,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                hintText: 'exemple@email.com',
                                prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: AppColors.textHint,
                                    size: 20),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Ce champ est obligatoire';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Email invalide';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              // Téléphone
                              UnderlineTextField(
                                label: 'Téléphone',
                                isRequired: true,
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                hintText: '+237 6XX XXX XXX',
                                prefixIcon: const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.textHint,
                                    size: 20),
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Ce champ est obligatoire'
                                        : null,
                              ),
                              const SizedBox(height: 22),

                              // Mot de passe
                              UnderlineTextField(
                                label: 'Mot de passe',
                                isRequired: true,
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                hintText: '••••••••',
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.textHint,
                                    size: 20),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textHint,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Ce champ est obligatoire';
                                  }
                                  if (v.length < 8) {
                                    return 'Minimum 8 caractères';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              // Confirmer mot de passe
                              UnderlineTextField(
                                label: 'Confirmer le mot de passe',
                                isRequired: true,
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                hintText: '••••••••',
                                prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.textHint,
                                    size: 20),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword),
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textHint,
                                    size: 20,
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Ce champ est obligatoire';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              // Accepter les conditions
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _acceptTerms,
                                      onChanged: (val) => setState(
                                          () => _acceptTerms = val ?? false),
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: const BorderSide(
                                          color: AppColors.borderDark),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: "J'accepte les ",
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "Conditions d'utilisation",
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' et la ',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: AppColors.textMuted,
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                'Politique de confidentialité',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),

                              // Bouton inscription
                              PrimaryButton(
                                text: "S'inscrire",
                                onPressed: _register,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lien connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style:
                            AppTextStyles.caption.copyWith(fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Se connecter',
                          style: AppTextStyles.link.copyWith(fontSize: 14),
                        ),
                      ),
                    ],
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
