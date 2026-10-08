import 'package:flutter/material.dart';

class CareDoctor {
  final String name;
  final String specialty;
  final IconData icon;
  final Color color;
  const CareDoctor(this.name, this.specialty, this.icon, this.color);
}

// Illustrative profiles from the existing home screen, awaiting the directory.
const doctorCatalog = [
  CareDoctor(
    'Dr Johnson Mike',
    'Médecin généraliste',
    Icons.medical_services_outlined,
    Color(0xFFE4F2FF),
  ),
  CareDoctor(
    'Dr Lawson Jennifer',
    'Cardiologue',
    Icons.monitor_heart_outlined,
    Color(0xFFE4F5F1),
  ),
];
