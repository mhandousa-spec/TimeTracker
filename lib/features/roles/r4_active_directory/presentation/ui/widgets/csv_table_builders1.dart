/// Module: roles / r4_active_directory / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: csv_table_builders1.dart
/// Purpose: Declares `CsvTableBuilders1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Toolbar, tabs and badges localized (text + numerals).
/// Updated: 25/8/2026 - Toolbar actions gated on the Active Directory
///          permissions. Reported as "switches of active directory not work":
///          `ActiveDirectory` (r1_role_management/domain/enums/roles) declares
///          uploadDocument / restoreData / exportData / editUploadedDocument /
///          removeEmployee, the role editor writes all five, and this toolbar
///          asked about none of them — Upload, Export, Restore and Edit were
///          unconditional for anyone who could open the page. Each button now
///          goes through `RolesModuleAccess.activeDirectory`, which also honours
///          the section master switch above those five (see that class).

part of '../pages/custom_csv_table_page.dart';

/// Keys the two tabs are selected by.
///
/// ADDED 29/8/2026 with the move to `StatusChipFilter`, which selects by
/// string key while `ActiveDirectoryController` tracks an integer
/// `selectedIndex`. The mapping lives only in `_buildTabBar`; nothing else
/// sees these.
const String _kUsersDataTabKey = 'usersData';
const String _kInvalidDataTabKey = 'invalidData';

extension CsvTableBuilders1 on CustomCsvTable {
  // ─── Permissions ─────────────────────────────────────────────────────────
  //
  // ADDED 25/8/2026. Read at build time rather than cached: a role change
  // lands on the signed-in employee's record while the page may already be
  // open, and `MainCoreEmployeeController` is the live source.
  //
  // Every one goes through `RolesModuleAccess`, not `isHasPermission` directly,
  // so the "الدليل النشط" section master switch is honoured as well as the leaf
  // — checking the leaf alone is what left that switch inert.

  bool get _canUploadDocument =>
      RolesModuleAccess.activeDirectory(ActiveDirectory.uploadDocument);

  bool get _canExportData =>
      RolesModuleAccess.activeDirectory(ActiveDirectory.exportData);

  bool get _canRestoreData =>
      RolesModuleAccess.activeDirectory(ActiveDirectory.restoreData);

  bool get _canEditUploadedDocument =>
      RolesModuleAccess.activeDirectory(ActiveDirectory.editUploadedDocument);

  /// A count rendered in the reader's numerals.
  ///
  /// ADDED 25/8/2026. The tab badges and the filter badge printed
  /// `count.toString()` — always Latin figures — so an Arabic user read
  /// "بيانات المستخدمين 87" with the number in the wrong script.
  ///
  /// `LocalizedDigits` is the app's shared helper. It maps a bare `ar` to
  /// `ar_EG` internally, because CLDR's generic Arabic is Latin-digit and
  /// `NumberFormat.decimalPattern('ar')` would hand "87" straight back.
  String _localizedCount(BuildContext context, int value) =>
      LocalizedDigits.apply(
        value.toString(),
        Localizations.localeOf(context).languageCode,
      );

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(
      ActiveDirectoryController controller,
      BuildContext context,
      bool isVertical,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
        bloc: AppControllers.activeDirectory,
        builder: (context, state) {
          final controller = AppControllers.activeDirectory;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabBar(controller, context),
              SizedBox(height: 15.h),
              _buildToolbar(controller, context, isVertical),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // GATED 25/8/2026. Edit mode is what puts the table's cells
                  // and its delete controls in reach, so it is the
                  // `Edit Uploaded Document` permission — on BOTH tabs, since
                  // the invalid-rows tab edits the same uploaded document.
                  if (_canEditUploadedDocument) ...[
                    if (controller.selectedIndex == 1)
                      _actionButton(
                        icon: controller.isEditMode
                            ? 'assets/icons_assets/messaging_assets/close_x_teal.svg'
                            : 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                        // LOCALIZED 25/8/2026: every label on this toolbar was an
                        // English literal.
                        label: controller.isEditMode
                            ? S.of(context).cancel
                            : S.of(context).edit,
                        isActive: controller.isEditMode,
                        onTap: () => controller.toggleEditMode(),
                      ),
                    if (controller.selectedIndex == 0)
                      _actionButton(
                        icon: 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                        label: S.of(context).edit,
                        onTap: () => controller.toggleEditMode(),
                      ),
                  ],
                  const Spacer(),
                  if (_canExportData)
                    _actionButton(
                      icon: 'assets/icons_assets/watermark/export.svg',
                      label: S.of(context).export,
                      // CHANGED 29/8/2026: show the simple File Name / Download
                      // card (CustomDialogManager.showExport) and export directly,
                      // instead of the old filter + preview _ExportDialog.
                      // NOTE 9/9/2026: this toolbar is tablet/desktop only —
                      // on a phone `CsvView` renders the Figma export form as
                      // the whole tab instead of this table, so nothing here
                      // is reachable there.
                      onTap: () async {
                        await CustomDialogManager.showExport(
                          context: context,
                          onDownload: (fileName) async {
                            final String name = fileName.trim();
                            final String fn = name.isEmpty
                                ? 'export.csv'
                                : (name.toLowerCase().endsWith('.csv')
                                    ? name
                                    : '$name.csv');
                            await controller.exportToCSV(fn);
                          },
                        );
                      },
                    ),
                  if (_canExportData && _canRestoreData)
                    SizedBox(width: 0.008.w),
                  if (_canRestoreData)
                    _actionButton(
                      icon: 'assets/icons_assets/watermark/restore.svg',
                      label: S.of(context).restore,
                      // CHANGED 30/8/2026. This button used to open the
                      // "backup restored successfully" dialog and nothing
                      // else — no collection was read and none was written,
                      // so Restore was a message box.
                      //
                      // It now opens `_RestoreBackupDialog`
                      // (csv_restore_dialog.dart): one tab per backup
                      // collection — `Employees Backup One`, and
                      // `Employees Backup Two` when that one holds anything —
                      // each showing every employee field, and restoring the
                      // selected one into `Employees_Info`.
                      onTap: () => _showRestoreBackupDialog(context),
                    ),
                ],
              ),
              if (controller.selectedIndex == 1) ...[
                SizedBox(height: 0.012.h),
                _buildErrorChips(controller),
              ],
            ],
          );
        },
      ),
    );
  }

  // ─── Tab bar ─────────────────────────────────────────────────────────────

  /// LOCALIZED 25/8/2026: the two tab labels were English literals and their
  /// badges printed Latin figures, so this bar stayed English on an otherwise
  /// Arabic page. It now takes a [context] purely to reach `S` and the reader's
  /// numerals.
  ///
  /// REPLACED 29/8/2026 — this was a hand-rolled `Row` of `_tabItem`s: its own
  /// count box, its own selected/unselected colours, its own spacing, and its
  /// own `_localizedCount` call. It is `StatusChipFilter`
  /// (core/custom/8-custom_filter_app.dart), which is the app's chip filter and
  /// draws exactly this shape — count box, label, selected fill — with the
  /// numeral localization already inside it.
  ///
  /// Two visual consequences of adopting the shared widget, both deliberate:
  /// the unselected count box is `AppColors.card` rather than `greyDark`, and
  /// the selected LABEL is `AppColors.text` rather than the brand primary. The
  /// selected chip is already the only one with a primary-filled box, so the
  /// label does not need to carry the same signal twice.
  Widget _buildTabBar(
      ActiveDirectoryController controller, BuildContext context) {
    return StatusChipFilter(
      selectedKey: controller.selectedIndex == 1
          ? _kInvalidDataTabKey
          : _kUsersDataTabKey,
      onSelected: (String key) =>
          controller.toggleIndex(key == _kInvalidDataTabKey ? 1 : 0),
      items: [
        StatusChipItem(
          key: _kUsersDataTabKey,
          label: S.of(context).usersData,
          // Show the filtered count when a filter is active, raw count
          // otherwise.
          count: controller.hasActiveFilters
              ? controller.filteredUsersData.length
              : controller.usersData.length,
        ),
        StatusChipItem(
          key: _kInvalidDataTabKey,
          label: S.of(context).invalidData,
          count: controller.rowInvalid.length,
        ),
      ],
    );
  }

  // ─── Toolbar ──────────────────────────────────────────────────────────────

  Widget _buildToolbar(
      ActiveDirectoryController controller,
      BuildContext context,
      bool isVertical,
      ) {
    return Row(
      children: [
        _buildSearchBar(controller),
        SizedBox(width: 0.008.w),
        // Filter button turns yellow + shows count badge when filters active
        _filterButton(context, controller),
        // GATED 25/8/2026 — `Upload_Document`.
        if (controller.selectedIndex == 0 && _canUploadDocument) ...[
          SizedBox(width: 0.008.w),
          _actionButton(
            icon: 'assets/icons_assets/watermark/upload.svg',
            label: S.of(context).upload,
            // CHANGED 29/8/2026: show the Upload card first, then run the
            // normal file upload from its "Browse Files" button.
            onTap: () async {
              await CustomDialogManager.showUpload(
                context: context,
                onBrowse: () async {
                  await controller.uploadExcelFile(
                    length: controller.usersData.length,
                  );
                },
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _filterButton(
      BuildContext context, ActiveDirectoryController controller) {
    final bool active = controller.hasActiveFilters;
    return InkWell(
      onTap: () => _showFilterPanel(context),
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100.sp,
            height: 38.sp,
            decoration: BoxDecoration(
              color:  AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons_assets/main_icons_assets/filter_sliders.svg',
                    width: 14.w,
                    height: 14.h,
                    color: AppColors.textButton,

                  ),
                  SizedBox(width: 5.w),
                  Text(
                    S.of(context).Filter,
                    style: StyleText.fontSize16Weight500.copyWith(
                      fontSize: FontConstants.fontSize013.w,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // // Active-filter badge
          // if (active)
          //   Positioned(
          //     top: -6,
          //     right: -6,
          //     child: Container(
          //       width: 16.r,
          //       height: 16.r,
          //       decoration: BoxDecoration(
          //         color: AppColors.primary,
          //         shape: BoxShape.circle,
          //       ),
          //       child: Center(
          //         child: Text(
          //           _localizedCount(context, controller.activeFilterCount),
          //           style: AppFontStyle.cairoRegularStyle.copyWith(
          //             fontSize: 8.sp,
          //             fontWeight: FontWeight.w700,
          //             color: AppColors.black,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ActiveDirectoryController controller) {
    // Uses the shared search widget (35-custom_search_widget_custom.dart);
    // `AppSearchTextField` already returns an `Expanded`, so the toolbar Row
    // places it directly rather than wrapping it in another Expanded.
    return AppSearchTextField(
      controller: controller.searchController,
      onChanged: (value) => controller.onSearchChanged(value),
      fillColor: AppColors.field,
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _actionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isOutlined = false,
    bool isActive = false,
  }) {
    final Color bgColor = isActive
        ? AppColors.red
        : isOutlined
        ? AppColors.transparent
        : AppColors.primary;
    final Color iconColor = AppColors.textButton;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 100.sp,
        height: 38.sp,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
          border: isOutlined ? Border.all(color: AppColors.border) : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 16.sp,
                height: 16.sp,
                fit: BoxFit.fill,
                colorFilter: ColorFilter.mode(
                  isActive ? AppColors.white : iconColor,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: StyleText.fontSize16Weight500.copyWith(
                  fontSize: FontConstants.fontSize013.w,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? AppColors.white
                      : isOutlined
                      ? AppColors.text
                      : AppColors.textButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Edit mode bottom bar ─────────────────────────────────────────────────

}
