/// Module: services_management_module
/// Description: Upload and edit data which come from bulk upload (Master
///              variant). uploadToFirebase() (now on UploadFileDetailsCubit)
///              returns Map<String, String> (serviceName -> docId) so Step 2
///              can use the real Firestore document IDs for
///              Parent_Service_Id.
/// Author: Amr Mesbah
/// Date: 2026-07-02
/// Dependencies: excel, permission_handler, MediaPickerService,
///               UploadFileDetailsCubit, UploadFileDetailsTable
/// Revision History:
///   - uploadToFirebase() changed return type from Future<void> to
///     Future<Map<String,String>>; returns serviceName -> firestoreDocId map.
///   - 2026-07-02 (Knowticed Team): Moved all Firestore writes into
///     UploadFileDetailsCubit and the row/header table rendering into
///     ui/widgets/upload_file_details_table.dart to bring this file under
///     the 800-LOC budget and remove direct .collection(/Timestamp usage
///     from the page (audit fix #1/#3).
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/presentation/ui/core_widgets/custom_buttons.dart';

import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/widgets/custom_excel_text_field.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
export 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/widgets/custom_excel_text_field.dart';
import 'dart:io';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/data_upload_upload_file_details_toggle.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/constants/master_upload_headers.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/domain/usecases/upload_file_row_validator.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/controller/upload_file_details_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/widgets/upload_file_details_table.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/widgets/upload_file_details_activate_flow.dart';

import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/upload_file_toggle.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'upload_file_details_part2.dart';

// ✅ FIX (bug report p14/p38 "use same check box in figma"): a second
// CustomCheckBox was declared here, shadowing the shared
// core/custom/23-custom_check_box.dart component with drifted values (20.sp
// instead of 22.sp, radius 6.r instead of 4.r, AppColors.grey border instead
// of secondaryText@50%, Icons.check instead of Icons.check_rounded).
//
// It had no references, so it is removed outright — screens in this feature use
// the shared component.

class UploadFileDetailsTabletMaster extends StatefulWidget {
  const UploadFileDetailsTabletMaster({
    super.key,
    required this.formData,
    required this.validationErrors,
    this.selectedFileName,
    this.onActivated,
  });

  final List<Map<String, TextEditingController>> formData;
  final List<Map<String, String>> validationErrors;
  final String? selectedFileName;

  /// Called after the user confirms activation.
  /// In master flow: receives uploadToFirebase fn — MasterUploadScreen stores it,
  /// defers execution until Step 2 confirms.
  /// The fn now returns Map<String, String> (serviceName → firestoreDocId).
  final Future<void> Function(Future<Map<String, String>> Function() uploadFn)? onActivated;

  @override
  State<UploadFileDetailsTabletMaster> createState() =>
      _UploadFileDetailsTabletMasterState();
}
