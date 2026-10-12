/// Module: services_management_module
/// Description: Mobile SLA configuration screen (set SLA breach thresholds
///              & notification preferences). SharedPreferences seeding
///              (edit-mode bootstrap) and percentage/checkbox/switch
///              persistence now go through SlaCubit — the page still owns
///              its own local widget state (checkbox/switch maps, text
///              controllers) since that drives the section-builder widget
///              tree, but no longer calls SharedPreferences.getInstance()
///              directly for that seeding/persistence step (audit fix 1e).
///              The actual create/update Firestore call continues to run
///              through ServicesManagerCubit (module-root, already fixed).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: AppColors, StyleText, S (localization), CustomTextField,
///               SlaCubit, ServicesManagerCubit
/// Revision History: Added controller/sla_cubit.dart (first controller/
///                    folder for s12) and routed the initState() prefs-seed
///                    block + _submitAllToSharedPrefs() through it.
///                    cloud_firestore import kept — Timestamp.now() is used
///                    as a client-side id/date-formatting utility only, no
///                    Firestore reads/writes happen in this file.

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/services_prefs_employee.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s12_create_notification_mobile/presentation/controller/sla_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

part 'sla_screen_mobile_sections.dart';

part 'sla_screen_mobile_part2.dart';

class SlaScreenMobile extends StatefulWidget {
  const SlaScreenMobile({super.key, this.editingModel});

  final ServicesHistoryModel? editingModel;

  @override
  State<SlaScreenMobile> createState() => _SlaScreenMobileState();
}
