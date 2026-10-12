// ******************* FILE INFO *******************
// File Name: master_table_section.dart
// Description: Table / Cards / Employee section for DashBoard Master
// Created by: Amr Mesbah
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/dashboard_master_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/controller/dashboard_master_state.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/services_management_module/s11_admin_dashboard_mobile/presentation/ui/widgets/table_dashboard.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MasterTableSection extends StatelessWidget {
  final DashboardMasterState state;
  final DashboardMasterCubit cubit;
  final String locale;
  final bool isTabletLandscape;
  final String Function(dynamic rawDate, String locale) formatDate;
  final Color Function(String status, BuildContext context) getStatusColor;

  const MasterTableSection({
    super.key,
    required this.state,
    required this.cubit,
    required this.locale,
    required this.isTabletLandscape,
    required this.formatDate,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;

    if (state.showRequestedServices) {
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildServiceCardsMobile(context),
        );
      }
      return _buildServicesTable(context);
    }

    return EmployeeCardDashboard(
      filteredItems: state.filteredItems,
      enToArDepartments: state.enToArDepartments,
      getUniqueProviders: cubit.getUniqueProviderNames,
      calculateProviderStats: cubit.calculateProviderStats,
      servicesDoneText: S.of(context).ServicesDone,
      totalHoursText: S.of(context).TotalHours,
      breachedSLAText: S.of(context).BreachedSLA,
      isTabletLandscape: isTabletLandscape,
      breachedBorderColor: AppColors.red,
    );
  }

  Widget _buildServicesTable(BuildContext context) {
    return ServicesDataTable(
      displayedItems: state.displayedItems,
      enToArDepartments: state.enToArDepartments,
      formatDate: formatDate,
      getStatusColor: getStatusColor,
      noText: S.of(context).NO,
      serviceNameText: S.of(context).ServiceName,
      serviceRequestorText: S.of(context).ServiceRequestor,
      requestedDateText: S.of(context).RequestedDate,
      statusText: S.of(context).Status,
      serviceProviderText: S.of(context).ServiceProvider,
      doneText: S.of(context).Done,
      pendingText: S.of(context).Pending,
      inprogressText: S.of(context).Inprogress,
      breachedSLAText: S.of(context).BreachedSLA,
      rejectedText: S.of(context).Rejected,
      canceledText: S.of(context).Canceled,
      approvedText: S.of(context).Approved,
      jobTitleText: S.of(context).jobTitle,
      requesterDepartmentText: S.of(context).department,
    );
  }

  List<Widget> _buildServiceCardsMobile(BuildContext context) {
    return state.displayedItems.map((item) {
      return _ServiceCardMobile(
        item: item,
        locale: locale,
        formatDate: formatDate,
        getStatusColor: getStatusColor,
      );
    }).toList();
  }
}

class _ServiceCardMobile extends StatelessWidget {
  final Map<String, dynamic> item;
  final String locale;
  final String Function(dynamic rawDate, String locale) formatDate;
  final Color Function(String status, BuildContext context) getStatusColor;

  const _ServiceCardMobile({
    required this.item,
    required this.locale,
    required this.formatDate,
    required this.getStatusColor,
  });

  String _getProviderName(Map<String, dynamic> item, String locale) {

    final selectedProvider =
        item['selectedProvider'] as Map<String, dynamic>? ?? {};

    // ── 1️⃣ selectedProvider map (locale-matched) ──
    String providerName = locale == 'ar'
        ? '${selectedProvider['firstNameInArabic'] ?? ''} ${selectedProvider['lastNameInArabic'] ?? ''}'
        .trim()
        : '${selectedProvider['firstName'] ?? ''} ${selectedProvider['lastName'] ?? ''}'
        .trim();

    if (providerName.isNotEmpty && providerName != 'null') {
      return providerName;
    }

    // ── 2️⃣ selectedProvider map (cross-locale fallback) ──
    providerName = locale == 'ar'
        ? '${selectedProvider['firstName'] ?? ''} ${selectedProvider['lastName'] ?? ''}'
        .trim()
        : '${selectedProvider['firstNameInArabic'] ?? ''} ${selectedProvider['lastNameInArabic'] ?? ''}'
        .trim();

    if (providerName.isNotEmpty && providerName != 'null') {
      return providerName;
    }

    // ── 3️⃣ Direct keys on item map (all possible key variations) ──
    providerName = _tryProviderFromItemKeys(item, locale);
    if (providerName.isNotEmpty && providerName != 'null' && providerName != 'N/A') {
      return providerName;
    }

    // ── 4️⃣ Raw Firestore data from model ──
    final model = item['model'];
    if (model != null) {
      // Try model.selectedProvider map
      try {
        final modelSelectedProvider = model.selectedProvider;
        if (modelSelectedProvider != null && modelSelectedProvider is Map<String, dynamic>) {
          providerName = locale == 'ar'
              ? '${modelSelectedProvider['firstNameInArabic'] ?? modelSelectedProvider['firstName'] ?? ''} ${modelSelectedProvider['lastNameInArabic'] ?? modelSelectedProvider['lastName'] ?? ''}'
              .trim()
              : '${modelSelectedProvider['firstName'] ?? ''} ${modelSelectedProvider['lastName'] ?? ''}'
              .trim();

          if (providerName.isNotEmpty && providerName != 'null') {
            return providerName;
          }

          // Cross-locale
          providerName = locale == 'ar'
              ? '${modelSelectedProvider['firstName'] ?? ''} ${modelSelectedProvider['lastName'] ?? ''}'
              .trim()
              : '${modelSelectedProvider['firstNameInArabic'] ?? ''} ${modelSelectedProvider['lastNameInArabic'] ?? ''}'
              .trim();

          if (providerName.isNotEmpty && providerName != 'null') {
            return providerName;
          }
        }
      } catch (e) {
      }

      // ── 5️⃣ Try Provider_Services from raw Firestore doc ──
      try {
        final providerServices = model.currentProviderServices;
        if (providerServices != null) {
          if (providerServices is Map<String, dynamic>) {
            providerName = locale == 'ar'
                ? '${providerServices['firstNameInArabic'] ?? providerServices['firstName'] ?? ''} ${providerServices['lastNameInArabic'] ?? providerServices['lastName'] ?? ''}'
                .trim()
                : '${providerServices['firstName'] ?? ''} ${providerServices['lastName'] ?? ''}'
                .trim();

            if (providerName.isNotEmpty && providerName != 'null') {
              return providerName;
            }
          } else if (providerServices is List && providerServices.isNotEmpty) {
            final firstProvider = providerServices.first;
            if (firstProvider is Map<String, dynamic>) {
              providerName = locale == 'ar'
                  ? '${firstProvider['firstNameInArabic'] ?? firstProvider['firstName'] ?? ''} ${firstProvider['lastNameInArabic'] ?? firstProvider['lastName'] ?? ''}'
                  .trim()
                  : '${firstProvider['firstName'] ?? ''} ${firstProvider['lastName'] ?? ''}'
                  .trim();

              if (providerName.isNotEmpty && providerName != 'null') {
                return providerName;
              }
            }
          }
        }
      } catch (e) {
      }
    }

    // ── 6️⃣ Try Provider_Services from raw item map ──
    final providerServicesRaw = item['Provider_Services'] ?? item['providerServices'];
    if (providerServicesRaw != null) {
      providerName = _extractProviderFromRaw(providerServicesRaw, locale);
      if (providerName.isNotEmpty && providerName != 'null' && providerName != 'N/A') {
        return providerName;
      }
    }

    // ── 7️⃣ Assigned provider e-mail → employee directory ──
    // Services mobile QA p.41 ("where is the service provider name"): requests
    // written by paths that only stored `Assigned_Provider_Email` (bulk
    // upload, the provider reassignment) have no provider name anywhere on
    // the document, so every lookup above came back empty and the card said
    // "N/A". The service details page already falls back to the e-mail (see
    // ServiceInfoCardWidget._resolveProvider); this card now does the same.
    final String assignedEmail = _assignedProviderEmail(item);
    if (assignedEmail.isNotEmpty &&
        Get.isRegistered<MainCoreEmployeeController>()) {
      final emp = Get.find<MainCoreEmployeeController>()
          .mapOfEmployeesWithEmailKey[assignedEmail];
      if (emp != null) {
        final String ar =
            '${emp.firstNameInArabic ?? ''} ${emp.lastNameInArabic ?? ''}'.trim();
        final String en = '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim();
        final String name = locale == 'ar' && ar.isNotEmpty ? ar : en;
        if (name.isNotEmpty) return name;
      }
    }

    return 'N/A';
  }

  /// The provider e-mail stored on the request, from the model or the raw map.
  String _assignedProviderEmail(Map<String, dynamic> item) {
    try {
      final model = item['model'];
      if (model != null) {
        final String email =
            (model.currentAssignedProviderEmail ?? '').toString().trim();
        if (email.isNotEmpty) return email;
      }
    } catch (_) {}
    return (item['Assigned_Provider_Email'] ??
            item['assignedProviderEmail'] ??
            item['providerEmail'] ??
            '')
        .toString()
        .trim();
  }

  /// Helper: try all possible direct key variations on item map
  String _tryProviderFromItemKeys(Map<String, dynamic> item, String locale) {
    final keyPairs = [
      // locale-matched
      if (locale == 'ar') ...[
        ['providerFirstNameArabic', 'providerLastNameArabic'],
        ['providerFirstNameInArabic', 'providerLastNameInArabic'],
      ] else ...[
        ['providerFirstName', 'providerLastName'],
      ],
      // cross-locale fallback
      if (locale == 'ar') ...[
        ['providerFirstName', 'providerLastName'],
      ] else ...[
        ['providerFirstNameArabic', 'providerLastNameArabic'],
        ['providerFirstNameInArabic', 'providerLastNameInArabic'],
      ],
      // Firestore key format
      ['Provider_First_Name', 'Provider_Last_Name'],
      ['Provider_First_Name_Arabic', 'Provider_Last_Name_Arabic'],
    ];

    for (final pair in keyPairs) {
      final first = item[pair[0]]?.toString() ?? '';
      final last = item[pair[1]]?.toString() ?? '';
      final name = '$first $last'.trim();
      if (name.isNotEmpty && name != 'null') return name;
    }

    return '';
  }

  /// Helper: extract provider name from Provider_Services raw data
  String _extractProviderFromRaw(dynamic providerServicesRaw, String locale) {
    if (providerServicesRaw is Map<String, dynamic>) {
      final name = locale == 'ar'
          ? '${providerServicesRaw['firstNameInArabic'] ?? providerServicesRaw['firstName'] ?? ''} ${providerServicesRaw['lastNameInArabic'] ?? providerServicesRaw['lastName'] ?? ''}'
          .trim()
          : '${providerServicesRaw['firstName'] ?? ''} ${providerServicesRaw['lastName'] ?? ''}'
          .trim();
      if (name.isNotEmpty && name != 'null') return name;
    } else if (providerServicesRaw is List && providerServicesRaw.isNotEmpty) {
      final first = providerServicesRaw.first;
      if (first is Map<String, dynamic>) {
        final name = locale == 'ar'
            ? '${first['firstNameInArabic'] ?? first['firstName'] ?? ''} ${first['lastNameInArabic'] ?? first['lastName'] ?? ''}'
            .trim()
            : '${first['firstName'] ?? ''} ${first['lastName'] ?? ''}'.trim();
        if (name.isNotEmpty && name != 'null') return name;
      }
    }
    return '';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ✅ Provider gender helper with full fallback chain
  // ══════════════════════════════════════════════════════════════════════════
  String _getProviderGender(Map<String, dynamic> item) {
    final selectedProvider =
        item['selectedProvider'] as Map<String, dynamic>? ?? {};
    final gender = selectedProvider['gender']?.toString() ?? '';
    if (gender.isNotEmpty && gender != 'null') return gender;

    // Fallback: direct key on item
    final directGender = item['providerGender']?.toString() ?? '';
    if (directGender.isNotEmpty && directGender != 'null') return directGender;

    // Fallback: model object
    final model = item['model'];
    if (model != null) {
      try {
        // Try model.selectedProvider
        final msp = model.selectedProvider;
        if (msp != null && msp is Map<String, dynamic>) {
          final mGender = msp['gender']?.toString() ?? '';
          if (mGender.isNotEmpty && mGender != 'null') return mGender;
        }
      } catch (_) {}
    }

    return 'male';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ✅ Department helper with full fallback chain
  // ══════════════════════════════════════════════════════════════════════════
  String _getDepartment(
      BuildContext context, Map<String, dynamic> item, String locale) {
    // 1️⃣ Direct 'department' key
    final dept = item['department']?.toString() ?? '';
    if (dept.isNotEmpty && dept != 'null') {
      return _getDepartmentDisplayName(context, dept, locale);
    }

    // 2️⃣ requesterData fallback
    final requesterData = item['requesterData'] as Map<String, dynamic>?;
    if (requesterData != null) {
      final deptValue = requesterData['department']?.toString() ?? '';
      if (deptValue.isNotEmpty && deptValue != 'null') {
        return _getDepartmentDisplayName(context, deptValue, locale);
      }
    }

    // 3️⃣ Model fallback
    final model = item['model'];
    if (model != null) {
      final deptValue = model.currentDepartmentRequester ?? '';
      if (deptValue.isNotEmpty) {
        return _getDepartmentDisplayName(context, deptValue, locale);
      }
    }

    return '-';
  }

  String _getDepartmentDisplayName(
      BuildContext context, String departmentValue, String locale) {
    if (departmentValue.isEmpty) return '';

    // If it's a numeric department ID, resolve it
    if (int.tryParse(departmentValue) != null) {
      try {
        final departmentController = context.read<MainCoreDepartmentCubit>();
        final departmentName = departmentController.getDepartmentName(
          departmentValue,
          locale == 'en',
        );
        return departmentName ?? departmentValue;
      } catch (e) {
        return departmentValue;
      }
    }

    return departmentValue;
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final model = item['model'] as ServicesHistoryModel;

    // ── Status ──
    final status = (item['status'] ?? '').toString().toLowerCase();
    final statusColor = getStatusColor(status, context);
    final localizedStatus = _localizeStatus(status, context);

    // ── Service Name ──
    final localizedServiceName = locale == 'ar'
        ? ((item['serviceNameArabic'] ?? '').toString().isNotEmpty
        ? item['serviceNameArabic'].toString()
        : (item['serviceName'] ?? '').toString())
        : ((item['serviceName'] ?? '').toString().isNotEmpty
        ? item['serviceName'].toString()
        : (item['serviceNameArabic'] ?? '').toString());

    // ── Requester Name ──
    final requesterName = locale == 'ar'
        ? (item['requestorArabic'] ?? item['requestor'] ?? '')
        .toString()
        .trim()
        : (item['requestor'] ?? '').toString().trim();

    // ── Provider Name ✅ FIXED: Full fallback chain ──
    final providerName = _getProviderName(item, locale);

    // ── Department ✅ FIXED: With department ID resolution ──
    final department = _getDepartment(context, item, locale);

    // ── Requested Date ──
    final requestedDate = formatDate(item['requestDate'], locale);

    // ── Gender for avatars ──
    final requesterGender = item['gender']?.toString() ?? 'male';
    final providerGender = _getProviderGender(item);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: lightMode
            ? AppColors.white
            : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Service icon + name | Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service icon container
              Container(
                width: 36.sp,
                height: 36.sp,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: CustomSvgImage(
                    assetPath: "assets/icons_assets/services_assets/headset_support.svg",
                    width: 15.w,
                    height: 15.h,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // Service Name
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    localizedServiceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Status
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomSvgImage(
                      assetPath: "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                      width: 14.sp,
                      height: 14.sp,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${S.of(context).status}: ',
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: lightMode
                            ? AppColors.secondaryText
                            : AppColors.grey,
                      ),
                    ),
                    Text(
                      localizedStatus,
                      style: StyleText.fontSize14Weight400.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // ── Row 2: Service Requester ──
          _buildInfoRow(
            context,
            svgAsset: "assets/icons_assets/main_icons_assets/person_outline.svg",
            label: S.of(context).serviceRequester,
            value: requesterName.isNotEmpty ? requesterName : 'N/A',
            showAvatar: true,
            gender: requesterGender,
            lightMode: lightMode,
          ),

          SizedBox(height: 10.h),

          // ── Row 3: Department ──
          _buildInfoRow(
            context,
            svgAsset: "assets/icons_assets/main_icons_assets/Case.svg",
            label: S.of(context).department,
            value: department.isNotEmpty ? department : 'N/A',
            showAvatar: false,
            lightMode: lightMode,
          ),

          SizedBox(height: 10.h),

          // ── Row 4: Service Provider ──
          _buildInfoRow(
            context,
            svgAsset: "assets/icons_assets/main_icons_assets/person_outline.svg",
            label: S.of(context).ServiceProvider,
            value: providerName,
            showAvatar: providerName != 'N/A',
            gender: providerGender,
            lightMode: lightMode,
          ),

          SizedBox(height: 12.h),

          // ── Row 5: Requested Date (aligned to end) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${S.of(context).RequestedDate}: ',
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              Text(
                requestedDate,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a labeled info row with optional avatar
  Widget _buildInfoRow(
      BuildContext context, {
        required String svgAsset,
        required String label,
        required String value,
        required bool lightMode,
        bool showAvatar = false,
        String gender = 'male',
      }) {
    return Row(
      children: [
        CustomSvgImage(
          assetPath: svgAsset,
          width: 16.sp,
          height: 16.sp,
          fit: BoxFit.scaleDown,
          color: AppColors.secondaryText,
        ),
        SizedBox(width: 6.w),
        Text(
          '$label: ',
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        if (showAvatar) ...[
          SizedBox(width: 4.w),
          ClipOval(
            child: SvgPicture.asset(
              gender == 'female' ? 'assets/icons_assets/main_icons_assets/female_avatar.svg' : 'assets/icons_assets/main_icons_assets/male_avatar.svg',
              width: 22.sp,
              height: 22.sp,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 6.w),
        ],
        Expanded(
          child: Text(
            FormatHelper.capitalize(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StyleText.fontSize12Weight500.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _localizeStatus(String status, BuildContext context) {
    return switch (status) {
      'done' => S.of(context).Done,
      'pending' => S.of(context).Pending,
      'inprogress' => S.of(context).Inprogress,
      'branchsla' => S.of(context).BreachedSLA,
      'rejected' => S.of(context).Rejected,
      'canceled' || 'cancel' => S.of(context).Canceled,
      'approved' => S.of(context).Approved,
      _ => status,
    };
  }
}
