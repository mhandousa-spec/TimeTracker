/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/comments_item.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comments_item.dart
/// Purpose: Contains the comment created on specific file in knowledge hub.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Refactored to fetch user data from cubit cache

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../main_controller/data/models/create_new_comment_model.dart';
import '../../../controller/create_comment_cubit.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

Widget commentItem({
  required CreateNewCommentModel comment,
  required bool isMyComment,
  required CommentsCubit cubit, // ✅ Required to access user data cache
}) {
  // ✅ Get user data from cache using createdById
  final userId = comment.currentCreatedById;
  final userData = cubit.usersCache[userId];

  // ✅ Parse timestamp string to DateTime
  DateTime? createdAt;
  try {
    final timestampStr = comment.currentTimestamp;
    if (timestampStr.isNotEmpty) {
      // Try parsing as formatted string first (yyyy-MM-dd HH:mm:ss)
      createdAt = DateTime.tryParse(timestampStr);
      
      // If that fails, try parsing as milliseconds timestamp
      if (createdAt == null) {
        final timestamp = int.tryParse(timestampStr);
        if (timestamp != null) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }
    }
  } catch (e) {
    // If parsing fails, use current time as fallback
    createdAt = DateTime.now();
  }

  return Align(
    alignment: isMyComment
        ? AlignmentDirectional.centerEnd
        : AlignmentDirectional.centerStart,
    child: Container(
      constraints: BoxConstraints(
        maxWidth: 0.75.sw, // Limit width to 75% of screen width
      ),
      child: Column(
        crossAxisAlignment: isMyComment
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isMyComment
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!isMyComment) ...[
                CircleAvatar(
                  backgroundColor: AppColors.background,
                  radius: 17.5.r,
                  backgroundImage: userData?.currentemployeePhoto.isNotEmpty == true
                      ? NetworkImage(userData!.currentemployeePhoto)
                      : null,
                  child: userData?.currentemployeePhoto.isNotEmpty != true
                      ? Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                SizedBox(width: 5.w,),
              ],
              Column(
                crossAxisAlignment: isMyComment
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userData?.currentemployeeName ?? 'Unknown User',
                    style: StyleText.fontSize14Weight500,
                  ),
                  Text(
                    userData?.currentemployeeRole ?? '',
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
              if (isMyComment) ...[
                SizedBox(width: 5.w,),
                CircleAvatar(
                  backgroundColor: AppColors.background,
                  radius: 17.5.r,
                  backgroundImage: userData?.currentemployeePhoto.isNotEmpty == true
                      ? NetworkImage(userData!.currentemployeePhoto)
                      : null,
                  child: userData?.currentemployeePhoto.isNotEmpty != true
                      ? Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h,),
          Container(
            decoration: BoxDecoration(
              color:
                  comment.currentAttachmentExtension.isNotEmpty &&
                      comment.currentCommentText.isEmpty
                  ? AppColors.transparent
                  : isMyComment
                  ? AppColors.transparent
                  : AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsetsDirectional.only(
              top: 8.h,
              bottom: 8.h,
              start: 14.w,
              end: 21.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isMyComment
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (comment.currentCommentText.isNotEmpty)
                  Text(
                    comment.currentCommentText,
                    style: StyleText.fontSize14Weight500,
                  ),
                // Display attachment if exists
                if (comment.currentAttachmentExtension.isNotEmpty)
                  _buildAttachment(comment),
              ],
            ),
          ),
          SizedBox(height: 8.h,),
          Text(
            _formatDateTime(createdAt ?? DateTime.now()),
            style: StyleText.fontSize12Weight600.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildAttachment(CreateNewCommentModel comment) {
  return Container(
    margin: EdgeInsets.only(top: 8.h),
    padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(
      color: AppColors.colorWhite,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: AppColors.background),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomSvgImage(
          assetPath: _getFileIcon(comment.currentAttachmentExtension),
          height: 50.sp,
          width: 45.sp,
        ),
        SizedBox(width: 5.w,),
        Flexible(
          child: Text(
            'Attachment', // ✅ Filename not stored, show generic text
            style: StyleText.fontSize12Weight500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (comment.currentAttachmentSize > 0)
          Text(
            ' (${_formatFileSize(comment.currentAttachmentSize)})',
            style: StyleText.fontSize10Weight400.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
      ],
    ),
  );
}

String _formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('dd MMM yyyy \'At\' hh:mm a');
  return formatter.format(dateTime);
}

String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _getFileIcon(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
    case 'doc':
    case 'docx':
      return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
    case 'xls':
    case 'xlsx':
      return 'assets/svg/excel_icon.svg';
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    default:
      return 'assets/svg/file_icon.svg';
  }
}