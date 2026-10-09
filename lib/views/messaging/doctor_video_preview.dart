import 'package:flutter/material.dart';
import '../../data/doctor_catalog.dart';
import '../../utils/app_colors.dart';
import '../../widgets/page_header.dart';

class DoctorVideoPreview extends StatefulWidget {
  final CareDoctor doctor;
  const DoctorVideoPreview({super.key, required this.doctor});

  @override
  State<DoctorVideoPreview> createState() => _DoctorVideoPreviewState();
}

class _DoctorVideoPreviewState extends State<DoctorVideoPreview> {
  bool _muted = false;
  bool _speaker = false;
  bool _camera = true;
  bool _frontCamera = true;

  Widget _control(
    String label,
    String tooltip,
    IconData icon,
    bool selected,
    VoidCallback action, {
    bool endCall = false,
  }) => SizedBox(
    width: 56,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    (endCall
                            ? const Color(0xFFE86F7A)
                            : const Color(0xFF9DAFC1))
                        .withValues(alpha: .22),
                blurRadius: 12,
                offset: const Offset(4, 5),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 12,
                offset: Offset(-4, -4),
              ),
            ],
          ),
          child: Semantics(
            selected: selected,
            child: IconButton.filledTonal(
              tooltip: tooltip,
              onPressed: action,
              style: IconButton.styleFrom(
                minimumSize: const Size(54, 54),
                shape: const CircleBorder(),
                backgroundColor: endCall
                    ? const Color(0xFFE86F7A)
                    : selected
                    ? AppColors.primary
                    : const Color(0xFFF8FAFD),
                foregroundColor: endCall || selected
                    ? Colors.white
                    : AppColors.textMuted,
              ),
              icon: Icon(icon, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    ),
  );

  Widget _localCamera() => Container(
    width: 106,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F7FB),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .16),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _camera ? Icons.person_outline_rounded : Icons.videocam_off_outlined,
          size: 32,
          color: AppColors.primary,
        ),
        const SizedBox(height: 10),
        Text(
          _camera ? 'Votre caméra' : 'Caméra désactivée',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        if (_camera) ...[
          const SizedBox(height: 5),
          Text(
            _frontCamera ? 'Avant' : 'Arrière',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: AppColors.textHint),
          ),
        ],
      ],
    ),
  );

  Widget _videoStage(double height) => Container(
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF879BAF).withValues(alpha: .22),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.doctor.imageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              semanticLabel:
                  'Portrait de démonstration de ${widget.doctor.name}',
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x330D1B2A),
                    Color(0x000D1B2A),
                    Color(0x770D1B2A),
                  ],
                  stops: [0, .5, 1],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 70,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '00:00 · Aperçu',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton.filledTonal(
              tooltip: 'Changer de caméra',
              onPressed: _camera
                  ? () => setState(() => _frontCamera = !_frontCamera)
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: .94),
                foregroundColor: AppColors.textMuted,
              ),
              icon: const Icon(Icons.flip_camera_ios_outlined, size: 22),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            right: 134,
            child: const Text(
              'Vue du médecin\nImage de démonstration',
              style: TextStyle(color: Colors.white, fontSize: 10, height: 1.6),
            ),
          ),
          Positioned(bottom: 14, right: 14, child: _localCamera()),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF2F6FA),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stageHeight = (constraints.maxHeight * .54).clamp(330.0, 470.0);
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const PageBackButton(),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Appel vidéo',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.videocam_outlined,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage(widget.doctor.imageAsset),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doctor.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.doctor.specialty,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _videoStage(stageHeight),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F6FA),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF9DAFC1,
                            ).withValues(alpha: .15),
                            blurRadius: 18,
                            offset: const Offset(6, 7),
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            blurRadius: 18,
                            offset: Offset(-6, -6),
                          ),
                        ],
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 8,
                        runSpacing: 18,
                        children: [
                          _control(
                            'Son',
                            'Haut-parleur',
                            Icons.volume_up_outlined,
                            _speaker,
                            () => setState(() => _speaker = !_speaker),
                          ),
                          _control(
                            'Micro',
                            'Micro',
                            _muted
                                ? Icons.mic_off_outlined
                                : Icons.mic_none_rounded,
                            _muted,
                            () => setState(() => _muted = !_muted),
                          ),
                          _control(
                            'Caméra',
                            'Caméra',
                            _camera
                                ? Icons.videocam_outlined
                                : Icons.videocam_off_outlined,
                            !_camera,
                            () => setState(() => _camera = !_camera),
                          ),
                          _control(
                            'Terminer',
                            'Terminer l’appel',
                            Icons.call_end_rounded,
                            false,
                            () => Navigator.pop(context),
                            endCall: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Aperçu de l’interface · Aucun appel lancé',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
