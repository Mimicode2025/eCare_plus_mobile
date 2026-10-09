import 'package:flutter/material.dart';
import '../data/doctor_catalog.dart';
import '../utils/app_colors.dart';
import '../views/messaging/doctor_chat_page.dart';

class DoctorMessageButton extends StatelessWidget {
  final CareDoctor doctor;
  const DoctorMessageButton({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: 'Message à ${doctor.name}',
    style: IconButton.styleFrom(
      minimumSize: const Size(44, 44),
      backgroundColor: AppColors.primaryLighter,
      foregroundColor: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => DoctorChatPage(doctor: doctor)),
    ),
    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 23),
  );
}
