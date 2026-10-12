// ****************** FILE INFO ******************
// File Name: crm_blacklisted_page.dart
// Purpose: Main CRM Blacklisted page with Blocked and Requests tabs, Table/Grid views.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/data/models/crm_blacklist_item_model.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/controller/crm_blacklist_cubit.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/controller/crm_blacklist_state.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/ui/widgets/crm_blacklist_main_tabs.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/ui/widgets/crm_blacklist_status_bar.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/ui/widgets/crm_blacklisted_card.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/ui/widgets/crm_blacklisted_table_view.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_export_documents_dialog.dart';
import 'package:knowticed_plus/features/crm/crm_di.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmBlacklistedPage extends StatefulWidget {
  const CrmBlacklistedPage({super.key});

  @override
  State<CrmBlacklistedPage> createState() => _CrmBlacklistedPageState();
}

class _CrmBlacklistedPageState extends State<CrmBlacklistedPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    registerCrmDependencies();
    _searchController = TextEditingController();
    context.read<CrmBlacklistCubit>().init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleUnblock(CrmBlacklistItemModel item) async {
    final bool confirmed =
        await CrmControlDialogs.showBlacklistConfirmationDialog(
      context: context,
      isRemoval: true,
    );
    if (!confirmed || !mounted) return;

    final bool success = await context.read<CrmBlacklistCubit>().unblockClient(
          recordId: item.recordId,
          reason: 'Unblocked by staff',
        );
    if (success && mounted) {
      CrmControlDialogs.showSuccessDialog(
        context: context,
        title: FormatHelper.localizedString(
          englishName: 'Client Unblocked',
          arabicName: 'تم إلغاء الحظر',
        ),
        subtitle: FormatHelper.localizedString(
          englishName:
              '${item.displayName} is now active and removed from blacklist.',
          arabicName:
              'تم تفعيل ${item.displayName} وإزالته من القائمة السوداء.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Blacklisted',
          arabicName: 'القائمة السوداء',
        ),
        onFirstTap: () => Navigator.pop(context),
        child: BlocConsumer<CrmBlacklistCubit, CrmBlacklistState>(
          listener: (BuildContext context, CrmBlacklistState state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              CrmControlDialogs.showErrorDialog(
                context: context,
                title: FormatHelper.localizedString(
                  englishName: 'Error',
                  arabicName: 'خطأ',
                ),
                subtitle: state.errorMessage!,
              );
              context.read<CrmBlacklistCubit>().clearMessages();
            }
          },
          builder: (BuildContext context, CrmBlacklistState state) {
            final CrmBlacklistCubit cubit = context.read<CrmBlacklistCubit>();
            final List<CrmBlacklistItemModel> visibleItems = cubit.visibleItems;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Top Tabs Switcher: Blocked | Requests
                  CrmBlacklistMainTabs(
                    selectedIndex: state.selectedMainTab,
                    onTabChanged: cubit.setMainTab,
                  ),
                  SizedBox(height: 16.sp),

                  // 2. Requests Status Count Chips (Only in Requests Tab)
                  if (state.selectedMainTab == 1) ...<Widget>[
                    CrmBlacklistStatusBar(
                      totalCount: cubit.totalRequestsCount,
                      pendingCount: cubit.pendingRequestsCount,
                      approvedCount: cubit.approvedRequestsCount,
                      rejectedCount: cubit.rejectedRequestsCount,
                      selectedStatus: state.requestStatusFilter,
                      onStatusSelected: cubit.setRequestStatusFilter,
                    ),
                    SizedBox(height: 16.sp),
                  ],

                  // 3. Search & Sort Bar Row
                  _buildSearchSortRow(state, cubit),
                  SizedBox(height: 12.sp),

                  // 4. Secondary Toolbar: Client Type Filter (Left) & Export / Grid-Table View (Right)
                  _buildSecondaryToolbar(state, cubit),
                  SizedBox(height: 16.sp),

                  // 5. Body Content (Loading / Empty / Table / Grid)
                  if (state.isLoading && state.items.isEmpty)
                    Container(
                      width: double.infinity,
                      height: 250.sp,
                      alignment: Alignment.center,
                      child: const CircleProgressMaster(),
                    )
                  else if (visibleItems.isEmpty)
                    _buildEmptyState(state)
                  else if (state.isGridView)
                    _buildGridView(visibleItems, state.selectedMainTab == 1)
                  else
                    _buildTableView(visibleItems),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  2. Search & Sort Row
  // ─────────────────────────────────────────────
  Widget _buildSearchSortRow(CrmBlacklistState state, CrmBlacklistCubit cubit) {
    return Row(
      children: <Widget>[
        // Search Input
        Expanded(
          child: Container(
            height: 38.sp,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderCard),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.sp),
            child: Row(
              children: <Widget>[
                CustomSvgImage(
                  assetPath: AppAssets.search,
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.darkGrey,
                ),
                SizedBox(width: 8.sp),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: cubit.setSearchQuery,
                    style: StyleText.fontSize14Weight400,
                    decoration: InputDecoration(
                      hintText: FormatHelper.localizedString(
                        englishName: 'Search',
                        arabicName: 'بحث',
                      ),
                      hintStyle: StyleText.fontSize14Weight400.copyWith(
                        color: AppColors.darkGrey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      cubit.setSearchQuery('');
                    },
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: AppColors.darkGrey,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10.sp),

        // Sort Popup Button
        PopupMenuButton<String>(
          onSelected: cubit.setSortOption,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'newest',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Newest First',
                  arabicName: 'الأحدث أولاً',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'oldest',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Oldest First',
                  arabicName: 'الأقدم أولاً',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'name_asc',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Name (A - Z)',
                  arabicName: 'الاسم (أ - ي)',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'name_desc',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Name (Z - A)',
                  arabicName: 'الاسم (ي - أ)',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
          ],
          child: Container(
            height: 38.sp,
            padding: EdgeInsets.symmetric(horizontal: 14.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderCard),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomSvgImage(
                  assetPath: AppAssets.sort,
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.darkGrey,
                ),
                SizedBox(width: 8.sp),
                Text(
                  FormatHelper.localizedString(
                    englishName: 'Sort',
                    arabicName: 'ترتيب',
                  ),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  3. Secondary Toolbar: Type Dropdown & Actions
  // ─────────────────────────────────────────────
  Widget _buildSecondaryToolbar(
      CrmBlacklistState state, CrmBlacklistCubit cubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Left: Client Type Dropdown
        PopupMenuButton<String>(
          onSelected: cubit.setSelectedClientType,
          color: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'All',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'All Types',
                  arabicName: 'جميع الأنواع',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'Person',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Person',
                  arabicName: 'فرد',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'Company',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Company',
                  arabicName: 'شركة',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'Government',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Government',
                  arabicName: 'حكومي',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
          ],
          child: Container(
            height: 38.sp,
            padding: EdgeInsets.symmetric(horizontal: 14.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.borderCard),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  state.selectedClientType == 'All'
                      ? FormatHelper.localizedString(
                          englishName: 'Client Type',
                          arabicName: 'نوع العميل',
                        )
                      : state.selectedClientType,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(width: 10.sp),
                CustomSvgImage(
                  assetPath: AppAssets.arrowDown,
                  width: 14.sp,
                  height: 14.sp,
                  color: AppColors.darkGrey,
                ),
              ],
            ),
          ),
        ),

        // Right: Export & Grid/Table Switcher
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Export Button
            customButtonWithSvg(
              title: FormatHelper.localizedString(
                englishName: 'Export',
                arabicName: 'تصدير',
              ),
              function: () {
                showExportDocumentsDialog(
                  context: context,
                  defaultFileName: 'CRM_Blacklisted_Clients',
                  onSubmit: (String fileName) {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: FormatHelper.localizedString(
                        englishName: 'Exported Successfully',
                        arabicName: 'تم التصدير بنجاح',
                      ),
                      subtitle: FormatHelper.localizedString(
                        englishName:
                            'Exported ${cubit.visibleItems.length} records as "$fileName"',
                        arabicName:
                            'تم تصدير ${cubit.visibleItems.length} سجلات باسم "$fileName"',
                      ),
                    );
                  },
                );
              },
              image: AppAssets.export,
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: AppColors.black,
              ),
              widthImage: 16.sp,
              heightImage: 16.sp,
            ),
            SizedBox(width: 10.sp),

            // Grid View Button
            customGridButton(
              isSelected: state.isGridView,
              color: AppColors.card,
              function: () => cubit.setGridView(true),
            ),
            SizedBox(width: 6.sp),

            // Table View Button
            customTableButton(
              isSelected: !state.isGridView,
              color: AppColors.card,
              function: () => cubit.setGridView(false),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  4. Content Views: Table / Grid / Empty
  // ─────────────────────────────────────────────
  Widget _buildTableView(List<CrmBlacklistItemModel> items) {
    return CrmBlacklistedTableView(
      items: items,
      onItemTap: _handleItemClick,
    );
  }

  Widget _buildGridView(
      List<CrmBlacklistItemModel> items, bool showStatusBadge) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisExtent: 96.sp,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmBlacklistItemModel item = items[index];
        return CrmBlacklistedCard(
          item: item,
          showStatusBadge: showStatusBadge,
          onTap: () => _handleItemClick(item),
        );
      },
    );
  }

  void _handleItemClick(CrmBlacklistItemModel item) {
    // Show actions sheet / dialog: View Profile or Unblock
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.displayName,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 4.sp),
            Text(
              '${item.clientType} • ${item.reason}',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: 16.sp),
            ListTile(
              leading: Icon(Icons.person_outline, color: AppColors.primary),
              title: Text(
                FormatHelper.localizedString(
                  englishName: 'View Client Profile',
                  arabicName: 'عرض ملف العميل',
                ),
                style: StyleText.fontSize14Weight500,
              ),
              onTap: () {
                Navigator.pop(ctx);
                CrmNavigationHelper.navigateToClientProfile(
                  context,
                  recordId: item.recordId,
                  clientType: item.clientType,
                  clientTypeId: item.clientTypeId,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.lock_open, color: AppColors.green),
              title: Text(
                FormatHelper.localizedString(
                  englishName: 'Unblock / Remove from Blacklist',
                  arabicName: 'إلغاء الحظر / الإزالة من القائمة السوداء',
                ),
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.green,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _handleUnblock(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(CrmBlacklistState state) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.sp, horizontal: 20.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomSvgImage(
            assetPath: AppAssets.crmBlacklist,
            width: 48.sp,
            height: 48.sp,
            color: AppColors.darkGrey,
          ),
          SizedBox(height: 14.sp),
          Text(
            state.selectedMainTab == 0
                ? FormatHelper.localizedString(
                    englishName: 'No Blocked Clients Found',
                    arabicName: 'لا يوجد عملاء محظورين',
                  )
                : FormatHelper.localizedString(
                    englishName: 'No Blacklist Requests Found',
                    arabicName: 'لا توجد طلبات حظر',
                  ),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 6.sp),
          Text(
            FormatHelper.localizedString(
              englishName:
                  'All blacklisted client records and requests will appear here.',
              arabicName: 'جميع سجلات وطلبات الحظر الخاصة بالعملاء ستظهر هنا.',
            ),
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
