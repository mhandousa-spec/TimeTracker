/// Module: settings/main_controller
///
///******************** FILE INFO ****************************///
/// File Name: settings_controller.dart
/// Purpose: Shell controller for the settings module — owns the loaded
///          employee, the directory entry and the per-section controllers.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - Converted GetxController -> Cubit; the two silent
///          empty catches now emit SettingsError; repository injected; the
///          employee/employeeDirectory globals moved here.
///
/// The class name and the `Get.put` / `Get.find` registration are kept: the
/// rest of the app resolves this through GetX. Only the state mechanism
/// changed, matching how NavBarCubit and AppDrawerCubit were converted.

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/repository/settings_repository.dart';
import 'package:knowticed_plus/features/settings/main_controller/domain/base_repository/settings_base_repository.dart';
import 'package:knowticed_plus/features/settings/main_controller/data/models/employee_directory_model.dart';

import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/controller/health_insurance_controller.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/controller/personal_information_controller.dart';
import 'package:knowticed_plus/features/settings/se2_social/presentation/controller/social_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';

part './settings_state.dart';

class SettingsController extends Cubit<SettingsState> {
  /// The repository is injected so it can be faked in tests; existing call
  /// sites keep using `SettingsController()`.
  SettingsController({SettingsBaseRepository? repository})
      : repository = repository ?? SettingsRepository(),
        super(const SettingsInitial());

  /// Typed as the domain contract, not the concrete class, so tests can pass a
  /// fake (CR-SKEL-SEMAIN-N05).
  final SettingsBaseRepository repository;

  bool darkModeEnabled = false;
  final GetStorage storage = GetStorage();

  int _selectedContainerIndex = -1;

  /// Which settings section the tablet/desktop content pane is showing.
  ///
  /// FIXED 13/8/2026: this was a plain public field. Nothing observed it, so
  /// assigning to it changed no widget — on tablet and desktop, tapping a menu
  /// row updated the number and the pane never moved. Phones were unaffected,
  /// because there the card's `onTap` pushes a real route instead of selecting.
  ///
  /// The file header of `settings_screen.dart` records the cause:
  /// "GetBuilder -> BlocBuilder". Under GetX the rebuild came from `update()`;
  /// `BlocBuilder` only rebuilds on `emit`, and this assignment never emitted,
  /// so the trigger was silently lost in that conversion.
  ///
  /// The setter now emits so `settings_layout` can rebuild. [SettingsLoaded] is
  /// deliberately non-const (see settings_state.dart) — consecutive selections
  /// emit distinct instances, so bloc's equality check never drops one.
  int get selectedContainerIndex => _selectedContainerIndex;

  set selectedContainerIndex(int value) {
    if (_selectedContainerIndex == value) return;
    _selectedContainerIndex = value;
    if (!isClosed) emit(SettingsLoaded());
  }

  /// The signed-in employee. This is the single source of truth that the
  /// `employee` top-level global in `settings_screen.dart` now delegates to.
  NewEmployeeModelHistory? employee;
  EmployeeDirectoryModel? employeeDirectory;

  EmployeeController get addEmployeeController => Get.find<EmployeeController>();

  // Section controllers.
  late PersonalInformationController personalInformationController;
  late SocialController socialController;
  late SettingsHealthInsuranceController healthInsuranceController;

  bool _initialised = false;

  /// Function Name: [init]
  ///
  /// Purpose: Replaces the GetX `onInit()` hook, which Cubit does not provide.
  ///          Safe to call more than once.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    // Section controllers must exist before employee data lands.
    socialController = SocialController(settingsController: this);
    healthInsuranceController = SettingsHealthInsuranceController(this);
    personalInformationController =
        PersonalInformationController(settingsController: this);

    await getEmployee();
    await getEmployeeDirectory();
  }

  /// Function Name: [getEmployee]
  ///
  /// Purpose: Load the signed-in employee from the employee controller.
  ///
  /// Emits [SettingsError] on failure — the previous implementation swallowed
  /// everything in an empty catch, so a failed load looked identical to a
  /// successful one with no data.
  Future<void> getEmployee() async {
    final String? email = storage.read(AppConstants.emailStorageKey);
    if (email == null || email.isEmpty) {
      emit(const SettingsError('No signed-in email found on this device.'));
      return;
    }

    emit(const SettingsLoading());
    try {
      employee = await addEmployeeController.getEmployee(email);

      if (employee == null) {
        emit(const SettingsError('Could not find your employee record.'));
        return;
      }

      // Re-hydrate the section controllers now that employee data exists.
      personalInformationController =
          PersonalInformationController(settingsController: this);
      socialController.restartController();
      healthInsuranceController.getData();

      emit(SettingsLoaded());
    } catch (e) {
      emit(SettingsError('Could not load your profile: $e'));
    }
  }

  /// Function Name: [getEmployeeDirectory]
  ///
  /// Purpose: Load the directory entry for the signed-in employee.
  Future<void> getEmployeeDirectory() async {
    final String? email = storage.read(AppConstants.emailStorageKey);
    if (email == null || email.isEmpty) return;

    try {
      employeeDirectory = await addEmployeeController.getEmployeeDirectory(email);
      emit(SettingsLoaded());
    } catch (e) {
      emit(SettingsError('Could not load the employee directory: $e'));
    }
  }

  /// Function Name: [updateEmployee]
  ///
  /// Purpose: Persist a changed profile through the repository, then reload.
  ///
  /// The repository was previously injected but never called from anywhere —
  /// the settings shell had a write path with no entry point. Failures emit
  /// [SettingsError] rather than being dropped.
  ///
  /// Returns: [Future<bool>] — `true` when the write succeeded.
  Future<bool> updateEmployee(NewEmployeeModelHistory updated) async {
    final Either<Failure, void> result =
        await repository.updateEmployee(updated);

    return result.fold(
      (Failure failure) {
        emit(SettingsError('Could not save your profile: ${failure.errMessage}'));
        return false;
      },
      (_) {
        employee = updated;
        emit(SettingsLoaded());
        return true;
      },
    );
  }

  /// Function Name: [refreshEmployeeData]
  ///
  /// Purpose: Reload the employee after an update elsewhere.
  Future<void> refreshEmployeeData() => getEmployee();

  /// Function Name: [toggleDarkMode]
  void toggleDarkMode(bool value) {
    darkModeEnabled = value;
    emit(SettingsLoaded());
  }

  /// Function Name: [notifyChanged]
  ///
  /// Purpose: Rebuild the settings screens after a section controller has
  ///          mutated state this Cubit exposes.
  ///
  /// The direct replacement for the GetX `update()` that the section
  /// controllers used to call. `emit` is `@protected`, so
  /// `SettingsHealthInsuranceController` — which is a plain class, not a
  /// Cubit — cannot reach it; this is the sanctioned way in.
  void notifyChanged() => emit(SettingsLoaded());

  /// Kept for call sites that still invoke the GetX lifecycle hook by hand.
  void onInit() => init();

  @override
  Future<void> close() async {
    // SocialController is a Cubit now (round 4), so it is closed rather than
    // disposed — it no longer owns any TextEditingControllers to tear down.
    if (_initialised) await socialController.close();
    return super.close();
  }
}

// Moved here from core/helper/settings/utils/settings_constants.dart, which was
// removed. Retained as a thin alias over AppConstants so the many existing
// `SettingsConstants.emailKey` call sites keep working.
class SettingsConstants {
  const SettingsConstants._();

  static const String emailKey = AppConstants.emailStorageKey;
}
