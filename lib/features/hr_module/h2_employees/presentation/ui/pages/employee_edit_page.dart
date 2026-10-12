// ***************************** FILE INFO ***************************** //
// File Name: employee_edit_page.dart
// Purpose: Hosts the reusable add-employee component in edit mode.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../../h3_add_employee/data/repository/employee_repository.dart';
import '../../../../h3_add_employee/presentation/controller/add_employee_cubit.dart';
import '../../../../h3_add_employee/presentation/controller/add_employee_state.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_address_details_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_certification_details_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_contact_details_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_emergency_details_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_identification_details_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_insurance_details_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_personal_information_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/hr_position_details_step.dart';
import '../../../../h3_add_employee/presentation/ui/widgets/add_employee_preview_section.dart';
import '../../../../h3_add_employee/utils/add_employee_step.dart';
import '../../../domain/entity/employee_details_view_data.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Renders one existing add-employee component as an editable section.
class EmployeeEditPage extends StatelessWidget {
  const EmployeeEditPage({
    required this.data,
    required this.section,
    super.key,
  });

  final EmployeeDetailsViewData data;
  final AddEmployeeStep section;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = AddEmployeeCubit(
          repository: EmployeeRepository(),
          hrModuleDataCubit: context.read<HrModuleDataCubit>(),
        );
        cubit.initializeForEdit(data);
        cubit.currentStepIndex = section.index;
        return cubit;
      },
      child: _EmployeeEditView(section: section),
    );
  }
}

class _EmployeeEditView extends StatelessWidget {
  const _EmployeeEditView({required this.section});

  final AddEmployeeStep section;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PaginationAppBar(
                screensTitles: [
                  localization.humanResources,
                  localization.employees,
                  section.title,
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: SingleChildScrollView(
                  child: AddEmployeePreviewSection(
                    title: section.title,
                    content: _sectionWidget(),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  customButton(
                    title: localization.discard,
                    color: AppColors.disabledGrey,
                    textStyle: StyleText.fontSize14Weight400,
                    function: () => Navigator.of(context).pop(),
                  ),
                  BlocBuilder<AddEmployeeCubit, AddEmployeeState>(
                    builder: (context, state) => customButton(
                      title: localization.saveChanges,
                      color: state.isDirty
                          ? AppColors.primary
                          : AppColors.disabledGrey,
                      textStyle: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.textButton,
                      ),
                      function: !state.isDirty ||
                              state.status is AddEmployeeFlowSubmitting
                          ? () {}
                          : () => _save(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionWidget() {
    switch (section) {
      case AddEmployeeStep.personalInformation:
        return const HrPersonalInformationStep(
            isReadOnly: false, useForm: true, scrollable: false);
      case AddEmployeeStep.contactDetails:
        return const HrContactDetailsStep(
            isReadOnly: false, useForm: true, scrollable: false);
      case AddEmployeeStep.addressDetails:
        return const HrAddressDetailsStep(
            isReadOnly: false, useForm: true, scrollable: false);
      case AddEmployeeStep.identificationDetails:
        return const HrIdentificationDetailsStep(
            isReadOnly: false, useForm: true, scrollable: false);
      case AddEmployeeStep.positionDetails:
        return const HrPositionDetailsStep(
            isReadOnly: false, useForm: true, scrollable: false);
      case AddEmployeeStep.certificationDetails:
        return const HrCertificationDetailsStep(
            isReadOnly: false, useForm: true, scrollable: false);
      case AddEmployeeStep.insuranceDetails:
        return const HrInsuranceDetailsStep(isReadOnly: false, useForm: true);
      case AddEmployeeStep.emergencyDetails:
        return const HrEmergencyDetailsStep(
            isReadOnly: false, useForm: true, scrollable: false);
    }
  }

  Future<void> _save(BuildContext context) async {
    final localization = S.of(context);
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
      confirmTitle: localization.confirm,
      confirmSubtitle: localization.confirmSaveEmployeeChanges,
      confirmYesText: localization.yes,
      confirmNoText: localization.no,
      onConfirm: () async {
        unawaited(showLoadingIndicator());
        final cubit = context.read<AddEmployeeCubit>();
        final failure = await cubit.saveEmployeeUpdate(section);
        hideLoadingIndicator();
        if (!context.mounted) return false;

        if (failure != null) {
          final message = failure.message.isEmpty
              ? localization.completeRequiredFields
              : failure.message;
          await CustomDialogManager.showMessage(
            context: context,
            lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
            title: localization.error,
            subtitle: message,
          );
          return false;
        }

        await context.read<HrModuleDataCubit>().refreshEmployees();
        return true;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/successful.json',
      successTitle: localization.successful,
      successSubtitle: localization.employeeDetailsUpdatedSuccessfully,
      onSuccessComplete: () {
        if (context.mounted) Navigator.of(context).pop(true);
      },
    );
  }
}
