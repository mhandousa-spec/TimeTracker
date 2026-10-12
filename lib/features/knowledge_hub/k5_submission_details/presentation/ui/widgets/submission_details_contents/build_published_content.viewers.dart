part of './build_published_content.dart';
/// Module: knowledge_hub / presentation / s5_submission_details/widgets/submission_details_contents/build_published_content.viewers.dart

/// File viewers, action buttons + approval/removal reason helpers (split from build_published_content.dart, §7).

Future<void> _showFileViewerDialog(
    BuildContext context, {
      required String fileUrl,
      required String fileName,
      required String fileExtension,
      required bool lightMode,
    }) async {
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.white : AppColors.chatBackground,
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
                          color: lightMode ? AppColors.blackButton : AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
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



Widget _buildFileContent({
  required String fileUrl,
  required String fileExtension,
  required bool lightMode,
}) {
  final extension = fileExtension.toLowerCase();

  if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
    return _buildImageViewer(fileUrl, lightMode);
  } else if (extension == 'pdf') {
    return _buildPDFViewer(fileUrl, lightMode);
  } else {
    return _buildUnsupportedFileView(fileExtension, lightMode);
  }
}

Widget _buildImageViewer(String imageUrl, bool lightMode) {
  // ✅ ADD THIS
  debugPrint('🖼️ _buildImageViewer called with URL: "$imageUrl"');
  debugPrint('🖼️ URL isEmpty: ${imageUrl.isEmpty}');
  return Container(
    color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
    child: PhotoView(
      // Keyed for the same reason as the pdf viewer below.
      key: ValueKey<String>(imageUrl),
      imageProvider: NetworkImage(imageUrl),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      initialScale: PhotoViewComputedScale.contained,
      backgroundDecoration: BoxDecoration(
        color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
      ),
      loadingBuilder: (context, event) => Center(
          child: CircleProgressMaster()
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
                color: lightMode ? AppColors.blackButton : AppColors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class DocumentTypeHelper {
  static final Map<String, Map<String, String>> documentTypes = {
    'presentation': {
      'en': 'Presentation',
      'ar': 'عرض تقديمي',
    },
    'form': {
      'en': 'Form',
      'ar': 'نموذج',
    },
    'report': {
      'en': 'Report',
      'ar': 'تقرير',
    },
    'booklet': {
      'en': 'Booklet',
      'ar': 'كتيب',
    },
    'video_recording': {
      'en': 'Video Recording',
      'ar': 'تسجيل فيديو',
    },
    'letter': {
      'en': 'Letter',
      'ar': 'خطاب',
    },
    'mandate': {
      'en': 'Mandate',
      'ar': 'تفويض',
    },
    'policy': {
      'en': 'Policy',
      'ar': 'سياسة',
    },
    'frame_work': {
      'en': 'Frame Work',
      'ar': 'إطار عمل',
    },
    'workshop': {
      'en': 'Workshop',
      'ar': 'ورشة عمل',
    },
    'guidelines': {
      'en': 'Guidelines',
      'ar': 'إرشادات',
    },
    'other': {
      'en': 'Other',
      'ar': 'أخرى',
    },
  };

  static String getLocalizedType(String typeKey, bool isArabic) {
    final typeMap = documentTypes[typeKey.toLowerCase().replaceAll(' ', '_')];
    if (typeMap == null) {
      return typeKey;
    }
    return isArabic ? (typeMap['ar'] ?? typeKey) : (typeMap['en'] ?? typeKey);
  }

  static String? getTypeKey(String typeName) {
    for (var entry in documentTypes.entries) {
      if (entry.value['en']?.toLowerCase() == typeName.toLowerCase() ||
          entry.value['ar'] == typeName) {
        return entry.key;
      }
    }
    return null;
  }
}

Widget _buildPDFViewer(String pdfUrl, bool lightMode) {
  // Logged so "it opened the wrong document" can be settled in one run:
  // if two documents print the SAME url here, the problem is the stored
  // documentUrl, not the viewer.
  log('📄 [KH-VIEWER] pdf url: $pdfUrl');
  return Container(
    color: lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
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
      key: ValueKey<String>(pdfUrl),
      pdfUrl,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
      enableTextSelection: true,
    ),
  );
}

Widget _buildUnsupportedFileView(String fileExtension, bool lightMode) {
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
            color: lightMode ? AppColors.blackButton : AppColors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'File type: .$fileExtension',
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
            'Please download to view this file',
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

// ============= ACTION BUTTONS SECTION =============

Widget _buildActionButtonsSection(
    BuildContext context, {
      required String currentStatus,
      required String knowledgeId,
      required String fileUrl,
      required String documentFileName,
      required String documentExtension,
      required bool isMobile,
      required bool lightMode,
      required String createdBy,
    })
{



  // ✅ ADD THESE DEBUG PRINTS
  debugPrint('═══════════════════════════════════════');
  debugPrint('🔍 ACTION BUTTONS DEBUG');
  debugPrint('═══════════════════════════════════════');
  debugPrint('📌 knowledgeId: "$knowledgeId"');
  debugPrint('📌 fileUrl: "$fileUrl"');
  debugPrint('📌 documentFileName: "$documentFileName"');
  debugPrint('📌 documentExtension: "$documentExtension"');
  debugPrint('📌 fileUrl isEmpty: ${fileUrl.isEmpty}');
  debugPrint('📌 fileUrl isValidUrl: ${Uri.tryParse(fileUrl)?.hasAbsolutePath ?? false}');
  debugPrint('═══════════════════════════════════════');


  bool showEditButton = currentStatus == 'rejected' ||
      currentStatus == 'archived' ||
      currentStatus == 'published';
  bool showRemoveButton = currentStatus == 'pending_approval' || currentStatus == 'scheduled';
  final controller = Get.find<MainCoreEmployeeController>();
  final employeeEntity = controller.employeeEntity!;
  final String currentUserId = employeeEntity.id!;
  final String currentUserEmail = employeeEntity.email ?? '';

  final bool isCreator =
      currentUserEmail.toLowerCase().trim() == createdBy.toLowerCase().trim();

  log('═══════════════════════════════════════', name: 'ActionButtons');
  log('👤 Creator Check:', name: 'ActionButtons');
  log('   Current User Email: "$currentUserEmail"', name: 'ActionButtons');
  log('   Creator Email (createdBy): "$createdBy"', name: 'ActionButtons');
  log('   Is Creator? $isCreator', name: 'ActionButtons');
  log('═══════════════════════════════════════', name: 'ActionButtons');

  // GATED 2/9/2026. The View button below was already behind `viewDocuments`
  // and the Remove button behind `removeDocuments`, but Download sat between
  // them with no check at all — so the Download switch in the role editor did
  // nothing on this screen.
  final EditAccess editAccess = KnowledgeHubAccess.editAccess;

  return Row(
    children: [
      if (KnowledgeHubAccess.canDownload)
      _buildActionButton(
        context,
        svgHeight: 20.h,
        svgWidth: 20.w,
        assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_download_icon.svg',
        functionName: S.of(context).download,
        color: AppColors.primary,
        isMobile: isMobile,
        // FIXED 22/9/2026 — "download here work like view".
        //
        // The Download button opened the in-app VIEWER dialog and recorded the
        // action as `'view'`. So the file was never saved anywhere, and the
        // Downloads figure on the Analytics tab counted views: a document
        // nobody had downloaded still reported downloads, and one that had
        // been downloaded reported none.
        //
        // It now runs the same path the K3 details screen already used —
        // `downloadFile` from knowledge_hub_file_operations, which refreshes
        // the Storage URL itself (so the local refresh here is gone) and
        // writes to the platform's Downloads location.
        onTap: () async {
          try {
            showLoadingDialog(
                context, S.of(context).downloading ?? 'Downloading...');

            // Let the dialog paint before the transfer starts.
            await Future.delayed(const Duration(milliseconds: 100));

            if (!isCreator) {
              await context.read<SubmissionsCubit>().recordFileAction(
                knowledgeId: knowledgeId,
                typeOfAction: 'download',
                userId: currentUserEmail,
              );
            }

            final bool success = await downloadFile(
              context,
              fileUrl: fileUrl,
              fileName: documentFileName,
            );

            if (context.mounted &&
                Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            if (!context.mounted) return;

            if (success) {
              showSuccessDialog(
                context,
                S.of(context).fileDownloadedSuccessfully ??
                    'File downloaded successfully',
              );
            } else {
              showErrorDialog(
                context,
                S.of(context).downloadFailed ?? 'Download failed',
              );
            }
          } catch (e) {
            log('❌ Download file error: $e');
            if (context.mounted &&
                Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            if (context.mounted) {
              showErrorDialog(context, 'Error: ${e.toString()}');
            }
          }
        },
      ),
      SizedBox(width: 15.w),
      if (controller.isHasPermission(
        module: Modules.knowledgeHub,
        section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
        permission: KnowledgeHubPermissions.viewDocuments,
      ))
        _buildActionButton(
          context,
          svgHeight: 20.h,
          svgWidth: 20.w,
          assetPath: 'assets/icons_assets/knowledge_hub_assets/view_icon.svg',
          color: AppColors.primary,
          functionName: S.of(context).view,
          isMobile: isMobile,
          onTap: () async {
            try {
              if (!isCreator) {
                await context.read<SubmissionsCubit>().recordFileAction(
                  knowledgeId: knowledgeId,
                  typeOfAction: 'view',
                  userId: currentUserEmail,
                );
                log('✅ View action recorded for user: $currentUserEmail', name: 'ActionButtons');
              } else {
                log('⏭️ Skipping view count - user is the creator (Email: $currentUserEmail)',
                    name: 'ActionButtons');
              }

              await _showFileViewerDialog(
                context,
                fileUrl: fileUrl,
                fileName: documentFileName,
                fileExtension: documentExtension,
                lightMode: lightMode,
              );
            } catch (e) {
              log('❌ View file error: $e', name: 'ActionButtons');
              if (context.mounted) {
                _showErrorDialog(context, 'Error: ${e.toString()}');
              }
            }
          },
        ),
      const Spacer(),


      // GATED 2/9/2026 on [EditAccess]. `showEditButton` tests only the
      // document's STATUS, so anyone who could open a rejected, archived or
      // published document could edit it — `editDocumentWithApproval` was
      // checked nowhere in the module, and `editDocumentWithoutApproval` only
      // ever chose the resulting status rather than whether editing was
      // allowed at all.
      //
      // Both permissions off now means no Edit button. Which of the two is on
      // still decides whether the edit publishes directly or queues for a
      // supervisor — that lives in `_getKnowledgeStatus`, unchanged.
      if (showEditButton && editAccess.canEdit)
        _buildActionButton(
          context,
          assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_edit_icon.svg',
          functionName: S.of(context)!.edit,
          color: AppColors.primary,
          isMobile: isMobile,
          onTap: () {
            log('📝 Opening edit screen for: $knowledgeId', name: 'EditButton');
            log('   Status: $currentStatus', name: 'EditButton');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => CreateKnowledgeCubit(KnowledgeHubFirebaseServices()),
                  child: CreatingKnowledgeHub(knowledgeId: knowledgeId),
                ),
              ),
            );
          },
        ),

      if (controller.isHasPermission(
        module: Modules.knowledgeHub,
        section: KnowledgeHubPermissionsSections.submissions,
        permission: SubmissionsPermissions.removeDocuments,
      ))
        if (showRemoveButton)
          _buildActionButton(
            context,
            assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_remove_icon.svg',
            functionName: S.of(context)!.remove,
            functionNameColor: AppColors.white,
            isMobile: isMobile,
            svgColor: AppColors.colorWhite,
            color: AppColors.darkRed,
            onTap: () {
              log('🔍 Remove button clicked', name: 'RemoveAction');
              log('📌 Knowledge ID: $knowledgeId', name: 'RemoveAction');
              log('📌 Full path will be: Demo/70843020/Create_Knowledge/$knowledgeId',
                  name: 'RemoveAction');

              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (dialogContext) => Center(
                  child: Material(
                    color: AppColors.transparent,
                    child: Container(
                      width: isMobile ? double.infinity : 411.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: lightMode ? AppColors.white : AppColors.background,
                      ),
                      padding: EdgeInsets.all(20.r),
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                            height: 70.h,
                            width: 70.w,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            S.of(context)!.removingDocument,
                            style: StyleText.fontSize20Weight500,
                          ),
                          SizedBox(height: 18.h),
                          Text(
                            S.of(context)!.areYouSureYouWantToRemoveDocument,
                            style: StyleText.fontSize14Weight500.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: customButton(
                                  title: S.of(context).no,
                                  height: 38.h,
                                  width: 135.w,
                                  color: lightMode?AppColors.colorGrey:AppColors.colorGreyDark,
                                  function: () {
                                    Navigator.pop(dialogContext);
                                  },
                                ),
                              ),
                              SizedBox(width: 45.w),
                              Expanded(
                                child: customButton(
                                  height: 38.h,
                                  width: 135.w,
                                  title: S.of(context).yes,
                                  function: () async {
                                    Navigator.of(dialogContext).pop();

                                    final result = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (ctx) => ReasonForRemovingDialog(
                                        documentId: knowledgeId,
                                        currentUserEmail: currentUserEmail,
                                      ),
                                    );

// ✅ Handle the result after dialog closes
                                    if (result == true && context.mounted) {
                                      // Refresh the submissions list
                                      try {
                                        await context.read<SubmissionsCubit>().fetchAllSubmissionsEMp();
                                        log('✅ Submissions refreshed after removal', name: 'RemoveAction');
                                      } catch (e) {
                                        log('⚠️ Error refreshing: $e', name: 'RemoveAction');
                                      }

                                      // Go back to submissions screen
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    ],
  );
}

Widget _buildActionButton(
    BuildContext context, {
      required String assetPath,
      required String functionName,
      required VoidCallback? onTap,
      required bool isMobile,
      Color? color,
      Color? functionNameColor,
      Color? svgColor,
      double? svgWidth,
      double? svgHeight,
    }) {
  return _AnimatedActionButton(
    onTap: onTap,
    child: Container(
      height: 38.h,
      width: isMobile ? 38.w : 135.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: color ?? AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: CustomSvgImage(
              assetPath: assetPath,
              width: svgWidth ?? 20.w,
              height: svgHeight ?? 20.h,
              color: svgColor ?? AppColors.textButton,
              fit: BoxFit.cover,
            ),
          ),
          if (!isMobile) ...[
            SizedBox(width: 8.w),
            Text(
              functionName,
              style: StyleText.fontSize16Weight500.copyWith(
                color: functionNameColor ?? AppColors.textButton,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

// ============= DOCUMENT INFO CARD SECTION =============

/// Removal reason — Firestore access delegated to the service (CR-KH-S5-04).
Future<String?> _getRemovalReason(String knowledgeId) =>
    KnowledgeHubFirebaseServices().getRemovalReason(knowledgeId);

/// Approval reason — Firestore access delegated to the service (CR-KH-S5-04).
Future<String?> _getApprovalReason(String knowledgeId) =>
    KnowledgeHubFirebaseServices().getApprovalReason(knowledgeId);
