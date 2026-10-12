// ***************************** FILE INFO ***************************** //
// File Name: employee_bulk_upload_drop_zone.dart
// Purpose: Matches the supplied bulk-upload file-selection presentation.
// Author: Mohamed Elrashidy
// Created At: 2026-08-15
// ********************************************************************* //

import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../../core/theme/app_colors.dart';

import '../../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Reference-styled drag-and-drop surface and paired action buttons.
class EmployeeBulkUploadDropZone extends StatefulWidget {
  const EmployeeBulkUploadDropZone({
    required this.onBrowse,
    required this.onDiscard,
    required this.onDropped,
    required this.onNoFilesDropped,
    required this.onUnsupportedFile,
    required this.onFileReadFailure,
    required this.isProcessing,
    super.key,
  });

  final VoidCallback onBrowse;
  final VoidCallback onDiscard;
  final Future<void> Function(String name, Uint8List bytes) onDropped;
  final VoidCallback onNoFilesDropped;
  final VoidCallback onUnsupportedFile;
  final VoidCallback onFileReadFailure;
  final bool isProcessing;

  @override
  State<EmployeeBulkUploadDropZone> createState() =>
      _EmployeeBulkUploadDropZoneState();
}

class _EmployeeBulkUploadDropZoneState
    extends State<EmployeeBulkUploadDropZone> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final dropZoneHeight = (viewportHeight * .78).clamp(360.0, 790.0);
    return Column(
      children: [
        Expanded(
          child: DropTarget(
            onDragEntered: (_) {
              if (!widget.isProcessing) setState(() => _dragging = true);
            },
            onDragExited: (_) => setState(() => _dragging = false),
            onDragDone: (details) async {
              setState(() => _dragging = false);
              if (widget.isProcessing) return;
              if (details.files.isEmpty) {
                widget.onNoFilesDropped();
                return;
              }
              final file = details.files.first;
              final normalizedName = file.name.toLowerCase();
              if (!normalizedName.endsWith('.xlsx') &&
                  !normalizedName.endsWith('.xls')) {
                widget.onUnsupportedFile();
                return;
              }
              try {
                await widget.onDropped(file.name, await file.readAsBytes());
              } catch (_) {
                widget.onFileReadFailure();
              }
            },
            child: GestureDetector(
              onTap: widget.isProcessing ? null : widget.onBrowse,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: dropZoneHeight,
                decoration: BoxDecoration(
                  color: _dragging
                      ? AppColors.primary.withValues(
                          alpha: lightMode ? .1 : .2,
                        )
                      : lightMode
                          ? AppColors.field
                          : AppColors.chatBackground,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _dragging
                          ? Icon(
                              Icons.cloud_upload_outlined,
                              key: const ValueKey('dragging'),
                              size: 150.sp,
                              color: AppColors.primary,
                            )
                          : SvgPicture.asset(
                              'assets/icons_assets/hr_assets/formkit_uploadcloud.svg',
                              key: const ValueKey('normal'),
                              width: 150.sp,
                              height: 150.sp,
                              fit: BoxFit.scaleDown,
                            ),
                    ),
                    SizedBox(height: 42.sp),
                    Text(
                      localization.employeeBulkDropFile,
                      style: StyleText.fontSize30Weight500.copyWith(
                        color: _dragging
                            ? AppColors.primary
                            : lightMode
                                ? AppColors.blackButton
                                : AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 26.sp),
        Row(
          children: [
            _ReferenceActionButton(
              title: localization.discard,
              color: lightMode ? AppColors.grey : AppColors.mediumGrey,
              textColor: lightMode ? AppColors.blackButton : AppColors.white,
              onTap: widget.onDiscard,
              enabled: !widget.isProcessing,
            ),
            const Spacer(),
            _ReferenceActionButton(
              title: localization.browseFiles,
              color: AppColors.primary,
              textColor: AppColors.textButton,
              onTap: widget.onBrowse,
              enabled: !widget.isProcessing,
            ),
          ],
        ),
        SizedBox(height: 26.sp),
      ],
    );
  }
}

class _ReferenceActionButton extends StatelessWidget {
  const _ReferenceActionButton({
    required this.title,
    required this.color,
    required this.textColor,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: enabled ? 1 : .55,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 150.sp,
            height: 38.sp,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
            ),
            alignment: Alignment.center,
            child: Text(
              title,
              style: StyleText.fontSize16Weight600.copyWith(
                color: textColor,
              ),
            ),
          ),
        ),
      );
}
