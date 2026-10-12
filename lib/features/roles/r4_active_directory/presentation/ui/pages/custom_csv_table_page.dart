/// Module: roles / r4_active_directory / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: custom_csv_table_page.dart
/// Purpose: Declares `CustomCsvTable`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart' hide AppLanguage;
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
// The shared chip filter behind the Users Data / Invalid Data tabs — see
// `_buildTabBar` in csv_table_builders1.dart.
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/generated/l10n.dart';
// ADDED 25/8/2026: the tab badges and the filter badge render their counts in
// the reader's numerals — see `_localizedCount` in csv_table_builders1.dart.
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/localized_digits.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/active_directory_controller.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/tabs/user_data_tab.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/tabs/wrong_data_tab.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
// ADDED 25/8/2026: the toolbar's Upload / Export / Restore / Edit buttons are
// gated on the Active Directory permissions — see the getters at the top of
// csv_table_builders1.dart.
import 'package:knowticed_plus/core/helper/role/roles_module_access.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/active_directory_permission.dart';
// ADDED 30/8/2026: the restore dialog draws one column per field, and the
// field list — with its English/Arabic header names — is this enum.
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';


part '../widgets/csv_table_builders1.dart';
part '../widgets/csv_table_builders2.dart';
part '../widgets/csv_export_dialog.dart';
part '../widgets/csv_export_preview.dart';
part '../widgets/csv_active_directory_filter_dialog.dart';
// ADDED 30/8/2026: Restore now previews the two backup collections before it
// overwrites Employees_Info — see csv_restore_dialog.dart.
part '../widgets/csv_restore_dialog.dart';

// ---------------------------------------------------------------------------
// Column index constants — derived from EmployeeDataItems enum order.
// 0:id  1:firstName  2:middleName  3:lastName
// 4:firstNameArabic  5:middleNameArabic  6:lastNameArabic
// 7:email  8:mobileCountryCode  9:mobileNumber
// 10:homeCountryCode  11:homeNumber  12:officeCountryCode  13:officeNumber
// 14:extension  15:gender  16:country  17:province  18:city
// 19:postalCode  20:street  21:language
// 22:departmentId  23:departmentEnglishName  24:departmentArabicName
// 25:supervisorEmail  26:role  27:englishTitle  28:arabicTitle
// 29:workLocation  30:none
// ---------------------------------------------------------------------------
class _ColumnIndex {
  static const int department   = 23;
  static const int role         = 26;
  static const int title        = 27;
  static const int workLocation = 29;
  static const int supervisor   = 25;
  static const int gender       = 15;
  static const int nationality  = -1; // not in CSV
  static const int country      = 16;
}

// ════════════════════════════════════════════════════════════════════════════
// MAIN WIDGET
// ════════════════════════════════════════════════════════════════════════════

/// Was `extends GetView<ActiveDirectoryController>`, whose inherited
/// `controller` getter is a GetX service-locator lookup. Now a plain
/// StatelessWidget resolving the same instance through the DI seam.
class CustomCsvTable extends StatelessWidget {
  /// The shared active-directory controller.
  ActiveDirectoryController get controller => AppControllers.activeDirectory;

  const CustomCsvTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return BlocBuilder<ActiveDirectoryController, ActiveDirectoryState>(
        bloc: AppControllers.activeDirectory,
        builder: (context, state) {
      final controller = AppControllers.activeDirectory;
      return controller.loadingData
          ? const Center(child: CircleProgressMaster())
          : Container(
        color: AppColors.background,
            child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            _buildHeader(controller, context, isVertical),
            Expanded(
              child: _buildTableArea(controller, context, isVertical),
            ),
            if (controller.isEditMode && controller.selectedIndex == 1)
              _buildEditBottomBar(controller, context),
                    ],
                  ),
          );
    });
  }
}
