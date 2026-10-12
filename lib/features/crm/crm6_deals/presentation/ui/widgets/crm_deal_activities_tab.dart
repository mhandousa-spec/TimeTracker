// ****************** FILE INFO ******************
// File Name: crm_deal_activities_tab.dart
// Purpose: Activities tab content for Deal Details page with status badges, search/sort/filter bar, Export, Grid/Table view switchers matching Figma screenshots 1, 4, 5
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_deal_add_activity_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activities_filter_badges_bar.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activities_table_view.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activity_card.dart';

class CrmDealActivitiesTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealActivitiesTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealActivitiesTab> createState() => _CrmDealActivitiesTabState();
}

class _CrmDealActivitiesTabState extends State<CrmDealActivitiesTab> {
  final TextEditingController _searchController = TextEditingController();
  CrmDealActivityStatus _selectedStatusFilter = CrmDealActivityStatus.all;
  bool _isGridView = true;

  final List<CrmDealActivityModel> _allActivities = <CrmDealActivityModel>[
    const CrmDealActivityModel(
      id: '1',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.scheduled,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
    const CrmDealActivityModel(
      id: '2',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.inProgress,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
    const CrmDealActivityModel(
      id: '3',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.completed,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
    const CrmDealActivityModel(
      id: '4',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.cancelled,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
    const CrmDealActivityModel(
      id: '5',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.scheduled,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
    const CrmDealActivityModel(
      id: '6',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.completed,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
    const CrmDealActivityModel(
      id: '7',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.completed,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
    const CrmDealActivityModel(
      id: '8',
      no: 1,
      categoryName: 'IT',
      activityType: 'Call',
      subjectEn: 'Connect',
      subjectAr: 'الاتصال',
      assigneeName: 'Aya Ali',
      assigneeRole: 'CEO',
      dueDate: '7/12/2026',
      time: '11:30',
      tags: 'Deals',
      status: CrmDealActivityStatus.scheduled,
      noteEn: "it's ................",
      noteAr: 'إنه كذلك ................',
    ),
  ];

  static const List<String> _sortOptions = <String>[
    'Recent',
    'Oldest',
    'Type',
    'Assignee',
    'Due Date',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CrmDealActivityModel> get _filteredActivities {
    return _allActivities.where((CrmDealActivityModel item) {
      if (_selectedStatusFilter != CrmDealActivityStatus.all &&
          item.status != _selectedStatusFilter) {
        return false;
      }
      if (_searchController.text.trim().isNotEmpty) {
        final String q = _searchController.text.trim().toLowerCase();
        final bool matchesCategory =
            item.categoryName.toLowerCase().contains(q);
        final bool matchesType = item.activityType.toLowerCase().contains(q);
        final bool matchesSubject = item.subjectEn.toLowerCase().contains(q) ||
            item.subjectAr.toLowerCase().contains(q);
        final bool matchesAssignee =
            item.assigneeName.toLowerCase().contains(q);
        if (!matchesCategory &&
            !matchesType &&
            !matchesSubject &&
            !matchesAssignee) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _onAddNewActivity() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmDealAddActivityPage(
          dealTitle: widget.deal.dealNameEn.isNotEmpty
              ? widget.deal.dealNameEn
              : 'ERP System Deal',
          mode: 'add',
          onActivityAdded: (CrmDealActivityModel newActivity) {
            setState(() {
              _allActivities.insert(0, newActivity);
            });
          },
        ),
      ),
    );
  }

  void _onOpenActivityDetails(CrmDealActivityModel item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmDealAddActivityPage(
          dealTitle: widget.deal.dealNameEn.isNotEmpty
              ? widget.deal.dealNameEn
              : 'ERP System Deal',
          mode: 'view',
          activity: item,
          onActivityUpdated: (CrmDealActivityModel updated) {
            setState(() {
              final int index = _allActivities
                  .indexWhere((CrmDealActivityModel a) => a.id == updated.id);
              if (index != -1) {
                _allActivities[index] = updated;
              }
            });
          },
          onActivityDeleted: (String id) {
            setState(() {
              _allActivities
                  .removeWhere((CrmDealActivityModel a) => a.id == id);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CrmDealActivityModel> displayList = _filteredActivities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. KPI Filter Badges Bar via StatusChipFilter ──────────────────────
        CrmDealActivitiesFilterBadgesBar(
          selectedStatus: _selectedStatusFilter,
          onStatusSelected: (CrmDealActivityStatus status) =>
              setState(() => _selectedStatusFilter = status),
          allCount: 200,
          scheduledCount: 20,
          inProgressCount: 20,
          completedCount: 20,
          cancelledCount: 20,
        ),

        SizedBox(height: 18.sp),

        // ── 2. Search, Filter, Sort & + Add Bar ───────────────────────────────
        CustomSearchFilterSortBar<String, String>(
          searchController: _searchController,
          onSearchChanged: (_) => setState(() {}),
          searchHint: 'Search',
          showFilter: true,
          onFilterTap: () {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: 'Filter Activities',
              subtitle: 'Filter options dialog.',
            );
          },
          showSort: true,
          sortItems: _sortOptions,
          selectedSort: 'Recent',
          sortLabelBuilder: (String item) => item,
          onSortChanged: (String? sort) {},
          trailingChildren: <Widget>[
            customButtonWithSvg(
              title: FormatHelper.localizedString(
                englishName: 'Add',
                arabicName: 'إضافة',
              ),
              image: AppAssets.add,
              widthImage: 14.sp,
              heightImage: 14.sp,
              colorBorder: Colors.transparent,
              color: AppColors.primary,
              textStyle: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
              function: _onAddNewActivity,
            ),
          ],
          fillColor: AppColors.white,
        ),

        SizedBox(height: 14.sp),

        // ── 3. Secondary Toolbar (Export + Grid/Table Toggle) ─────────────────
        _buildViewToggleBar(),

        SizedBox(height: 16.sp),

        // ── 4. Main Content: Grid View or Table View ──────────────────────────
        if (displayList.isEmpty)
          Container(
            height: 200.sp,
            alignment: Alignment.center,
            child: Text(
              FormatHelper.localizedString(
                englishName: 'No activities found.',
                arabicName: 'لا توجد أنشطة.',
              ),
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          )
        else if (_isGridView)
          _buildGridView(displayList)
        else
          CrmDealActivitiesTableView(
            activities: displayList,
            onActivityTap: _onOpenActivityDetails,
          ),
      ],
    );
  }

  Widget _buildViewToggleBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        // Export Button
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Export',
            arabicName: 'تصدير',
          ),
          image: AppAssets.export,
          widthImage: 14.sp,
          heightImage: 14.sp,
          colorBorder: Colors.transparent,
          color: AppColors.primary,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
          function: () {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: 'Export Activities',
              subtitle: 'Exporting activities to Excel sheet.',
            );
          },
        ),

        SizedBox(width: 12.sp),

        // Grid Button
        customGridButton(
          isSelected: _isGridView,
          color: AppColors.white,
          function: () => setState(() => _isGridView = true),
        ),

        SizedBox(width: 8.sp),

        // Table Button
        customTableButton(
          isSelected: !_isGridView,
          color: AppColors.white,
          function: () => setState(() => _isGridView = false),
        ),
      ],
    );
  }

  Widget _buildGridView(List<CrmDealActivityModel> list) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 96.sp,
            crossAxisSpacing: 12.sp,
            mainAxisSpacing: 12.sp,
          ),
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            final CrmDealActivityModel item = list[index];
            return CrmDealActivityCard(
              activity: item,
              onTap: () => _onOpenActivityDetails(item),
            );
          },
        );
      },
    );
  }
}
