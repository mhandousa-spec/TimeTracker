// ******************* FILE INFO *******************
// File Name: responsive_text
// Description: Responsive text.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

String getLocalizedDurationUnit(
    BuildContext context,
    String? rawUnit, {
      num? quantity,
    }) {
  final localizer = S.of(context);
  if (rawUnit == null) return '';

  final k = rawUnit.trim().toLowerCase();

  String canonical;
  switch (k) {
    case 'h':
    case 'hr':
    case 'hrs':
    case 'hour':
    case 'hours':
      canonical = 'hours';
      break;

    case 'm':
    case 'min':
    case 'mins':
    case 'minute':
    case 'minutes':
      canonical = 'minutes';
      break;

    case 's':
    case 'sec':
    case 'secs':
    case 'second':
    case 'seconds':
      canonical = 'seconds';
      break;

    case 'w':
    case 'wk':
    case 'wks':
    case 'week':
    case 'weeks':
      canonical = 'week';
      break;

    case 'd':
    case 'day':
    case 'days':
      canonical = 'day';
      break;
    case 'mo':
    case 'month':
    case 'months':
      canonical = 'month';
      break;
    case 'y':
    case 'yr':
    case 'yrs':
    case 'year':
    case 'years':
      canonical = 'year';
      break;

    default:
      return rawUnit;
  }

  switch (canonical) {
    case 'hours':
      return localizer.hours;
    case 'minutes':
      return localizer.minutes;
    case 'seconds':
      return localizer.seconds;
    case 'week':
      return localizer.week;
    case 'day':
      return localizer.day;
    case 'month':
      return localizer.month;
    case 'year':
      return localizer.year;
    default:
      return rawUnit;
  }
}

// ✅ Helper function to extract phone data
String _extractPhoneData(dynamic phoneData, String fieldName) {

  if (phoneData == null) {
    return '';
  }

  String result = '';

  if (phoneData is String) {
    // Remove brackets from string like "[965]" -> "965"
    result = phoneData.replaceAll(RegExp(r'[\[\]]'), '').trim();
  } else if (phoneData is List && phoneData.isNotEmpty) {
    // Extract first element from list
    result = phoneData[0].toString();
  } else {
    result = phoneData.toString();
  }

  return result;
}

// ✅ Helper function to format complete phone number
String _formatPhoneNumber(Map<String, dynamic>? mobilePhone) {

  if (mobilePhone == null) {
    return '-';
  }

  final countryCode = _extractPhoneData(mobilePhone['countryCode'], 'countryCode');
  final phone = _extractPhoneData(mobilePhone['phone'], 'phone');

  if (countryCode.isNotEmpty && phone.isNotEmpty) {
    final formatted = "+$countryCode $phone";
    return FormatHelper.capitalize(formatted);
  }

  return '-';
}

/// Layout breakpoints for the request-details info block.
abstract class DetailsBreakpoints {
  /// Below this: stacked (mobile).
  static const double twoColumn = 600;

  /// At/above this: 3 items per row (desktop). Between the two: 2 per row.
  static const double threeColumn = 1200;
}

Widget buildProviderServiceDetailsServices({
  required BuildContext context,
  required String owningDepartment,
  required String durationUnit,
  required Map<String, dynamic> provider,
  required ServicesHistoryModel requestModel,
}) {

  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final isMobile = ContextExtension(context).isPhone;
  final isTabletLandscape = MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).orientation == Orientation.landscape;

  final leftColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          isArabic
              ? "${provider['firstNameInArabic'] ?? '-'} ${provider['lastNameInArabic'] ?? '-'}"
              : "${provider['firstName'] ?? '-'} ${provider['lastName'] ?? '-'}",
        ),
        image: "assets/icons_assets/main_icons_assets/person_outline.svg",
        title: FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
        imagePerson: (provider['gender'] ?? 'male') == "male"
            ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
            : "assets/icons_assets/main_icons_assets/female_avatar.svg",
      ),
      SizedBox(height: 6.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(provider['email'] ?? '-'),
        image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
        title: FormatHelper.capitalize("${S.of(context).email}: "),
      ),
      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data:
        "${FormatHelper.capitalize(requestModel.currentDurationOfServices ?? '')} ${getLocalizedDurationUnit(context, durationUnit)}",
        image: "assets/icons_assets/services_assets/clock_dashed.svg",
        title: FormatHelper.capitalize("${S.of(context).durationOfService}: "),
      ),
    ],
  );

  final rightColumn = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      isMobile ? SizedBox() : SizedBox(height: 8.sp),

      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          isArabic ? provider['titleInArabic'] ?? '-' : provider['title'] ?? '-',
        ),
        image: "assets/icons_assets/main_icons_assets/Case.svg",
        title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
      ),
      SizedBox(height: 11.sp),

      // ✅ FIXED: Mobile/Tablet phone display
      CustomRowDetailsMaster(
        data: _formatPhoneNumber(provider['mobilePhone']),
        image: "assets/icons_assets/services_assets/phone_handset.svg",
        title: FormatHelper.capitalize("${S.of(context).phone}: "),
      ),

      SizedBox(height: 12.sp),
      CustomRowDetailsMaster(
        data: FormatHelper.capitalize(
          requestModel.currentApprovalCycle?.isEmpty ?? true
              ? (S.of(context).sm_doesnTNeedApproval)
              : (S.of(context).sm_needApproval),
        ),
        image: "assets/icons_assets/watermark/approval.svg",
        title: FormatHelper.capitalize("${S.of(context).approvals}: "),
      ),
    ],
  );

  if (isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        leftColumn,
        SizedBox(height: 10.sp),
        rightColumn,
      ],
    );
  } else {
    // 2 items per row until there's genuinely room for 3.
    // Each CustomRowDetailsMaster needs ~380px to show an email or a job
    // title without truncating, so 3-across only pays off past ~1200.
    final width = MediaQuery.sizeOf(context).width;
    var isTablet = width >= 600 && width < DetailsBreakpoints.threeColumn;

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    isArabic
                        ? "${provider['firstNameInArabic'] ?? '-'} ${provider['lastNameInArabic'] ?? '-'}"
                        : "${provider['firstName'] ?? '-'} ${provider['lastName'] ?? '-'}",
                  ),
                  image: "assets/icons_assets/main_icons_assets/person_outline.svg",
                  title: FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
                  imagePerson: (provider['gender'] ?? 'male') == "male"
                      ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
                      : "assets/icons_assets/main_icons_assets/female_avatar.svg",
                ),
                SizedBox(height: 6.sp),
                CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(provider['email'] ?? '-'),
                  image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
                  title: FormatHelper.capitalize("${S.of(context).email}: "),
                ),
                SizedBox(height: 12.sp),
                CustomRowDetailsMaster(
                  data:
                  "${FormatHelper.capitalize(requestModel.currentDurationOfServices ?? '')} ${getLocalizedDurationUnit(context, durationUnit)}",
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
                    isArabic ? provider['titleInArabic'] ?? '-' : provider['title'] ?? '-',
                  ),
                  image: "assets/icons_assets/main_icons_assets/Case.svg",
                  title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
                ),
                SizedBox(height: 11.sp),

                // ✅ FIXED: Tablet phone display
                CustomRowDetailsMaster(
                  data: _formatPhoneNumber(provider['mobilePhone']),
                  image: "assets/icons_assets/services_assets/phone_handset.svg",
                  title: FormatHelper.capitalize("${S.of(context).phone}: "),
                ),

                SizedBox(height: 12.sp),
                CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    requestModel.currentApprovalCycle?.isEmpty ?? true
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
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    isArabic
                        ? "${provider['firstNameInArabic'] ?? '-'} ${provider['lastNameInArabic'] ?? '-'}"
                        : "${provider['firstName'] ?? '-'} ${provider['lastName'] ?? '-'}",
                  ),
                  image: "assets/icons_assets/main_icons_assets/person_outline.svg",
                  title: FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
                  imagePerson: (provider['gender'] ?? 'male') == "male"
                      ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
                      : "assets/icons_assets/main_icons_assets/female_avatar.svg",
                ),
              ),
              Expanded(
                child: CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(provider['email'] ?? '-'),
                  image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
                  title: FormatHelper.capitalize("${S.of(context).email}: "),
                ),
              ),
              Expanded(
                child: CustomRowDetailsMaster(
                  data: FormatHelper.capitalize(
                    requestModel.currentApprovalCycle?.isEmpty ?? true
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
                    isArabic ? provider['titleInArabic'] ?? '-' : provider['title'] ?? '-',
                  ),
                  image: "assets/icons_assets/main_icons_assets/Case.svg",
                  title: FormatHelper.capitalize("${S.of(context).jobTitle}: "),
                ),
              ),
              Expanded(
                // ✅ FIXED: Desktop phone display
                child: CustomRowDetailsMaster(
                  data: _formatPhoneNumber(provider['mobilePhone']),
                  image: "assets/icons_assets/services_assets/phone_handset.svg",
                  title: FormatHelper.capitalize("${S.of(context).phone}: "),
                ),
              ),
              Expanded(
                child: CustomRowDetailsMaster(
                  data:
                  "${FormatHelper.capitalize(requestModel.currentDurationOfServices ?? '')} ${getLocalizedDurationUnit(context, durationUnit)}",
                  image: "assets/icons_assets/services_assets/clock_dashed.svg",
                  title: FormatHelper.capitalize("${S.of(context).durationOfService}: "),
                ),
              ),
            ],
          )
        ],
      );
    }
  }
}

class CustomRowDetailsMaster extends StatelessWidget {
  const CustomRowDetailsMaster({
    super.key,
    required this.image,
    required this.title,
    required this.data,
    this.imagePerson,
    this.unit,
  });

  final String image;
  final String title;
  final String data;
  final String? imagePerson;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          image,
          semanticsLabel: 'Icon',
          width: 17.sp,
          height: 17.sp,
          fit: BoxFit.fill,
        ),
        SizedBox(width: 4.sp),
        // The label keeps its intrinsic width where possible but yields
        // before the row overflows.
        Flexible(
          flex: 0,
          child: Text(
            FormatHelper.capitalize(title),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: isMobile
                ? StyleText.fontSize12Weight400.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.secondaryText
                  : AppColors.grey,
            )
                : StyleText.fontSize14Weight400.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),
          ),
        ),
        if (imagePerson != null)
          Row(
            children: [
              ClipOval(
                child: SvgPicture.asset(
                  imagePerson!,
                  fit: BoxFit.cover,
                  width: 28.w,
                  height: 28.h,
                  semanticsLabel: 'Dart Logo',
                ),
              ),
              SizedBox(width: 5.w),
            ],
          ),
        // The value takes the remaining width and ellipsises instead of
        // overflowing — emails and job titles are unbounded in length.
        Expanded(
          child: Row(
          children: [
            Flexible(
              child: Text(
                FormatHelper.capitalize(data),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: isMobile
                    ? StyleText.fontSize12Weight400.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blackButton
                      : AppColors.white,
                )
                    : StyleText.fontSize14Weight400.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ),
            if (unit != null && unit!.isNotEmpty) ...[
              SizedBox(width: 2.w),
              Text(
                FormatHelper.capitalize(unit!),
                style: isMobile
                    ? StyleText.fontSize12Weight400.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blackButton
                      : AppColors.white,
                )
                    : StyleText.fontSize14Weight400.copyWith(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ],
        ),
        ),
      ],
    );
  }
}
