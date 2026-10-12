/// Module: roles / r4_active_directory / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: csv_export_preview.dart
/// Purpose: Declares `ExportDialogPreview`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/custom_csv_table_page.dart';

extension ExportDialogPreview on _ExportDialogState {
  Widget _buildPreviewPanel() {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/search_magnifier_alt.svg',
                    width: 16.w,
                    height: 16.h,
                    colorFilter: ColorFilter.mode(
                        AppColors.secondaryText, BlendMode.srcIn),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize014.w,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        hintText: S.current.searchEmployee,
                        hintStyle: AppFontStyle.cairoRegularStyle.copyWith(
                          fontSize: FontConstants.fontSize014.w,
                          color: AppColors.secondaryText,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Employee list from real data
          Expanded(
            child: _previewRows.isEmpty
                ? Center(
              child: Text(
                S.current.noMatchesFound,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize014.w,
                  color: AppColors.secondaryText,
                ),
              ),
            )
                : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _previewRows.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.border, height: 1),
              itemBuilder: (context, index) {
                final row = _previewRows[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors.greyDark,
                        child: Text(
                          _rowName(row).isNotEmpty
                              ? _rowName(row)[0].toUpperCase()
                              : '?',
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: FontConstants.fontSize014.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _rowName(row),
                              style: AppFontStyle.cairoRegularStyle
                                  .copyWith(
                                fontSize: FontConstants.fontSize014.w,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              _rowDepartment(row),
                              style: AppFontStyle.cairoRegularStyle
                                  .copyWith(
                                fontSize: FontConstants.fontSize012.w,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            Text(
                              _rowTitle(row),
                              style: AppFontStyle.cairoRegularStyle
                                  .copyWith(
                                fontSize: FontConstants.fontSize012.w,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom actions
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          S.current.discard,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize013.w,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: _previewRows.isEmpty
                        ? null
                        : () async {
                      Navigator.pop(context);
                      // Trigger the real export through the controller
                      final ctrl =
                      AppControllers.activeDirectory;
                      // FIXED 25/8/2026 — this compared against the English
                      // LABEL 'Excel (.xlsx)'. Since the export dialog started
                      // storing a locale-independent CODE ('csv'/'xlsx'/'pdf')
                      // it could never match, so picking Excel still wrote a
                      // .csv — and under Arabic the label had changed anyway.
                      final fileName =
                          _fileFormat == 'xlsx' ? 'export.xlsx' : 'export.csv';
                      await ctrl.exportToCSV(fileName);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: _previewRows.isEmpty
                            ? AppColors.greyDark
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_rounded,
                                size: 16.r,
                                color: _previewRows.isEmpty
                                    ? AppColors.white
                                    : AppColors.black),
                            SizedBox(width: 6.w),
                            Text(
                              S.current.export,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize013.w,
                                fontWeight: FontWeight.w600,
                                color: _previewRows.isEmpty
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
