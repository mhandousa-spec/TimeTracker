// ***************************** FILE INFO ***************************** //
// File Name: employee_details_field.dart
// Purpose: Renders one read-only employee detail label and value.
// Author: Mohamed Elrashidy
// Created At: 2026-08-17
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/32-custom_svg.dart';
import '../../../../../../core/custom/16-custom_card_styles.dart';
import '../../../../../../core/helper/main_helper/format_title.dart';
import '../../../utils/employee_details_display_values.dart';

/// Displays an icon followed by a localized label and read-only value.
class EmployeeDetailsField extends StatelessWidget {
  const EmployeeDetailsField({
    required this.iconAsset,
    required this.label,
    this.value,
    this.valueWidget,
    this.allowWrap = false,
    super.key,
  });

  final String iconAsset;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool allowWrap;

  /// Method Name: [_displayValue]
  ///
  /// Purpose: Resolves empty storage values to one localized display value.
  ///
  /// Returns: The trimmed value or the localized unavailable label.
  String _displayValue() {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty
        ? EmployeeDetailsDisplayValues.unavailable
        : FormatHelper.capitalize(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final textValue = _displayValue();
    return Row(
      crossAxisAlignment:
          allowWrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        CustomSvgImage(
          assetPath: iconAsset,
          height: 18.sp,
          width: 18.sp,
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: valueWidget == null
              ? Text.rich(
                  TextSpan(
                    text: '$label: ',
                    style: CardStyles.label(14),
                    children: [
                      TextSpan(text: textValue, style: CardStyles.value(14))
                    ],
                  ),
                  maxLines: allowWrap ? null : 1,
                  overflow:
                      allowWrap ? TextOverflow.visible : TextOverflow.ellipsis,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$label: ', style: CardStyles.label(14)),
                    Expanded(child: valueWidget!),
                  ],
                ),
        ),
      ],
    );
  }
}
