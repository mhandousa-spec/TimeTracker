// ***************************** FILE INFO ***************************** //
// File Name: hr_personal_information_step.dart
// Purpose: Renders validated personal details for the add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/31-custom_multi_select_dropdown.dart';
import '../../../../../../core/custom/46-custom_image_picker.dart';
import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/helper/hr/input_formatter.dart';
import '../../../../../../core/helper/hr/validator.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../../core/helper/main_helper/countries.dart';
import '../../../utils/add_employee_gender_option.dart';
import '../../../utils/add_employee_language_option.dart';
import '../../../utils/add_employee_marital_status_option.dart';
import '../../../utils/add_employee_step.dart';
import '../../../utils/employee_field_validation_localization.dart';
import '../../controller/add_employee_cubit.dart';
import '../../controller/add_employee_state.dart';
import 'add_employee_date_field.dart';
import 'add_employee_dropdown.dart';
import 'add_employee_multi_select_dropdown.dart';
import 'add_employee_read_only_scope.dart';
import 'add_employee_text_field.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';

/// Renders the employee personal-information form with an optional image.
class HrPersonalInformationStep extends StatelessWidget {
  const HrPersonalInformationStep({
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
    return BlocBuilder<AddEmployeeCubit, AddEmployeeState>(
      builder: (context, state) {
        final cubit = context.read<AddEmployeeCubit>();
        final localization = S.of(context);
        final englishValidation =
            EmployeeFieldValidationLocalization.englishMessages();
        final arabicValidation =
            EmployeeFieldValidationLocalization.arabicMessages();
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IgnorePointer(
              ignoring: isReadOnly,
              child: CustomImagePicker(
                key: ValueKey<String?>(state.profileImage?.path),
                imageFile: state.profileImage,
                placeholderSvg: AppAssets.defaultIcon,
                onImagePicked: cubit.updateProfileImage,
              ),
            ),
            SizedBox(height: 28.h),
            DynamicHeightGrid(
              widgets: [
                _nameField(
                  controller: cubit.firstNameController,
                  label: localization.employeeEnglishFirstName,
                  hint: localization.employeeEnglishNameHint,
                  localization: englishValidation,
                  script: HrNameScript.english,
                  textDirection: TextDirection.ltr,
                  scriptFormatter: HrInputFormatter.englishName,
                ),
                _nameField(
                  controller: cubit.middleNameController,
                  label: localization.employeeEnglishMiddleName,
                  hint: localization.employeeEnglishNameHint,
                  localization: englishValidation,
                  script: HrNameScript.english,
                  textDirection: TextDirection.ltr,
                  scriptFormatter: HrInputFormatter.englishName,
                ),
                _nameField(
                  controller: cubit.lastNameController,
                  label: localization.employeeEnglishLastName,
                  hint: localization.employeeEnglishNameHint,
                  localization: englishValidation,
                  script: HrNameScript.english,
                  textDirection: TextDirection.ltr,
                  scriptFormatter: HrInputFormatter.englishName,
                ),
                _nameField(
                  controller: cubit.firstNameArabicController,
                  label: localization.employeeArabicFirstName,
                  hint: localization.employeeArabicNameHint,
                  localization: arabicValidation,
                  script: HrNameScript.arabic,
                  textDirection: TextDirection.rtl,
                  scriptFormatter: HrInputFormatter.arabicName,
                ),
                _nameField(
                  controller: cubit.middleNameArabicController,
                  label: localization.employeeArabicMiddleName,
                  hint: localization.employeeArabicNameHint,
                  localization: arabicValidation,
                  script: HrNameScript.arabic,
                  textDirection: TextDirection.rtl,
                  scriptFormatter: HrInputFormatter.arabicName,
                ),
                _nameField(
                  controller: cubit.lastNameArabicController,
                  label: localization.employeeArabicLastName,
                  hint: localization.employeeArabicNameHint,
                  localization: arabicValidation,
                  script: HrNameScript.arabic,
                  textDirection: TextDirection.rtl,
                  scriptFormatter: HrInputFormatter.arabicName,
                ),
                _dropdown(
                    context,
                    cubit.genderController,
                    localization.gender,
                    GenderOption.values
                        .map((option) => DropdownItem(
                            value: option.value, label: option.title))
                        .toList(),
                    isRequired: true),
                AddEmployeeDateField(
                    value: DateTime.tryParse(cubit.birthDayController.text),
                    label: localization.birthday,
                    hint: localization.selectDate,
                    isRequired: false,
                    lastDate: DateTime(2010, 12, 31),
                    onChanged: (date) => cubit.updateBirthday(
                        date.toIso8601String().split('T').first),
                    validator: null),
                _dropdown(
                    context,
                    cubit.maritalStatusController,
                    localization.maritalStatus,
                    MaritalStatusOption.values
                        .map((option) => DropdownItem(
                            value: option.value, label: option.title))
                        .toList()),
                _dropdown(
                    context,
                    cubit.nationalityController,
                    localization.nationality,
                    countries
                        .map((country) => DropdownItem(
                            value: country.code,
                            label: country.localizedName(
                                Localizations.localeOf(context).languageCode)))
                        .toList()),
                AddEmployeeMultiSelectDropdown<String>(
                    values: state.selectedLanguages,
                    items: LanguageOption.values
                        .map((option) => MultiSelectDropdownItem(
                            value: option.value, label: option.title))
                        .toList(),
                    label: localization.language,
                    hint: localization.select,
                    isRequired: false,
                    onChanged: cubit.updateLanguages,
                    validator: (_) => null),
              ],
              crossAxisCount: CrossAxisCountHelperResponsive
                  .getCrossAxisCountForDefaultTabletResponsive(context),
              horizontalSpacing: 16.sp,
              verticalSpacing: 20.sp,
            ),
          ],
        );
        final formContent = useForm
            ? Form(
                key: cubit
                    .stepFormKeys[AddEmployeeStep.personalInformation.index],
                child: content,
              )
            : content;
        return AddEmployeeReadOnlyScope(
          isReadOnly: isReadOnly,
          child: scrollable
              ? SingleChildScrollView(child: formContent)
              : formContent,
        );
      },
    );
  }

  /// Method Name: [_nameField]
  ///
  /// Purpose: Builds a required name field locked to its designated script.
  ///
  /// Parameters:
  /// - [controller]: Controller owning the employee name value.
  /// - [label]: Fixed-language field label.
  /// - [hint]: Fixed-language input hint.
  /// - [localization]: Source of localized validation messages.
  /// - [script]: Writing system accepted by validation.
  /// - [textDirection]: Direction matching the accepted writing system.
  /// - [scriptFormatter]: Formatter preventing other writing systems.
  ///
  /// Returns: A configured employee name field.
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
        isRequired: true,
        validator: HrValidator.name(localization, script: script),
        textDirection: textDirection,
        inputFormatters: [
          scriptFormatter,
          LengthLimitingTextInputFormatter(20),
        ],
      );

  /// Method Name: [_dropdown]
  ///
  /// Purpose: Builds a localized personal-information dropdown with optional
  /// required selection validation.
  ///
  /// Parameters:
  /// - [context]: Context used to resolve localization and the flow Cubit.
  /// - [controller]: Controller that stores the selected stable value.
  /// - [label]: Localized field label.
  /// - [items]: Available localized dropdown options.
  /// - [isRequired]: Whether a selection is required before progressing.
  ///
  /// Returns: A configured validated employee dropdown.
  Widget _dropdown(
    BuildContext context,
    TextEditingController controller,
    String label,
    List<DropdownItem<String>> items, {
    bool isRequired = false,
  }) {
    final localization = S.of(context);
    return AddEmployeeDropdown<String>(
        value: controller.text.isEmpty ? null : controller.text,
        items: items,
        label: label,
        hint: localization.select,
        isRequired: isRequired,
        onChanged: (value) =>
            context.read<AddEmployeeCubit>().updateValue(controller, value),
        validator: isRequired
            ? (value) => HrValidator.requiredSelection(value, localization)
            : null);
  }
}
