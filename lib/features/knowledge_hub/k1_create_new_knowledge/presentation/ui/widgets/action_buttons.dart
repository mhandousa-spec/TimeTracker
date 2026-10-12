/// Module: knowledge_hub / presentation / s1_create_new_knowledge / widgets/action_buttons.dart
/// ************************* FILE INFO *************************** ///
/// File Name: action_buttons_section.dart
/// Purpose: Widget for action buttons (Discard & Submit)
/// Author: Youssef Khaled
/// Created At: 22/10/2025
/// Updated: 22/9/2026 - The submit label follows KnowledgeHubAccess, and
///          distinguishes creating (Create_Without_Need_Approval) from
///          editing (Edit_Document_Without_Approval).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/helper/knowledge_hub_permissions.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

class ActionButtonsSection extends StatelessWidget {
  final VoidCallback onDiscard;
  final VoidCallback onSubmit;
  final bool isFormComplete;

  /// Whether the page is editing an existing document rather than creating a
  /// new one. ADDED 22/9/2026 — the button label has to name what the tap
  /// does, and creating and editing are now governed by different permissions.
  final bool isEditing;

  const ActionButtonsSection({
    super.key,
    required this.onDiscard,
    required this.onSubmit,
    this.isFormComplete = false,
    this.isEditing = false,
  });

  /// Whether THIS submission skips the approval queue.
  ///
  /// CHANGED 22/9/2026 — this asked `editDocumentWithoutApproval` for both
  /// cases, so on a NEW document the button read "Submit" (publishes directly)
  /// for anyone who could edit without approval, while the document itself is
  /// now correctly queued. Label and outcome have to come from the same
  /// question, so both go through [KnowledgeHubAccess] — the same source
  /// `_getKnowledgeStatus` uses.
  bool _publishesDirectly() {
    try {
      return isEditing
          ? KnowledgeHubAccess.editAccess.publishesDirectly
          : KnowledgeHubAccess.createsWithoutApproval;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;

    // ✅ Check permission
    final bool publishesDirectly = _publishesDirectly();

    // FIXED 28/8/2026 — the "without approval" branch said `save`, so a user who
    // CAN publish without approval saw a button labelled "Save" while the tap
    // actually submitted the document (status `approved`, no supervisor
    // notification — see _getKnowledgeStatus in creating_knowledge_hub.actions).
    // The label now names what the tap does in both branches:
    //   permission ON  → "Submit"              (goes live immediately)
    //   permission OFF → "Submit For Approval" (queued for a supervisor)
    final String submitButtonText = publishesDirectly
        ? S.of(context).submit // Publishes directly, no approval step
        : S.of(context).submit_for_approval; // Requires approval

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
            height: 38.h,
            width: isMobile ? 150.w : 185.w,
            title: S.of(context).discard,
            textStyle: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.white,
            ),
            function: onDiscard,
            color: AppColors.darkGrey,
        ),
        const Spacer(),

        // ✅ Submit button - text changes based on permission
        customButton(
          color:isFormComplete ?  AppColors.primary : AppColors.darkGrey,
          height: 38.h,
          width: isMobile ? 150.w : 185.w,
          textStyle: StyleText.fontSize16Weight500.copyWith(
            color: isFormComplete ? AppColors.textButton : AppColors.colorBlack,
          ),
          title: submitButtonText,  // ✅ Dynamic text
          function: isFormComplete ? onSubmit : () {},
        ),
      ],
    );
  }
}