import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_decor.dart';
import '../../widgets/gradient_button.dart';
import '../../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  /// true = première connexion : après "Enregistrer" on va au dashboard.
  final bool firstTime;
  const ProfilePage({super.key, this.firstTime = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _prenom = TextEditingController();
  final _poids = TextEditingController();
  final _taille = TextEditingController();
  String? _sexe;
  String? _groupe;
  bool _loading = false;

  @override
  void dispose() {
    _nom.dispose();
    _prenom.dispose();
    _poids.dispose();
    _taille.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Ce champ est obligatoire' : null;

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // TODO: enregistrer le profil via ton service
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    if (widget.firstTime) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (r) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    if (!widget.firstTime)
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: AppDecor.shadow()),
                          child: const Icon(Icons.arrow_back_rounded,
                              color: AppColors.textDark),
                        ),
                      )
                    else
                      const SizedBox(width: 42),
                    Expanded(
                      child: Text('Votre profil',
                          textAlign: TextAlign.center,
                          style: AppDecor.t(20, w: FontWeight.w700, c: AppColors.primary)),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
                const SizedBox(height: 22),
                _Avatar(onAdd: () {
                  // TODO: image_picker
                }),
                const SizedBox(height: 28),
                _Label('Nom'),
                _input(_nom, 'Votre nom', validator: _required),
                _Label('Prénom'),
                _input(_prenom, 'Votre prénom', validator: _required),
                _Label('Sexe'),
                _dropdown(_sexe, const ['Femme', 'Homme'],
                    (v) => setState(() => _sexe = v)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Poids (kg)'),
                          _input(_poids, '70',
                              number: true, validator: _required),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Taille (cm)'),
                          _input(_taille, '175',
                              number: true, validator: _required),
                        ],
                      ),
                    ),
                  ],
                ),
                _Label('Groupe sanguin (facultatif)'),
                _dropdown(
                    _groupe,
                    const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                    (v) => setState(() => _groupe = v)),
                const SizedBox(height: 30),
                GradientButton(
                    text: 'Enregistrer',
                    onPressed: _save,
                    isLoading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppDecor.t(14, c: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, 1.6),
        errorBorder: _border(Colors.redAccent),
        focusedErrorBorder: _border(Colors.redAccent, 1.6),
      );

  OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: c, width: w),
      );

  Widget _input(TextEditingController c, String hint,
      {bool number = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      validator: validator,
      keyboardType: number ? TextInputType.number : TextInputType.name,
      style: AppDecor.t(14.5, w: FontWeight.w600),
      decoration: _deco(hint),
    );
  }

  Widget _dropdown(
      String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
      decoration: _deco('Sélectionner'),
      style: AppDecor.t(14.5, w: FontWeight.w600),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
          child: Text(text, style: AppDecor.t(13, w: FontWeight.w600)),
        ),
      );
}

class _Avatar extends StatelessWidget {
  final VoidCallback onAdd;
  const _Avatar({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
              gradient: AppDecor.gradient, shape: BoxShape.circle),
          child: const CircleAvatar(
            radius: 58,
            backgroundColor: AppColors.primaryLighter,
            backgroundImage: AssetImage('assets/images/avatar.png'),
            onBackgroundImageError: _ignore,
            child: Icon(Icons.person_rounded, size: 56, color: AppColors.primary),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 6,
          child: GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 19),
            ),
          ),
        ),
      ],
    );
  }
}

void _ignore(Object e, StackTrace? s) {}
