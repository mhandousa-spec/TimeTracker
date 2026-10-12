/// Module: services_management_module
/// Description: "My assigned services" list screen for s10 (employee
///              action). Firestore fetch-and-cache now goes through
///              EmployeeServicesCubit — this page only dispatches
///              loadAndCacheServices() and renders EmployeeServicesState;
///              all subsequent filtering/searching/counting still runs
///              locally against the cached list (audit fix 1b).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, EmployeeServicesCubit, dropdown_button2
/// Revision History: Extracted _loadAndCacheServices() (the only Firestore
///                    call in this file) into EmployeeServicesCubit; the
///                    'Demo'/'RequestServices' collection-path literals now
///                    live in the cubit as FirebaseCollections constants.
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/54-custom_grid_view.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/widgets/custom_table.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/widgets/export_file.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_multi.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/reuse_text.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';

import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/employee_services_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/controller/employee_services_state.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/pages/employee_details_services_toggle.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'employee_services_part2.dart';
part 'employee_services_part3.dart';

class EmployeeServicesScreenTablet extends StatefulWidget {
  const EmployeeServicesScreenTablet({super.key});

  @override
  State<EmployeeServicesScreenTablet> createState() =>
      _EmployeeServicesScreenTabletState();
}
