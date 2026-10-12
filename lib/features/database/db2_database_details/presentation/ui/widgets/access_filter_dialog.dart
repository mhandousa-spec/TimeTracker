/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: access_filter_dialog.dart
/// Purpose: Declares `AccessFilterDialog` and `AccessFilterResult`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The Filter card on the Access screen (Figma 7398:10662, the middle control
/// of the search row).
///
/// It filters on DEPARTMENT, not on status: the chip row directly above it
/// already owns status, and a dialog that offered the same four values would
/// leave two controls able to contradict each other — pick "Active" on the
/// chips and "Removed" in the dialog and neither reading of the screen is
/// right. Department is the axis the chips do not cover.
///
/// Built the same way as db1's `DatabaseFilterDialog` and the system-logs
/// filter: `FiltersAppBar` (custom 80) + `CustomDropdown` (custom 1) +
/// `customButton` (custom 5). Nothing about the card's shape is decided here.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/80-filters_appbar.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db2_database_details/domain/constants/database_details_constants.dart';

/// What Apply hands back. A class rather than a bare `String?` so that
/// "dismissed" (null result) and "applied with nothing selected" (a result
/// carrying null) stay different answers — without it, Reset-then-Apply would
/// be indistinguishable from tapping outside the dialog.
class AccessFilterResult {
  const AccessFilterResult(this.departmentId);

  final String? departmentId;
}

class AccessFilterDialog extends StatefulWidget {
  const AccessFilterDialog({
    super.key,
    required this.departments,
    this.initialDepartmentId,
  });

  final List<DatabaseDepartment> departments;

  /// The filter currently applied, so reopening shows what the user is
  /// actually looking at instead of an empty field.
  final String? initialDepartmentId;

  static Future<AccessFilterResult?> show(
    BuildContext context, {
    required List<DatabaseDepartment> departments,
    String? initialDepartmentId,
  }) {
    return showDialog<AccessFilterResult>(
      context: context,
      barrierColor: AppColors.totalBlack.withOpacity(0.4),
      builder: (BuildContext _) => AccessFilterDialog(
        departments: departments,
        initialDepartmentId: initialDepartmentId,
      ),
    );
  }

  @override
  State<AccessFilterDialog> createState() => _AccessFilterDialogState();
}

class _AccessFilterDialogState extends State<AccessFilterDialog> {
  /// Local draft. The table is not touched until Apply, so a user who opens
  /// the dialog, changes their mind and taps outside is left exactly where
  /// they were.
  late String? _departmentId = widget.initialDepartmentId;

  @override
  Widget build(BuildContext context) {
    final DatabaseDetailsStrings strings = DatabaseDetailsStrings.of(context);
    final bool isArabic = context.isArabic;
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: isTablet ? 60.w : 20.w),
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: 411.w,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.only(bottom: 15.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Bottom padding dropped and the gap below made explicit, for the
            // same reason db1's filter card does it: the heading's default
            // 1.8 line height plus its own padding brings ~50px of dead space
            // into a dialog this small.
            FiltersAppBar(
              imageUrl:
                  'assets/icons_assets/main_icons_assets/filter_sliders.svg',
              title: strings.filter,
              padding: EdgeInsets.fromLTRB(15.sp, 15.sp, 15.sp, 0),
              titleLineHeight: 1.2,
            ),
            SizedBox(height: 20.sp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              child: CustomDropdown<String>(
                hint: strings.department,
                value: _departmentId,
                // The same light/dark pair the create card uses for its
                // fields — `AppColors.field` is white in light mode and would
                // vanish into the dialog behind it.
                fillColor: AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.fieldFillLight,
                valueStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.text),
                itemStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.text),
                hintStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.secondaryText),
                items: widget.departments
                    .map((DatabaseDepartment d) => DropdownItem<String>(
                          value: d.id,
                          label: d.localizedName(isArabic: isArabic),
                        ))
                    .toList(growable: false),
                onChanged: (String value) =>
                    setState(() => _departmentId = value),
              ),
            ),
            SizedBox(height: 20.sp),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Reset clears the field and LEAVES THE DIALOG OPEN. It is
                  // an edit to the draft, not a second way to apply: closing
                  // here would make "reset, then pick something else" — the
                  // reason people reach for Reset — impossible.
                  customButton(
                    title: strings.reset,
                    function: () => setState(() => _departmentId = null),
                    color: AppColors.colorGreydark,
                    textColor: AppColors.text,
                  ),
                  customButton(
                    title: strings.apply,
                    function: () => Navigator.of(context)
                        .pop(AccessFilterResult(_departmentId)),
                    color: AppColors.primary,
                    textColor: AppColors.textButton,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
