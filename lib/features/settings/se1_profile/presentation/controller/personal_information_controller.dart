/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: personal_information_controller.dart
/// Purpose: Exposes the personal-information read model and tracks what the
///          user changed, for the "request to change" flow.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N07/N08: the ten TextEditingControllers are
///          gone — form state belongs to the editing page's State, and this
///          page is read-only, so nothing needed them. `initPersonalInformation`
///          (which only copied employee values into those controllers) went
///          with them; [profile] replaces it. Explicit return types added.

import 'package:knowticed_plus/core/helper/main_helper/phone_number.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/use_cases/build_personal_profile.dart';

class PersonalInformationController {
  PersonalInformationController({
    required this.settingsController,
    BuildPersonalProfile? buildPersonalProfile,
  }) : _buildPersonalProfile =
            buildPersonalProfile ?? const BuildPersonalProfile();

  final SettingsController settingsController;
  final BuildPersonalProfile _buildPersonalProfile;

  /// Function Name: [profile]
  ///
  /// Purpose: The page's read model, rebuilt from whatever the settings shell
  ///          currently holds.
  ///
  /// Returns: [PersonalProfile] — never null; an unloaded employee yields
  ///          [PersonalProfile.empty]. Widgets take this instead of reaching
  ///          for the `employee` global (CR-SKEL-SE1-N17).
  PersonalProfile get profile =>
      _buildPersonalProfile(settingsController.employee);

  // ── Pending edits ─────────────────────────────────────────────────────────
  // What the user typed/picked but has not submitted yet. These used to be
  // duplicated as top-level globals in the deleted profile_screen.dart
  // (CR-SKEL-SE1-N02); this is now the only copy.

  String? firstName;
  String? middleName;
  String? lastName;

  String? email;
  PhoneNumber? phone;
  String? address;
  String? country;
  String? city;
  String? province;

  String? selectedGender;
  String? selectedNationality;
  String? selectedMaritalStatus;

  /// Pending birth date, in `EmployeeDateFormatter.storagePattern` form. Was a
  /// `TextEditingController` used purely as a string box.
  String? birthDate;

  /// Function Name: [hasPendingChanges]
  ///
  /// Purpose: Whether anything has been edited since the page opened.
  bool get hasPendingChanges =>
      firstName != null ||
      middleName != null ||
      lastName != null ||
      birthDate != null ||
      selectedGender != null ||
      selectedMaritalStatus != null ||
      selectedNationality != null;

  void firstNameOnChanged(String value) {
    firstName = value.trim().toLowerCase();
  }

  void lastNameOnChanged(String value) {
    lastName = value.trim().toLowerCase();
  }

  void middleNameOnChanged(String value) {
    middleName = value.trim().toLowerCase();
  }
}
