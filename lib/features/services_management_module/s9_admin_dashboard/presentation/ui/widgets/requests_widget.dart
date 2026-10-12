// ******************* FILE INFO *******************
// File Name: requests_widget
// Description: Requests widget.
// Module: services_management_module / presentation/s9_admin_dashboard/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';


import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

class RequestsListWidget extends StatelessWidget {
  final bool isLoadingRequests;
  final List<Map<String, dynamic>> displayedItems;
  final Map<String, String> stateTranslationsAr;
  final Map<String, String> enToArDepartments;
  final Function(Map<String, dynamic>)? onItemTap;

  const RequestsListWidget({
    Key? key,
    required this.isLoadingRequests,
    required this.displayedItems,
    required this.stateTranslationsAr,
    required this.enToArDepartments,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoadingRequests) {
      return _buildLoadingState(context);
    }

    if (displayedItems.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildRequestsList(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircleProgressMaster(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.sp,
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
          SizedBox(height: 16.sp),
          Text(
            S.of(context).sm_noRequestsFound,
            style: StyleText.fontSize16Weight500.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context) {
    return ListView.builder(
      itemCount: displayedItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return RequestItemCard(
          item: displayedItems[index],
          stateTranslationsAr: stateTranslationsAr,
          enToArDepartments: enToArDepartments,
          onTap: onItemTap,
        );
      },
    );
  }
}

class RequestItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, String> stateTranslationsAr;
  final Map<String, String> enToArDepartments;
  final Function(Map<String, dynamic>)? onTap;

  const RequestItemCard({
    Key? key,
    required this.item,
    required this.stateTranslationsAr,
    required this.enToArDepartments,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rawState = item["status"]?.toString() ?? '';
    final state = rawState.trim().toLowerCase();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final statusColor = _getStatusColor(state);

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(item);
        }
      },
      child: Stack(
        alignment: AlignmentGeometry.topRight,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 6.sp),
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: lightMode
                  ? AppColors.white
                  : AppColors.chatBackground,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceNameAndStatus(context, isArabic, lightMode, state, statusColor),
                SizedBox(height: 6.sp),
                _buildServiceRequester(context, isArabic, lightMode),
                SizedBox(height: 6.sp),
                _buildDepartment(context, isArabic, lightMode),
                SizedBox(height: 6.sp),
                _buildServiceProvider(context, isArabic, lightMode),
                _buildRequestDate(context, lightMode, state, statusColor),
              ],
            ),
          ),
          Positioned(
            top: 10.h,
            right: isArabic ? null :  10.w,
            left: isArabic ?  10.w : null,
            child: Row(
              children: [
                Text(
                  "${S.of(context).Status}: ",
                  style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
                    color: lightMode
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                Text(
                  isArabic
                      ? (stateTranslationsAr[state] ?? state)
                      : FormatHelper.capitalize(state),
                  style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getStatusColor(String state) {
    return switch (state) {
      'pending' => const Color(0XFFFF814A),
      'done' => AppColors.lightGreen,
      'approved' => AppColors.green!,
      'rejected' => AppColors.red,
      'cancel' => AppColors.block,
      'inprogress' => AppColors.secondaryPrimary,
      'breached sla' || 'branchsla' => AppColors.block,
      _ => AppColors.grey!,
    };
  }

  Widget _buildServiceNameAndStatus(BuildContext context, bool isArabic, bool lightMode, String state, Color statusColor) {
    return Row(
      children: [
        Container(
          width: 30.sp,
          height: 30.sp,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: SvgPicture.asset(
            "assets/icons_assets/services_assets/Group (1).svg",
            width: 12.sp,
            height: 12.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 5.sp),
        Expanded(
          child: Row(
            children: [
              Text(
                FormatHelper.capitalize(isArabic
                    ? item['serviceNameArabic'] ?? ''
                    : item['serviceName'] ?? ''),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),

            ],
          ),
        ),

      ],
    );
  }

  Widget _buildServiceRequester(BuildContext context, bool isArabic, bool lightMode) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/person_outline.svg",
          width: 12.sp,
          height: 12.sp,
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 6.sp),
        Text(
          "${FormatHelper.capitalize(S.of(context).ServiceRequestor)}: ",
          style: StyleText.fontSize10Weight400.copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        ClipOval(
          child: SvgPicture.asset(
            item["gender"] == "male"
                ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
                : "assets/icons_assets/main_icons_assets/female_avatar.svg",
            width: 20.sp,
            height: 20.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 4.sp),
        Expanded(
          child: Text(
            FormatHelper.capitalize(isArabic
                ? "${item["firstNameRequesterArabic"] ?? ''} ${item["lastNameRequesterArabic"] ?? ''}"
                : "${item["firstNameRequester"] ?? ''} ${item["lastNameRequester"] ?? ''}"),
            style: StyleText.fontSize10Weight400.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDepartment(BuildContext context, bool isArabic, bool lightMode) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/Case.svg",
          width: 12.sp,
          height: 12.sp,
          fit: BoxFit.scaleDown,
          color: AppColors.secondaryText,
        ),
        SizedBox(width: 6.sp),
        Text(
          FormatHelper.capitalize("${S.of(context).Department}: "),
          style: StyleText.fontSize10Weight400.copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        SizedBox(width: 2.sp),
        Text(
          FormatHelper.capitalize(isArabic
              ? enToArDepartments[item["department"]] ?? item["department"]
              : item["department"]),
          style: StyleText.fontSize10Weight400.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceProvider(BuildContext context, bool isArabic, bool lightMode) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/person_outline.svg",
          width: 12.sp,
          height: 12.sp,
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 6.sp),
        Text(
          FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
          style: StyleText.fontSize10Weight400.copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        ClipOval(
          child: SvgPicture.asset(
            item["gender"] == "male"
                ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
                : "assets/icons_assets/main_icons_assets/female_avatar.svg",
            width: 20.sp,
            height: 20.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 4.sp),
        Expanded(
          child: Text(
            FormatHelper.capitalize(isArabic
                ? "${item["firstNameProviderArabic"] ?? ''} ${item["lastNameProviderArabic"] ?? ''}"
                : "${item["firstNameProvider"] ?? ''} ${item["lastNameProvider"] ?? ''}"),
            style: StyleText.fontSize10Weight400.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestDate(BuildContext context, bool lightMode,String state, Color statusColor) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        Spacer(),
        Text(
          FormatHelper.capitalize("${S.of(context).RequestedDate}: "),
          style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        Text(
          item["requestDate"] != null
              ? _formatDate(item["requestDate"], Localizations.localeOf(context).languageCode)
              : 'N/A',
          style: StyleText.fontSize8Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),

      ],
    );
  }
  String _formatDate(String? dateString, String locale) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }

    // W16: no try/catch — use DateTime.tryParse/int.tryParse (null on failure).
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    const englishMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    String render(int day, int month, int year) {
      if (month < 1 || month > 12) return dateString;
      final months = locale == 'ar' ? arabicMonths : englishMonths;
      return '$day ${months[month - 1]} $year';
    }

    // Normalise to just the date part, then try ISO parsing.
    String datePart = dateString;
    if (dateString.contains(' - ')) {
      datePart = dateString.split(' - ')[0];
    } else if (dateString.contains(' ') && !dateString.contains('T')) {
      datePart = dateString.split(' ')[0];
    }

    final parsed = DateTime.tryParse(datePart);
    if (parsed != null) {
      return render(parsed.day, parsed.month, parsed.year);
    }

    // Manual fallback for "yyyy-mm-dd" style strings.
    if (dateString.contains('-')) {
      final parts = dateString.split('-');
      if (parts.length >= 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2].split(' ')[0]);
        if (year != null && month != null && day != null) {
          return render(day, month, year);
        }
      }
    }
    return dateString;
  }
}
