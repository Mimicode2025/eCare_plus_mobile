import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/care_data.dart';
import '../utils/app_colors.dart';

class PatientAvatar extends StatelessWidget {
  final double radius;
  const PatientAvatar({super.key, required this.radius});
  @override
  Widget build(BuildContext context) {
    final photo = context.select((CareData data) => data.profilePhoto);
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLighter,
      backgroundImage: photo == null
          ? const AssetImage('lib/data/Profile.png')
          : MemoryImage(photo),
    );
  }
}
