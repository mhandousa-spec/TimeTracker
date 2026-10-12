// ***************************** FILE INFO ***************************** //
// File Name: add_employee_actions_row.dart
// Purpose: Renders navigation actions for the add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/5-custom_button.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import '../../controller/add_employee_cubit.dart';
import '../../controller/add_employee_state.dart';
import '../../../utils/add_employee_step.dart';
import '../pages/hr_add_employee_preview_page.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays the left and right actions for the current add-employee step.
class AddEmployeeActionsRow extends StatelessWidget {
  const AddEmployeeActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddEmployeeCubit, AddEmployeeState>(
      builder: (context, state) {
        final localization = S.of(context);
        final lightMode = Theme.of(context).brightness == Brightness.light;
        final secondaryActionColor =
            lightMode ? AppColors.grey : AppColors.mediumGrey;
        final secondaryActionTextStyle =
            StyleText.fontSize14Weight400.copyWith(
          color: lightMode ? AppColors.black : AppColors.white,
        );
        final isFirstStep =
            state.currentStep == AddEmployeeStep.personalInformation;
        final isLastStep = state.currentStep == AddEmployeeStep.values.last;
        final canAdvance =
            context.read<AddEmployeeCubit>().canAdvanceCurrentStep;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isFirstStep
                ? customButton(
                    title: localization.discard,
                    color: secondaryActionColor,
                    textStyle: secondaryActionTextStyle,
                    function: () => _handleDiscard(context),
                  )
                : Column(
                    children: [
                      customButton(
                        title: localization.back,
                        color: secondaryActionColor,
                        textStyle: secondaryActionTextStyle,
                        function: () => _handleLeftAction(context, state),
                      ),
                      SizedBox(height: 16.h),
                      customButton(
                        title: localization.discard,
                        color: secondaryActionColor,
                        textStyle: secondaryActionTextStyle,
                        function: () => _handleDiscard(context),
                      ),
                    ],
                  ),
            IgnorePointer(
              ignoring: !canAdvance,
              child: customButton(
                title: isLastStep ? localization.preview : localization.next,
                color: canAdvance ? AppColors.primary : secondaryActionColor,
                textStyle: StyleText.fontSize14Weight400.copyWith(
                  color: canAdvance
                      ? AppColors.textButton
                      : lightMode
                          ? AppColors.black
                          : AppColors.white,
                ),
                function: () => _handleNextAction(context),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Method Name: [_handleDiscard]
  ///
  /// Purpose: Exits the add-employee flow and returns to Employees.
  ///
  /// Parameters:
  /// - [context]: Context used to access the current navigator.
  ///
  /// Returns: No value; the current route is popped.
  void _handleDiscard(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Method Name: [_handleLeftAction]
  ///
  /// Purpose: Handles discard, back, and create-other actions by step.
  ///
  /// Parameters:
  /// - [context]: Context used to access the flow Cubit and navigator.
  /// - [state]: Current add-employee flow state.
  ///
  /// Returns: A future that completes after the selected action.
  Future<void> _handleLeftAction(
    BuildContext context,
    AddEmployeeState state,
  ) async {
    final cubit = context.read<AddEmployeeCubit>();
    final isFirstStep =
        state.currentStep == AddEmployeeStep.personalInformation;

    if (isFirstStep) {
      Navigator.of(context).pop();
    } else {
      await cubit.goToPreviousStep();
    }
  }

  /// Method Name: [_handleNextAction]
  ///
  /// Purpose: Validates the active step and advances the flow when possible.
  ///
  /// Parameters:
  /// - [context]: Context used to access the flow Cubit.
  ///
  /// Returns: A future that completes after the optional step transition.
  Future<void> _handleNextAction(BuildContext context) async {
    final cubit = context.read<AddEmployeeCubit>();
    if (!cubit.validateCurrentStep()) return;
    if (cubit.currentStepIndex == AddEmployeeStep.emergencyDetails.index) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: cubit,
            child: const HrAddEmployeePreviewPage(),
          ),
        ),
      );
      return;
    }
    await cubit.goToNextStep();
  }
}
