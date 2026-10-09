import 'package:flutter/material.dart';
import '../data/doctor_catalog.dart';
import '../services/doctor_contact_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

class DoctorSocialLinks extends StatelessWidget {
  final CareDoctor doctor;
  final DoctorContactService? contactService;
  const DoctorSocialLinks({
    super.key,
    required this.doctor,
    this.contactService,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 14,
    runSpacing: 14,
    children: [
      _contact(
        context,
        'WhatsApp',
        Icons.chat_outlined,
        const Color(0xFF128C5E),
        doctor.whatsappUrl,
      ),
      _contact(
        context,
        'Facebook',
        Icons.facebook,
        AppColors.facebookBlue,
        doctor.facebookUrl,
      ),
      _contact(
        context,
        'TikTok',
        Icons.music_note_rounded,
        AppColors.textDark,
        doctor.tiktokUrl,
      ),
    ],
  );

  Widget _contact(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String? url,
  ) {
    final available = DoctorContactService.contactUri(url) != null;
    return SizedBox(
      width: 94,
      child: Column(
        children: [
          Tooltip(
            message: available
                ? 'Ouvrir $label'
                : '$label : contact non renseigné',
            child: SizedBox(
              width: 56,
              height: 56,
              child: IconButton.filledTonal(
                onPressed: available
                    ? () async {
                        final opened =
                            await (contactService ?? DoctorContactService())
                                .open(url);
                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Impossible d’ouvrir $label. Réessayez plus tard.',
                              ),
                            ),
                          );
                        }
                      }
                    : null,
                style: IconButton.styleFrom(
                  backgroundColor: color.withValues(alpha: .09),
                  foregroundColor: color,
                  disabledBackgroundColor: const Color(0xFFF1F4F7),
                  disabledForegroundColor: AppColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: Icon(icon, size: 27),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppDecor.t(12, w: FontWeight.w600),
          ),
          if (!available)
            Text(
              'Indisponible',
              textAlign: TextAlign.center,
              style: AppDecor.t(10, c: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}
