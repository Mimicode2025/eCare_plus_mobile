import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/auth_field.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/social_auth_row.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  late final Animation<Offset> _slide =
      Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
          .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: appel du service d'authentification
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const AuthHeader(
                title: 'Content de vous\nrevoir !',
                subtitle: 'Connectez-vous pour poursuivre votre suivi personnalisé.',
                height: 310,
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Transform.translate(
                        offset: const Offset(0, -52),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0B2A5B).withAlpha(26),
                                blurRadius: 40,
                                offset: const Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    AuthField(
                                      label: "Nom d'utilisateur",
                                      controller: _userController,
                                      icon: Icons.person_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                              ? 'Ce champ est obligatoire'
                                              : null,
                                    ),
                                    const SizedBox(height: 16),
                                    AuthField(
                                      label: 'Mot de passe',
                                      controller: _passwordController,
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscure,
                                      textInputAction: TextInputAction.done,
                                      suffix: IconButton(
                                        tooltip: _obscure
                                            ? 'Afficher le mot de passe'
                                            : 'Masquer le mot de passe',
                                        onPressed: () =>
                                            setState(() => _obscure = !_obscure),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppColors.textHint,
                                          size: 21,
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v == null || v.isEmpty)
                                              ? 'Ce champ est obligatoire'
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                      context, AppRoutes.forgotPassword),
                                  child: Text(
                                    'Mot de passe oublié ?',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              GradientButton(
                                text: 'Se connecter',
                                onPressed: _login,
                                isLoading: _loading,
                              ),
                              const SizedBox(height: 26),
                              const SocialAuthRow(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -34),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Nouveau sur eCare+ ?',
                          style: AppTextStyles.body.copyWith(
                              fontSize: 14.5, color: AppColors.textMuted)),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: Text('Créer un compte',
                            style: AppTextStyles.link.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}
