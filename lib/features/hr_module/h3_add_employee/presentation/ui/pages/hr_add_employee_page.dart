// ***************************** FILE INFO ***************************** //
// File Name: hr_add_employee_page.dart
// Purpose: Provides the entry page and navigation for the HR add-employee flow.
// Author: Mohamed Elrashidy
// Created At: 2026-08-08
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../data/repository/employee_repository.dart';
import '../../../../../../core/helper/main_helper/pagination_app_bar.dart';
import '../../controller/add_employee_cubit.dart';
import '../../controller/add_employee_state.dart';
import '../widgets/add_employee_actions_row.dart';
import '../widgets/add_employee_step_surface.dart';
import '../widgets/hr_address_details_step.dart';
import '../widgets/hr_personal_information_step.dart';
import '../widgets/hr_contact_details_step.dart';
import '../widgets/hr_identification_details_step.dart';
import '../widgets/hr_position_details_step.dart';
import '../widgets/hr_certification_details_step.dart';
import '../widgets/hr_insurance_details_step.dart';
import '../widgets/hr_emergency_details_step.dart';
import '../../../../main_controller/presentation/ui/widgets/hr_progress_stepper.dart';
import '../../../utils/add_employee_step.dart';

/// Provides the initial placeholder page for the add-employee flow.
class HrAddEmployeePage extends StatelessWidget {
  const HrAddEmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);

    return BlocProvider(
      create: (_) => AddEmployeeCubit(
        repository: EmployeeRepository(),
        hrModuleDataCubit: context.read<HrModuleDataCubit>(),
      ),
      child: Scaffold(
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
                Expanded(
                  child: BlocBuilder<AddEmployeeCubit, AddEmployeeState>(
                    builder: (context, state) {
                      final stepItems = AddEmployeeStep.values
                          .map((step) => step.title)
                          .toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HrProgressStepper(
                            items: stepItems,
                            currentItem: state.currentStep.index,
                            progressAmount: context
                                .read<AddEmployeeCubit>()
                                .getStepProgress(state.currentStep),
                            stepProgressAmounts: AddEmployeeStep.values
                                .map(context
                                    .read<AddEmployeeCubit>()
                                    .getStepProgress)
                                .toList(),
                          ),
                          SizedBox(height: 24.h),
                          Expanded(
                            child: PageView(
                              controller: context
                                  .read<AddEmployeeCubit>()
                                  .pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                AddEmployeeStepSurface(
                                    child: const HrPersonalInformationStep()),
                                AddEmployeeStepSurface(
                                    child: const HrContactDetailsStep()),
                                AddEmployeeStepSurface(
                                    child: const HrAddressDetailsStep()),
                                AddEmployeeStepSurface(
                                    child: const HrIdentificationDetailsStep()),
                                AddEmployeeStepSurface(
                                    child: const HrPositionDetailsStep()),
                                AddEmployeeStepSurface(
                                    child: const HrCertificationDetailsStep()),
                                AddEmployeeStepSurface(
                                    child: const HrInsuranceDetailsStep()),
                                AddEmployeeStepSurface(
                                    child: const HrEmergencyDetailsStep()),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          const AddEmployeeActionsRow(),
                          SizedBox(height: 24.h),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
