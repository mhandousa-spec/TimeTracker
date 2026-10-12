/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: edit_page_request_health.dart
/// Purpose: The health-insurance edit form that feeds the preview page.
/// Author: Amr Mesbah
/// Created at: 20/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N14/N17: the two GetBuilder<RequestController> wrappers are
///          gone (the controller no longer has a method that calls update());
///          Get.snackbar replaced with a themed SnackBar; raw colours routed
///          through AppColors.
///
/// REMAINING (CR-SKEL-SE4-N13): the preview page is still handed 21 freshly
/// constructed TextEditingControllers that nothing disposes. Passing a value
/// model instead changes the preview page's whole constructor and ~40 read
/// sites; staged, not done.

///********************* FILE INFO ***********************///
/// Purpose: Edit page for health insurance settings with exact same UI as view page
/// Author: Assistant
/// Created: 2025
/// Updated: 31/10/2025
/// Updated By: Claude AI Assistant
/// Changes: Updated to fetch data from NewEmployeeModelHistory model
/// Description: Allows users to edit health insurance and emergency contact information

// ignore_for_file: must_be_immutable, prefer_const_declarations, unused_local_variable, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, unrelated_type_equality_checks, sdk_version_since, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/pages/preview_health_changes_page.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart' show SettingsController;

// ADDED 9/10/2026 — 2nd emergency contact optional.
import 'package:knowticed_plus/features/settings/se4_health_insurance/domain/rules/health_request_form_rules.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/widgets/sections/edit_details.dart';
import 'package:knowticed_plus/features/settings/se4_health_insurance/presentation/ui/widgets/sections/edit_health.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class EditPageRequestHealth extends StatefulWidget {
  const EditPageRequestHealth({super.key});

  @override
  _EditPageRequestHealthState createState() => _EditPageRequestHealthState();
}

class _EditPageRequestHealthState extends State<EditPageRequestHealth> {
  bool isEnglish = Get.locale.toString().contains('en');
  final _formKey = GlobalKey<FormState>();

  /// True once the user has tapped Preview — makes empty fields show
  /// their required-error state.
  bool _submitted = false;

  // Controllers
  final MainCoreEmployeeController employeeController = Get.find<MainCoreEmployeeController>();
  NewEmployeeModelHistory? currentEmployeeHistory;

  // Health Insurance Controllers
  late TextEditingController insuranceNameController;
  late TextEditingController insurancePolicyNumberController;

  // 1st Emergency Contact Controllers
  late TextEditingController firstContact_FirstNameController;
  late TextEditingController firstContact_LastNameController;
  late TextEditingController firstContact_RelationshipController;
  late TextEditingController firstContact_EmailController;
  late TextEditingController firstContact_PhoneController;
  late TextEditingController firstContact_LanguageController;
  late TextEditingController firstContact_CountryController;
  late TextEditingController firstContact_ProvinceController;
  late TextEditingController firstContact_CityController;
  late TextEditingController firstContact_StreetController;

  // 2nd Emergency Contact Controllers
  late TextEditingController secondContact_FirstNameController;
  late TextEditingController secondContact_LastNameController;
  late TextEditingController secondContact_RelationshipController;
  late TextEditingController secondContact_EmailController;
  late TextEditingController secondContact_PhoneController;
  late TextEditingController secondContact_LanguageController;
  late TextEditingController secondContact_CountryController;
  late TextEditingController secondContact_ProvinceController;
  late TextEditingController secondContact_CityController;
  late TextEditingController secondContact_StreetController;

  /// The values the page opened with, in `_allControllers` order. Preview
  /// compares against this so the button only lights up once something has
  /// actually been edited — a page that merely *has* all its fields filled is
  /// not a change request.
  late List<String> _initialValues;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();

    _initialValues =
        _allControllers.map((c) => c.text.trim()).toList(growable: false);

    // Rebuild on every keystroke so the Preview button enables/disables live.
    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }
  }

  /// Every field on this page — listened to, and compared for changes.
  /// (Since 9/10/2026 NOT all required: see [_canPreview].)
  List<TextEditingController> get _allControllers => [
    insuranceNameController,
    insurancePolicyNumberController,
    firstContact_FirstNameController,
    firstContact_LastNameController,
    firstContact_RelationshipController,
    firstContact_EmailController,
    firstContact_PhoneController,
    firstContact_LanguageController,
    firstContact_CountryController,
    firstContact_ProvinceController,
    firstContact_CityController,
    firstContact_StreetController,
    secondContact_FirstNameController,
    secondContact_LastNameController,
    secondContact_RelationshipController,
    secondContact_EmailController,
    secondContact_PhoneController,
    secondContact_LanguageController,
    secondContact_CountryController,
    secondContact_ProvinceController,
    secondContact_CityController,
    secondContact_StreetController,
  ];

  // CHANGED 9/10/2026 (owner decision) — the 2nd emergency contact is
  // OPTIONAL. `_allFieldsFilled` required all 22 fields, so an employee with
  // a single emergency contact could never submit. Now: insurance + 1st
  // contact required; the 2nd contact empty, or (once any of its fields is
  // typed in) complete. Rule + tests: HealthRequestFormRules.
  List<String> get _insuranceValues => <String>[
        insuranceNameController.text,
        insurancePolicyNumberController.text,
      ];

  List<String> get _firstContactValues => <String>[
        firstContact_FirstNameController.text,
        firstContact_LastNameController.text,
        firstContact_RelationshipController.text,
        firstContact_EmailController.text,
        firstContact_PhoneController.text,
        firstContact_LanguageController.text,
        firstContact_CountryController.text,
        firstContact_ProvinceController.text,
        firstContact_CityController.text,
        firstContact_StreetController.text,
      ];

  List<String> get _secondContactValues => <String>[
        secondContact_FirstNameController.text,
        secondContact_LastNameController.text,
        secondContact_RelationshipController.text,
        secondContact_EmailController.text,
        secondContact_PhoneController.text,
        secondContact_LanguageController.text,
        secondContact_CountryController.text,
        secondContact_ProvinceController.text,
        secondContact_CityController.text,
        secondContact_StreetController.text,
      ];

  /// True when the required fields are filled and the optional 2nd contact is
  /// either untouched or complete (9/10/2026).
  bool get _canPreview => HealthRequestFormRules.canPreview(
        insurance: _insuranceValues,
        firstContact: _firstContactValues,
        secondContact: _secondContactValues,
      );

  /// The 2nd contact's empty fields show "required" only after a submit
  /// attempt AND once that contact has been started (9/10/2026).
  bool get _secondContactSubmitted =>
      HealthRequestFormRules.showSecondContactErrors(
        submitted: _submitted,
        secondContact: _secondContactValues,
      );

  /// True once at least one field differs from what the page loaded with.
  bool get _hasChanges {
    final List<TextEditingController> current = _allControllers;
    for (int i = 0; i < current.length; i++) {
      if (current[i].text.trim() != _initialValues[i]) return true;
    }
    return false;
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  /// The Preview button. Always visible — greyed out and not tappable until
  /// the user has actually changed something AND every field has a value.
  /// Filled-but-untouched is not enough: submitting then would raise a change
  /// request that changes nothing.
  Widget _buildPreviewButton(BuildContext context) {
    // 9/10/2026: `_canPreview` (2nd contact optional) replaces
    // `_allFieldsFilled`.
    final enabled = _hasChanges && _canPreview;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: IgnorePointer(
        // 9/10/2026 (owner UI rule): a greyed-out primary button still reacts
        // to a tap once something changed — `_submitRequest` then marks the
        // missing fields red and says what is missing. With no change at all
        // there is nothing to show, so it stays inert.
        ignoring: !_hasChanges,
        child: customButton(
          title: S.of(context).preview,
          function: _submitRequest,
          color: enabled ? AppColors.primary : AppColors.darkGrey,
          width: 150.w,
          height: 38.h,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          radius: 8.r,
        ),
      ),
    );
  }

  void _loadEmployeeData() {
    // Get current employee's history data
    // CHANGED 9/10/2026 — null-safe read (was `employee!.email?.last`, which
    // throws if the settings employee has not loaded yet). An unknown email
    // leaves `currentEmployeeHistory` null, which `_submitRequest` already
    // reports with `errorOccurred` instead of crashing.
    String currentUserEmail =
        Get.find<EmployeeController>().employee?.email.lastOrNull ?? '';

    // Find the current employee from the history model
    currentEmployeeHistory = employeeController.allNewEmployees?.firstWhereOrNull(
            (emp) => emp.email.isNotEmpty && emp.email.last == currentUserEmail
    );

    // Initialize Health Insurance Controllers
    String insuranceName = '';
    String policyNumber = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.insuranceName.isNotEmpty) {
        insuranceName = currentEmployeeHistory!.insuranceName.last;
      }
      if (currentEmployeeHistory!.insurancePolicyNumber.isNotEmpty) {
        policyNumber = currentEmployeeHistory!.insurancePolicyNumber.last;
      }
    }

    insuranceNameController = TextEditingController(text: insuranceName);
    insurancePolicyNumberController = TextEditingController(text: policyNumber);

    // Initialize 1st Emergency Contact Controllers
    String firstContactFirstName = '';
    String firstContactLastName = '';
    String firstContactRelationship = '';
    String firstContactEmail = '';
    String firstContactPhone = '';
    String firstContactLanguage = '';
    String firstContactCountry = '';
    String firstContactProvince = '';
    String firstContactCity = '';
    String firstContactStreet = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.firstContactFirstName.isNotEmpty) {
        firstContactFirstName = currentEmployeeHistory!.firstContactFirstName.last;
      }
      if (currentEmployeeHistory!.firstContactLastName.isNotEmpty) {
        firstContactLastName = currentEmployeeHistory!.firstContactLastName.last;
      }
      if (currentEmployeeHistory!.firstContactRelationship.isNotEmpty) {
        firstContactRelationship = currentEmployeeHistory!.firstContactRelationship.last;
      }
      if (currentEmployeeHistory!.firstContactEmail.isNotEmpty) {
        firstContactEmail = currentEmployeeHistory!.firstContactEmail.last;
      }
      if (currentEmployeeHistory!.firstContactPhone.isNotEmpty) {
        firstContactPhone = currentEmployeeHistory!.firstContactPhone.last;
      }
      if (currentEmployeeHistory!.firstContactLanguage.isNotEmpty) {
        firstContactLanguage = currentEmployeeHistory!.firstContactLanguage.last;
      }
      if (currentEmployeeHistory!.firstContactCountry.isNotEmpty) {
        firstContactCountry = currentEmployeeHistory!.firstContactCountry.last;
      }
      if (currentEmployeeHistory!.firstContactProvince.isNotEmpty) {
        firstContactProvince = currentEmployeeHistory!.firstContactProvince.last;
      }
      if (currentEmployeeHistory!.firstContactCity.isNotEmpty) {
        firstContactCity = currentEmployeeHistory!.firstContactCity.last;
      }
      if (currentEmployeeHistory!.firstContactStreet.isNotEmpty) {
        firstContactStreet = currentEmployeeHistory!.firstContactStreet.last;
      }
    }

    firstContact_FirstNameController = TextEditingController(text: firstContactFirstName);
    firstContact_LastNameController = TextEditingController(text: firstContactLastName);
    firstContact_RelationshipController = TextEditingController(text: firstContactRelationship);
    firstContact_EmailController = TextEditingController(text: firstContactEmail);
    firstContact_PhoneController = TextEditingController(text: firstContactPhone);
    firstContact_LanguageController = TextEditingController(text: firstContactLanguage);
    firstContact_CountryController = TextEditingController(text: firstContactCountry);
    firstContact_ProvinceController = TextEditingController(text: firstContactProvince);
    firstContact_CityController = TextEditingController(text: firstContactCity);
    firstContact_StreetController = TextEditingController(text: firstContactStreet);

    // Initialize 2nd Emergency Contact Controllers
    String secondContactFirstName = '';
    String secondContactLastName = '';
    String secondContactRelationship = '';
    String secondContactEmail = '';
    String secondContactPhone = '';
    String secondContactLanguage = '';
    String secondContactCountry = '';
    String secondContactProvince = '';
    String secondContactCity = '';
    String secondContactStreet = '';

    if (currentEmployeeHistory != null) {
      if (currentEmployeeHistory!.secondContactFirstName.isNotEmpty) {
        secondContactFirstName = currentEmployeeHistory!.secondContactFirstName.last;
      }
      if (currentEmployeeHistory!.secondContactLastName.isNotEmpty) {
        secondContactLastName = currentEmployeeHistory!.secondContactLastName.last;
      }
      if (currentEmployeeHistory!.secondContactRelationship.isNotEmpty) {
        secondContactRelationship = currentEmployeeHistory!.secondContactRelationship.last;
      }
      if (currentEmployeeHistory!.secondContactEmail.isNotEmpty) {
        secondContactEmail = currentEmployeeHistory!.secondContactEmail.last;
      }
      if (currentEmployeeHistory!.secondContactPhone.isNotEmpty) {
        secondContactPhone = currentEmployeeHistory!.secondContactPhone.last;
      }
      if (currentEmployeeHistory!.secondContactLanguage.isNotEmpty) {
        secondContactLanguage = currentEmployeeHistory!.secondContactLanguage.last;
      }
      if (currentEmployeeHistory!.secondContactCountry.isNotEmpty) {
        secondContactCountry = currentEmployeeHistory!.secondContactCountry.last;
      }
      if (currentEmployeeHistory!.secondContactProvince.isNotEmpty) {
        secondContactProvince = currentEmployeeHistory!.secondContactProvince.last;
      }
      if (currentEmployeeHistory!.secondContactCity.isNotEmpty) {
        secondContactCity = currentEmployeeHistory!.secondContactCity.last;
      }
      if (currentEmployeeHistory!.secondContactStreet.isNotEmpty) {
        secondContactStreet = currentEmployeeHistory!.secondContactStreet.last;
      }
    }

    secondContact_FirstNameController = TextEditingController(text: secondContactFirstName);
    secondContact_LastNameController = TextEditingController(text: secondContactLastName);
    secondContact_RelationshipController = TextEditingController(text: secondContactRelationship);
    secondContact_EmailController = TextEditingController(text: secondContactEmail);
    secondContact_PhoneController = TextEditingController(text: secondContactPhone);
    secondContact_LanguageController = TextEditingController(text: secondContactLanguage);
    secondContact_CountryController = TextEditingController(text: secondContactCountry);
    secondContact_ProvinceController = TextEditingController(text: secondContactProvince);
    secondContact_CityController = TextEditingController(text: secondContactCity);
    secondContact_StreetController = TextEditingController(text: secondContactStreet);
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChanged);
    }

    // Dispose Health Insurance Controllers
    insuranceNameController.dispose();
    insurancePolicyNumberController.dispose();

    // Dispose 1st Emergency Contact Controllers
    firstContact_FirstNameController.dispose();
    firstContact_LastNameController.dispose();
    firstContact_RelationshipController.dispose();
    firstContact_EmailController.dispose();
    firstContact_PhoneController.dispose();
    firstContact_LanguageController.dispose();
    firstContact_CountryController.dispose();
    firstContact_ProvinceController.dispose();
    firstContact_CityController.dispose();
    firstContact_StreetController.dispose();

    // Dispose 2nd Emergency Contact Controllers
    secondContact_FirstNameController.dispose();
    secondContact_LastNameController.dispose();
    secondContact_RelationshipController.dispose();
    secondContact_EmailController.dispose();
    secondContact_PhoneController.dispose();
    secondContact_LanguageController.dispose();
    secondContact_CountryController.dispose();
    secondContact_ProvinceController.dispose();
    secondContact_CityController.dispose();
    secondContact_StreetController.dispose();

    super.dispose();
  }

  void _submitRequest() async {
    // Block the preview until the REQUIRED fields are filled (9/10/2026: the
    // 2nd emergency contact is optional — empty, or complete once started).
    // Marking as submitted turns the empty fields red so the user
    // can see exactly what is missing.
    if (!_canPreview) {
      setState(() => _submitted = true);
      final bool onlySecondContact = HealthRequestFormRules.isComplete(
              _insuranceValues) &&
          HealthRequestFormRules.isComplete(_firstContactValues) &&
          HealthRequestFormRules.isSecondContactIncomplete(
              _secondContactValues);
      _showError(onlySecondContact
          ? S.of(context).secondContactIncomplete
          : S.of(context).fillAllRequiredFields);
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Collect all changes by comparing old vs new values
      Map<String, dynamic> changes = {};

      if (currentEmployeeHistory == null) {
        _showError(S.of(context).errorOccurred);
        return;
      }

      // Helper function to get last value safely
      String getLastValue(List<String> list) => list.isNotEmpty ? list.last : '';

      // Health Insurance Changes
      String oldInsuranceName = getLastValue(currentEmployeeHistory!.insuranceName);
      String newInsuranceName = insuranceNameController.text.trim();
      if (oldInsuranceName != newInsuranceName) {
        changes['insuranceName'] = {
          'oldValue': oldInsuranceName,
          'newValue': newInsuranceName,
        };
      }

      String oldPolicyNumber = getLastValue(currentEmployeeHistory!.insurancePolicyNumber);
      String newPolicyNumber = insurancePolicyNumberController.text.trim();
      if (oldPolicyNumber != newPolicyNumber) {
        changes['insurancePolicyNumber'] = {
          'oldValue': oldPolicyNumber,
          'newValue': newPolicyNumber,
        };
      }

      // 1st Emergency Contact Changes
      if (getLastValue(currentEmployeeHistory!.firstContactFirstName) != firstContact_FirstNameController.text.trim()) {
        changes['firstContact_firstName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactFirstName),
          'newValue': firstContact_FirstNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactLastName) != firstContact_LastNameController.text.trim()) {
        changes['firstContact_lastName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactLastName),
          'newValue': firstContact_LastNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactRelationship) != firstContact_RelationshipController.text.trim()) {
        changes['firstContact_relationship'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactRelationship),
          'newValue': firstContact_RelationshipController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactEmail) != firstContact_EmailController.text.trim()) {
        changes['firstContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactEmail),
          'newValue': firstContact_EmailController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactPhone) != firstContact_PhoneController.text.trim()) {
        changes['firstContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactPhone),
          'newValue': firstContact_PhoneController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactLanguage) != firstContact_LanguageController.text.trim()) {
        changes['firstContact_language'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactLanguage),
          'newValue': firstContact_LanguageController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactCountry) != firstContact_CountryController.text.trim()) {
        changes['firstContact_country'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCountry),
          'newValue': firstContact_CountryController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactProvince) != firstContact_ProvinceController.text.trim()) {
        changes['firstContact_province'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactProvince),
          'newValue': firstContact_ProvinceController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactCity) != firstContact_CityController.text.trim()) {
        changes['firstContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactCity),
          'newValue': firstContact_CityController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.firstContactStreet) != firstContact_StreetController.text.trim()) {
        changes['firstContact_street'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.firstContactStreet),
          'newValue': firstContact_StreetController.text.trim(),
        };
      }

      // 2nd Emergency Contact Changes
      if (getLastValue(currentEmployeeHistory!.secondContactFirstName) != secondContact_FirstNameController.text.trim()) {
        changes['secondContact_firstName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactFirstName),
          'newValue': secondContact_FirstNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactLastName) != secondContact_LastNameController.text.trim()) {
        changes['secondContact_lastName'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactLastName),
          'newValue': secondContact_LastNameController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactRelationship) != secondContact_RelationshipController.text.trim()) {
        changes['secondContact_relationship'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactRelationship),
          'newValue': secondContact_RelationshipController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactEmail) != secondContact_EmailController.text.trim()) {
        changes['secondContact_email'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactEmail),
          'newValue': secondContact_EmailController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactPhone) != secondContact_PhoneController.text.trim()) {
        changes['secondContact_phone'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactPhone),
          'newValue': secondContact_PhoneController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactLanguage) != secondContact_LanguageController.text.trim()) {
        changes['secondContact_language'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactLanguage),
          'newValue': secondContact_LanguageController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactCountry) != secondContact_CountryController.text.trim()) {
        changes['secondContact_country'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactCountry),
          'newValue': secondContact_CountryController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactProvince) != secondContact_ProvinceController.text.trim()) {
        changes['secondContact_province'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactProvince),
          'newValue': secondContact_ProvinceController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactCity) != secondContact_CityController.text.trim()) {
        changes['secondContact_city'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactCity),
          'newValue': secondContact_CityController.text.trim(),
        };
      }

      if (getLastValue(currentEmployeeHistory!.secondContactStreet) != secondContact_StreetController.text.trim()) {
        changes['secondContact_street'] = {
          'oldValue': getLastValue(currentEmployeeHistory!.secondContactStreet),
          'newValue': secondContact_StreetController.text.trim(),
        };
      }

      // Check if there are any changes
      if (changes.isEmpty) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            var lightMode = Theme.of(context).brightness == Brightness.light;
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                width: 411.w,
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.background,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lottie Animation
                    Lottie.asset(
                      'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
                      width: 100.w,
                      height: 100.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16.h),
                    // Error Message
                    Text(
                      S.of(context).noChangeFound,
                      style: StyleText.fontSize18Weight500.copyWith(
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
        return;
      }

      // Navigate to Preview Page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewHealthInsuranceChangesPage(
            changes: changes,
            insuranceNameController: TextEditingController(
                text: FormatHelper.capitalize(insuranceNameController.text)
            ),
            insurancePolicyNumberController: TextEditingController(
                text: FormatHelper.capitalize(insurancePolicyNumberController.text)
            ),
            firstContact_FirstNameController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_FirstNameController.text)
            ),
            firstContact_LastNameController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_LastNameController.text)
            ),
            firstContact_RelationshipController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_RelationshipController.text)
            ),
            firstContact_EmailController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_EmailController.text)
            ),
            firstContact_PhoneController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_PhoneController.text)
            ),
            firstContact_LanguageController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_LanguageController.text)
            ),
            firstContact_CountryController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_CountryController.text)
            ),
            firstContact_ProvinceController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_ProvinceController.text)
            ),
            firstContact_CityController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_CityController.text)
            ),
            firstContact_StreetController: TextEditingController(
                text: FormatHelper.capitalize(firstContact_StreetController.text)
            ),
            secondContact_FirstNameController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_FirstNameController.text)
            ),
            secondContact_LastNameController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_LastNameController.text)
            ),
            secondContact_RelationshipController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_RelationshipController.text)
            ),
            secondContact_EmailController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_EmailController.text)
            ),
            secondContact_PhoneController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_PhoneController.text)
            ),
            secondContact_LanguageController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_LanguageController.text)
            ),
            secondContact_CountryController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_CountryController.text)
            ),
            secondContact_ProvinceController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_ProvinceController.text)
            ),
            secondContact_CityController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_CityController.text)
            ),
            secondContact_StreetController: TextEditingController(
                text: FormatHelper.capitalize(secondContact_StreetController.text)
            ),
          ),
        ),
      );
    }
  }

  /// Was `Get.snackbar` with raw Colors.red/white (CR-SKEL-SE4-N17).
  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
          backgroundColor: AppColors.signOut,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;
    return Scaffold(
      body: isMobile ?

      SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: (){
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingHealthInsurance,
        // Was GetBuilder<RequestController>; the controller no longer has any
        // write method that calls update(), so it rebuilt on nothing
        // (CR-SKEL-SE6-N09).
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: SingleChildScrollView(

                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        // Card shell matched to the view page (se1_profile /
                        // settings_health_insurance): AppColors.card, an 8.r
                        // radius and 15.sp between cards. The outer wrapper
                        // that used to paint its own background behind these
                        // is gone — it made the three cards read as one slab,
                        // which is exactly what the view page stopped doing.
                        Container(
                          decoration: !isTablet
                              ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: AppColors.card,
                          )
                              : null,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: 15.sp,
                              left: 15.sp,
                              top: 15.sp,
                              bottom: !isTablet ? 15.sp : 0,
                            ),
                            child: EditableHealthInsuranceSection(
                              insuranceNameController: insuranceNameController,
                              insurancePolicyNumberController: insurancePolicyNumberController,
                              submitted: _submitted,
                            ),
                          ),
                        ),
                        SizedBox(height: 15.sp),

                        // 1st Emergency Contact Section (Editable)
                        Container(
                          padding: EdgeInsets.only(
                            left: !isTablet ? 15.sp : 0,
                            right: !isTablet ? 15.sp : 0,
                            top: !isTablet ? 15.sp : 0,
                            bottom: !isTablet ? 15.sp : 0,
                          ),
                          decoration: !isTablet
                              ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: AppColors.card,
                          )
                              : null,
                          child: EditableEmergencyContactInformationSection(
                            submitted: _submitted,
                            isFirstContact: true,
                            firstNameController: firstContact_FirstNameController,
                            lastNameController: firstContact_LastNameController,
                            relationshipController: firstContact_RelationshipController,
                            emailController: firstContact_EmailController,
                            mobilePhoneController: firstContact_PhoneController,
                            languageController: firstContact_LanguageController,
                            countryController: firstContact_CountryController,
                            provinceController: firstContact_ProvinceController,
                            cityController: firstContact_CityController,
                            streetController: firstContact_StreetController,
                          ),
                        ),
                        SizedBox(height: 15.sp),

                        // 2nd Emergency Contact Section (Editable)
                        Container(
                          padding: EdgeInsets.only(
                            left: !isTablet ? 15.sp : 0,
                            right: !isTablet ? 15.sp : 0,
                            top: !isTablet ? 15.sp : 0,
                            bottom: !isTablet ? 15.sp : 0,
                          ),
                          decoration: !isTablet
                              ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: AppColors.card,
                          )
                              : null,
                          child: EditableEmergencyContactInformationSection(
                            // 9/10/2026 — optional contact: errors only once
                            // started; the hint says so.
                            submitted: _secondContactSubmitted,
                            optionalHint: S.of(context).secondContactOptionalHint,
                            isFirstContact: false,
                            firstNameController: secondContact_FirstNameController,
                            lastNameController: secondContact_LastNameController,
                            relationshipController: secondContact_RelationshipController,
                            emailController: secondContact_EmailController,
                            mobilePhoneController: secondContact_PhoneController,
                            languageController: secondContact_LanguageController,
                            countryController: secondContact_CountryController,
                            provinceController: secondContact_ProvinceController,
                            cityController: secondContact_CityController,
                            streetController: secondContact_StreetController,
                          ),
                        ),

                        SizedBox(height: 15.sp),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Discard Changes Button
                            customButton(
                              title: S.of(context).discardChange,
                              function: (){
                                Navigator.pop(context);
                              },
                              color: AppColors.darkGrey,
                              width: 150.w,
                              height: 38.h,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.white,
                              ),
                              radius: 8.r,
                            ),
                            Spacer(),

                            // Submit Button (Now goes to Preview)
                            _buildPreviewButton(context),
                          ],
                        ),

                        SizedBox(height: 20.sp),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ),
      ) :

      SideFrameMasterServices(
        titleText: S.of(context).settings,
        onFirstTap: (){
          Navigator.pop(context);
        },
        secondTitle: S.of(context).editingHealthInsurance,
        // Was GetBuilder<RequestController>; the controller no longer has any
        // write method that calls update(), so it rebuilt on nothing
        // (CR-SKEL-SE6-N09).
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15.sp),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Health Insurance Section (Editable)
                                EditableHealthInsuranceSection(
                                  insuranceNameController: insuranceNameController,
                                  insurancePolicyNumberController: insurancePolicyNumberController,
                                  submitted: _submitted,
                                ),
                                SizedBox(height: 20.h),

                                // 1st Emergency Contact Section (Editable)
                                EditableEmergencyContactInformationSection(
                                  submitted: _submitted,
                                  isFirstContact: true,
                                  firstNameController: firstContact_FirstNameController,
                                  lastNameController: firstContact_LastNameController,
                                  relationshipController: firstContact_RelationshipController,
                                  emailController: firstContact_EmailController,
                                  mobilePhoneController: firstContact_PhoneController,
                                  languageController: firstContact_LanguageController,
                                  countryController: firstContact_CountryController,
                                  provinceController: firstContact_ProvinceController,
                                  cityController: firstContact_CityController,
                                  streetController: firstContact_StreetController,
                                ),
                                SizedBox(height: 20.h),

                                // 2nd Emergency Contact Section (Editable)
                                EditableEmergencyContactInformationSection(
                                  // 9/10/2026 — optional contact (see phone
                                  // layout above).
                                  submitted: _secondContactSubmitted,
                                  optionalHint:
                                      S.of(context).secondContactOptionalHint,
                                  isFirstContact: false,
                                  firstNameController: secondContact_FirstNameController,
                                  lastNameController: secondContact_LastNameController,
                                  relationshipController: secondContact_RelationshipController,
                                  emailController: secondContact_EmailController,
                                  mobilePhoneController: secondContact_PhoneController,
                                  languageController: secondContact_LanguageController,
                                  countryController: secondContact_CountryController,
                                  provinceController: secondContact_ProvinceController,
                                  cityController: secondContact_CityController,
                                  streetController: secondContact_StreetController,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // Action Buttons
                        // This row used to hold two Discard buttons and no
                        // Preview button, so the tablet layout had no way to
                        // reach the preview page at all.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Discard Changes Button
                            customButton(
                              title: S.of(context).discardChange,
                              function: (){
                                Navigator.pop(context);
                              },
                              color: AppColors.darkGrey,
                              width: 150.w,
                              height: 38.h,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color:  AppColors.white,
                              ),
                              radius: 8.r,
                            ),
                            Spacer(),

                            // Preview Button
                            _buildPreviewButton(context),
                          ],
                        ),

                        SizedBox(height: 10.sp),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ),
      ),
    );
  }
}