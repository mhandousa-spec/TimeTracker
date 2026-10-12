// ****************** FILE INFO ******************
// File Name: crm_client_documents_tab.dart
// Purpose: Documents tab — search/sort toolbar, source filter, upload dialog trigger, export, edit mode toggle, and document cards grid.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_document_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_documents_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_documents_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_document_card.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_export_documents_dialog.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmClientDocumentsTab extends StatefulWidget {
  final String clientId;

  const CrmClientDocumentsTab({
    super.key,
    required this.clientId,
  });

  @override
  State<CrmClientDocumentsTab> createState() => _CrmClientDocumentsTabState();
}

class _CrmClientDocumentsTabState extends State<CrmClientDocumentsTab> {
  late final CrmClientDocumentsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = CrmClientDocumentsCubit(clientId: widget.clientId)..init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
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
        _cubit.uploadCustomDocument(
          file: file,
          customTitle: titleName,
        );
      },
    );
  }

  Future<void> _handleDelete(CrmClientDocumentModel document) async {
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
      onConfirm: () async {
        final bool success = await _cubit.removeDocument(document.id);
        if (mounted && success) {
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<CrmClientDocumentsCubit, CrmClientDocumentsState>(
        listener: (BuildContext context, CrmClientDocumentsState state) {
          if (state.error != null && state.error!.isNotEmpty) {
            CrmControlDialogs.showErrorDialog(
              context: context,
              title: S.current.errorOccurred,
              subtitle: state.error!,
            );
            _cubit.clearMessages();
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            CrmControlDialogs.showSuccessDialog(
              context: context,
              title: S.current.success,
              subtitle: state.successMessage!,
            );
            _cubit.clearMessages();
          }
        },
        builder: (BuildContext context, CrmClientDocumentsState state) {
          if (state.isLoading && state.documents.isEmpty) {
            return Container(
              width: double.infinity,
              height: 200.sp,
              alignment: Alignment.center,
              child: const CircleProgressMaster(),
            );
          }

          final List<CrmClientDocumentModel> visibleDocs =
              _cubit.visibleDocuments;

          return Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Toolbar Row 1: Search, Sort, + Add Action
                  _buildTopToolbar(state),
                  SizedBox(height: 12.sp),

                  // 2. Toolbar Row 2: Source Dropdown (Left) & Export / Edit Buttons (Right)
                  _buildSecondaryToolbar(state),
                  SizedBox(height: 16.sp),

                  // 3. Documents Grid / Empty Placeholder
                  if (visibleDocs.isEmpty)
                    _buildEmptyState()
                  else
                    _buildDocumentsGrid(visibleDocs, state.isEditMode),
                ],
              ),

              // Loading overlay on top of body tab while uploading
              if (state.isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.sp,
                        vertical: 20.sp,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.borderCard),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: 36.sp,
                            height: 36.sp,
                            child: const CircleProgressMaster(),
                          ),
                          SizedBox(height: 12.sp),
                          Text(
                            FormatHelper.localizedString(
                              englishName: 'Uploading document...',
                              arabicName: 'جاري رفع الملف...',
                            ),
                            style:
                                StyleText.fontSize14Weight600.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopToolbar(CrmClientDocumentsState state) {
    return CustomSearchFilterSortBar<String, String>(
      searchController: _searchController,
      onSearchChanged: _cubit.setQuery,
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
      selectedSort: state.sort,
      sortTitle: FormatHelper.localizedString(
        englishName: 'Sort',
        arabicName: 'ترتيب',
      ),
      sortLabelBuilder: _sortLabel,
      onSortChanged: _cubit.setSort,
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

  Widget _buildSecondaryToolbar(CrmClientDocumentsState state) {
    final String sourceLabel = FormatHelper.localizedString(
      englishName: 'Source',
      arabicName: 'المصدر',
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Left: Source Dropdown Selector
        PopupMenuButton<String>(
          onSelected: _cubit.setSourceFilter,
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
                  state.sourceFilter == 'All'
                      ? sourceLabel
                      : state.sourceFilter,
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
            customButtonWithSvg(
              title: FormatHelper.localizedString(
                englishName: 'Export',
                arabicName: 'تصدير',
              ),
              function: () {
                showExportDocumentsDialog(
                  context: context,
                  defaultFileName: 'Client_Documents_${widget.clientId}',
                  onSubmit: (String fileName) {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: FormatHelper.localizedString(
                        englishName: 'Exported Successfully',
                        arabicName: 'تم التصدير بنجاح',
                      ),
                      subtitle: FormatHelper.localizedString(
                        englishName:
                            'Exported ${_cubit.visibleDocuments.length} documents as "$fileName"',
                        arabicName:
                            'تم تصدير ${_cubit.visibleDocuments.length} ملفات باسم "$fileName"',
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
            customButtonWithSvg(
              title: state.isEditMode
                  ? FormatHelper.localizedString(
                      englishName: 'Done',
                      arabicName: 'تم',
                    )
                  : FormatHelper.localizedString(
                      englishName: 'Edit',
                      arabicName: 'تعديل',
                    ),
              function: _cubit.toggleEditMode,
              image: AppAssets.edit,
              color: state.isEditMode ? AppColors.darkGrey : AppColors.primary,
              colorBorder: AppColors.transparent,
              textStyle: StyleText.fontSize14Weight600.copyWith(
                color: state.isEditMode ? AppColors.white : AppColors.black,
              ),
              widthImage: 16.sp,
              heightImage: 16.sp,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsGrid(
      List<CrmClientDocumentModel> docs, bool isEditMode) {
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
        final CrmClientDocumentModel doc = docs[index];
        return CrmClientDocumentCard(
          document: doc,
          isEditMode: isEditMode,
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
              englishName: 'Click "+ Add" to attach files to this client',
              arabicName: 'اضغط على "+ إضافة" لإرفاق ملفات بهذا العميل',
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
