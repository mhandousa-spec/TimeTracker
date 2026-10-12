/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: import_table_dialog.dart
/// Purpose: Declares `showImportTableDialog` and `TableImportRequest`.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// "Import Table" — Figma 7398:4041 (600 x 429), drawn over Table Name Details
/// at 7398:3450 with "Overwrite" picked and 7398:3647 with "Append".
///
/// NOT `showUploadDialog`. The core dialog is the same shape — a title, a
/// picker, Discard and a primary action — but it captures a TITLE for the
/// attachment where this one captures a Type Of Import, and the two are asking
/// for different things. Forking the core widget to take an arbitrary field
/// would make every other caller carry a parameter that means nothing to them.
///
/// IT PARSES BUT DOES NOT WRITE
/// ----------------------------
/// The dialog resolves with a [TableImportRequest] — the rows it read and the
/// mode the user chose — and the screen that opened it decides what to do with
/// them. That keeps the one place rows are written (`TableDataCubit.save`) as
/// the one place rows are written, and it means an import can be undone by the
/// same Undo that covers typing.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db3_create_table/data/data_source/local_data_source/table_import_file_parser.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/enums/table_import_mode.dart';

/// What the dialog resolved with.
class TableImportRequest {
  const TableImportRequest({required this.mode, required this.result});

  final TableImportMode mode;
  final TableImportResult result;
}

/// Function Name: [showImportTableDialog]
///
/// Purpose: Ask for a file and a mode, and hand back the rows it held.
///
/// Resolves null when the user discards or taps the barrier — the same "nothing
/// happened" every other dialog in this module returns.
Future<TableImportRequest?> showImportTableDialog({
  required BuildContext context,
  required List<TableColumn> columns,
}) {
  return showDialog<TableImportRequest>(
    context: context,
    barrierColor: AppColors.totalBlack.withOpacity(0.4),
    builder: (_) => _ImportTableDialog(columns: columns),
  );
}

class _ImportTableDialog extends StatefulWidget {
  const _ImportTableDialog({required this.columns});

  final List<TableColumn> columns;

  @override
  State<_ImportTableDialog> createState() => _ImportTableDialogState();
}

class _ImportTableDialogState extends State<_ImportTableDialog> {
  TableImportMode _mode = TableImportMode.overwrite;

  PlatformFile? _file;
  String? _error;
  bool _reading = false;

  /// Function Name: [_pickFile]
  ///
  /// Purpose: Open the system picker, filtered to what the parser can read.
  ///
  /// `withData: true` because the parser takes bytes: on the web there is no
  /// path at all, and asking for a path here would make the dialog work on a
  /// tablet and fail in a browser for a reason nobody could see.
  Future<void> _pickFile() async {
    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: TableImportFileParser.allowedExtensions,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty || !mounted) return;

    setState(() {
      _file = picked.files.first;
      _error = null;
    });
  }

  /// Parses and pops. The parse happens HERE and not after the dialog closes so
  /// a file that cannot be read is reported on the dialog that chose it, with
  /// the picker still open to try another one.
  Future<void> _import() async {
    final PlatformFile? file = _file;
    if (file == null || file.bytes == null) return;

    setState(() {
      _reading = true;
      _error = null;
    });

    try {
      final TableImportResult result = TableImportFileParser.parse(
        bytes: file.bytes!,
        fileName: file.name,
        columns: widget.columns,
      );

      if (!mounted) return;
      Navigator.of(context).pop(
        TableImportRequest(mode: _mode, result: result),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _reading = false;
        _error = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _reading = false;
        _error = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final bool canImport = _file != null && !_reading;

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ConstrainedBox(
        // 600 x 429 in the Figma. A max rather than a fixed size: the dialog
        // has to fit a phone in landscape too, and a hard 600 would overflow
        // one by 100pt with no way to scroll.
        constraints: BoxConstraints(maxWidth: 600.sp),
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _title(strings),
              SizedBox(height: 20.sp),

              Row(
                children: [
                  Expanded(
                    child: CustomDropdown<TableImportMode>(
                      height: 38,
                      label: strings.typeOfImport,
                      value: _mode,
                      enabled: !_reading,
                      fillColor: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                      items: <DropdownItem<TableImportMode>>[
                        for (final TableImportMode mode in TableImportMode.values)
                          DropdownItem<TableImportMode>(
                            value: mode,
                            label: mode.localizedLabel(isArabic: context.isArabic),
                          ),
                      ],
                      onChanged: (TableImportMode mode) =>
                          setState(() => _mode = mode),
                    ),
                  ),
                  Expanded(child: Container())
                ],
              ),
              SizedBox(height: 24.sp),

              _dropZone(strings),
              SizedBox(height: 24.sp),

              _actions(strings, canImport),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(CreateTableStrings strings) {
    return Row(
      children: <Widget>[
        Container(
          width: 32.sp,
          height: 32.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath: CreateTableAssets.importTable,
              width: 18.sp,
              height: 18.sp,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(width: 10.sp),
        Text(
          strings.importTable,
          style: StyleText.fontSize16Weight500.copyWith(color: AppColors.text),
        ),
      ],
    );
  }

  /// The cloud, the button, and whatever the last attempt has to say — the
  /// chosen file's name on success, the reason on failure.
  Widget _dropZone(CreateTableStrings strings) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          CustomSvgImage(
            assetPath: CreateTableAssets.cloudUpload,
            width: 84.sp,
            height: 84.sp,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16.sp),
          customButtonWithSvg(
            title: strings.uploadFile,
            function: _reading ? () {} : _pickFile,
            color: AppColors.primary,
            colorBorder: AppColors.transparent,
            image: CreateTableAssets.uploadArrow,
            widthImage: 16.r,
            heightImage: 16.r,
            svgColor: AppColors.textButton,
            textStyle: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.textButton),
          ),
          if (_file != null || _error != null) ...<Widget>[
            SizedBox(height: 12.sp),
            Text(
              _error ?? _file!.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: StyleText.fontSize13Weight400.copyWith(
                color: _error != null ? AppColors.red : AppColors.secondaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Discard on the leading edge, Import on the trailing one — the same
  /// grouping every other pair of actions in this module uses.
  Widget _actions(CreateTableStrings strings, bool canImport) {
    return Row(
      children: <Widget>[
        customButton(
          title: strings.discard,
          function: _reading ? () {} : () => Navigator.of(context).pop(),
          color: AppColors.darkGrey,
          textStyle:
              StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
        ),
        const Spacer(),
        customButton(
          title: strings.import,
          function: canImport ? _import : () {},
          // Grey until a file has been chosen: Import with nothing picked can
          // only do nothing, and a button that does nothing is one the user
          // presses twice before deciding the dialog is broken.
          color: canImport ? AppColors.primary : AppColors.darkGrey,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: canImport ? AppColors.textButton : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
