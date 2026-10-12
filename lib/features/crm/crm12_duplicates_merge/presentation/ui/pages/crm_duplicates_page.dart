// ****************** FILE INFO ******************
// File Name: crm_duplicates_page.dart
// Purpose: Main CRM Duplicates Review & Merge page with SideFrameMasterServices, StatusChipFilter, search bar, and cards grid matching Figma
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/enums/crm_duplicates_enums.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_state.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_merge_history_details_page.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_merge_history_page.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_merge_wizard_page.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_duplicate_card.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_duplicates_empty_state.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_how_it_works_dialog.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merged_record_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDuplicatesPage extends StatefulWidget {
  const CrmDuplicatesPage({super.key});

  @override
  State<CrmDuplicatesPage> createState() => _CrmDuplicatesPageState();
}

class _CrmDuplicatesPageState extends State<CrmDuplicatesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Duplicates Review & Merge',
          arabicName: 'مراجعة ودمج المكررات',
        ),
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: BlocBuilder<CrmDuplicatesCubit, CrmDuplicatesState>(
          builder: (BuildContext context, CrmDuplicatesState state) {
            final CrmDuplicatesCubit cubit = context.read<CrmDuplicatesCubit>();
            final bool isDuplicateTab =
                state.activeTab == CrmDuplicatesTab.duplicate;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Toolbar Row: Switch Toggle & Action Buttons (How it Work / History)
                  _buildToolbarRow(context, state, cubit),
                  SizedBox(height: 16.sp),

                  // 2. Status Chips Filter Bar (Only in Duplicate tab)
                  if (isDuplicateTab) ...[
                    _buildStatusFilter(state, cubit),
                    SizedBox(height: 18.sp),
                  ],

                  // 3. Search & Filter & Sort Bar
                  CustomSearchFilterSortBar<String, String>(
                    searchController: _searchController,
                    searchHint: FormatHelper.localizedString(
                      englishName: 'Search',
                      arabicName: 'بحث',
                    ),
                    onSearchChanged: cubit.setSearchQuery,
                    showFilter: isDuplicateTab,
                    filterItems: <String>[
                      'All',
                      ...state.mergeLevels.map(
                        (level) => 'level:${level.id}',
                      ),
                    ],
                    selectedFilter: state.selectedFilter,
                    filterLabelBuilder: (String item) => item == 'All'
                        ? FormatHelper.localizedString(
                            englishName: 'All', arabicName: 'الكل')
                        : _mergeLevelName(
                            state, item.substring('level:'.length)),
                    onFilterChanged: (String? val) {
                      if (val != null) cubit.setSelectedFilter(val);
                    },
                    showSort: true,
                    sortItems: isDuplicateTab
                        ? const <String>[
                            'Default',
                            'Match % (High to Low)',
                            'Match % (Low to High)',
                            'Name (A-Z)',
                          ]
                        : const <String>[
                            'Default',
                            'Date (Newest First)',
                            'Name (A-Z)',
                          ],
                    selectedSort: state.selectedSort,
                    sortLabelBuilder: (String item) => item,
                    onSortChanged: (String? val) {
                      if (val != null) cubit.setSelectedSort(val);
                    },
                    fillColor: AppColors.white,
                  ),
                  SizedBox(height: 18.sp),

                  // 4. Content: Loading / Empty State / 2-Column Cards Grid
                  if (state.isLoading)
                    const Center(child: CircleProgressMaster())
                  else if (isDuplicateTab && state.filteredPairs.isEmpty)
                    CrmDuplicatesEmptyState(
                      isSearchEmpty: state.searchQuery.isNotEmpty ||
                          (isDuplicateTab && state.selectedFilter != 'All'),
                    )
                  else if (!isDuplicateTab &&
                      state.filteredMergeHistory.isEmpty)
                    CrmDuplicatesEmptyState(
                      isSearchEmpty: state.searchQuery.isNotEmpty,
                      isMergeHistory: true,
                    )
                  else if (isDuplicateTab)
                    _buildDuplicatesGrid(context, state, cubit)
                  else
                    _buildMergedHistoryGrid(context, state, cubit),

                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolbarRow(
    BuildContext context,
    CrmDuplicatesState state,
    CrmDuplicatesCubit cubit,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Switch Toggle (Duplicate / Merge)
        Container(
          height: 38.sp,
          padding: EdgeInsets.all(3.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTabButton(
                title: FormatHelper.localizedString(
                  englishName: 'Duplicate',
                  arabicName: 'المكررات',
                ),
                isSelected: state.activeTab == CrmDuplicatesTab.duplicate,
                onTap: () => cubit.setActiveTab(CrmDuplicatesTab.duplicate),
              ),
              _buildTabButton(
                title: FormatHelper.localizedString(
                  englishName: 'Merge',
                  arabicName: 'الدمج',
                ),
                isSelected: state.activeTab == CrmDuplicatesTab.merge,
                onTap: () => cubit.setActiveTab(CrmDuplicatesTab.merge),
              ),
            ],
          ),
        ),

        // Right Actions: How it Work & History Buttons
        Builder(
          builder: (BuildContext context) {
            final bool isMobile = MediaQuery.of(context).size.width < 600;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // How it Work Button
                InkWell(
                  onTap: () => CrmHowItWorksDialog.show(context),
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    width: isMobile ? 36.sp : null,
                    height: 36.sp,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 14.sp,
                      vertical: 8.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomSvgImage(
                          assetPath: AppAssets.crmHowItWork,
                          width: 16.sp,
                          height: 16.sp,
                          color: AppColors.text,
                        ),
                        if (!isMobile) ...<Widget>[
                          SizedBox(width: 6.sp),
                          Text(
                            FormatHelper.localizedString(
                              englishName: 'How it Work',
                              arabicName: 'كيف تعمل',
                            ),
                            style:
                                StyleText.fontSize12Weight500.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),

                // History Button
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => BlocProvider.value(
                          value: cubit,
                          child: const CrmMergeHistoryPage(),
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    width: isMobile ? 36.sp : null,
                    height: 36.sp,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 14.sp,
                      vertical: 8.sp,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CustomSvgImage(
                          assetPath: AppAssets.crmHistory,
                          width: 16.sp,
                          height: 16.sp,
                          color: AppColors.text,
                        ),
                        if (!isMobile) ...<Widget>[
                          SizedBox(width: 6.sp),
                          Text(
                            FormatHelper.localizedString(
                              englishName: 'History',
                              arabicName: 'سجل الدمج',
                            ),
                            style:
                                StyleText.fontSize12Weight500.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 6.sp),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          title,
          style: StyleText.fontSize14Weight500.copyWith(
            color: isSelected ? AppColors.text : AppColors.darkGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter(
    CrmDuplicatesState state,
    CrmDuplicatesCubit cubit,
  ) {
    return StatusChipFilter(
      selectedKey: state.selectedFilter,
      onSelected: cubit.setSelectedFilter,
      selectedColor: AppColors.primary,
      selectedCountTextColor: AppColors.text,
      unselectedColor: AppColors.card,
      chipSpacing: 24.sp,
      innerSpacing: 12.sp,
      chipSize: 42.sp,
      items: <StatusChipItem>[
        StatusChipItem(
          key: 'All',
          label: FormatHelper.localizedString(
            englishName: 'All',
            arabicName: 'الكل',
          ),
          count: state.totalCount,
          labelColor: AppColors.text,
        ),
        ...state.mergeLevels.map(
          (level) => StatusChipItem(
            key: 'level:${level.id}',
            label: level.displayName,
            count: state.pendingCountByMergeLevel[level.id] ?? 0,
            labelColor: AppColors.text,
          ),
        ),
      ],
    );
  }

  String _mergeLevelName(CrmDuplicatesState state, String levelId) {
    return state.mergeLevels
        .firstWhere((level) => level.id == levelId)
        .displayName;
  }

  Widget _buildDuplicatesGrid(
    BuildContext context,
    CrmDuplicatesState state,
    CrmDuplicatesCubit cubit,
  ) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    final int crossAxisCount = isMobile ? 1 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 72.sp,
        crossAxisSpacing: 16.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: state.filteredPairs.length,
      itemBuilder: (BuildContext ctx, int index) {
        final CrmDuplicatePairModel pair = state.filteredPairs[index];
        return CrmDuplicateCard(
          pair: pair,
          onReviewMerge: () {
            cubit.startMergeWizard(pair);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => BlocProvider.value(
                  value: cubit,
                  child: const CrmMergeWizardPage(),
                ),
              ),
            );
          },
          onIgnore: () => cubit.ignorePair(pair.id),
        );
      },
    );
  }

  Widget _buildMergedHistoryGrid(
    BuildContext context,
    CrmDuplicatesState state,
    CrmDuplicatesCubit cubit,
  ) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        mainAxisExtent: 72.sp,
        crossAxisSpacing: 16.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: state.filteredMergeHistory.length,
      itemBuilder: (BuildContext itemContext, int index) {
        final CrmMergeHistoryModel history = state.filteredMergeHistory[index];
        return CrmMergedRecordCard(
          history: history,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext routeContext) => BlocProvider.value(
                value: cubit,
                child: CrmMergeHistoryDetailsPage(history: history),
              ),
            ),
          ),
        );
      },
    );
  }
}
