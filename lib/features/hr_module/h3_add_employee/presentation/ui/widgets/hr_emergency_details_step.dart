// ***************************** FILE INFO ***************************** //
// File Name: hr_emergency_details_step.dart
// Purpose: Renders and validates both required emergency-contact sections.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/helper/hr/input_formatter.dart';
import '../../../../../../core/helper/hr/validator.dart';

import '../../../../../../generated/l10n.dart';
import '../../../utils/add_employee_form_options.dart';
import '../../../utils/add_employee_step.dart';
import '../../../utils/employee_field_validation_localization.dart';
import '../../controller/add_employee_cubit.dart';
import 'add_employee_dropdown.dart';
import 'add_employee_intl_phone_field.dart';
import 'add_employee_read_only_scope.dart';
import 'add_employee_text_field.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Renders the two controlled emergency-contact forms for a new employee.
class HrEmergencyDetailsStep extends StatelessWidget {
  const HrEmergencyDetailsStep({
    super.key,
    this.isReadOnly = false,
    this.useForm = true,
    this.scrollable = true,
  });

  final bool isReadOnly;
  final bool useForm;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddEmployeeCubit>();
    final localization = S.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.firstEmergencyContact,
          style: StyleText.fontSize16Weight500,
        ),
        SizedBox(height: 16.h),
        _contactGrid(context, cubit, first: true),
        SizedBox(height: 28.h),
        Text(
          localization.secondEmergencyContact,
          style: StyleText.fontSize16Weight500,
        ),
        SizedBox(height: 16.h),
        _contactGrid(context, cubit, first: false),
      ],
    );
    final formContent = useForm
        ? Form(
            key: cubit.stepFormKeys[AddEmployeeStep.emergencyDetails.index],
            child: content,
          )
        : content;
    return AddEmployeeReadOnlyScope(
      isReadOnly: isReadOnly,
      child:
          scrollable ? SingleChildScrollView(child: formContent) : formContent,
    );
  }

  Widget _contactGrid(BuildContext context, AddEmployeeCubit cubit,
      {required bool first}) {
    final localization = S.of(context);
    final englishValidation =
        EmployeeFieldValidationLocalization.englishMessages();
    final arabicValidation =
        EmployeeFieldValidationLocalization.arabicMessages();
    final englishNameControllers = first
        ? [
            cubit.firstEmergencyFirstNameController,
            cubit.firstEmergencyLastNameController,
          ]
        : [
            cubit.secondEmergencyFirstNameController,
            cubit.secondEmergencyLastNameController,
          ];
    final arabicNameControllers = first
        ? [
            cubit.firstEmergencyFirstNameArabicController,
            cubit.firstEmergencyLastNameArabicController,
          ]
        : [
            cubit.secondEmergencyFirstNameArabicController,
            cubit.secondEmergencyLastNameArabicController,
          ];
    final detailControllers = first
        ? [
            cubit.firstEmergencyRelationshipController,
            cubit.firstEmergencyEmailController,
            cubit.firstEmergencyMobileController,
            cubit.firstEmergencyCountryController,
            cubit.firstEmergencyProvinceController,
            cubit.firstEmergencyCityController,
            cubit.firstEmergencyStreetController,
            cubit.firstEmergencyLanguageController
          ]
        : [
            cubit.secondEmergencyRelationshipController,
            cubit.secondEmergencyEmailController,
            cubit.secondEmergencyMobileController,
            cubit.secondEmergencyCountryController,
            cubit.secondEmergencyProvinceController,
            cubit.secondEmergencyCityController,
            cubit.secondEmergencyStreetController,
            cubit.secondEmergencyLanguageController
          ];
    return DynamicHeightGrid(
      widgets: [
        _nameField(
          controller: englishNameControllers[0],
          label: localization.employeeEnglishFirstName,
          hint: localization.employeeEnglishNameHint,
          localization: englishValidation,
          script: HrNameScript.english,
          textDirection: TextDirection.ltr,
          scriptFormatter: HrInputFormatter.englishName,
        ),
        _nameField(
          controller: englishNameControllers[1],
          label: localization.employeeEnglishLastName,
          hint: localization.employeeEnglishNameHint,
          localization: englishValidation,
          script: HrNameScript.english,
          textDirection: TextDirection.ltr,
          scriptFormatter: HrInputFormatter.englishName,
        ),
        _nameField(
          controller: arabicNameControllers[0],
          label: localization.employeeArabicFirstName,
          hint: localization.employeeArabicNameHint,
          localization: arabicValidation,
          script: HrNameScript.arabic,
          textDirection: TextDirection.rtl,
          scriptFormatter: HrInputFormatter.arabicName,
        ),
        _nameField(
          controller: arabicNameControllers[1],
          label: localization.employeeArabicLastName,
          hint: localization.employeeArabicNameHint,
          localization: arabicValidation,
          script: HrNameScript.arabic,
          textDirection: TextDirection.rtl,
          scriptFormatter: HrInputFormatter.arabicName,
        ),
        _relationshipDropdown(context, detailControllers[0]),
        AddEmployeeTextField(
            controller: detailControllers[1],
            label: localization.personalEmail,
            hint: localization.textHere,
            isRequired: false,
            validator: HrValidator.email(localization, required: false),
            keyboardType: TextInputType.emailAddress),
        AddEmployeeIntlPhoneField(
          numberController: first
              ? cubit.firstEmergencyMobileController
              : cubit.secondEmergencyMobileController,
          countryCodeController: first
              ? cubit.firstEmergencyCountryCodeController
              : cubit.secondEmergencyCountryCodeController,
          label: localization.mobilePhone,
          isRequired: false,
        ),
        AddEmployeeTextField(
            controller: detailControllers[3],
            label: localization.country,
            hint: localization.textHere,
            isRequired: false,
            validator: HrValidator.required(localization, required: false)),
        AddEmployeeTextField(
            controller: detailControllers[4],
            label: localization.province,
            hint: localization.textHere,
            isRequired: false,
            validator: HrValidator.required(localization, required: false)),
        AddEmployeeTextField(
            controller: detailControllers[5],
            label: localization.city,
            hint: localization.textHere,
            isRequired: false,
            validator: HrValidator.required(localization, required: false)),
        AddEmployeeTextField(
            controller: detailControllers[6],
            label: localization.street,
            hint: localization.textHere,
            isRequired: false,
            validator: HrValidator.required(localization, required: false)),
        _languageDropdown(context, detailControllers[7]),
      ],
      crossAxisCount: CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(context),
      horizontalSpacing: 16.sp,
      verticalSpacing: 20.sp,
    );
  }

  /// Method Name: [_nameField]
  ///
  /// Purpose: Builds an optional emergency name field with a fixed script and
  /// direction independent of the active application locale.
  ///
  /// Parameters:
  /// - [controller]: Controller owning the emergency name value.
  /// - [label]: Fixed-language field label.
  /// - [hint]: Fixed-language input hint.
  /// - [localization]: Source of localized validation messages.
  /// - [script]: Writing system accepted by validation.
  /// - [textDirection]: Direction matching the accepted writing system.
  /// - [scriptFormatter]: Formatter preventing other writing systems.
  ///
  /// Returns: A configured optional emergency name field.
  Widget _nameField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required S localization,
    required HrNameScript script,
    required TextDirection textDirection,
    required TextInputFormatter scriptFormatter,
  }) =>
      AddEmployeeTextField(
        controller: controller,
        label: label,
        hint: hint,
        isRequired: false,
        validator: HrValidator.name(
          localization,
          required: false,
          script: script,
        ),
        textDirection: textDirection,
        inputFormatters: [
          scriptFormatter,
          LengthLimitingTextInputFormatter(20),
        ],
      );

  Widget _relationshipDropdown(
      BuildContext context, TextEditingController controller) {
    final localization = S.of(context);
    return AddEmployeeDropdown<String>(
        value: controller.text.isEmpty ? null : controller.text,
        items: AddEmployeeStandardOptions.relationships
            .map((option) =>
                DropdownItem(value: option.value, label: option.title))
            .toList(),
        label: localization.relationship,
        hint: localization.select,
        isRequired: false,
        onChanged: (value) =>
            context.read<AddEmployeeCubit>().updateValue(controller, value),
        validator: null);
  }

  Widget _languageDropdown(
      BuildContext context, TextEditingController controller) {
    final localization = S.of(context);
    return AddEmployeeDropdown<String>(
        value: controller.text.isEmpty ? null : controller.text,
        items: LanguageOption.values
            .map((option) =>
                DropdownItem(value: option.value, label: option.title))
            .toList(),
        label: localization.language,
        hint: localization.select,
        isRequired: false,
        onChanged: (value) =>
            context.read<AddEmployeeCubit>().updateValue(controller, value),
        validator: null);
  }
}
