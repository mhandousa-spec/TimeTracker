/// Module: services_management_module
/// Description: Cubit owning I/O for the home/services list screen:
///              employee bootstrap (waiting for MainCoreEmployeeController
///              to finish loading), department-name lookup with its
///              fallback path, clearing stale provider selections on the
///              module-level ServicesManagerCubit, persisting the
///              requester's profile fields to SharedPreferences
///              (startApp), and fetching additional Firebase drafts.
///              home_page_services.dart calls these methods instead of
///              doing raw I/O + try/catch inline.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: MainCoreEmployeeController, MainCoreDepartmentCubit,
///              ServicesManagerCubit, SharedPrefsServiceMaster,
///              SharedPrefsEmployeeHelper, SharedPreferences
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Initial version — extracted from
///     home_page_services.dart (fix item 1). Moves 6 of the file's 9
///     try/catch blocks here (employee bootstrap, department fallback
///     lookup, provider-selection clearing, startApp persistence, Firebase
///     drafts fetch). The remaining 3 try/catches live inside
///     _applyFilters()/its department-reload fallback, which stay on the
///     page because they are tightly coupled to BuildContext-dependent
///     localization (S.of(context)) and setState-driven filter state —
///     converting that flow to Bloc state was judged too high-risk to do
///     blind without a compiler (see audit report). Emits
///     loading/error states from waitForEmployee/fetchAdditionalFirebaseDrafts
///     for future BlocListener/BlocBuilder consumers; the page currently
///     still drives its own setState-based loading flag in parallel.
///   - 02/07/2026 (Knowticed Team, fix item 10): AppControllers.employee
///     / departmentCubit are retained deliberately —
///     these singletons have no Provider/BlocProvider registration anywhere
///     in the app (verified via grep across lib/), so Get.find is the only
///     way to reach them. This is the sole remaining GetX usage in this file.
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/services_prefs_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/controller/home_page_services_state.dart';

class HomePageServicesCubit extends Cubit<HomePageServicesState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  final ServicesManagerCubit servicesManagerCubit;

  /// Department lookups are injected; no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  HomePageServicesCubit({
    required this.servicesManagerCubit,
    required this.departmentCubit,
  }) : super(HomePageServicesInitial());

  /// Waits (up to ~10s) for MainCoreEmployeeController to finish loading the
  /// current employee, then returns it. Returns null if it never loads.
  /// Emits [HomePageServicesLoading] while waiting and
  /// [HomePageServicesError] if the employee never loads, so callers that
  /// want to react via BlocListener/BlocBuilder can (the page itself still
  /// drives its own setState-based loading flag for the initial-load UI —
  /// see class header for why the full page wasn't converted to BlocBuilder).
  Future<EmployeeEntityPro?> waitForEmployee() async {
    emit(HomePageServicesLoading());
    final controller = AppControllers.employee;

    int attempts = 0;
    while (controller.employeeEntity == null && attempts < 100) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    final entity = controller.employeeEntity;
    if (entity == null) {
      emit(const HomePageServicesError('Employee failed to load'));
    }
    return entity;
  }

  /// Runs the one-time post-employee-load bootstrap: fixes existing drafts,
  /// clears selected-employee prefs, clears the module cubit's stale
  /// provider selection, and kicks off the services load.
  Future<void> bootstrapAfterEmployeeLoaded() async {
    await SharedPrefsServiceMaster.fixExistingDrafts();
    await SharedPrefsEmployeeHelper.clearSelectedEmployees();
    clearStaleProviderSelection();
    servicesManagerCubit.loadServices();
  }

  /// Clears any stale provider-selection left on the module-level cubit's
  /// in-progress doc. Never throws — a missing/invalid docService is a
  /// no-op, not an error.
  void clearStaleProviderSelection() {
    final doc = servicesManagerCubit.docService;
    if (doc != null) {
      servicesManagerCubit.docService = doc.copyWith(providerServices: []);
    }
  }

  /// Looks up the employee's department name, using
  /// [MainCoreEmployeeController.getEmployeeDepartmentName] first and
  /// falling back to [MainCoreDepartmentCubit.getDepartmentName] via
  /// the employee's departmentId if that comes back empty.
  String resolveUserDepartment(EmployeeEntityPro? employeeEntity, String userEmail) {
    if (userEmail.isEmpty) return '';

    var department =
        AppControllers.employee.getEmployeeDepartmentName(userEmail);

    if (department.isEmpty && employeeEntity?.departmentId != null) {
      final fallback = departmentCubit.getDepartmentName(
        employeeEntity!.departmentId!,
        true, // English
      );
      if (fallback.isNotEmpty) department = fallback;
    }

    return department;
  }

  /// Persists the requester's profile fields to SharedPreferences so the
  /// "request service" flow can read them back. Mirrors the original
  /// startApp() 2-second UX delay (kept for parity with existing behavior).
  Future<void> persistRequesterProfile(EmployeeEntityPro employeeEntity) async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final department = departmentCubit
        .getEnglishDepartmentNameFromDepartmentId(
      departmentId: employeeEntity.departmentId!,
    );

    await prefs.setString("emailRequester", employeeEntity.email ?? '');
    await prefs.setString("firstNameRequester", employeeEntity.firstName ?? '');
    await prefs.setString("lastNameRequester", employeeEntity.lastName ?? '');
    await prefs.setString("genderRequester", employeeEntity.gender ?? '');
    await prefs.setString("phoneRequester", employeeEntity.mobilePhone?.phone ?? '');
    await prefs.setString(
        "firstNameRequesterArabic", employeeEntity.firstNameInArabic ?? '');
    await prefs.setString(
        "lastNameRequesterArabic", employeeEntity.lastNameInArabic ?? '');
    await prefs.setString(
        "jobTitleRequesterArabic", employeeEntity.titleInArabic ?? '');
    await prefs.setString("jobTitleRequester", employeeEntity.title ?? '');
    await prefs.setString("departmentRequester", department ?? '');

    if (employeeEntity.email != null) {
      await servicesManagerCubit.getMyApprovalServices(employeeEntity.email!);
    }
  }

  /// Fetches any additional Firebase drafts not already present locally.
  /// Returns an empty list on failure instead of throwing (drafts are
  /// best-effort — a fetch failure shouldn't block showing local data), but
  /// still emits [HomePageServicesError] so listeners can surface a
  /// non-blocking notice if desired.
  Future<List<ServicesHistoryModel>> fetchAdditionalFirebaseDrafts() async {
    try {
      return await servicesManagerCubit.getFirebaseDrafts();
    } catch (e) {
      debugPrint('HomePageServicesCubit: failed to fetch Firebase drafts: $e');
      emit(HomePageServicesError('Failed to fetch drafts: $e'));
      return [];
    }
  }

  /// Resolves the provider map for one service, in order: the service's own
  /// provider data, then the repository.
  Future<Map<String, dynamic>?> selectServiceProvider(String serviceId) {
    return servicesManagerCubit.repository.selectServiceProvider(serviceId);
  }
}
