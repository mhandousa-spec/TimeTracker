// ***************************** FILE INFO ***************************** //
// File Name: hr_contact_details_step.dart
// Purpose: Renders validated contact details for the add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/helper/hr/validator.dart';
import '../../../../../../generated/l10n.dart';
import '../../../utils/add_employee_step.dart';
import '../../controller/add_employee_cubit.dart';
import 'add_employee_intl_phone_field.dart';
import 'add_employee_read_only_scope.dart';
import 'add_employee_text_field.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';

/// Renders the required employee contact details form.
class HrContactDetailsStep extends StatelessWidget {
  const HrContactDetailsStep({
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
    final localization = S.of(context);
    final cubit = context.read<AddEmployeeCubit>();
    final content = DynamicHeightGrid(
      widgets: [
        _phoneField(
          numberController: cubit.mobileNumberController,
          countryCodeController: cubit.mobileCountryCodeController,
          label: localization.mobilePhone,
          isRequired: true,
        ),
        _phoneField(
          numberController: cubit.homeNumberController,
          countryCodeController: cubit.homeCountryCodeController,
          label: localization.homeNumber,
          isRequired: false,
        ),
        AddEmployeeTextField(
            controller: cubit.emailController,
            label: localization.personalEmail,
            hint: localization.textHere,
            isRequired: true,
            readOnly: cubit.isEditMode,
            validator: HrValidator.email(localization),
            keyboardType: TextInputType.emailAddress),
        _phoneField(
          numberController: cubit.officeNumberController,
          countryCodeController: cubit.officeCountryCodeController,
          label: localization.officeNumber,
          isRequired: false,
        ),
        _numberField(
            cubit.extensionController, localization.extension, localization,
            isRequired: false),
        AddEmployeeTextField(
            controller: cubit.businessEmailController,
            label: localization.businessEmail,
            hint: localization.textHere,
            isRequired: true,
            validator: HrValidator.email(localization),
            keyboardType: TextInputType.emailAddress),
      ],
      crossAxisCount: CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(context),
      horizontalSpacing: 16.sp,
      verticalSpacing: 20.sp,
    );
    final formContent = useForm
        ? Form(
            key: cubit.stepFormKeys[AddEmployeeStep.contactDetails.index],
            child: content,
          )
        : content;
    return AddEmployeeReadOnlyScope(
      isReadOnly: isReadOnly,
      child:
          scrollable ? SingleChildScrollView(child: formContent) : formContent,
    );
  }

  Widget _phoneField({
    required TextEditingController numberController,
    required TextEditingController countryCodeController,
    required String label,
    required bool isRequired,
  }) {
    return AddEmployeeIntlPhoneField(
      numberController: numberController,
      countryCodeController: countryCodeController,
      label: label,
      isRequired: isRequired,
    );
  }

  /// Method Name: [_numberField]
  ///
  /// Purpose: Builds a numeric contact field with configurable requiredness.
  ///
  /// Parameters:
  /// - [controller]: Controller that stores the numeric value.
  /// - [label]: Localized field label.
  /// - [localization]: Source of localized validation messages.
  /// - [isRequired]: Whether an empty value is invalid.
  ///
  /// Returns: A configured numeric contact field.
  Widget _numberField(
    TextEditingController controller,
    String label,
    S localization, {
    bool isRequired = true,
  }) {
    return AddEmployeeTextField(
        controller: controller,
        label: label,
        hint: localization.textHere,
        isRequired: isRequired,
        validator: HrValidator.number(localization, required: isRequired),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10)
        ]);
  }
}
