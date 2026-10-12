import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/terms_conditions_field_controller.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
// Date: 08/1/2026
// By: Amr
// Last update: 08/1/2026
// Objectives: Preview widget for Terms and Conditions field showing title, terms text, and acceptance checkbox

/// Preview widget for Terms and Conditions field
///
/// Displays:
/// - Title (aligned based on configuration)
/// - Terms and conditions text (based on current locale)
/// - Acceptance checkbox (always required)
class TermsAndConditionsPreviewWidget extends StatefulWidget {
  final bool isReadOnly;
  final TermsConditionsFieldController fieldController;

  const TermsAndConditionsPreviewWidget({
    super.key,
    required this.isReadOnly,
    required this.fieldController,
  });

  @override
  State<TermsAndConditionsPreviewWidget> createState() =>
      _TermsAndConditionsPreviewWidgetState();
}

class _TermsAndConditionsPreviewWidgetState
    extends State<TermsAndConditionsPreviewWidget> {
  @override
  Widget build(BuildContext context) {
    // Get current locale to determine which terms text to show
    final isArabic = Get.locale?.languageCode == 'ar';
    final termsText = isArabic
        ? widget.fieldController.termsAr?.text ?? ''
        : widget.fieldController.termsEn?.text ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),

      ),
      child: Column(
        crossAxisAlignment: _getCrossAxisAlignment(),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (widget.fieldController.title?.text.isNotEmpty ?? false) ...[
            Text(
              widget.fieldController.title!.text,
              style: StyleText.fontSize16Weight500,
              textAlign: _getTextAlignment(),
            ),
            verticalSpace(12),
          ],

          // Terms and Conditions Text Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.border.withOpacity(0.1),
                width: 1,
              ),
            ),
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 200,
            ),
            child: SingleChildScrollView(
              child: Text(
                termsText.isNotEmpty
                    ? termsText
                    : S.of(context).fieldTypeTermsAndCondition,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: termsText.isEmpty
                      ? AppColors.text.withOpacity(0.4)
                      : AppColors.text,
                  height: 1.5,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),

          verticalSpace(12),

          // Acceptance Checkbox
          InkWell(
            onTap: widget.isReadOnly
                ? null
                : () {
              setState(() {
                widget.fieldController.isAccepted =
                !widget.fieldController.isAccepted;
              });
            },
            child: Row(
              children: [
                CustomCheckBox(
                  isSelected: widget.fieldController.isAccepted,
                  borderColor: AppColors.text,
                ),
                horizontalSpace(8.w),
                Expanded(
                  child: Text(
                    S.of(context).iAgreeToThePrivacyPolicyAndTermsAndConditions,
                    style: StyleText.fontSize14Weight400,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  /// Get cross axis alignment based on field configuration
  CrossAxisAlignment _getCrossAxisAlignment() {
    final alignment = widget.fieldController.alignment;
    switch (alignment) {
      case 'Left':
        return CrossAxisAlignment.start;
      case 'Right':
        return CrossAxisAlignment.end;
      case 'Center':
        return CrossAxisAlignment.center;
      case 'Expand':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }

  /// Get text alignment based on field configuration
  TextAlign _getTextAlignment() {
    final alignment = widget.fieldController.alignment;
    switch (alignment) {
      case 'Left':
        return TextAlign.left;
      case 'Right':
        return TextAlign.right;
      case 'Center':
        return TextAlign.center;
      case 'Expand':
        return TextAlign.justify;
      default:
        return TextAlign.center;
    }
  }
}