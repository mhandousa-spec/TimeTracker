// ***************************** FILE INFO ***************************** //
// File Name: hr_insurance_details_step.dart
// Purpose: Renders and validates the insurance-details add-employee step.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../generated/l10n.dart';
import '../../../utils/add_employee_step.dart';
import '../../controller/add_employee_cubit.dart';
import 'add_employee_read_only_scope.dart';
import 'add_employee_text_field.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';

/// Renders the controlled insurance form for a new employee.
class HrInsuranceDetailsStep extends StatelessWidget {
  const HrInsuranceDetailsStep({
    super.key,
    this.isReadOnly = false,
    this.useForm = true,
  });

  final bool isReadOnly;
  final bool useForm;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final cubit = context.read<AddEmployeeCubit>();
    final content = DynamicHeightGrid(
      widgets: [
        AddEmployeeTextField(
            controller: cubit.insuranceNameController,
            label: localization.insuranceName,
            hint: localization.textHere,
            isRequired: false),
        AddEmployeeTextField(
            controller: cubit.insurancePolicyNumberController,
            label: localization.insurancePolicyNumber,
            hint: localization.textHere,
            isRequired: false),
        AddEmployeeTextField(
            controller: cubit.insuranceProviderContactController,
            label: localization.insuranceProviderContact,
            hint: localization.textHere,
            isRequired: false),
      ],
      crossAxisCount: CrossAxisCountHelperResponsive
          .getCrossAxisCountForDefaultTabletResponsive(context),
      horizontalSpacing: 16.sp,
      verticalSpacing: 20.sp,
    );
    return AddEmployeeReadOnlyScope(
      isReadOnly: isReadOnly,
      child: useForm
          ? Form(
              key: cubit.stepFormKeys[AddEmployeeStep.insuranceDetails.index],
              child: content,
            )
          : content,
    );
  }
}
