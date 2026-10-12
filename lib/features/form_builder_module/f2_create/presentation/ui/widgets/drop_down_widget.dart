/// Module: form_builder_module / f2_create
///
///*************************** FILE INFO ****************************///
/// File Name: drop_down_widget.dart
/// Purpose: The Form Builder's dropdown field.
/// Author: Knowticed Plus team
/// Rewritten: 19/8/2026 — moved from AppDropdown onto CustomDropdown.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// ── Figma spec: MESBAH / node 7444-41775 (field dropdown, e.g. 7444-41905) ──
///
///   trigger box      254 × 36    (a 38-tall variant exists; 36 is the form one)
///   content inset    x 8,  y 6
///   leading icon     16 × 16, at x 0 of the content, centred on the 24 label
///   icon → label     8
///   label            starts x 24, 24 tall
///   chevron          24 × 24, right-aligned
///
/// The two icon numbers are why this file was rewritten. Under `AppDropdown`
/// they came from two unrelated places and neither was 16:
///
///   * the TRIGGER icon was `AppDropdown._buildIconDropdown()`, hardcoded
///     `width: 14.w, height: 6.h, fit: BoxFit.fill` — six logical pixels tall
///     and stretched, which is the "very small" prefix in the bug report;
///   * the MENU icons were built by `FieldTypeExtension.dropDownItems` with NO
///     width or height at all, so each SVG drew at its own intrinsic size
///     inside an unbounded Row — the "very big" ones.
///
/// Both now come from [kLeadingIconSize], so they cannot drift apart again.
const double kDropdownTriggerHeight = 36;
const double kLeadingIconSize = 16;

/// A labelled dropdown field.
///
/// WHY CustomDropdown AND NOT AppDropdown (19/8/2026): `CustomTextField`'s own
/// header says it "mirrors CustomDropdown API exactly", and every field on
/// these screens sits next to a `CustomTextField`. Running the dropdowns on
/// `AppDropdown` meant the two halves of one form disagreed about label size,
/// hint size, error rendering and trigger height. `CustomDropdown` also gives
/// per-item `leading`, which is what makes a single icon size possible.
class DropDownWidget extends StatelessWidget {
  /// The title of the dropdown field.
  final String title;

  /// The hint text displayed when no value is selected.
  final String hint;

  /// The currently selected value.
  final String? currentValue;

  /// Callback triggered when the value changes.
  final dynamic Function(dynamic) onChanged;

  /// Menu items.
  ///
  /// Still `DropdownMenuItem`, so no caller had to change. Every enum in
  /// `f2_create/domain/enums` builds these as `value: element.name` with a
  /// `Text(element.name)` child, so the VALUE already is the label — which is
  /// why [_toCustomItems] can rebuild them for `CustomDropdown` without
  /// reaching into the child widget.
  final List<DropdownMenuItem<dynamic>> items;

  /// Validator for the selected value.
  final String? Function(dynamic)? validator;

  /// SVG shown at the start of the TRIGGER.
  final String? svgIconPath;

  /// SVG shown at the start of each MENU ITEM, chosen per value.
  ///
  /// ADDED 19/8/2026. The field-type dropdown is the only one with per-item
  /// icons, and they used to be baked into the `DropdownMenuItem` children at
  /// their intrinsic size. Passing a builder instead keeps the sizing here,
  /// next to the trigger icon it has to match.
  final String? Function(String value)? leadingIconForValue;

  final TextStyle? textStyle;
  final Color? fillColor;
  final bool isReadOnly;

  const DropDownWidget({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.currentValue,
    required this.onChanged,
    this.validator,
    this.svgIconPath,
    this.leadingIconForValue,
    this.textStyle,
    this.fillColor,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    // FormField, not CustomDropdown alone: `formKey.currentState.validate()`
    // on publish has to keep working, and CustomDropdown is a plain
    // StatefulWidget rather than a FormField. This wrapper puts it back in the
    // Form and feeds the result to CustomDropdown's own `errorText`, so the
    // message renders in the widget's standard slot instead of the hand-rolled
    // `Text` the old implementation appended underneath.
    return FormField<String>(
      initialValue: currentValue,
      validator: (_) => validator?.call(currentValue),
      builder: (field) {
        return CustomDropdown<String>(
          label: title,
          hint: hint,
          value: currentValue,
          // Raw 36, not 36.sp — CustomDropdown.height documents that it scales
          // the value itself, exactly like CustomTextField.height does.
          height: kDropdownTriggerHeight,
          enabled: !isReadOnly,
          fillColor: fillColor ?? AppColors.background,
          errorText: field.errorText,
          valueStyle: textStyle,
          itemStyle: textStyle,
          // FIXED 19/8/2026 — "have duplicate in all svg item dropdown".
          //
          // My own regression from the CustomDropdown migration. Unlike
          // AppDropdown, CustomDropdown ALREADY draws the selected item's
          // `leading` on the trigger (see its build, `shownItem.leading`), so
          // passing `prefixIcon` as well rendered the glyph twice: "☎ ☎ Phone".
          //
          // Where the caller supplies per-item icons, the item's own leading is
          // also the better source — it follows the selection for free, whereas
          // `svgIconPath` is a snapshot the caller has to keep in step.
          prefixIcon:
              leadingIconForValue == null ? _buildIcon(svgIconPath) : null,
          items: _toCustomItems(),
          onChanged: (value) {
            field.didChange(value);
            hapticController.triggerHapticFeedback(
              vibration: VibrateType.lightImpact,
              hapticFeedback: HapticFeedback.lightImpact,
            );
            onChanged(value);
          },
        );
      },
    );
  }

  /// ONE icon builder for both the trigger and the menu rows — see the note at
  /// the top of the file for what happened when there were two.
  Widget? _buildIcon(String? assetPath) {
    if (assetPath == null || assetPath.isEmpty) return null;

    return SvgPicture.asset(
      assetPath,
      width: kLeadingIconSize.sp,
      height: kLeadingIconSize.sp,
      // contain, never `fill`: these glyphs are not all square, and `fill` is
      // what squashed the trigger icon into a 14 × 6 smear.
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
    );
  }

  /// Rebuilds the caller's `DropdownMenuItem`s as `CustomDropdown` items.
  ///
  /// Reads the LABEL off `item.value` rather than the child widget. That holds
  /// because every enum in this module writes `value: element.name` and renders
  /// that same string — if a future dropdown breaks the pairing, this is the
  /// line that will need a real label field instead.
  List<DropdownItem<String>> _toCustomItems() {
    return items.where((item) => item.value != null).map((item) {
      final value = item.value.toString();
      // Bug report #4: the menu showed the raw VALUE (department ids "1",
      // "10", "2"…) and ignored the item's own Text. Use the Text's string
      // when the caller supplied one; fall back to the value.
      final Widget child = item.child;
      final String label =
          (child is Text && (child.data?.isNotEmpty ?? false))
              ? child.data!
              : value;
      return DropdownItem<String>(
        value: value,
        label: label,
        leading: _buildIcon(leadingIconForValue?.call(value)),
      );
    }).toList();
  }
}
