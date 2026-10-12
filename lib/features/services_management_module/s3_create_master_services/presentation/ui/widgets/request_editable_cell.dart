// ******************* FILE INFO *******************
// File Name: request_editable_cell
// Description: Reusable editable table cell for the master-upload request table.
// Module: services_management_module / presentation / s3_create_master_services / ui / widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

/// Q04: extracted from upload_details.dart — a generic, reusable editable cell
/// used in the request-preview table (§17: shared widgets live in ui/widgets/).
class RequestEditableCell extends StatelessWidget {
  const RequestEditableCell({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.errorText,
    required this.onChanged,
    this.width = 220,
    this.height = 36,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final String? errorText;
  final VoidCallback onChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isEmailField = placeholder.toLowerCase().contains('email') ||
        placeholder.toLowerCase().contains('provider') ||
        placeholder.toLowerCase().contains('approver');

    return SizedBox(
      width: errorText != null ? width + 40 : width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            height: height,
            child: CustomTextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (_) => onChanged(),
              hint: placeholder,
              // Error is signalled by the external error icon next to the cell
              // (kept below); no inline errorText here to avoid overflowing the
              // fixed-height table cell.
              fillColor: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              valueStyle: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.text),
              hintStyle: StyleText.fontSize14Weight400.copyWith(fontSize: 13, color: AppColors.mediumGrey),
              inputFormatters: isEmailField
                  ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
                  : null,
            ),
          ),
          if (errorText != null) SizedBox(width: 8.sp),
          if (errorText != null)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 24.sp, horizontal: 16.sp),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    content: SizedBox(
                      width: 410.sp,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                              width: 70.sp, height: 70.sp),
                          SizedBox(height: 16.sp),
                          Text(
                            '${S.of(dialogCtx).warning} $placeholder',
                            style: StyleText.fontSize20Weight600.copyWith(
                                color: AppColors.text, height: 1.7),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.sp),
                          Text(
                            errorText!,
                            style: StyleText.fontSize14Weight400.copyWith(
                                color: AppColors.mediumGrey, height: 1.7),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: 20.sp,
                height: height,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg',
                  width: 20.sp,
                  height: 20.sp,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
