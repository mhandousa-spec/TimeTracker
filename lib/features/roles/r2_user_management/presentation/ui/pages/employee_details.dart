/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details.dart
/// Purpose: Declares `RoleEmployeeDetailsPage`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Card dates and the module count use Arabic numerals.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/custom_button_with_image.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/edit_user_access_dialog.dart';
// REMOVED 25/8/2026: `dart:ui as ui` — its only use was the hardcoded
// `ui.TextDirection.ltr` in the chip width measurement, which now reads the
// ambient directionality instead.
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/permission_label.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/localized_digits.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
// ADDED 21/9/2026 — the role header's status label and colour (the same ones
// the User Management grid uses).
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/widgets/user_access_status_label.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/user_management_home.dart'
    show UserAccessStatusColor;
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_management_permission.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/widgets/access_grant_widget.dart';
// ADDED 28/8/2026 for the header's Chat button. `drawerCubit()` / `openInShell`
// are the hardened module-navigation helpers — see `_openMessages` in
// employee_details_methods4.dart for why they are used instead of context.read.
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';

import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:collection/collection.dart';
part '../widgets/employee_details_methods1.dart';
part '../widgets/employee_details_methods2.dart';
part '../widgets/employee_details_methods3.dart';
part '../widgets/employee_details_methods4.dart';

class RoleEmployeeDetailsPage extends StatefulWidget {
  final UserPermissionEntity userPermission;

  const RoleEmployeeDetailsPage({super.key, required this.userPermission});

  @override
  State<RoleEmployeeDetailsPage> createState() =>
      _RoleEmployeeDetailsPageState();
}

class _RoleEmployeeDetailsPageState extends State<RoleEmployeeDetailsPage> {
  final MainCoreEmployeeController employeeController =
  AppControllers.employee;

  EmployeeEntityPro? currentEmployeeEntity;

  bool _permissionsLoaded = false;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, List<String>> _modulePermissions = {};
  List<String> activeModuleStrings = [];

  // ── Shared month lists ────────────────────────────────────────────────────
  static const _enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _arMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];

  // ── Master date formatter ─────────────────────────────────────────────────
  /// Renders in the reader's language AND numerals:
  /// "24 Aug 2023" / "٢٤ أغسطس ٢٠٢٣".
  String _formatDate(String? rawDate, bool isArabic) {
    if (rawDate == null || rawDate.isEmpty || rawDate == '-') return '-';

    DateTime? parsed;
    try {
      // 1. ISO with T  e.g. "2023-08-24T10:30:00"
      if (rawDate.contains('T')) {
        parsed = DateTime.parse(rawDate);
      }
      // 2. Space-separated timestamp  e.g. "2026-01-09 16:20:58.514133"
      else if (rawDate.contains('-') && rawDate.contains(' ')) {
        parsed = DateTime.parse(rawDate.replaceFirst(' ', 'T'));
      }
      // 3. Pure date  e.g. "2023-08-24"
      else if (rawDate.contains('-') && !rawDate.contains(' ')) {
        parsed = DateTime.parse(rawDate);
      }
      // 4. dd/MM/yyyy
      else if (rawDate.contains('/')) {
        final parts = rawDate.split('/');
        if (parts.length == 3) {
          parsed = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      // 5. Already a readable string — try common EN formats
      else if (rawDate.contains(' ') || rawDate.contains(',')) {
        final formats = [
          'dd MMM yyyy',
          'MMM dd, yyyy',
          'dd MMMM yyyy',
          'MMMM dd, yyyy',
          'MMM dd yyyy',
          'dd MMM yyyy, hh:mm a',
        ];
        for (final fmt in formats) {
          try {
            parsed = DateFormat(fmt, 'en').parse(rawDate);
            break;
          } catch (_) {}
        }
      }
    } catch (_) {}

    if (parsed == null) return rawDate; // give up — return as-is

    // The month has always followed the locale; the DIGITS did not — this used
    // to be built "manually → always Western numerals", so an Arabic user read
    // "22 أغسطس 2026" with Latin figures in the middle of Arabic text.
    // CHANGED 25/8/2026: Arabic now gets Arabic-Indic numerals too.
    //
    // Display only. This formats `rawDate` for the screen; the stored value is
    // untouched, and the parser above still reads the 'en' on-disk format.
    final day   = parsed.day.toString().padLeft(2, '0');
    final month = isArabic
        ? _arMonths[parsed.month - 1]
        : _enMonths[parsed.month - 1];
    final year  = parsed.year.toString();
    final String formatted = '$day $month $year';

    return isArabic ? LocalizedDigits.apply(formatted, 'ar') : formatted;
  }

  @override
  void initState() {
    super.initState();
    RoleLogService.log(RoleLogService.pageEmployeeDetails);
    _loadEmployeeData();
    _initializePage();
  }












  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // FIXED 8/9/2026: see the note in `_buildContent` — a Scaffold on the
      // outside so the SafeArea's status-bar inset is painted, not black.
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => Navigator.pop(context),
          secondTitle: S.of(context).employeeDetails,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 200.h,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleProgressMaster(),
                  SizedBox(height: 16.sp),
                  Text(
                    S.of(context).loadingEmployeeDetails,
                    style: StyleText.fontSize16Weight400
                        .copyWith(color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      );
    }

    if (_errorMessage != null) {
      // FIXED 8/9/2026: see the note in `_buildContent` — a Scaffold on the
      // outside so the SafeArea's status-bar inset is painted, not black.
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).platformControlsAndManagement,
          onFirstTap: () => Navigator.pop(context),
          secondTitle: S.of(context).employeeDetails,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
                SizedBox(height: 16.sp),
                Text(S.of(context).errorLoadingData,
                    style: StyleText.fontSize16Weight400),
                SizedBox(height: 8.sp),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.sp),
                  child: Text(
                    _errorMessage!,
                    style: StyleText.fontSize12Weight400,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 16.sp),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _initializePage();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: Text(S.of(context).retry),
                ),
              ],
            ),
          ),
        ),
        ),
      );
    }

    return _buildContent();
  }













}
