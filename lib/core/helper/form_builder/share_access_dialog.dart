/// Module: form_builder_module/core
///
/// FILE INFO
/// File Name   : share_access_dialog.dart
/// Objective   : Share-access summary dialog (person selection + edit
///               permission + access window). Extracted from app_dialogs.dart.
///               Contains NO try/catch — error handling belongs in the
///               ShareCubit, the widget only renders state (§11.2, §19).
library;

import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/edit_permission_info_hint.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/custom/77-default_dialog.dart';
/// Dialog that lets the publisher review recipients and access settings
/// before sharing a form.
class ShareAccessDialog {
  ShareAccessDialog._();

  static void show(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    ShareCubit? shareCubit,
  }) {
    final effectiveShareCubit = shareCubit ?? context.read<ShareCubit>();
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    // Bug report (share, p.1): validation used to run in ShareCubit.grantAccess
    // AFTER this dialog had already closed, and it reported through
    // Get.snackbar — the "Error / Please select access begin date" toast that
    // landed on top of the logo. The dialog now validates itself and shows the
    // message under the field, the same way SummaryOpenAccessDialog does.
    bool showValidationErrors = false;

    GetDialogHelper.generalDialog(
      context: context,
      child: BlocProvider<ShareCubit>.value(
        value: effectiveShareCubit,
        child: DefaultDialog(
          width: !ContextExtension(context).isPhone ? 615.w : 320.w,
          height: !ContextExtension(context).isPhone ? 685.h : 500.h,
          customWidget: Padding(
            padding: const EdgeInsets.all(15),
            child: StatefulBuilder(
              builder: (context, setState) =>
                  BlocBuilder<ShareCubit, ShareState>(
              builder: (context, state) {
                if (state is! ShareLoaded) {
                  return const SizedBox.shrink();
                }

                final cubit = context.read<ShareCubit>();
                final bool hasTimeBegin = state.timeBegin != null;
                final bool hasTimeEnd = state.timeEnd != null;
                final bool hasPersons = state.newSelectedPersons.isNotEmpty;
                final bool isValid = hasTimeBegin && hasTimeEnd && hasPersons;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 15.r,
                          child: SvgPicture.asset(AppAssets.summary),
                        ),
                        horizontalSpace(8),
                        Text(
                          'Summary',
                          style: StyleText.fontSize16Weight500,
                        ),
                        const Spacer(),
                        Text(
                          'Edit Permission',
                          style: StyleText.fontSize14Weight500,
                        ),
                        horizontalSpace(10),
                        const EditPermissionInfoHint(),
                        horizontalSpace(20),
                        AdvancedSwitch(
                          onChanged: (value) {
                            cubit.updateEditPermission(value);
                          },
                          initialValue: state.isEditPermission,
                          activeColor: AppColors.primary,
                          width: 30,
                          height: 18,
                        ),
                      ],
                    ),
                    verticalSpace(15),

                    // Date Pickers Row — top-aligned so an error line under
                    // one field does not push the other one out of line.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomDropdownCalendar(
                                label: 'Access Begins',
                                fillColor: AppColors.background,
                                value: state.timeBegin,
                                hint: 'Choose The Date',
                                errorText: showValidationErrors && !hasTimeBegin
                                    ? 'Please select start date'
                                    : null,
                                onChanged: (value) {
                                  if (value != null) {
                                    cubit.updateTimeBegin(value);
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                        horizontalSpace(15),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomDropdownCalendar(
                                label: 'Access Ends',
                                fillColor: AppColors.background,
                                value: state.timeEnd,
                                hint: 'Choose The Date',
                                errorText: showValidationErrors && !hasTimeEnd
                                    ? 'Please select end date'
                                    : null,
                                onChanged: (value) {
                                  if (value != null) {
                                    cubit.updateTimeEnd(value);
                                  }
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    verticalSpace(20),

                    // Search Field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppSearchTextField(
                          fillColor: AppColors.background,
                          controller: TextEditingController(),
                          onChanged: (value) {
                            cubit.newSelectedSearch(value);
                          },
                        )
                      ],
                    ),
                    if (showValidationErrors && !hasPersons) ...[
                      verticalSpace(6),
                      Text(
                        'Please select at least one person',
                        style: StyleText.fontSize12Weight400
                            .copyWith(color: AppColors.red),
                      ),
                    ],
                    verticalSpace(15),

                    // Person List
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final persons = state.filteredNewSelectedPersons;

                          if (persons.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No persons found',
                                  style: StyleText.fontSize16Weight500,
                                ),
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            key: const ValueKey('person_scroll_view'),
                            child: Column(
                              children: isTablet
                                  ? _buildTabletPersonList(context, persons)
                                  : _buildPhonePersonList(context, persons),
                            ),
                          );
                        },
                      ),
                    ),
                    verticalSpace(25),

                    // Action Buttons
                    Row(
                      children: [
                        customButton(
                          width: 150,
                          height: 38,
                          title: 'Discard',
                          function: () {
                            Get.back();
                          },
                          // Bug report #29: darkGrey with white text.
                          color: AppColors.darkGrey,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.white),
                        ),
                        const Spacer(),
                        customButton(
                          width: 150,
                          height: 38,
                          textStyle: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.textButton),
                          title: 'Send',
                          function: () {
                            if (!isValid) {
                              setState(() => showValidationErrors = true);
                              return;
                            }
                            Get.back();
                            onPublishClicked.call();
                          },
                        )
                      ],
                    ),
                  ],
                );
              },
            ),
            ),
          ),
          autoClose: false,
        ),
      ),
    );
  }

  static List<Widget> _buildTabletPersonList(
      BuildContext context, List<PersonEntity> persons) {
    final rowCount = (persons.length + 1) ~/ 2;

    return List.generate(rowCount, (index) {
      final leftIndex = index * 2;
      final rightIndex = leftIndex + 1;

      return Container(
        key: ValueKey('tablet_row_$index'),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            _personView(context, persons[leftIndex]),
            horizontalSpace(10),
            if (rightIndex < persons.length)
              _personView(context, persons[rightIndex])
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
    });
  }

  static List<Widget> _buildPhonePersonList(
      BuildContext context, List<PersonEntity> persons) {
    return List.generate(persons.length, (index) {
      return Container(
        key: ValueKey('phone_person_${persons[index].id}_$index'),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: _personView(context, persons[index]),
      );
    });
  }

  static Widget _personView(BuildContext context, PersonEntity person) {
    final cubit = context.read<ShareCubit>();
    final state = cubit.state;

    if (state is! ShareLoaded) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          final index = state.filteredPersons.indexOf(person);
          if (index != -1) {
            cubit.togglePersonSelection(index, false);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.all(Radius.circular(6.r)),
          ),
          padding: EdgeInsetsDirectional.only(
            start: 13.sp,
            end: 7.sp,
            top: 10.sp,
            bottom: 10.sp,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 15.r,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: SizedBox(
                          child: CustomSvgImage(
                            assetPath:
                                "assets/icons_assets/main_icons_assets/male_avatar.svg",
                            width: 40.w,
                            height: 40.h,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    horizontalSpace(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatHelper.capitalize(person.name),
                            style: StyleText.fontSize14Weight500,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            FormatHelper.capitalize(person.departmentName),
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                          ),
                          Text(
                            FormatHelper.capitalize(person.title),
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              CustomCheckBox(isSelected: person.isSelected),
            ],
          ),
        ),
      ),
    );
  }
}
