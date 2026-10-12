/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: employee_directory_repository_impl.dart
/// Purpose: Declares `EmployeeDirectoryRepositoryImpl` — the company's
///          employees for the Employees / Groups screens, read from the
///          app-wide employee cache (`MainCoreEmployeeController`, which
///          loads `Demo/{cid}/Employees_Info`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// The legacy controller is reached through `AppControllers` (playbook §3 —
/// no `package:get` in the module). When the cache is still empty it is
/// refreshed once. Inactive / deleted employees are left out; e-mails are
/// lower-cased and de-duplicated. Read-only.
/// Updated: 9/10/2026 - phase 4: also maps the employee id and role.

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';

class EmployeeDirectoryRepositoryImpl implements EmployeeDirectoryBaseRepository {
  const EmployeeDirectoryRepositoryImpl();

  /// Stored statuses that hide an employee from the set-up screens.
  static const Set<String> _hiddenStatuses = <String>{
    'inactive',
    'deleted',
    'disabled',
    'terminated',
  };

  @override
  Future<List<TimeTrackerEmployee>> fetchEmployees({
    required bool isArabic,
  }) async {
    if (!AppControllers.isEmployeeRegistered) return const <TimeTrackerEmployee>[];
    try {
      final controller = AppControllers.employee;
      var all = controller.allEmployeesEntities ?? const [];
      if (all.isEmpty) {
        all = await controller.getAllNewEmployees() ?? const [];
      }
      final Map<String, TimeTrackerEmployee> byEmail = <String, TimeTrackerEmployee>{};
      for (final e in all) {
        final String email = (e.email ?? '').trim().toLowerCase();
        if (email.isEmpty || byEmail.containsKey(email)) continue;
        if (_hiddenStatuses.contains((e.status ?? '').trim().toLowerCase())) {
          continue;
        }
        String join(String? a, String? b) =>
            '${(a ?? '').trim()} ${(b ?? '').trim()}'.trim();
        final String departmentId = (e.departmentId ?? '').trim();
        byEmail[email] = TimeTrackerEmployee(
          email: email,
          nameEn: join(e.firstName, e.lastName),
          nameAr: join(e.firstNameInArabic, e.lastNameInArabic),
          jobTitleEn: (e.title ?? '').trim(),
          jobTitleAr: (e.titleInArabic ?? '').trim(),
          departmentId: departmentId,
          departmentName: departmentId.isEmpty
              ? ''
              : controller.departmentController
                  .getDepartmentName(departmentId, !isArabic),
          // 9/10/2026 (QA KP-TT-017): both languages, so cards follow the
          // app language (`TimeTrackerEmployee.department`).
          departmentNameEn: departmentId.isEmpty
              ? ''
              : controller.departmentController.getDepartmentName(departmentId, true),
          departmentNameAr: departmentId.isEmpty
              ? ''
              : controller.departmentController.getDepartmentName(departmentId, false),
          phone: e.mobilePhone?.phone ?? '',
          photo: controller.getEmployeePhoto(e.email ?? ''),
          employeeId: (e.id ?? '').trim(),
          role: (e.role ?? '').trim(),
        );
      }
      final List<TimeTrackerEmployee> list = byEmail.values.toList()
        ..sort((TimeTrackerEmployee a, TimeTrackerEmployee b) => a
            .name(isArabic: isArabic)
            .toLowerCase()
            .compareTo(b.name(isArabic: isArabic).toLowerCase()));
      return List<TimeTrackerEmployee>.unmodifiable(list);
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Could not load the employees: $error');
    }
  }

  @override
  Future<Map<String, String>> fetchDepartments({required bool isArabic}) async {
    if (!AppControllers.isEmployeeRegistered) return const <String, String>{};
    try {
      final departments = AppControllers.employee.departmentController;
      if (departments.departmentIds.isEmpty) await departments.getAllDepartments();
      final List<String> ids = departments.departmentIds;
      final List<String> names =
          isArabic ? departments.departmentsArabicName : departments.departmentsEnglishName;
      return Map<String, String>.unmodifiable(<String, String>{
        for (int i = 0; i < ids.length; i++)
          if (ids[i].trim().isNotEmpty)
            ids[i]: i < names.length && names[i].trim().isNotEmpty ? names[i].trim() : ids[i],
      });
    } catch (error) {
      if (error is Exception) rethrow;
      throw Exception('Could not load the departments: $error');
    }
  }
}
