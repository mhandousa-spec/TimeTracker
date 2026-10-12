/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_tabs.dart
/// Purpose: Declares `CustomTabs`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Reusable underlined text tabs (extracted from RoleScreen).
// Horizontal scrollable row of tab titles; the selected tab is tinted
// with the primary color and underlined (1.5 high line).
//
// Supports an optional [values] list so callers can keep their own
// underlying indices (e.g. permission-filtered tab ids) while only the
// visible tabs are rendered.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// ```dart
/// CustomTabs(
///   tabs: const ['Role Management', 'User Management', 'User Access'],
///   selectedValue: selectedIndex,
///   onChanged: (v) => setState(() => selectedIndex = v),
///   // optional: underlying ids when some tabs are hidden
///   // values: visibleTabIndices,
/// )
/// ```
class CustomTabs extends StatelessWidget {
  /// Visible tab titles (already translated).
  final List<String> tabs;

  /// Underlying value of each tab. Defaults to `[0..tabs.length-1]`.
  /// Must have the same length as [tabs].
  final List<int>? values;

  /// Currently selected value (compared against [values]).
  final int selectedValue;

  /// Called with the tapped tab's value (only when it changes).
  final ValueChanged<int> onChanged;

  /// Gap between tabs. Default 32.sp (Figma).
  final double? spacing;

  final TextStyle? textStyle;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomTabs({
    super.key,
    required this.tabs,
    required this.selectedValue,
    required this.onChanged,
    this.values,
    this.spacing,
    this.textStyle,
    this.selectedColor,
    this.unselectedColor,
  }) : assert(values == null || values.length == tabs.length,
            'values must match tabs length');

  @override
  Widget build(BuildContext context) {
    final List<int> tabValues =
        values ?? List<int>.generate(tabs.length, (i) => i);
    final TextStyle baseStyle = textStyle ??
        (context.isPhone
            ? StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack)
            : StyleText.fontSize20Weight500.copyWith(color: AppColors.secondaryBlack));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++) ...[
            if (i > 0) SizedBox(width: spacing ?? 32.sp),
            GestureDetector(
              onTap: () {
                if (selectedValue != tabValues[i]) onChanged(tabValues[i]);
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      tabs[i],
                      style: baseStyle.copyWith(
                        height: 1.3,
                        color: selectedValue == tabValues[i]
                            ? (selectedColor ?? AppColors.primary)
                            : (unselectedColor ?? AppColors.secondaryBlack),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      height: 1.5.sp,
                      color: selectedValue == tabValues[i]
                          ? (selectedColor ?? AppColors.primary)
                          : AppColors.transparent,
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
}
