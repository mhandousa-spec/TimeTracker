/// Module: knowledge_hub / presentation / s7_approvals_details / widgets/build_action_buttons.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_action_buttons.dart
/// Purpose: Contains the action button to download/view files from Approvals.
/// Author: Youssef Khaled
/// Created At: 26/10/2025
/// Updated: Full file viewer support WITHOUT WebView

import 'dart:developer';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/knowledge_hub_file_operations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:path_provider/path_provider.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k6_approvals/presentation/controller/approvals_cubit.dart';
import '../../../../k6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
// ADDED 2/9/2026 — the Download / View permission checks below.
import '../../../../main_controller/helper/knowledge_hub_permissions.dart';

part './build_action_buttons.viewers.dart';

// ✅ Initialize HapticController

// ✅ Animated Action Button Wrapper
class _AnimatedActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedActionButton({
    required this.child,
    required this.onTap,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.onTap == null) return;

    hapticController.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    await _controller.forward();
    widget.onTap!();
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

class ApprovalsActionButtonsWidget extends StatelessWidget with _ApprovalsFileViewers {
  final String knowledgeId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final String department;
  final String fileExtension;

  const ApprovalsActionButtonsWidget({
    super.key,
    required this.knowledgeId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.department,
    required this.fileExtension,
  });

  /// ✅ Handle download action
  Future<void> _handleDownload(BuildContext context) async {
    try {
      final employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;
      final String currentUserId = employeeEntity.id!;

      log('🔽 Download initiated for: $fileName', name: 'ApprovalsDownload');

      showLoadingDialog(context, S.of(context).downloading ?? 'Downloading...');
      await Future.delayed(Duration(milliseconds: 100));

      await context.read<ApprovalsCubit>().recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: 'download',
        userId: currentUserId,
      );

      bool success = await downloadFile(
        context,
        fileUrl: fileUrl,
        fileName: fileName,
      );

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (success) {
        showSuccessDialog(
          context,
          S.of(context).fileDownloadedSuccessfully ?? 'File downloaded successfully',
        );
        log('✅ Download successful', name: 'ApprovalsDownload');
      } else {
        showErrorDialog(
          context,
          S.of(context).downloadFailed ?? 'Download failed',
        );
        log('❌ Download failed', name: 'ApprovalsDownload');
      }
    } catch (e) {
      log('❌ Download error: $e', name: 'ApprovalsDownload');

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      showErrorDialog(context, 'Error: ${e.toString()}');
    }
  }

  /// ✅ Handle view action
  Future<void> _handleView(BuildContext context) async {
    try {
      final employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;
      final String currentUserId = employeeEntity.id!;

      log('👁️ View initiated for: $fileName', name: 'ApprovalsView');

      await context.read<ApprovalsCubit>().recordFileAction(
        knowledgeId: knowledgeId,
        typeOfAction: 'view',
        userId: currentUserId,
      );

      final lightMode = Theme.of(context).brightness == Brightness.light;
      _showFileViewerDialog(
        context,
        fileUrl: fileUrl,
        fileName: fileName,
        fileExtension: fileExtension,
        lightMode: lightMode,
      );

      log('✅ View dialog shown', name: 'ApprovalsView');
    } catch (e) {
      log('❌ View error: $e', name: 'ApprovalsView');
      if (context.mounted) {
        showErrorDialog(context, 'Error: ${e.toString()}');
      }
    }
  }

  /// ✅ Show file viewer dialog
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
                    // border: Border(
                    //   bottom: BorderSide(
                    //     color: lightMode
                    //         ? AppColors.secondaryText.withOpacity(0.2)
                    //         : AppColors.grey.withOpacity(0.2),
                    //     width: 1,
                    //   ),
                    // ),
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

                // File content viewer
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

  /// ✅ Build file content based on extension
  Widget _buildFileContent({
    required String fileUrl,
    required String fileExtension,
    required bool lightMode,
  }) {
    final extension = fileExtension.toLowerCase();

    // PDF files
    if (extension == 'pdf') {
      return _buildPdfViewer(fileUrl, lightMode);
    }

    // Image files
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return _buildImageViewer(fileUrl, lightMode);
    }

    // Video files
    if (['mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm'].contains(extension)) {
      return _buildVideoPlayer(fileUrl, lightMode);
    }

    // Excel/CSV files
    if (['xls', 'xlsx', 'xlsm', 'csv'].contains(extension)) {
      return _buildOfficeFileViewer(fileUrl, extension, lightMode);
    }

    // Word/PowerPoint files
    if (['doc', 'docx', 'ppt', 'pptx'].contains(extension)) {
      return _buildDocumentPlaceholder(extension, lightMode);
    }

    // Unsupported file type
    return _buildUnsupportedFileView(extension, lightMode);
  }

  /// ✅ PDF Viewer

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApprovalsCubit, ApprovalsStates>(
      listener: (context, state) {
        if (state is RecordFileActionSuccess) {
          log(
            '${state.typeOfAction == 'download' ? 'Download' : 'View'} recorded successfully',
            name: 'ApprovalsActions',
          );
        } else if (state is RecordFileActionFailure) {
          log('Failed to record action: ${state.error}', name: 'ApprovalsActions');
        }
      },
      child: BlocBuilder<ApprovalsCubit, ApprovalsStates>(
        builder: (context, state) {
          final isLoading = state is RecordFileActionLoading;

          // GATED 2/9/2026. Both buttons rendered unconditionally here, while
          // the same two on k3 were already behind these permissions — so
          // turning Download off in the role editor stopped downloads from the
          // document screen and not from the approvals screen. Same checks,
          // same order as k3/.../document_info/build_action_buttons.dart.
          final bool canDownload = KnowledgeHubAccess.canDownload;
          final bool canView = KnowledgeHubAccess.canView;

          return Row(
            children: [
              if (canDownload)
                _buildActionButton(
                  context,
                  assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_download_icon.svg',
                  functionName: S.of(context).download,
                  onTap: isLoading ? null : () => _handleDownload(context),
                ),
              // Only when both are showing, so a single button is not left
              // sitting against a 15pt gap.
              if (canDownload && canView) SizedBox(width: 15.w),
              if (canView)
                _buildActionButton(
                  context,
                  assetPath: 'assets/icons_assets/knowledge_hub_assets/view_icon.svg',
                  functionName: S.of(context).view,
                  onTap: isLoading ? null : () => _handleView(context),
                ),
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
      }) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return _AnimatedActionButton(
      onTap: onTap,
      child: Container(
        height: 38.h,
        width: isMobile ? 38.w : 135.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.primary,
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
                  color: AppColors.textButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ✅ Video Player Widget
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool lightMode;

  const _VideoPlayerWidget({
    required this.videoUrl,
    required this.lightMode,
  });

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          backgroundColor: AppColors.colorGrey,
          bufferedColor: AppColors.primary.withOpacity(0.3),
        ),
        placeholder: Container(
          color: widget.lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                SizedBox(height: 16.h),
                Text(
                  'Error loading video',
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: widget.lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      log('❌ Error initializing video: $e', name: 'VideoPlayer');
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(
              'Loading video...',
              style: StyleText.fontSize14Weight500.copyWith(
                color: widget.lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
            SizedBox(height: 16.h),
            Text(
              'Error loading video',
              style: StyleText.fontSize16Weight600.copyWith(
                color: widget.lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: widget.lightMode ? AppColors.offWhite : AppColors.colorBlack.withOpacity(0.87),
      child: Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : SizedBox.shrink(),
      ),
    );
  }
}

// Helper function
Widget buildApprovalsActionButtons({
  required String knowledgeId,
  required String fileName,
  required String fileType,
  required String fileUrl,
  required String department,
  String fileExtension = '',
}) {
  return ApprovalsActionButtonsWidget(
    knowledgeId: knowledgeId,
    fileName: fileName,
    fileType: fileType,
    fileUrl: fileUrl,
    department: department,
    fileExtension: fileExtension,
  );
}
