// ***************************** FILE INFO ***************************** //
// File Name: hr_address_details_step.dart
// Purpose: Renders validated address details for the add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/helper/hr/validator.dart';
import '../../../../../../generated/l10n.dart';
import '../../../utils/add_employee_step.dart';
import '../../controller/add_employee_cubit.dart';
import 'add_employee_read_only_scope.dart';
import 'add_employee_text_field.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';

/// Renders the required employee address details form.
class HrAddressDetailsStep extends StatelessWidget {
  const HrAddressDetailsStep({
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
        _field(
          cubit.countryController,
          localization.country,
          localization,
          maxLength: 25,
        ),
        _field(
          cubit.provinceController,
          localization.province,
          localization,
          maxLength: 25,
        ),
        _field(
          cubit.cityController,
          localization.city,
          localization,
          maxLength: 25,
        ),
        _field(
          cubit.streetController,
          localization.street,
          localization,
          maxLength: 50,
        ),
        AddEmployeeTextField(
            controller: cubit.postalCodeController,
            label: localization.postalCode,
            hint: localization.textHere,
            isRequired: true,
            validator: HrValidator.number(localization),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ]),
      ],
      crossAxisCount: CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(context),
      horizontalSpacing: 16.sp,
      verticalSpacing: 20.sp,
    );
    final formContent = useForm
        ? Form(
            key: cubit.stepFormKeys[AddEmployeeStep.addressDetails.index],
            child: content,
          )
        : content;
    return AddEmployeeReadOnlyScope(
      isReadOnly: isReadOnly,
      child:
          scrollable ? SingleChildScrollView(child: formContent) : formContent,
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    S localization, {
    required int maxLength,
  }) {
    return AddEmployeeTextField(
      controller: controller,
      label: label,
      hint: localization.textHere,
      isRequired: true,
      validator: HrValidator.required(localization),
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
    );
  }
}
