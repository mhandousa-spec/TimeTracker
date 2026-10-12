/// Module: knowledge_hub / presentation / s7_approvals_details / approvals_details_screen.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_details_screen.dart
/// Purpose: Approvals details screen — Approvals Details (S7) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/knowledge_hub/k7_approvals_details/presentation/ui/widgets/build_action_buttons.dart';
import 'package:knowticed_plus/features/knowledge_hub/k7_approvals_details/presentation/ui/widgets/reason_for_justifications_dialog.dart';
import 'package:knowticed_plus/features/knowledge_hub/k7_approvals_details/presentation/ui/widgets/reason_for_approval_removing_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/services/knowledge_hub_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/submission_date_formatter.dart';

import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import '../../../../../../core/extensions/context_extensions.dart';
import '../../../../main_controller/data/models/employee_data.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k6_approvals/presentation/controller/approvals_cubit.dart';
import '../../../../k6_approvals/presentation/controller/approvals_states.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
// ADDED 2/9/2026 — the Approve / Reject tier check used by the part file below.
import '../../../../main_controller/helper/knowledge_hub_permissions.dart';

part './approvals_details_screen.sections.dart';

/// ✅ COMPLETE UPDATED APPROVALS DETAILS SCREEN
///
/// Key Features:
/// - ✅ Real-time status updates (approved/rejected)
/// - ✅ Arabic/English localization for title, description
/// - ✅ Formatted phone numbers with country code
/// - ✅ Proper SVG icons and colors for all statuses
/// - ✅ BlocListener for state management
/// - ✅ Dynamic action buttons based on status
/// - ✅ Start/End dates and times display

class ApprovalsDetailsScreen extends StatefulWidget {
  final String documentName;
  final String knowledgeId;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final String department;
  final String documentDesc;
  final String createdByEmail;
  final int? createdTimestamp;
  final String status;
  final String fileExtension;
  final dynamic startDate;
  final dynamic endDate;
  final dynamic startTime;
  final dynamic endTime;

  const ApprovalsDetailsScreen({
    super.key,
    required this.documentName,
    required this.knowledgeId,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.department,
    required this.documentDesc,
    required this.createdByEmail,
    this.createdTimestamp,
    required this.status,
    required this.fileExtension,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  @override
  State<ApprovalsDetailsScreen> createState() => _ApprovalsDetailsScreenState();
}

class _ApprovalsDetailsScreenState extends State<ApprovalsDetailsScreen> with _ApprovalsDetailsSections {
  // ---- fields & helpers moved to _ApprovalsDetailsSections (approvals_details_screen.sections.dart) ----


  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
    _fetchData();
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final statusInfo = _getStatusInfo(currentStatus);

    // ✅ Format dates and times
    final formattedStartDate = _formatDateTime(widget.startDate);
    final formattedEndDate = _formatDateTime(widget.endDate);
    final formattedStartTime = _formatTime(widget.startTime);
    final formattedEndTime = _formatTime(widget.endTime);

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).knowledge_hub,
        secondTitle: S.of(context)!.approvals,
        thirdTitle: _getLocalizedDocumentName(),
        onFirstTap: () => Navigator.of(context).pop(),
        onSecondTap: () => Navigator.of(context).pop(),
        child: BlocListener<ApprovalsCubit, ApprovalsStates>(
          listener: (context, state) {
            if (state is ApprovingKnowledgeSuccessState) {
              if (mounted) {
                setState(() {
                  currentStatus = 'published'; // ✅ Use 'published' to match _getStatusInfo
                });
              }
            }

            if (state is RejectingKnowledgeSuccessState) {
              if (mounted) {
                setState(() {
                  currentStatus = 'rejected';
                });

              }
            }

            if (state is ApprovingKnowledgeErrorState) {
              if (mounted) {

              }
            }

            if (state is RejectingKnowledgeErrorState) {
              if (mounted) {

              }
            }
          },
          child: isLoading
              ? Center(child: CircleProgressMaster())
              : SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isMobile)
                      Text(
                        '${_getLocalizedDocumentName()} ${S.of(context)!.details}',
                        style: StyleText.fontSize20Weight600.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    buildApprovalsActionButtons(
                      knowledgeId: widget.knowledgeId,
                      fileName: widget.fileName,
                      fileType: widget.fileType,
                      fileUrl: widget.fileUrl,
                      department: departmentName ?? widget.department,
                      fileExtension: widget.fileExtension,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.all(15.sp),
                      child: Column(
                        children: [
                          // ✅ File Icon and Document Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomSvgImage(
                                assetPath: getFileIcon(widget.fileExtension),
                                height: 70.h,
                                width: 70.w,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(width: 10.sp),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isMobile)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${S.of(context)!.requestedDate}: ',
                                            style: StyleText.fontSize10Weight400.copyWith(
                                              color: lightMode
                                                  ? AppColors.secondaryText
                                                  : AppColors.grey,
                                            ),
                                          ),
                                          Text(
                                            _formatDate(widget.createdTimestamp),
                                            style: StyleText.fontSize10Weight400.copyWith(
                                              color: lightMode
                                                  ? AppColors.blackButton
                                                  : AppColors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (!isMobile)
                                              Row(
                                                children: [
                                                  CustomSvgImage(
                                                    assetPath: 'assets/icons_assets/knowledge_hub_assets/limited_department_icon.svg',
                                                    fit: BoxFit.fill,
                                                    width: 16.w,
                                                    height: 16.h,
                                                  ),
                                                  SizedBox(width: 6.w),
                                                ],
                                              ),

                                            Text(
                                              isMobile
                                                  ? _getLocalizedDocumentName()
                                                  : S.of(context)!.description,
                                              style: StyleText.fontSize14Weight400.copyWith(
                                                color: lightMode
                                                    ? isMobile
                                                    ? AppColors.blackButton
                                                    : AppColors.secondaryText
                                                    : isMobile
                                                    ? AppColors.white
                                                    : AppColors.grey,
                                              ),
                                            ),
                                          ],
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 5.h),
                                    if (!isMobile)
                                      Text(
                                        _getLocalizedDescription(),
                                        style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                                          color: AppColors.text
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),













                          if (isMobile) SizedBox(height: 10.sp),
                          if (isMobile) ...[
                            Row(
                              children: [
                                CustomSvgImage(
                                  assetPath: 'assets/icons_assets/knowledge_hub_assets/limited_department_icon.svg',
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  S.of(context)!.description,
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: lightMode
                                        ? AppColors.secondaryText
                                        : AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional.topStart,
                              child: Text(
                                _getLocalizedDescription(),
                                style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                                  color: lightMode
                                      ? AppColors.blackButton
                                      : AppColors.white,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: isMobile ? 20.h : 25.h),

                          // ✅ Department and Document Type
                          buildUserDataInfo(
                            firstKey: "${S.of(context).owning_department}: ",
                            firstValue: _getLocalizedDepartmentName(departmentName ?? 'Unknown Department'),
                            secondKey: '${S.of(context).document_type}: ',
                            secondValue: _getLocalizedDocumentType(widget.fileType),
                            firstIcon: CustomSvgImage(
                                assetPath: 'assets/icons_assets/knowledge_hub_assets/departments_analytics_icon.svg',
                                height: 24.h,
                                width: 24.w,
                                fit: BoxFit.fill,
                                color: AppColors.secondaryText.withOpacity(.7)                        ),
                            secondIcon: CustomSvgImage(
                                assetPath: 'assets/icons_assets/knowledge_hub_assets/doctype.svg',
                                height: 24.h,
                                width: 24.w,
                                fit: BoxFit.fill,
                                color: AppColors.secondaryText.withOpacity(.7)                        ),
                            isMobile: isMobile,
                            lightMode: lightMode,
                          ),
                          SizedBox(height: isMobile ? 12.h : 15.h),

                          // ✅ Requested By and Job Title
                          buildUserDataInfo(
                            firstKey: '${S.of(context)!.requestedBy}: ',
                            firstValue: _getLocalizedEmployeeName(creatorData),
                            secondKey: '${S.of(context)!.jobTitle}: ',
                            secondValue: _getLocalizedJobTitle(creatorData),
                            firstIcon: CustomSvgImage(
                              assetPath: 'assets/icons_assets/main_icons_assets/details_User Plus.svg',
                              height: 24.h,
                              width: 24.w,
                              fit: BoxFit.cover,
                              color: AppColors.secondaryText.withOpacity(.7)
                            ),
                            secondIcon: CustomSvgImage(
                                assetPath: 'assets/icons_assets/main_icons_assets/svg_Case.svg',
                                height: 24.h,
                                width: 24.w,
                                fit: BoxFit.fill,
                                color: AppColors.secondaryText.withOpacity(.7)                        ),
                            isMobile: isMobile,
                            lightMode: lightMode,
                            userPhoto: creatorData?.currentemployeePhoto != null &&
                                creatorData!.currentemployeePhoto.isNotEmpty
                                ? CircleAvatar(
                              radius: 16.r,
                              backgroundImage: NetworkImage(
                                creatorData!.currentemployeePhoto,
                              ),
                              onBackgroundImageError: (_, __) {},
                              child: SizedBox(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CustomSvgImage(
                                      assetPath: 'assets/icons_assets/main_icons_assets/assets_male.svg',
                                      height: 32.r,
                                      width: 32.r,
                                      color: AppColors.secondaryText
                                  ),
                                ),
                              ),
                            )
                                : CircleAvatar(
                              radius: 16.r,
                              backgroundColor: AppColors.transparent,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: CustomSvgImage(
                                  assetPath: 'assets/icons_assets/main_icons_assets/assets_male.svg',
                                  height: 32.r,
                                  width: 32.r,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 12.h : 15.h),

                          // ✅ Email and Phone Number
                          buildUserDataInfo(
                            firstKey: '${S.of(context)!.email}: ',
                            firstValue: creatorData?.currentemployeeEmail ?? widget.createdByEmail,
                            secondKey: '${S.of(context)!.phoneNumber}: ',
                            secondValue: _formatPhoneNumber(creatorData?.currentemployeePhone),
                            firstIcon: CustomSvgImage(
                                assetPath: 'assets/icons_assets/main_icons_assets/images_email.svg',
                                height: 24.h,
                                width: 24.w,
                                fit: BoxFit.fill,
                                color: AppColors.secondaryText.withOpacity(.7)
                            ),
                            secondIcon: CustomSvgImage(
                                assetPath: 'assets/icons_assets/knowledge_hub_assets/phone_ser.svg',
                                height: 24.h,
                                width: 24.w,
                                fit: BoxFit.fill,
                                color: AppColors.secondaryText.withOpacity(.7)
                            ),
                            isMobile: isMobile,
                            lightMode: lightMode,
                          ),

                          // ✅ START DATE + TIME and END DATE + TIME
                          if (formattedStartDate != null || formattedEndDate != null) ...[
                            SizedBox(height: isMobile ? 12.h : 15.h),
                            buildUserDataInfo(
                              firstKey: '${S.of(context).start_date}: ',
                              firstValue: formattedStartTime != null && formattedStartTime.isNotEmpty
                                  ? '$formattedStartDate At $formattedStartTime'
                                  : formattedStartDate ?? '-',
                              secondKey: '${S.of(context).end_date}: ',
                              secondValue: formattedEndTime != null && formattedEndTime.isNotEmpty
                                  ? '$formattedEndDate At $formattedEndTime'
                                  : formattedEndDate ?? '-',
                              firstIcon: CustomSvgImage(
                                  assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                                  height: 24.h,
                                  width: 24.w,
                                  fit: BoxFit.fill,
                                  color: AppColors.secondaryText
                              ),
                              secondIcon: CustomSvgImage(
                                  assetPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                                  height: 24.h,
                                  width: 24.w,
                                  fit: BoxFit.fill,
                                  color: AppColors.secondaryText
                              ),
                              isMobile: isMobile,
                              lightMode: lightMode,
                            ),
                          ],

                          SizedBox(height: isMobile ? 12.h : 15.h),

                          // ✅ NEW: REMOVAL REASON SECTION (only show if status is removed)
                          if (currentStatus.toLowerCase() == 'removed') ...[
                            FutureBuilder<String?>(
                              future: _getRemovalReason(widget.knowledgeId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return SizedBox(
                                    height: 20.h,
                                    child: Center(
                                      child: SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final reason = snapshot.data;

                                if (reason == null || reason.isEmpty) {
                                  return SizedBox();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isMobile) ...[
                                      // Mobile Layout
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CustomSvgImage(
                                            assetPath: 'assets/icons_assets/main_icons_assets/assets_status.svg',
                                            fit: BoxFit.fill,
                                            width: 16.w,
                                            height: 16.h,
                                            color: AppColors.darkRed,
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${S.of(context)!.reasonOfRemoving}: ',
                                                  style: StyleText.fontSize14Weight400.copyWith(
                                                      color: AppColors.darkRed
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  reason,
                                                  style: StyleText.fontSize14Weight400.copyWith(
                                                    color: AppColors.text,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else ...[
                                      // Desktop Layout
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 16.h,
                                            width: 16.w,
                                            child: CustomSvgImage(
                                                assetPath: 'assets/icons_assets/main_icons_assets/assets_status.svg',
                                                fit: BoxFit.fill,
                                                color:AppColors.darkRed
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            '${S.of(context)!.reasonOfRemoving}: ',
                                            style: StyleText.fontSize14Weight400.copyWith(
                                              color: AppColors.darkRed,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              reason,
                                              style: StyleText.fontSize14Weight400.copyWith(
                                                color: AppColors.text,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    SizedBox(height: isMobile ? 12.h : 15.h),
                                  ],
                                );
                              },
                            ),
                          ],

                          SizedBox(height: 24.h),

                          // ✅ Action buttons or status badge
                          if (currentStatus.toLowerCase() == 'pending' ||
                              currentStatus.toLowerCase() == 'pending_approval' ||
                              currentStatus.toLowerCase() == 'scheduled')
                            _buildApprovalButtons(isMobile, lightMode)
                          else
                            _buildStatusBadge(isMobile, lightMode, statusInfo),
                        ],
                      ),
                    ),
                    if (!isMobile)
                      Positioned(
                        top: 8.h,
                        right: context.isArabic ? null :8.h,
                        left: context.isArabic ? 8.h: null,
                        child: Row(
                          children: [
                            Text(
                              '${S.of(context)!.requestedDate}: ',
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: lightMode
                                    ? AppColors.secondaryText
                                    : AppColors.grey,
                              ),
                            ),
                            Text(
                              _formatDate(widget.createdTimestamp),
                              style: StyleText.fontSize14Weight400.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                            ),
                          ],
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
  }
}
