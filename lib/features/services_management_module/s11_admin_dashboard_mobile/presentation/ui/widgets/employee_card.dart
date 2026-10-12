// ******************* FILE INFO *******************
// File Name: employee_card
// Description: Employee card.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

// =============================================
// InfoBox Widget - Displays stat information
// =============================================
class InfoBox extends StatelessWidget {
  final String title;
  final String value;
  final Color borderColor;
  final bool isTabletLandscape;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? valueColor;

  const InfoBox({
    Key? key,
    required this.title,
    required this.value,
    this.borderColor = AppColors.transparent,
    this.isTabletLandscape = false,
    this.backgroundColor,
    this.titleColor,
    this.valueColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final bgColor = backgroundColor ??
        (lightMode ? AppColors.lightGrey! : AppColors.darkGrey!);
    final txtTitleColor = titleColor ?? (lightMode ? AppColors.mediumGrey! : AppColors.grey!);
    final txtValueColor = valueColor ?? (lightMode ? AppColors.black.withOpacity(0.87) : AppColors.white.withOpacity(0.70));

    return Container(
      height: isMobile ? 30.sp : 38.sp,
      width: isMobile
          ? 100.sp
          : isTabletLandscape
          ? 160.sp
          : 130.sp,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _capitalize(title),
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: isMobile
                  ? 10.sp
                  : !isTabletLandscape
                  ? 13.sp
                  : 16.sp,
              fontWeight: FontWeight.w500,
              wordSpacing: isMobile ? 0 : null,
              letterSpacing: isMobile ? 0 : null,
              color: txtTitleColor,
            ),
          ),
          SizedBox(width: 6.sp),
          Text(
            _capitalize(value),
            style: StyleText.fontSize14Weight400.copyWith(
              fontSize: isMobile
                  ? 10.sp
                  : !isTabletLandscape
                  ? 13.sp
                  : 16.sp,
              fontWeight: FontWeight.w500,
              color: txtValueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

// =============================================
// EmployeeCard Widget - Displays employee statistics
// =============================================
class EmployeeCardDashboard extends StatelessWidget {
  final List<Map<String, dynamic>> filteredItems;
  final Map<String, String> enToArDepartments;
  final List<String> Function(List<Map<String, dynamic>>) getUniqueProviders;
  final Map<String, dynamic> Function(String) calculateProviderStats;
  final String servicesDoneText;
  final String totalHoursText;
  final String breachedSLAText;
  final bool isTabletLandscape;
  final Color? cardBackgroundColor;
  final Color? textColor;
  final Color? subtitleColor;
  final Color? breachedBorderColor;

   EmployeeCardDashboard({
    Key? key,
    required this.filteredItems,
    required this.enToArDepartments,
    required this.getUniqueProviders,
    required this.calculateProviderStats,
    required this.servicesDoneText,
    required this.totalHoursText,
    required this.breachedSLAText,
    this.isTabletLandscape = false,
    this.cardBackgroundColor,
    this.textColor,
    this.subtitleColor,
    this.breachedBorderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filteredItems.isEmpty) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context).languageCode;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final uniqueProviders = getUniqueProviders(filteredItems);
    final statsList = uniqueProviders.map((email) {
      return calculateProviderStats(email);
    }).toList();

    final cardBgColor = cardBackgroundColor ??
        (lightMode ? AppColors.white : AppColors.darkGrey!);
    final txtColor = textColor ?? (lightMode ? AppColors.black.withOpacity(0.87) : AppColors.white.withOpacity(0.70));
    final subColor = subtitleColor ?? (lightMode ? AppColors.mediumGrey! : AppColors.grey!);

    return Column(
      children: List.generate(statsList.length, (index) {
        final providerStats = statsList[index];

        final item = filteredItems.firstWhere(
              (e) => e['provider'] == providerStats['name'],
          orElse: () => {},
        );

        if (item.isEmpty) return const SizedBox.shrink();

        final selectedProvider = item['selectedProvider'] ?? {};

        final providerName = locale == 'ar'
            ? '${selectedProvider['firstNameInArabic'] ?? ''} ${selectedProvider['lastNameInArabic'] ?? ''}'
            .trim()
            : '${selectedProvider['firstName'] ?? ''} ${selectedProvider['lastName'] ?? ''}'
            .trim();

        final providerTitle = locale == 'ar'
            ? selectedProvider['titleInArabic'] ?? ''
            : selectedProvider['title'] ?? '';

        final originalDept = providerStats['department'] ?? 'N/A';
        final localizedDepartment = locale == 'ar'
            ? enToArDepartments[originalDept] ?? originalDept
            : originalDept;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.sp),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 10.sp),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: isMobile
                ? _buildMobileLayout(
              context,
              providerName,
              providerTitle,
              localizedDepartment,
              providerStats,
              txtColor,
              subColor,
            )
                : _buildTabletLayout(
              context,
              providerName,
              providerTitle,
              localizedDepartment,
              providerStats,
              txtColor,
              subColor,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      String providerName,
      String providerTitle,
      String localizedDepartment,
      Map<String, dynamic> providerStats,
      Color txtColor,
      Color subColor,
      ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 12.sp),
            ClipOval(
              child: SvgPicture.asset(
                "assets/icons_assets/main_icons_assets/male_avatar.svg",
                fit: BoxFit.scaleDown,
                width: 40.sp,
                height: 40.sp,
                semanticsLabel: 'Profile',
              ),
            ),
            SizedBox(width: 6.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(providerName.isNotEmpty ? providerName : 'N/A'),
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: txtColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _capitalize(providerTitle.isNotEmpty ? providerTitle : 'N/A'),
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _capitalize(localizedDepartment),
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 15.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InfoBox(
              title: "$servicesDoneText:",
              value: providerStats["done"].toString(),
              borderColor: AppColors.transparent,
              isTabletLandscape: isTabletLandscape,
            ),
            SizedBox(width: 8.sp),
            InfoBox(
              title: "$totalHoursText:",
              value: providerStats["hours"].toStringAsFixed(1),
              borderColor: AppColors.transparent,
              isTabletLandscape: isTabletLandscape,
            ),
            SizedBox(width: 8.sp),
            InfoBox(
              title: "$breachedSLAText:",
              value: providerStats["breached"].toString(),
              borderColor: breachedBorderColor ?? AppColors.red,
              isTabletLandscape: isTabletLandscape,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
      BuildContext context,
      String providerName,
      String providerTitle,
      String localizedDepartment,
      Map<String, dynamic> providerStats,
      Color txtColor,
      Color subColor,
      ) {
    return Row(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 10.sp),
            ClipOval(
              child: SvgPicture.asset(
                "assets/icons_assets/main_icons_assets/male_avatar.svg",
                fit: BoxFit.scaleDown,
                width: 40.sp,
                height: 40.sp,
                semanticsLabel: 'Profile',
              ),
            ),
            SizedBox(width: 6.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(providerName.isNotEmpty ? providerName : 'N/A'),
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: txtColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _capitalize(providerTitle.isNotEmpty ? providerTitle : 'N/A'),
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _capitalize(localizedDepartment),
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InfoBox(
              title: "$servicesDoneText:",
              value: providerStats["done"].toString(),
              borderColor: AppColors.transparent,
              isTabletLandscape: isTabletLandscape,
            ),
            SizedBox(width: isTabletLandscape ? 30.sp : 8.sp),
            InfoBox(
              title: "$totalHoursText:",
              value: providerStats["hours"].toStringAsFixed(1),
              borderColor: AppColors.transparent,
              isTabletLandscape: isTabletLandscape,
            ),
            SizedBox(width: isTabletLandscape ? 30.sp : 8.sp),
            InfoBox(
              title: "$breachedSLAText:",
              value: providerStats["breached"].toString(),
              borderColor: breachedBorderColor ?? AppColors.red,
              isTabletLandscape: isTabletLandscape,
            ),
            SizedBox(width: isTabletLandscape ? 30.sp : 8.sp),
          ],
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

// Usage Example:
/*
// For InfoBox (standalone usage):
InfoBox(
  title: "Services Done",
  value: "15",
  borderColor: AppColors.transparent,
  isTabletLandscape: false,
)

// For EmployeeCard:
EmployeeCard(
  filteredItems: filteredItems,
  enToArDepartments: enToArDepartments,
  getUniqueProviders: getUniqueProviderEmails,
  calculateProviderStats: calculateProviderStats,
  servicesDoneText: S.of(context).ServicesDone,
  totalHoursText: S.of(context).TotalHours,
  breachedSLAText: S.of(context).BreachedSLA,
  isTabletLandscape: isTabletLandscape(context),
  breachedBorderColor: AppColors.red,
)
*/