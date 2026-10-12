/// Module: roles / r4_active_directory / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: csv_table_builders2.dart
/// Purpose: Declares `CsvTableBuilders2`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/custom_csv_table_page.dart';

extension CsvTableBuilders2 on CustomCsvTable {
  Widget _buildEditBottomBar(
      ActiveDirectoryController controller,
      BuildContext context,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.012.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => controller.discardAllChanges(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                S.of(context).discardChange,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize013.w,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              controller.isEditMode = false;
              controller.refresh();
              await CustomDialogManager.showMessage(
                context: context,
                title: 'Editing Active Directory',
                subtitle: 'You Successfully Edited Active Directory',
                lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_successful.json',
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                S.of(context).Save,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize013.w,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Error filter chips ───────────────────────────────────────────────────

  Widget _buildErrorChips(ActiveDirectoryController controller) {
    final bool hasErrors = controller.invalidFieldsCount > 0;
    const chipLabels = [
      'Missing Values',
      'Language Mandatory',
      'Duplication',
      'Date Expiration',
      'Non-Numeric',
      'Format',
      'Not Assigned',
      'Trailing Whitespaces',
      'Timezone Mismatch',
      'Special Characters Not Allowed',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: hasErrors ? AppColors.red : AppColors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Total Errors: ${controller.invalidFieldsCount}',
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize012.w,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
          ...chipLabels.map(
                (label) => Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                label,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize012.w,
                  color: AppColors.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Table area ───────────────────────────────────────────────────────────

  Widget _buildTableArea(
      ActiveDirectoryController controller,
      BuildContext context,
      bool isVertical,
      ) {
    // Use filtered list for tab-0 when filters/search are active
    final displayData = controller.hasActiveFilters || controller.searchQuery.isNotEmpty
        ? controller.filteredUsersData
        : controller.usersData;

    final isEmpty = (controller.selectedIndex == 1 &&
        controller.rowInvalid.isEmpty) ||
        (controller.selectedIndex == 0 && displayData.isEmpty);

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lottie_assets/roles_lottie_assets/no_data.json"),
            SizedBox(height: 0.04.h),
            Text(
              S.of(context).noWrongDataFound,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize022.w,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicWidth(
        child: Container(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.selectedIndex == 1)
                WrongData(isVertical)
              else
              // Pass filtered data so the table renders the right rows
                UserData(isVertical, data: displayData),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// FILTER PANEL
// ════════════════════════════════════════════════════════════════════════════

void _showFilterPanel(BuildContext context) {
  final controller = AppControllers.activeDirectory;

  // Extract unique sorted values from a column; returns [] for invalid index
  List<String> extract(int columnIndex) {
    if (columnIndex < 0) return [];
    return controller.usersData
        .map((row) => row.length > columnIndex
        ? (row[columnIndex]?.toString().trim() ?? '')
        : '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  showDialog(
    context: context,
    builder: (_) => _ActiveDirectoryFilterDialog(
      // Pre-populate current selections so re-opening shows previous state
      initialDepartment:   controller.filterDepartment,
      initialRole:         controller.filterRole,
      initialTitle:        controller.filterTitle,
      initialWorkLocation: controller.filterWorkLocation,
      initialSupervisor:   controller.filterSupervisor,
      initialGender:       controller.filterGender,
      initialNationality:  controller.filterNationality,
      initialCountry:      controller.filterCountry,
      // Dropdown options from real data
      departments:   extract(_ColumnIndex.department),
      roles:         extract(_ColumnIndex.role),
      titles:        extract(_ColumnIndex.title),
      workLocations: extract(_ColumnIndex.workLocation),
      supervisors:   extract(_ColumnIndex.supervisor),
      genders:       extract(_ColumnIndex.gender),
      nationalities: extract(_ColumnIndex.nationality), // [] — not in CSV
      countries:     extract(_ColumnIndex.country),
    ),
  );
}
