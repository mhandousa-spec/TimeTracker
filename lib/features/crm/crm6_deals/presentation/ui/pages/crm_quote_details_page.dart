// ****************** FILE INFO ******************
// File Name: crm_quote_details_page.dart
// Purpose: Quote Details full page container supporting Overview, Products, Services, Terms, and Documents tabs with View and Edit modes
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_create_contract_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_overview_section.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_products_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_terms_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_versions_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_documents_tab.dart';

class CrmQuoteDetailsPage extends StatefulWidget {
  final CrmClientDealModel deal;
  final CrmQuoteModel quote;

  const CrmQuoteDetailsPage({
    super.key,
    required this.deal,
    required this.quote,
  });

  @override
  State<CrmQuoteDetailsPage> createState() => _CrmQuoteDetailsPageState();
}

class _CrmQuoteDetailsPageState extends State<CrmQuoteDetailsPage> {
  int _selectedTabIndex = 0;
  late CrmQuoteStatus _currentStatus;
  bool _isEditMode = false;

  // Overview edit-mode controllers
  late final TextEditingController _quoteNumberCtrl;
  late final TextEditingController _quoteDateCtrl;
  late final TextEditingController _quoteDateUntilCtrl;
  late final TextEditingController _noteEnCtrl;
  late final TextEditingController _noteArCtrl;

  static const List<String> _tabTitles = <String>[
    'Overview',
    'Products',
    'Terms',
    'Versions',
    'Documents',
  ];

  static const List<CrmQuoteStatus> _editableStatuses = <CrmQuoteStatus>[
    CrmQuoteStatus.pending,
    CrmQuoteStatus.adjustment,
    CrmQuoteStatus.approved,
    CrmQuoteStatus.reject,
    CrmQuoteStatus.expired,
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.quote.clientStatus;
    _quoteNumberCtrl = TextEditingController(text: widget.quote.quoteNo);
    _quoteDateCtrl = TextEditingController(text: widget.quote.createdDate);
    _quoteDateUntilCtrl = TextEditingController(text: widget.quote.validUntil);
    _noteEnCtrl = TextEditingController(text: widget.quote.noteEn);
    _noteArCtrl = TextEditingController(text: widget.quote.noteAr);
  }

  @override
  void dispose() {
    _quoteNumberCtrl.dispose();
    _quoteDateCtrl.dispose();
    _quoteDateUntilCtrl.dispose();
    _noteEnCtrl.dispose();
    _noteArCtrl.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  void _onDeleteQuote() {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Delete Quote',
        arabicName: 'حذف عرض الأسعار',
      ),
      subtitle: FormatHelper.localizedString(
        englishName:
            'Are you sure you want to delete this quote? This cannot be undone.',
        arabicName:
            'هل أنت متأكد من حذف عرض الأسعار هذا؟ لا يمكن التراجع عن هذا الإجراء.',
      ),
      onConfirm: () {
        Navigator.pop(context); // close dialog
        Navigator.pop(context); // exit details page
      },
    );
  }

  void _onCreateVersion() {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Create Version',
        arabicName: 'إنشاء نسخة',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'A new version of this quote has been created.',
        arabicName: 'تم إنشاء نسخة جديدة من عرض الأسعار هذا.',
      ),
    );
  }

  void _onCreateContract() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CrmCreateContractPage(
          deal: widget.deal,
          quote: widget.quote,
        ),
      ),
    );
  }

  void _onSaveEdit() {
    setState(() => _isEditMode = false);
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Saved',
        arabicName: 'تم الحفظ',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Quote details have been updated successfully.',
        arabicName: 'تم تحديث تفاصيل عرض الأسعار بنجاح.',
      ),
    );
  }

  Future<void> _pickDateUntil() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (BuildContext ctx, Widget? child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.black,
              onSurface: AppColors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _quoteDateUntilCtrl.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dealTitle = widget.deal.dealNameEn.isNotEmpty
        ? widget.deal.dealNameEn
        : 'ERP System Deal';

    if (_isEditMode) {
      return _buildEditPage(dealTitle);
    }
    return _buildViewPage(dealTitle);
  }

  // ── View Mode ────────────────────────────────────────────────────────────────

  Widget _buildViewPage(String dealTitle) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: FormatHelper.localizedString(
          englishName: 'Deals',
          arabicName: 'الصفقات',
        ),
        secondTitle: dealTitle,
        thirdTitle: FormatHelper.localizedString(
          englishName: 'Quote Details',
          arabicName: 'تفاصيل عرض الأسعار',
        ),
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── 1. Top Control Bar (Status + Actions) ─────────────────────
              _buildViewTopBar(context),

              SizedBox(height: 20.sp),

              // ── 2. Tab Bar ────────────────────────────────────────────────
              CustomTabs(
                tabs: _tabTitles,
                selectedValue: _selectedTabIndex,
                spacing: 24.sp,
                onChanged: (int index) =>
                    setState(() => _selectedTabIndex = index),
              ),

              SizedBox(height: 24.sp),

              // ── 3. Active Tab Content ─────────────────────────────────────
              _buildActiveTabContent(context, isEdit: false),

              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Status pill dropdown
        _buildStatusPillDropdown(),

        // Right: context-specific actions + Delete
        Row(
          children: <Widget>[
            if (_currentStatus == CrmQuoteStatus.adjustment) ...<Widget>[
              customButtonWithSvg(
                title: FormatHelper.localizedString(
                  englishName: 'Create Version',
                  arabicName: 'إنشاء نسخة',
                ),
                image: AppAssets.crmVersion,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: Colors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                function: _onCreateVersion,
              ),
              SizedBox(width: 10.sp),
            ],
            if (_currentStatus == CrmQuoteStatus.approved) ...<Widget>[
              customButtonWithSvg(
                title: FormatHelper.localizedString(
                  englishName: 'Create Contract',
                  arabicName: 'إنشاء عقد',
                ),
                image: AppAssets.crmTablerContract,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: Colors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                function: _onCreateContract,
              ),
              SizedBox(width: 10.sp),
            ],
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
              onTap: _onDeleteQuote,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusPillDropdown() {
    return PopupMenuButton<CrmQuoteStatus>(
      onSelected: (CrmQuoteStatus status) =>
          setState(() => _currentStatus = status),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      itemBuilder: (BuildContext context) {
        return _editableStatuses.map((CrmQuoteStatus s) {
          return PopupMenuItem<CrmQuoteStatus>(
            value: s,
            child: Text(
              s.labelEn,
              style: StyleText.fontSize14Weight400,
            ),
          );
        }).toList();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
        decoration: BoxDecoration(
          color: _currentStatus.color,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _currentStatus.labelEn,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.sp),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.white,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit Mode ────────────────────────────────────────────────────────────────

  Widget _buildEditPage(String dealTitle) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: dealTitle,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Quote Details',
          arabicName: 'تفاصيل عرض الأسعار',
        ),
        thirdTitle: FormatHelper.localizedString(
          englishName: 'Edit Quote',
          arabicName: 'تعديل عرض الأسعار',
        ),
        onFirstTap: () => setState(() => _isEditMode = false),
        onSecondTap: () => setState(() => _isEditMode = false),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Active Tab Form in Edit Mode ───────────────────────────────
              _buildActiveTabContent(context, isEdit: true),

              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Content Switcher ─────────────────────────────────────────────────────

  Widget _buildActiveTabContent(BuildContext context, {required bool isEdit}) {
    switch (_selectedTabIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CrmQuoteOverviewSection(
              quoteNumberCtrl: _quoteNumberCtrl,
              quoteDateCtrl: _quoteDateCtrl,
              quoteDateUntilCtrl: _quoteDateUntilCtrl,
              noteEnCtrl: _noteEnCtrl,
              noteArCtrl: _noteArCtrl,
              isReadOnly: !isEdit,
              onDateUntilTap: _pickDateUntil,
              onEditTap: () => setState(() => _isEditMode = true),
            ),
            if (isEdit) ...<Widget>[
              SizedBox(height: 32.sp),
              _buildOverviewBottomBar(context),
            ],
          ],
        );
      case 1:
        return CrmQuoteProductsTab(
          isEditMode: isEdit,
          hasPermission: true,
          onEditTap: () => setState(() => _isEditMode = true),
          onDiscardTap: () => setState(() => _isEditMode = false),
          onSaveTap: _onSaveEdit,
        );
      case 2:
        return CrmQuoteTermsTab(
          isEditMode: isEdit,
          onEditTap: () => setState(() => _isEditMode = true),
          onDiscardTap: () => setState(() => _isEditMode = false),
          onSaveTap: _onSaveEdit,
        );
      case 3:
        return CrmQuoteVersionsTab(currentQuote: widget.quote);
      case 4:
        return const CrmQuoteDocumentsTab();
      default:
        return _buildEmptyTabPlaceholder();
    }
  }

  Widget _buildOverviewBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Discard',
            arabicName: 'تراجع',
          ),
          color: const Color(0xFFE5E7EB),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          function: () => setState(() => _isEditMode = false),
        ),
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Save',
            arabicName: 'حفظ',
          ),
          color: AppColors.primary,
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          function: _onSaveEdit,
        ),
      ],
    );
  }

  Widget _buildEmptyTabPlaceholder() {
    return Container(
      padding: EdgeInsets.all(32.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      alignment: Alignment.center,
      child: Text(
        FormatHelper.localizedString(
          englishName: 'No items in this section yet.',
          arabicName: 'لا توجد عناصر في هذا القسم بعد.',
        ),
        style: StyleText.fontSize14Weight400.copyWith(
          color: AppColors.darkGrey,
        ),
      ),
    );
  }
}
