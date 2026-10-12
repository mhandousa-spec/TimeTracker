/// Module: services_app_module/core
///
/// FILE INFO
/// File Name   : picker_helper.dart
/// Objective   : Small pure helpers around picker-related lookups.
///               NOTE: file/image picking now lives in
///               core/services/media_picker_service.dart — FilePicker must
///               never be called from a helper (§16, §21).
library;

import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';

abstract class PickerHelper {
  /// Localised department names for dropdowns/filters.
  static List<String> get departments {
    return [
      S.current.all.toLowerCase(),
      ...Get.find<MainCoreDepartmentCubit>().departmentModels.map((e) =>
          (Get.locale?.languageCode == 'en')
              ? FormatHelper.capitalize(e.departmentName!)
              : e.departmentNameInArabic!)
    ];
  }
}
