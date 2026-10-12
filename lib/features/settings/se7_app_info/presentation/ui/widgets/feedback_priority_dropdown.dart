/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_priority_dropdown.dart
/// Purpose: The "Select Priority" field under each box on the comments and
///          feedback form.
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
/// Updated: 1/9/2026 - Rebuilt on [CustomDropdown]. It was a hand-rolled
///          PopupMenuButton, which meant a second idea about placeholder
///          colour, label size and chevron in a codebase that already has one.
///
/// Figma: MESBAH 7628:8169 — a 265×36 field with a chevron, sitting beside the
/// "Attach Document" button.
///
/// The label, the 14.sp-label / 12.sp-hint type scale and the placeholder
/// colour all come from [CustomDropdown]; nothing is restated here. Only two
/// things are passed that are specific to this screen: the [AppColors.card]
/// fill and the 36 height the design draws.
///
/// NOTE the clear path. [CustomDropdown.onChanged] is `ValueChanged<T>`, so it
/// can only ever report a CHOSEN value — there is no "none" entry, and none is
/// wanted: priority is optional, the field starts empty, and the way to clear
/// it is to untick the box, which drops the whole entry in the screen's
/// `_priorities` map.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class FeedbackPriorityDropdown extends StatelessWidget {
  const FeedbackPriorityDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  /// Null while the user has not chosen — the "Select Priority" placeholder
  /// state. [CustomDropdown] draws the hint whenever no item matches.
  final FeedbackPriority? value;

  final ValueChanged<FeedbackPriority> onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<FeedbackPriority>(
      label: S.of(context).priority,
      hint: S.of(context).selectpriority,
      value: value,
      enabled: enabled,
      fillColor: AppColors.background,
      // Raw, not `.sp` — CustomDropdown.height is documented as being
      // interpreted in .sp and scaled internally. Pre-scaling it here would
      // scale it twice.
      height: 36,
      // ADDED 8/9/2026 — tighter than the shared kFieldLabelGap (6) for this
      // form, where the label and its field read as one unit stacked under a
      // checkbox rather than as a row of aligned fields. Same value is passed
      // by the More Options dropdowns below, so the whole form agrees.
      labelGap: 3,
      onChanged: onChanged,
      items: <DropdownItem<FeedbackPriority>>[
        for (final FeedbackPriority priority in FeedbackPriority.values)
          DropdownItem<FeedbackPriority>(
            value: priority,
            label: FeedbackDisplay.priorityLabel(context, priority),
          ),
      ],
    );
  }
}
