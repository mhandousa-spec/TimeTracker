part of './build_published_content.dart';
/// Module: knowledge_hub / presentation / s5_submission_details/widgets/submission_details_contents/build_published_content.info_card.dart

/// Document info card, info rows, status button + error dialog (split from build_published_content.dart, §7).

Widget _buildDocumentInfoCard(
    BuildContext context, {
      required String publishDate,
      required String documentName,
      required String documentNameAr,
      required String documentType,
      required String owningDepartment,
      required String documentDescription,
      required String documentExtension,
      required bool isMobile,
      required String currentStatus,
      required bool lightMode,
      required String knowledgeId,
      List<String>? limitedDepartments,
      required List<String>? statusHistory,
      String? startDate,
      String? endDate,
      String? startTime,
      String? endTime,
      required String createdBy,
    }) {

  debugPrint('═══════════════════════════════════════');
  debugPrint('📊 [INFO_CARD] _buildDocumentInfoCard RECEIVED:');
  debugPrint('   startDate: "$startDate" (isEmpty: ${startDate?.isEmpty ?? true})');
  debugPrint('   endDate: "$endDate" (isEmpty: ${endDate?.isEmpty ?? true})');
  debugPrint('   startTime: "$startTime" (isEmpty: ${startTime?.isEmpty ?? true})');
  debugPrint('   endTime: "$endTime" (isEmpty: ${endTime?.isEmpty ?? true})');
  debugPrint('═══════════════════════════════════════\n');

  final departmentController = Get.find<MainCoreDepartmentCubit>();
  final controller = Get.find<MainCoreEmployeeController>();
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  // ✅ NEW: Get removal reason from Firestore
  String? removalReason;
  if (currentStatus == 'removed') {
    // Fetch the document data to get the removal reason
    // The reason is stored in descriptionEnglish/descriptionArabic when status is 'removed'
    _getRemovalReason(knowledgeId).then((reason) {
      if (reason != null) {
        removalReason = reason;
      }
    });
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'rejected':
        return {
          'text': S.of(context)!.rejected,
          'color': AppColors.red,
          'widget': SizedBox(
            child: Container(
              width: 15.w,
              height: 15.h,
              child: SizedBox(
                child: CustomSvgImage(
                  assetPath: 'assets/icons_assets/knowledge_hub_assets/rejected_status_icon.svg',
                  height: 20.h,
                  width: 20.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        };
      case 'pending_approval':
      case 'scheduled':
        return {
          'text': S.of(context)!.pending,
          'color': AppColors.orange,
          'widget': Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: CustomSvgImage(
              assetPath: 'assets/icons_assets/main_icons_assets/state_pending.svg',
              height: 20.h,
              width: 20.w,
              fit: BoxFit.cover,
            ),
          )
        };
      case 'published':
        return {
          'text': S.of(context)!.published,
          'color': AppColors.green,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/published_status_icon.svg',
            height: 20.sp,
            width: 20.sp,
            fit: BoxFit.cover,
          ),
        };
      case 'approved':
        return {
          'text': S.of(context)!.approved,
          'color': AppColors.lightGreen,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/approve_icon.svg',
            height: 20.sp,
            width: 20.sp,
            fit: BoxFit.cover,
          ),
        };
      case 'archived':
        return {
          'text': S.of(context)!.archive,
          'color': KnowledgeHubColors.neutralGrey,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/arcive_new_icon.svg',
            height: 20.sp,
            width: 20.sp,
            fit: BoxFit.cover,
          ),
        };
      case 'removed':
        return {
          'text': S.of(context)!.removed,
          'color': AppColors.darkRed,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/remove_icon.svg',
            height: 20.sp,
            width: 20.sp,
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
  final isPending = currentStatus == 'pending_approval' || currentStatus == 'scheduled';

  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: lightMode ? AppColors.white : AppColors.chatBackground,
        ),
        padding: EdgeInsets.all(15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

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
              Text(
                documentDescription,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: lightMode ? AppColors.secondaryText : AppColors.white,
                ),
              ),
              SizedBox(height: 15.h),
              _buildInfoRow(
                context,
                iconPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
                label: '${S.of(context).document_type}: ',
                value: documentType,
                lightMode: lightMode,
              ),
              SizedBox(height: 15.h),
              _buildInfoRow(
                context,
                iconPath: 'assets/icons_assets/knowledge_hub_assets/owning_department_icon.svg',
                label: "${S.of(context).owning_department}: ",
                value: owningDepartment,
                lightMode: lightMode,
              ),

              if (startDate != null && startDate.isNotEmpty) ...[
                SizedBox(height: 15.h),
                _buildInfoRow(
                  context,
                  iconPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                  label: '${S.of(context).start_date}: ',
                  value: DateTimeLocalizationHelper.formatDateTime(
                    date: startDate,
                    time: startTime,
                    isArabic: isArabic,
                  ),
                  lightMode: lightMode,
                ),
              ],

              if (endDate != null && endDate.isNotEmpty) ...[
                SizedBox(height: 15.h),
                _buildInfoRow(
                  context,
                  iconPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                  label: '${S.of(context).end_date}: ',
                  value: DateTimeLocalizationHelper.formatDateTime(
                    date: endDate,
                    time: endTime,
                    isArabic: isArabic,
                  ),
                  lightMode: lightMode,
                ),
              ],
            ] else ...[
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        iconPath: 'assets/icons_assets/knowledge_hub_assets/document_type_icon.svg',
                        label: '${S.of(context).document_type}: ',
                        value: documentType,
                        lightMode: lightMode,
                      ),


                      SizedBox(height: 15.h),
                      _buildInfoRow(
                        context,
                        iconPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                        label: '${S.of(context).start_date}: ',
                        value: startDate == null  ? "-" : DateTimeLocalizationHelper.formatDateTime(
                          date: startDate,
                          time: startTime,
                          isArabic: isArabic,
                        ),
                        lightMode: lightMode,
                      ),
                    ],
                  ),
                  SizedBox(width: 50.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        iconPath: 'assets/icons_assets/knowledge_hub_assets/owning_department_icon.svg',
                        label: "${S.of(context).owning_department}: ",
                        value: owningDepartment,
                        lightMode: lightMode,
                      ),
                      SizedBox(height: 15.h),
                      _buildInfoRow(
                        context,
                        iconPath: 'assets/icons_assets/main_icons_assets/images_Calendar.svg',
                        label: '${S.of(context).end_date}: ',
                        value:endDate == null ? "-" : DateTimeLocalizationHelper.formatDateTime(
                          date: endDate!,
                          time: endTime,
                          isArabic: isArabic,
                        ),
                        lightMode: lightMode,
                      ),

                    ],
                  ),
                ],
              ),
            ],
            SizedBox(height: 15.h),

            // ✅ LIMITED DEPARTMENTS SECTION
            if (limitedDepartments != null && limitedDepartments.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomSvgImage(
                        assetPath: 'assets/icons_assets/knowledge_hub_assets/limited_department_icon.svg',
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '${S.of(context)!.limitedDepartmentAvailability}:',
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode ? AppColors.secondaryText : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: (limitedDepartments.isEmpty)
                        ? [
                      Text(
                        '-',
                        style: StyleText.fontSize14Weight400.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                    ]
                        : limitedDepartments.map((department) {
                      String localizedDepartmentName = department;
                      try {
                        String? departmentId =
                        departmentController.getDepartmentIdFromDepartmentName(
                          departmentName: department.toLowerCase(),
                        );

                        if (departmentId != null) {
                          final isArabic =
                              Localizations.localeOf(context).languageCode == 'ar';
                          if (isArabic) {
                            localizedDepartmentName = departmentController
                                .getArabicDepartmentNameFromDepartmentId(
                              departmentId: departmentId,
                            ) ??
                                department;
                          } else {
                            localizedDepartmentName = departmentController
                                .getEnglishDepartmentNameFromDepartmentId(
                              departmentId: departmentId,
                            ) ??
                                department;
                          }
                        }
                      } catch (e) {
                        debugPrint('Error localizing department: $e');
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          localizedDepartmentName,
                          style: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode
                                ? AppColors.blackButton
                                : AppColors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 15.h),
                ],
              ),

            // ✅ NEW: APPROVAL JUSTIFICATION SECTION
            if (currentStatus == 'approved' || currentStatus == 'published')
              FutureBuilder<String?>(
                future: _getApprovalReason(knowledgeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 20.h,
                      child: Center(
                        child: SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircleProgressMaster()
                        ),
                      ),
                    );
                  }

                  final reason = snapshot.data;

                  // Don't show anything if there's no approval reason
                  if (reason == null || reason.isEmpty) {
                    return SizedBox();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomSvgImage(
                            assetPath: 'assets/icons_assets/main_icons_assets/assets_status.svg',
                            fit: BoxFit.cover,
                            width: 16.w,
                            height: 16.h,
                            color: AppColors.green,
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${S.of(context)!.approvalJustification}: ',
                                  style: StyleText.fontSize14Weight500.copyWith(
                                    color: AppColors.green,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: StyleText.fontSize12Weight400.copyWith(
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                    ],
                  );
                },
              ),


            // ✅ NEW: REMOVAL REASON SECTION (appears after limited departments)
            if (currentStatus == 'removed')
              FutureBuilder<String?>(
                future: _getRemovalReason(knowledgeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 20.h,
                      child: Center(
                        child: SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircleProgressMaster()
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomSvgImage(
                            assetPath: 'assets/icons_assets/main_icons_assets/assets_status.svg',
                            fit: BoxFit.cover,
                            width: 16.w,
                            height: 16.h,
                            color: AppColors.darkRed,
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '${S.of(context)!.reasonOfRemoving}: ',
                                  style: StyleText.fontSize14Weight500.copyWith(
                                      color: AppColors.darkRed
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  reason,
                                  style: StyleText.fontSize12Weight400.copyWith(
                                      color: AppColors.text
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                    ],
                  );
                },
              ),

            // ✅ REJECTION REASON (keep existing)
            if (currentStatus == 'rejected') ...[
              Row(
                children: [
                  CustomSvgImage(
                    assetPath: 'assets/icons_assets/main_icons_assets/assets_status.svg',
                    fit: BoxFit.fill,
                    color: AppColors.red,

                  ),
                  SizedBox(width: 5.w),
                  Text(
                    '${S.of(context)!.reasonOfRejection}: ',
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.red,
                    ),
                  ),
                  Text(
                    S.of(context)!.reasonOfRejection,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: lightMode ? AppColors.blackButton : AppColors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
            ],

            // STATUS BUTTON AND SEND REMINDER
            Row(
              mainAxisAlignment: isMobile
                  ? MainAxisAlignment.center
                  : (isPending ? MainAxisAlignment.start : MainAxisAlignment.end),
              children: [
                if (isPending) ...[
                  GestureDetector(
                    onTap: () async {
                      // ... existing send reminder code ...
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
                          Center(
                            child: CustomSvgImage(
                              assetPath: 'assets/icons_assets/knowledge_hub_assets/send_reminder_icon.svg',
                              fit: BoxFit.cover,
                              width: 20.w,
                              height: 20.h,
                              color: AppColors.textButton,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            S.of(context)!.sendReminder,
                            style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                              color: AppColors.textButton,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  _buildStatusButton(
                    statusInfo: statusInfo,
                    width: isMobile ? 140.w : 185.w,
                    lightMode: lightMode,
                  ),
                ] else ...[
                  _buildStatusButton(
                    statusInfo: statusInfo,
                    width: isMobile ? ScreenUtil().screenWidth - 80.w : 200.w,
                    lightMode: lightMode,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      Positioned(
          right: isArabic ? null : 8.w,
          left: isArabic ? 8.w: null ,
          top: 8.h,
          child: buildSubmissionDate(context, submissionDate: publishDate)),
    ],
  );
}




Widget _buildInfoRow(
    BuildContext context, {
      required String iconPath,
      required String label,
      required String value,
      required bool lightMode,
    }) {
  return Row(
    children: [
      CustomSvgImage(
        width: 16.w,
        height: 16.h,
        assetPath: iconPath,
        fit: BoxFit.fill,
      ),
      SizedBox(width: 5.w),
      Text(
        label,
        style: StyleText.fontSize14Weight400.copyWith(
          color: lightMode ? AppColors.secondaryText : AppColors.grey,
        ),
      ),
      Text(
        value,
        style: StyleText.fontSize14Weight400.copyWith(
          color: lightMode ? AppColors.blackButton : AppColors.white,
        ),
      ),
    ],
  );
}

Widget _buildStatusButton({
  required Map<String, dynamic> statusInfo,
  required double width,
  required bool lightMode,
}) {
  return Container(
    height: 36.sp,
    width: width,
    decoration: BoxDecoration(
      color: lightMode ? AppColors.white : AppColors.chatBackground,
      border: Border.all(color: statusInfo['color'], width: 2),
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            color: statusInfo['color'],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: statusInfo['widget'],
          ),
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
  );
}

void _showErrorDialog(BuildContext context, String message) {
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
              color: lightMode ? AppColors.white : AppColors.chatBackground,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.red,
                  size: 48.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  message,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                customButton(
                  title: S.of(context).ok ?? 'OK',
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
