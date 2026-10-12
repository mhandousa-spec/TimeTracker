/// Module: roles / r4_active_directory / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: csv_restore_dialog.dart
/// Purpose: Declares `_RestoreBackupDialog` — the Restore card on the Active
///          Directory page.
/// Author: Knowticed Plus team
/// Created: 30/8/2026
///
/// Why this exists: the Restore button in csv_table_builders1.dart opened the
/// "the backup has been restored successfully" message and did nothing else —
/// it never read a backup collection and never wrote one. Restore was a
/// message box.
///
/// This card shows what is actually in the two backup collections that
/// `EmployeeBackupRemoteDataSource.backupCollections` rolls:
///
///   Demo/{companyId}/Employees Backup One   ← the previous Employees_Info
///   Demo/{companyId}/Employees Backup Two   ← the one before that
///
/// one tab each, with every employee field as a column — the same field list
/// and the same column order as the Users Data table, because both are
/// `EmployeeDataItems.values`. The second tab appears only when backup two
/// holds something; on a tenant that has uploaded once, it is empty.
///
/// Picking a backup and confirming replaces `Employees_Info` with it — see
/// `ActiveDirectoryController.restoreBackup`, and note that the restore is
/// destructive: every current employee document is deleted first. The data
/// source refuses to restore an empty backup, so a tab with no rows offers no
/// Restore button rather than failing after the confirmation.

part of '../pages/custom_csv_table_page.dart';

/// Keys the two backup tabs are selected by — the same strings
/// `EmployeeBackupRemoteDataSource` switches on, so the collection previewed
/// is the collection restored.
const String _kBackupOneKey = ActiveDirectoryController.backupVersionOne;
const String _kBackupSecondKey = ActiveDirectoryController.backupVersionSecond;

/// Width of one column in the preview table. Thirty-one fields never fit a
/// dialog, so the table scrolls horizontally the way the page's own table
/// does.
///
/// Read with `.sp`, never `.w`. This app declares
/// `extension ScreenSizeExtension on double` (core/theme/app_font_size.dart)
/// where `.w` is `Get.width * this` — a FRACTION of the screen, which is why
/// sizes are written as `0.013.w`. Dart picks that extension over
/// flutter_screenutil's `on num` one for any `double`, so reading this with
/// `.w` gave 170 screen-widths per column and the table rendered as a single
/// column of full-width bars. An int literal like `44.h` is not a `double` and
/// still goes to screenutil, which is why the row heights looked right.
const double _kRestoreCellWidth = 170;

/// Function Name: [_showRestoreBackupDialog]
///
/// Purpose: Open the Restore card, then — if the user picked a backup — run
///          the confirm → restore → success flow.
///
/// The picking and the confirming are deliberately two dialogs: the card can
/// be dismissed with no consequence, and the only path to a destructive write
/// is the explicit Yes in [CustomDialogManager.showDialogFlow].
///
/// Parameters:
/// - [context]: The page context, used for both dialogs.
Future<void> _showRestoreBackupDialog(BuildContext context) async {
  final String? backupVersion = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    useRootNavigator: true,
    builder: (_) => const _RestoreBackupDialog(),
  );

  if (backupVersion == null) return;

  // Let the card finish closing before the confirmation opens on top of it.
  await Future.delayed(const Duration(milliseconds: 120));

  await CustomDialogManager.showDialogFlow(
    context: context,
    confirmLottie:
        'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
    confirmTitle: S.of(context).restore,
    confirmSubtitle: S.of(context).areYouSureRestore,
    confirmYesText: S.of(context).yes,
    confirmNoText: S.of(context).no,
    onConfirm: () =>
        AppControllers.activeDirectory.restoreBackup(backupVersion),
    successLottie:
        'assets/lottie_assets/main_lottie_assets/lottie_successful.json',
    successTitle: S.of(context).Successful,
    successSubtitle: S.of(context).theBackupHasBeenRestoredSuccessfully,
  );
}

// ════════════════════════════════════════════════════════════════════════════
// RESTORE CARD
// ════════════════════════════════════════════════════════════════════════════

/// Pops with the chosen backup version string, or `null` when dismissed.
class _RestoreBackupDialog extends StatefulWidget {
  const _RestoreBackupDialog({Key? key}) : super(key: key);

  @override
  State<_RestoreBackupDialog> createState() => _RestoreBackupDialogState();
}

class _RestoreBackupDialogState extends State<_RestoreBackupDialog> {
  ActiveDirectoryController get _controller => AppControllers.activeDirectory;

  bool _loading = true;
  String _selectedKey = _kBackupOneKey;
  String _searchQuery = '';

  /// Backs [AppSearchTextField], which takes a controller rather than owning
  /// one — the same arrangement the page's own search bar uses, where the
  /// controller lives on `ActiveDirectoryController`. Here the search is
  /// per-dialog, so the controller is per-dialog too.
  final TextEditingController _searchController = TextEditingController();

  /// Rows in the same shape as `ActiveDirectoryController.usersData`: one
  /// entry per employee, `EmployeeDataItems.values.length` cells wide.
  List<List<dynamic>> _backupOneRows = <List<dynamic>>[];
  List<List<dynamic>> _backupSecondRows = <List<dynamic>>[];

  /// Every field except [EmployeeDataItems.none], which is the enum's padding
  /// entry and has no header name.
  static final List<EmployeeDataItems> _columns = EmployeeDataItems.values
      .where((EmployeeDataItems item) => item != EmployeeDataItems.none)
      .toList();

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBackups() async {
    // Both reads are plain collection gets; nothing here writes.
    final List<List<dynamic>> one =
        await _controller.getBackupTableData(_kBackupOneKey);
    final List<List<dynamic>> second =
        await _controller.getBackupTableData(_kBackupSecondKey);

    if (!mounted) return;
    setState(() {
      _backupOneRows = one;
      _backupSecondRows = second;
      _loading = false;
      // Land on whichever backup has data, so a tenant whose first upload
      // filled only backup one does not open on an empty tab.
      if (_backupOneRows.isEmpty && _backupSecondRows.isNotEmpty) {
        _selectedKey = _kBackupSecondKey;
      }
    });
  }

  // ─── Derived ──────────────────────────────────────────────────────────────

  List<List<dynamic>> get _selectedRows =>
      _selectedKey == _kBackupSecondKey ? _backupSecondRows : _backupOneRows;

  /// [_selectedRows] narrowed by the search box: a row matches when any of its
  /// cells contains the query.
  List<List<dynamic>> get _visibleRows {
    if (_searchQuery.trim().isEmpty) return _selectedRows;
    final String query = _searchQuery.trim().toLowerCase();
    return _selectedRows
        .where((List<dynamic> row) => row.any((dynamic cell) =>
            cell?.toString().toLowerCase().contains(query) ?? false))
        .toList();
  }

  String _cell(List<dynamic> row, EmployeeDataItems item) {
    if (row.length <= item.index) return '';
    return row[item.index]?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final Size screen = MediaQuery.of(context).size;
    final bool isMobile = screen.width < 600;

    return Dialog(
      backgroundColor: isLight ? AppColors.white : AppColors.chatBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.w : 24.w,
        vertical: 24.h,
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        child: SizedBox(
          // Wide by intent: this table carries every employee field.
          width: isMobile ? screen.width : screen.width * 0.85,
          height: screen.height * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(context, isLight),
              SizedBox(height: 16.h),
              if (_loading)
                const Expanded(child: Center(child: CircleProgressMaster()))
              else ...[
                _buildBackupTabs(context),
                SizedBox(height: 12.h),
                _buildSearchField(context),
                SizedBox(height: 12.h),
                Expanded(child: _buildTable(context)),
              ],
              SizedBox(height: 16.h),
              _buildActions(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeaderRow(BuildContext context, bool isLight) {
    return Row(
      children: [
        Container(
          width: 30.sp,
          height: 30.sp,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath: 'assets/icons_assets/watermark/restore.svg',
              width: 18.w,
              height: 18.h,
              fit: BoxFit.contain,
              color: AppColors.textButton,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // REMOVED 30/8/2026: a "choose which backup you want to restore"
        // subtitle sat under the title. The two backup chips directly below it
        // already say that, and in Arabic it wrapped across the title row.
        Expanded(
          child: Text(
            S.of(context).restore,
            style: StyleText.fontSize20Weight500.copyWith(
              color: isLight ? AppColors.blackButton : AppColors.white,
            ),
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.all(4.sp),
            child: Icon(Icons.close_rounded,
                size: 20.sp, color: AppColors.secondaryText),
          ),
        ),
      ],
    );
  }

  // ─── Tabs ─────────────────────────────────────────────────────────────────

  /// One chip per backup collection, using the app's shared chip filter — the
  /// same widget the Users Data / Invalid Data tabs use, so the counts are
  /// already rendered in the reader's numerals.
  ///
  /// The second chip is present only when backup two holds rows. "if found" is
  /// the literal rule here: `backupCollections` writes backup two only from
  /// the second upload onwards, so on most tenants it does not exist yet, and
  /// an always-visible empty tab would read as a bug.
  Widget _buildBackupTabs(BuildContext context) {
    return StatusChipFilter(
      selectedKey: _selectedKey,
      onSelected: (String key) => setState(() {
        _selectedKey = key;
        // Clear the box as well as the query — a term left behind from the
        // other backup would filter the new tab down to nothing.
        _searchQuery = '';
        _searchController.clear();
      }),
      items: <StatusChipItem>[
        StatusChipItem(
          key: _kBackupOneKey,
          label: S.of(context).firstBackup,
          count: _backupOneRows.length,
        ),
        if (_backupSecondRows.isNotEmpty)
          StatusChipItem(
            key: _kBackupSecondKey,
            label: S.of(context).secondBackup,
            count: _backupSecondRows.length,
          ),
      ],
    );
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  /// CHANGED 30/8/2026: this was a hand-rolled search box — its own container,
  /// its own magnifier, its own hint and hint style. It is now
  /// [AppSearchTextField] (core/custom/35-custom_search_widget_custom.dart),
  /// the app's search field, which is what the page's own toolbar uses.
  ///
  /// Two consequences, both intended: the hint is the widget's default
  /// `S.of(context).search` — "Search", not "Search employee..." — and the fill
  /// is `AppColors.card`. `fillColor` is passed explicitly even though it is
  /// also the widget's default, so a later change to that default does not
  /// silently re-skin this field.
  ///
  /// [AppSearchTextField] returns an `Expanded`, so it must sit in a flex —
  /// hence the `Row`, the same way the page's toolbar places it.
  Widget _buildSearchField(BuildContext context) {
    return Row(
      children: [
        AppSearchTextField(
          controller: _searchController,
          onChanged: (String value) => setState(() => _searchQuery = value),
          fillColor: AppColors.card,
        ),
      ],
    );
  }

  // ─── Table ────────────────────────────────────────────────────────────────

  /// Every field of every employee in the selected backup.
  ///
  /// Built by hand rather than with `DataTable`: thirty-one columns need a
  /// fixed cell width and one shared horizontal scroll across header and body,
  /// which is what the page's own table does too.
  Widget _buildTable(BuildContext context) {
    final List<List<dynamic>> rows = _visibleRows;

    if (rows.isEmpty) {
      return Center(
        child: Text(
          _selectedRows.isEmpty
              ? S.of(context).noData
              : S.of(context).noMatchesFound,
          style: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: FontConstants.fontSize014.w,
            color: AppColors.secondaryText,
          ),
        ),
      );
    }

    final String languageCode = Localizations.localeOf(context).languageCode;
    final double tableWidth = _kRestoreCellWidth.sp * _columns.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                height: 44.h,
                color: AppColors.card,
                child: Row(
                  children: _columns
                      .map((EmployeeDataItems item) => _headerCell(
                          item.getLocalizedName(languageCode)))
                      .toList(),
                ),
              ),
              Divider(color: AppColors.border, height: 1),
              // Body
              Expanded(
                child: ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: AppColors.border, height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final List<dynamic> row = rows[index];
                    return Container(
                      height: 44.h,
                      color: index.isEven
                          ? AppColors.background
                          : AppColors.transparent,
                      child: Row(
                        children: _columns
                            .map((EmployeeDataItems item) =>
                                _bodyCell(_cell(row, item)))
                            .toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCell(String label) {
    return SizedBox(
      width: _kRestoreCellWidth.sp,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: FontConstants.fontSize013.w,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyCell(String value) {
    return SizedBox(
      width: _kRestoreCellWidth.sp,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: FontConstants.fontSize013.w,
              color: AppColors.text,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context, bool isMobile) {
    // An empty backup cannot be restored: the data source throws rather than
    // clearing Employees_Info and replacing it with nothing. Hiding the action
    // says so before the user commits to a confirmation.
    final bool canRestore = !_loading && _selectedRows.isNotEmpty;

    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context, rootNavigator: true).pop(),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: isMobile ? 120.sp : 150.sp,
            height: 44.sp,
            decoration: BoxDecoration(
              color: AppColors.secondaryButton,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                S.of(context).discard,
                style: StyleText.fontSize15Weight400
                    .copyWith(color: AppColors.blackButton),
              ),
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: canRestore
              // Pops with the selected version; the caller runs the
              // confirmation and the restore itself.
              ? () => Navigator.of(context, rootNavigator: true)
                  .pop(_selectedKey)
              : null,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: isMobile ? 120.sp : 150.sp,
            height: 44.sp,
            decoration: BoxDecoration(
              color: canRestore ? AppColors.primary : AppColors.greyDark,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                S.of(context).restore,
                style: StyleText.fontSize15Weight400.copyWith(
                  color:
                      canRestore ? AppColors.textButton : AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
