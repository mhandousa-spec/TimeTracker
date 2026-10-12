import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/49-custom_view_multi_select_dropdown.dart';

class MultiDropDownWidget extends StatelessWidget {
  /// The title of the dropdown field
  final String title;

  /// The hint text displayed when no value is selected
  final String hint;

  /// The currently selected value
  final String? currentValue;

  /// Callback function triggered when the value changes
  final dynamic Function(dynamic) onChanged;

  /// List of dropdown menu items
  final List<String> items;
  final List<String> selectedItems;

  /// Validator function for validating the selected value
  final String? Function(dynamic)? validator;

  /// Path to the SVG icon displayed in the dropdown
  final String? svgIconPath;

  /// Text style for the dropdown text
  final TextStyle? textStyle;

  final Color? fillColor;
  final bool isReadOnly;

  /// Constructor for initializing the DropDownWidget instance
  MultiDropDownWidget({
    super.key,
    required this.title,
    required this.hint,
    required this.items,
    required this.currentValue,
    required this.onChanged,
    required this.selectedItems,
    this.validator,
    this.svgIconPath,
    this.textStyle,
    this.fillColor,
    this.isReadOnly = false,
  });
  bool isShowError = false;
  String? errorText;
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: StyleText.fontSize14Weight400),
            verticalSpace(8),
            // Dropdown field
            SizedBox(
              height: 36,
              child: AppMultiSelectDropdownMaster(
                selectedItems: selectedItems,
                showErrorBorder: isShowError,
                value: currentValue,
                width: double.infinity,
                svgIconPath: svgIconPath,
                fillColor: fillColor ?? AppColors.background,
                textStyle: textStyle,
                textButton: currentValue ?? hint,
                items: items,
                onChanged: isReadOnly ? (v) {} : onChanged,
                validator: (value) {
                  var flag = validator?.call(value);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      isShowError = flag != null;
                      errorText = flag;
                    });
                  });
                  return null;
                },
              ),
            ),
            if (isShowError && errorText != null) ...[
              verticalSpace(4),
              Text(errorText!, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.red)),
            ],
          ],
        );
      },
    );
  }
}
