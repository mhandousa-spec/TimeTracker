/// Module: services_management_module
/// Description: Approvals list page — status chips (per-state counts) and
///              the searchable/filterable/sortable grid of ApprovalRequestCard
///              tiles for requests awaiting (or resolved by) the current
///              user's approval. Per-state counts are loaded via
///              ApprovalRequestCubit.fetchServiceStateCounts(); no Firestore
///              access happens directly in this file.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, ApprovalRequestCubit, ServicesManagerCubit
/// Revision History: 2026-07-02 (Knowticed Team) — audit fix item 2: moved
///                    the `_fetchServiceStateCounts()` collectionGroup scan
///                    into ApprovalRequestCubit / CreateServicesRepository.
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/controller/approval_request_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/widgets/approval_request_card.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/widgets/approval_request_card_header.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/34-custom_gridview_with_animation.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/sort.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/widgets/approvals_department_filter.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_multi.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'approval_request_part2.dart';

class ApprovalServices extends StatefulWidget {
  const ApprovalServices({super.key});
  @override
  State<ApprovalServices> createState() => _ApprovalServicesState();
}
