/// Module: knowledge_hub / presentation / s5_submission_details / submission_details_screen.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submission_details_screen.dart
/// Purpose: Submission details screen — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/knowledge_hub/k5_submission_details/presentation/ui/widgets/submission_details_contents/build_published_content.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/submission_date_formatter.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import '../../../../main_controller/data/services/submissions_firebase_service.dart';
import '../../../../k4_submissions/presentation/controller/submissions_cubit.dart';

class SubmissionDetailsScreen extends StatefulWidget {
  final String documentName;
  final String documentNameAr;
  final String documentType;
  final String documentEnglishDescriptionAr;
  final String owningDepartment;
  final String documentEnglishDescription;
  final String submissionDate;
  final String fileType;
  final String fileUrl;
  final String knowledgeId;
  final String documentExtension;
  final String currentStatus;
  final List<String>? limitedDepartments;
  final dynamic startDate;
  final dynamic endDate;
  final dynamic startTime;
  final dynamic endTime;
  final List<String>? statusHistory;
  final String createdBy;

  const SubmissionDetailsScreen({
    super.key,
    required this.documentName,
    required this.documentNameAr,
    required this.documentType,
    required this.documentEnglishDescriptionAr,
    required this.owningDepartment,
    required this.documentEnglishDescription,
    required this.submissionDate,
    required this.fileType,
    required this.fileUrl,
    required this.knowledgeId,
    required this.documentExtension,
    required this.currentStatus,
    this.limitedDepartments,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.statusHistory,
    required this.createdBy,
  });

  @override
  State<SubmissionDetailsScreen> createState() =>
      _SubmissionDetailsScreenState();
}

class _SubmissionDetailsScreenState extends State<SubmissionDetailsScreen> {
  bool _showFullComments = false;
  final TextEditingController _searchStatisticsController =
  TextEditingController();

  static const String _publishedStatus = 'published';

  @override
  void initState() {
    super.initState();
    if (widget.currentStatus != _publishedStatus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SubmissionsCubit>().fetchCommentsByKnowledgeId(
          widget.knowledgeId,
        );
      });
    }
  }

  @override
  void dispose() {
    _searchStatisticsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsivePage.isMobile(context);
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isPublished = widget.currentStatus == _publishedStatus;

    debugPrint('═══════════════════════════════════════');
    debugPrint('📱 SUBMISSION DETAILS SCREEN BUILD');
    debugPrint('═══════════════════════════════════════');
    debugPrint('📌 Knowledge ID: ${widget.knowledgeId}');
    debugPrint('📌 Current Status: ${widget.currentStatus}');
    debugPrint('📌 Created By: ${widget.createdBy}');
    debugPrint('📌 Is Published (current): $isPublished');
    debugPrint('📌 Is Mobile: $isMobile');
    debugPrint('───────────────────────────────────────');
    debugPrint('📊 Status History Received:');
    debugPrint('   Type: ${widget.statusHistory.runtimeType}');
    debugPrint('   Value: ${widget.statusHistory}');
    debugPrint('   Length: ${widget.statusHistory?.length ?? 0}');
    if (widget.statusHistory != null && widget.statusHistory!.isNotEmpty) {
      debugPrint('   Contents:');
      for (int i = 0; i < widget.statusHistory!.length; i++) {
        debugPrint('      [$i] "${widget.statusHistory![i]}"');
      }
    } else {
      debugPrint('   ⚠️ WARNING: Status history is NULL or EMPTY!');
    }
    debugPrint('───────────────────────────────────────');
    debugPrint('📅 Date Information:');
    debugPrint('   Start Date Raw: ${widget.startDate} (${widget.startDate.runtimeType})');
    debugPrint('   End Date Raw: ${widget.endDate} (${widget.endDate.runtimeType})');
    debugPrint('   Start Time Raw: ${widget.startTime} (${widget.startTime.runtimeType})');
    debugPrint('   End Time Raw: ${widget.endTime} (${widget.endTime.runtimeType})');

    // ✅ Format the dates and times
    final formattedStartDate =
        SubmissionDateFormatter.formatDateTime(widget.startDate);
    final formattedEndDate =
        SubmissionDateFormatter.formatDateTime(widget.endDate);
    final formattedStartTime =
        SubmissionDateFormatter.formatTime(widget.startTime);
    final formattedEndTime =
        SubmissionDateFormatter.formatTime(widget.endTime);

    debugPrint('   Start Date Formatted: $formattedStartDate');
    debugPrint('   End Date Formatted: $formattedEndDate');
    debugPrint('   Start Time Formatted: $formattedStartTime');
    debugPrint('   End Time Formatted: $formattedEndTime');
    debugPrint('═══════════════════════════════════════\n');

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).knowledge_hub,
        secondTitle: S.of(context).submissions,
        thirdTitle: isArabic ? widget.documentNameAr : widget.documentName,
        onFirstTap: () => Navigator.of(context).pop(),
        onSecondTap: () => Navigator.of(context).pop(),
        child: buildPublishedContent(
          context,
          createdBy: widget.createdBy,
          documentNameAr: widget.documentNameAr,
          documentName: widget.documentName,
          documentDescriptionAr: widget.documentEnglishDescriptionAr,
          documentType: widget.documentType,
          owningDepartment: widget.owningDepartment,
          documentDescription: widget.documentEnglishDescription,
          publishDate: widget.submissionDate,
          fileType: widget.fileType,
          fileUrl: widget.fileUrl,
          knowledgeId: widget.knowledgeId,
          documentExtension: widget.documentExtension,
          isMobile: isMobile,
          currentStatus: widget.currentStatus,
          limitedDepartments: widget.limitedDepartments,
          lightMode: lightMode,
          searchStatisticsController: _searchStatisticsController,
          startDate: formattedStartDate,
          endDate: formattedEndDate,
          startTime: formattedStartTime,
          endTime: formattedEndTime,
          statusHistory: widget.statusHistory ?? [],
        ),
      ),
    );
  }

}