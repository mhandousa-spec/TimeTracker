/// Module: knowledge_hub / presentation / s4_submissions / submissions_screen.dart
/// ************************* FILE INFO *************************** ///
/// File Name: submissions_screen.dart
/// Purpose: Submissions screen — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/ui/widgets/category_list.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/ui/widgets/inner_status_section.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/ui/widgets/search_section.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/ui/widgets/submitted_documents_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import '../../../../main_controller/domain/constants/constant.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import '../../controller/submissions_cubit.dart';
import '../../controller/submissions_states.dart';

class SubmissionsScreen extends StatefulWidget {
  const SubmissionsScreen({super.key});

  @override
  State<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends State<SubmissionsScreen> {
  int selectedIndex = 0;
  int selectedInnerIndex = 0;
  final searchCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }



  void _initializeUserData() {
    final cubit = context.read<SubmissionsCubit>();

    // Get user email from various sources
    String? userEmail;

    // From GetX controller
    try {
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final employeeController = Get.find<MainCoreEmployeeController>();
        userEmail = employeeController.employeeEntity?.email;
      }
    } catch (e) {
      log('Error getting email from GetX: $e');
    }

    // From ConstantVar
    if (userEmail == null || userEmail.isEmpty) {
      try {
        if (ConstantVar.emailUser.isNotEmpty) {
          userEmail = ConstantVar.emailUser;
        }
      } catch (e) {
        log('Error getting email from ConstantVar: $e');
      }
    }

    if (userEmail != null && userEmail.isNotEmpty) {
      cubit.setCurrentUserEmail(userEmail);
      log('✅ User email set in submissions: $userEmail');
    } else {
      log('❌ Could not set user email in submissions');
    }

    // ✅ Fetch submissions first
    cubit.fetchAllSubmissionsEMp().then((_) {
      // ✅ After fetching, check for expiring documents
      log('📊 Submissions loaded, now checking for expiring documents...');
      cubit.checkAndNotifyExpiringDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).knowledge_hub,
          secondTitle: S.of(context).submissions,
          onFirstTap: () => Navigator.of(context).pop(),
          child: BlocListener<SubmissionsCubit, SubmissionsStates>(
            listener: _handleIndexChanges,
            child: SingleChildScrollView(
              child: Column(
                children: [
                 // if (isMobile) SizedBox(height: 30.h),
                  categoryList(
                    context,
                    isMobile: isMobile,
                    selectedIndex: selectedIndex,
                  ),
                  SizedBox(height: 25.h),
                  searchWithStatusFilters(
                    context,
                    searchCategoryController: searchCategoryController,
                  ),
                  SizedBox(height: 15.h),
                  innerStatusSection(
                    context,
                    selectedInnerIndex: selectedInnerIndex,
                    lighMode: lightMode,
                  ),
                  SizedBox(height: 10.h),
                  SubmittedDocumentsView(isMobile: isMobile)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleIndexChanges(BuildContext context, SubmissionsStates state) {
    if (state is ChangeIndexSuccessState) {
      setState(() {
        selectedIndex = state.index;
        log('Selected index: $selectedIndex');
      });
    }
    if (state is ChangeInnerIndexSuccessState) {
      setState(() {
        selectedInnerIndex = state.index;
        log('Selected inner index: $selectedInnerIndex');
      });
    }
  }
}
