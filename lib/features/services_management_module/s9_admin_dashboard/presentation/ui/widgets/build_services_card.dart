// ******************* FILE INFO *******************
// File Name: build_services_card.dart
// Description: Reusable mobile card widget for service requests
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
// Created by: Amr Mesbah
// Last Update: [Current Date]
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart'; // ✅ Updated import
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

class ServiceRequestMobileCard extends StatelessWidget {
  final List<Map<String, dynamic>> displayedItems;
  final String locale;
  final Map<String, String> enToArDepartments;
  final void Function(Map<String, dynamic> item)? onTap;

  const ServiceRequestMobileCard({
    Key? key,
    required this.displayedItems,
    required this.locale,
    required this.enToArDepartments,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _buildServiceCards(context),
    );
  }

  List<Widget> _buildServiceCards(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return List.generate(displayedItems.length, (index) {
      final item = displayedItems[index];
      final model = item["model"] as ServicesHistoryModel; // ✅ Updated type
      final selectedProvider = item['selectedProvider'] ?? {};

      final status = (item["status"] ?? '').toString().toLowerCase();
      final statusColor = _getStatusColor(status);
      final localizedStatus = _getLocalizedStatus(context, status);

      // ✅ Updated to use current getters
      final localizedServiceName = locale == 'ar'
          ? model.currentServiceNameArabic.isNotEmpty
          ? model.currentServiceNameArabic
          : model.currentServiceNameEnglish
          : model.currentServiceNameEnglish.isNotEmpty
          ? model.currentServiceNameEnglish
          : model.currentServiceNameArabic;

      // ✅ Updated to use current getters
      final requestorName = locale == 'ar'
          ? '${model.currentFirstNameRequesterArabic} ${model.currentLastNameRequesterArabic}'
          : '${model.currentFirstNameRequester} ${model.currentLastNameRequester}';

      final providerName = _getProviderName(selectedProvider, locale);
      final department = _getDepartmentName(item["department"], locale);
      final requestDate = _formatRequestDate(model);

      return GestureDetector(
        onTap: () => onTap?.call(item),
        child: Container(
          width: 345.sp,
          margin: EdgeInsets.only(bottom: 15.sp),
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.chatBackground,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, localizedServiceName, localizedStatus, statusColor, lightMode),
              SizedBox(height: 9.sp),
              _buildRequester(context, requestorName, lightMode),
              SizedBox(height: 8.sp),
              _buildDepartment(context, department, lightMode),
              SizedBox(height: 6.sp),
              _buildProvider(context, providerName, lightMode),
              _buildRequestDate(context, requestDate, lightMode),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(
      BuildContext context,
      String serviceName,
      String status,
      Color statusColor,
      bool lightMode,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 5.sp),
        // Service name
        Padding(
          padding: EdgeInsets.only(top: 5.sp),
          child: SizedBox(
            width: 165.sp,
            child: Text(
              FormatHelper.capitalize(serviceName),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: StyleText.fontSize16Weight500.copyWith(
                color: lightMode ? AppColors.blackButton : AppColors.white,
              ),
            ),
          ),
        ),
        Spacer(),
        // Status
        Padding(
          padding: EdgeInsets.only(top: 3.sp),
          child: SvgPicture.asset(
            "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
            fit: BoxFit.contain,
            width: 10.sp,
            height: 10.sp,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          FormatHelper.capitalize("${S.of(context).status} : "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode ? AppColors.secondaryText : AppColors.grey,
          ),
        ),
        Text(
          FormatHelper.capitalize(status),
          style: StyleText.fontSize14Weight400.copyWith(
            fontWeight: FontWeight.w400,
            color: statusColor,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildRequester(BuildContext context, String requestorName, bool lightMode) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/person_outline.svg",
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 6.w),
        Text(
          FormatHelper.capitalize("${S.of(context).serviceRequester} : "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode ? AppColors.secondaryText : AppColors.grey,
          ),
        ),
        SizedBox(width: 2.w),
        ClipOval(
          child: SvgPicture.asset(
            "assets/icons_assets/main_icons_assets/male_avatar.svg",
            width: 25.sp,
            height: 25.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            FormatHelper.capitalize(requestorName),
            style: StyleText.fontSize12Weight400.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartment(BuildContext context, String department, bool lightMode) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/Case.svg",
          fit: BoxFit.scaleDown,
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
        SizedBox(width: 6.w),
        Text(
          FormatHelper.capitalize("${S.of(context).department}: "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode ? AppColors.secondaryText : AppColors.grey,
          ),
        ),
        Text(
          FormatHelper.capitalize(department),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProvider(BuildContext context, String providerName, bool lightMode) {
    return Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/person_outline.svg",
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 6.w),
        Text(
          FormatHelper.capitalize("${S.of(context).serviceProvider}: "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode ? AppColors.secondaryText : AppColors.grey,
          ),
        ),
        SizedBox(width: 2.w),
        ClipOval(
          child: SvgPicture.asset(
            "assets/icons_assets/main_icons_assets/male_avatar.svg",
            width: 25.sp,
            height: 25.sp,
            fit: BoxFit.scaleDown,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            providerName.isNotEmpty
                ? FormatHelper.capitalize(providerName)
                : S.of(context).notAvailable,
            style: StyleText.fontSize12Weight400.copyWith(
              color: lightMode ? AppColors.blackButton : AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestDate(BuildContext context, String requestDate, bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Spacer(),
        Text(
          FormatHelper.capitalize("${S.of(context).RequestedDate} "),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode ? AppColors.secondaryText : AppColors.grey,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          requestDate,
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
      ],
    );
  }

  // ==================== HELPER METHODS ====================

  Color _getStatusColor(String status) {
    return switch (status) {
      'approved' => AppColors.green,
      'done' => AppColors.green,
      'rejected' => AppColors.red,
      'canceled' => AppColors.red,
      'cancel' => AppColors.red,
      'inprogress' => AppColors.orange,
      'pending' => AppColors.orange,
      'branchsla' => AppColors.red,
      'breached sla' => AppColors.red,
      _ => AppColors.orange,
    };
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    return switch (status) {
      'done' => S.of(context).Done,
      'pending' => S.of(context).Pending,
      'inprogress' => S.of(context).Inprogress,
      'branchsla' => S.of(context).BreachedSLA,
      'breached sla' => S.of(context).BreachedSLA,
      'rejected' => S.of(context).Rejected,
      'canceled' => S.of(context).Canceled,
      'cancel' => S.of(context).Canceled,
      'approved' => S.of(context).Approved,
      _ => status,
    };
  }

  String _getProviderName(Map<String, dynamic> selectedProvider, String locale) {
    if (locale == 'ar') {
      final arabicFirst = selectedProvider['firstNameInArabic']?.toString()?.trim() ?? '';
      final arabicLast = selectedProvider['lastNameInArabic']?.toString()?.trim() ?? '';
      final arabicName = '$arabicFirst $arabicLast'.trim();

      if (arabicName.isNotEmpty && arabicName != 'null null') {
        return arabicName;
      }
    }

    final englishFirst = selectedProvider['firstName']?.toString()?.trim() ?? '';
    final englishLast = selectedProvider['lastName']?.toString()?.trim() ?? '';
    final englishName = '$englishFirst $englishLast'.trim();

    return englishName.isNotEmpty && englishName != 'null null' ? englishName : '';
  }

  String _getDepartmentName(String? department, String locale) {
    if (department == null || department.isEmpty) return '';

    if (locale == 'ar') {
      return enToArDepartments[department] ?? department;
    }

    return department;
  }

  // ✅ Updated to use currentDurationOfServicesTimestamp
  String _formatRequestDate(ServicesHistoryModel model) {
    final timestamp = model.currentDurationOfServicesTimestamp;
    if (timestamp != null) {
      return DateFormat('MMMM d, y').format(timestamp.toDate());
    }
    return '-';
  }
}
