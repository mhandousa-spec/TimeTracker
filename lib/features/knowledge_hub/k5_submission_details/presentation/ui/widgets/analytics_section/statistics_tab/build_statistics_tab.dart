/// Module: knowledge_hub / presentation / s5_submission_details / widgets/analytics_section/statistics_tab/build_statistics_tab.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_statistics_tab.dart
/// Purpose: Build statistics tab — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/knowledge_hub/k5_submission_details/presentation/controller/analytics_states.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/ui/widgets/submitted_documents_grid_states/table.dart';
import 'package:knowticed_plus/features/knowledge_hub/k5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/build_statistics_item.dart';



import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import '../../../../../../main_controller/data/models/employee_data.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../controller/analytics_cubit.dart';
import './filter_statistics.dart';

Widget buildStatisticsTab(
    BuildContext context, {
      required bool lightMode,
      required TextEditingController searchStatisticsController,
    }) {
  final isMobile = ContextExtension(context).isPhone;

  return BlocBuilder<AnalyticsCubit, AnalyticsStates>(
    builder: (context, state) {
      final cubit = context.read<AnalyticsCubit>();

      // ✅ DEBUG: Log cache status
      log('═══════════════════════════════════════', name: 'StatisticsTab');
      log('📊 Statistics Tab Build', name: 'StatisticsTab');
      log('📌 Total Actions: ${cubit.allActions.length}', name: 'StatisticsTab');
      log('📌 Users Cache Size: ${cubit.usersCache.length}', name: 'StatisticsTab');

      // ✅ DEBUG: Log user IDs from actions vs cache
      if (cubit.allActions.isNotEmpty) {
        log('📋 First 5 Action User IDs:', name: 'StatisticsTab');
        for (var i = 0; i < cubit.allActions.take(5).length; i++) {
          final action = cubit.allActions[i];
          final userId = action.currentUserId;
          final hasUser = cubit.usersCache.containsKey(userId);
          log('   Action $i: UserID="$userId", InCache=$hasUser', name: 'StatisticsTab');

          if (hasUser) {
            final user = cubit.usersCache[userId];
            log('      → Name: ${user?.currentemployeeName}', name: 'StatisticsTab');
          }
        }
      }
      log('═══════════════════════════════════════', name: 'StatisticsTab');

      // ✅ Show loading
      if (state is FetchingAnalyticsLoadingState) {
        return Center(
          child: CircleProgressMaster(),
        );
      }

      // ✅ Show error
      if (state is FetchingAnalyticsErrorState) {
        return Center(
          child: Text(
            '${S.of(context)!.error}: ${state.error}',
            style: TextStyle(color: AppColors.red),
          ),
        );
      }

      // ✅ CHANGED: Always show table for both Empty and Success states
      //
      // CHANGED 22/9/2026 — `filteredActions`, not `allActions`. The Filter
      // dialog and the search field above the table now narrow this list; see
      // the STATISTICS TAB section of AnalyticsCubit.
      final actions = cubit.filteredActions;
      final usersCache = cubit.usersCache;

      // ✅ For mobile: Show empty state or list items
      if (isMobile) {
        if (actions.isEmpty) {
          // CHANGED 12/9/2026 — the app's one empty state (the `lottie_empty`
          // animation) replaces the "No statistics available" sentence, which
          // sat alone at the top of the tab and read like a failed load. See
          // [CustomEmptyState] for why the empty states carry no words.
          //
          // The extra vertical padding drops it clear of the tab row instead of
          // hanging off it — the tab area sizes itself to its content on a
          // phone, so the padding is what places the animation rather than a
          // Center inside a box that is only as tall as the animation.
          return const CustomEmptyState(verticalPadding: 48);
        }

        return SingleChildScrollView(
          child: Column(
            children: actions.map((action) {
              final userData = usersCache[action.currentUserId];

              if (userData == null) {
                log('⚠️ Missing user data for userId: ${action.currentUserId}', name: 'StatisticsTab');
              }

              return buildStatisticsItem(
                context,
                lightMode: lightMode,
                isMobile: isMobile,
                action: action,
                userData: userData,
              );
            }).toList(),
          ),
        );
      }

      // ✅ For desktop/tablet: Always show table (empty or with data)
      return statisticsTable(
        context,
        lightMode: lightMode,
        actions: actions, // ✅ Pass empty list if no data - table will handle it
        searchStatisticsController: searchStatisticsController,
        usersCache: usersCache,
      );
    },
  );
}