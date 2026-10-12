import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
class TimeSelectorPreviewWidget extends StatelessWidget {
  const TimeSelectorPreviewWidget({
    super.key,
    this.fieldController,
    this.reviewModel,
    this.isValidated = false,
    this.isReadOnly = false,
    this.isWhiteFill = false,
    this.onTapZone,
    this.onTapTime,
  });
  final TimeSelectorFieldController? fieldController;
  final TimeSelectorFieldModel? reviewModel;
  final bool isValidated, isWhiteFill, isReadOnly;
  final void Function()? onTapZone;
  final void Function(TimeOfDay)? onTapTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and required indicator
        TextRequiredWidget(
          isRequired: _getIsRequired(),
          text: _getTitle(),
        ),
        verticalSpace(4),
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: isReadOnly
                    ? null
                    : () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (context, child) {
                            return Localizations.override(
                              context: context,
                              locale: Get.locale,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    backgroundColor: AppColors.background,
                                    dayPeriodTextColor: AppColors.text,
                                    hourMinuteTextColor:
                                        AppTheme.contrastColor(),
                                    dayPeriodBorderSide: BorderSide(
                                      color: AppColors.secondaryPrimary,
                                    ),
                                    dayPeriodColor: AppColors.secondaryPrimary,
                                  ),
                                  colorScheme: ColorScheme(
                                    primary: AppColors.secondaryPrimary,
                                    secondary: AppColors.secondaryPrimary,
                                    surface: AppColors.primary,
                                    onSurface: AppTheme.contrastColor(),
                                    onError: AppColors.red,
                                    onPrimary: AppColors.white,
                                    onSecondary: AppColors.black,
                                    brightness: AppTheme.isDark ?? false
                                        ? Brightness.dark
                                        : Brightness.light,
                                    error: AppColors.red,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                          },
                        ).then(
                          (value) {
                            if (value != null) {
                              // Convert TimeOfDay to formatted string
                              final String formattedTime =
                                  value.format(context);

                              // If custom callback exists, use it
                              if (onTapTime != null) {
                                onTapTime!(value);
                              }
                              // Otherwise use default behavior
                              else if (isValidated) {
                                Get.find<FillOutCubit>().onTimeClicked(
                                    controller: fieldController!, value: value);
                              }
                            }
                          },
                        );
                      },
                child: SizedBox(
                  width: 70.w,
                  child: CustomTextField(
        enabled: false,
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #23
        hint: fieldController?.time ?? _getHint(),
        hintStyle: StyleText.fontSize12Weight400,
        maxLines: 1,
        fillColor:
                        isWhiteFill ? AppColors.white : AppColors.background,
        width: double.infinity,
      ),
                ),
              ),
              horizontalSpace(10),

              GestureDetector(
                onTap: onTapZone ??
                    () {
                      if (!isReadOnly || isValidated) {
                        Get.find<FillOutCubit>()
                            .onTimeAmClicked(controller: fieldController!);
                      }
                    },
                child: Container(
                  height: 36.sp, // form bug report #23: same scale as CustomTextField
                  width: 36.w,
                  decoration: BoxDecoration(
                    color: isWhiteFill ? AppColors.white : AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                      alignment: AlignmentDirectional.center,
                      child: Text(
                          isValidated
                              ? (fieldController?.amOrPM ??
                                  'AM')
                              : 'AM',
                          style: StyleText.fontSize12Weight400)),
                ),
              ),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  bool _getIsRequired() {
    bool flag = false;
    if (reviewModel != null) {
      flag = reviewModel?.isRequired ?? false;
      return flag;
    }
    flag = fieldController?.isRequired ?? false;
    return flag;
  }

  String _getTitle() {
    if (reviewModel != null) {
      return reviewModel?.title ?? '';
    }
    return fieldController?.title?.text ?? '';
  }

  _getHint() {
    return '${FormDateTimeHelper.formatInt(0)} ${FormDateTimeHelper.formatInt(0)} : ${FormDateTimeHelper.formatInt(00)} ${FormDateTimeHelper.formatInt(0)}';
  }

  _getValidate(String? value) {
    if (isValidated) {
      if (fieldController?.time != null) return null;
      if (fieldController?.isRequired ?? false) {
        String? error =
            Validator.isEmpty(value, fieldController?.title?.text ?? '');
        return error;
      }
    } else {
      return null;
    }
  }
}
