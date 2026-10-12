/// Module: knowledge_hub / presentation / s5_submission_details / widgets/submitted_document_info_card.dart
/// ************************* FILE INFO *************************** ///
/// File Name: document_info_card.dart
/// Purpose: Contains the document info without inquiries and comments.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/knowledge_hub/k5_submission_details/presentation/ui/widgets/submitted_document_header.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import './build_submission_date.dart';
import './build_submitted_document_data_row.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget submittedDocumentInfoCard(
  BuildContext context, {
  required String publishDate,
  required String documentName,
  required String documentType,
  required String owningDepartment,
  required String documentDescription,
  required String documentExtension,
  required bool isMobile,
  required String currentStatus,
  List<String>? limitedDepartments,
}) {
  final isMobile = ResponsivePage.isMobile(context);
  final lightMode = Theme.of(context).brightness == Brightness.light;

  // ✅ MODIFIED: Changed to return Widget instead of IconData
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'rejected':
        return {
          'text': S.of(context)!.rejected,
          'color': AppColors.red,
          'widget': CustomSvgImage(
            assetPath:
                'assets/svg/Group 1000004184.svg', // Replace with your SVG path
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };
      case 'pending_approval':
      case 'scheduled':
        return {
          'text': S.of(context)!.pending,
          'color': AppColors.orange,
          'widget': CustomSvgImage(
            assetPath: 'assets/svg/pending.svg', // Replace with your SVG path
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };
      case 'published':
        return {
          'text': S.of(context)!.published,
          'color': AppColors.green,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/published_status_icon.svg',
            // Replace with your SVG path
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };
      case 'approved':
        return {
          'text': S.of(context)!.approved,
          'color': AppColors.lightGreen,
          'widget': CustomSvgImage(
            assetPath:
                'assets/svg/approve_new.svg', // Replace with your SVG path
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.fill,
          ),
        };
      case 'removed':
        return {
          'text': 'Removed',
          'color': AppColors.white,
          'widget': CustomSvgImage(
            assetPath: 'assets/svg/remove.svg', // Replace with your SVG path
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };
      default:
        return {
          'text': status,
          'color': AppColors.primary,
          'widget': Icon(Icons.info, color: AppColors.colorWhite, size: 20.sp),
        };
    }
  }

  final statusInfo = _getStatusInfo(currentStatus);
  final isPending =
      currentStatus == 'pending_approval' || currentStatus == 'scheduled';

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.r),
      color: lightMode ? AppColors.white : AppColors.chatBackground,
    ),
    padding: EdgeInsets.all(15.sp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildSubmissionDate(context, submissionDate: publishDate),
        buildSubmittedDocumentHeader(
          context,
          documentName: documentName,
          documentDescription: documentDescription,
          documentExtension: documentExtension,
          isMobile: isMobile,
          lightMode: lightMode,
        ),
        SizedBox(height: 15.h),

        if (isMobile) ...[
          buildSubmittedDocumentDescription(
            context,
            documentDescription: documentDescription,
            isMobile: isMobile,
            lightMode: lightMode,
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
                fit: BoxFit.cover,
              ),
              SizedBox(width: 5.w),
              Text(
                '${S.of(context).document_type}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              Text(
                documentType,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/owning_department_icon.svg',
                fit: BoxFit.cover,
              ),
              SizedBox(width: 3.w),
              Text(
                S.of(context).owning_department,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              Text(
                owningDepartment,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/limited_department_icon.svg',
                fit: BoxFit.cover,
              ),
              SizedBox(width: 3.w),
              Text(
                '${S.of(context).limit_department_availability}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              Text(
                "limited Departments",
                style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomSvgImage(
                        assetPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '${S.of(context).document_type}: ',
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                      Text(
                        documentType,
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      CustomSvgImage(
                        assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '${S.of(context).start_date}: ',
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                      Text(
                        DateFormat('DD MMM').format(DateTime.now()),
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 50.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomSvgImage(
                        assetPath: 'assets/icons_assets/knowledge_hub_assets/owning_department_icon.svg',
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        S.of(context).owning_department,
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                      Text(
                        owningDepartment,
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Row(
                    children: [
                      CustomSvgImage(
                        assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '${S.of(context).end_date}: ',
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.secondaryText
                              : AppColors.grey,
                        ),
                      ),
                      Text(
                        DateFormat('DD MMM').format(DateTime.now()),
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
        SizedBox(height: 15.h),
        if (limitedDepartments != null && limitedDepartments.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/limited_department_icon.svg',
                fit: BoxFit.cover,
              ),
              SizedBox(width: 5.w),
              Text(
                '${S.of(context)!.limitedDepartmentAvailability}: ',
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              Flexible(
                // ✅ Changed from Expanded to Flexible
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (limitedDepartments.isEmpty)
                      ? [
                          Text(
                            'N/A',
                            style: StyleText.fontSize14Weight400.copyWith(
                              color: lightMode
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                        ]
                      : limitedDepartments.map((department) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: lightMode
                                  ? AppColors.background
                                  : AppColors.chatBackground,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              department,
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                            ),
                          );
                        }).toList(),
                ),
              ),
            ],
          ),

        if (currentStatus == 'rejected') ...[
          SizedBox(height: 15.h),
          Row(
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/main_icons_assets/assets_status.svg',
                fit: BoxFit.cover,
              ),
              SizedBox(width: 5.w),
              Text(
                '${S.of(context)!.reasonOfRejection}: ',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: lightMode
                      ? AppColors.secondaryText
                      : AppColors.grey,
                ),
              ),
              Text(
                S.of(context)!.reasonOfRejection,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode
                      ? AppColors.blackButton
                      : AppColors.white,
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: 15.h),

        Row(
          mainAxisAlignment: isMobile
              ? MainAxisAlignment.center
              : (isPending
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end),
          children: [
            if (isPending) ...[
              GestureDetector(
                onTap: () {
                  // TODO: Implement send reminder functionality
                },
                child: Container(
                  height: 36.sp,
                  width: isMobile ? 150.w : 185.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 6.h,
                    horizontal: 15.w,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath: 'assets/icons_assets/knowledge_hub_assets/send_reminder_icon.svg',
                        fit: BoxFit.cover,
                        width: 24.w,
                        height: 24.h,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        S.of(context)!.sendReminder,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Container(
                height: 36.sp,
                width: isMobile ? 150.w : 185.w,
                decoration: BoxDecoration(
                  color: lightMode
                      ? AppColors.white
                      : AppColors.chatBackground,
                  border: Border.all(color: statusInfo['color'], width: 2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ MODIFIED: Changed from CircleAvatar with Icon to Widget
                    Center(
                      child: statusInfo['widget'], // ✅ Use the widget here
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      statusInfo['text'],
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: statusInfo['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                height: 36.sp,
                width: isMobile ? ScreenUtil().screenWidth - 80.w : 200.w,
                decoration: BoxDecoration(
                  color: lightMode
                      ? AppColors.white
                      : AppColors.chatBackground,
                  border: Border.all(color: statusInfo['color'], width: 2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ MODIFIED: Changed from CircleAvatar with Icon to Widget
                    Center(
                      child: statusInfo['widget'], // ✅ Use the widget here
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      statusInfo['text'],
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: statusInfo['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}
