/// Module: knowledge_hub / presentation / s5_submission_details / widgets/comments_section/comments_list_view_on_submitted_file.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comments_list_view_on_submitted_file.dart
/// Purpose: Comments list view on submitted file — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/services/knowledge_hub_firebase_services.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../../../main_controller/data/models/create_new_comment_model.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../k4_submissions/presentation/controller/submissions_cubit.dart';
import './comment_item_on_submitted_file.dart';

/// ✅ Wrapper function for backwards compatibility
Widget commentsListViewOnSubmittedFile({
  required BuildContext context,
  required bool lightMode,
  required List<CreateNewCommentModel> comments,
  required SubmissionsCubit cubit,
  required String knowledgeId,
  String? currentUserEmail,
}) {
  return CommentsListViewOnSubmittedFile(
    parentContext: context,
    lightMode: lightMode,
    comments: comments,
    cubit: cubit,
    knowledgeId: knowledgeId,
    currentUserEmail: currentUserEmail,
  );
}

/// ✅ Enhanced Comments List View with CommentSection-style UI
class CommentsListViewOnSubmittedFile extends StatefulWidget {
  final BuildContext parentContext;
  final bool lightMode;
  final List<CreateNewCommentModel> comments;
  final SubmissionsCubit cubit;
  final String knowledgeId;
  final String? currentUserEmail;

  const CommentsListViewOnSubmittedFile({
    Key? key,
    required this.parentContext,
    required this.lightMode,
    required this.comments,
    required this.cubit,
    required this.knowledgeId,
    this.currentUserEmail,
  }) : super(key: key);

  @override
  State<CommentsListViewOnSubmittedFile> createState() =>
      _CommentsListViewOnSubmittedFileState();
}

class _CommentsListViewOnSubmittedFileState
    extends State<CommentsListViewOnSubmittedFile> {
  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MediaPickerService _mediaPicker = MediaPickerService();
  bool isFullScreen = false;

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============= MEDIA UPLOAD =============
  Future<void> _pickMedia() async {
    final isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows);
    final controller = Get.find<MainCoreEmployeeController>();

    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SimpleDialog(
        backgroundColor: widget.lightMode
            ? AppColors.white
            : AppColors.chatBackground,
        title: Text(
          S.of(context).selectFileSource,
          style: StyleText.fontSize16Weight500.copyWith(
            color: widget.lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
        children: [
          if (!isDesktop) _buildMediaOption(S.of(context).camera, 'camera'),
          _buildMediaOption(S.of(context).gallery, 'gallery'),
          _buildMediaOption(S.of(context).document, 'document'),
          _buildMediaOption(S.of(context).cancel, null),
        ],
      ),
    );

    if (choice == null) return;

    String? filePath;
    String? fileName;
    String? fileExtension;
    int? fileSize;

    // Handle Camera or Gallery
    if (choice == 'camera' || choice == 'gallery') {
      final picked =
          await _mediaPicker.pickImage(fromCamera: choice == 'camera');
      if (picked?.path == null) return;

      filePath = picked!.path;
      fileName = picked.name;
      fileExtension = fileName.split('.').last;
      fileSize = picked.bytes.length;
    }
    // Handle Document
    else if (choice == 'document') {
      final picked = await _mediaPicker.pickDocument(
        extensions: const ['pdf', 'doc', 'docx'],
      );
      if (picked?.path == null) return;

      filePath = picked!.path;
      fileName = picked.name;
      fileExtension = fileName.split('.').last;
      fileSize = picked.bytes.length;
    }

    if (filePath == null || fileName == null) return;

    try {
      // Show loading
      _showLoadingDialog("uploadingFile");

      // Upload via service (no FirebaseStorage in the UI layer, S5-04)
      await KnowledgeHubFirebaseServices().uploadCommentAttachment(
        file: File(filePath),
        knowledgeId: widget.knowledgeId,
        fileName: fileName,
      );

      Navigator.of(context).pop(); // Hide loading

      final employeeEntity = controller.employeeEntity;
      if (employeeEntity == null ||
          employeeEntity.id == null ||
          employeeEntity.email == null) {
        _showErrorSnackbar(S.of(context).error);
        return;
      }

      // Add comment with attachment
      await widget.cubit.addComment(
        knowledgeId: widget.knowledgeId,
        commentText: fileName,
        createdById: employeeEntity.id!,
        createdByEmail: employeeEntity.email!,
        attachmentExtension: fileExtension,
        attachmentSize: fileSize,
      );

      _showSuccessSnackbar(S.of(context).uploadSuccess);
      _scrollToBottom();
    } catch (e) {
      Navigator.of(context).pop(); // Hide loading
      _showErrorSnackbar('${S.of(context).uploadFailed}: $e');
    }
  }

  Widget _buildMediaOption(String title, String? returnVal) {
    return Padding(
      padding: EdgeInsets.all(8.sp),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: SimpleDialogOption(
            onPressed: () => Navigator.pop(context, returnVal),
            child: Text(
              title,
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============= COMMENT ACTIONS =============
  Future<void> _sendMessage() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final controller = Get.find<MainCoreEmployeeController>();
    final employeeEntity = controller.employeeEntity;

    if (employeeEntity == null ||
        employeeEntity.id == null ||
        employeeEntity.email == null) {
      _showErrorSnackbar(S.of(context).error);
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await widget.cubit.addComment(
        knowledgeId: widget.knowledgeId,
        commentText: text,
        createdById: employeeEntity.id!,
        createdByEmail: employeeEntity.email!,
      );

      commentController.clear();
      _scrollToBottom();
    } catch (e) {
      _showErrorSnackbar('$e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _editComment(CreateNewCommentModel comment, int index) {
    final editController = TextEditingController(text: comment.currentCommentText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.lightMode
            ? AppColors.white
            : AppColors.chatBackground,
        title: Text(
          S.of(context).EditMessage,
          style: StyleText.fontSize16Weight500.copyWith(
            color: widget.lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: S.of(context).Edityourmessage,
            filled: true,
            fillColor: widget.lightMode
                ? AppColors.background
                : AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: null,
          style: StyleText.fontSize14Weight400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).Cancel,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty) {
                try {
                  // TODO: Implement update comment in cubit
                  Navigator.pop(context);
                  _showSuccessSnackbar(S.of(context).Save);
                } catch (e) {
                  _showErrorSnackbar('${S.of(context).error}: $e');
                }
              }
            },
            child: Text(
              S.of(context).Save,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteComment(CreateNewCommentModel comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.lightMode
            ? AppColors.white
            : AppColors.chatBackground,
        title: Text(
          S.of(context).delete,
          style: StyleText.fontSize16Weight500,
        ),
        content: Text(
          S.of(context).areYouSureYouWantToRemoveDocument,
          style: StyleText.fontSize14Weight400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).no,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                // TODO: Implement delete comment in cubit
                Navigator.pop(context);
                _showSuccessSnackbar('Comment deleted');
              } catch (e) {
                _showErrorSnackbar('${S.of(context).error}: $e');
              }
            },
            child: Text(
              S.of(context).yes,
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ============= UI HELPERS =============
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: widget.lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16.h),
                Text(message, style: StyleText.fontSize14Weight500),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.lightGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ============= MAIN UI =============
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainCoreEmployeeController>();
    final String? userEmail =
        widget.currentUserEmail ?? controller.employeeEntity?.email;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // // Fullscreen toggle button
        // InkWell(
        //   onTap: () {
        //     setState(() {
        //       isFullScreen = !isFullScreen;
        //     });
        //   },
        //   splashColor: AppColors.transparent,
        //   hoverColor: AppColors.transparent,
        //   child: Text(
        //     isFullScreen
        //         ? (isArabic ? 'تصغير' : 'Minimize')
        //         : (isArabic ? 'تكبير' : 'Maximize'),
        //     style: StyleText.fontSize12Weight400.copyWith(
        //       color: AppColors.blue,
        //       decoration: TextDecoration.underline,
        //       decorationColor: AppColors.blue,
        //     ),
        //   ),
        // ),
        //
        // SizedBox(height: 5.h),

        // Main content container
        Container(
          height: isFullScreen ? 570.h : 300.h,
          child: Column(
            children: [
              // Comments content area
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15.sp),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Comments list
                        ...List.generate(widget.comments.length, (index) {
                          final comment = widget.comments[index];
                          final userId = comment.currentCreatedById;
                          final userData = widget.cubit.usersCache[userId];

                          bool isMyComment = false;
                          if (userEmail != null) {
                            isMyComment = comment.currentCreatedByEmail
                                .toLowerCase()
                                .trim() ==
                                userEmail.toLowerCase().trim();
                          }

                          DateTime? createdAt;
                          try {
                            final timestampStr = comment.currentTimestamp;
                            if (timestampStr.isNotEmpty) {
                              createdAt = DateTime.tryParse(timestampStr);
                              if (createdAt == null) {
                                final timestamp = int.tryParse(timestampStr);
                                if (timestamp != null) {
                                  createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
                                }
                              }
                            }
                          } catch (e) {
                            createdAt = DateTime.now();
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: 30.sp),
                            child: commentItemOnSubmittedFile(
                              context: context,
                              commentText: comment.currentCommentText,
                              attachmentExtension: comment.currentAttachmentExtension,
                              attachmentSize: comment.currentAttachmentSize,
                              createdAt: createdAt ?? DateTime.now(),
                              createdByName: userData?.currentemployeeName ?? 'Unknown User',
                              createdByRole: userData?.currentemployeeRole ?? '',
                              createdByPhoto: userData?.currentemployeePhoto.isNotEmpty == true
                                  ? userData!.currentemployeePhoto
                                  : null,
                              isMyComment: isMyComment,
                              lightMode: widget.lightMode,
                              onEdit: () => _editComment(comment, index),
                              onDelete: () => _deleteComment(comment),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Input Field
              Row(
                children: [
                  // Input Field with Upload Button
                  Expanded(
                    child: Container(
                      height: 38.h,
                      decoration: BoxDecoration(
                        color: widget.lightMode
                            ? AppColors.white
                            : AppColors.chatBackground,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: GestureDetector(
                              onTap: _pickMedia,
                              child: SvgPicture.asset(
                                "assets/icons_assets/main_icons_assets/uploadcamera.svg",
                                width: 16.sp,
                                height: 16.sp,
                                color: widget.lightMode
                                    ? AppColors.blackButton
                                    : AppColors.whiteShadow,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          hintText: S.of(context).WriteaComment,
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8.w),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: widget.lightMode
                              ? AppColors.white
                              : AppColors.chatBackground,
                          hintStyle: StyleText.fontSize14Weight500.copyWith(
                            color: widget.lightMode
                                ? AppColors.secondaryText
                                : AppColors.grey,
                          ),
                        ),
                        style: StyleText.fontSize14Weight500.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 15.w),

                  // Send Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 35.sp,
                      height: 35.sp,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryPrimary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: SvgPicture.asset(
                        "assets/icons_assets/main_icons_assets/assets_save.svg",
                        width: 20.sp,
                        height: 20.sp,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
}