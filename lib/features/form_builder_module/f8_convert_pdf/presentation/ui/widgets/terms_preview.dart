import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/terms_and_condition.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
// Date: 09/1/2026
// By: Amr
// Last update: 10/1/2026
// Purpose: PDF preview widget for Terms and Conditions field

/// PDF Preview widget for Terms and Conditions field
///
/// This widget is used specifically for PDF generation.
/// It displays the T&C title, terms text, and acceptance status
/// in a format suitable for PDF export.
/// UI matches TermsAndConditionsPreviewWidget for consistency.
class TermsAndConditionsPdfPreviewWidget extends StatelessWidget {
  final TermsAndConditionsFieldModel model;

  const TermsAndConditionsPdfPreviewWidget({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    // Get current locale to determine which terms text to show
    final isArabic = Get.locale?.languageCode == 'ar';
    final termsText = isArabic ? model.termsAr : model.termsEn;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15), // ✅ Match preview widget padding
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8), // ✅ Match preview widget radius
      ),
      child: Column(
        crossAxisAlignment: _getCrossAxisAlignment(),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (model.title.isNotEmpty) ...[
            Text(
              model.title,
              style: StyleText.fontSize16Weight500, // ✅ Match preview widget style
              textAlign: _getTextAlignment(),
            ),
            verticalSpace(12), // ✅ Match preview widget spacing
          ],

          // Terms Text Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12), // ✅ Match preview widget padding
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6), // ✅ Match preview widget radius
              border: Border.all(
                color: AppColors.border.withOpacity(0.1),
                width: 1,
              ),
            ),
            constraints: const BoxConstraints(
              minHeight: 100, // ✅ Match preview widget constraints
              maxHeight: 200,
            ),
            child: SingleChildScrollView( // ✅ Add scroll like preview widget
              child: Text(
                termsText.isNotEmpty
                    ? termsText
                    : 'Terms And Condition',
                style: StyleText.fontSize14Weight400.copyWith( // ✅ Match preview widget style
                  color: termsText.isEmpty
                      ? AppColors.text.withOpacity(0.4)
                      : AppColors.text,
                  height: 1.5,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),

          verticalSpace(12), // ✅ Match preview widget spacing

          // Acceptance Status - Using CustomCheckBox for consistency
          Row(
            children: [
              CustomCheckBox(
                isSelected: model.isAccepted ?? false, // ✅ Use CustomCheckBox like preview widget
                borderColor: AppColors.text,
              ),
              horizontalSpace(8), // ✅ Match preview widget spacing
              Expanded(
                child: Text(
                  'I agree to the Privacy Policy and Terms & Conditions',
                  style: StyleText.fontSize14Weight400, // ✅ Match preview widget style
                ),
              ),
            ],
          ),

          if (model.isAccepted != null) ...[
            verticalSpace(8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: model.isAccepted == true
                      ? AppColors.green.withOpacity(0.1)
                      : AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      model.isAccepted == true ? Icons.check_circle : Icons.cancel,
                      size: 12,
                      color: model.isAccepted == true
                          ? AppColors.green
                          : AppColors.red,
                    ),
                    horizontalSpace(4),
                    Text(
                      model.isAccepted == true ? S.of(context).accepted : S.of(context).notAccepted,
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: model.isAccepted == true
                            ? AppColors.green
                            : AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get cross axis alignment based on field configuration
  CrossAxisAlignment _getCrossAxisAlignment() {
    switch (model.alignment) {
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
    switch (model.alignment) {
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