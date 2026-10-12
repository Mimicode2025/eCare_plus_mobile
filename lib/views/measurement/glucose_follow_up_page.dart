import 'package:flutter/material.dart';
import 'follow_up_page.dart';

/// Dedicated screen for a patient whose configured follow-up is glucose only.
class GlucoseFollowUpPage extends StatelessWidget {
  const GlucoseFollowUpPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const FollowUpPage(mode: FollowUpMode.glucose);
}
