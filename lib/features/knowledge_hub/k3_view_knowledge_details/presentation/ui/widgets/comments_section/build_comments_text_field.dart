/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/build_comments_text_field.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_comments_text_field.dart
/// Purpose: Contains the text field to add new comment on file in knowledge hub.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Refactored to use simplified comment model (only stores userId and email)

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../controller/create_comment_cubit.dart';
import '../../../controller/create_comment_states.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

class CommentInputWidget extends StatefulWidget {
  final String knowledgeId;

  const CommentInputWidget({super.key, required this.knowledgeId});

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget> {
  final TextEditingController _commentController = TextEditingController();
  File? _selectedFile;
  String? _selectedFileName;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final picked = await MediaPickerService().pickDocument(
        extensions: const [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
        ],
      );

      if (picked?.path != null) {
        setState(() {
          _selectedFile = File(picked!.path!);
          _selectedFileName = picked.name;
        });

        // Upload the file immediately
        if (mounted) {
          context.read<CommentsCubit>().uploadAttachment(_selectedFile!);
        }
      }
    } catch (e) {
      final lightMode = Theme.of(context).brightness == Brightness.light;
      showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: AppColors.transparent,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.colorWhite,
                ),
                padding: EdgeInsets.all(20.r),
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error picking file',
                      style: StyleText.fontSize20Weight500.copyWith(
                        color: lightMode
                            ? AppColors.secondaryText
                            : AppColors.grey,
                      ),
                    ),
                    customButton(
                      title: 'Got it',
                      function: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
    context.read<CommentsCubit>().clearAttachment();
  }

  Future<void> _submitComment() async {
    final commentText = _commentController.text.trim();

    if (commentText.isEmpty && _selectedFile == null) {
      log('You can not add empty comment');
      return;
    }

    final employeeEntity =
        Get.find<MainCoreEmployeeController>().employeeEntity!;
    log(employeeEntity.email ?? 'No email found', name: 'Employee email');

    // ✅ Only need userId and email - other user details fetched when displaying comments
    final String currentUserId = employeeEntity.id!;
    final String currentUserEmail = employeeEntity.email!;

    // Submit comment with simplified parameters
    await context.read<CommentsCubit>().createComment(
      knowledgeId: widget.knowledgeId,
      commentText: commentText,
      createdById: currentUserId,
      createdByEmail: currentUserEmail,
    );

    // Clear text field and file after submission
    _commentController.clear();
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return BlocListener<CommentsCubit, CommentsState>(
      listener: (context, state) {
        if (state is UploadAttachmentSuccess) {
          Fluttertoast.showToast(
            msg: 'File Uploaded Successfully',
            backgroundColor: AppColors.primary,
            textColor: AppColors.colorBlack,
          );
        } else if (state is UploadAttachmentFailure) {
          _removeFile();
          Fluttertoast.showToast(
            msg: 'Failed to Upload File: ${state.error}',
            backgroundColor: AppColors.red,
            textColor: AppColors.colorWhite,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show selected file if exists
          if (_selectedFileName != null)
            Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.colorWhite,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, size: 16.w, color: AppColors.primary),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      _selectedFileName!,
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: lightMode
                            ? AppColors.secondaryText
                            : AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18.w),
                    onPressed: _removeFile,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          // Comment input
          Container(
            constraints: BoxConstraints(minHeight: 38.h, maxHeight: 120.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildTextField(context),
                SizedBox(width: 10.w),
                _buildSendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
        ),
        height: 38.sp,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<CommentsCubit, CommentsState>(
              builder: (context, state) {
                if (state is UploadAttachmentLoading) {
                  return CustomSvgImage(
                    assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_attach_icon.svg',
                    height: 16.h,
                    width: 16.w,
                  );
                }
                return GestureDetector(
                  onTap: _pickFile,
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: 10.w),
                    child: CustomSvgImage(
                      assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_attach_icon.svg',
                      height: 16.h,
                      width: 16.w,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: _commentController,
                maxLines: null,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  hintText: S.of(context).write_a_comment,
                  hintStyle: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        final isLoading = state is CreateCommentLoading;

        return GestureDetector(
          onTap: isLoading ? null : _submitComment,
          child: Container(
            width: 38.sp,
            height: 38.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.secondaryPrimary,
            ),
            alignment: Alignment.center,
            child: CustomSvgImage(
              assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_send_icon.svg',
              height: 20.h,
              width: 20.w,
            ),
          ),
        );
      },
    );
  }
}

// Helper function to use in other files
Widget buildCommentInput(BuildContext context, {required String knowledgeId}) {
  return CommentInputWidget(knowledgeId: knowledgeId);
}
