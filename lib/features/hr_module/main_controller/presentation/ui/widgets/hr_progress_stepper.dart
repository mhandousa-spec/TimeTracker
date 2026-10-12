// ***************************** FILE INFO ***************************** //
// File Name: hr_progress_stepper.dart
// Purpose: Displays a localized, horizontally scrollable HR flow stepper.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays labeled flow steps with segmented progress bars.
class HrProgressStepper extends StatelessWidget {
  const HrProgressStepper({
    super.key,
    required this.items,
    required this.currentItem,
    required this.progressAmount,
    this.stepProgressAmounts,
  });

  final List<String> items;
  final int currentItem;
  final double progressAmount;

  /// Optional actual completion ratios for every step, in item order.
  ///
  /// When omitted, the stepper preserves its legacy behavior of filling each
  /// step before the active step completely.
  final List<double>? stepProgressAmounts;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final activeItem = currentItem.clamp(0, items.length - 1);
    final activeProgress = progressAmount.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = math.max(
          140.w,
          constraints.maxWidth / items.length,
        );
        final contentWidth = itemWidth * items.length;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: contentWidth,
              child: Row(
                children: List.generate(
                  items.length,
                  (index) => _buildStep(
                    label: items[index],
                    index: index,
                    itemWidth: itemWidth,
                    activeItem: activeItem,
                    activeProgress: activeProgress,
                    stepProgress: _stepProgressFor(index),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Method Name: [_stepProgressFor]
  ///
  /// Purpose: Resolves an explicitly supplied completion ratio for a step,
  /// while retaining the legacy current-step behavior for existing callers.
  ///
  /// Parameters:
  /// - [index]: Zero-based step index to resolve.
  ///
  /// Returns: The supplied clamped ratio, or null when legacy behavior applies.
  double? _stepProgressFor(int index) {
    final amounts = stepProgressAmounts;
    if (amounts == null || index >= amounts.length) return null;
    return amounts[index].clamp(0.0, 1.0);
  }

  /// Method Name: [_buildStep]
  ///
  /// Purpose: Builds one localized step label and its progress segment.
  ///
  /// Parameters:
  /// - [label]: Localized label displayed above the progress segment.
  /// - [index]: Zero-based index of the rendered item.
  /// - [itemWidth]: Equal width assigned to each step.
  /// - [activeItem]: Clamped current item index.
  /// - [activeProgress]: Clamped progress for the current item.
  ///
  /// Returns: A fixed-width step widget.
  Widget _buildStep({
    required String label,
    required int index,
    required double itemWidth,
    required int activeItem,
    required double activeProgress,
    required double? stepProgress,
  }) {
    final progress = stepProgress ??
        (index < activeItem
            ? 1.0
            : index == activeItem
                ? activeProgress
                : 0.0);

    return SizedBox(
      width: itemWidth,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize15Weight500.copyWith(color: AppColors.inverseBase),
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                minHeight: 8.h,
                value: progress,
                backgroundColor: AppColors.lightGrey,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
