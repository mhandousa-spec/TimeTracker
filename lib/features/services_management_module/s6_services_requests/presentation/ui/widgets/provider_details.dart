// ******************* FILE INFO *******************
// File Name: provider_details
// Description: Provider details.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/pages/select_services_provider_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/responsive_text.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget buildProviderDetailsSectionMaster({
  Function()? onTap,
  bool table = false,
  required BuildContext context,
  required String duration,
  required String durationUnit,
  required Timestamp durationTimeStamp,
  required List approvalCycle,
  required EmployeeEntityModell model,
  required String state,
}) {
  final isMobile = ContextExtension(context).isPhone;
  final EmployeeEntityModell provider = model;
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  // ✅ Only allow edit if state is pending or approved
  final canEdit = state.toLowerCase() == 'pending' || state.toLowerCase() == 'approved';

  // ✅ Reusable avatar + name row (no edit, no gesture)
  final avatarAndName = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipOval(
        child: SvgPicture.asset(
          (provider.gender ?? 'male') == 'male'
              ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
              : "assets/icons_assets/main_icons_assets/female_avatar.svg",
          width: 25.sp,
          height: 25.sp,
          fit: BoxFit.scaleDown,
        ),
      ),
      SizedBox(width: 5.sp),
      Text(
        FormatHelper.capitalize(
          isArabic
              ? "${provider.firstNameInArabic ?? '-'} ${provider.lastNameInArabic ?? '-'}"
              : "${provider.firstName ?? '-'} ${provider.lastName ?? '-'}",
        ),
        style: StyleText.fontSize14Weight400.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.blackButton
              : AppColors.white,
        ),
      ),
    ],
  );

  // ✅ Single builder for the provider row — used in all 3 layout branches
  Widget buildProviderRow() {
    if (!table) {
      return CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          isArabic
              ? "${provider.firstNameInArabic ?? '-'} ${provider.lastNameInArabic ?? '-'}"
              : "${provider.firstName ?? '-'} ${provider.lastName ?? '-'}",
        ),
        image: "assets/icons_assets/main_icons_assets/person_outline.svg",
        title: FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
        imagePerson: (provider.gender ?? 'male') == 'male'
            ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
            : "assets/icons_assets/main_icons_assets/female_avatar.svg",
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/person_outline.svg",
          semanticsLabel: 'Icon',
          width: 20.sp,
          height: 20.sp,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.secondaryText
              : AppColors.whiteShadow,
        ),
        SizedBox(width: 8.w),
        Text(
          FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
          style: StyleText.fontSize14Weight400.copyWith(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        // ✅ If canEdit → wrap with GestureDetector + show edit icon
        // ✅ If !canEdit → show only avatar + name
        canEdit
            ? GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.background
                  : AppColors.background,
              borderRadius: BorderRadius.circular(4.r),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 6.sp,
              horizontal: 6.sp,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                avatarAndName,
                SizedBox(width: 15.sp),
                SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/edit_pencil_square.svg",
                  width: 16.sp,
                  height: 16.sp,
                  fit: BoxFit.scaleDown,
                ),
              ],
            ),
          ),
        )
            : avatarAndName,
      ],
    );
  }

  // ==================== LEFT COLUMN ====================

  final leftColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildProviderRow(),
      SizedBox(height: 6.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(provider.email ?? '-'),
        image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
        title: FormatHelper.capitalize("${S.of(context).email}: "),
      ),
      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data: "${FormatHelper.capitalize(duration)} ${getLocalizedDurationUnitProvider(durationUnit, isArabic, context)}",
        image: "assets/icons_assets/services_assets/clock_dashed.svg",
        title: FormatHelper.capitalize("${S.of(context).durationOfService}: "),
      ),
    ],
  );

  // ==================== RIGHT COLUMN ====================

  final rightColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      isMobile ? const SizedBox() : SizedBox(height: 8.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          isArabic ? provider.titleInArabic ?? '-' : provider.title ?? '-',
        ),
        image: "assets/icons_assets/main_icons_assets/Case.svg",
        title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
      ),
      SizedBox(height: 11.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          provider.mobilePhone?.phone?.toString().replaceAll(RegExp(r'[\[\]]'), '') ?? '-',
        ),
        image: "assets/icons_assets/services_assets/phone_handset.svg",
        title: FormatHelper.capitalize("${S.of(context).phone}: "),
      ),
      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          approvalCycle.isEmpty
              ? (S.of(context).sm_doesnTNeedApproval)
              : (S.of(context).sm_needApproval),
        ),
        image: "assets/icons_assets/watermark/approval.svg",
        title: FormatHelper.capitalize("${S.of(context).approvals}: "),
      ),
    ],
  );

  // ==================== MOBILE LAYOUT ====================

  if (isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        SizedBox(height: 10.sp),
        rightColumn,
      ],
    );
  }

  // ==================== TABLET LAYOUT (600 - 900) ====================

  final isTabletCheck = MediaQuery.sizeOf(context).width >= 600 &&
      MediaQuery.sizeOf(context).width < 900;

  if (isTabletCheck) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildProviderRow(),
              SizedBox(height: 6.sp),
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(provider.email ?? '-'),
                image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
                title: FormatHelper.capitalize("${S.of(context).email}: "),
              ),
              SizedBox(height: 12.sp),
              CustomRowDetailsMaster(
                data: "${FormatHelper.capitalize(duration)} ${getLocalizedDurationUnitProvider(durationUnit, isArabic, context)}",
                image: "assets/icons_assets/services_assets/clock_dashed.svg",
                title: FormatHelper.capitalize("${S.of(context).durationOfService}: "),
              ),
            ],
          ),
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(
                  isArabic ? provider.titleInArabic ?? '-' : provider.title ?? '-',
                ),
                image: "assets/icons_assets/main_icons_assets/Case.svg",
                title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
              ),
              SizedBox(height: 11.sp),
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(provider.mobilePhone?.phone ?? '-'),
                image: "assets/icons_assets/services_assets/phone_handset.svg",
                title: FormatHelper.capitalize("${S.of(context).phone}: "),
              ),
              SizedBox(height: 12.sp),
              CustomRowDetailsMaster(
                data: FormatHelper.capitalize(
                  approvalCycle.isEmpty
                      ? (S.of(context).sm_doesnTNeedApproval)
                      : (S.of(context).sm_needApproval),
                ),
                image: "assets/icons_assets/watermark/approval.svg",
                title: FormatHelper.capitalize("${S.of(context).approvals}: "),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== DESKTOP/LARGE TABLET LAYOUT ====================

  return Column(
    children: [
      Row(
        children: [
          Expanded(child: buildProviderRow()),
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(provider.email ?? '-'),
              image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
              title: FormatHelper.capitalize("${S.of(context).email}: "),
            ),
          ),
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(
                approvalCycle.isEmpty
                    ? (S.of(context).sm_doesnTNeedApproval)
                    : (S.of(context).sm_needApproval),
              ),
              image: "assets/icons_assets/watermark/approval.svg",
              title: FormatHelper.capitalize("${S.of(context).approvals}: "),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.sp),
      Row(
        children: [
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(
                isArabic ? provider.titleInArabic ?? '-' : provider.title ?? '-',
              ),
              image: "assets/icons_assets/main_icons_assets/Case.svg",
              title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
            ),
          ),
          Expanded(
            child: CustomRowDetailsMaster(
              data: FormatHelper.capitalize(
                "+${provider.mobilePhone?.countryCode?.toString().replaceAll(RegExp(r'[\[\]]'), '') ?? ''} ${provider.mobilePhone?.phone?.toString().replaceAll(RegExp(r'[\[\]]'), '') ?? '-'}",
              ),
              image: "assets/icons_assets/services_assets/phone_handset.svg",
              title: FormatHelper.capitalize("${S.of(context).phone}: "),
            ),
          ),
          Expanded(
            child: CustomRowDetailsMaster(
              data: "${FormatHelper.capitalize(duration)} ${getLocalizedDurationUnitProvider(durationUnit, isArabic, context)}",
              image: "assets/icons_assets/services_assets/clock_dashed.svg",
              title: FormatHelper.capitalize("${S.of(context).durationOfService}: "),
            ),
          ),
        ],
      ),
    ],
  );
}

// ==================== HELPERS ====================

String getLocalizedDurationUnitProvider(String? unit, bool isArabic, BuildContext context) {
  if (unit == null) return '';

  final lowerUnit = unit.toLowerCase().trim();

  final map = {
    'days': S.of(context).sm_days,
    'day': S.of(context).sm_day,
    'weeks': S.of(context).sm_weeks,
    'week': S.of(context).sm_week,
    'hours': S.of(context).sm_hours,
    'hour': S.of(context).sm_hour,
    'minutes': S.of(context).sm_minutes,
    'minute': S.of(context).sm_minute,
  };

  return map[lowerUnit] ?? (S.of(context).sm_unknownUnit);
}
