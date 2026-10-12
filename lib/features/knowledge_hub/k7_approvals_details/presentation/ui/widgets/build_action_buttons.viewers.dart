part of './build_action_buttons.dart';
/// Module: knowledge_hub / presentation / s7_approvals_details / widgets/build_action_buttons.viewers.dart
/// File-type viewer builders (pdf/image/video/office/excel/csv/placeholder),
/// split out of build_action_buttons.dart to stay under 800 LOC (§7).
/// Param-only helpers — no widget-field access.
mixin _ApprovalsFileViewers {
  Widget _buildPdfViewer(String fileUrl, bool lightMode) {
    return Container(
      color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
      // FIXED 22/9/2026 — "every knowledge view the same file".
      //
      // `SfPdfViewer` holds the loaded document in its State and does NOT
      // reload it when only the `network` URL changes. With no key, Flutter
      // matches the new widget to the existing element by position and type
      // and calls `didUpdateWidget` instead of building fresh State, so the
      // FIRST pdf opened in this viewer kept rendering for every document
      // opened afterwards — the breadcrumb said one document, the pages were
      // another's.
      //
      // Keying on the URL makes a different document a different element, so
      // the State is rebuilt and the right file loads. Same document reopened
      // = same key = the existing cache is reused, which is the behaviour that
      // made this worth having in the first place.
      child: SfPdfViewer.network(
        key: ValueKey<String>(fileUrl),
        fileUrl,
        canShowScrollHead: true,
        canShowScrollStatus: true,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
      ),
    );
  }

  /// ✅ Image Viewer
  Widget _buildImageViewer(String fileUrl, bool lightMode) {
    return Container(
      color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
      child: PhotoView(
        // Keyed for the same reason as the pdf viewer above.
        key: ValueKey<String>(fileUrl),
        imageProvider: NetworkImage(fileUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        initialScale: PhotoViewComputedScale.contained,
        backgroundDecoration: BoxDecoration(
          color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
        ),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
        errorBuilder: (context, error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
              SizedBox(height: 16.h),
              Text(
                'Failed to load image',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Video Player Widget
  Widget _buildVideoPlayer(String fileUrl, bool lightMode) {
    return _VideoPlayerWidget(
      videoUrl: fileUrl,
      lightMode: lightMode,
    );
  }

  /// ✅ Office Files Viewer (Excel/CSV)
  Widget _buildOfficeFileViewer(String fileUrl, String extension, bool lightMode) {
    return FutureBuilder<Widget>(
      future: _loadOfficeFile(fileUrl, extension, lightMode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16.h),
                Text(
                  'Loading ${extension.toUpperCase()} file...',
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                SizedBox(height: 16.h),
                Text(
                  'Error loading file',
                  style: StyleText.fontSize16Weight600.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return snapshot.data ?? SizedBox.shrink();
      },
    );
  }

  /// ✅ Load Office File (Excel/CSV)
  Future<Widget> _loadOfficeFile(String fileUrl, String extension, bool lightMode) async {
    try {
      log('📥 Loading $extension file from: $fileUrl', name: 'OfficeViewer');

      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download file: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      log('✅ File downloaded: ${bytes.length} bytes', name: 'OfficeViewer');

      if (['xls', 'xlsx', 'xlsm'].contains(extension)) {
        return _buildExcelViewer(bytes, lightMode);
      } else if (extension == 'csv') {
        return _buildCsvViewer(bytes, lightMode);
      }

      return _buildUnsupportedFileView(extension, lightMode);
    } catch (e) {
      log('❌ Error loading office file: $e', name: 'OfficeViewer');
      rethrow;
    }
  }

  /// ✅ Excel Viewer
  Widget _buildExcelViewer(List<int> bytes, bool lightMode) {
    try {
      var excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        return Center(
          child: Text(
            'Excel file is empty',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        );
      }

      var sheetName = excel.tables.keys.first;
      var sheet = excel.tables[sheetName]!;

      if (sheet.rows.isEmpty) {
        return Center(
          child: Text(
            'Sheet is empty',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        );
      }

      return Container(
        color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            // Sheet tabs
            if (excel.tables.keys.length > 1)
              Container(
                height: 48.h,
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: excel.tables.keys.length,
                  itemBuilder: (context, index) {
                    final name = excel.tables.keys.elementAt(index);
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: ChoiceChip(
                        label: Text(name),
                        selected: name == sheetName,
                        selectedColor: AppColors.primary,
                        backgroundColor: lightMode ? AppColors.colorWhite : AppColors.chatBackground,
                        labelStyle: TextStyle(
                          color: name == sheetName
                              ? AppColors.colorWhite
                              : (lightMode
                              ? AppColors.blackButton
                              : AppColors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Excel table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      AppColors.primary.withOpacity(0.1),
                    ),
                    dataRowColor: MaterialStateProperty.all(
                      lightMode ? AppColors.colorWhite : AppColors.chatBackground,
                    ),
                    border: TableBorder.all(
                      color: lightMode ? AppColors.colorGrey! : AppColors.colorGreyDark!,
                      width: 1,
                    ),
                    columnSpacing: 20.w,
                    columns: List.generate(
                      sheet.maxColumns,
                          (index) {
                        final cell = sheet.rows[0][index];
                        return DataColumn(
                          label: Container(
                            constraints: BoxConstraints(maxWidth: 150.w),
                            child: Text(
                              cell?.value?.toString() ?? '',
                              style: StyleText.fontSize14Weight600.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                    rows: List.generate(
                      sheet.rows.length - 1,
                          (rowIndex) => DataRow(
                        cells: List.generate(
                          sheet.maxColumns,
                              (colIndex) {
                            final cell = sheet.rows[rowIndex + 1][colIndex];
                            return DataCell(
                              Container(
                                constraints: BoxConstraints(maxWidth: 150.w),
                                child: Text(
                                  cell?.value?.toString() ?? '',
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: lightMode
                                        ? AppColors.blackButton
                                        : AppColors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      log('❌ Error parsing Excel: $e', name: 'ExcelViewer');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(
              'Error parsing Excel file',
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.red,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// ✅ CSV Viewer
  Widget _buildCsvViewer(List<int> bytes, bool lightMode) {
    try {
      final csvString = utf8.decode(bytes);
      final rows = Csv(autoDetect: false, skipEmptyLines: false).decode(csvString);

      if (rows.isEmpty) {
        return Center(
          child: Text(
            'CSV file is empty',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        );
      }

      final maxColumns = rows.fold<int>(0, (max, row) => row.length > max ? row.length : max);

      return Container(
        color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
        padding: EdgeInsets.all(8.w),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                AppColors.primary.withOpacity(0.1),
              ),
              dataRowColor: MaterialStateProperty.all(
                lightMode ? AppColors.colorWhite : AppColors.chatBackground,
              ),
              border: TableBorder.all(
                color: lightMode ? AppColors.colorGrey! : AppColors.colorGreyDark!,
                width: 1,
              ),
              columnSpacing: 20.w,
              columns: List.generate(
                maxColumns,
                    (index) => DataColumn(
                  label: Container(
                    constraints: BoxConstraints(maxWidth: 150.w),
                    child: Text(
                      index < rows[0].length ? rows[0][index]?.toString() ?? '' : '',
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              rows: List.generate(
                rows.length - 1,
                    (rowIndex) => DataRow(
                  cells: List.generate(
                    maxColumns,
                        (colIndex) {
                      final row = rows[rowIndex + 1];
                      return DataCell(
                        Container(
                          constraints: BoxConstraints(maxWidth: 150.w),
                          child: Text(
                            colIndex < row.length ? row[colIndex]?.toString() ?? '' : '',
                            style: StyleText.fontSize12Weight400.copyWith(
                              color: lightMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      log('❌ Error parsing CSV: $e', name: 'CsvViewer');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(
              'Error parsing CSV file',
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.red,
              ),
            ),
          ],
        ),
      );
    }
  }

  /// ✅ Document Placeholder (Word/PowerPoint)
  Widget _buildDocumentPlaceholder(String extension, bool lightMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForExtension(extension),
            size: 80.sp,
            color: AppColors.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            '${extension.toUpperCase()} Preview',
            style: StyleText.fontSize16Weight600.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'Preview not available for ${extension.toUpperCase()} files.\nPlease download to view.',
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Unsupported File Type View
  Widget _buildUnsupportedFileView(String extension, bool lightMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 80.sp,
            color: AppColors.darkGrey,
          ),
          SizedBox(height: 16.h),
          Text(
            'Unsupported File Type',
            style: StyleText.fontSize16Weight600.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '.${extension.toUpperCase()}',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Preview not available',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Please download the file to view',
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Helper: Get icon for file extension
  IconData _getIconForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'xlsm':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      default:
        return Icons.insert_drive_file;
    }
  }
}
