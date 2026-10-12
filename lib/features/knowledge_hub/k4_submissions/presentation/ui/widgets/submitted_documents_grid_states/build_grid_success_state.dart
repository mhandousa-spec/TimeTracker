/// Module: knowledge_hub / presentation / s4_submissions / widgets/submitted_documents_grid_states/build_grid_success_state.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_grid_success_state.dart
/// Purpose: Build grid success state — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../../../main_controller/data/services/submissions_firebase_service.dart';
import '../../../controller/submissions_cubit.dart';
import '../../../../../k5_submission_details/presentation/ui/pages/submission_details_screen.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

Widget buildSubmissionsGrid(BuildContext context, bool isMobile) {
  var isMobile = ContextExtension(context).isPhone;
  final lightMode = Theme.of(context).brightness == Brightness.light;

  String getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'assets/icons_assets/main_icons_assets/svg_pdf_icon.svg';
      case 'ppt':
      case 'pptx':
        return 'assets/icons_assets/main_icons_assets/ppt_attachment_icon.svg';
      case 'doc':
      case 'docx':
        return 'assets/icons_assets/main_icons_assets/doc_icon.svg';
      case 'png':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    }
  }

  // Format date
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  final cubit = context.read<SubmissionsCubit>();
  final submissions = cubit.filteredKnowledge;

  if (submissions.isEmpty) {
    return buildNoFilterResultsState(context);
  }

  return SizedBox(
    height: 600.sp,
    child: GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
            context,
          ),
          mainAxisExtent: 100.sp,
          crossAxisSpacing: 15.sp,
          mainAxisSpacing: 15.sp
      ),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        final Color statusColor = _getStatusColor(submission.currentStatus);

        // ✅ Updated: Handle both Timestamp and int
        final DateTime? uploadDate = submission.timestamps.isNotEmpty
            ? _getTimestampDate(submission.timestamps.first)
            : null;

        final DateTime? lastEditDate = submission.timestamps.isNotEmpty
            ? _getTimestampDate(submission.timestamps.last)
            : null;

        final String statusDisplay = _getStatusDisplay(
          context,
          submission.currentStatus,
        );

        // ✅ Get start and end dates from submission
        final DateTime? startDate = _getTimestampDate(submission.startDateTime);
        final DateTime? endDate = _getTimestampDate(submission.endDateTime);

        return GestureDetector(
          onTap: (){},
          child: Container(
            width: isMobile ? 345.sp : ContextExtension(context).isTabletLandscape ? 288.sp : 320.sp,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.r),
              color: lightMode ? AppColors.white : AppColors.chatBackground,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        submission.currentImageUrl.isNotEmpty
                            ? SizedBox(
                          height: 55.h,
                          width: 40.w,
                          child: Image.network(
                            submission.currentImageUrl,
                            fit: BoxFit.fitHeight,
                          ),
                        )
                            : CustomSvgImage(
                          assetPath: getFileIcon(submission.currentDocumentExtension),
                          height: 50.h,
                          width: 50.w,
                          fit: BoxFit.scaleDown,
                        ),
                        Text(
                          submission.currentNameEnglish,
                          style: StyleText.fontSize12Weight500.copyWith(
                            color: lightMode
                                ? AppColors.blackButton
                                : AppColors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.sp),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                S.of(context).owning_department,
                                style: StyleText.fontSize12Weight600.copyWith(
                                  color: lightMode
                                      ? AppColors.secondaryText
                                      : AppColors.grey,
                                ),
                              ),
                              Text(
                                submission.currentOwningDepartment,
                                style: StyleText.fontSize12Weight600.copyWith(
                                  color: lightMode
                                      ? AppColors.blackButton
                                      : AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    S.of(context).publish_date,
                                    style: StyleText.fontSize12Weight400.copyWith(
                                      color: lightMode
                                          ? AppColors.secondaryText
                                          : AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatDate(uploadDate),
                                    style: StyleText.fontSize12Weight400.copyWith(
                                      color: lightMode
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              SizedBox(width: 75.sp),
                              Row(
                                children: [
                                  Text(
                                    '${S.of(context).last_edit}: ',
                                    style: StyleText.fontSize12Weight400.copyWith(
                                      color: lightMode
                                          ? AppColors.secondaryText
                                          : AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    formatDate(lastEditDate),
                                    style: StyleText.fontSize12Weight400.copyWith(
                                      color: lightMode
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget buildNoFilterResultsState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.search_off, size: 64.sp, color: AppColors.secondaryText),
        SizedBox(height: 16.h),
        Text(
          S.of(context)!.noSubmissionsMatchFilters,
          style: StyleText.fontSize16Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    ),
  );
}

/// ✅ Updated: Handle both Firestore Timestamp and int timestamps
DateTime? _getTimestampDate(dynamic timestamp) {
  if (timestamp == null) return null;

  try {
    // If it's a Firestore Timestamp
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    // If it's an integer (milliseconds)
    else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    // If it's a String that contains a number
    else if (timestamp is String) {
      final int? ms = int.tryParse(timestamp);
      if (ms != null) {
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    return null;
  } catch (e) {
    log('Error parsing timestamp: $e');
    return null;
  }
}

/// Helper function to get display name for status
String _getStatusDisplay(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'published':
      return S.of(context)!.published;
    case 'pending_approval':
      return S.of(context)!.pending;
    case 'scheduled':
      return S.of(context)!.scheduled;
    case 'rejected':
      return S.of(context)!.rejected;
    case 'removed':
      return S.of(context)!.removed;
    case 'archived':
      return S.of(context)!.archive;
    default:
      return status;
  }
}

/// Helper function to get color for status
Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'published':
      return AppColors.green;
    case 'pending_approval':
      return AppColors.orange;
    case 'scheduled':
      return AppColors.blue;
    case 'rejected':
      return AppColors.red;
    case 'removed':
      return AppColors.colorGrey;
    case 'archived':
      return AppColors.secondaryText;
    default:
      return AppColors.grey;
  }
}
