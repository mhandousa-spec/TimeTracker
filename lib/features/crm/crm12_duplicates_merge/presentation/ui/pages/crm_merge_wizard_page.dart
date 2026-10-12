// ****************** FILE INFO ******************
// File Name: crm_merge_wizard_page.dart
// Purpose: 4-Step Merge Wizard container page hosting steps 1 to 4 with SideFrameMasterServices matching Figma screenshots
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_state.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merge_compare_section.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merge_preview_card.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merge_select_duplicates_section.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merge_stepper_header.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merge_success_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmMergeWizardPage extends StatelessWidget {
  const CrmMergeWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CrmDuplicatesCubit, CrmDuplicatesState>(
        builder: (BuildContext context, CrmDuplicatesState state) {
          final CrmDuplicatesCubit cubit = context.read<CrmDuplicatesCubit>();
          final pair = state.currentWizardPair;

          if (pair == null) {
            return Center(
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'No duplicate pair selected',
                  arabicName: 'لم يتم تحديد سجل مكرر',
                ),
              ),
            );
          }

          return SideFrameMasterServices(
            titleText: S.current.crmClients,
            secondTitle: FormatHelper.localizedString(
              englishName: 'Duplicates Review & Merge',
              arabicName: 'مراجعة ودمج المكررات',
            ),
            thirdTitle: FormatHelper.localizedString(
              englishName: 'Add Comparison',
              arabicName: 'إضافة مقارنة',
            ),
            onFirstTap: () => Navigator.pop(context),
            onSecondTap: () => Navigator.pop(context),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. 4-Step Stepper Header
                  CrmMergeStepperHeader(currentStep: state.currentStep),
                  SizedBox(height: 20.sp),

                  // 2. Step Dynamic Content
                  _buildStepContent(context, state, cubit),
                  SizedBox(height: 28.sp),

                  // 3. Bottom Action Buttons
                  _buildActionButtons(context, state, cubit),

                  SizedBox(height: 32.sp),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    CrmDuplicatesState state,
    CrmDuplicatesCubit cubit,
  ) {
    final pair = state.currentWizardPair!;

    switch (state.currentStep) {
      case CrmMergeStep.selectDuplicates:
        return CrmMergeSelectDuplicatesSection(pair: pair);

      case CrmMergeStep.compareAndMerge:
        return CrmMergeCompareSection(
          pair: pair,
          selectedMasterId: state.selectedMasterRecordId ?? pair.record1.id,
          selectedFieldSources: state.selectedFieldRecordSources,
          onMasterChanged: cubit.setMasterRecord,
          onFieldSourceChanged: cubit.selectFieldSource,
        );

      case CrmMergeStep.reviewAndConfirm:
        return CrmMergePreviewCard(
          pair: pair,
          masterId: state.selectedMasterRecordId ?? pair.record1.id,
          selectedFieldSources: state.selectedFieldRecordSources,
        );

      case CrmMergeStep.completed:
        return CrmMergeSuccessView(
          onBackToDuplicates: () => Navigator.pop(context),
          onViewClient: () => Navigator.pop(context),
        );
    }
  }

  Widget _buildActionButtons(
    BuildContext context,
    CrmDuplicatesState state,
    CrmDuplicatesCubit cubit,
  ) {
    if (state.currentStep == CrmMergeStep.selectDuplicates) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Discard',
              arabicName: 'إلغاء',
            ),
            color: AppColors.grey,
            textColor: AppColors.text,
            function: () => Navigator.pop(context),
          ),
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Compare',
              arabicName: 'مقارنة',
            ),
            color: AppColors.primary,
            textColor: AppColors.text,
            function: () => cubit.goToStep(CrmMergeStep.compareAndMerge),
          ),
        ],
      );
    }

    if (state.currentStep == CrmMergeStep.compareAndMerge) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Back',
                  arabicName: 'رجوع',
                ),
                color: AppColors.grey,
                textColor: AppColors.text,
                function: () => cubit.goToStep(CrmMergeStep.selectDuplicates),
              ),
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Confirm',
                  arabicName: 'تأكيد',
                ),
                color: AppColors.primary,
                textColor: AppColors.text,
                function: () => cubit.goToStep(CrmMergeStep.reviewAndConfirm),
              ),
            ],
          ),
          SizedBox(height: 10.sp),
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Save for Later',
              arabicName: 'حفظ للمتابعة لاحقاً',
            ),
            color: AppColors.darkGrey,
            textColor: AppColors.white,
            function: () => Navigator.pop(context),
          ),
        ],
      );
    }

    if (state.currentStep == CrmMergeStep.reviewAndConfirm) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Back',
                  arabicName: 'رجوع',
                ),
                color: AppColors.grey,
                textColor: AppColors.text,
                function: () => cubit.goToStep(CrmMergeStep.compareAndMerge),
              ),
              customButton(
                title: FormatHelper.localizedString(
                  englishName: 'Merge',
                  arabicName: 'دمج',
                ),
                color: AppColors.primary,
                textColor: AppColors.text,
                function: () => cubit.executeMerge(),
              ),
            ],
          ),
          SizedBox(height: 10.sp),
          customButton(
            title: FormatHelper.localizedString(
              englishName: 'Save for Later',
              arabicName: 'حفظ للمتابعة لاحقاً',
            ),
            color: AppColors.darkGrey,
            textColor: AppColors.white,
            function: () => Navigator.pop(context),
          ),
        ],
      );
    }

    // Step 4: Completed
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Back',
                arabicName: 'رجوع',
              ),
              color: AppColors.grey,
              textColor: AppColors.text,
              function: () => Navigator.pop(context),
            ),
            customButton(
              title: FormatHelper.localizedString(
                englishName: 'Confirm',
                arabicName: 'تأكيد',
              ),
              color: AppColors.primary,
              textColor: AppColors.text,
              function: () => Navigator.pop(context),
            ),
          ],
        ),
        SizedBox(height: 10.sp),
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Save for Later',
            arabicName: 'حفظ للمتابعة لاحقاً',
          ),
          color: AppColors.darkGrey,
          textColor: AppColors.white,
          function: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
