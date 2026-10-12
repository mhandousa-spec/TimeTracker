// ******************* FILE INFO *******************
// File Name: sla_screen_page.dart
// Description: Main screen for SLA notification tablet view
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/sla_notification_state.dart';

import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/dialogs.dart';
// ADDED 26/8/2026 — ConfirmationDialog for the Save For Later prompt, and the
// draft-page constants for the Firebase draft write. See `initState` and
// `_confirmThenSaveForLater` in sla_screen_page_part2.dart.
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/details_switch_widgets.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/firebase_draft_repository.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/notification_section.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/sla_notification_widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';


import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/pages/details_switch_screen_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/sla_notification_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'sla_screen_page_part2.dart';

class SlaScreenPageTablet extends StatefulWidget {
  const SlaScreenPageTablet({super.key, this.editingModel});

  final ServicesHistoryModel? editingModel;

  @override
  State<SlaScreenPageTablet> createState() => _SlaScreenPageTabletState();
}
