import 'package:flutter/material.dart';
import '../data/doctor_catalog.dart';
import '../utils/app_colors.dart';
import '../utils/app_decor.dart';

class DoctorCareer extends StatelessWidget {
  final List<DoctorCareerStep> steps;
  const DoctorCareer({super.key, required this.steps});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < steps.length; i++)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: i == steps.length - 1
                            ? AppColors.primary
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.primaryLight,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: i < steps.length - 1 ? 26 : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].period,
                        style: AppDecor.t(
                          11,
                          c: AppColors.primary,
                          w: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        steps[i].title,
                        style: AppDecor.t(15, w: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[i].description,
                        style: AppDecor.t(13, c: AppColors.textMuted, h: 1.7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
