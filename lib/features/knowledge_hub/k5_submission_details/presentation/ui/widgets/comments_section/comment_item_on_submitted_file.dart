/// Module: knowledge_hub / presentation / s5_submission_details / widgets/comments_section/comment_item_on_submitted_file.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comment_item_on_submitted_file.dart
/// Purpose: Comment item on submitted file — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

Widget commentItemOnSubmittedFile({
  required BuildContext context,
  required bool isMyComment,
  String? createdByPhoto,
  required String createdByName,
  required String createdByRole,
  required String commentText,
  String? attachmentExtension,
  int? attachmentSize,
  required DateTime createdAt,
  required bool lightMode,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return Container(
    height: 180.h,
    decoration: BoxDecoration(
      color: lightMode
          ? AppColors.white
          : AppColors.chatBackground,
    ),
    child: Padding(
      padding: EdgeInsets.only(bottom: 15.h, left: 15.w, right: 15.w, top: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Name/Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: lightMode
                    ? AppColors.background
                    : AppColors.chatBackground,
                radius: 17.5.r,
                child: createdByPhoto != null && createdByPhoto.isNotEmpty
                    ? ClipOval(
                  child: Image.network(
                    createdByPhoto,
                    width: 35.r,
                    height: 35.r,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SvgPicture.asset(
                        "assets/icons_assets/main_icons_assets/assets_male.svg",
                        width: 35.sp,
                        height: 35.sp,
                        fit: BoxFit.cover,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                )
                    : SvgPicture.asset(
                  "assets/icons_assets/main_icons_assets/assets_male.svg",
                  width: 35.sp,
                  height: 35.sp,
                  fit: BoxFit.cover,
                ),
              ),


              SizedBox(width: 10.w),

              // Name and Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      createdByName,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                    SizedBox(height: 5.sp),
                    if (createdByRole.isNotEmpty)
                      Text(
                        createdByRole,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Message/Attachment Bubble
          GestureDetector(
            onLongPress: isMyComment
                ? () => _showCustomMenu(
              context,
              lightMode: lightMode,
              onEdit: onEdit,
              onDelete: onDelete,
            )
                : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: lightMode
                    ? AppColors.background
                    : AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text Comment
                  if (commentText.isNotEmpty)
                    Text(
                      commentText,
                      style: StyleText.fontSize12Weight400.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),

                  // Attachment Preview
                  if (attachmentExtension != null &&
                      attachmentExtension.isNotEmpty &&
                      attachmentExtension != '')
                    Padding(
                      padding: EdgeInsets.only(top: commentText.isNotEmpty ? 8.h : 0),
                      child: _buildAttachmentPreview(
                        attachmentExtension,
                        attachmentSize ?? 0,
                        lightMode,
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // Timestamp
          Text(
            _formatDateTime(createdAt),
            style: StyleText.fontSize10Weight400.copyWith(
              color: lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}

// Attachment Preview Widget
Widget _buildAttachmentPreview(String extension, int size, bool lightMode) {
  final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.webp', 'jpg', 'jpeg', 'png', 'gif', 'webp']
      .any((ext) => extension.toLowerCase().contains(ext));
  final isPDF = extension.toLowerCase().contains('pdf');

  return Row(
    children: [
      SvgPicture.asset(
        isImage ? 'assets/icons_assets/main_icons_assets/images_image_big.svg' : 'assets/icons_assets/main_icons_assets/assets_pdf.svg',
        width: 35.sp,
        height: 35.sp,
        fit: BoxFit.scaleDown,
      ),
      SizedBox(width: 8.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isImage ? 'Image Attachment' : 'Document Attachment',
              style: TextStyle(
                color: AppColors.blue,
                decoration: TextDecoration.underline,
                fontSize: 12.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (size > 0)
              Text(
                _formatFileSize(size),
                style: TextStyle(
                  color: lightMode ? AppColors.colorBlack.withOpacity(0.54) : AppColors.colorWhite.withOpacity(0.54),
                  fontSize: 10.sp,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

// Format file size
String _formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

// Format DateTime
String _formatDateTime(DateTime dateTime) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';

  return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} At $hour:${dateTime.minute.toString().padLeft(2, '0')} $period";
}

// Custom Menu for Edit/Delete
void _showCustomMenu(
    BuildContext context, {
      required bool lightMode,
      required VoidCallback onEdit,
      required VoidCallback onDelete,
    }) {
  String? selectedItem;

  showDialog(
    context: context,
    barrierColor: AppColors.colorBlack.withOpacity(0.26),
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () => Navigator.pop(dialogContext),
            child: Material(
              color: AppColors.transparent,
              child: Center(
                child: Container(
                  width: 150.w,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: lightMode
                        ? AppColors.white
                        : AppColors.chatBackground,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.colorBlack.withOpacity(0.26),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOptionItem(
                        label: S.of(dialogContext).edit,
                        iconPath: "assets/icons_assets/main_icons_assets/edit_icon.svg",
                        isSelected: selectedItem == 'edit',
                        lightMode: lightMode,
                        onTap: () {
                          setState(() => selectedItem = 'edit');
                          Future.delayed(Duration(milliseconds: 150), () {
                            Navigator.pop(dialogContext);
                            onEdit();
                          });
                        },
                      ),
                      _buildOptionItem(
                        label: S.of(dialogContext).delete,
                        iconPath: "assets/icons_assets/main_icons_assets/icon _trash.svg",
                        isSelected: selectedItem == 'delete',
                        lightMode: lightMode,
                        onTap: () {
                          setState(() => selectedItem = 'delete');
                          Future.delayed(Duration(milliseconds: 150), () {
                            Navigator.pop(dialogContext);
                            onDelete();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildOptionItem({
  required String label,
  required String iconPath,
  required bool isSelected,
  required bool lightMode,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 280.sp,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : (lightMode ? AppColors.white : AppColors.chatBackground),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            fit: BoxFit.scaleDown,
            color: isSelected
                ? AppColors.white
                : AppColors.secondaryText,
            width: 14.sp,
            height: 14.sp,
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
              color: isSelected
                  ? AppColors.white
                  : (lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}