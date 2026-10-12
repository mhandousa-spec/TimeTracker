/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/view_knowledge_details.dart
/// ************************* FILE INFO *************************** ///
/// File Name: view_knowledge_details.dart
/// Purpose: Contains the file info and comments section with conditional tabs for owners.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Added Analytics & Statistics tabs for document owners

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/knowledge_hub/k3_view_knowledge_details/presentation/ui/widgets/comments_section/build_comments_list.dart';
import 'package:knowticed_plus/features/knowledge_hub/k3_view_knowledge_details/presentation/ui/widgets/document_info/document_details_section.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/presentation/ui/widgets/default_form_field.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hub_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
import '../../../../main_controller/data/services/submissions_firebase_service.dart';
import '../widgets/comments_section/build_comments_list.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../../main_controller/data/services/create_comment_firebase_service.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import '../../../../main_controller/data/services/submissions_firebase_service.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k5_submission_details/presentation/controller/analytics_cubit.dart';
import '../../../../k6_approvals/presentation/controller/approvals_states.dart';
import '../../controller/create_comment_cubit.dart';
import '../../controller/create_comment_states.dart';
import '../../../../k5_submission_details/presentation/ui/widgets/analytics_section/analytics_tab/build_analytics_tab.dart';
import '../../../../k5_submission_details/presentation/ui/widgets/analytics_section/statistics_tab/build_statistics_tab.dart';
import '../../../../k8_dashboard/presentation/ui/pages/dashboard_screen.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

part './view_knowledge_details.sections.dart';

class ViewKnowledgeDetails extends StatefulWidget {
  final String documentName;
  final String documentNameAr;
  final String documentType;
  final String owningDepartment;
  final String documentEnglishDescription;
  final String documentEnglishDescriptionAr;
  final String publishDate;
  final String knowledgeId;
  final String fileUrl;
  final String fileType;
  final String documentExtension;
  final String emailUser; // ✅ Creator's email

  const ViewKnowledgeDetails({
    super.key,
    required this.documentName,
    required this.documentNameAr,
    required this.publishDate,
    required this.documentType,
    required this.owningDepartment,
    required this.documentEnglishDescription,
    required this.documentEnglishDescriptionAr,
    required this.knowledgeId,
    required this.fileType,
    required this.fileUrl,
    required this.emailUser,
    required this.documentExtension,
  });

  @override
  State<ViewKnowledgeDetails> createState() => _ViewKnowledgeDetailsState();
}

class _ViewKnowledgeDetailsState extends State<ViewKnowledgeDetails>
    with SingleTickerProviderStateMixin, _ViewKnowledgeDetailsSections {
  @override
  void initState() {
    super.initState();

    // ✅ Determine if current user is the owner
    isOwner = _checkIfOwner();

    log('═══════════════════════════════════════', name: 'ViewKnowledgeDetails');
    log('📄 Document: ${widget.documentName}', name: 'ViewKnowledgeDetails');
    log('👤 Creator Email: ${widget.emailUser}', name: 'ViewKnowledgeDetails');
    log('✓ Is Owner: $isOwner', name: 'ViewKnowledgeDetails');
    log('═══════════════════════════════════════', name: 'ViewKnowledgeDetails');

    // ✅ Initialize TabController ONLY for owners (3 tabs)
    if (isOwner) {
      _tabController = TabController(length: 3, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchStatisticsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // ✅ Get localized document name
    final localizedDocumentName = isArabic ? widget.documentNameAr : widget.documentName;

    // ✅ Get localized description
    final localizedDescription = isArabic
        ? widget.documentEnglishDescriptionAr
        : widget.documentEnglishDescription;

    // ✅ Get localized document type
    final localizedDocumentType = DocumentTypeHelper.getLocalizedType(
      widget.documentType,
      isArabic,
    );

    // ✅ Get localized department name
    final departmentController = Get.find<MainCoreDepartmentCubit>();
    String localizedDepartment = widget.owningDepartment;
    try {
      String? departmentId = departmentController.getDepartmentIdFromDepartmentName(
        departmentName: widget.owningDepartment.toLowerCase(),
      );

      if (departmentId != null) {
        if (isArabic) {
          localizedDepartment = departmentController.getArabicDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ?? widget.owningDepartment;
        } else {
          localizedDepartment = departmentController.getEnglishDepartmentNameFromDepartmentId(
            departmentId: departmentId,
          ) ?? widget.owningDepartment;
        }
      }
    } catch (e) {
      log('Error getting department name: $e', name: 'ViewKnowledgeDetails');
    }

    return MultiBlocProvider(
      providers: [
        // ✅ CommentsCubit - Always needed
        BlocProvider(
          create: (context) => CommentsCubit(CommentsFirebaseServices())
            ..fetchComments(widget.knowledgeId),
        ),
        // ✅ AnalyticsCubit - Only for owners
        if (isOwner)
          BlocProvider(
            create: (context) => AnalyticsCubit(CommentsFirebaseServices())
              ..fetchAnalytics(widget.knowledgeId),
          ),
      ],
      child: Scaffold(
        body: BlocListener<CommentsCubit, CommentsState>(
          listener: (context, state) {
            if (state is CreateCommentSuccess) {
              log('Comment added successfully', name: 'ViewKnowledgeDetails');
            } else if (state is CreateCommentFailure) {
              _showErrorDialog(context, state.error);
            }
          },
          child: SideFrameMasterServices(
            titleText: S.of(context).knowledge_hub,
            onFirstTap: () => Navigator.of(context).pop(),
            secondTitle: localizedDocumentName,
            child: SingleChildScrollView(  // ✅ Add SingleChildScrollView here
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // ✅ Document Info Section - Always visible at top
                  buildDocumentDetailsSection(
                    context,
                    documentName: localizedDocumentName,
                    documentType: localizedDocumentType,
                    owningDepartment: localizedDepartment,
                    documentDescription: localizedDescription,
                    publishDate: widget.publishDate,
                    fileType: widget.fileType,
                    fileUrl: widget.fileUrl,
                    knowledgeId: widget.knowledgeId,
                    documentExtension: widget.documentExtension,
                    createdByEmail: widget.emailUser,
                  ),

                  SizedBox(height: 15.h),

                  // ✅ CONDITIONAL RENDERING: Tabs for Owner, Simple Comments for Contributors
                  if (isOwner)
                    _buildOwnerTabsView(context, lightMode)
                  else
                    _buildContributorCommentsView(context, lightMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
