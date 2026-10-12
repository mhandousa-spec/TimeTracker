// ******************* FILE INFO *******************
// File Name: build_services_card
// Description: Build services card.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Color _getBorderColor(String state) {
  switch (state.toLowerCase()) {
    case 'pending':
      return AppColors.pending; // orange
    case 'done':
      return AppColors.lightGreen; // Or any other color for "done"
    case 'approved':
      return AppColors.lightGreen; // green
    case 'rejected':
    case 'cancel':
      return AppColors.block; // red
    case 'inprogress':
      return AppColors.secondaryPrimary; // yellow
    case 'breached sla':
      return AppColors.block; // dark red
    default:
      return AppColors.lightGrey!; // normal
  }
}

Map<String, dynamic> getStatusStyle(
    String status,
    bool isArabic,
    bool lightMode,
    BuildContext context,
    ) {
  final labelMap = {
    "approved": S.of(context).sm_approved,
    "pending": S.of(context).status_pending,
    "rejected": S.of(context).status_rejected,
    "done": S.of(context).status_done,
    "cancel": S.of(context).status_cancel,
    "inprogress": S.of(context).status_inprogress,
    "breached sla": S.of(context).sm_breachedSla,
  };

  return {
    "label": labelMap[status.toLowerCase()] ?? (S.of(context).sm_unknown),
    "color": _getBorderColor(status),
  };
}

Widget buildServiceCardFromMap(Map<String, dynamic> item, BuildContext context) {
  final model = item["model"] as ServicesHistoryModel;
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final lightMode = Theme.of(context).brightness == Brightness.light;

  // Get department controller
  final departmentController = context.read<MainCoreDepartmentCubit>();

  // ✅ Get department ID and translate it dynamically
  final rawDepartmentId = model.currentDepartmentRequester;
  final department = rawDepartmentId.isNotEmpty
      ? departmentController.getDepartmentName(rawDepartmentId, !isArabic)
      : "-";

  // ✅ Get service name using the correct getter
  final String serviceName = isArabic
      ? (model.currentServiceNameArabic.isNotEmpty
      ? model.currentServiceNameArabic
      : "-")
      : (model.currentServiceNameEnglish.isNotEmpty
      ? model.currentServiceNameEnglish
      : "-");

  // ✅ Get requester name using the correct getters
  final String requesterFirstName = isArabic
      ? model.currentFirstNameRequesterArabic
      : model.currentFirstNameRequester;

  final String requesterLastName = isArabic
      ? model.currentLastNameRequesterArabic
      : model.currentLastNameRequester;

  final requestor = "$requesterFirstName $requesterLastName".trim().isNotEmpty
      ? "$requesterFirstName $requesterLastName".trim()
      : "-";

  // ✅ Get request date
  final requestDate = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode)
      .format(model.currentDurationOfServicesTimestamp.toDate());

  final provider = item["provider"] ?? "-";

  final status = item["status"]?.toString().toLowerCase() ?? "-";
  final statusInfo = getStatusStyle(status, isArabic, lightMode, context);
  final translatedStatus = statusInfo["label"];
  final statusColor = statusInfo["color"];

  final jobTitle = isArabic
      ? model.currentJobTitleRequesterArabic
      : model.currentJobTitleRequester;

  // Debug prints

  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(bottom: 14.sp),
        padding: EdgeInsets.all(14.sp),
        decoration: BoxDecoration(
          color: lightMode ? AppColors.white : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Row: Service Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  // Services mobile QA p.34: the service tile showed a person
                  // icon; it is the default service image (headset), as on
                  // every other services card.
                  child: SvgPicture.asset(
                    "assets/icons_assets/services_assets/headset_support.svg",
                    width: 16.sp,
                    height: 16.sp,
                    fit: BoxFit.scaleDown,
                    color: AppColors.secondaryText,
                    semanticsLabel: 'Icon',
                  ),
                ),
                SizedBox(width: 5.sp),
                Expanded(
                  child: Text(
                    serviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.sp),

            /// Row: Requester
            Row(
              children: [
                SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/person_outline.svg",
                  fit: BoxFit.scaleDown,
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.whiteShadow,
                ),
                SizedBox(width: 6.sp),
                Text(
                  "${S.of(context).serviceRequester}: ",
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: lightMode
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                SizedBox(width: 2.sp),
                ClipOval(
                  child: SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/male_avatar.svg",
                    fit: BoxFit.scaleDown,
                    width: 25.sp,
                    height: 25.sp,
                  ),
                ),
                SizedBox(width: 4.sp),
                Expanded(
                  child: Text(
                    FormatHelper.capitalize(requestor),
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.sp),

            /// Row: Requested Date
            Row(
              children: [
                SvgPicture.asset(
                  "assets/icons_assets/roles_assets/calendar.svg",
                  fit: BoxFit.scaleDown,
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.whiteShadow,
                ),
                SizedBox(width: 6.w),
                Text(
                  "${S.of(context).RequestedDate}: ",
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: lightMode
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                Text(
                  requestDate,
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.sp),

            /// Row: Service Provider
            Row(
              children: [
                SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/person_outline.svg",
                  fit: BoxFit.scaleDown,
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.whiteShadow,
                ),
                SizedBox(width: 6.w),
                Text(
                  "${S.of(context).serviceProvider}: ",
                  style: StyleText.fontSize12Weight400.copyWith(
                    color: lightMode
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                SizedBox(width: 2.w),
                ClipOval(
                  child: SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/male_avatar.svg",
                    fit: BoxFit.scaleDown,
                    width: 25.sp,
                    height: 25.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    FormatHelper.capitalize(provider),
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        top: 7.sp,
        right: isArabic ? null : 7.sp,
        left: isArabic ? 7.sp : null,
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
              fit: BoxFit.scaleDown,
              color: lightMode
                  ? AppColors.secondaryText
                  : AppColors.whiteShadow,
            ),
            SizedBox(width: 2.w),
            Text(
              "${S.of(context).status}: ",
              style: StyleText.fontSize12Weight400.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
            Text(
              translatedStatus,
              style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
