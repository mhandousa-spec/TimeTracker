/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: add_component_widget.dart
/// Purpose: Declares `AddComponentWidget`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/home_card_metrics.dart';

class AddComponentWidget extends StatelessWidget {
  AddComponentWidget(
      {required this.columnIndex,
      required this.rowIndex,
      this.width,
      super.key});
  int columnIndex;
  int rowIndex;

  /// Natural width of one empty slot.
  ///
  /// Exposed because edit_home_page.dart counts how many slots fit across a
  /// row, and that arithmetic has to read the SAME number this widget draws —
  /// duplicating 125.sp at the call site is how the two drift apart.
  static double get slotWidth => 125.sp;

  /// Optional override. Null keeps [slotWidth].
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.sp),
      child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            padding: EdgeInsets.all(0.sp),
            color: AppColors.primary,
            strokeWidth: 1,
            radius: Radius.circular(8.sp),
            dashPattern: const [10, 5],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.sp),
              border: Border.all(color: AppColors.border, width: 1.sp),
              color: AppColors.field,
            ),
            // HEIGHT comes from HomeCardMetrics so an empty slot is exactly as
            // tall as a filled one beside it — that is the dimension every card
            // in a row shares.
            //
            // WIDTH is this widget's own. A placeholder has no content to
            // measure, so unlike a real card it cannot take "the width it
            // needs" — it has to state one. 125.sp is what it has always been;
            // it briefly used HomeCardMetrics.width while the cards were pinned
            // to a shared width too, and went back when they stopped being.
            height: HomeCardMetrics.height,
            width: width ?? slotWidth,
            child: Center(
              child: Icon(Icons.add, size: 24.sp, color: AppColors.text),
            ),
          )),
    );
  }
}
