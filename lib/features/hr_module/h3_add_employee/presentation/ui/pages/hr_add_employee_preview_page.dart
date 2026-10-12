// ***************************** FILE INFO ***************************** //
// File Name: hr_add_employee_preview_page.dart
// Purpose: Displays the completed add-employee form in a read-only preview.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/custom/57-custom_dialog_manager.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../../../main_controller/presentation/ui/widgets/hr_progress_stepper.dart';
import '../../controller/add_employee_cubit.dart';
import '../../controller/add_employee_state.dart';
import '../../../utils/add_employee_step.dart';
import '../../../utils/employee_creation_failure.dart';
import '../widgets/add_employee_preview_section.dart';
import '../widgets/hr_address_details_step.dart';
import '../widgets/hr_certification_details_step.dart';
import '../widgets/hr_contact_details_step.dart';
import '../widgets/hr_emergency_details_step.dart';
import '../widgets/hr_identification_details_step.dart';
import '../widgets/hr_insurance_details_step.dart';
import '../widgets/hr_personal_information_step.dart';
import '../widgets/hr_position_details_step.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays an editable review of every completed add-employee step.
class HrAddEmployeePreviewPage extends StatelessWidget {
  const HrAddEmployeePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return BlocConsumer<AddEmployeeCubit, AddEmployeeState>(
      listener: _handleState,
      builder: (context, state) => Scaffold(
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
                    localization.addingNewEmployee,
                  ],
                ),
                HrProgressStepper(
                  items:
                      AddEmployeeStep.values.map((step) => step.title).toList(),
                  currentItem: AddEmployeeStep.values.length - 1,
                  progressAmount: 1,
                  stepProgressAmounts: AddEmployeeStep.values
                      .map(context.read<AddEmployeeCubit>().getStepProgress)
                      .toList(),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.personalInformation.title,
                          content: const HrPersonalInformationStep(
                            useForm: false,
                            scrollable: false,
                          ),
                        ),
                        _space,
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.contactDetails.title,
                          content: const HrContactDetailsStep(
                            useForm: false,
                            scrollable: false,
                          ),
                        ),
                        _space,
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.addressDetails.title,
                          content: const HrAddressDetailsStep(
                            useForm: false,
                            scrollable: false,
                          ),
                        ),
                        _space,
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.identificationDetails.title,
                          content: const HrIdentificationDetailsStep(
                            useForm: false,
                            scrollable: false,
                          ),
                        ),
                        _space,
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.positionDetails.title,
                          content: const HrPositionDetailsStep(
                            useForm: false,
                            scrollable: false,
                          ),
                        ),
                        _space,
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.certificationDetails.title,
                          content: const HrCertificationDetailsStep(
                            useForm: false,
                            scrollable: false,
                          ),
                        ),
                        _space,
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.insuranceDetails.title,
                          content: const HrInsuranceDetailsStep(
                            useForm: false,
                          ),
                        ),
                        _space,
                        AddEmployeePreviewSection(
                          title: AddEmployeeStep.emergencyDetails.title,
                          content: const HrEmergencyDetailsStep(
                            useForm: false,
                            scrollable: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                EmployeePreviewActions(
                  state: state,
                  onBack: () => Navigator.of(context).pop(),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _space => SizedBox(height: 20.h);

  /// Method Name: [_handleState]
  ///
  /// Purpose: Synchronizes the shared loader and terminal feedback dialogs.
  ///
  /// Parameters:
  /// - [context]: Preview context used for dialogs and navigation.
  /// - [state]: Latest add-employee flow state.
  ///
  /// Returns: Updates presentation feedback for the emitted state.
  void _handleState(BuildContext context, AddEmployeeState state) {
    if (state.status is AddEmployeeFlowSubmitting) {
      unawaited(showLoadingIndicator());
      return;
    }
    if (state.status is AddEmployeeFlowSuccess) {
      hideLoadingIndicator();
      unawaited(_showSuccessAndClose(context));
      return;
    }
    if (state.status is AddEmployeeFlowFailure && state.failure != null) {
      hideLoadingIndicator();
      unawaited(_showFailure(context, state.failure!, state.createdEmployeeId));
      return;
    }
    if (state.status is AddEmployeeFlowEditing &&
        state.currentStep != AddEmployeeStep.emergencyDetails) {
      Navigator.of(context).pop();
    }
  }

  /// Method Name: [_showSuccessAndClose]
  ///
  /// Purpose: Shows creation confirmation before closing both flow pages.
  ///
  /// Parameters:
  /// - [context]: Preview context used for feedback and navigation.
  ///
  /// Returns: Completes after the success dialog and navigation finish.
  Future<void> _showSuccessAndClose(BuildContext context) async {
    final localization = S.of(context);
    await CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: localization.employeeCreatedSuccessfully,
      subtitle: localization.employeeCreatedSuccessfullyDescription,
    );
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pop();
  }

  /// Method Name: [_showFailure]
  ///
  /// Purpose: Maps typed creation failures to localized user feedback.
  ///
  /// Parameters:
  /// - [context]: Preview context used for feedback and navigation.
  /// - [failure]: Typed creation or refresh failure.
  /// - [createdEmployeeId]: Created ID when only refresh failed.
  ///
  /// Returns: Completes after feedback and any required navigation finish.
  Future<void> _showFailure(
    BuildContext context,
    EmployeeCreationFailure failure,
    String? createdEmployeeId,
  ) async {
    final localization = S.of(context);
    final message = switch (failure) {
      DuplicateEmployeeIdFailure() => localization.employeeIdAlreadyExists,
      DuplicateBusinessEmailFailure() =>
        localization.businessEmailAlreadyExists,
      DuplicatePersonalEmailFailure() =>
        localization.personalEmailAlreadyExists,
      MatchingEmployeeEmailsFailure() =>
        localization.personalAndBusinessEmailsMustDiffer,
      EmployeeFileUploadFailure() => localization.employeeFileUploadFailed,
      EmployeeRefreshFailure() => localization.employeeCreatedButRefreshFailed,
      EmployeeTransactionFailure() ||
      UnknownEmployeeCreationFailure() =>
        localization.employeeCreationFailed,
    };
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.noData,
      title: localization.error,
      subtitle: message,
    );
    if (!context.mounted ||
        failure is! EmployeeRefreshFailure ||
        createdEmployeeId == null) {
      return;
    }
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pop();
  }
}

/// Renders preview actions and blocks them while submission is active.
class EmployeePreviewActions extends StatelessWidget {
  const EmployeePreviewActions({
    super.key,
    required this.state,
    required this.onBack,
  });

  final AddEmployeeState state;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final isSubmitting = state.status is AddEmployeeFlowSubmitting;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final secondaryActionColor =
        lightMode ? AppColors.grey : AppColors.mediumGrey;
    final secondaryActionTextStyle =
        StyleText.fontSize14Weight400.copyWith(
      color: lightMode ? AppColors.black : AppColors.white,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            SizedBox(height: 16.h),
            customButton(
              title: localization.back,
              color: secondaryActionColor,
              textStyle: secondaryActionTextStyle,
              function: isSubmitting ? () {} : onBack,
            ),
            SizedBox(height: 16.h),
            customButton(
              title: localization.discard,
              color: secondaryActionColor,
              textStyle: secondaryActionTextStyle,
              function: isSubmitting
                  ? () {}
                  : () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      navigator.pop();
                    },
            ),
          ],
        ),
        customButton(
          title: localization.submit,
          color: isSubmitting ? AppColors.disabledGrey : AppColors.primary,
          textStyle: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.textButton,
          ),
          function: isSubmitting
              ? () {}
              : context.read<AddEmployeeCubit>().submitEmployee,
        ),
      ],
    );
  }
}
