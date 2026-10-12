/// Module: settings/se5_emergency_contact
///
///*************************** FILE INFO ****************************///
/// File Name: emergency_contact_information_section.dart
/// Purpose: Displays one emergency contact (1st or 2nd) in the settings
///          health-insurance screen.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE5-N14/N15: the three `Get.find<...>()` calls
///          in `build` are gone — the employee history comes in as a
///          constructor argument, resolved once by the caller — and the
///          14-line commented-out print block is deleted.
///          Earlier: added support for both contacts from the history model.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EmergencyContactInformationSection extends StatelessWidget {
  const EmergencyContactInformationSection({
    super.key,
    required this.employeeHistory,
    this.isFirstContact = true,
  });

  /// The employee whose contacts are shown. Was resolved inside `build` with
  /// three `Get.find<...>()` calls — service location in a widget
  /// (CR-SKEL-SE5-N14).
  final NewEmployeeModelHistory? employeeHistory;

  /// `true` for the 1st contact, `false` for the 2nd.
  final bool isFirstContact;

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    final NewEmployeeModelHistory? currentEmployeeHistory = employeeHistory;
    // Initialize variables for contact data
    String firstName = '';
    String lastName = '';
    String relationship = '';
    String email = '';
    String phone = '';
    String language = '';
    String country = '';
    String province = '';
    String city = '';
    String street = '';

    // Get data based on which contact (1st or 2nd) from history
    if (currentEmployeeHistory != null) {
      if (isFirstContact) {
        // First contact data (get last value from arrays)
        if (currentEmployeeHistory.firstContactFirstName.isNotEmpty) {
          firstName = currentEmployeeHistory.firstContactFirstName.last;
        }
        if (currentEmployeeHistory.firstContactLastName.isNotEmpty) {
          lastName = currentEmployeeHistory.firstContactLastName.last;
        }
        if (currentEmployeeHistory.firstContactRelationship.isNotEmpty) {
          relationship = currentEmployeeHistory.firstContactRelationship.last;
        }
        if (currentEmployeeHistory.firstContactEmail.isNotEmpty) {
          email = currentEmployeeHistory.firstContactEmail.last;
        }
        if (currentEmployeeHistory.firstContactPhone.isNotEmpty) {
          phone = currentEmployeeHistory.firstContactPhone.last;
        }
        if (currentEmployeeHistory.firstContactLanguage.isNotEmpty) {
          language = currentEmployeeHistory.firstContactLanguage.last;
        }
        if (currentEmployeeHistory.firstContactCountry.isNotEmpty) {
          country = currentEmployeeHistory.firstContactCountry.last;
        }
        if (currentEmployeeHistory.firstContactProvince.isNotEmpty) {
          province = currentEmployeeHistory.firstContactProvince.last;
        }
        if (currentEmployeeHistory.firstContactCity.isNotEmpty) {
          city = currentEmployeeHistory.firstContactCity.last;
        }
        if (currentEmployeeHistory.firstContactStreet.isNotEmpty) {
          street = currentEmployeeHistory.firstContactStreet.last;
        }
      } else {
        // Second contact data (get last value from arrays)
        if (currentEmployeeHistory.secondContactFirstName.isNotEmpty) {
          firstName = currentEmployeeHistory.secondContactFirstName.last;
        }
        if (currentEmployeeHistory.secondContactLastName.isNotEmpty) {
          lastName = currentEmployeeHistory.secondContactLastName.last;
        }
        if (currentEmployeeHistory.secondContactRelationship.isNotEmpty) {
          relationship = currentEmployeeHistory.secondContactRelationship.last;
        }
        if (currentEmployeeHistory.secondContactEmail.isNotEmpty) {
          email = currentEmployeeHistory.secondContactEmail.last;
        }
        if (currentEmployeeHistory.secondContactPhone.isNotEmpty) {
          phone = currentEmployeeHistory.secondContactPhone.last;
        }
        if (currentEmployeeHistory.secondContactLanguage.isNotEmpty) {
          language = currentEmployeeHistory.secondContactLanguage.last;
        }
        if (currentEmployeeHistory.secondContactCountry.isNotEmpty) {
          country = currentEmployeeHistory.secondContactCountry.last;
        }
        if (currentEmployeeHistory.secondContactProvince.isNotEmpty) {
          province = currentEmployeeHistory.secondContactProvince.last;
        }
        if (currentEmployeeHistory.secondContactCity.isNotEmpty) {
          city = currentEmployeeHistory.secondContactCity.last;
        }
        if (currentEmployeeHistory.secondContactStreet.isNotEmpty) {
          street = currentEmployeeHistory.secondContactStreet.last;
        }
      }
    }

    // Controllers for all fields
    final firstNameController = TextEditingController(
      text: FormatHelper.capitalize(firstName),
    );
    final lastNameController = TextEditingController(
      text: FormatHelper.capitalize(lastName),
    );
    final relationshipController = TextEditingController(
      text: FormatHelper.capitalize(relationship),
    );
    final emailController = TextEditingController(
      text: email,
    );
    final mobilePhoneController = TextEditingController(
      text: phone,
    );
    final languageController = TextEditingController(
      text: FormatHelper.capitalize(language),
    );
    final countryController = TextEditingController(
      text: FormatHelper.capitalize(country),
    );
    final provinceController = TextEditingController(
      text: FormatHelper.capitalize(province),
    );
    final cityController = TextEditingController(
      text: FormatHelper.capitalize(city),
    );
    final streetController = TextEditingController(
      text: FormatHelper.capitalize(street),
    );

    // Header text based on which contact
    final headerText = isFirstContact
        ? S.of(context).emergencyContact
        : S.of(context).secondEmergencyContact;

    return Padding(
      padding: EdgeInsets.only(right: 15.sp,left: 15.sp,top: context.isPhone ? 0.sp : 15.sp,bottom: 15.sp),
      child: Column(
        children: [
          SizedBox(height: 15.sp,),
          SettingsHeader(
            // 0: the Padding wrapping this section already applies 15.sp on
            // each side, so SettingsHeader must not add its own on top.
            horizontalPadding: 0,
            imagePath: 'assets/icons_assets/main_icons_assets/emergency_contact_person.svg',
            text: headerText,
          ),
          // Mobile only: 15.sp after a section title.
          isMobile ? SizedBox(height: 0.sp) : SizedBox(height: 10.sp),
          SizedBox(height: isTablet ? 0 : 0.02.h),

          // First Row/Column: First Name, Last Name, Relationship
          isMobile
              ? Column(
            children: [
              CustomTextField(
                label: S.of(context).firstName,
                hint: '-',
                controller: firstNameController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).lastName,
                hint: '-',
                controller: lastNameController,
                enabled: false,
              ),
             isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).relationship,
                hint: '-',
                controller: relationshipController,
                enabled: false,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: S.of(context).firstName,
                  hint: '-',
                  controller: firstNameController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).lastName,
                  hint: '-',
                  controller: lastNameController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).relationship,
                  hint: '-',
                  controller: relationshipController,
                  enabled: false,
                ),
              ),
            ],
          ),

          isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 15.sp),
          // Second Row/Column: Email, Mobile Phone, Language
          isMobile
              ? Column(
            children: [
              CustomTextField(
                label: S.of(context).email,
                hint: '-',
                controller: emailController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).phoneNumber,
                hint: '-',
                controller: mobilePhoneController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).language,
                hint: '-',
                controller: languageController,
                enabled: false,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: S.of(context).email,
                  hint: "-",
                  controller: emailController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).phoneNumber,
                  hint: '-',
                  controller: mobilePhoneController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).language,
                  hint: '-',
                  controller: languageController,
                  enabled: false,
                ),
              ),
            ],
          ),
          isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 15.sp),


          // Third Row/Column: Country, Province, City
          isMobile
              ? Column(
            children: [
              CustomTextField(
                label: S.of(context).country,
                hint: '-',
                controller: countryController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).province,
                hint: '-',
                controller: provinceController,
                enabled: false,
              ),
              isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
              CustomTextField(
                label: S.of(context).city,
                hint: '-',
                controller: cityController,
                enabled: false,
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: S.of(context).country,
                  hint: '-',
                  controller: countryController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).province,
                  hint: '-',
                  controller: provinceController,
                  enabled: false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: S.of(context).city,
                  hint: '-',
                  controller: cityController,
                  enabled: false,
                ),
              ),
            ],
          ),

          isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 15.sp),

          // Fourth Row: Street (full width on both mobile and desktop)
          CustomTextField(
            label: S.of(context).street,
            hint: '-',
            controller: streetController,
            enabled: false,
          ),
        ],
      ),
    );
  }
}