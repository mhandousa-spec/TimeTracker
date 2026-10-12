/// Module: roles / r4_active_directory / presentation / ui / widgets / user_data_widgets
///
///*************************** FILE INFO ****************************///
/// File Name: text_widget.dart
/// Purpose: Declares `UserText`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/fields/default_csv_field.dart';

/// A table cell widget that switches between a plain [Text] (read mode)
/// and an inline [TextField] (edit mode).
///
/// ── HEIGHT ALIGNMENT FIX ──────────────────────────────────────────────────
/// The original widget wrapped the editable field in a `Container` with
/// `height: 38.h`, making editing rows taller than read-only rows.
/// Flutter's DataTable sets row height from the tallest cell, so ONE tall
/// cell caused the entire edited row to shift, misaligning it with the
/// column headers above.
///
/// Fix:
///  • Both modes now share the exact same visual height — controlled by
///    [_kCellHeight]. The text field's `contentPadding` is tuned so the
///    cursor sits in the middle without adding extra vertical space.
///  • The outer [SizedBox] with a fixed height is the single source of
///    truth for this widget's vertical footprint.
///  • `isDense: true` + zero `contentPadding` on the inner TextField keeps
///    the field from adding any extra intrinsic height.
// ---------------------------------------------------------------------------

// Must match DefaultDataTable's dataRowMinHeight/dataRowMaxHeight (46.h).
// Both read and edit states wrap their content in SizedBox(height: _kCellHeight.h)
// so the DataRow height never changes when toggling edit mode.
const double _kCellHeight = 38;

class UserText extends StatefulWidget {
  final String text;
  final bool isEditable;
  final bool useingInfo;
  final TextStyle? style;
  final String? Function(String?)? validator;
  final String? Function(String?)? titleValidator;
  final Function(String)? onChanged;
  final Color? fillColor;

  const UserText({
    Key? key,
    required this.text,
    required this.isEditable,
    required this.onChanged,
    this.useingInfo = true,
    this.style,
    this.validator,
    this.titleValidator,
    this.fillColor,
  }) : super(key: key);

  @override
  _UserTextState createState() => _UserTextState();
}

class _UserTextState extends State<UserText> {
  late TextEditingController _controller;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _controller.addListener(() {
      final error =
          widget.validator != null && widget.validator!(_controller.text) != null;
      if (error != hasError) {
        setState(() => hasError = error);
      }
    });
  }

  @override
  void didUpdateWidget(UserText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller text when the cell exits edit mode so the plain-text
    // label reflects any changes that were saved.
    if (!widget.isEditable && oldWidget.isEditable) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    final Color backgroundColor = widget.fillColor ??
        (lightMode ? AppColors.evenRowColor : AppColors.oddRowColor);

    // Fixed height for both modes — this is the key to alignment.
    final double cellH = _kCellHeight.h;

    if (widget.isEditable) {
      // ── EDIT MODE ────────────────────────────────────────────────────────
      // Use a SizedBox with the same height as the read-mode text so the
      // DataRow height never changes when a cell enters/exits edit mode.
      return Padding(
        padding:  EdgeInsets.symmetric(vertical: 6.h),
        child: SizedBox(
          height: cellH,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: ColoredBox(
              color: backgroundColor,
              child: DefaultCsvField(
                onChanged: (value) => widget.onChanged?.call(value),
                titleValidator: widget.titleValidator,
                validator: widget.validator,
                controller: _controller,
                contentPadding: EdgeInsetsDirectional.symmetric(
                  horizontal: 8.w,
                  vertical: 6.h,
                ),
                maxLength: 50,
                showCounter: false,
                removeBorder: true,
                fillColor: backgroundColor,
                filled: true,
                borderRadius: 6.r,
                // Pass the explicit height so DefaultCsvField (if it uses one)
                // also respects our cell height.
                height: cellH,
              ),
            ),
          ),
        ),
      );
    }

    // ── READ MODE ──────────────────────────────────────────────────────────
    // Wrap in the same SizedBox height so the DataRow never reflowed.
    return SizedBox(
      height: cellH,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          widget.text.isEmpty ? '-' : widget.text,
          style: widget.style ??
              StyleText.fontSize16Weight600.copyWith(
                color: lightMode ? AppColors.black : AppColors.white,
              ),
          maxLines: 1,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}