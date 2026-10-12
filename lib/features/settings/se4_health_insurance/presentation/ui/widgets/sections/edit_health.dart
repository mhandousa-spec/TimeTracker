/// Module: settings/se4_health_insurance
///
///*************************** FILE INFO ****************************///
/// File Name: edit_health.dart
/// Purpose: The editable insurance fields used by the request form.
/// Author: Amr Mesbah
/// Created at: 12/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE4-N02: renamed from the misspelled `edit_heath.dart`.

///******************** FILE INFO ********************///
/// Purpose: Editable version of health insurance section
/// Author: Assistant
/// Created At: 2025
/// Updated: Editable fields for health insurance information with controllers passed from parent
import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class EditableHealthInsuranceSection extends StatelessWidget {
  // Controllers passed from parent
  final TextEditingController insuranceNameController;
  final TextEditingController insurancePolicyNumberController;

  /// Set to true after the user taps Preview so empty fields show
  /// the "required" error state.
  final bool submitted;

  const EditableHealthInsuranceSection({
    super.key,
    required this.insuranceNameController,
    required this.insurancePolicyNumberController,
    this.submitted = false,
  });

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 0.02.h),
          child: SettingsHeader(
            // 0: same double-padding as the emergency-contact header — the
            // card in edit_page_request_health.dart already applies 15.sp on
            // each side, and SettingsHeader's phone default added another.
            // FIXED 8/9/2026.
            horizontalPadding: 0,
            imagePath: 'assets/icons_assets/main_icons_assets/insurance_document_shield.svg',
            text: S.of(context).insuranceDetails,
          ),
        ),

        SizedBox(height: 15.sp),

        // Insurance Name and Policy Number Row
        isMobile
            ? Column(
          children: [
            CustomTextField(
              label: S.of(context).insuranceName,
              hint: S.of(context).enterInsuranceName,
              controller: insuranceNameController,
              fillColor: AppColors.background,
              enabled: true,
              submitted: submitted,
              required: true,
            ),
            isMobile ? SizedBox(height: 10.sp) : SizedBox(height: 16),
            CustomTextField(
              label: S.of(context).insurancePolicyNumber,
              hint: S.of(context).enterPolicyNumber,
              controller: insurancePolicyNumberController,
              fillColor: AppColors.background,
              enabled: true,
              submitted: submitted,
              required: true,
            ),
          ],
        )
            : Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: S.of(context).insuranceName,
                hint: S.of(context).enterInsuranceName,
                controller: insuranceNameController,
                fillColor: AppColors.background,
                enabled: true,
              submitted: submitted,
              required: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: S.of(context).insurancePolicyNumber,
                hint: S.of(context).enterPolicyNumber,
                controller: insurancePolicyNumberController,
                enabled: true,
              submitted: submitted,
              required: true,
                fillColor: AppColors.background,
              ),
            ),
          ],
        ),
      ],
    );
  }
}