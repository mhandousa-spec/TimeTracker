// ******************* FILE INFO *******************
// File Name: upload_file.dart
// Description: can make bulk upload of file by drag and drop here
// Module: services_management_module / presentation / s4_bulk_upload_services / ui / services_management_module
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';

import 'dart:io';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart' hide Border, BorderStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:desktop_drop/desktop_drop.dart';

import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';

import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/data_upload_upload_file_details_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'upload_file_part2.dart';

class UploadFileTablet extends StatefulWidget {
  const UploadFileTablet({super.key});

  @override
  State<UploadFileTablet> createState() => _UploadFileTabletState();
}
