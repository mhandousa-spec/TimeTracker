import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';

import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/preview_screen.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
class CardPreviewActions extends StatelessWidget {
  const CardPreviewActions({
    super.key,
    required this.formModel,
    required this.dataState,
    required this.headState,
  });

  final FormEntity? formModel;
  final CreateFormDataLoaded dataState;
  final CreateFormHeadLoaded headState;

  @override
  Widget build(BuildContext context) {
    final bool isEditMode =
        formModel != null && formModel!.status == FormStatus.publish;

    if (Get.find<MainCoreEmployeeController>().isHasPermission(
      module: Modules.formBuilder,
      section: FormPermissionsSections.formPermissions,
      permission: FormPermissions.convertToPdf,
    ))
      if (formModel != null && formModel!.status == FormStatus.deleted) {
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: customButtonWithSvg(
            title: 'Restore',
            function: () async {
              context.read<HomeCubit>().restoreForm(
                    model: formModel!,
                    context: context,
                  );
            },
            textStyle: StyleText.fontSize16Weight500
                .copyWith(color: AppColors.black),
            color: AppColors.primary,
            image: '',
            widthImage: 0,
            heightImage: 0,
            colorBorder: AppColors.transparent,
          ),
        );
      }

    if (formModel == null || formModel!.status == FormStatus.drafts) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customButtonWithSvg(
                title: 'Preview',
                function: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) {
                    return const PreviewScreen();
                  }));
                },
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                color: AppColors.primary,
                image: '',
                widthImage: 0,
                heightImage: 0,
                colorBorder: AppColors.transparent,
              ),
              customButtonWithSvg(
                title: 'Publish',
                function: () => _handlePublish(context, isEditMode: false),
                textStyle: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.textButton),
                color: AppColors.primary,
                image: '',
                widthImage: 0,
                heightImage: 0,
                colorBorder: AppColors.transparent,
              ),
            ],
          ),
          verticalSpace(8),
          customButtonWithSvg(
            title: 'Save For Later',

            function: () => _handleSaveForLater(context),
            // Bug report p.31/p.34: secondary actions are darkGrey + white
            // text — the same pair as Back and the dialogs' Discard.
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.white,
            ),
            color: AppColors.darkGrey,
            image: '',
            widthImage: 0,
            heightImage: 0,
            colorBorder: AppColors.transparent,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: 10.sp,
          children: [
            customButtonWithSvg(
              title: 'Preview',
              function: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return const PreviewScreen();
                }));
              },
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.black),
              color: AppColors.primary,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.transparent,
            ),
            customButtonWithSvg(
              title: 'Discard Changes',
              function: () => context.pop(),
              // Bug report p.4/p.35: darkGrey + white text, like Back.
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.white),
              color: AppColors.darkGrey,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.transparent,
            ),
          ],
        ),
        customButtonWithSvg(
          title: 'Save',
          function: () => _handlePublish(context, isEditMode: true),
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.black),
          color: AppColors.primary,
          image: '',
          widthImage: 0,
          heightImage: 0,
          colorBorder: AppColors.transparent,
        ),
      ],
    );
  }

  /// Handles form publishing/saving with validation
  Future<void> _handlePublish(
    BuildContext context, {
    required bool isEditMode,
  }) async {
    try {
      final headCubit = context.read<CreateFormHeadCubit>();
      final dataCubit = context.read<CreateFormDataCubit>();
      final homeCubit = context.read<HomeCubit>();

      if (headCubit.state is! CreateFormHeadLoaded) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Form head data not initialized. Please try again.'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (dataCubit.state is! CreateFormDataLoaded) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Form data not initialized. Please try again.'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final isValid = headCubit.validateForm();
      if (!isValid) {
        return;
      }

      final headState = headCubit.state as CreateFormHeadLoaded;
      final dataState = dataCubit.state as CreateFormDataLoaded;
      final accessManagement = headState.accessManagement;

      final formEntityToSave = dataCubit.createFormHomeModel();

      if (isEditMode) {
        homeCubit.updateExistingForm(
          model: formEntityToSave,
          context: context,
          createFormDataCubit: dataCubit,
        );
        return;
      }

      if (ContextExtension(context).isTablett) {
        if (accessManagement == 'Open Access') {
          AppDialogs.summaryOpenAccessDialog(
            context,
            () {
              homeCubit.publishNewForm(
                model: formEntityToSave,
                context: context,
                createFormDataCubit: dataCubit,
                skipDialog: true,
              );
            },
            headCubit: headCubit,
            dataCubit: dataCubit,
          );
        } else if (accessManagement == 'Restricted Access') {
          AppDialogs.summaryRestrictedAccessDialog(
            context,
            () {
              homeCubit.publishNewForm(
                model: formEntityToSave,
                context: context,
                createFormDataCubit: dataCubit,
                skipDialog: true,
              );
            },
            headCubit: headCubit,
            dataCubit: dataCubit,
          );
        } else if (accessManagement == 'Personal Access') {
          homeCubit.publishNewForm(
            model: formEntityToSave,
            context: context,
            createFormDataCubit: dataCubit,
            skipDialog: false,
          );
        }
      } else {
        homeCubit.publishNewForm(
          model: formEntityToSave,
          context: context,
          createFormDataCubit: dataCubit,
        );
      }
    } catch (e, stackTrace) {}
  }

  /// Handles saving form as draft with validation
  Future<void> _handleSaveForLater(BuildContext context) async {
    try {
      final headCubit = context.read<CreateFormHeadCubit>();
      final dataCubit = context.read<CreateFormDataCubit>();
      final homeCubit = context.read<HomeCubit>();

      final isValid = headCubit.validateForm();

      if (!isValid) {
        return;
      }

      homeCubit.draftNewForm(
        model: dataCubit.createFormHomeModel(),
        context: context,
      );
    } catch (e, stackTrace) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save form: ${e.toString()}'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
