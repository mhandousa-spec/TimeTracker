/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/build_action_buttons.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_action_buttons.dart
/// Purpose: Contains the action button to download/view files from knowledge hub.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Added permission check for removing any document (not just owned ones)

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/services/knowledge_hub_firebase_services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/knowledge_hub_file_operations.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../k5_submission_details/presentation/controller/analytics_cubit.dart';
import '../../../controller/create_comment_cubit.dart';
import '../../../controller/create_comment_states.dart';
import '../../../../../main_controller/presentation/ui/widgets/customed_text_field.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';

class ActionButtonsWidget extends StatelessWidget {
  final String knowledgeId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final String department;
  final String documentExtension;
  final String? createdBy; // ✅ Creator's email

  const ActionButtonsWidget({
    super.key,
    required this.knowledgeId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.department,
    required this.documentExtension,
    this.createdBy,
    required String createdByEmail,
  });

  /// ✅ NEW: Check if user can remove documents (either owner or has permission)
  bool _canRemoveDocument(BuildContext context) {
    final employeeController = Get.find<MainCoreEmployeeController>();

    // Get current logged-in user's email
    final String currentUserEmail = employeeController.employeeEntity?.email?.toLowerCase().trim() ?? '';

    // Check if current user is the creator
    final bool isCreator = createdBy != null &&
        currentUserEmail == createdBy!.toLowerCase().trim();

    // Check if user has permission to remove any document
    final bool hasRemoveAnyPermission = employeeController.isHasPermission(
      module: Modules.knowledgeHub,
      section: KnowledgeHubPermissionsSections.allowsRemovingDocumentsOwnedByAnyone,
      permission: null,
    );

    log('═══════════════════════════════════════', name: 'RemovePermissionCheck');
    log('👤 Current User Email: "$currentUserEmail"', name: 'RemovePermissionCheck');
    log('👤 Creator Email: "$createdBy"', name: 'RemovePermissionCheck');
    log('✓ Is Creator: $isCreator', name: 'RemovePermissionCheck');
    log('✓ Has Remove Any Permission: $hasRemoveAnyPermission', name: 'RemovePermissionCheck');
    log('✓ Can Remove Document: ${isCreator || hasRemoveAnyPermission}', name: 'RemovePermissionCheck');
    log('═══════════════════════════════════════', name: 'RemovePermissionCheck');

    return isCreator || hasRemoveAnyPermission;
  }

  /// ✅ Handle download action with creator detection
  Future<void> _handleDownload(BuildContext context) async {
    try {
      final controller = Get.find<MainCoreEmployeeController>();
      final employeeEntity = controller.employeeEntity!;
      final String currentUserEmail = employeeEntity.email ?? '';

      // ✅ Check if current user is the creator
      final bool isCreator = createdBy != null &&
          currentUserEmail.toLowerCase().trim() == createdBy!.toLowerCase().trim();

      log('═══════════════════════════════════════', name: 'ViewKnowledgeDownload');
      log('🔽 Download initiated for: $fileName', name: 'ViewKnowledgeDownload');
      log('👤 Current User Email: "$currentUserEmail"', name: 'ViewKnowledgeDownload');
      log('👤 Creator Email: "$createdBy"', name: 'ViewKnowledgeDownload');
      log('✓ Is Creator? $isCreator', name: 'ViewKnowledgeDownload');
      log('═══════════════════════════════════════', name: 'ViewKnowledgeDownload');

      // Show loading dialog
      showLoadingDialog(context, S.of(context).downloading ?? 'Downloading...');

      // Small delay to ensure dialog is rendered
      await Future.delayed(Duration(milliseconds: 100));

      // ✅ Record download action ONLY if NOT the creator
      if (!isCreator) {
        await context.read<CommentsCubit>().recordFileAction(
          knowledgeId: knowledgeId,
          typeOfAction: 'download',
          userId: currentUserEmail,
        );
        log('✅ Download action recorded for user: $currentUserEmail', name: 'ViewKnowledgeDownload');
      } else {
        log('⏭️ Skipping download count - user is the creator', name: 'ViewKnowledgeDownload');
      }

      // Download the file
      bool success = await downloadFile(
        context,
        fileUrl: fileUrl,
        fileName: fileName,
      );

      // Close loading dialog using rootNavigator
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Show result
      if (success) {
        showSuccessDialog(
          context,
          S.of(context).fileDownloadedSuccessfully ?? 'File downloaded successfully',
        );
        log('✅ Download successful', name: 'ViewKnowledgeDownload');
      } else {
        showErrorDialog(
          context,
          S.of(context).downloadFailed ?? 'Download failed',
        );
        log('❌ Download failed', name: 'ViewKnowledgeDownload');
      }
    } catch (e) {
      log('❌ Download error: $e', name: 'ViewKnowledgeDownload');

      // Close loading dialog on error
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      showErrorDialog(context, 'Error: ${e.toString()}');
    }
  }

  /// ✅ Handle view action with creator detection - Shows file DIRECTLY in dialog
  Future<void> _handleView(BuildContext context) async {
    try {
      final controller = Get.find<MainCoreEmployeeController>();
      final employeeEntity = controller.employeeEntity!;
      final String currentUserEmail = employeeEntity.email ?? '';

      // ✅ Check if current user is the creator
      final bool isCreator = createdBy != null &&
          currentUserEmail.toLowerCase().trim() == createdBy!.toLowerCase().trim();

      log('═══════════════════════════════════════', name: 'ViewKnowledgeView');
      log('👁️ View initiated for: $fileName', name: 'ViewKnowledgeView');
      log('👤 Current User Email: "$currentUserEmail"', name: 'ViewKnowledgeView');
      log('👤 Creator Email: "$createdBy"', name: 'ViewKnowledgeView');
      log('✓ Is Creator? $isCreator', name: 'ViewKnowledgeView');
      log('═══════════════════════════════════════', name: 'ViewKnowledgeView');

      // ✅ Record view action ONLY if NOT the creator
      if (!isCreator) {
        await context.read<CommentsCubit>().recordFileAction(
          knowledgeId: knowledgeId,
          typeOfAction: 'view',
          userId: currentUserEmail,
        );
        log('✅ View action recorded for user: $currentUserEmail', name: 'ViewKnowledgeView');
      } else {
        log('⏭️ Skipping view count - user is the creator', name: 'ViewKnowledgeView');
      }

      // Show file viewer dialog DIRECTLY (always show, regardless of creator status)
      final lightMode = Theme.of(context).brightness == Brightness.light;
      _showFileViewerDialog(
        context,
        fileUrl: fileUrl,
        fileName: fileName,
        fileExtension: documentExtension,
        lightMode: lightMode,
      );

      log('✅ View dialog shown', name: 'ViewKnowledgeView');
    } catch (e) {
      log('❌ View error: $e', name: 'ViewKnowledgeView');
      if (context.mounted) {
        showErrorDialog(context, 'Error: ${e.toString()}');
      }
    }
  }

  /// ✅ Handle remove action - Updates status to "removed" with dynamic company ID
  ///
  /// CHANGED 28/9/2026 (Knowledge Hub bug report p.13 — "wrong dialog"). The
  /// 22/9/2026 version asked "are you sure" AND collected the justification in
  /// ONE hand-built dialog, which matched nothing else in the app. It now runs
  /// the app's standard sequence, `CustomDialogManager.showDialogFlow` — the
  /// same one editing a document uses (confirm → "Reason Of Editing" →
  /// success): a Remove Knowledge confirmation, then a separate "Reason Of
  /// Removing" dialog, then the success dialog. The reason is still required
  /// and still stored through `removeKnowledgeWithReason`.
  ///
  /// The page pops with `true` after a removal so the list that opened it
  /// can refetch — see Knowledge Hub p.17, where the removed card stayed on
  /// the list until the user logged out and back in.
  Future<void> _handleRemove(BuildContext context) async {
    log('🗑️ Remove initiated for: $fileName ($knowledgeId)',
        name: 'ViewKnowledgeRemove');

    final TextEditingController reasonController = TextEditingController();
    bool removed = false;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
      confirmTitle: S.of(context).removeKnowledge,
      confirmSubtitle: S.of(context).areYouSureDeleteKnowledge,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,

      // Reason step — required: the author is told why their document was
      // pulled, and a blank reason tells them nothing.
      comment: true,
      commentRequired: true,
      commentController: reasonController,
      customReasonTitle: S.of(context).reasonOfRemoving,
      commentSubmitText: S.of(context).submit,
      commentDiscardText: S.of(context).discard,
      onCommentSubmit: () async => true,

      // The removal itself. Returning false stops the flow before the success
      // dialog, so a failed removal cannot report success.
      onConfirm: () async {
        if (!context.mounted) return false;
        showLoadingDialog(context, S.of(context).Delete ?? 'Deleting...');
        await Future.delayed(const Duration(milliseconds: 100));

        RemoveKnowledgeReasonResult? result;
        Object? error;
        try {
          final String currentUserEmail =
              Get.find<MainCoreEmployeeController>().employeeEntity?.email ??
                  '';
          result = await KnowledgeHubFirebaseServices().removeKnowledgeWithReason(
            documentId: knowledgeId,
            currentUserEmail: currentUserEmail,
            justification: reasonController.text.trim(),
          );
        } catch (e, stackTrace) {
          error = e;
          log('❌ Remove error: $e', name: 'ViewKnowledgeRemove');
          log('❌ Stack trace: $stackTrace', name: 'ViewKnowledgeRemove');
        }

        // Close the loading dialog.
        if (context.mounted &&
            Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        if (!context.mounted) return false;

        if (error != null) {
          showErrorDialog(
            context,
            error.toString().contains('not found')
                ? 'Knowledge document not found'
                : 'Delete failed: $error',
          );
          return false;
        }
        if (result == null) {
          showErrorDialog(
            context,
            'This knowledge document has already been removed or no longer exists.',
          );
          return false;
        }

        removed = true;
        log('✅ Knowledge removed successfully', name: 'ViewKnowledgeRemove');
        return true;
      },

      successLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
      successTitle: S.of(context).successful,
      successSubtitle: S.of(context).knowledgeRemovedSuccessfully ??
          'Knowledge removed successfully',
      onSuccessComplete: () {
        if (removed && context.mounted) Navigator.of(context).pop(true);
      },
    );

    reasonController.dispose();
  }

  /// ✅ Show file viewer dialog - LOADS FILE DIRECTLY
  void _showFileViewerDialog(
      BuildContext context, {
        required String fileUrl,
        required String fileName,
        required String fileExtension,
        required bool lightMode,
      }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.transparent,
          insetPadding: EdgeInsets.all(10.w),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: lightMode ? AppColors.white : AppColors.background,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                // Header with close button
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: lightMode
                        ? AppColors.white
                        : AppColors.chatBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: lightMode
                            ? AppColors.secondaryText.withOpacity(0.2)
                            : AppColors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          fileName,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: lightMode
                                ? AppColors.blackButton
                                : AppColors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),

                // File content viewer - LOADS DIRECTLY FROM URL
                Expanded(
                  child: _buildFileContent(
                    fileUrl: fileUrl,
                    fileExtension: fileExtension,
                    lightMode: lightMode,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ Build file content - DIRECT LOADING FROM URL
  Widget _buildFileContent({
    required String fileUrl,
    required String fileExtension,
    required bool lightMode,
  }) {
    final extension = fileExtension.toLowerCase().replaceAll('.', '');

    // PDF files - LOAD DIRECTLY FROM URL
    // See the note in K5's _buildPDFViewer for why the url is logged.
    log('📄 [KH-VIEWER] pdf url: $fileUrl', name: 'ViewKnowledgeView');
    if (extension == 'pdf') {
      return Container(
        color: lightMode ? AppColors.offWhite : AppColors.colorBlack,
        // FIXED 22/9/2026 — "every knowledge view the same file".
        //
        // `SfPdfViewer` holds the loaded document in its State and does NOT
        // reload it when only the `network` URL changes. With no key, Flutter
        // matches the new widget to the existing element by position and type
        // and calls `didUpdateWidget` instead of building fresh State, so the
        // FIRST pdf opened in this viewer kept rendering for every document
        // opened afterwards — the breadcrumb said one document, the pages were
        // another's.
        //
        // Keying on the URL makes a different document a different element, so
        // the State is rebuilt and the right file loads. Same document reopened
        // = same key = the existing cache is reused, which is the behaviour that
        // made this worth having in the first place.
        child: SfPdfViewer.network(
          key: ValueKey<String>(fileUrl),
          fileUrl,
          canShowScrollHead: true,
          canShowScrollStatus: true,
          enableDoubleTapZooming: true,
          enableTextSelection: true,
        ),
      );
    }

    // Image files - LOAD DIRECTLY FROM URL
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return Container(
        color: lightMode ? AppColors.offWhite : AppColors.colorBlack,
        child: PhotoView(
          // Keyed for the same reason as the pdf viewer above.
          key: ValueKey<String>(fileUrl),
          imageProvider: NetworkImage(fileUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: BoxDecoration(
            color: lightMode ? AppColors.offWhite : AppColors.colorBlack,
          ),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load image',
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // For other file types (Excel, Word, etc.)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
            height: 64.sp,
            width: 64.sp,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 24.h),
          Text(
            'Preview not available',
            style: StyleText.fontSize16Weight500.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'File type: .$extension',
            style: StyleText.fontSize14Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Please use download button to view this file',
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<MainCoreEmployeeController>();

    debugPrint("createdBy is ${createdBy}");

    // ✅ Check if user can remove this document
    final bool canRemove = _canRemoveDocument(context);

    return BlocListener<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state is RecordFileActionSuccess) {
          log(
            '${state.actionType == 'download' ? 'Download' : 'View'} recorded successfully',
            name: 'ViewKnowledgeActions',
          );
        } else if (state is RecordFileActionFailure) {
          log('Failed to record action: ${state.error}', name: 'ViewKnowledgeActions');
        }
      },
      child: BlocBuilder<CommentsCubit, CommentsState>(
        builder: (context, state) {
          final isLoading = state is RecordFileActionLoading;

          return Row(
            children: [

              if (controller.isHasPermission(
                module: Modules.knowledgeHub,
                section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                permission: KnowledgeHubPermissions.viewDocuments,
              ))

              // View Button
                _buildActionButton(
                  context,
                  assetPath: "assets/icons_assets/knowledge_hub_assets/view_icon.svg",
                  functionName: S.of(context).view,
                  onTap: isLoading ? null : () => _handleView(context),
                ),
              SizedBox(width: 15.w),

              if (controller.isHasPermission(
                module: Modules.knowledgeHub,
                section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                permission: KnowledgeHubPermissions.downloadDocuments,
              ))

              // Download Button
                _buildActionButton(
                  context,
                  assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_download_icon.svg',
                  functionName: S.of(context).download,
                  onTap: isLoading ? null : () => _handleDownload(context),
                ),

              // ✅ UPDATED: Only add Spacer if showing remove button
              if (canRemove) Spacer(),

              // ✅ UPDATED: Remove Button - Show if user is creator OR has permission
              if (canRemove) ...[
                SizedBox(width: 15.w),
                customButtonWithSvg(
                  title: S.of(context).remove,
                  function: () => _handleRemove(context),
                  textStyle: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.white,
                  ),
                  width: 135.sp,
                  height: 38.sp,
                  space: 8.sp,
                  radius: 8.r,
                  color: Color(0xffDF1C1C),
                  image: "assets/icons_assets/knowledge_hub_assets/svg_remove_icon.svg",
                  svgColor: AppColors.colorWhite,
                  widthImage: 20.w,
                  heightImage: 20.h,
                  colorBorder: AppColors.transparent,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String assetPath,
        required String functionName,
        required VoidCallback? onTap,
        Color? buttonColor,
        Color? textColor,
      }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        width: isMobile ? 38.w : 135.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: buttonColor ?? AppColors.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: assetPath,
              width: 20.w,
              height: 20.h,
              fit: BoxFit.fill,
              color: AppColors.textButton,
            ),
            if (!isMobile) ...[
              SizedBox(width: 8.w),
              Text(
                functionName,
                style: StyleText.fontSize16Weight500.copyWith(
                  color: textColor ?? AppColors.textButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ✅ Helper function with createdBy parameter
Widget buildActionButtons({
  required String knowledgeId,
  required String fileName,
  required String fileType,
  required String fileUrl,
  required String department,
  required String createdByEmail,
  required String documentExtension,
  String? createdBy,
}) {
  return ActionButtonsWidget(
    knowledgeId: knowledgeId,
    fileName: fileName,
    fileType: fileType,
    fileUrl: fileUrl,
    department: department,
    createdByEmail: createdByEmail,
    documentExtension: documentExtension,
    createdBy: createdBy,
  );
}