// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_cell.dart
// Purpose: Renders a reference-styled editable spreadsheet cell and warning.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../../../../../core/theme/app_colors.dart';

import '../../../../../../../generated/l10n.dart';
import '../../../utils/constants/employee_bulk_upload_headers.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Editable spreadsheet cell matching the supplied service upload table.
class EmployeeBulkUploadCell extends StatefulWidget {
  const EmployeeBulkUploadCell({
    required this.header,
    required this.value,
    required this.error,
    required this.focused,
    required this.onChanged,
    super.key,
  });

  final String header;
  final String value;
  final String? error;
  final bool focused;
  final ValueChanged<String> onChanged;

  @override
  State<EmployeeBulkUploadCell> createState() => _EmployeeBulkUploadCellState();
}

class _EmployeeBulkUploadCellState extends State<EmployeeBulkUploadCell> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    if (widget.focused) _requestFocus();
  }

  @override
  void didUpdateWidget(covariant EmployeeBulkUploadCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
    if (widget.focused && !oldWidget.focused) _requestFocus();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.header == EmployeeBulkUploadHeaders.number;
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(widget.header);
    return SizedBox(
      width: 250.sp,
      child: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36.sp,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: readOnly,
                  keyboardType: _keyboardType(widget.header),
                  inputFormatters: _inputFormatters(widget.header),
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: readOnly ? AppColors.grey : AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.header,
                    hintStyle: StyleText.fontSize14Weight400.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.mediumGrey,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.sp,
                      vertical: 5.sp,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: widget.focused
                            ? AppColors.primary
                            : AppColors.transparent,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: readOnly ? null : widget.onChanged,
                ),
              ),
            ),
            if (widget.error != null) SizedBox(width: 8.sp),
            if (widget.error != null)
              GestureDetector(
                onTap: () => _showError(context),
                child: SizedBox(
                  width: 20.sp,
                  height: 36.sp,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg',
                      width: 20.sp,
                      height: 20.sp,
                      colorFilter: ColorFilter.mode(
                        AppColors.red,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context) {
    final localization = S.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(
          vertical: 24.sp,
          horizontal: 16.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        content: SizedBox(
          width: 410.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/warning.json',
                width: 70.sp,
                height: 70.sp,
              ),
              SizedBox(height: 16.sp),
              Text(
                '${localization.warning} ${widget.header}',
                style: StyleText.fontSize20Weight600.copyWith(
                  color: AppColors.text,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              Text(
                widget.error!,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.mediumGrey,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextInputType _keyboardType(String header) {
    if (header == EmployeeBulkUploadHeaders.email ||
        header == EmployeeBulkUploadHeaders.supervisor) {
      return TextInputType.emailAddress;
    }
    if (header == EmployeeBulkUploadHeaders.mobilePhone ||
        header == EmployeeBulkUploadHeaders.homeNumber ||
        header == EmployeeBulkUploadHeaders.officeNumber) {
      return TextInputType.phone;
    }
    if (header == EmployeeBulkUploadHeaders.nationalId ||
        header == EmployeeBulkUploadHeaders.extension ||
        header == EmployeeBulkUploadHeaders.departmentId) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }

  List<TextInputFormatter>? _inputFormatters(String header) {
    if (header == EmployeeBulkUploadHeaders.email ||
        header == EmployeeBulkUploadHeaders.supervisor) {
      return [FilteringTextInputFormatter.deny(RegExp(r'\s'))];
    }
    return null;
  }
}
