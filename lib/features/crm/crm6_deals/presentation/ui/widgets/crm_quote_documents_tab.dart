// ****************** FILE INFO ******************
// File Name: crm_quote_documents_tab.dart
// Purpose: Documents tab content for Quote Details page with search/sort bar, Export, Edit/Delete mode, and document cards grid matching Figma screenshots 3 & 4
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_quote_document_card.dart';

class CrmQuoteDocumentsTab extends StatefulWidget {
  const CrmQuoteDocumentsTab({super.key});

  @override
  State<CrmQuoteDocumentsTab> createState() => _CrmQuoteDocumentsTabState();
}

class _CrmQuoteDocumentsTabState extends State<CrmQuoteDocumentsTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isDeleteMode = false;

  final List<QuoteDocumentItemModel> _documents = <QuoteDocumentItemModel>[
    const QuoteDocumentItemModel(
        id: '1', fileName: 'Watermark.png', extension: 'pdf'),
    const QuoteDocumentItemModel(
        id: '2', fileName: 'Watermark.png', extension: 'pdf'),
    const QuoteDocumentItemModel(
        id: '3', fileName: 'Watermark.png', extension: 'pdf'),
    const QuoteDocumentItemModel(
        id: '4', fileName: 'Watermark.png', extension: 'doc'),
    const QuoteDocumentItemModel(
        id: '5', fileName: 'Watermark.png', extension: 'xlsx'),
    const QuoteDocumentItemModel(
        id: '6', fileName: 'Watermark.png', extension: 'ppt'),
    const QuoteDocumentItemModel(
        id: '7', fileName: 'Watermark.png', extension: 'pdf'),
    const QuoteDocumentItemModel(
        id: '8', fileName: 'Watermark.png', extension: 'pdf'),
    const QuoteDocumentItemModel(
        id: '9', fileName: 'Watermark.png', extension: 'pdf'),
  ];

  static const List<String> _sortOptions = <String>[
    'Recent',
    'Oldest',
    'Name A-Z',
    'Size',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onRemoveDocument(QuoteDocumentItemModel doc) {
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Delete Document',
        arabicName: 'حذف المستند',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Are you sure you want to remove ${doc.fileName}?',
        arabicName: 'هل أنت متأكد من حذف ${doc.fileName}؟',
      ),
      onConfirm: () {
        Navigator.pop(context);
        setState(() {
          _documents.removeWhere((QuoteDocumentItemModel d) => d.id == doc.id);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Search & Sort Bar ──────────────────────────────────────────────
        CustomSearchFilterSortBar<String, String>(
          searchController: _searchController,
          onSearchChanged: (String query) => setState(() {}),
          searchHint: 'Search',
          showFilter: false,
          showSort: true,
          sortItems: _sortOptions,
          selectedSort: 'Recent',
          sortLabelBuilder: (String item) => item,
          onSortChanged: (String? sort) {},
          fillColor: AppColors.white,
        ),

        SizedBox(height: 14.sp),

        // ── 2. Sub-Toolbar: Export & Edit Buttons (Right Aligned) ───────────────
        if (!_isDeleteMode)
          Row(
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
                    title: 'Export Documents',
                    subtitle: 'Exporting documents as ZIP archive.',
                  );
                },
              ),

              SizedBox(width: 10.sp),

              // Edit Button (Toggles Delete Mode)
              customButtonWithSvg(
                title: FormatHelper.localizedString(
                  englishName: 'Edit',
                  arabicName: 'تعديل',
                ),
                image: AppAssets.edit,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: Colors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                function: () => setState(() => _isDeleteMode = true),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              // Done Button to exit Delete Mode
              customButtonWithSvg(
                title: FormatHelper.localizedString(
                  englishName: 'Done',
                  arabicName: 'تم',
                ),
                image: AppAssets.success,
                widthImage: 14.sp,
                heightImage: 14.sp,
                colorBorder: Colors.transparent,
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                function: () => setState(() => _isDeleteMode = false),
              ),
            ],
          ),

        SizedBox(height: 16.sp),

        // ── 3. Documents Grid ─────────────────────────────────────────────────
        if (_documents.isEmpty)
          Container(
            height: 180.sp,
            alignment: Alignment.center,
            child: Text(
              FormatHelper.localizedString(
                englishName: 'No documents attached.',
                arabicName: 'لا توجد مستندات مرفقة.',
              ),
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.darkGrey,
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : (constraints.maxWidth > 600 ? 2 : 1);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 80.sp,
                  crossAxisSpacing: 12.sp,
                  mainAxisSpacing: 12.sp,
                ),
                itemCount: _documents.length,
                itemBuilder: (BuildContext context, int index) {
                  final QuoteDocumentItemModel doc = _documents[index];
                  return CrmQuoteDocumentCard(
                    document: doc,
                    isDeleteMode: _isDeleteMode,
                    onDelete: () => _onRemoveDocument(doc),
                    onTap: () {
                      if (!_isDeleteMode) {
                        CrmControlDialogs.showSuccessDialog(
                          context: context,
                          title: doc.fileName,
                          subtitle:
                              'Document preview: ${doc.fileSize} • Uploaded by ${doc.uploadedBy}',
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
      ],
    );
  }
}
