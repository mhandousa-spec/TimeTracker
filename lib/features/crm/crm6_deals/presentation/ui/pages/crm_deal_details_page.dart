// ****************** FILE INFO ******************
// File Name: crm_deal_details_page.dart
// Purpose: Deal Details full page container hosting Overview, Products, Services, and other deal tabs with CustomTabs and CustomDeleteIcon
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_activities_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_overview_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_products_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_quotes_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_services_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_contract_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_documents_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_timeline_tab.dart';

class CrmDealDetailsPage extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealDetailsPage({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealDetailsPage> createState() => _CrmDealDetailsPageState();
}

class _CrmDealDetailsPageState extends State<CrmDealDetailsPage> {
  int _selectedTabIndex = 0;
  late String _currentStage;

  static const List<String> _tabTitles = <String>[
    'Overview',
    'Products',
    'Services',
    'Quotes',
    'Activities',
    'Timeline',
    'Documents',
    'Contract',
  ];

  static const List<Map<String, String>> _dealStages = <Map<String, String>>[
    <String, String>{'key': 'new', 'label': 'New'},
    <String, String>{'key': 'discovery', 'label': 'Discovery'},
    <String, String>{'key': 'qualified', 'label': 'Qualified'},
    <String, String>{'key': 'proposal', 'label': 'Proposal'},
    <String, String>{'key': 'negotiation', 'label': 'Negotiation'},
    <String, String>{'key': 'closedLost', 'label': 'Closed Lost'},
    <String, String>{'key': 'closedWon', 'label': 'Closed Won'},
  ];

  @override
  void initState() {
    super.initState();
    _currentStage = widget.deal.stage;
  }

  String _getStageLabel(String key) {
    final Map<String, String> match = _dealStages.firstWhere(
      (Map<String, String> s) => s['key'] == key,
      orElse: () => <String, String>{'key': key, 'label': key.toUpperCase()},
    );
    return match['label']!;
  }

  void _onDeleteDeal() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Delete Deal',
        arabicName: 'حذف الصفقة',
      ),
      subtitle: FormatHelper.localizedString(
        englishName:
            'Are you sure you want to delete this deal? This action cannot be undone.',
        arabicName:
            'هل أنت متأكد من رغبتك في حذف هذه الصفقة؟ لا يمكن التراجع عن هذا الإجراء.',
      ),
      onConfirm: () {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // return from details page
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dealTitle = widget.deal.dealNameEn.isNotEmpty
        ? widget.deal.dealNameEn
        : 'ERP System Deal';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: FormatHelper.localizedString(
          englishName: 'Client Profile',
          arabicName: 'ملف العميل',
        ),
        secondTitle: FormatHelper.localizedString(
          englishName: 'Deals',
          arabicName: 'الصفقات',
        ),
        thirdTitle: dealTitle,
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── 1. Top Controls Bar: Stage Dropdown + CustomDeleteIcon ────
              _buildTopControlsBar(context),

              SizedBox(height: 20.sp),

              // ── 2. Reusable CustomTabs Bar (matching Client Profile page) ─
              CustomTabs(
                tabs: _tabTitles,
                selectedValue: _selectedTabIndex,
                spacing: 24.sp,
                onChanged: (int index) =>
                    setState(() => _selectedTabIndex = index),
              ),

              SizedBox(height: 24.sp),

              // ── 3. Active Tab Content ───────────────────────────────────────
              _buildActiveTabContent(context),

              SizedBox(height: 24.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControlsBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Stage Selector Dropdown Button
        PopupMenuButton<String>(
          onSelected: (String stage) => setState(() => _currentStage = stage),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          itemBuilder: (BuildContext context) {
            return _dealStages.map((Map<String, String> s) {
              return PopupMenuItem<String>(
                value: s['key'],
                child: Text(
                  s['label']!,
                  style: StyleText.fontSize14Weight400,
                ),
              );
            }).toList();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _getStageLabel(_currentStage),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8.sp),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.white,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),

        // Pre-built Custom Delete Button
        CustomDeleteIcon(
          title: FormatHelper.localizedString(
            englishName: 'Delete',
            arabicName: 'حذف',
          ),
          color: const Color(0xFFDC2626),
          borderColor: Colors.transparent,
          svgColor: AppColors.white,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
          onTap: _onDeleteDeal,
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    switch (_selectedTabIndex) {
      case 0:
        return CrmDealOverviewTab(
          deal: widget.deal,
          onSave: () {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: FormatHelper.localizedString(
                englishName: 'Saved Successfully',
                arabicName: 'تم الحفظ بنجاح',
              ),
              subtitle: FormatHelper.localizedString(
                englishName: 'Deal details have been updated.',
                arabicName: 'تم تحديث تفاصيل الصفقة.',
              ),
            );
          },
        );
      case 1:
        return CrmDealProductsTab(deal: widget.deal);
      case 2:
        return CrmDealServicesTab(deal: widget.deal);
      case 3:
        return CrmDealQuotesTab(deal: widget.deal);
      case 4:
        return CrmDealActivitiesTab(deal: widget.deal);
      case 5:
        return CrmDealTimelineTab(deal: widget.deal);
      case 6:
        return CrmDealDocumentsTab(deal: widget.deal);
      case 7:
        return CrmDealContractTab(deal: widget.deal);
      default:
        return Container(
          padding: EdgeInsets.all(32.sp),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
          ),
          alignment: Alignment.center,
          child: Text(
            'No items in this section yet.',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        );
    }
  }
}
