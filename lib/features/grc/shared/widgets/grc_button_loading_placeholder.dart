import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

/// Fixed-size loading placeholder shown in place of an action button while
/// its async handler is running. Extracted because control_owner's details
/// page duplicated this exact Container+spinner block for its
/// Reassign/Edit buttons.
class GrcButtonLoadingPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const GrcButtonLoadingPlaceholder({
    super.key,
    this.width = 135,
    this.height = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        height: 18,
        width: 18,
        child: const CircleProgressMaster(),
      ),
    );
  }
}
