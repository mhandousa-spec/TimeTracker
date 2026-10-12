/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_title_value_widget.dart
/// Purpose: Declares `CustomTitleValueWidget`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Renders a `Title: value` pair on one line.
///
/// [titleStyle] / [valueStyle] are *merged over* the defaults, so a caller can
/// override just the font size and still inherit the default colours.
/// (These parameters used to be accepted and then silently ignored, which made
/// every call site render at fontSize14 regardless of what it asked for and
/// overflowed the fixed-height cards that use it.)
class CustomTitleValueWidget extends StatelessWidget {
  const CustomTitleValueWidget({
    required this.title,
    required this.value,
    this.titleStyle,
    this.valueStyle,
    super.key,
  });

  final String title;
  final String value;
  final TextStyle? titleStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final baseTitle = StyleText.fontSize14Weight500.copyWith(
      color: AppColors.secondaryText,
    );
    final baseValue = StyleText.fontSize14Weight500.copyWith(
      color: AppColors.text,
    );

    // A single Text.rich rather than a Row of two Texts: it ellipsizes when the
    // parent is narrow, lays out naturally when width is unbounded, and still
    // reports intrinsic dimensions (so it is safe inside IntrinsicWidth and
    // horizontal ListViews). A Row with Flexible children would throw in any
    // unbounded-width parent.
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: title, style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.secondaryText
          )),
          TextSpan(text: value, style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.text
          )),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
