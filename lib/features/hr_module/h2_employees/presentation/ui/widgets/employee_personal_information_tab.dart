// ***************************** FILE INFO ***************************** //
// File Name: employee_personal_information_tab.dart
// Purpose: Displays all read-only personal employee detail sections.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../domain/entity/employee_details_view_data.dart';
import '../../../utils/employee_details_display_values.dart';
import 'employee_details_field.dart';
import 'employee_details_fields_grid.dart';
import 'employee_details_section.dart';
import 'employee_emergency_contact_card.dart';

/// Builds the personal-information detail content from loaded profile data.
class EmployeePersonalInformationTab extends StatelessWidget {
  const EmployeePersonalInformationTab({required this.data, super.key});

  final EmployeeDetailsViewData data;

  /// Method Name: [_latest]
  ///
  /// Purpose: Resolves the latest usable value from a persisted history.
  ///
  /// Parameters:
  /// - [history]: Historical values in chronological storage order.
  ///
  /// Returns: The latest non-empty value or null when unavailable.
  String? _latest(List<String>? history) {
    if (history == null) return null;
    for (final value in history.reversed) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// Method Name: [_phone]
  ///
  /// Purpose: Joins an optional dialing code and national phone number for display.
  ///
  /// Parameters:
  /// - [countryCode]: Stored dialing code.
  /// - [number]: Stored national number.
  ///
  /// Returns: A display phone string or null when no values are available.
  String? _phone(String? countryCode, String? number) {
    final parts = [countryCode?.trim() ?? '', number?.trim() ?? '']
        .where((value) => value.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Method Name: [_department]
  ///
  /// Purpose: Resolves the selected employee's localized department name.
  ///
  /// Parameters:
  /// - [isEnglish]: Whether an English department label is required.
  ///
  /// Returns: A department name or null when no department is assigned.
  String? _department(bool isEnglish) {
    final id = data.employee.departmentId?.trim() ?? '';
    if (id.isEmpty) return null;
    final value =
        Get.find<MainCoreDepartmentCubit>().getDepartmentName(id, isEnglish);
    return value.trim().isEmpty ? null : value;
  }

  /// Method Name: [_languages]
  ///
  /// Purpose: Splits persisted language text into compact display chips.
  ///
  /// Returns: A localized unavailable label or wrapped language chips.
  Widget _languages(BuildContext context) {
    final values = (data.employee.language ?? '')
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (values.isEmpty) {
      return const Text(EmployeeDetailsDisplayValues.unavailable);
    }
    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: values
          .map(
            (value) => Chip(
              label: Text(FormatHelper.capitalize(value)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppColors.background,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.symmetric(horizontal: 6.w),
              side: BorderSide.none,
            ),
          )
          .toList(),
    );
  }

  /// Method Name: [_fullEmergencyName]
  ///
  /// Purpose: Builds a locale-appropriate emergency-contact display name.
  ///
  /// Parameters:
  /// - [first]: Stored English first name.
  /// - [last]: Stored English last name.
  /// - [arabicFirst]: Stored Arabic first name.
  /// - [arabicLast]: Stored Arabic last name.
  /// - [isEnglish]: Whether English values should be preferred.
  ///
  /// Returns: A composed contact name or null when unavailable.
  String? _fullEmergencyName({
    required String? first,
    required String? last,
    required String? arabicFirst,
    required String? arabicLast,
    required bool isEnglish,
  }) {
    final parts = (isEnglish ? [first, last] : [arabicFirst, arabicLast])
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    final fallback = [first, last]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return fallback.isEmpty ? null : fallback.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    final employee = data.employee;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final contact = data.contactDetails;
    final certification = data.certificationDetails;
    final insurance = data.insuranceDetails;
    final emergency = data.emergencyDetails;
    final mobile =
        _phone(employee.mobilePhone?.countryCode, employee.mobilePhone?.number);
    final home = _phone(_latest(contact?.homeCountryCode), employee.homePhone);
    final office =
        _phone(_latest(contact?.officeCountryCode), employee.officePhone);
    final workingHours = [
      employee.startTime,
      employee.endTime,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' - ');
    final salary = [
      employee.salary,
      employee.currency,
    ].whereType<String>().where((value) => value.isNotEmpty).join(' ');

    return Column(
      children: [
        EmployeeDetailsSection(
          title: l.personalInformation,
          child: EmployeeDetailsFieldsGrid(
            children: [
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeName,
                  label: l.firstName,
                  value: employee.firstNameForLanguage(isEnglish: isEnglish)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeName,
                  label: l.middleName,
                  value: employee.middleNameForLanguage(isEnglish: isEnglish)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeName,
                  label: l.lastName,
                  value: employee.lastNameForLanguage(isEnglish: isEnglish)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeGender,
                  label: l.gender,
                  value: employee.gender),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeBirthday,
                  label: l.birthday,
                  value: employee.birthDay),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeNationality,
                  label: l.nationality,
                  value: employee.nationality),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeMaritalStatus,
                  label: l.maritalStatus,
                  value: employee.maritalStatus),
              EmployeeDetailsField(
                iconAsset: HRAssets.employeeLanguage,
                label: l.language,
                valueWidget: _languages(context),
              ),
            ],
          ),
        ),
        EmployeeDetailsSection(
          title: l.contactDetails,
          child: EmployeeDetailsFieldsGrid(
            children: [
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeePhone,
                  label: l.phoneNumber,
                  value: mobile),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeEmail,
                  label: l.personalEmail,
                  value: _latest(contact?.personalEmail)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeOfficePhone,
                  label: l.officeNumber,
                  value: office),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeHome,
                  label: l.homeNumber,
                  value: home),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeBusinessEmail,
                  label: l.businessEmail,
                  value: employee.email),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeExtension,
                  label: l.extension,
                  value: employee.extension),
            ],
          ),
        ),
        EmployeeDetailsSection(
          title: l.addressDetails,
          child: EmployeeDetailsFieldsGrid(
            children: [
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCountry,
                  label: l.country,
                  value: employee.country),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeProvince,
                  label: l.province,
                  value: employee.province),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCity,
                  label: l.city,
                  value: employee.city),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeStreet,
                  label: l.street,
                  value: employee.street),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeePostalCode,
                  label: l.postalCode,
                  value: employee.postalCode),
            ],
          ),
        ),
        EmployeeDetailsSection(
          title: l.identificationDetails,
          child: EmployeeDetailsFieldsGrid(
            children: [
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeNationalId,
                  label: l.nationalId,
                  value: employee.nationalId),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeePassport,
                  label: l.passport,
                  value: employee.passport),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeDrivingLicense,
                  label: l.drivingLicenseId,
                  value: employee.drivingLicenseId),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeExpiration,
                  label: l.nationalIdExpiration,
                  value: employee.nationalIdExpirationDate),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeExpiration,
                  label: l.passportExpiration,
                  value: employee.passportExpirationDate),
              EmployeeDetailsField(
                iconAsset: HRAssets.employeeCarPlate,
                label: l.carPlate,
                value: employee.carPlates
                    ?.whereType<String>()
                    .map((value) => value.trim())
                    .where((value) => value.isNotEmpty)
                    .join(', '),
              ),
            ],
          ),
        ),
        EmployeeDetailsSection(
          title: l.positionDetails,
          child: EmployeeDetailsFieldsGrid(
            children: [
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeJobTitle,
                  label: l.jobTitle,
                  value: employee.jobTitleForLanguage(isEnglish: isEnglish)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeDepartment,
                  label: l.department,
                  value: _department(isEnglish)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeManager,
                  label: l.manager,
                  value: employee.supervisor),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeJobType,
                  label: l.jobType,
                  value: employee.jobType),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeWorkArrangement,
                  label: l.workArrangement,
                  value: employee.workArrangement),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeRemoteStatus,
                  label: l.remoteStatus,
                  value: employee.remoteStatus),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeWorkingHours,
                  label: l.workingHours,
                  value: workingHours),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeStartDate,
                  label: l.startDate,
                  value: employee.startDate),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeSalary,
                  label: l.salary,
                  value: salary),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeDaysOff,
                  label: l.daysOff,
                  value: employee.daysOff),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeJobLocation,
                  label: l.jobLocation,
                  value: employee.workLocation),
            ],
          ),
        ),
        EmployeeDetailsSection(
          title: l.certificationDetails,
          child: EmployeeDetailsFieldsGrid(
            children: [
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCertification,
                  label: l.institutionName,
                  value: _latest(certification?.institutionName)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCertification,
                  label: l.degreeOrCertification,
                  value: _latest(certification?.degree)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCertification,
                  label: l.fieldOfStudy,
                  value: _latest(certification?.fieldOfStudy)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeStartDate,
                  label: l.startDate,
                  value: _latest(certification?.startDate)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeExpiration,
                  label: l.endDate,
                  value: _latest(certification?.endDate)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCertification,
                  label: l.gradeOrScore,
                  value: _latest(certification?.gradeOrScore)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeNationalId,
                  label: l.certificateId,
                  value: _latest(certification?.certificateId)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCertification,
                  label: l.issuingAuthority,
                  value: _latest(certification?.issuingAuthority)),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeEmail,
                  label: l.documentUrl,
                  value: _latest(certification?.certificationDocumentUrl),
                  allowWrap: true),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeCertification,
                  label: l.notes,
                  value: _latest(certification?.notes),
                  allowWrap: true),
            ],
          ),
        ),
        EmployeeDetailsSection(
          title: l.healthInsurance,
          child: EmployeeDetailsFieldsGrid(
            children: [
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeHealthInsurance,
                  label: l.insuranceName,
                  value: employee.insuranceName),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeeHealthInsurance,
                  label: l.insurancePolicyNumber,
                  value: employee.insurancePolicyNumber),
              EmployeeDetailsField(
                  iconAsset: HRAssets.employeePhone,
                  label: l.insuranceProviderContact,
                  value: _latest(insurance?.providerContact)),
            ],
          ),
        ),
        EmployeeDetailsSection(
          title: l.emergencyDetails,
          child: _emergencyContacts(context, isEnglish, emergency),
        ),
      ],
    );
  }

  /// Method Name: [_emergencyContacts]
  ///
  /// Purpose: Builds responsive cards for the employee's two emergency contacts.
  ///
  /// Parameters:
  /// - [context]: Build context used for localized labels.
  /// - [isEnglish]: Whether English contact names are preferred.
  /// - [details]: Optional supplemental emergency-contact data.
  ///
  /// Returns: A responsive contact-card layout.
  Widget _emergencyContacts(
    BuildContext context,
    bool isEnglish,
    dynamic details,
  ) {
    final employee = data.employee;
    final first = EmployeeEmergencyContactCard(
      name: _fullEmergencyName(
        first: employee.firstContactFirstName,
        last: employee.firstContactLastName,
        arabicFirst: _latest(details?.firstContactFirstNameArabic),
        arabicLast: _latest(details?.firstContactLastNameArabic),
        isEnglish: isEnglish,
      ),
      relationship: employee.firstContactRelationship,
      email: employee.firstContactEmail,
      phone: _phone(_latest(details?.firstContactCountryCode),
          employee.firstContactPhone),
      country: employee.firstContactCountry,
      province: employee.firstContactProvince,
      city: employee.firstContactCity,
      street: employee.firstContactStreet,
      language: employee.firstContactLanguage,
    );
    final second = EmployeeEmergencyContactCard(
      name: _fullEmergencyName(
        first: employee.secondContactFirstName,
        last: employee.secondContactLastName,
        arabicFirst: _latest(details?.secondContactFirstNameArabic),
        arabicLast: _latest(details?.secondContactLastNameArabic),
        isEnglish: isEnglish,
      ),
      relationship: employee.secondContactRelationship,
      email: employee.secondContactEmail,
      phone: _phone(_latest(details?.secondContactCountryCode),
          employee.secondContactPhone),
      country: employee.secondContactCountry,
      province: employee.secondContactProvince,
      city: employee.secondContactCity,
      street: employee.secondContactStreet,
      language: employee.secondContactLanguage,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 700.w
            ? (constraints.maxWidth - 18.w) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 18.w,
          runSpacing: 14.h,
          children: [
            SizedBox(width: width, child: first),
            SizedBox(width: width, child: second),
          ],
        );
      },
    );
  }
}
