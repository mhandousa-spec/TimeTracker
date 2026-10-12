import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

/// White, rounded, shadowed card wrapper used for every "Details" section
/// (Policy Details, Control Details, Submissions/Approvals, ...) across the
/// Assignment Controls and Approvals pages. Extracted because both features
/// built the exact same container markup independently.
class GrcSectionCard extends StatelessWidget {
  final List<Widget> children;
  final Color? color;

  const GrcSectionCard({super.key, required this.children, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: color,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
