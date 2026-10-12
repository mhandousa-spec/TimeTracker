// ******************* FILE INFO *******************
// File Name: custom_excel_text_field.dart
// Description: Reusable Excel-style text field cell used in bulk-upload tables.
// Module: services_management_module / s4_bulk_upload_services / ui / widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CustomExcelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final double width;
  final double height;
  final bool showHeader;
  final FocusNode? focusNode;
  final String headerLabel;
  final String placeholder;
  final Function(String value)? onChanged;
  final int? rowIndex;
  final Function(String key, int index)? validator;
  final bool isDisabled;

  const CustomExcelTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.errorText,
    this.width = 200,
    // ✅ FIX: was 36, which could not contain CustomTextField's default
    // `EdgeInsets.symmetric(vertical: 12.h)` padding plus the 12sp text line
    // (~43px) — that 7px shortfall was the
    //   "A RenderFlex overflowed by 6.9 pixels on the bottom"
    // banner striping every cell of the bulk-upload table.
    //
    // Raised to fit the field as-is, so no contentPadding override is needed.
    this.height = 44,
    this.showHeader = false,
    this.headerLabel = '',
    this.onChanged,
    this.focusNode,
    this.rowIndex,
    this.validator,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isEmail = placeholder.toLowerCase().contains('email');
    final isPhone = placeholder.toLowerCase().contains('phone');
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment:
                headerLabel.trim().contains(RegExp(r'[؀-ۿ]'))
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  headerLabel,
                  style:  StyleText.fontSize14Weight400.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.black.withOpacity(0.87)),
                ),
              ),
            ),
          SizedBox(
            width: width,
            child: Directionality(
              textDirection:
              placeholder.trim().contains(RegExp(r'[؀-ۿ]'))
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Row(
                children: [
                  Expanded(
                    // ✅ FIX: a minimum, not a fixed height. CustomTextField's
                    // default padding is screenutil-scaled (12.h), so on a
                    // denser display it can exceed any hardcoded value — a
                    // fixed SizedBox would start overflowing again. A floor
                    // keeps the row height consistent while letting the field
                    // grow if it must, so this can never overflow.
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: height),
                      child: CustomTextField(
                        controller: controller,
                        focusNode: focusNode,
                        enabled: !isDisabled,
                        hint: placeholder,
                        contentPadding: EdgeInsets.symmetric(vertical: 17.sp,horizontal: 8.sp),
                        fillColor: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                        // contentPadding intentionally NOT overridden — the
                        // field keeps CustomTextField's own default padding.
                        // The cell's `height` parameter is sized to accommodate
                        // it instead.
                        keyboardType:
                            isPhone ? TextInputType.phone : TextInputType.text,
                        inputFormatters: isEmail
                            ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
                            : null,
                        valueStyle: StyleText.fontSize12Weight500.copyWith(
                          color: isDisabled ? AppColors.grey : AppColors.text,
                        ),
                        hintStyle: StyleText.fontSize14Weight400.copyWith(
                            fontSize: 13,
                            color: isDisabled
                                ? AppColors.secondaryText.withOpacity(.5)
                                : AppColors.mediumGrey),
                        onChanged: (value) {
                          if (validator != null && rowIndex != null && !isDisabled) {
                            validator!(placeholder, rowIndex!);
                          }
                          if (onChanged != null) onChanged!(value);
                        },
                      ),
                    ),
                  ),
                  if (errorText != null) SizedBox(width: 8.sp),
                  GestureDetector(
                    onTap: () {
                      if (errorText != null) {
                        showDialog(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 24.sp, horizontal: 16.sp),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                            content: Container(
                              width: 410.sp,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                                      width: 70.sp, height: 70.sp),
                                  SizedBox(height: 16.sp),
                                  Text(
                                    '${S.of(dialogContext).warning} $placeholder',
                                    style: StyleText.fontSize20Weight600.copyWith(
                                        color: AppColors.text, height: 1.7),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16.sp),
                                  Text(
                                    errorText == S.of(dialogContext).emailDoesNotExist ||
                                        errorText == S.of(dialogContext).departmentDoesNotExist
                                        ? S.of(dialogContext).specifiedDoesNotExist(placeholder)
                                        : S.of(dialogContext).specifiedError(placeholder, errorText ?? ''),
                                    style: StyleText.fontSize14Weight400.copyWith(
                                        color: AppColors.mediumGrey, height: 1.7),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: errorText != null
                        ? Container(
                      width: 20.sp,
                      height: height,
                      alignment: Alignment.center,
                      child: SvgPicture.asset('assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg',
                          width: 20.sp, height: 20.sp, fit: BoxFit.cover, color: Colors.red,),
                    )
                        : SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
