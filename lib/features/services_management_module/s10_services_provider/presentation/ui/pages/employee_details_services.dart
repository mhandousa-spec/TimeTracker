/// Module: services_management_module
/// Description: View all request details with action capabilities
///              (approve/progress/done). All Firestore reads/writes for
///              state mutation now go through EmployeeActionCubit — this
///              page only dispatches cubit methods and keeps its own local
///              UI state (currentState/selectedState) for rendering (audit
///              fix 1b: hard-reject on cloud_firestore + try/catch in UI).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, EmployeeActionCubit, ServicesManagerCubit,
///               dropdown_button2
/// Revision History: Removed file_picker/image_picker/firebase_storage/
///                    permission_handler/dart:io imports (all unused —
///                    dead cruft from a copy-paste, this page never picked
///                    files). Extracted _ensureApprovalCycleExists,
///                    _fetchLatestStateFromFirestore, _updateStateInFirestore,
///                    _sendStatusChangeNotification into EmployeeActionCubit.
///                    Extracted dialogs + requester-details/approval-cycle
///                    section builders into
///                    ui/widgets/employee_details_dialogs_and_sections.dart
///                    (size item 4a) — dropped now-unused lottie/
///                    custom_botton.dart/approvals.dart imports.
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/employee_action_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/employee_action_state.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/widgets/employee_details_dialogs_and_sections.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/pages/select_services_provider_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/provider_details.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/responsive_text.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/show_request_details_shimmer.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/pages/employee_services_toggle.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart' show FirestoreCollections;

part 'employee_details_services_part2.dart';
part 'employee_details_services_part3.dart';

class EmployeeDetailsServicesScreenTablet extends StatefulWidget {
  const EmployeeDetailsServicesScreenTablet({
    required this.approvalModel,
    required this.index,
    super.key,
  });

  final ServicesHistoryModel approvalModel;
  final int index;

  @override
  State<EmployeeDetailsServicesScreenTablet> createState() => _EmployeeDetailsServicesScreenTabletState();
}
