// ***************************** FILE INFO ***************************** //
// File Name: hr_routing.dart
// Purpose: Resolves centralized named routes for the HR module.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/hr_module/h1_dashboard/presentation/controller/cubit/hr_dashboard_cubit.dart';
import '../../../features/hr_module/h1_dashboard/presentation/ui/pages/hr_dashboard_page.dart';
import '../../../features/hr_module/h9_shift_management/presentation/ui/pages/shift_management_home_page.dart';
import '../../../features/hr_module/h9_shift_management/presentation/ui/pages/assign_shift_page.dart';
import '../../../features/hr_module/h9_shift_management/presentation/ui/pages/edit_employees_shift_page.dart';
import '../../../features/hr_module/h9_shift_management/presentation/ui/pages/edit_employees_shift_preview_page.dart';
import '../../../features/hr_module/h9_shift_management/presentation/controller/shift_management_cubit.dart';
import '../../../features/hr_module/h9_shift_management/presentation/controller/shift_assignment_cubit.dart';
import '../../../features/hr_module/h9_shift_management/utils/edit_shift_selection.dart';
import '../../../features/hr_module/h2_employees/presentation/ui/pages/hr_employees_page.dart';
import '../../../features/hr_module/h2_employees/presentation/ui/pages/hr_employee_details_page.dart';
import '../../../features/hr_module/h10_departments/presentation/ui/pages/hr_departments_page.dart';
import '../../../features/hr_module/h10_departments/data/repository/department_locations_repository.dart';
import '../../../features/hr_module/h10_departments/presentation/controller/department_locations_cubit.dart';
import '../../../features/hr_module/h3_add_employee/presentation/ui/pages/hr_add_employee_page.dart';
import '../../../features/roles/r2_user_management/presentation/ui/pages/request_page_approval.dart';
import '../../../features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import '../../../features/hr_module/h4_bulk_upload_employees/presentation/ui/pages/hr_employee_bulk_upload_page.dart';
import '../../../features/hr_module/h5_bulk_upload_health_insurance/presentation/ui/pages/hr_health_insurance_bulk_upload_page.dart';
import '../../../features/hr_module/h6_bulk_upload_salaries/presentation/ui/pages/hr_salary_bulk_upload_page.dart';
import '../../../features/hr_module/h7_bulk_upload_emergency_contacts/presentation/ui/pages/hr_emergency_contact_bulk_upload_page.dart';
import '../../../features/hr_module/h8_bulk_upload_certifications/presentation/ui/pages/hr_certification_bulk_upload_page.dart';
import '../../../features/hr_module/main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../features/hr_module/main_controller/domain/entity/hr_employee_entity.dart';
import 'hr_routes.dart';

/// Resolves named navigation destinations for the HR module.
class HRRouting {
  /// Method Name: [hrOnGenerateRoute]
  ///
  /// Purpose: Builds the route associated with an HR module route name.
  ///
  /// Parameters:
  /// - [settings]: Requested named-route settings.
  /// - [hrModuleDataCubit]: Shared HR module data provider.
  ///
  /// Returns: The matching HR route, or null when the route is unknown.
  static Route<dynamic>? hrOnGenerateRoute(
    RouteSettings settings, {
    required HrModuleDataCubit hrModuleDataCubit,
  }) {
    switch (settings.name) {
      case HRRoutes.hrModuleDashboardPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => HrDashboardCubit(
              hrModuleDataCubit: hrModuleDataCubit,
            ),
            child: const HRDashboardPage(),
          ),
        );
      case HRRoutes.hrModuleShiftManagementPage:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => ShiftManagementCubit(
              hrModuleDataCubit: hrModuleDataCubit,
            )..load(),
            child: const ShiftManagementHomePage(),
          ),
        );
      case HRRoutes.hrModuleAssignShiftPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ShiftAssignmentCubit(
              hrModuleDataCubit: hrModuleDataCubit,
            )..load(),
            child: const AssignShiftPage(),
          ),
        );
      case HRRoutes.hrModuleEditEmployeesShiftPage:
        final shiftManagementCubit = settings.arguments;
        if (shiftManagementCubit is! ShiftManagementCubit) return null;
        return MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: shiftManagementCubit,
            child: EditEmployeesShiftPage(),
          ),
        );
      case HRRoutes.hrModuleEditEmployeesShiftPreviewPage:
        final selection = settings.arguments;
        if (selection is! EditShiftSelection) return null;
        return MaterialPageRoute(
          builder: (_) => EditEmployeesShiftPreviewPage(selection: selection),
        );
      case HRRoutes.hrModuleRequestsPage:
        return MaterialPageRoute(
          builder: (_) => const RequestPageApproval(),
        );
      case HRRoutes.hrModuleEmployeesPage:
        return MaterialPageRoute(
          builder: (_) => const HREmployeesPage(),
        );
      case HRRoutes.hrModuleDepartmentsPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => DepartmentLocationsCubit(
              repository: DepartmentLocationsRepository(),
            )..loadLocations(),
            child: const HrDepartmentsPage(),
          ),
        );
      case HRRoutes.hrModuleAddEmployeePage:
        return MaterialPageRoute(
          builder: (_) => const HrAddEmployeePage(),
        );
      case HRRoutes.hrModuleEmployeeDetailsPage:
        final employee = settings.arguments;
        if (employee is! EmployeeEntityPro) return null;
        final hrEmployee = employee is HrEmployeeEntity
            ? employee
            : HrEmployeeEntity.fromEmployee(employee);
        return MaterialPageRoute(
          builder: (_) => HrEmployeeDetailsPage(employee: hrEmployee),
        );
      case HRRoutes.hrModuleBulkUploadEmployeesPage:
        return MaterialPageRoute(
          builder: (_) => HrEmployeeBulkUploadPage(
            hrModuleDataCubit: hrModuleDataCubit,
          ),
        );
      case HRRoutes.hrModuleBulkUploadHealthInsurancePage:
        return MaterialPageRoute(
          builder: (_) => const HrHealthInsuranceBulkUploadPage(),
        );
      case HRRoutes.hrModuleBulkUploadSalariesPage:
        return MaterialPageRoute(
            builder: (_) => HrSalaryBulkUploadPage(
                  refreshProvider: hrModuleDataCubit.refreshEmployees,
                ));
      case HRRoutes.hrModuleBulkUploadEmergencyContactsPage:
        return MaterialPageRoute(
            builder: (_) => const HrEmergencyContactBulkUploadPage());
      case HRRoutes.hrModuleBulkUploadCertificationsPage:
        return MaterialPageRoute(
            builder: (_) => HrCertificationBulkUploadPage(
                  refreshProvider: hrModuleDataCubit.refreshEmployees,
                ));
      default:
        return null;
    }
  }
}
