/// Module: form_builder_module/core
///
/// FILE INFO
/// File Name   : summary_open_access_dialog.dart
/// Objective   : Open-access publish summary dialog. Extracted from
///               app_dialogs.dart; renders CreateForm head/data cubit state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/edit_permission_info_hint.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/custom/77-default_dialog.dart';
import 'package:knowticed_plus/core/helper/form_builder/dialog_shared_widgets.dart';
/// Publish-summary dialog used when the form is shared with open access.
class SummaryOpenAccessDialog {
  SummaryOpenAccessDialog._();

  static void show(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    CreateFormHeadCubit? headCubit,
    CreateFormDataCubit? dataCubit,
  }) {
    bool showValidationErrors = false;

    final effectiveHeadCubit = headCubit ?? context.read<CreateFormHeadCubit>();
    final effectiveDataCubit = dataCubit ?? context.read<CreateFormDataCubit>();

    final MainCoreDepartmentCubit addDepartmentController =
        Get.find<MainCoreDepartmentCubit>();

    GetDialogHelper.generalDialog(
      context: context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CreateFormHeadCubit>.value(value: effectiveHeadCubit),
          BlocProvider<CreateFormDataCubit>.value(value: effectiveDataCubit),
        ],
        child: DefaultDialog(
          width: 600.w,
          customWidget: StatefulBuilder(
            builder: (context, setState) {
              return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
                builder: (context, headState) {
                  if (headState is! CreateFormHeadLoaded) {
                    return const Center(child: Text('Loading head state...'));
                  }

                  return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
                    builder: (context, dataState) {
                      if (dataState is! CreateFormDataLoaded) {
                        return const Center(child: Text('Loading data state...'));
                      }

                      final dataCubit = context.read<CreateFormDataCubit>();

                      final hasDepartments =
                          dataState.departmentsShown.isNotEmpty;
                      final hasTimeBegin = dataState.timeBegin != null;
                      final hasTimeEnd = dataState.timeEnd != null;
                      final isValid =
                          hasDepartments && hasTimeBegin && hasTimeEnd;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary,
                                radius: 15,
                                child: SvgPicture.asset(AppAssets.summary),
                              ),
                              horizontalSpace(8),
                              Text(
                                'Summary',
                                style: StyleText.fontSize16Weight500,
                              ),
                            ],
                          ),
                          verticalSpace(15),

                          // Summary boxes
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              DialogSharedWidgets.buildSummaryBox(
                                'Access Management',
                                'Open Access',
                                color: AppColors.secondaryText,
                              ),
                              const Spacer(),
                              DialogSharedWidgets.buildSummaryBox(
                                'Orientation',
                                headState.orientation ??
                                    'Portrait',
                                color: AppColors.secondaryText,
                              ),


                              const Spacer(),
                              DialogSharedWidgets.buildSummaryBox(
                                'Total Pages',
                                FormDateTimeHelper.formatInt(
                                    dataState.pages.length),
                                color: AppColors.secondaryText,
                              ),
                            ],
                          ),
                          verticalSpace(15),

                          // Department dropdown and selected departments
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: DropDownWidget(
                                      fillColor: AppColors.background,
                                      title: 'Department',
                                      hint: 'Department',
                                      items: addDepartmentController
                                          .departmentModels
                                          .map((element) {
                                        final isArabic =
                                            Get.locale?.languageCode == 'ar';
                                        final displayName = isArabic
                                            ? element.departmentNameInArabic ??
                                                element.departmentName!
                                            : addDepartmentController
                                                .containAbbreviation(
                                                element.departmentName!
                                                    .toLowerCase(),
                                              );

                                        return DropdownMenuItem<String>(
                                          value: element.departmentID!,
                                          child: Text(
                                            displayName,
                                            style: StyleText.fontSize14Weight400,
                                          ),
                                        );
                                      }).toList(),
                                      currentValue: null,
                                      onChanged: (value) {
                                        dataCubit.onDropDownOpenAccess(value);
                                      },
                                    ),
                                  ),
                                  horizontalSpace(15),
                                  Expanded(child: Container())
                                ],
                              ),
                              verticalSpace(4),
                              if (showValidationErrors && !hasDepartments) ...[
                                Text(
                                  'Please select at least one department',
                                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
                                ),
                                verticalSpace(8),
                              ],
                              Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: List.generate(
                                  dataState.departmentsShown.length,
                                  (index) {
                                    final isArabic =
                                        Get.locale?.languageCode == 'ar';
                                    final department =
                                        dataState.departmentsShown[index];
                                    final displayName = isArabic
                                        ? department.nameAr
                                        : department.name;

                                    return Container(
                                      height: 28.h,
                                      decoration: ShapeDecoration(
                                        color: AppColors.background,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Text(
                                                FormatHelper.capitalize(displayName),
                                                style: StyleText.fontSize14Weight600,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment:
                                                AlignmentDirectional.topEnd,
                                            child: InkWell(
                                              onTap: () {
                                                dataCubit
                                                    .onCancelDepartmentOpenAccess(
                                                        index);
                                              },
                                              child: Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                  top: 8.h,
                                                  end: 5.w,
                                                ),
                                                child: SvgPicture.asset(
                                                  AppAssets.cancel,
                                                  height: 12.h,
                                                  width: 12.w,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          verticalSpace(18),

                          // Time fields — top-aligned (bug p.39): with an
                          // error line under only one field the default
                          // center alignment pushed the two out of line.
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // LABEL VIA `label:`, NOT A HAND-ROLLED
                                    // `Text` ABOVE THE FIELD (19/8/2026).
                                    //
                                    // "Department" is drawn by CustomDropdown's
                                    // own label slot — StyleText.fontSize14-
                                    // Weight500 at 14.sp, then a 6.sp gap. The
                                    // two date titles were a plain `Text` in
                                    // StyleText.fontSize14Weight600 followed by
                                    // verticalSpace(8), so they sat at a
                                    // different weight and a different distance
                                    // from their box than the dropdown above.
                                    // CustomDropdownCalendar.label renders the
                                    // identical label + 6.sp spacer, so handing
                                    // it the string keeps all three titles in
                                    // step by construction — no style constant
                                    // to keep in sync here.
                                    CustomDropdownCalendar(
                                      label: 'Access Begins',
                                      fillColor: AppColors.background,
                                      value: dataState.timeBegin,
                                      hint: 'Choose The Date',
                                      errorText: showValidationErrors &&
                                              !hasTimeBegin
                                          ? 'Please select start date'
                                          : null,
                                      onChanged: (value) {
                                        if (value != null) {
                                          dataCubit.updateTimeBegin(value);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              horizontalSpace(15),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // See the note on 'Access Begins' above.
                                    CustomDropdownCalendar(
                                      label: 'Access Ends',
                                      fillColor: AppColors.background,
                                      value: dataState.timeEnd,
                                      hint: 'Choose The Date',
                                      errorText:
                                          showValidationErrors && !hasTimeEnd
                                              ? 'Please select end date'
                                              : null,
                                      onChanged: (value) {
                                        if (value != null) {
                                          dataCubit.updateTimeEnd(value);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          verticalSpace(25),

                          // Edit permission switch
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const EditPermissionInfoHint(),
                                    horizontalSpace(10),
                                    Text(
                                      'Edit Permission',
                                      style: StyleText.fontSize14Weight600,
                                    ),
                                    const Spacer(),
                                    AdvancedSwitch(
                                      onChanged: (value) {
                                        dataCubit.updateIsEdit(value);
                                      },
                                      initialValue: dataState.isEdit,
                                      activeColor: AppColors.primary,
                                      width: 30.w,
                                      height: 18.h,
                                    ),
                                  ],
                                ),
                              ),
                              horizontalSpace(15),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                          verticalSpace(25),

                          // Action buttons
                          Row(
                            children: [
                              customButton(
                                title: 'Discard',
                                function: () {
                                  Navigator.pop(context);
                                },
                                width: 150,
                                height: 38,
                                // Bug report #8/#29: same type style as
                                // Publish; Discard darkGrey + white text.
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.white),
                                color: AppColors.darkGrey,
                              ),
                              const Spacer(),
                              customButton(
                                title: 'Grant Access',
                                function: () {
                                  if (isValid) {
                                    Navigator.pop(context);
                                    onPublishClicked();
                                  } else {
                                    setState(() {
                                      showValidationErrors = true;
                                    });
                                  }
                                },
                                width: 150,
                                height: 38,
                                textStyle: StyleText.fontSize16Weight500
                                    .copyWith(color: AppColors.textButton),
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          verticalSpace(5),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
          autoClose: false,
        ),
      ),
    );
  }
}
