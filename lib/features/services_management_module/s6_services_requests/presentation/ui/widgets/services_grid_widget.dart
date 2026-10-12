// ******************* FILE INFO *******************
// File Name: services_grid_widget
// Description: Services grid widget.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/34-custom_gridview_with_animation.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/show_requests_service_card.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/service_card_metrics.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/service_lookup_cache.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/helper_function.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services_details_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesGridWidget extends StatelessWidget {
  final List<ServicesHistoryModel> services;
  final Map<String, Map<String, dynamic>?> providerCache;

  const ServicesGridWidget({
    required this.services,
    required this.providerCache,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return AnimatedCustomGridView(
      itemCount: services.length,
      crossAxisCount: CrossAxisCountHelperResponsive.getCrossAxisCountForDefaultTabletResponsive(context),
      mainAxisExtent: ServiceCardMetrics.requestCardExtent(context),
      mainAxisSpacing: 15.sp,
      crossAxisSpacing: 15.sp,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      animationDuration: const Duration(milliseconds: 800),
      staggerDelay: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      itemBuilder: (context, index) {
        final model = services[index];

        final serviceName = isArabic
            ? model.currentServiceNameArabic
            : model.currentServiceNameEnglish;

        final durationText = '${model.currentDurationOfServices} ${_getLocalizedDurationUnit(context, model.currentSelectedDurationUnit)}';

        final approvalCycle = model.currentApprovalCycle;
        final approvalText = approvalCycle.isEmpty
            ? (S.of(context).sm_doesnTNeedApproval)
            : (S.of(context).sm_needApproval);

        final rawDepartment = _extractDepartmentFromModel(model.currentDepartmentRequester);
        final owningDepartmentName = _getLocalizedDepartment(context, rawDepartment, isArabic);

        return GestureDetector(
          onTap: () {
            navigateTo(
              context,
              RequestServicesDetailsToggle(requestModel: model),
            );
          },
          child: FutureBuilder<Map<String, dynamic>?>(
            // Memoised: a fresh Future here would refire on every rebuild
            // (resize, bloc emit) and reset the card back to "...".
            future: ServiceLookupCache.provider(
              model.currentId,
              () => _getServiceProvider(model.currentId, model),
            ),
            builder: (context, snapshot) {
              String providerName = "...";
              String providerTitle = "...";

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  providerName = "-";
                  providerTitle = "-";
                } else if (snapshot.hasData && snapshot.data != null) {
                  final provider = snapshot.data!;

                  // ✅ FIXED: Safely get provider name
                  final firstNameKey = isArabic ? 'firstNameInArabic' : 'firstName';
                  final lastNameKey = isArabic ? 'lastNameInArabic' : 'lastName';
                  final titleKey = isArabic ? 'titleInArabic' : 'title';

                  final firstName = provider[firstNameKey]?.toString() ?? '';
                  final lastName = provider[lastNameKey]?.toString() ?? '';
                  providerName = '$firstName $lastName'.trim();

                  if (providerName.isEmpty) {
                    providerName = '-';
                  }

                  // ✅ FIXED: Safely get provider job title
                  providerTitle = provider[titleKey]?.toString() ?? '-';
                } else {
                  providerName = '-';
                  providerTitle = '-';
                }
              }

              return CustomServiceCard(
                serviceName: serviceName,
                owningDepartment: owningDepartmentName,
                serviceProvider: providerName,
                jobTitle: providerTitle,
                durationOfServices: durationText,
                approval: approvalText,
                model: model,
              );
            },
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getServiceProvider(String serviceId, ServicesHistoryModel model) async {
    try {

      // ✅ Check cache first
      if (providerCache.containsKey(serviceId)) {
        return providerCache[serviceId];
      }

      // ✅ Try getting provider from model's providerServices
      final providers = model.currentProviderServices;
      if (providers != null && providers.isNotEmpty) {

        // ✅ Prefer the provider this request was actually assigned to.
        // Using .first meant every request showed the same person even when
        // the workload balancer had picked someone else.
        final assignedEmail =
            model.currentAssignedProviderEmail?.toLowerCase().trim() ?? '';

        final providerData = assignedEmail.isEmpty
            ? providers.first
            : providers.firstWhere(
                (p) => (p.email?.toLowerCase().trim() ?? '') == assignedEmail,
                orElse: () => providers.first,
              );

        // ✅ FIXED: Check if it's EmployeeEntityModel
        if (providerData is EmployeeEntityModell) {
          return _employeeToMap(providerData);
        }

      }

      // ✅ Fallback to helper function
      final provider = await selectServiceProvider(serviceId);
      return provider;

    } catch (e, stackTrace) {
      return null;
    }
  }

  // ✅ NEW: Convert EmployeeEntityModel to Map
  Map<String, dynamic> _employeeToMap(EmployeeEntityModell employee) {
    return {
      'firstName': employee.firstName,
      'lastName': employee.lastName,
      'firstNameInArabic': employee.firstNameInArabic,
      'lastNameInArabic': employee.lastNameInArabic,
      'title': employee.title,
      'titleInArabic': employee.titleInArabic,
      'email': employee.email,
      'departmentId': employee.departmentId,
    };
  }

  String _extractDepartmentFromModel(dynamic dept) {
    if (dept == null) return '';

    if (dept is List && dept.isNotEmpty) {
      return dept[0].toString();
    }

    if (dept is String) {
      if (dept.startsWith('[') && dept.endsWith(']')) {
        final cleaned = dept.substring(1, dept.length - 1);
        return cleaned.trim();
      }
      return dept;
    }

    return '';
  }

  String _getLocalizedDepartment(
      BuildContext context, String departmentId, bool isArabic) {
    final deptController = context.read<MainCoreDepartmentCubit>();

    final Map<String, String> departmentTranslations = {
      "Marketing": "التسويق",
      "Sales": "المبيعات",
      "HR": "شؤون الموظفين",
      "Executive": "الإدارة التنفيذية",
      "Customer Support": "دعم العملاء",
      "Operations": "العمليات",
      "Finance": "المالية",
      "Information Technology": "تقنية المعلومات",
      "Human Resources": "الموارد البشرية",
      "Data Management": "إدارة البيانات",
      "Compliance & Legal": "الامتثال والقانون",
      "Software": "البرمجيات",
    };

    if (!departmentId.contains(RegExp(r'^[0-9]+$'))) {
      final deptId = deptController.getDepartmentIdFromDepartmentName(
        departmentName: departmentId.toLowerCase(),
      );

      if (deptId != null && deptId != "none") {
        final localizedName = deptController.getDepartmentName(deptId, !isArabic);
        return localizedName;
      }

      final fallback = isArabic ? (departmentTranslations[departmentId] ?? departmentId) : departmentId;
      return fallback;
    }

    final localizedName = deptController.getDepartmentName(departmentId, !isArabic);
    return localizedName;
  }

  String _getLocalizedDurationUnit(BuildContext context, String? rawUnit) {
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
}
