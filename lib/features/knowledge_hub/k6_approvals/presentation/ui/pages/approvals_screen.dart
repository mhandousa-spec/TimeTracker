/// Module: knowledge_hub / presentation / s6_approvals / approvals_screen.dart
/// ************************* FILE INFO *************************** ///
/// File Name: approvals_screen.dart
/// Purpose: Approvals screen — Approvals (S6) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/helper/format_helper.dart';
import 'package:knowticed_plus/features/knowledge_hub/k6_approvals/presentation/ui/widgets/approvals_document_card.dart';
import 'package:knowticed_plus/features/knowledge_hub/k6_approvals/presentation/ui/widgets/search_approvals.dart';
import 'package:knowticed_plus/features/knowledge_hub/k6_approvals/presentation/ui/widgets/status_list.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/helper/cross_axis_count_helper.dart';
import '../../../../main_controller/data/models/create_knowledge_new_model.dart';
import '../../../../main_controller/data/models/employee_data.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import '../../controller/approvals_cubit.dart';
import '../../controller/approvals_states.dart';
import '../../../../k7_approvals_details/presentation/ui/pages/approvals_details_screen.dart';
import '../../../../k7_approvals_details/presentation/ui/widgets/reason_for_justifications_dialog.dart';
import '../../../../k7_approvals_details/presentation/ui/widgets/reason_for_approval_removing_dialog.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part './approvals_screen.sections.dart';

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen>
    with TickerProviderStateMixin , _ApprovalsScreenSections {  // ✅ ADDED TickerProviderStateMixin
  // ---- fields & helpers moved to _ApprovalsScreenSections (approvals_screen.sections.dart) ----


  @override
  void initState() {
    super.initState();

    // ✅ ADDED: Initialize animation controller - 1 SECOND DURATION
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // 1 second
      vsync: this,
    );

    // Use Future.microtask to ensure context is available
    Future.microtask(() {
      _initializeApprovals();
    });
  }


  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    var isMobile = ContextExtension(context).isPhone;
    var isTablet = ContextExtension(context).isTablet;
    var islandScape = ContextExtension(context).isLandscape;


    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          secondTitle: S.of(context)!.approvals,
          onFirstTap: () => Navigator.of(context).pop(),
          child: BlocListener<ApprovalsCubit, ApprovalsStates>(
            listener: (context, state) {
              _handleIndexChanges(context, state);
        
              if (state is ApprovalsInitial && !_isInitialized) {
                Future.microtask(() => _initializeApprovals());
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Status List
                  BlocBuilder<ApprovalsCubit, ApprovalsStates>(
                    builder: (context, state) {
                      return statusList(
                        context,
                        isMobile: isMobile,
                        selectedIndex: selectedIndex,
                      );
                    },
                  ),
        
                  SizedBox(height: 20.h),
        
                  // Search
                  SearchApprovals(
                    key: ValueKey(_currentSelectedDepartment ?? 'all'),
                    searchApprovalsController: searchApprovalsController,
                  ),
        
                  SizedBox(height: 15),
        
                  // Documents View with loading state
                  BlocBuilder<ApprovalsCubit, ApprovalsStates>(
                    builder: (context, state) {
        
                      if (state is FetchingApprovalsLoadingState ||
                          state is ApprovingKnowledgeLoadingState ||
                          state is RejectingKnowledgeLoadingState ||
                          state is FetchingCommentsLoadingState ||
                          state is AddingCommentLoadingState ||
                          state is RecordFileActionLoading) {
                        return _buildLoadingState();
                      }
        
                      if (state is FetchingApprovalsErrorState) {
                        return _buildErrorState(state.error);
                      }
        
                      if (state is FetchingApprovalsEmptyState) {
                        return _buildEmptyState();
                      }
        
                      if (state is FetchingApprovalsSuccessState) {
                        if (state.approvals.isEmpty) {
                          return _buildEmptyState();
                        }
                        return buildApprovalsGrid(context, isMobile);
                      }
        
                      if (!_isInitialized) {
                        return _buildLoadingState();
                      }
        
                      return _buildLoadingState();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    searchApprovalsController.dispose();
    _gridAnimationController.dispose(); // ✅ ADDED: Dispose animation controller
    super.dispose();
  }
}
