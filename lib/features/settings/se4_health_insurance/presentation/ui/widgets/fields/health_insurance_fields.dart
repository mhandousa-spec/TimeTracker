/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: health_insurance_fields.dart
/// Purpose: Stacks the insurance and emergency-contact cards.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N16: the employee history is resolved once here and passed
///          down, instead of each contact section locating three controllers.

///********************* FILE INFO ***********************///
/// Purpose: This file contains the HealthInsuranceFields in health insurance settings page.
/// Author: Amr Mesbah
/// Refactored at: 12/11/2023
/// Updated: Added 2nd Emergency Contact section

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';


import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/presentation/ui/widgets/sections/emergency_contact_information_section.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/widgets/sections/health_insurance_section.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HealthInsuranceFields extends StatefulWidget {
  HealthInsuranceFields({super.key});

  @override
  State<HealthInsuranceFields> createState() => _HealthInsuranceFieldsState();
}

class _HealthInsuranceFieldsState extends State<HealthInsuranceFields> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Resolved once here and passed down, rather than each contact section
    // locating three controllers of its own (CR-SKEL-SE4-N16, CR-SKEL-SE5-N14).
    // The `employee!` force-unwrap is gone with it.
    final MainCoreEmployeeController employeeController =
        Get.find<MainCoreEmployeeController>();
    final String currentUserEmail =
        Get.find<EmployeeController>().employee?.email.lastOrNull ?? '';

    final NewEmployeeModelHistory? currentEmployeeHistory = employeeController
        .allNewEmployees
        ?.firstWhereOrNull((emp) =>
            emp.email.isNotEmpty && emp.email.last == currentUserEmail);

    bool hasSecondContact = false;
    if (currentEmployeeHistory != null) {
      hasSecondContact = currentEmployeeHistory.secondContactFirstName.any((name) => name.isNotEmpty) ||
          currentEmployeeHistory.secondContactEmail.any((email) => email.isNotEmpty) ||
          currentEmployeeHistory.secondContactPhone.any((phone) => phone.isNotEmpty);
    }

    // Was GetBuilder with `init: SettingsController()`, which constructed a
    // SECOND controller instead of observing the registered one — so this
    // subtree never saw updates from the real instance.
    return BlocBuilder<SettingsController, SettingsState>(
      bloc: Get.find<SettingsController>(),
      builder: (BuildContext context, SettingsState state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health Insurance Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.card
              ),
              child: isMobile ? HealthInsuranceSection() : Padding(
                padding: EdgeInsets.only(top: 15.sp, right: 15.sp, left: 15.sp),
                child: HealthInsuranceSection(),
              ),
            ),

            isMobile ? SizedBox(height: 15.sp) : SizedBox(height: 0),

            // 1st Emergency Contact Section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.card
              ),
              child: EmergencyContactInformationSection(
                employeeHistory: currentEmployeeHistory,
                isFirstContact: true,
              ),
            ),
            isMobile ? SizedBox(height: 20.sp) : SizedBox(),

            // 2nd Emergency Contact Section - Only show if data exists
            if (hasSecondContact) ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.card
                ),
                child: EmergencyContactInformationSection(
                  employeeHistory: currentEmployeeHistory,
                  isFirstContact: false,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}