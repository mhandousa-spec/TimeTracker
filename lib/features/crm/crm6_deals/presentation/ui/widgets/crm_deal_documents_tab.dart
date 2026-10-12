// ****************** FILE INFO ******************
// File Name: crm_deal_documents_tab.dart
// Purpose: Documents tab for CRM Deals — search/sort toolbar, source filter, upload dialog trigger, export, edit mode toggle, and document cards grid (exact replica of Clients Documents tab)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_export_documents_dialog.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_document_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_document_card.dart';

class CrmDealDocumentsTab extends StatefulWidget {
  final CrmClientDealModel deal;

  const CrmDealDocumentsTab({
    super.key,
    required this.deal,
  });

  @override
  State<CrmDealDocumentsTab> createState() => _CrmDealDocumentsTabState();
}

class _CrmDealDocumentsTabState extends State<CrmDealDocumentsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'newest';
  String _selectedSourceFilter = 'All';
  bool _isEditMode = false;

  final List<CrmDealDocumentModel> _documents = <CrmDealDocumentModel>[
    CrmDealDocumentModel(
      id: '1',
      dealId: 'deal_1',
      name: 'Contract_Agreement_Final.pdf',
      url: 'https://example.com/contract.pdf',
      sizeBytes: 2450000,
      extension: 'pdf',
      uploadedBy: 'Staff',
      uploadedByName: 'Amro Handousa',
      uploadedAt: DateTime(2026, 5, 16),
      storagePath: 'deals/deal_1/contract.pdf',
    ),
    CrmDealDocumentModel(
      id: '2',
      dealId: 'deal_1',
      name: 'Technical_Proposal_v2.docx',
      url: 'https://example.com/proposal.docx',
      sizeBytes: 1200000,
      extension: 'docx',
      uploadedBy: 'Staff',
      uploadedByName: 'Sara Ahmed',
      uploadedAt: DateTime(2026, 5, 15),
      storagePath: 'deals/deal_1/proposal.docx',
    ),
    CrmDealDocumentModel(
      id: '3',
      dealId: 'deal_1',
      name: 'Pricing_Breakdown_Q2.xlsx',
      url: 'https://example.com/pricing.xlsx',
      sizeBytes: 850000,
      extension: 'xlsx',
      uploadedBy: 'Staff',
      uploadedByName: 'Aya Ali',
      uploadedAt: DateTime(2026, 5, 14),
      storagePath: 'deals/deal_1/pricing.xlsx',
    ),
    CrmDealDocumentModel(
      id: '4',
      dealId: 'deal_1',
      name: 'Client_Requirements_Brief.pdf',
      url: 'https://example.com/requirements.pdf',
      sizeBytes: 3100000,
      extension: 'pdf',
      uploadedBy: 'Client',
      uploadedByName: 'Client Portal',
      uploadedAt: DateTime(2026, 5, 12),
      storagePath: 'deals/deal_1/requirements.pdf',
    ),
    CrmDealDocumentModel(
      id: '5',
      dealId: 'deal_1',
      name: 'ERP_System_Presentation.pptx',
      url: 'https://example.com/presentation.pptx',
      sizeBytes: 5400000,
      extension: 'pptx',
      uploadedBy: 'Staff',
      uploadedByName: 'Amro Handousa',
      uploadedAt: DateTime(2026, 5, 10),
      storagePath: 'deals/deal_1/presentation.pptx',
    ),
    CrmDealDocumentModel(
      id: '6',
      dealId: 'deal_1',
      name: 'Company_CR_Certificate.jpg',
      url: 'https://example.com/cr.jpg',
      sizeBytes: 620000,
      extension: 'jpg',
      uploadedBy: 'Client',
      uploadedByName: 'Client Portal',
      uploadedAt: DateTime(2026, 5, 8),
      storagePath: 'deals/deal_1/cr.jpg',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _sortLabel(String sortKey) {
    switch (sortKey) {
      case 'oldest':
        return FormatHelper.localizedString(
          englishName: 'Oldest',
          arabicName: 'الأقدم',
        );
      case 'name_asc':
        return FormatHelper.localizedString(
          englishName: 'Name (A-Z)',
          arabicName: 'الاسم (أ-ي)',
        );
      case 'name_desc':
        return FormatHelper.localizedString(
          englishName: 'Name (Z-A)',
          arabicName: 'الاسم (ي-أ)',
        );
      case 'size_desc':
        return FormatHelper.localizedString(
          englishName: 'Largest',
          arabicName: 'الأكبر حجماً',
        );
      case 'size_asc':
        return FormatHelper.localizedString(
          englishName: 'Smallest',
          arabicName: 'الأصغر حجماً',
        );
      case 'newest':
      default:
        return FormatHelper.localizedString(
          englishName: 'Newest',
          arabicName: 'الأحدث',
        );
    }
  }

  List<CrmDealDocumentModel> get _visibleDocuments {
    final List<CrmDealDocumentModel> filtered =
        _documents.where((CrmDealDocumentModel doc) {
      if (doc.isDeleted) return false;

      // Source Filter
      if (_selectedSourceFilter != 'All') {
        if (doc.uploadedBy != _selectedSourceFilter) return false;
      }

      // Search Query
      if (_searchController.text.trim().isNotEmpty) {
        final String query = _searchController.text.trim().toLowerCase();
        final bool matchesName = doc.name.toLowerCase().contains(query);
        final bool matchesUploader =
            doc.uploadedByName.toLowerCase().contains(query);
        if (!matchesName && !matchesUploader) return false;
      }

      return true;
    }).toList();

    // Sort
    switch (_selectedSort) {
      case 'oldest':
        filtered.sort((a, b) => a.uploadedAt.compareTo(b.uploadedAt));
        break;
      case 'name_asc':
        filtered.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_desc':
        filtered.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'size_desc':
        filtered.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
      case 'size_asc':
        filtered.sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
        break;
    }

    return filtered;
  }

  Future<void> _handleOpenUploadDialog() async {
    await showUploadDialog(
      context: context,
      dialogTitle: FormatHelper.localizedString(
        englishName: 'Adding Attachment',
        arabicName: 'إضافة مرفق',
      ),
      titleFieldLabel: FormatHelper.localizedString(
        englishName: 'Title Name',
        arabicName: 'اسم العنوان',
      ),
      titleFieldHint: FormatHelper.localizedString(
        englishName: 'Text here',
        arabicName: 'اكتب هنا',
      ),
      submitLabel: FormatHelper.localizedString(
        englishName: 'Submit',
        arabicName: 'حفظ',
      ),
      discardLabel: FormatHelper.localizedString(
        englishName: 'Discard',
        arabicName: 'إلغاء',
      ),
      browseLabel: FormatHelper.localizedString(
        englishName: 'Browse Files',
        arabicName: 'تصفح الملفات',
      ),
      onSubmit: (PlatformFile file, String titleName) {
        final String finalName =
            titleName.trim().isNotEmpty ? titleName.trim() : file.name;
        final String ext = file.extension ?? 'pdf';

        final CrmDealDocumentModel newDoc = CrmDealDocumentModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          dealId: widget.deal.id,
          name: finalName.contains('.') ? finalName : '$finalName.$ext',
          url: file.path ?? '',
          sizeBytes: file.size,
          extension: ext,
          uploadedBy: 'Staff',
          uploadedByName: 'Amro Handousa',
          uploadedAt: DateTime.now(),
          storagePath: 'deals/${widget.deal.id}/${file.name}',
        );

        setState(() {
          _documents.insert(0, newDoc);
        });

        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: FormatHelper.localizedString(
            englishName: 'Uploaded Successfully',
            arabicName: 'تم الرفع بنجاح',
          ),
          subtitle: FormatHelper.localizedString(
            englishName: 'Document has been added to deal files.',
            arabicName: 'تمت إضافة الملف إلى مستندات الصفقة بنجاح.',
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(CrmDealDocumentModel document) async {
    final String title = FormatHelper.localizedString(
      englishName: 'Delete File',
      arabicName: 'حذف الملف',
    );
    final String subtitle = FormatHelper.localizedString(
      englishName: 'Are you sure to delete this file?',
      arabicName: 'هل أنت متأكد من حذف هذا الملف؟',
    );

    await CrmControlDialogs.showRemoveDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      onConfirm: () {
        setState(() {
          _documents
              .removeWhere((CrmDealDocumentModel d) => d.id == document.id);
        });
        CrmControlDialogs.showSuccessDialog(
          context: context,
          title: FormatHelper.localizedString(
            englishName: 'Deleted',
            arabicName: 'تم الحذف',
          ),
          subtitle: FormatHelper.localizedString(
            englishName: 'Document deleted successfully',
            arabicName: 'تم حذف الملف بنجاح',
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CrmDealDocumentModel> visibleDocs = _visibleDocuments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Toolbar Row 1: Search, Sort, + Add Action ─────────────────────
        _buildTopToolbar(),
        SizedBox(height: 12.sp),

        // ── 2. Toolbar Row 2: Source Dropdown (Left) & Export / Edit Buttons ──
        _buildSecondaryToolbar(visibleDocs.length),
        SizedBox(height: 16.sp),

        // ── 3. Documents Grid / Empty Placeholder ───────────────────────────
        if (visibleDocs.isEmpty)
          _buildEmptyState()
        else
          _buildDocumentsGrid(visibleDocs),
      ],
    );
  }

  Widget _buildTopToolbar() {
    return CustomSearchFilterSortBar<String, String>(
      searchController: _searchController,
      onSearchChanged: (String val) => setState(() {}),
      searchHint: FormatHelper.localizedString(
        englishName: 'Search',
        arabicName: 'بحث',
      ),
      showSort: true,
      sortItems: const <String>[
        'newest',
        'oldest',
        'name_asc',
        'name_desc',
        'size_desc',
        'size_asc',
      ],
      selectedSort: _selectedSort,
      sortTitle: FormatHelper.localizedString(
        englishName: 'Sort',
        arabicName: 'ترتيب',
      ),
      sortLabelBuilder: _sortLabel,
      onSortChanged: (String? val) {
        if (val != null) setState(() => _selectedSort = val);
      },
      trailingChildren: <Widget>[
        customButtonWithSvg(
          title: FormatHelper.localizedString(
            englishName: 'Add',
            arabicName: 'إضافة',
          ),
          function: _handleOpenUploadDialog,
          image: AppAssets.add,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          textStyle: StyleText.fontSize14Weight600.copyWith(
            color: AppColors.black,
          ),
          widthImage: 16.sp,
          heightImage: 16.sp,
        ),
      ],
    );
  }

  Widget _buildSecondaryToolbar(int count) {
    final String sourceLabel = FormatHelper.localizedString(
      englishName: 'Source',
      arabicName: 'المصدر',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Left: Source Dropdown Selector
        PopupMenuButton<String>(
          onSelected: (String val) =>
              setState(() => _selectedSourceFilter = val),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          color: AppColors.card,
          itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'All',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'All Sources',
                  arabicName: 'جميع المصادر',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'Staff',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Uploaded by Staff',
                  arabicName: 'بواسطة الموظفين',
                ),
                style: StyleText.fontSize14Weight500,
              ),
            ),
            PopupMenuItem<String>(
              value: 'Client',
              child: Text(
                FormatHelper.localizedString(
                  englishName: 'Uploaded by Client',
                  arabicName: 'بواسطة العميل',
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
                  _selectedSourceFilter == 'All'
                      ? sourceLabel
                      : (_selectedSourceFilter == 'Staff' ? 'Staff' : 'Client'),
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(width: 12.sp),
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

        // Right: Export and Edit Action Buttons
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
                  defaultFileName: 'Deal_Documents_${widget.deal.id}',
                  onSubmit: (String fileName) {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: FormatHelper.localizedString(
                        englishName: 'Exported Successfully',
                        arabicName: 'تم التصدير بنجاح',
                      ),
                      subtitle: FormatHelper.localizedString(
                        englishName: 'Exported $count documents as "$fileName"',
                        arabicName: 'تم تصدير $count ملفات باسم "$fileName"',
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

            // Edit Mode Toggle Button
            customButtonWithSvg(
              title: _isEditMode
                  ? FormatHelper.localizedString(
                      englishName: 'Done',
                      arabicName: 'تم',
                    )
                  : FormatHelper.localizedString(
                      englishName: 'Edit',
                      arabicName: 'تعديل',
                    ),
              function: () => setState(() => _isEditMode = !_isEditMode),
              image: AppAssets.edit,
              color: _isEditMode ? AppColors.darkGrey : AppColors.primary,
              colorBorder: AppColors.transparent,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: _isEditMode ? AppColors.white : AppColors.black,
              ),
              widthImage: 16.sp,
              heightImage: 16.sp,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsGrid(List<CrmDealDocumentModel> docs) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisExtent: 76.sp,
        crossAxisSpacing: 10.sp,
        mainAxisSpacing: 10.sp,
      ),
      itemCount: docs.length,
      itemBuilder: (BuildContext context, int index) {
        final CrmDealDocumentModel doc = docs[index];
        return CrmDealDocumentCard(
          document: doc,
          isEditMode: _isEditMode,
          onDelete: () => _handleDelete(doc),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.sp, horizontal: 16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomSvgImage(
            assetPath: AppAssets.crmTemplateEmpty,
            width: 100.sp,
            height: 100.sp,
          ),
          SizedBox(height: 16.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'No documents uploaded yet',
              arabicName: 'لا توجد ملفات مرفوعة بعد',
            ),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'Click "+ Add" to attach files to this deal',
              arabicName: 'اضغط على "+ إضافة" لإرفاق ملفات بهذه الصفقة',
            ),
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
