// ******************* FILE INFO *******************
// File Name: calc_state_method
// Description: Calc state method.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Map<String, dynamic> calculateStatsForEmployee(
    EmployeeEntityModell emp,
    BuildContext context,
    List<Map<String, dynamic>> filteredItems, {
      String? parentDuration,
      String? parentDurationUnit,
    }) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final fullName = isArabic
      ? '${emp.firstNameInArabic ?? ''} ${emp.lastNameInArabic ?? ''}'.trim()
      : '${emp.firstName ?? ''} ${emp.lastName ?? ''}'.trim();

  int done = 0;
  int breached = 0;
  double totalMinutes = 0;

  final employeeController = AppControllers.employee;
  final enToArDepartments = context.read<MainCoreDepartmentCubit>().enToAr;
  final String? email = emp.email;
  final rawDepartment =
  (email != null) ? employeeController.getEmployeeDepartmentName(email) : 'N/A';

  final department =
  isArabic ? enToArDepartments[rawDepartment] ?? rawDepartment : rawDepartment;

  String? jobTitle = isArabic ? emp.titleInArabic : emp.title;

  for (final item in filteredItems) {
    final model = item["model"] as ServicesHistoryModel;
    final data = item["raw"] as Map<String, dynamic>;

    final firstName = isArabic
        ? _extractValue(model.firstNameRequesterArabic)
        : _extractValue(model.firstNameRequester);
    final lastName = isArabic
        ? _extractValue(model.lastNameRequesterArabic)
        : _extractValue(model.lastNameRequester);

    final requesterName = '$firstName $lastName'.trim();

    final rawState = data["state"];
    final state = _extractValue(rawState).toLowerCase().trim();

    if (requesterName == fullName) {
      if (state == 'done') done++;
      if (state == 'branchsla' || state == 'breached sla') breached++;

      if (['inprogress', 'done', 'branchsla'].contains(state)) {
        // ✅ FIX: Try request doc → model → parent service duration
        final rawDuration = data['durationOfServices']
            ?? data['Duration_Of_Services']
            ?? (model.currentDurationOfServices.isNotEmpty
                ? model.currentDurationOfServices
                : null)
            ?? parentDuration
            ?? '0';
        final rawUnit = data['selectedDurationUnit']
            ?? data['Selected_Duration_Unit']
            ?? (model.currentSelectedDurationUnit.isNotEmpty
                ? model.currentSelectedDurationUnit
                : null)
            ?? parentDurationUnit
            ?? 'minutes';

        final duration = double.tryParse(_extractValue(rawDuration)) ?? 0;
        final unit = _extractValue(rawUnit).toLowerCase();

        final minutes = switch (unit) {
          "minutes" => duration,
          "minute" => duration,
          "hours" => duration * 60,
          "hour" => duration * 60,
          "days" => duration * 1440,
          "day" => duration * 1440,
          "weeks" => duration * 10080,
          "week" => duration * 10080,
          _ => 0,
        };
        totalMinutes += minutes;
      }
    }
  }

  return {
    "name": fullName.isEmpty ? 'N/A' : fullName,
    "title": jobTitle ?? 'N/A',
    "department": department,
    "done": done,
    "breached": breached,
    "hours": totalMinutes / 60,
    "gender": emp.gender ?? 'male',
  };
}

String _extractValue(dynamic value) {
  if (value == null) return '';
  if (value is List) {
    for (int i = value.length - 1; i >= 0; i--) {
      final item = value[i]?.toString().trim() ?? '';
      if (item.isNotEmpty) return item;
    }
    return '';
  }
  if (value is Map && value.containsKey('value')) {
    return _extractValue(value['value']);
  }
  return value.toString().trim();
}
