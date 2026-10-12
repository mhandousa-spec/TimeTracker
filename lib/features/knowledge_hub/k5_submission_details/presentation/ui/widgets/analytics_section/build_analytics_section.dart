/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/build_analytics_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_analytics_section.dart
/// Purpose: Build analytics section — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/controller/submissions_states.dart' show SubmissionsStates;
import 'package:knowticed_plus/features/knowledge_hub/k5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/build_statistics_tab.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../../../main_controller/data/services/create_comment_firebase_service.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../controller/analytics_cubit.dart';
import '../../../../../k6_approvals/presentation/controller/approvals_states.dart';
import '../../../../../k4_submissions/presentation/controller/submissions_cubit.dart';
import '../comments_section/comments_list_view_on_submitted_file.dart';
import './analytics_tab/build_analytics_tab.dart';

/// Analytics Section for Published Documents
class AnalyticsSection extends StatefulWidget {
  final bool lightMode;
  final String knowledgeId;
  final TextEditingController searchStatisticsController;

  const AnalyticsSection({
    Key? key,
    required this.lightMode,
    required this.knowledgeId,
    required this.searchStatisticsController,
  }) : super(key: key);

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  int selectedIndex = 0;
  bool isCommentSectionExpanded = false; // ✅ Track comment section expansion state

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainCoreEmployeeController>();
    return BlocProvider(
      create: (context) {
        log('🏗️ [buildAnalyticsSection] Creating AnalyticsCubit');
        final cubit = AnalyticsCubit(CommentsFirebaseServices());
        log('📡 [buildAnalyticsSection] Triggering fetchAnalytics');
        cubit.fetchAnalytics(widget.knowledgeId);
        return cubit;
      },
      // FIXED 12/9/2026 — "RenderFlex children have non-zero flex but incoming
      // height constraints are unbounded", thrown on Submission Details on a
      // phone.
      //
      // The tab content below is an `Expanded`, which needs a FINITE height to
      // divide up. It gets one on tablet/desktop, where the caller wraps this
      // section in `Container(height: 960.h)`. On a phone the caller has no
      // such box and the whole page sits in a scroll view, so the incoming
      // height is infinite — `Expanded` is a contradiction there ("fill the
      // remaining space" inside something that is shrink-wrapping) and layout
      // aborts, which is why the screen came up blank with a wall of
      // 'RenderBox was not laid out' errors after it.
      //
      // So: flex only when there is a height to flex into, and otherwise let
      // the section be as tall as the selected tab and let the page's own
      // scroll view do the scrolling.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // CHANGED 28/9/2026 (Knowledge Hub bug report p.22 — "remove this
          // extra space" under the comment box): the Comments tab never fills
          // the section. It is only as tall as the comments themselves, and the
          // caller's box (a max height since this change, see
          // build_published_content.dart) shrinks to it instead of leaving
          // the rest of a 960.h block empty.
          final bool bounded =
              constraints.hasBoundedHeight && selectedIndex != 2;

          return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Custom Tab Bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            // ADDED 22/9/2026 alongside the 24pt tab labels — a plain Row
            // would overflow. Three labels at 24pt plus two 40.w gaps is wider
            // than a phone in English and wider again in Arabic, and the Row
            // has no flexible child to absorb it, so it would throw the yellow
            // overflow stripes rather than clip. Scrolling keeps every tab
            // reachable at any width instead of hiding the last one.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                if( controller.isHasPermission(
                  module: Modules.knowledgeHub,
                  section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                  permission: KnowledgeHubPermissions.analytics,
                ))

                  _buildTabItem(
                    context,
                    title: S.of(context)!.analytics,
                    index: 0,
                  ),
                if( controller.isHasPermission(
                  module: Modules.knowledgeHub,
                  section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                  permission: KnowledgeHubPermissions.statistics,
                ))
                  SizedBox(width: 40.w),
                if( controller.isHasPermission(
                  module: Modules.knowledgeHub,
                  section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                  permission: KnowledgeHubPermissions.statistics,
                ))
                  _buildTabItem(
                    context,
                    title: S.of(context)!.statistics,
                    index: 1,
                  ),

                if( controller.isHasPermission(
                  module: Modules.knowledgeHub,
                  section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                  permission: KnowledgeHubPermissions.inquiriesAndComments,
                ))
                  SizedBox(width: 40.w),

                if( controller.isHasPermission(
                  module: Modules.knowledgeHub,
                  section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
                  permission: KnowledgeHubPermissions.inquiriesAndComments,
                ))
                  _buildTabItem(
                    context,
                    title: S.of(context)!.comments,
                    index: 2,
                  ),
              ],
              ),
            ),
          ),

          SizedBox(height: 20.sp),

          // Tab Content — see the note above: `Expanded` only where the
          // height is finite.
          _tabContent(
            bounded: bounded,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.r),
                  bottomRight: Radius.circular(8.r),
                ),
              ),
              child: _tabStack(
                fill: bounded,
                children: [
                  // Analytics Tab
                  buildAnalyticsTab(context, widget.lightMode, widget.knowledgeId),

                  // Statistics Tab
                  buildStatisticsTab(
                    context,
                    lightMode: widget.lightMode,
                    searchStatisticsController: widget.searchStatisticsController,
                  ),

                  // ✅ Comments Tab - Using UniversalCommentSection
                  UniversalCommentSection(
                    isExpandable: true,
                    collectionPath: 'Demo/75440689/Comments',
                    filterFields: {
                      'Request_Id': widget.knowledgeId, // ✅ Using knowledgeId as Request_Id
                    },
                    currentUserId: Get.find<MainCoreEmployeeController>()
                        .employeeEntity!
                        .email!,
                    fixedHeight: isCommentSectionExpanded ? null : 400.h,
                    collapsedHeight: 400.h,
                    onExpandChanged: (bool expanded) {
                      // ✅ Update state when expansion changes
                      setState(() {
                        isCommentSectionExpanded = expanded;
                      });
                    },
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
              ),
            ),
          ),
        ],
          );
        },
      ),
    );
  }

  /// The tab-content slot: a flex child where the incoming height is finite,
  /// and a plain child where it is not. See the note in [build].
  Widget _tabContent({required bool bounded, required Widget child}) =>
      bounded ? Expanded(child: child) : child;

  /// The three tabs. ADDED 28/9/2026.
  ///
  /// When the section fills a fixed height, an [IndexedStack] as before. When
  /// it sizes to its content, ONLY the selected tab is built: an IndexedStack
  /// is as tall as its TALLEST child, so the short Comments tab used to sit on
  /// top of the Analytics tab's full height — the empty band reported on p.22.
  Widget _tabStack({required bool fill, required List<Widget> children}) =>
      fill
          ? IndexedStack(index: selectedIndex, children: children)
          : children[selectedIndex.clamp(0, children.length - 1)];

  Widget _buildTabItem(BuildContext context, {required String title, required int index}) {
    final isSelected = selectedIndex == index;
    final textColor = isSelected
        ? AppColors.primary
        : AppColors.secondaryText; // ✅ CHANGED: Unselected tab color

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            // CHANGED 22/9/2026 — 16 -> 24, in two steps (16 -> 20 -> 24;
            // 20 was still reported as too small). These three tabs are the
            // only navigation on Submission Details and sat smaller than the
            // "Department" / "Document Utilization" card headings beneath
            // them, so they read as secondary text rather than as the control
            // they are. 24 puts them clearly above those headings.
            style: StyleText.fontSize24Weight500.copyWith(
              color: textColor,
              shadows: [],
            ),
          ),
          SizedBox(height: 0.6.h),
          if (isSelected)
            Container(
              height: 0.6.h,
              // The underline is measured from the same style as the label, so
              // it has to move with it.
              width: _getTextWidth(title, StyleText.fontSize24Weight500),
              color: AppColors.primary,
            ),
        ],
      ),
    );
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}

/// Wrapper function to maintain compatibility with existing code
Widget buildAnalyticsSection(
    BuildContext context, {
      required bool lightMode,
      required String knowledgeId,
      String selectedTab = 'Analytics',
      required TextEditingController searchStatisticsController,
    }) {
  return AnalyticsSection(
    lightMode: lightMode,
    knowledgeId: knowledgeId,
    searchStatisticsController: searchStatisticsController,
  );
}