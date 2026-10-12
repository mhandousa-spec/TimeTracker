/// Module: knowledge_hub / presentation / s5_submission_details / widgets/submission_details_contents/build_published_content.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_published_content.dart
/// Purpose: Build published content — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'dart:io';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/submissions_permissions_enum.dart';
import 'package:lottie/lottie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:ui' as ui;



import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../../../../core/extensions/context_extensions.dart';
import '../../../../../main_controller/data/services/knowledge_hub_firebase_services.dart';
import '../../../../../main_controller/domain/constants/knowledge_hub_colors.dart';
import '../../../../../main_controller/helper/knowledge_hub_file_operations.dart';
import '../../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../../k4_submissions/presentation/controller/submissions_cubit.dart';
import '../../../../../k4_submissions/presentation/controller/submissions_states.dart';
import '../../../../../k1_create_new_knowledge/presentation/ui/pages/creating_knowledge_hub.dart';
import '../../../../../main_controller/presentation/ui/widgets/customed_text_field.dart';
import '../analytics_section/build_analytics_section.dart';
import '../build_submission_date.dart';
import '../comments_section/comments_list_view_on_submitted_file.dart';
import '../submitted_document_header.dart';
import 'package:flutter/services.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
// ADDED 2/9/2026 — the Download and Edit permission checks in the .viewers
// part file below.
import '../../../../../main_controller/helper/knowledge_hub_permissions.dart';

part './build_published_content.viewers.dart';
part './build_published_content.info_card.dart';
part './build_published_content.dialog.dart';


// ✅ CREATE: Animated Action Button Wrapper
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
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
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

    await Future.delayed(const Duration(milliseconds: 100));
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

class DateTimeLocalizationHelper {
  /// Convert Western Arabic numerals (0-9) to Eastern Arabic numerals (٠-٩)
  static String toArabicNumerals(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], arabic[i]);
    }
    return result;
  }

  /// Convert AM/PM to Arabic
  /// AM → ص (صباحاً - morning)
  /// PM → م (مساءً - evening)
  static String localizeAmPm(String input, bool isArabic) {
    if (!isArabic) return input;

    String result = input;

    // Convert AM to ص (صباحاً - morning)
    result = result.replaceAll('AM', 'ص');
    result = result.replaceAll('am', 'ص');
    result = result.replaceAll('A.M.', 'ص');
    result = result.replaceAll('a.m.', 'ص');

    // Convert PM to م (مساءً - evening)
    result = result.replaceAll('PM', 'م');
    result = result.replaceAll('pm', 'م');
    result = result.replaceAll('P.M.', 'م');
    result = result.replaceAll('p.m.', 'م');

    return result;
  }

  /// Format date and time with proper localization
  /// For Arabic: converts numerals, AM/PM, and uses "في" (at)
  /// For English: uses "at"
  ///
  /// Examples:
  /// - English: "2024-01-19 at 08:14 PM"
  /// - Arabic: "٢٠٢٤-٠١-١٩ في ٠٨:١٤ م"
  static String formatDateTime({
    required String date,
    String? time,
    required bool isArabic,
  }) {
    if (isArabic) {
      // Convert date to Arabic numerals
      String arabicDate = toArabicNumerals(date);

      if (time != null && time.isNotEmpty) {
        // Convert time to Arabic numerals
        String arabicTime = toArabicNumerals(time);
        // Convert AM/PM to Arabic
        arabicTime = localizeAmPm(arabicTime, true);
        return '$arabicDate في $arabicTime';
      }
      return arabicDate;
    } else {
      // English format
      if (time != null && time.isNotEmpty) {
        return '$date at $time';
      }
      return date;
    }
  }
}



Widget buildPublishedContent(
    BuildContext context, {
      required bool isMobile,
      required bool lightMode,
      required String documentName,
      required String documentNameAr,
      required String documentType,
      required String owningDepartment,
      required String documentDescription,
      required String documentDescriptionAr,
      required String publishDate,
      required String fileType,
      required String fileUrl,
      required String knowledgeId,
      required String documentExtension,
      required String currentStatus,
      required List<String>? limitedDepartments,
      required TextEditingController searchStatisticsController,
      required List<String>? statusHistory,
      String? startDate,
      String? endDate,
      String? startTime,
      String? endTime,
      required String createdBy,
    }) {

  // ✅ DEBUG: Log what buildPublishedContent receives
  debugPrint('═══════════════════════════════════════');
  debugPrint('📊 [BUILD_PUBLISHED] buildPublishedContent RECEIVED:');
  debugPrint('   startDate: "$startDate" (isEmpty: ${startDate?.isEmpty ?? true})');
  debugPrint('   endDate: "$endDate" (isEmpty: ${endDate?.isEmpty ?? true})');
  debugPrint('   startTime: "$startTime" (isEmpty: ${startTime?.isEmpty ?? true})');
  debugPrint('   endTime: "$endTime" (isEmpty: ${endTime?.isEmpty ?? true})');
  debugPrint('═══════════════════════════════════════\n');

  final controller = Get.find<MainCoreEmployeeController>();
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  debugPrint('═══════════════════════════════════════');
  debugPrint('📊 ANALYTICS VISIBILITY CHECK');
  debugPrint('═══════════════════════════════════════');
  debugPrint('📌 Knowledge ID: $knowledgeId');
  debugPrint('📌 Current Status: $currentStatus');
  debugPrint('📌 Status History: $statusHistory');
  debugPrint('📌 Status History Type: ${statusHistory.runtimeType}');
  debugPrint('📌 Status History Length: ${statusHistory?.length ?? 0}');
  debugPrint('📌 Is Mobile: $isMobile');

  final bool hasBeenPublished = statusHistory?.any((status) {
    final isPublished = status.toLowerCase() == 'published';
    debugPrint('   - Checking status: "$status" → isPublished: $isPublished');
    return isPublished;
  }) ??
      false;

  debugPrint('✅ Final Decision - Has Been Published: $hasBeenPublished');
  debugPrint('✅ Will Show Analytics: $hasBeenPublished');
  debugPrint('═══════════════════════════════════════\n');

  final localizedDocumentType = DocumentTypeHelper.getLocalizedType(
    documentType,
    isArabic,
  );

  final departmentController = Get.find<MainCoreDepartmentCubit>();
  String localizedDepartment = owningDepartment;
  try {
    String? departmentId = departmentController.getDepartmentIdFromDepartmentName(
      departmentName: owningDepartment.toLowerCase(),
    );

    if (departmentId != null) {
      if (isArabic) {
        localizedDepartment = departmentController.getArabicDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        ) ??
            owningDepartment;
      } else {
        localizedDepartment = departmentController.getEnglishDepartmentNameFromDepartmentId(
          departmentId: departmentId,
        ) ??
            owningDepartment;
      }
    }
  } catch (e) {
    debugPrint('Error getting department name: $e');
    debugPrint('Department name: $owningDepartment');
  }

  // ✅ NEW: Build the UniversalCommentSection widget to reuse in both layouts
  Widget buildCommentsSection({double? fixedHeight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        UniversalCommentSection(
          collectionPath: '${getBaseUrl('Comments')}',
          filterFields: {
            'Request_Id': knowledgeId,
          },
          currentUserId: controller.employeeEntity?.email ?? '',
          isExpandable: true,
          fixedHeight: fixedHeight ?? MediaQuery.of(context).size.height,
          style: CommentSectionStyle(
            hintStyle: StyleText.fontSize16Weight400.copyWith(
                color: AppColors.secondaryText.withOpacity(.5)),
            commentTextStyle: StyleText.fontSize18Weight500
                .copyWith(color: AppColors.text),
            fileChipDecoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
            ),
            fileIconColor: AppColors.text,
            fileNameStyle: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.text),
            avatarColor: AppColors.background,
            inputFillColor: AppColors.card,
            containerDecoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            commentItemDecoration: BoxDecoration(
                color: AppColors.transparent,
                borderRadius: BorderRadius.circular(8.r)),
            userNameStyle: StyleText.fontSize16Weight400.copyWith(
              color: AppColors.text,
            ),
            sendButtonDecoration: BoxDecoration(
              color: AppColors.secondaryPrimary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            sendIconColor: AppColors.secondaryPrimaryText,
          ),
        ),
      ],
    );
  }

  return isMobile
      ? SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildActionButtonsSection(
              context,
              currentStatus: currentStatus,
              knowledgeId: knowledgeId,
              fileUrl: fileUrl,
              documentFileName: isArabic ? documentNameAr : documentName,
              documentExtension: documentExtension,
              isMobile: isMobile,
              lightMode: lightMode,
              createdBy: createdBy,
            ),
            SizedBox(height: 15.h),
            _buildDocumentInfoCard(
              context,
              publishDate: publishDate,
              documentName: isArabic ? documentNameAr : documentName,
              documentNameAr: documentNameAr,
              documentType: localizedDocumentType,
              owningDepartment: localizedDepartment,
              documentDescription: isArabic ? documentDescriptionAr : documentDescription,
              documentExtension: documentExtension,
              isMobile: isMobile,
              currentStatus: currentStatus,
              statusHistory: statusHistory,
              limitedDepartments: limitedDepartments,
              lightMode: lightMode,
              knowledgeId: knowledgeId,
              startDate: startDate,
              endDate: endDate,
              startTime: startTime,
              endTime: endTime,
              createdBy: createdBy,
            ),
            SizedBox(height: 20.h),
          ],
        ),
        if (hasBeenPublished) ...[
          SizedBox(height: 20.h),
          Container(
            child: buildAnalyticsSection(
              context,
              lightMode: lightMode,
              knowledgeId: knowledgeId,
              searchStatisticsController: searchStatisticsController,
            ),
          ),
        ] else ...[
          // ✅ REPLACED: Old inline BlocBuilder comments with UniversalCommentSection
          buildCommentsSection(),
        ],
      ],
    ),
  )
      : SingleChildScrollView(
    physics: ClampingScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _buildActionButtonsSection(
              context,
              currentStatus: currentStatus,
              knowledgeId: knowledgeId,
              fileUrl: fileUrl,
              documentFileName: isArabic ? documentNameAr : documentName,
              documentExtension: documentExtension,
              isMobile: isMobile,
              lightMode: lightMode,
              createdBy: createdBy,
            ),
            SizedBox(height: 15.h),
            _buildDocumentInfoCard(
              context,
              publishDate: publishDate,
              documentName: isArabic ? documentNameAr : documentName,
              documentNameAr: documentNameAr,
              documentType: localizedDocumentType,
              owningDepartment: localizedDepartment,
              documentDescription: isArabic ? documentDescriptionAr : documentDescription,
              documentExtension: documentExtension,
              isMobile: isMobile,
              currentStatus: currentStatus,
              statusHistory: statusHistory,
              limitedDepartments: limitedDepartments,
              lightMode: lightMode,
              knowledgeId: knowledgeId,
              startDate: startDate,
              endDate: endDate,
              startTime: startTime,
              endTime: endTime,
              createdBy: createdBy,
            ),
            SizedBox(height: 20.h),
          ],
        ),
        if (hasBeenPublished) ...[
          SizedBox(height: 10.h),
          // CHANGED 28/9/2026 (Knowledge Hub p.22): a MAX height, not a fixed
          // one. Analytics and Statistics still fill 960.h exactly as before;
          // the Comments tab is allowed to be shorter, so the page no longer
          // ends in a band of empty space under the comment box.
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 960.h),
            child: buildAnalyticsSection(
              context,
              lightMode: lightMode,
              knowledgeId: knowledgeId,
              searchStatisticsController: searchStatisticsController,
            ),
          ),
        ] else ...[
          // ✅ REPLACED: Old inline BlocBuilder comments with UniversalCommentSection
          buildCommentsSection(fixedHeight: MediaQuery.of(context).size.height),
          SizedBox(height: 25.h),
        ],
      ],
    ),
  );
}
