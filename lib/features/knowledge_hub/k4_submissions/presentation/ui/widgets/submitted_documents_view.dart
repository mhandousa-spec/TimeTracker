/// Module: knowledge_hub / presentation / s4_submissions / widgets/submitted_documents_view.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submitted_documents_view.dart
/// Purpose: Submitted documents view — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/domain/constants/knowledge_hub_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/data/services/submissions_firebase_service.dart';
import '../../controller/submissions_cubit.dart';
import '../../controller/submissions_states.dart';
import '../../../../k5_submission_details/presentation/ui/pages/submission_details_screen.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

// ✅ CONVERT TO STATEFUL WIDGET
class SubmittedDocumentsView extends StatefulWidget {
  final bool isMobile;

  const SubmittedDocumentsView({Key? key, required this.isMobile})
      : super(key: key);

  @override
  State<SubmittedDocumentsView> createState() => _SubmittedDocumentsViewState();
}

class _SubmittedDocumentsViewState extends State<SubmittedDocumentsView>
    with TickerProviderStateMixin {
  // ✅ Animation Controllers
  late AnimationController _gridAnimationController;
  List<Animation<Offset>> _slideAnimations = [];
  List<Animation<double>> _fadeAnimations = [];
  bool _animationsCreated = false;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize animation controller - 1 SECOND DURATION
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // 1 second
      vsync: this,
    );
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  // ✅ CREATE HORIZONTAL STAGGERED ANIMATIONS
  void _createSlideAnimations(int itemCount) {
    _slideAnimations.clear();
    _fadeAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      // Stagger delay: 40ms between each item
      final delay = i * 0.04;

      // ✅ HORIZONTAL Slide animation from LEFT
      final slideAnimation = Tween<Offset>(
        begin: const Offset(-0.3, 0.0), // Horizontal from left
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay.clamp(0.0, 0.6),
            (delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );

      // Fade animation
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay.clamp(0.0, 0.6),
            (delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ),
      );

      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);
    }

    _animationsCreated = true;
  }

  // ✅ PLAY ANIMATION
  void _playGridAnimation() {
    if (_gridAnimationController.isAnimating) return;
    _gridAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubmissionsCubit, SubmissionsStates>(
      builder: (context, state) {
        if (state is FetchingSubmissionsLoadingState) {
          return _buildLoadingState();
        } else if (state is FetchingSubmissionsEmptyState) {
          return _buildEmptyState(context);
        } else if (state is FetchingSubmissionsErrorState) {
          return _buildErrorState(context, state);
        } else {
          return _buildSubmissionsGrid(context, widget.isMobile);
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(child: CircleProgressMaster());
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_empty.json',
              height: 250.h, width: 200.w, repeat: true, fit: BoxFit.fill),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, FetchingSubmissionsErrorState state) {
    return Center(
      child: Lottie.asset(
        'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
        repeat: true,
        width: 300.w,
        height: 300.h,
      ),
    );
  }

// ✅ UPDATED: Add startTime and endTime extraction and pass to SubmissionDetailsScreen

  Widget _buildSubmissionsGrid(BuildContext context, bool isMobile) {
    var isMobile = ContextExtension(context).isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final departmentController = Get.find<MainCoreDepartmentCubit>();

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

    String formatDate(DateTime? date) {
      if (date == null) return 'N/A';
      return DateFormat('dd MMM yyyy').format(date);
    }

    String getDepartmentNameLocalized(String? departmentName, bool isArabic) {
      if (departmentName == null || departmentName.isEmpty) {
        return 'N/A';
      }

      try {
        final departmentId =
        departmentController.getDepartmentId(departmentName);

        if (departmentId == "none") {
          return departmentName;
        }

        if (isArabic) {
          return departmentController.getArabicDepartmentNameFromDepartmentId(
              departmentId: departmentId) ??
              departmentName;
        } else {
          return departmentController.getEnglishDepartmentNameFromDepartmentId(
              departmentId: departmentId) ??
              departmentName;
        }
      } catch (e) {
        debugPrint('Error getting department name: $e');
        return departmentName;
      }
    }

    final cubit = context.read<SubmissionsCubit>();
    final submissions = cubit.filteredKnowledge;

    if (submissions.isEmpty) {
      return _buildNoFilterResultsState(context);
    }

    // ✅ CREATE ANIMATIONS IF NOT CREATED
    if (!_animationsCreated ||
        _slideAnimations.length != submissions.length) {
      _createSlideAnimations(submissions.length);
      // Play animation after creation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playGridAnimation();
      });
    }

    return SizedBox(
      height: 600.sp,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
              context,
            ),
            // RAISED 22/9/2026 — the cell was sized for three lines (title,
            // owning department, dates). The status moved out of its
            // floating overlay and into the column as a fourth line, so the
            // cell has to grow with it or every card overflows by the height
            // of that row.
            mainAxisExtent: isMobile ? 99.sp : 102.sp,
            crossAxisSpacing: 10.sp,
            mainAxisSpacing: 10.sp),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final submission = submissions[index];

          final Color statusColor = _getStatusColor(submission.currentStatus);

          final DateTime? uploadDate =
          _getTimestampDate(submission.timestamps.first);
          final DateTime? lastEditDate =
          _getTimestampDate(submission.timestamps.last);
          final String statusDisplay = _getStatusDisplay(
            context,
            submission.currentStatus,
          );

          // ✅ EXTRACT START DATE
          dynamic rawStartDate;
          if (submission.startDateTime != null) {
            if (submission.startDateTime is List &&
                (submission.startDateTime as List).isNotEmpty) {
              rawStartDate = (submission.startDateTime as List).first;
            } else {
              rawStartDate = submission.startDateTime;
            }
          }

          // ✅ EXTRACT END DATE
          dynamic rawEndDate;
          if (submission.endDateTime != null) {
            if (submission.endDateTime is List &&
                (submission.endDateTime as List).isNotEmpty) {
              rawEndDate = (submission.endDateTime as List).first;
            } else {
              rawEndDate = submission.endDateTime;
            }
          }

          // ✅ NEW: EXTRACT START TIME
          dynamic rawStartTime;
          if (submission.startTime != null) {
            if (submission.startTime is List &&
                (submission.startTime as List).isNotEmpty) {
              rawStartTime = (submission.startTime as List).first;
            } else {
              rawStartTime = submission.startTime;
            }
          }

          // ✅ NEW: EXTRACT END TIME
          dynamic rawEndTime;
          if (submission.endTime != null) {
            if (submission.endTime is List &&
                (submission.endTime as List).isNotEmpty) {
              rawEndTime = (submission.endTime as List).first;
            } else {
              rawEndTime = submission.endTime;
            }
          }

          final isArabic = Localizations.localeOf(context).languageCode == 'ar';

          final dateInfo = _getDateInfoByStatus(
            context,
            submission.currentStatus,
            uploadDate,
            lastEditDate,
            rawStartDate,
            rawEndDate,
          );

          final String departmentName = getDepartmentNameLocalized(
            submission.currentOwningDepartment,
            isArabic,
          );

          // ✅ WRAP WITH ANIMATED TRANSITIONS
          return SlideTransition(
            position: _slideAnimations.length > index
                ? _slideAnimations[index]
                : AlwaysStoppedAnimation(Offset.zero),
            child: FadeTransition(
              opacity: _fadeAnimations.length > index
                  ? _fadeAnimations[index]
                  : AlwaysStoppedAnimation(1.0),
              child:
              GestureDetector(
                onTap: () {
                  log(submission.currentKnowledgeId, name: 'SUBMISSION_TAP');

                  // ✅ EXTRACT START DATE
                  dynamic rawStartDate;
                  if (submission.startDateTime != null) {
                    if (submission.startDateTime is List &&
                        (submission.startDateTime as List).isNotEmpty) {
                      rawStartDate = (submission.startDateTime as List).first;
                    } else {
                      rawStartDate = submission.startDateTime;
                    }
                  }

                  // ✅ EXTRACT END DATE
                  dynamic rawEndDate;
                  if (submission.endDateTime != null) {
                    if (submission.endDateTime is List &&
                        (submission.endDateTime as List).isNotEmpty) {
                      rawEndDate = (submission.endDateTime as List).first;
                    } else {
                      rawEndDate = submission.endDateTime;
                    }
                  }

                  // ✅ EXTRACT START TIME - Use currentStartTime getter
                  String? extractedStartTime = submission.currentStartTime;

                  // ✅ EXTRACT END TIME - Use currentEndTime getter
                  String? extractedEndTime = submission.currentEndTime;

                  log('═══════════════════════════════════════', name: 'NavigationData');
                  log('📅 Extracted Data for Navigation:', name: 'NavigationData');
                  log('   Start Date: $rawStartDate', name: 'NavigationData');
                  log('   End Date: $rawEndDate', name: 'NavigationData');
                  log('   Start Time: $extractedStartTime', name: 'NavigationData');
                  log('   End Time: $extractedEndTime', name: 'NavigationData');
                  log('═══════════════════════════════════════', name: 'NavigationData');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => SubmissionsCubit(SubmissionsFirebaseServices()),
                        child: SubmissionDetailsScreen(
                          createdBy: submission.currentCreatedByEmail,
                          statusHistory: submission.status,
                          documentNameAr: submission.currentNameArabic,
                          documentName: submission.currentNameEnglish,
                          documentEnglishDescription: submission.currentDescriptionEnglish,
                          documentEnglishDescriptionAr: submission.currentDescriptionArabic,
                          documentExtension: submission.currentDocumentExtension,
                          documentType: submission.currentKnowledgeDocumentType,
                          fileType: submission.currentKnowledgeDocumentType,
                          fileUrl: submission.currentDocumentUrl,
                          knowledgeId: submission.currentKnowledgeId,
                          owningDepartment: submission.currentOwningDepartment,
                          submissionDate: uploadDate != null
                              ? DateFormat('dd MMM yyyy').format(uploadDate)
                              : 'N/A',
                          currentStatus: submission.currentStatus,
                          limitedDepartments: submission.currentLimitedDepartmentsList,
                          startDate: rawStartDate,
                          endDate: rawEndDate,
                          startTime: extractedStartTime,  // ✅ Pass extracted time string
                          endTime: extractedEndTime,      // ✅ Pass extracted time string
                        ),
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: lightMode
                            ? AppColors.white
                            : AppColors.chatBackground,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 5.sp, right: 10.sp, left: 5.sp),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Stack(
                                  children: [
                                    submission.currentImageUrl.isNotEmpty
                                        ? SizedBox(
                                      height: 55.h,
                                      width: 45.w,

                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(4.r),
                                        child: Image.network(
                                          submission.currentImageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                        : SizedBox(
                                      height: 45.h,
                                      width: 45.w,
                                      child: CustomSvgImage(
                                        assetPath: getFileIcon(submission
                                            .currentDocumentExtension),
                                        height: 35.h,
                                        width: 35.w,
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                    if (submission.currentImageUrl.isNotEmpty)
                                      Positioned(
                                        bottom: 2.sp,
                                        right: 2.sp,
                                        child: CustomSvgImage(
                                          assetPath: getFileIcon(submission
                                              .currentDocumentExtension),
                                          height: 30.h,
                                          width: 30.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic
                                        ? submission.currentNameArabic
                                        : submission.currentNameEnglish,
                                    style: StyleText.fontSize14Weight500
                                        .copyWith(
                                      color: lightMode
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6.h),
                                  // Status — see the note where the old
                                  // `Positioned` overlay used to be.
                                  Row(
                                    children: [
                                      Text(
                                        "${S.of(context).status}: ",
                                        style: StyleText.fontSize10Weight400
                                            .copyWith(
                                          color: lightMode
                                              ? AppColors.secondaryText
                                              : AppColors.grey,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          statusDisplay,
                                          style: StyleText.fontSize10Weight400
                                              .copyWith(color: statusColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Text(
                                        "${S.of(context).owning_department}: ",
                                        style: StyleText.fontSize10Weight400
                                            .copyWith(
                                          color: lightMode
                                              ? AppColors.secondaryText
                                              : AppColors.grey,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          departmentName,
                                          style: StyleText.fontSize12Weight500
                                              .copyWith(
                                            color: lightMode
                                                ? AppColors.blackButton
                                                : AppColors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  Row(
                                    children: [
                                      Text(
                                        FormatHelper.capitalize(
                                            "${dateInfo['firstLabel']} "),
                                        style: StyleText.fontSize10Weight400
                                            .copyWith(
                                          color: lightMode
                                              ? AppColors.secondaryText
                                              : AppColors.grey,
                                        ),
                                      ),
                                      Text(
                                        formatDate(dateInfo['firstDate']),
                                        style: StyleText.fontSize10Weight400
                                            .copyWith(
                                          color: lightMode
                                              ? AppColors.blackButton
                                              : AppColors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (dateInfo['secondLabel'] != null) ...[
                                        Spacer(),
                                        Text(
                                          dateInfo['secondLabel'],
                                          style: StyleText.fontSize10Weight400
                                              .copyWith(
                                            color: lightMode
                                                ? AppColors.secondaryText
                                                : AppColors.grey,
                                          ),
                                        ),
                                        Text(
                                          formatDate(dateInfo['secondDate']),
                                          style: StyleText.fontSize10Weight400
                                              .copyWith(
                                            color: lightMode
                                                ? AppColors.blackButton
                                                : AppColors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // MOVED 22/9/2026 — the status used to be a `Positioned`
                    // pinned to the card's top-right corner, floating OVER the
                    // document title. Any title longer than about half the card
                    // ran underneath it (see "Form Builder Bug Report"), so the
                    // two unrelated pieces of text overlapped and neither could
                    // be read. It is now a normal row directly under the title,
                    // inside the same column, where it takes its own space and
                    // the title's ellipsis can do its job.
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildNoFilterResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64.sp, color: AppColors.secondaryText),
          SizedBox(height: 16.h),
          Text(
            S.of(context).noSubmissionsMatchFilters,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ HELPER FUNCTIONS (keep all existing helper functions)

DateTime? _getTimestampDate(int? timestamp) {
  return timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(timestamp)
      : null;
}

Map<String, dynamic> _getDateInfoByStatus(
    BuildContext context,
    String status,
    DateTime? uploadDate,
    DateTime? lastEditDate,
    dynamic rawStartDate,
    dynamic rawEndDate,
    ) {
  DateTime? startDate;
  DateTime? endDate;

  if (rawStartDate != null) {
    if (rawStartDate is int) {
      startDate = DateTime.fromMillisecondsSinceEpoch(rawStartDate);
    } else if (rawStartDate is DateTime) {
      startDate = rawStartDate;
    }
  }

  if (rawEndDate != null) {
    if (rawEndDate is int) {
      endDate = DateTime.fromMillisecondsSinceEpoch(rawEndDate);
    } else if (rawEndDate is DateTime) {
      endDate = rawEndDate;
    }
  }

  switch (status.toLowerCase()) {
    case 'published':
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).last_edit}: ',
        'secondDate': lastEditDate,
      };

    case 'pending_approval':
      return {
        'firstLabel': S.of(context).submittedDate,
        'firstDate': uploadDate,
        'secondLabel': null,
        'secondDate': null,
      };

    case 'approved':
      return {
        'firstLabel': S.of(context).publishingDate,
        'firstDate': uploadDate,
        'secondLabel': null,
        'secondDate': null,
      };

    case 'rejected':
      return {
        'firstLabel': S.of(context).submittedDate,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).rejectedDate}: ',
        'secondDate': lastEditDate,
      };

    case 'removed':
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).removedDate}',
        'secondDate': lastEditDate,
      };

    case 'archived':
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).end_date}: ',
        'secondDate': endDate ?? lastEditDate,
      };

    default:
      return {
        'firstLabel': S.of(context).publish_date,
        'firstDate': uploadDate,
        'secondLabel': '${S.of(context).last_edit}: ',
        'secondDate': lastEditDate,
      };
  }
}

String _getStatusDisplay(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'published':
      return S.of(context).published;
    case 'approved':
      return S.of(context).approved;
    case 'pending_approval':
      return S.of(context).pending;
    case 'scheduled':
      return S.of(context).scheduled;
    case 'rejected':
      return S.of(context).rejected;
    case 'removed':
      return S.of(context).removed;
    case 'archived':
      return S.of(context).archive;
    default:
      return status;
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'published':
      return KnowledgeHubColors.excelGreen;
    case 'approved':
      return KnowledgeHubColors.greenAccent;
    case 'pending_approval':
      return AppColors.orange;
    case 'scheduled':
      return AppColors.blue;
    case 'rejected':
      return AppColors.darkRed;
    case 'removed':
      return AppColors.darkRed;
    case 'archived':
      return AppColors.secondaryBlack;
    default:
      return AppColors.grey;
  }
}

Color _getExtensionBadgeColor(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return KnowledgeHubColors.red;
    case 'ppt':
    case 'pptx':
      return KnowledgeHubColors.pdfRed;
    case 'doc':
    case 'docx':
      return KnowledgeHubColors.wordBlue;
    case 'xls':
    case 'xlsx':
      return KnowledgeHubColors.excelGreenDark;
    case 'txt':
      return KnowledgeHubColors.slateGrey;
    case 'png':
    case 'jpg':
    case 'jpeg':
      return KnowledgeHubColors.purple;
    case 'mp4':
    case 'mov':
      return KnowledgeHubColors.powerpointOrange;
    default:
      return KnowledgeHubColors.darkSlate;
  }
}
