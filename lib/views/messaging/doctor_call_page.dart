import 'package:flutter/material.dart';
import '../../data/doctor_catalog.dart';
import '../../utils/app_colors.dart';
import '../../widgets/page_header.dart';
import 'doctor_video_preview.dart';

class DoctorCallPage extends StatefulWidget {
  final CareDoctor doctor;
  final bool video;
  const DoctorCallPage({super.key, required this.doctor, required this.video});

  @override
  State<DoctorCallPage> createState() => _DoctorCallPageState();
}

class _DoctorCallPageState extends State<DoctorCallPage> {
  bool _muted = false;
  bool _speaker = false;

  Widget _audioControl(
    String label,
    String tooltip,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) => SizedBox(
    width: 86,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9DAFC1).withValues(alpha: .2),
                blurRadius: 14,
                offset: const Offset(5, 5),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 14,
                offset: Offset(-5, -5),
              ),
            ],
          ),
          child: Semantics(
            selected: selected,
            child: IconButton.filledTonal(
              tooltip: tooltip,
              onPressed: onTap,
              style: IconButton.styleFrom(
                minimumSize: const Size(58, 58),
                shape: const CircleBorder(),
                backgroundColor: selected
                    ? AppColors.primary
                    : const Color(0xFFF8FAFD),
                foregroundColor: selected ? Colors.white : AppColors.textMuted,
              ),
              icon: Icon(icon, size: 25),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _audioScreen(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF2F6FA),
    body: Stack(
      children: [
        Positioned(
          right: -140,
          top: -100,
          child: IgnorePointer(
            child: Container(
              width: 330,
              height: 330,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primaryLighter, Color(0x00E6F2FC)],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 40).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const PageBackButton(),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Appel audio',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.headset_mic_outlined,
                          color: AppColors.primary,
                          size: 23,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(
                        children: [
                          Container(
                            width: 184,
                            height: 184,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE9EFF5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF879BAF,
                                  ).withValues(alpha: .2),
                                  blurRadius: 24,
                                  offset: const Offset(8, 8),
                                ),
                                const BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 24,
                                  offset: Offset(-8, -8),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF8FAFD),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: AssetImage(
                                  widget.doctor.imageAsset,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            widget.doctor.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.doctor.specialty,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLighter,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Text(
                              '00:00 · Aperçu',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 20,
                          children: [
                            _audioControl(
                              'Vidéo',
                              'Passer en vidéo',
                              Icons.videocam_outlined,
                              false,
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => DoctorCallPage(
                                    doctor: widget.doctor,
                                    video: true,
                                  ),
                                ),
                              ),
                            ),
                            _audioControl(
                              'Haut-parleur',
                              'Haut-parleur',
                              Icons.volume_up_outlined,
                              _speaker,
                              () => setState(() => _speaker = !_speaker),
                            ),
                            _audioControl(
                              _muted ? 'Micro coupé' : 'Micro',
                              'Micro',
                              _muted
                                  ? Icons.mic_off_outlined
                                  : Icons.mic_none_rounded,
                              _muted,
                              () => setState(() => _muted = !_muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFE86F7A,
                                ).withValues(alpha: .25),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: IconButton.filled(
                            tooltip: 'Terminer l’appel',
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFE86F7A),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(68, 68),
                              shape: const CircleBorder(),
                            ),
                            icon: const Icon(Icons.call_end_rounded, size: 29),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Terminer',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Aperçu de l’interface · Aucun appel lancé',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => widget.video
      ? DoctorVideoPreview(doctor: widget.doctor)
      : _audioScreen(context);
}
