// ******************* FILE INFO *******************
// File Name: services_multi_select
// Description: Services multi select.
// Module: services_management_module / data/helper
// *************************************************

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';

/// Module-local wrapper that preserves the `AppMultiSelectDropdown` call-site
/// API used in the services module, while rendering the core
/// [CustomMultiSelectDropdown] (lib/core/custom/3-custom_dropdown_multiselect.dart).
///
/// The core widget reports the FULL selection via onChanged(List<String>);
/// the existing call sites expect the single toggled value, so we diff against
/// the previous selection and forward just the changed item. Bundled so the
/// module stays self-contained and portable.
class AppMultiSelectDropdown extends StatelessWidget {
  final List<String> selectedItems;
  final List<String> items;
  final Map<String, String>? itemLabelMap;
  final String? textButton;
  final String? hintText;
  final void Function(dynamic)? onChanged;
  final double? width;
  final double? height;
  final Color? fillColor;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;
  final TextDirection? forceDirection;

  const AppMultiSelectDropdown({
    super.key,
    this.selectedItems = const [],
    this.items = const [],
    this.itemLabelMap,
    this.textButton,
    this.hintText,
    this.onChanged,
    this.width,
    this.height,
    this.fillColor,
    this.color,
    this.textColor,
    this.textStyle,
    this.forceDirection,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownItems = items
        .map((k) => MultiSelectDropdownItem<String>(
              value: k,
              label: itemLabelMap?[k] ?? k,
            ))
        .toList();

    final TextStyle? valueStyle = textColor != null
        ? (textStyle ?? const TextStyle()).copyWith(color: textColor)
        : textStyle;

    Widget dropdown = CustomMultiSelectDropdown<String>(
      items: dropdownItems,
      values: selectedItems,
      hint: hintText,
      fillColor: fillColor ?? color,
      valueStyle: valueStyle,
      hintStyle: textStyle,
      selectedTextBuilder:
          textButton != null ? (selected) => textButton! : null,
      onChanged: (newValues) {
        // Forward only the single toggled item, matching the old API.
        final added = newValues.where((e) => !selectedItems.contains(e));
        final removed = selectedItems.where((e) => !newValues.contains(e));
        final changed =
            added.isNotEmpty ? added.first : (removed.isNotEmpty ? removed.first : null);
        if (changed != null) onChanged?.call(changed);
      },
    );

    if (width != null) {
      dropdown = SizedBox(width: width, child: dropdown);
    }
    if (forceDirection != null) {
      dropdown = Directionality(textDirection: forceDirection!, child: dropdown);
    }
    return dropdown;
  }
}
