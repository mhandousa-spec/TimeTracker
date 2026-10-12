// ***************************** FILE INFO ***************************** //
// File Name: hr_bulk_upload_workbook.dart
// Purpose: Renders the shared Employee-style workbook surface for HR uploads.
// Author: Mohamed Elrashidy
// Created At: 2026-08-23
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../../../../../core/theme/app_colors.dart';

import '../../../../../generated/l10n.dart';
import 'bulk_upload_template.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays an editable, validated workbook using the Employee upload layout.
class HrBulkUploadWorkbook extends StatelessWidget {
  const HrBulkUploadWorkbook({
    required this.file,
    required this.template,
    required this.focusedErrorIndex,
    required this.selectedRows,
    required this.canSubmit,
    required this.submitting,
    required this.onPreviousError,
    required this.onNextError,
    required this.onAdd,
    required this.onDuplicate,
    required this.onRemove,
    required this.onToggleRow,
    required this.onChanged,
    required this.onDiscard,
    required this.onSubmit,
    this.showRowActions = true,
    super.key,
  });

  final BulkUploadFile file;
  final BulkUploadTemplate template;
  final int focusedErrorIndex;
  final Set<int> selectedRows;
  final bool canSubmit;
  final bool submitting;
  final VoidCallback onPreviousError;
  final VoidCallback onNextError;
  final VoidCallback onAdd;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;
  final ValueChanged<int> onToggleRow;
  final void Function(int rowIndex, String header, String value) onChanged;
  final VoidCallback onDiscard;
  final Future<void> Function() onSubmit;
  final bool showRowActions;

  @override
  Widget build(BuildContext context) {
    final errorCount = file.errors.length;
    final currentError = errorCount == 0
        ? 0
        : focusedErrorIndex < 0
            ? 1
            : focusedErrorIndex + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          file.fileName,
          style: StyleText.fontSize23Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 23.sp),
        _Toolbar(
          errorCount: errorCount,
          currentError: currentError,
          hasSelection: selectedRows.isNotEmpty,
          canDuplicate: selectedRows.length == 1,
          showRowActions: showRowActions,
          onPreviousError: onPreviousError,
          onNextError: onNextError,
          onAdd: onAdd,
          onDuplicate: onDuplicate,
          onRemove: onRemove,
        ),
        SizedBox(height: 10.sp),
        _Table(
          file: file,
          template: template,
          selectedRows: selectedRows,
          onToggleRow: onToggleRow,
          onChanged: onChanged,
        ),
        SizedBox(height: 20.sp),
        _Actions(
          canSubmit: canSubmit,
          submitting: submitting,
          onDiscard: onDiscard,
          onSubmit: onSubmit,
        ),
        SizedBox(height: 12.h),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.errorCount,
    required this.currentError,
    required this.hasSelection,
    required this.canDuplicate,
    required this.showRowActions,
    required this.onPreviousError,
    required this.onNextError,
    required this.onAdd,
    required this.onDuplicate,
    required this.onRemove,
  });

  final int errorCount;
  final int currentError;
  final bool hasSelection;
  final bool canDuplicate;
  final bool showRowActions;
  final VoidCallback onPreviousError;
  final VoidCallback onNextError;
  final VoidCallback onAdd;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final localeIsArabic = Localizations.localeOf(context).languageCode == 'ar';
    final arrowColor = errorCount == 0
        ? AppColors.grey
        : lightMode
            ? AppColors.blackButton
            : AppColors.whiteShadow;
    return Row(
      children: [
        Container(
          height: 30.sp,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ErrorArrow(
                asset: localeIsArabic
                    ? 'assets/icons_assets/main_icons_assets/chevron_right.svg'
                    : 'assets/icons_assets/main_icons_assets/chevron_left.svg',
                color: arrowColor,
                onTap: errorCount == 0 ? null : onPreviousError,
              ),
              SizedBox(width: 9.sp),
              Text(
                '${l10n.error}: ',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
              ),
              Text(
                errorCount == 0 ? '0' : '$currentError/$errorCount',
                style: StyleText.fontSize16Weight500.copyWith(
                  color: AppColors.red,
                ),
              ),
              SizedBox(width: 9.sp),
              _ErrorArrow(
                asset: localeIsArabic
                    ? 'assets/icons_assets/main_icons_assets/chevron_left.svg'
                    : 'assets/icons_assets/main_icons_assets/chevron_right.svg',
                color: arrowColor,
                onTap: errorCount == 0 ? null : onNextError,
              ),
            ],
          ),
        ),
        if (showRowActions) ...[
          const Spacer(),
          _ToolbarButton(
            title: l10n.removeSelection,
            width: 166.sp,
            enabled: hasSelection,
            asset: 'assets/icons_assets/main_icons_assets/minus_circle_red.svg',
            iconWidth: 12.sp,
            iconHeight: 12.sp,
            useDashIcon: true,
            iconColor: AppColors.background,
            onTap: onRemove,
          ),
          SizedBox(width: 10.sp),
          _ToolbarButton(
            title: l10n.duplication,
            width: 103.sp,
            enabled: canDuplicate,
            onTap: onDuplicate,
          ),
          SizedBox(width: 10.sp),
          _ToolbarButton(
            title: l10n.row,
            width: 82.sp,
            asset: 'assets/icons_assets/main_icons_assets/plus.svg',
            iconWidth: 12.sp,
            iconHeight: 12.sp,
            onTap: onAdd,
          ),
        ],
      ],
    );
  }
}

class _Table extends StatefulWidget {
  const _Table({
    required this.file,
    required this.template,
    required this.selectedRows,
    required this.onToggleRow,
    required this.onChanged,
  });

  final BulkUploadFile file;
  final BulkUploadTemplate template;
  final Set<int> selectedRows;
  final ValueChanged<int> onToggleRow;
  final void Function(int rowIndex, String header, String value) onChanged;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  final ScrollController _horizontal = ScrollController();
  final ScrollController _vertical = ScrollController();

  @override
  void dispose() {
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.only(bottom: 10.sp),
          child: SingleChildScrollView(
            controller: _horizontal,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: (widget.template.headers.length * 265.sp) + 90.sp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.sp,
                          top: 10.sp,
                          right: 10.sp,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(8.sp),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${S.of(context).employeeBulkTotalEmployees}: ${widget.file.rows.length}',
                            style:
                                StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.sp),
                      child: SingleChildScrollView(
                        controller: _vertical,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeaderRow(headers: widget.template.headers),
                            ...List.generate(
                              widget.file.rows.length,
                              (index) => _DataRow(
                                rowIndex: index,
                                row: widget.file.rows[index],
                                headers: widget.template.headers,
                                selected: widget.selectedRows.contains(index),
                                errors: widget.file.errors,
                                readOnlyHeaders:
                                    widget.template.readOnlyHeaders,
                                onToggle: () => widget.onToggleRow(index),
                                onChanged: (header, value) =>
                                    widget.onChanged(index, header, value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.headers});
  final List<String> headers;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 33.sp),
        child: Row(
          children: headers
              .map(
                (header) => Container(
                  width: 250.sp,
                  margin: EdgeInsets.only(right: 12.sp),
                  alignment: _isArabic(header)
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    header,
                    textAlign:
                        _isArabic(header) ? TextAlign.right : TextAlign.left,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.rowIndex,
    required this.row,
    required this.headers,
    required this.selected,
    required this.errors,
    required this.readOnlyHeaders,
    required this.onToggle,
    required this.onChanged,
  });

  final int rowIndex;
  final BulkUploadRow row;
  final List<String> headers;
  final bool selected;
  final List<BulkUploadCellError> errors;
  final Set<String> readOnlyHeaders;
  final VoidCallback onToggle;
  final void Function(String header, String value) onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp, right: 12.sp),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 24.sp,
                height: 24.sp,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.secondaryPrimary
                      : AppColors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                  border: selected
                      ? null
                      : Border.all(color: AppColors.grey, width: 1.5.sp),
                ),
                child: Icon(Icons.check,
                    size: 20.sp,
                    color: selected
                        ? AppColors.textButton
                        : AppColors.transparent),
              ),
            ),
            SizedBox(width: 10.sp),
            for (final header in headers)
              Padding(
                padding: EdgeInsets.only(right: 12.sp),
                child: _Cell(
                  key: ValueKey('$rowIndex|$header'),
                  header: header,
                  value: row.value(header),
                  error: _errorFor(header),
                  readOnly: readOnlyHeaders.contains(header),
                  onChanged: (value) => onChanged(header, value),
                ),
              ),
          ],
        ),
      );

  String? _errorFor(String header) {
    for (final error in errors) {
      if (error.rowIndex == rowIndex && error.header == header) {
        return error.message;
      }
    }
    return null;
  }
}

class _Cell extends StatefulWidget {
  const _Cell({
    required this.header,
    required this.value,
    required this.error,
    required this.readOnly,
    required this.onChanged,
    super.key,
  });

  final String header;
  final String value;
  final String? error;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _Cell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 250.sp,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36.sp,
                child: TextField(
                  controller: _controller,
                  readOnly: widget.readOnly,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: widget.readOnly ? AppColors.grey : AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.header,
                    hintStyle: StyleText.fontSize14Weight400.copyWith(
                      fontSize: 13.sp,
                      color: AppColors.mediumGrey,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.sp, vertical: 5.sp),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(
                        color: widget.error == null
                            ? AppColors.transparent
                            : AppColors.red,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  onChanged: widget.readOnly ? null : widget.onChanged,
                ),
              ),
            ),
            if (widget.error != null)
              GestureDetector(
                onTap: () => _showError(context),
                child: Padding(
                  padding: EdgeInsets.only(left: 8.sp),
                  child: SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg',
                    width: 20.sp,
                    height: 20.sp,
                    colorFilter:
                        ColorFilter.mode(AppColors.red, BlendMode.srcIn),
                  ),
                ),
              ),
          ],
        ),
      );

  void _showError(BuildContext context) {
    final l10n = S.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/warning.json',
              width: 70.sp,
              height: 70.sp,
            ),
            SizedBox(height: 16.sp),
            Text('${l10n.warning} ${widget.header}',
                textAlign: TextAlign.center,
                style: StyleText.fontSize20Weight600
                    .copyWith(color: AppColors.text)),
            SizedBox(height: 16.sp),
            Text(widget.error!,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.mediumGrey)),
          ],
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions(
      {required this.canSubmit,
      required this.submitting,
      required this.onDiscard,
      required this.onSubmit});
  final bool canSubmit;
  final bool submitting;
  final VoidCallback onDiscard;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final enabled = canSubmit && !submitting;
    return Row(
      children: [
        _Action(
          title: l10n.discard,
          width: 150.sp,
          enabled: !submitting,
          color: AppColors.grey,
          textColor: AppColors.text,
          onTap: onDiscard,
        ),
        const Spacer(),
        _Action(
          title: l10n.activate,
          width: 150.sp,
          enabled: enabled,
          color: enabled ? AppColors.primary : AppColors.grey,
          textColor: enabled ? AppColors.textButton : AppColors.text,
          onTap: enabled ? () => _confirm(context) : () {},
        ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.employeeBulkConfirmTitle),
        content: Text(l10n.employeeBulkConfirmMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.no)),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.yes)),
        ],
      ),
    );
    if (confirmed == true) await onSubmit();
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {required this.title,
      required this.width,
      required this.onTap,
      this.enabled = true,
      this.color,
      this.textColor});
  final String title;
  final double width;
  final VoidCallback onTap;
  final bool enabled;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : .45,
          child: Container(
            width: width,
            height: 38.sp,
            decoration: BoxDecoration(
                color: color ?? AppColors.primary,
                borderRadius: BorderRadius.circular(8.r)),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight400
                        .copyWith(color: textColor ?? AppColors.textButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ErrorArrow extends StatelessWidget {
  const _ErrorArrow({required this.asset, required this.color, this.onTap});

  final String asset;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(4.sp),
          child: SvgPicture.asset(
            asset,
            width: 15.sp,
            height: 15.sp,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      );
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.title,
    required this.width,
    required this.onTap,
    this.enabled = true,
    this.asset,
    this.iconWidth,
    this.iconHeight,
    this.useDashIcon = false,
    this.iconColor,
  });

  final String title;
  final double width;
  final VoidCallback onTap;
  final bool enabled;
  final String? asset;
  final double? iconWidth;
  final double? iconHeight;
  final bool useDashIcon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : .45,
          child: Container(
            width: width,
            height: 30.sp,
            decoration: BoxDecoration(
              color: AppColors.blackButton,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (asset != null) ...[
                  useDashIcon
                      ? Icon(
                          Icons.remove,
                          size: iconWidth,
                          color: iconColor ?? AppColors.blackButton,
                        )
                      : SvgPicture.asset(
                          asset!,
                          width: iconWidth,
                          height: iconHeight,
                          colorFilter: ColorFilter.mode(
                            AppColors.textButton,
                            BlendMode.srcIn,
                          ),
                        ),
                  SizedBox(width: 8.sp),
                ],
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

bool _isArabic(String value) => RegExp(r'[\u0600-\u06FF]').hasMatch(value);
