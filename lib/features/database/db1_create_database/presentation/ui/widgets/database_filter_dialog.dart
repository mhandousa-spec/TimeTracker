/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_filter_dialog.dart
/// Purpose: Declares `DatabaseFilterDialog` and `DatabaseFilterResult`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The Filter card the "Filter" button on the Database Builder list opens
/// (Figma frame 1597883942): the yellow filter badge and "Filter" heading, one
/// Access Management dropdown, then Reset and Apply.
///
/// Every piece is a shared widget rather than something shaped here —
/// `FiltersAppBar` (custom 80) for the heading, `CustomDropdown` (custom 1)
/// for the field and `customButton` (custom 5) for both actions — so this file
/// only decides WHAT is being filtered, not how any of it looks. That is the
/// same composition `FilterDialog` in r5_system_logs uses.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/80-filters_appbar.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';

/// What Apply hands back.
///
/// A bare `DatabaseAccessType?` would not do: the dialog can close with "no
/// access type" in two different ways — Apply after Reset (clear the filter)
/// and a barrier tap (change nothing) — and both would arrive as null. So the
/// future resolves to null for "dismissed" and to this object for "applied",
/// whose [accessType] is then allowed to be null in its own right.
@immutable
class DatabaseFilterResult {
  const DatabaseFilterResult(this.accessType);

  final DatabaseAccessType? accessType;
}

class DatabaseFilterDialog extends StatefulWidget {
  const DatabaseFilterDialog({super.key, this.initialAccessType});

  /// The filter currently applied to the list, so reopening the dialog shows
  /// what the user is actually looking at instead of an empty field.
  final DatabaseAccessType? initialAccessType;

  /// Opens the dialog and resolves to the applied filter, or null when the
  /// user dismissed it.
  static Future<DatabaseFilterResult?> show(
    BuildContext context, {
    DatabaseAccessType? initialAccessType,
  }) {
    return showDialog<DatabaseFilterResult>(
      context: context,
      barrierColor: AppColors.totalBlack.withOpacity(0.4),
      builder: (BuildContext _) =>
          DatabaseFilterDialog(initialAccessType: initialAccessType),
    );
  }

  @override
  State<DatabaseFilterDialog> createState() => _DatabaseFilterDialogState();
}

class _DatabaseFilterDialogState extends State<DatabaseFilterDialog> {
  /// Local draft. The list is not touched until Apply, so a user who opens
  /// the dialog, changes their mind and taps outside is left exactly where
  /// they were.
  late DatabaseAccessType? _accessType = widget.initialAccessType;

  @override
  Widget build(BuildContext context) {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
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
            // Yellow badge + "Filter", identical to every other filter card in
            // the app — but told to hug its content.
            //
            // Left at its defaults the heading brings ~50px of dead space with
            // it: a 1.8 line height on a 28px title plus its own 15.sp bottom
            // padding. That reads fine on a full screen, absurd in a dialog
            // this small. Bottom padding is dropped and the gap below is one
            // explicit 20.sp SizedBox, so the spacing is visible in this file
            // rather than inherited from three places at once.
            FiltersAppBar(
              imageUrl:
                  'assets/icons_assets/main_icons_assets/filter_sliders.svg',
              title: strings.filter,
              padding: EdgeInsets.fromLTRB(15.sp, 15.sp, 15.sp,0),
              titleLineHeight: 1.2,
            ),


            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.sp),
              child: CustomDropdown<DatabaseAccessType>(
                hint: strings.accessManagement,
                value: _accessType,
                fillColor: AppTheme.isDark
                    ? AppColors.colorBlack
                    : AppColors.fieldFillLight,
                valueStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.text),
                itemStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.text),
                hintStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.secondaryText),
                items: DatabaseAccessType.values
                    .map((DatabaseAccessType type) =>
                        DropdownItem<DatabaseAccessType>(
                          value: type,
                          label: isArabic ? type.labelAr : type.labelEn,
                        ))
                    .toList(growable: false),
                onChanged: (DatabaseAccessType value) =>
                    setState(() => _accessType = value),
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
                  // here would make "reset then pick something else" —
                  // the reason people reach for Reset — impossible.
                  customButton(
                    title: strings.reset,
                    function: () => setState(() => _accessType = null),
                    color: AppColors.colorGreydark,
                    textColor: AppColors.black,
                  ),
                  customButton(
                    title: strings.apply,
                    function: () => Navigator.of(context)
                        .pop(DatabaseFilterResult(_accessType)),
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
