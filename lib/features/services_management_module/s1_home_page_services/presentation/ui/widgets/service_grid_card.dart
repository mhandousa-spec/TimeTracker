// ******************* FILE INFO *******************
// File Name: service_grid_card
// Description: Single service card shown in the management grid view, including
//              tap handling (draft resume / details navigation) and the
//              duration pluralization helpers. Extracted from ManagementWidget.
// Module: services_management_module / presentation/s1_home_page_services/ui/widgets
// *************************************************

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/firebase_draft_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/pages/details_services_toggle.dart';

class ServiceGridCard extends StatelessWidget {
  final ServicesHistoryModel service;
  final String duration;
  final String unit;
  final bool isArabic;
  final String Function(dynamic) formatStartDate;

  /// Resolved "done services" counts (local Firestore counts take precedence
  /// over the parent-provided map; merge them before passing in).
  final Map<String, int> doneServicesCount;

  const ServiceGridCard({
    Key? key,
    required this.service,
    required this.duration,
    required this.unit,
    required this.isArabic,
    required this.formatStartDate,
    required this.doneServicesCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticController.low(); // card tap
        final isDraft = service.currentState.toLowerCase().trim() == 'draft';
        final cubit = ServicesManagerCubit.get(context);

        if (isDraft) {
          // 🔥 CHECK IF IT'S A FIREBASE DRAFT WITH PAGE TRACKING
          final draftWithPage = await cubit.getDraftWithPage(service.currentId);

          if (draftWithPage != null) {
            // Navigate to specific page based on saved progress
            _navigateToDraftPage(context, draftWithPage);
          } else {
            // Fallback: old SharedPrefs draft or new draft without page info
            navigateTo(
              context,
              CreateNewServicesLayout(editingModel: service),
            );
          }
        } else {
          // Existing active/inactive service flow
          final serviceId = service.currentId;
          if (serviceId.isNotEmpty) {
            await cubit.getRequestedServices(serviceId);
            await cubit.getStatistics(serviceId);
            navigateTo(
              context,
              ToggleDetailsServicesLayout(createServicesModel: service),
            );
          }
        }
      },
      child: _buildServiceCardContent(context),
    );
  }

  /// Open a draft at the start of the wizard.
  ///
  /// ✅ FIX (bug report p2): this used to deep-link straight to
  /// `draftWithPage.currentPage`, so a draft saved on the provider step
  /// reopened on the provider step. Resuming a draft always starts at step 1
  /// (basic info) instead: the saved model is passed through so every step
  /// stays prefilled and the user walks forward through the wizard.
  ///
  /// `draftWithPage.currentPage` is still written by the save path and is left
  /// intact for progress reporting.
  void _navigateToDraftPage(BuildContext context, DraftWithPage draftWithPage) {
    navigateTo(
      context,
      CreateNewServicesLayout(
        editingModel: draftWithPage.model,
        docId: draftWithPage.draftId,
      ),
    );
  }

  Widget _buildServiceCardContent(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              right: 10.sp,
              left: isArabic ? 10.sp : 0.sp,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildServiceImage(context),
                SizedBox(width: isArabic ? 0.sp : 5.sp),
                Expanded(
                  child: _buildServiceInfo(context),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          child: _buildStartDate(context),
        ),
      ],
    );
  }

  Widget _buildServiceImage(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      margin: EdgeInsets.only(top: 10.sp, bottom: 10.sp, left: 10.sp),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors. background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: (service.currentImageUrl.isNotEmpty)
          ? ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: CachedNetworkImage(
          imageUrl: service.currentImageUrl,
          width: 80.sp,
          height: 80.sp,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: AppColors.secondaryText.withOpacity(.3),
            highlightColor: AppColors.background.withOpacity(.5),
            child: Container(
              width: 80.sp,
              height: 80.sp,
              decoration: BoxDecoration(
                color: AppColors.secondaryText.withOpacity(.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          errorWidget: (context, url, error) {
            return SvgPicture.asset(
              'assets/icons_assets/services_assets/clock_dashed.svg',
              width: 40.sp,
              height: 40.sp,
              color: AppColors.secondaryText,
              fit: BoxFit.scaleDown,
            );
          },
        ),
      )
          : SvgPicture.asset(
        'assets/icons_assets/services_assets/headset_support.svg',
        width: 30.w,
        height: 30.h,
        color: AppColors.secondaryText,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildServiceInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 11.sp, bottom: 10.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Padding(
            padding:  EdgeInsets.only(top: 3.h),
            child: _buildServiceName(context),
          )),
          Expanded(child: _buildDoneServicesCount(context)),
          Expanded(child: _buildDuration(context)),
        ],
      ),
    );
  }

  Widget _buildServiceName(BuildContext context) {
    final serviceName = Localizations.localeOf(context).languageCode == 'ar'
        ? service.currentServiceNameArabic
        : service.currentServiceNameEnglish;

    return Text(
      FormatHelper.capitalize(serviceName),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.text,
      ),
    );
  }

  Widget _buildDoneServicesCount(BuildContext context) {
    // 🔥 Priority handled by caller: local Firestore count > parent count > "-"
    final count = doneServicesCount[service.currentId];

    return Row(
      children: [
        Text(
          "${S.of(context).doneServices}: ",
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          "${count ?? '-'}",
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildDuration(BuildContext context) {
    // Parse duration to check if we need plural form
    int? durationValue = int.tryParse(duration);
    String displayUnit = unit;

    // Only modify unit if we successfully parsed the duration
    if (durationValue != null) {
      final isAr = Localizations.localeOf(context).languageCode == 'ar';

      // Get the canonical unit type
      String canonicalUnit = _getCanonicalUnit(unit.toLowerCase().trim());

      // Apply pluralization logic
      displayUnit = _getPluralizedUnit(context, canonicalUnit, durationValue, isAr);
    }

    return Row(
      children: [
        Text(
          "${S.of(context).duration}: ",
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText
          ),
        ),
        Text(
          FormatHelper.capitalize("$duration $displayUnit"),
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text
          ),
        ),
      ],
    );
  }

  // Helper method to get canonical unit type
  String _getCanonicalUnit(String unit) {
    if (unit.contains('hour') || unit == 'h' || unit == 'hr' || unit == 'hrs' ||
        unit.contains('ساعة')) {
      return 'hour';
    } else if (unit.contains('minute') || unit == 'm' || unit == 'min' || unit == 'mins' ||
        unit.contains('دقيقة')) {
      return 'minute';
    } else if (unit.contains('second') || unit == 's' || unit == 'sec' || unit == 'secs' ||
        unit.contains('ثانية')) {
      return 'second';
    } else if (unit.contains('week') || unit == 'w' || unit == 'wk' || unit == 'wks' ||
        unit.contains('أسبوع')) {
      return 'week';
    } else if (unit.contains('day') || unit == 'd' ||
        unit.contains('يوم')) {
      return 'day';
    } else if (unit.contains('month') || unit == 'mo' ||
        unit.contains('شهر')) {
      return 'month';
    } else if (unit.contains('year') || unit == 'y' || unit == 'yr' || unit == 'yrs' ||
        unit.contains('سنة')) {
      return 'year';
    }
    return unit;
  }

  // Helper method to get pluralized unit
  String _getPluralizedUnit(BuildContext context, String canonicalUnit, int value, bool isArabic) {
    // For value of 1, use singular form
    if (value == 1) {
      switch (canonicalUnit) {
        case 'hour':
          return S.of(context).sm_hour;
        case 'minute':
          return S.of(context).sm_minute;
        case 'second':
          return S.of(context).sm_second;
        case 'week':
          return S.of(context).sm_week;
        case 'day':
          return S.of(context).sm_day;
        case 'month':
          return S.of(context).sm_month;
        case 'year':
          return S.of(context).sm_year;
        default:
          return canonicalUnit;
      }
    }

    // For value > 1, use plural form
    switch (canonicalUnit) {
      case 'hour':
        return S.of(context).sm_hours;
      case 'minute':
        return S.of(context).sm_minutes;
      case 'second':
        return S.of(context).sm_seconds;
      case 'week':
        return S.of(context).sm_weeks;
      case 'day':
        return S.of(context).sm_days;
      case 'month':
        return S.of(context).sm_months;
      case 'year':
        return S.of(context).year;
      default:
        return canonicalUnit;
    }
  }

  Widget _buildStartDate(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 0.sp, left: 0.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                "${S.of(context).startDate}: ",
                style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.secondaryText
                ),
              ),
              _buildStartDateValue(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartDateValue(BuildContext context) {
    final isDraft = service.currentState.toLowerCase().trim() == 'draft';

    if (isDraft) {
      return Text(
        '-',
        style: StyleText.fontSize10Weight400.copyWith(
            color: AppColors.text
        ),
      );
    }

    // W04: guarded access instead of try/catch.
    if (service.timestamps.isNotEmpty) {
      final timestamp = Timestamp.fromMillisecondsSinceEpoch(
        service.timestamps[0],
      );
      return Text(
        formatStartDate(timestamp),
        style: StyleText.fontSize10Weight400.copyWith(
            color: AppColors.text
        ),
      );
    }

    return Text(
      '-',
      style: StyleText.fontSize10Weight400.copyWith(
          color: AppColors.text
      ),
    );
  }
}
