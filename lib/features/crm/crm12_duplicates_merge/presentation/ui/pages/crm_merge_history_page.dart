// ****************** FILE INFO ******************
// File Name: crm_merge_history_page.dart
// Purpose: History list page displaying past merge operations in a 2-column grid matching Figma screenshot 1
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_state.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_merge_history_details_page.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_duplicates_empty_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:intl/intl.dart';

class CrmMergeHistoryPage extends StatefulWidget {
  const CrmMergeHistoryPage({super.key});

  @override
  State<CrmMergeHistoryPage> createState() => _CrmMergeHistoryPageState();
}

class _CrmMergeHistoryPageState extends State<CrmMergeHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSort = 'Default';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmClients,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Duplicates Review & Merge',
          arabicName: 'مراجعة ودمج المكررات',
        ),
        thirdTitle: FormatHelper.localizedString(
          englishName: 'History',
          arabicName: 'سجل الدمج',
        ),
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: BlocBuilder<CrmDuplicatesCubit, CrmDuplicatesState>(
          builder: (BuildContext context, CrmDuplicatesState state) {
            final CrmDuplicatesCubit cubit = context.read<CrmDuplicatesCubit>();

            List<CrmMergeHistoryModel> list = state.mergeHistory.where((h) {
              if (_searchQuery.trim().isEmpty) return true;
              final String q = _searchQuery.trim().toLowerCase();
              return h.masterClientName.toLowerCase().contains(q) ||
                  h.mergedClientName.toLowerCase().contains(q) ||
                  h.mergedBy.toLowerCase().contains(q);
            }).toList();

            if (_selectedSort == 'Name (A-Z)') {
              list.sort(
                  (a, b) => a.masterClientName.compareTo(b.masterClientName));
            } else if (_selectedSort == 'Date (Newest First)') {
              list.sort((a, b) => b.mergedAt.compareTo(a.mergedAt));
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Search & Sort Toolbar
                  CustomSearchFilterSortBar<String, String>(
                    searchController: _searchController,
                    searchHint: FormatHelper.localizedString(
                      englishName: 'Search',
                      arabicName: 'بحث',
                    ),
                    onSearchChanged: (val) =>
                        setState(() => _searchQuery = val),
                    showFilter: false,
                    showSort: true,
                    sortItems: const [
                      'Default',
                      'Date (Newest First)',
                      'Name (A-Z)',
                    ],
                    selectedSort: _selectedSort,
                    sortLabelBuilder: (String item) => item,
                    onSortChanged: (String? val) {
                      if (val != null) setState(() => _selectedSort = val);
                    },
                    fillColor: AppColors.card,
                  ),
                  SizedBox(height: 20.sp),

                  // 2. 2-Column Grid of History Cards
                  if (list.isEmpty)
                    const CrmDuplicatesEmptyState(isSearchEmpty: true)
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 1 : 2,
                        mainAxisExtent: 72.sp,
                        crossAxisSpacing: 16.sp,
                        mainAxisSpacing: 12.sp,
                      ),
                      itemCount: list.length,
                      itemBuilder: (BuildContext ctx, int i) {
                        final CrmMergeHistoryModel item = list[i];
                        return _buildHistoryCard(item, cubit);
                      },
                    ),

                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
      CrmMergeHistoryModel item, CrmDuplicatesCubit cubit) {
    final String formattedDate = DateFormat('d/M/yyyy').format(item.mergedAt);
    final String formattedTime = DateFormat('h:mm a').format(item.mergedAt);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => BlocProvider.value(
              value: cubit,
              child: CrmMergeHistoryDetailsPage(history: item),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: <Widget>[
            // 1. Left Icon Container
            Container(
              width: 42.sp,
              height: 42.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmRecord,
                width: 22.sp,
                height: 22.sp,
                color: AppColors.black,
              ),
            ),
            SizedBox(width: 12.sp),

            // 2. Client Name & Record Count Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.masterClientName,
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    '3 Record',
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.sp),

            // 3. Right: Date & Time
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  formattedDate,
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: 2.sp),
                Text(
                  formattedTime,
                  style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack).copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
