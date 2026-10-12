part of './approvals_details_screen.dart';
/// Module: knowledge_hub / presentation / s7_approvals_details/approvals_details_screen.sections.dart

/// Fields + helper/builder methods for the screen, split out to keep
/// each file under 800 LOC (§7).
mixin _ApprovalsDetailsSections on State<ApprovalsDetailsScreen> {

  /// Removal reason — Firestore access + extraction owned by the service
  /// (CR-KH-S7-01 / S7-02).
  Future<String?> _getRemovalReason(String knowledgeId) {
    final isArabic = Get.locale?.languageCode == 'ar';
    return KnowledgeHubFirebaseServices()
        .getRemovalReasonFromStatus(knowledgeId, isArabic);
  }

  EmployeeData? creatorData;

  String? departmentName;

  bool isLoading = true;

  String currentStatus = '';

  /// ✅ Get file icon based on extension
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
      case 'jpg':
      case 'jpeg':
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
      case 'flv':
      case 'mkv':
      case 'webm':
        return 'assets/icons_assets/main_icons_assets/knowledgeVideo.svg';
      case 'xlsx':
      case 'xls':
      case 'xlsm':
      case 'csv':
        return 'assets/icons_assets/main_icons_assets/excell.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/svg_image_icon.svg';
    }
  }

  /// ✅ Fetch creator and department data
  Future<void> _fetchData() async {
    final cubit = context.read<ApprovalsCubit>();

    try {
      if (widget.createdByEmail.isNotEmpty) {
        creatorData = await cubit.getUserDataByEmail(widget.createdByEmail);
      }

      if (widget.department.isNotEmpty) {
        departmentName = await cubit.getDepartmentName(widget.department);
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// ✅ Format timestamp to readable date
  String _formatDate(int? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  /// Delegated to the shared formatter so the Firestore `Timestamp` handling
  /// stays out of the UI (CR-KH-S7 §3).
  String? _formatDateTime(dynamic timestamp) =>
      SubmissionDateFormatter.formatDateTime(timestamp);

  /// ✅ Format Time from various formats (String, Map, List)
  String? _formatTime(dynamic timeData) {
    if (timeData == null) return null;

    try {
      // Handle List - take first element
      if (timeData is List) {
        if (timeData.isEmpty) return null;
        timeData = timeData.first;
      }

      // If it's already a formatted string like "14:30" or "2:30 PM"
      if (timeData is String) {
        // Check if it's already in 12-hour format with AM/PM
        if (timeData.contains('AM') || timeData.contains('PM')) {
          return timeData;
        }

        // If it's in 24-hour format "HH:mm", convert to 12-hour
        if (timeData.contains(':')) {
          try {
            final parts = timeData.split(':');
            if (parts.length == 2) {
              int hour = int.parse(parts[0]);
              int minute = int.parse(parts[1]);

              // Convert to 12-hour format
              String period = hour >= 12 ? 'PM' : 'AM';
              int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

              return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
            }
          } catch (e) {
            return timeData;
          }
        }

        return timeData;
      }

      // If it's a map with hour and minute (from TimeOfDay serialization)
      if (timeData is Map) {
        int hour = timeData['hour'] ?? 0;
        int minute = timeData['minute'] ?? 0;

        // Format as 12-hour time with AM/PM
        String period = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// ✅ Get localized employee name (Arabic/English)
  String _getLocalizedEmployeeName(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = Get.find<MainCoreEmployeeController>();
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale != 'ar';

    String name = employeeController.getEmployeeNameEnglishArabic(
      employee.currentemployeeEmail,
      isEnglish,
    );

    return name.isNotEmpty ? FormatHelper.capitalize(name) : FormatHelper.capitalize(employee.currentemployeeName);
  }

  /// ✅ Get localized department name (Arabic/English)
  String _getLocalizedDepartmentName(String departmentName) {
    final departmentController = Get.find<MainCoreDepartmentCubit>();

    String? departmentId = departmentController.getDepartmentIdFromDepartmentName(
      departmentName: departmentName.toLowerCase(),
    );

    if (departmentId != null && departmentId != 'none') {
      String localizedName = departmentController.getDepartmentName(departmentId, null);
      return localizedName;
    }

    return departmentName;
  }

  /// ✅ Get localized job title (Arabic/English)
  String _getLocalizedJobTitle(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = Get.find<MainCoreEmployeeController>();
    String jobTitle = employeeController.getEmployeeJobTitle(employee.currentemployeeEmail);

    return jobTitle == "no job" ? employee.currentemployeeRole : jobTitle;
  }

  /// ✅ Get localized document name (Arabic/English)
  String _getLocalizedDocumentName() {
    return FormatHelper.capitalize(widget.documentName);
  }

  /// ✅ Get localized description (Arabic/English)
  String _getLocalizedDescription() {
    return FormatHelper.capitalize(widget.documentDesc);
  }

  /// ✅ Format phone number with country code (+966 for Saudi Arabia)
  String _formatPhoneNumber(dynamic phone) {

    if (phone == null) return 'N/A';

    String phoneStr = '';

    if (phone is List) {
      if (phone.isEmpty) return 'N/A';
      phoneStr = phone.first.toString();
    } else if (phone is String) {
      if (phone.isEmpty) return 'N/A';
      phoneStr = phone;
    } else {
      phoneStr = phone.toString();
    }

    phoneStr = phoneStr.replaceAll('[', '').replaceAll(']', '').trim();

    if (phoneStr.isEmpty) return 'N/A';

    if (phoneStr.startsWith('+')) {
      return phoneStr;
    }

    if (phoneStr.startsWith('05') || phoneStr.startsWith('5')) {
      String cleanNumber = phoneStr.startsWith('0') ? phoneStr.substring(1) : phoneStr;
      return '+966 $cleanNumber';
    }

    return phoneStr;
  }

  /// ✅ Get status info with proper SVG icons and colors
  Map<String, dynamic> _getStatusInfo(String status) {

    String statusLower = status.toLowerCase().trim();

    switch (statusLower) {
      case 'rejected':
        return {
          'text': S.of(context)!.rejected,
          'color': AppColors.red,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/assets_reject.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'pending_approval':
      case 'pending':
        return {
          'text': S.of(context)!.pending,
          'color': AppColors.orange,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/state_pending.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'scheduled':
        return {
          'text': S.of(context)!.pending,
          'color': AppColors.orange,
          'widget': CustomSvgImage(
            assetPath: 'assets/svg/pending.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'published':
        return {
          'text': S.of(context)!.published,
          'color': AppColors.lightGreen,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/knowledge_hub_assets/published_status_icon.svg',
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
            assetPath: 'assets/icons_assets/knowledge_hub_assets/images_approve.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      case 'removed':
        return {
          'text': S.of(context)!.removed,
          'color': KnowledgeHubColors.redCrimson,
          'widget': CustomSvgImage(
            assetPath: 'assets/icons_assets/main_icons_assets/removed.svg',
            height: 24.sp,
            width: 24.sp,
            fit: BoxFit.cover,
          ),
        };

      default:
        return {
          'text': status,
          'color': AppColors.primary,
          'widget': Icon(Icons.info, color: AppColors.primary, size: 24.sp),
        };
    }
  }

  /// ✅ Get localized document type (Arabic/English)
  String _getLocalizedDocumentType(String fileType) {
    String typeLower = fileType.toLowerCase().trim();

    switch (typeLower) {
      case 'presentation':
        return S.of(context)!.presentation;
      case 'form':
        return S.of(context)!.form;
      case 'report':
        return S.of(context)!.report;
      case 'booklet':
        return S.of(context)!.booklet;
      case 'video recording':
        return S.of(context)!.video_recording;
      case 'letter':
        return S.of(context)!.letter;
      case 'mandate':
        return S.of(context)!.mandate;
      case 'policy':
        return S.of(context)!.policy;
      case 'frame work':
        return S.of(context)!.frame_work;
      case 'workshop':
        return S.of(context)!.workshop;
      case 'guidelines':
        return S.of(context)!.guidelines;
      case 'other':
        return S.of(context)!.other;
      default:
        return FormatHelper.capitalize(fileType);
    }
  }

  /// ✅ Build approval/reject action buttons
  ///
  /// GATED 2/9/2026 on [KnowledgeHubAccess.approvalAccess]. Both buttons used
  /// to render for anyone who could open this screen, so the
  /// `Approved And Rejected` / `Approved Only` switches in the role editor
  /// controlled nothing at all.
  ///
  /// They are TIERS, not two flags — see [ApprovalAccess]. Reject is only ever
  /// offered alongside Approve, never on its own.
  Widget _buildApprovalButtons(bool isMobile, bool lightMode) {
    final ApprovalAccess access = KnowledgeHubAccess.approvalAccess;

    // Nothing to act with — draw no row rather than an empty one, so the
    // spacing above and below collapses too.
    if (!access.canApprove) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        // Approve stands alone on the approve-only tier, so it takes the full
        // width rather than leaving a gap where Reject used to be.
        final buttonWidth =
            access.canReject ? (availableWidth - 10.w) / 2 : availableWidth;

        return Row(
          mainAxisAlignment: isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
          children: [
            if (access.canReject) ...[
            customButtonWithSvg(
              title: S.of(context)!.reject,
              function: () => _showRejectDialog(isMobile, lightMode),
              textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.red),
              height: 36,
              space: 8.w,
              radius: 8.r,
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              image: 'assets/icons_assets/knowledge_hub_assets/assets_reject.svg',
              widthImage: 24.w,
              heightImage: 24.h,
              colorBorder: AppColors.red,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              width: isMobile ? buttonWidth : 150.w,
            ),
            SizedBox(width: 10.w),
            ],
            customButtonWithSvg(
              title: S.of(context)!.approve,
              function: () => _showApproveDialog(isMobile, lightMode),
              textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.lightGreen),
              height: 36,
              space: 8.w,
              radius: 8.r,
              color: lightMode ? AppColors.white : AppColors.chatBackground,
              image: 'assets/icons_assets/knowledge_hub_assets/images_approve.svg',
              widthImage: 24.w,
              heightImage: 24.h,
              colorBorder: AppColors.lightGreen,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              width: isMobile ? buttonWidth : 150.w,
            ),
          ],
        );
      },
    );
  }

  /// ✅ Build status badge
  Widget _buildStatusBadge(bool isMobile, bool lightMode, Map<String, dynamic> statusInfo) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: 36,
          width: isMobile ? ScreenUtil().screenWidth - 80.w : 200.w,
          decoration: BoxDecoration(
            color: lightMode ? AppColors.white : AppColors.chatBackground,
            border: Border.all(color: statusInfo['color'], width: 2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              statusInfo['widget'],
              SizedBox(width: 8.w),
              Text(
                statusInfo['text'],
                style: StyleText.fontSize16Weight500.copyWith(color: statusInfo['color']),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ✅ Show approve dialog
  void _showApproveDialog(bool isMobile, bool lightMode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: lightMode ? AppColors.white : AppColors.chatBackground,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                  height: 70.h,
                  width: 70.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context)!.approveRequest,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context)!.areYouSureYouWantToApproveRequest,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton(
                      title: S.of(context).no,
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.colorBlack),
                      color: AppColors.grey,
                      function: () => Navigator.of(ctx).pop(),
                    ),
                    SizedBox(width: 23.w),
                    customButton(
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      title: S.of(context).yes,
                      function: () {
                        Navigator.pop(ctx);
                        showDialog(
                          barrierDismissible: true,
                          builder: (dialogContext) => BlocProvider.value(
                            value: context.read<ApprovalsCubit>(),
                            child: ReasonForJustificationsDialog(
                              knowledgeId: widget.knowledgeId,
                            ),
                          ), context: ctx,
                        );
                      },
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

  /// ✅ Show reject dialog
  void _showRejectDialog(bool isMobile, bool lightMode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.chatBackground,
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
                  S.of(context)!.rejectRequest,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context)!.areYouSureYouWantToRejectRequest,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customButton(
                      title: S.of(context).no,
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.colorBlack),
                      color: AppColors.grey,
                      function: () => Navigator.of(ctx).pop(),
                    ),
                    SizedBox(width: 23.w),
                    customButton(
                      height: 38.h,
                      width: 135.w,
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      title: S.of(context).yes,
                      function: () {
                        Navigator.pop(ctx);
                        showDialog(
                          barrierDismissible: true,
                          builder: (dialogContext) => BlocProvider.value(
                            value: context.read<ApprovalsCubit>(),
                            child: ResonForApprovalRemovingDialog(
                              knowledgeId: widget.knowledgeId,
                            ),
                          ), context: ctx,
                        );
                      },
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

  /// ✅ Build user data info row
  Widget buildUserDataInfo({
    required String firstKey,
    required String firstValue,
    required String secondKey,
    required String secondValue,
    required Widget firstIcon,
    required Widget secondIcon,
    required bool isMobile,
    required bool lightMode,
    Widget? userPhoto,
  }) {
    return isMobile
        ? Column(
      children: [
        Row(
          children: [
            firstIcon,
            SizedBox(width: 4.w),
            Text(
              firstKey,
              style: StyleText.fontSize14Weight400.copyWith(
               color: AppColors.secondaryText.withOpacity(.7)
              ),
            ),
            if (userPhoto != null) ...[userPhoto, SizedBox(width: 4.w)],
            Expanded(
              child: Text(
                firstValue,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            secondIcon,
            SizedBox(width: 4.w),
            Text(
              secondKey,
              style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText.withOpacity(.7)
              ),
            ),
            Expanded(
              child: Text(
                secondValue,
                style: StyleText.fontSize14Weight400.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    )
        : Row(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              SizedBox(height: 16.h, width: 16.w, child: firstIcon),
              SizedBox(width: 3.w),
              Text(
                firstKey,
                style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.secondaryText.withOpacity(.7)
                ),
              ),
              if (userPhoto != null) ...[userPhoto, SizedBox(width: 4.w)],
              Expanded(
                child: Text(
                  firstValue,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              SizedBox(height: 16.h, width: 16.w, child: secondIcon),
              SizedBox(width: 3.w),
              Text(
                secondKey,
                style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.secondaryText.withOpacity(.7)                ),
              ),
              Expanded(
                child: Text(
                  FormatHelper.capitalize(secondValue),
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
