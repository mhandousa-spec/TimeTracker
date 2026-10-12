/// Module: services_management_module
/// Description: Approval-request card — one tile in the approvals grid.
///              Shows service/requester summary info and, when it's the
///              current user's turn to act, approve/reject buttons. The
///              approve/reject mutation (approval-cycle patch, Firestore
///              write, notification fan-out to requester/provider/next
///              approver) is delegated to the shared ApprovalRequestCubit
///              passed down from ApprovalServices — this widget only reads
///              the model and dispatches actions.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: ApprovalRequestCubit, CreateServicesHelper
/// Revision History: 2026-07-02 (Knowticed Team) — audit fix item 2: moved
///                    every try/catch + direct Firestore call (approve/reject
///                    mutation, notification fan-out) into ApprovalRequestCubit.
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/approval_permission_work.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/controller/approval_request_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/pages/approval_request_details_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/widgets/approval_request_card_action_buttons.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/widgets/approval_request_card_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/custom/57-custom_dialog_manager.dart';

part 'approval_request_card_part2.dart';

class ApprovalRequestCard extends StatefulWidget {
  final ServicesHistoryModel service;
  final VoidCallback onRefresh;
  final bool isTablet;
  final bool isMobile;
  final bool isLandscape;
  final ApprovalRequestCubit cubit;

  const ApprovalRequestCard({
    super.key,
    required this.service,
    required this.onRefresh,
    required this.isTablet,
    required this.isMobile,
    required this.isLandscape,
    required this.cubit,
  });

  @override
  State<ApprovalRequestCard> createState() => _ApprovalRequestCardState();
}
