/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_more_options_panel.dart
/// Purpose: The collapsible "More Options" block under each box on the
///          comments-and-feedback form — seven triage dropdowns and the
///          "Steps to reproduce" field.
/// Author: Knowticed Plus team
/// Created at: 2/9/2026
///
/// Figma: MESBAH 4717:8596. A slate header bar with a chevron, and under it a
/// two-column grid: Module / Screen-Section, Design Issue / Logic Issue,
/// Device / Software Type, then Frequency alone on its own row, then a
/// full-width multi-line "Steps to reproduce" box with a 0/500 counter.
///
/// WHY COLLAPSED BY DEFAULT, AND WHY IT MATTERS. Seven optional dropdowns in
/// front of someone reporting a typo is how a feedback form stops being used.
/// The panel is shut until asked for, every field inside it is optional, and
/// nothing here gates Submit — see `hasAnyData` on the screen, which still
/// only asks for a ticked box with text in it.
///
/// STATELESS ON PURPOSE. The open/closed flag and the answers both live in the
/// screen's State, keyed by [FeedbackKind]. A user can have the bug box's
/// panel open with a Module chosen while the feature-request box's panel is
/// shut and empty, and that is three pieces of per-kind state — putting any of
/// it in here would mean this widget losing it every time the parent rebuilds
/// the list of boxes.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class FeedbackMoreOptionsPanel extends StatelessWidget {
  const FeedbackMoreOptionsPanel({
    super.key,
    required this.details,
    required this.isExpanded,
    required this.onToggle,
    required this.onChanged,
    required this.stepsController,
    required this.isMobile,
    this.enabled = true,
  });

  /// The answers so far for THIS box. Never null — the screen creates an empty
  /// [FeedbackDetails] the first time a box is ticked, so this widget never
  /// has to distinguish "no panel yet" from "panel with nothing in it".
  final FeedbackDetails details;

  /// Whether the body under the header bar is showing.
  final bool isExpanded;

  final VoidCallback onToggle;

  /// Reports the whole [FeedbackDetails] back, not the single field that
  /// changed. Each dropdown below calls `details.copyWith(...)` itself, which
  /// keeps the screen from needing seven callbacks or a stringly-typed
  /// "which field" parameter.
  final ValueChanged<FeedbackDetails> onChanged;

  /// Owned by the screen, like the three body controllers beside it, so it is
  /// created and disposed exactly once per kind rather than on every rebuild.
  ///
  /// Its text is NOT mirrored into [details] on every keystroke — the screen
  /// folds it in at submit time. Rebuilding seven dropdowns for each character
  /// typed is work nobody sees.
  final TextEditingController stepsController;

  /// One column instead of two. The design's two-up grid needs ~530pt to stay
  /// readable, which a phone does not have.
  final bool isMobile;

  /// False while a file is uploading for this box, matching the attach button
  /// and priority field above.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _header(context),
        if (isExpanded) ...<Widget>[
          SizedBox(height: 12.h),
          _body(context),
        ],
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  /// The slate bar. [AppColors.navyBlue] is `#768396` in BOTH themes — one of
  /// the few colours in the palette that does not flip — which is why the
  /// label and chevron on it can be a flat white rather than a theme lookup.
  Widget _header(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: double.infinity,
        height: 30.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                S.of(context).moreOptions,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: Colors.white),
              ),
            ),
            AnimatedRotation(
              // Same 0.5 turn and 180ms CustomDropdown gives its own chevron,
              // so the two controls on this form animate identically.
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: CustomSvgImage(
                assetPath:
                    'assets/icons_assets/main_icons_assets/chevron_down.svg',
                width: 18.sp,
                height: 18.sp,
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _pair(
          _moduleField(context),
          _screenSectionField(context),
        ),
        SizedBox(height: 15.sp),
        _pair(
          _designIssueField(context),
          _logicIssueField(context),
        ),
        SizedBox(height: 15.sp),
        _pair(
          _deviceField(context),
          _softwareTypeField(context),
        ),
        SizedBox(height: 15.sp),
        _pair(_frequencyField(context), null),
        SizedBox(height: 15.sp),
        _stepsField(context),
      ],
    );
  }

  /// Function Name: [_pair]
  ///
  /// Purpose: Two fields side by side on tablet, stacked on a phone.
  ///
  /// Parameters:
  /// - [left], [right]: [right] may be null for a half-width row.
  ///
  /// `Expanded` on both halves rather than a fixed width: this panel sits
  /// inside the settings pane, whose width changes with the split, and a
  /// hardcoded 265 from the design would clip the moment the pane narrowed.
  Widget _pair(Widget left, Widget? right) {
    if (isMobile) {
      if (right == null) return left;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          left,
          SizedBox(height: 12.h),
          right,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: left),
        SizedBox(width: 15.w),
        // A SizedBox.shrink() inside an Expanded, not a missing child: the
        // left column must stay half-width on the Frequency row.
        Expanded(child: right ?? const SizedBox.shrink()),
      ],
    );
  }

  /// Every dropdown on this panel, built the same way.
  ///
  /// The 36 height, the [AppColors.background] fill and the label/hint type
  /// scale all match [FeedbackPriorityDropdown] directly above the panel —
  /// they are the same control in the same form and must not disagree.
  ///
  /// `height: 36` is RAW, not `.sp`. [CustomDropdown.height] documents itself
  /// as being interpreted in `.sp` and scaled internally; pre-scaling here
  /// would scale it twice.
  ///
  /// TAP-TO-CLEAR, added 8/9/2026. Choosing the item that is already selected
  /// clears the field instead of re-selecting it. Every field in this panel is
  /// optional, and until now there was no way to take an answer back short of
  /// unticking the whole box and losing everything else with it.
  ///
  /// [CustomDropdown.onChanged] is `ValueChanged<T>` and can only ever report
  /// a CHOSEN item, so the comparison has to happen here on the way out — and
  /// [onSelected] is `ValueChanged<T?>` for the same reason.
  Widget _dropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<DropdownItem<T>> items,
    required ValueChanged<T?> onSelected,
  }) {
    return CustomDropdown<T>(
      label: label,
      hint: hint,
      value: value,
      items: items,
      enabled: enabled,
      // NO triggerPadding — FIXED 8/9/2026.
      //
      // It was `EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp)`.
      // 12 + 12 of vertical padding plus a 14pt line needs more than the 36.sp
      // the trigger is pinned to, so InputDecorator laid the value out below
      // the visible box: the SELECTED text was clipped along its bottom and sat
      // off-centre, while the hint (12pt) still fit and looked fine — which is
      // why only chosen values looked broken.
      //
      // Dropping it falls back to CustomDropdown's own 12.sp/10.sp, which is
      // exactly what FeedbackPriorityDropdown above uses at the same 36 height,
      // so the value now centres in the box and the two controls match.
      fillColor: AppColors.background,
      height: 36,
      // Matches FeedbackPriorityDropdown directly above the panel — see the
      // note there. These are the same control in the same form.
      labelGap: 3,
      onChanged: (T chosen) => onSelected(chosen == value ? null : chosen),
    );
  }

  Widget _moduleField(BuildContext context) {
    return _dropdown<FeedbackModule>(
      label: S.of(context).module,
      hint: S.of(context).selectModule,
      value: details.module,
      onSelected: (FeedbackModule? value) =>
          onChanged(details.copyWith(module: () => value)),
      items: <DropdownItem<FeedbackModule>>[
        for (final FeedbackModule value in FeedbackModule.values)
          DropdownItem<FeedbackModule>(
            value: value,
            label: FeedbackDisplay.moduleLabel(context, value),
          ),
      ],
    );
  }

  Widget _screenSectionField(BuildContext context) {
    return _dropdown<FeedbackScreenSection>(
      label: S.of(context).screenSection,
      hint: S.of(context).selectScreenSection,
      value: details.screenSection,
      onSelected: (FeedbackScreenSection? value) =>
          onChanged(details.copyWith(screenSection: () => value)),
      items: <DropdownItem<FeedbackScreenSection>>[
        for (final FeedbackScreenSection value in FeedbackScreenSection.values)
          DropdownItem<FeedbackScreenSection>(
            value: value,
            label: FeedbackDisplay.screenSectionLabel(context, value),
          ),
      ],
    );
  }

  Widget _designIssueField(BuildContext context) {
    return _dropdown<FeedbackDesignIssue>(
      label: S.of(context).designIssue,
      hint: S.of(context).selectDesignIssue,
      value: details.designIssue,
      onSelected: (FeedbackDesignIssue? value) =>
          onChanged(details.copyWith(designIssue: () => value)),
      items: <DropdownItem<FeedbackDesignIssue>>[
        for (final FeedbackDesignIssue value in FeedbackDesignIssue.values)
          DropdownItem<FeedbackDesignIssue>(
            value: value,
            label: FeedbackDisplay.designIssueLabel(context, value),
          ),
      ],
    );
  }

  Widget _logicIssueField(BuildContext context) {
    return _dropdown<FeedbackLogicIssue>(
      label: S.of(context).logicIssue,
      hint: S.of(context).selectLogicIssue,
      value: details.logicIssue,
      onSelected: (FeedbackLogicIssue? value) =>
          onChanged(details.copyWith(logicIssue: () => value)),
      items: <DropdownItem<FeedbackLogicIssue>>[
        for (final FeedbackLogicIssue value in FeedbackLogicIssue.values)
          DropdownItem<FeedbackLogicIssue>(
            value: value,
            label: FeedbackDisplay.logicIssueLabel(context, value),
          ),
      ],
    );
  }

  Widget _deviceField(BuildContext context) {
    return _dropdown<FeedbackDevice>(
      label: S.of(context).device,
      hint: S.of(context).selectDevice,
      value: details.device,
      onSelected: (FeedbackDevice? value) =>
          onChanged(details.copyWith(device: () => value)),
      items: <DropdownItem<FeedbackDevice>>[
        for (final FeedbackDevice value in FeedbackDevice.values)
          DropdownItem<FeedbackDevice>(
            value: value,
            label: FeedbackDisplay.deviceLabel(context, value),
          ),
      ],
    );
  }

  Widget _softwareTypeField(BuildContext context) {
    return _dropdown<FeedbackSoftwareType>(
      label: S.of(context).softwareType,
      hint: S.of(context).selectSoftwareType,
      value: details.softwareType,
      onSelected: (FeedbackSoftwareType? value) =>
          onChanged(details.copyWith(softwareType: () => value)),
      items: <DropdownItem<FeedbackSoftwareType>>[
        for (final FeedbackSoftwareType value in FeedbackSoftwareType.values)
          DropdownItem<FeedbackSoftwareType>(
            value: value,
            label: FeedbackDisplay.softwareTypeLabel(context, value),
          ),
      ],
    );
  }

  Widget _frequencyField(BuildContext context) {
    return _dropdown<FeedbackFrequency>(
      label: S.of(context).frequency,
      hint: S.of(context).selectFrequency,
      value: details.frequency,
      onSelected: (FeedbackFrequency? value) =>
          onChanged(details.copyWith(frequency: () => value)),
      items: <DropdownItem<FeedbackFrequency>>[
        for (final FeedbackFrequency value in FeedbackFrequency.values)
          DropdownItem<FeedbackFrequency>(
            value: value,
            label: FeedbackDisplay.frequencyLabel(context, value),
          ),
      ],
    );
  }

  /// The full-width box at the bottom of the panel.
  ///
  /// [FeedbackDetails.maxStepsLength] rather than a literal 500, so the
  /// counter under this field and anything that validates the value later
  /// cannot disagree about the ceiling.
  ///
  /// No `showCharCount` — [CustomTextField] draws the counter whenever either
  /// that flag OR a [CustomTextField.maxLength] is set, and passing both would
  /// suggest they do different things.
  Widget _stepsField(BuildContext context) {
    return CustomTextField(
      label: S.of(context).stepsToReproduce,
      hint: S.of(context).describeTheStepsYouTook,
      controller: stepsController,
      enabled: enabled,
      maxLines: 3,
      maxLength: FeedbackDetails.maxStepsLength,
      fillColor: AppColors.background,
    );
  }
}
