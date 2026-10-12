// ***************************** FILE INFO ***************************** //
// File Name: hr_identification_details_step.dart
// Purpose: Renders validated identification details and optional documents.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/helper/hr/validator.dart';
import '../../../../../../generated/l10n.dart';
import '../../../utils/add_employee_document_type.dart';
import '../../../utils/add_employee_step.dart';
import '../../controller/add_employee_cubit.dart';
import '../../controller/add_employee_state.dart';
import 'add_employee_date_field.dart';
import 'add_employee_read_only_scope.dart';
import 'add_employee_text_field.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';
import '../../../../main_controller/presentation/ui/widgets/hr_image_upload_field.dart';

/// Renders the employee identification form with optional document uploads.
class HrIdentificationDetailsStep extends StatelessWidget {
  const HrIdentificationDetailsStep({
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
      builder: (context, _) {
        final localization = S.of(context);
        final cubit = context.read<AddEmployeeCubit>();
        final content = Column(
          children: [
            DynamicHeightGrid(
              widgets: [
                _field(
                  cubit.nationalIdController,
                  localization.nationalId,
                  localization,
                  maxLength: 50,
                ),
                AddEmployeeDateField(
                    value: DateTime.tryParse(
                        cubit.nationalIdExpirationDateController.text),
                    label: localization.nationalIdExpiration,
                    hint: localization.selectDate,
                    isRequired: true,
                    onChanged: (date) =>
                        cubit.updateNationalIdExpirationDate(_formatDate(date)),
                    validator: (value) =>
                        HrValidator.requiredSelection(value, localization)),
                _field(
                  cubit.passportController,
                  localization.passport,
                  localization,
                  isRequired: false,
                ),
                AddEmployeeDateField(
                    isRequired: false,
                    value: DateTime.tryParse(
                        cubit.passportExpirationDateController.text),
                    label: localization.passportExpiration,
                    hint: localization.selectDate,
                    onChanged: (date) =>
                        cubit.updatePassportExpirationDate(_formatDate(date)),
                    validator: null),
                _field(
                  cubit.drivingLicenseIdController,
                  localization.drivingLicenseId,
                  localization,
                  isRequired: false,
                ),
                _field(
                  cubit.carPlatesController,
                  localization.carPlate,
                  localization,
                  isRequired: false,
                ),
              ],
              crossAxisCount: CrossAxisCountHelperResponsive
                  .getCrossAxisCountForDefaultTabletResponsive(context),
              horizontalSpacing: 16.sp,
              verticalSpacing: 20.sp,
            ),
            SizedBox(height: 20.h),
            DynamicHeightGrid(
              widgets: [
                HrImageUploadField(
                    label: localization.uploadPassport,
                    file: cubit.passportDocument,
                    isReadOnly: isReadOnly,
                    onChanged: (file) => cubit.updateImageDocument(
                        AddEmployeeDocumentType.passport, file)),
                HrImageUploadField(
                    label: localization.uploadNationalIdFront,
                    file: cubit.nationalIdFrontDocument,
                    isReadOnly: isReadOnly,
                    isRequired: true,
                    onChanged: (file) => cubit.updateImageDocument(
                        AddEmployeeDocumentType.nationalIdFront, file)),
                HrImageUploadField(
                    label: localization.uploadNationalIdBack,
                    file: cubit.nationalIdBackDocument,
                    isReadOnly: isReadOnly,
                    isRequired: true,
                    onChanged: (file) => cubit.updateImageDocument(
                        AddEmployeeDocumentType.nationalIdBack, file)),
                HrImageUploadField(
                    label: localization.uploadDrivingLicenseId,
                    file: cubit.drivingLicenseDocument,
                    isReadOnly: isReadOnly,
                    onChanged: (file) => cubit.updateImageDocument(
                        AddEmployeeDocumentType.drivingLicense, file)),
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
                    .stepFormKeys[AddEmployeeStep.identificationDetails.index],
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

  Widget _field(
    TextEditingController controller,
    String label,
    S localization, {
    bool isRequired = true,
    int? maxLength,
  }) =>
      AddEmployeeTextField(
        controller: controller,
        label: label,
        hint: localization.textHere,
        isRequired: isRequired,
        validator: HrValidator.required(
          localization,
          required: isRequired,
        ),
        inputFormatters: maxLength == null
            ? null
            : [LengthLimitingTextInputFormatter(maxLength)],
      );

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
}
