// ******************* FILE INFO *******************
// File Name: request_details.dart
// Description: in page can make request on this services if need
// Created by: Amr Mesbah
// Last Update: 02/02/2026
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'dart:math';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' show DateFormat;


import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/approval_cycle_widget.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/request_service_dialogs.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/responsive_text.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/service_header_widget.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/services/services_notification_service.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/requested_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_services_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/show_requests_shimmer.dart';

import '../../../../main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'request_details_part2.dart';

class RequestServicesDetails extends StatefulWidget {
  const RequestServicesDetails({required this.requestModel, super.key});
  final ServicesHistoryModel requestModel;

  @override
  State<RequestServicesDetails> createState() => _RequestServicesDetailsState();
}
