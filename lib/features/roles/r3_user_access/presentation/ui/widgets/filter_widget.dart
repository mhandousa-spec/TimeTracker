/// Module: roles / r3_user_access / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: filter_widget.dart
/// Purpose: Declares `SortOptionRoleLabel`, `SortDropdownWidgetRole`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Sort menu now lists SortOptionRole.selectable.

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/enums/sort_option_role.dart';

// SortOptionRole moved 12/8/2026 to domain/enums/sort_option_role.dart — it is
// domain vocabulary, and the cubit imported it from this widget file. Its
// hardcoded 'First Name' / 'الاسم الأول' pairs and its `Get.locale` lookup are
// replaced by the `S.of(context)` mapping below (§13).

/// Localized label for a [SortOptionRole], resolved from the app's ARB strings
/// via the ambient [Localizations] rather than a service locator.
extension SortOptionRoleLabel on SortOptionRole {
  String label(BuildContext context) {
    switch (this) {
      case SortOptionRole.firstName:
        return S.of(context).firstName;
      case SortOptionRole.lastName:
        return S.of(context).lastName;
      case SortOptionRole.firstLogin:
        return S.of(context).firstLogin;
      case SortOptionRole.lastLogin:
        return S.of(context).last_login;
    }
  }
}

// ============================================================
// 2. SORT DROPDOWN WIDGET
// ============================================================
class SortDropdownWidgetRole extends StatelessWidget {
  final SortOptionRole? selectedSortOptionRole;
  final Function(SortOptionRole?) onChanged;
  final bool isMobile;
  final bool isPortrait;

  /// Direction of the active sort. Re-picking the selected option flips it,
  /// and the icon mirrors so the two orders are told apart at a glance.
  final bool isAscending;

  const SortDropdownWidgetRole({
    super.key,
    required this.selectedSortOptionRole,
    required this.onChanged,
    this.isMobile = false,
    this.isPortrait = false,
    this.isAscending = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isPortrait ? 38.h : 100.sp,

      child: CustomDropdown<SortOptionRole>(
        height: 38,
        triggerPadding: EdgeInsets.symmetric(vertical: 14.sp,horizontal: 8.sp),
        value: selectedSortOptionRole,
        // Keep the "Sort" hint on the trigger even after a choice is made — the
        // selected option must never replace the label. The active state is
        // shown only by the button style (fill + icon), not by the text.
        alwaysShowHint: true,
        fillColor: selectedSortOptionRole != null
            ? AppColors.primary
            : AppColors.field,
        borderRadius: BorderRadius.circular(8.r),
        hint: S.of(context).Sort,
        hintStyle: StyleText.fontSize16Weight500.copyWith(
          color: AppColors.secondaryText.withOpacity(.5),
          fontWeight: selectedSortOptionRole != null
              ? FontWeight.w700
              : FontWeight.w500,
        ),
        suffixIcon: Transform.flip(
          flipY: selectedSortOptionRole != null && !isAscending,
          child: CustomSvgImage(
            assetPath: AppAssets.sort,
            color: selectedSortOptionRole != null
                ? AppColors.textButton
                : AppColors.secondaryText,
          ),
        ),
        // `selectable`, not `values`: first name and last name were dropped
        // from the Sort menu on 25/8/2026 while their enum values — and the
        // cubit's comparators for them — stay. See sort_option_role.dart.
        items: SortOptionRole.selectable.map((SortOptionRole sort) {
          return DropdownItem<SortOptionRole>(
            value: sort,
            label: sort.label(context),
          );
        }).toList(),
        onChanged: (value) {
          onChanged(value);
        },
      ),
    );
  }
}