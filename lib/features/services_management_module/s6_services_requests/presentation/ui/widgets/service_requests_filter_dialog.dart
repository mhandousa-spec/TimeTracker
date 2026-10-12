// ******************* FILE INFO *******************
// File Name: service_requests_filter_dialog
// Description: Filter dialog for the Service Requests page (phone).
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// Added: 1/10/2026 - Services mobile QA p.22 ("the filter is missing").
// *************************************************
//
// The Service Requests page had a search field and nothing beside it, while
// every other services list (My Requests, the service details tabs) has a
// filter button there. On a phone the department chips above the search run
// off the screen, so the filter gives the same choice in one tap: pick an
// owning department, Apply, or Reset back to All.
//
// Same shell as the other services filter dialogs (s5 filter.dart): yellow
// badge + "Filter" title, full-width field, Reset (secondary) / Apply
// (primary) buttons.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Opens the filter and returns the chosen department key ('All' when reset),
/// or null when the dialog was dismissed without Apply.
Future<String?> showServiceRequestsFilterDialog({
  required BuildContext context,
  required List<String> departments,
  required String selectedDepartment,
}) {
  final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
  String? current = selectedDepartment == 'All' ? null : selectedDepartment;

  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final lightMode = Theme.of(dialogContext).brightness == Brightness.light;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: lightMode ? AppColors.white : AppColors.chatBackground,
        child: StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return Container(
              constraints: BoxConstraints(maxWidth: 645.sp, minWidth: 300.sp),
              padding: EdgeInsets.all(15.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                            width: 13.sp,
                            height: 13.sp,
                            fit: BoxFit.scaleDown,
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Text(
                        S.of(builderContext).Filter,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: lightMode ? AppColors.blackButton : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                  CustomDropdown<String>(
                    value: current,
                    items: departments
                        .map((d) => DropdownItem<String>(
                              value: d,
                              label: FormatHelper.capitalize(
                                  isArabic ? (kDepartmentEnToAr[d] ?? d) : d),
                            ))
                        .toList(),
                    onChanged: (v) => setDialogState(() => current = v),
                    fillColor: AppColors.background,
                    hint: S.of(builderContext).department,
                    hintStyle: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  SizedBox(height: 25.sp),
                  Row(
                    children: [
                      Expanded(
                        child: customButton(
                          title: S.of(builderContext).Reset,
                          function: () =>
                              Navigator.of(dialogContext).pop('All'),
                          color: AppColors.secondaryAction,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.onSecondaryAction),
                          height: 42.sp,
                        ),
                      ),
                      SizedBox(width: 15.sp),
                      Expanded(
                        child: customButton(
                          title: S.of(builderContext).Apply,
                          function: () =>
                              Navigator.of(dialogContext).pop(current ?? 'All'),
                          color: AppColors.primary,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton),
                          height: 42.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
