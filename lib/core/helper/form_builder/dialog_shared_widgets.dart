/// Module: form_builder_module/core
///
/// FILE INFO
/// File Name   : dialog_shared_widgets.dart
/// Objective   : Shared presentational pieces reused by the summary/share
///               dialogs (summary box, time fields, edit-permission switch,
///               action buttons). Extracted from the former 1,951-LOC
///               app_dialogs.dart so each dialog file stays small (§7).
library;

import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/edit_permission_info_hint.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
/// Stateless helper widgets shared across the form-builder summary dialogs.
class DialogSharedWidgets {
  DialogSharedWidgets._();

  /// Small labelled value box used in the summary header row.
  static Widget buildSummaryBox(String label, String value, {Color? color}) {
    return Container(
      height: 70.h,
      // Bug report #4/#8: a fixed 150.w let "Access Management" run into the
      // box's corners. At least 150.w, growing with its text, with a 16.sp
      // inset on both sides.
      constraints: BoxConstraints(minWidth: 150.w),
      padding: EdgeInsets.only(
          top: 0.h, bottom: 8.h, left: 16.sp, right: 16.sp),
      decoration: ShapeDecoration(
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label\n',
                style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                  height: 2.0,
                ),
              ),
              TextSpan(
                text: value,
                style: StyleText.fontSize16Weight500.copyWith(color: AppColors.fullBlack).copyWith(
                  color: color ?? AppColors.secondaryText,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Access-begins / access-ends date pickers wired to [cubit].
  static Widget buildTimeFields(
    BuildContext context,
    CreateFormDataCubit cubit,
  ) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, state) {
        if (state is! CreateFormDataLoaded) {
          return const SizedBox.shrink();
        }

        return Row(
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
        );
      },
    );
  }

  /// Edit-permission label + info hint + toggle.
  static Widget buildEditPermissionSwitch(
    BuildContext context,
    CreateFormDataCubit cubit,
  ) {
    return Row(
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
                onChanged: (value) {},
                initialValue: false,
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
    );
  }

  /// Discard / grant-access buttons row.
  static Widget buildActionButtons(
    BuildContext context,
    dynamic Function() onPublishClicked,
  ) {
    return Row(
      children: [
        customButton(
          title: 'Discard',
          function: () {
            Navigator.pop(context);
          },
          width: 150,
          height: 38,
          // Bug report #8/#29: Publish's type style; Discard is darkGrey
          // with white text.
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.white,
          ),
          color: AppColors.darkGrey,
        ),
        const Spacer(),
        customButton(
          title: 'Grant Access',
          function: () {
            Navigator.pop(context);
            onPublishClicked.call();
          },
          width: 150,
          height: 38,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.textButton,
          ),
          color: AppColors.primary,
        ),
      ],
    );
  }
}
