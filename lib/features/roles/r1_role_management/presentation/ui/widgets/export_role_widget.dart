/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: export_role_widget.dart
/// Purpose: Declares `RoleExportDialog`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - A finished export now ends on the app's shared success
///                      dialog (CustomDialogManager) instead of a bare
///                      Material AlertDialog.
/// Updated: 8/9/2026  - "Export does not work, nothing downloads": every
///                      failure was reported on a SnackBar painted UNDER this
///                      dialog's own modal barrier, so the button looked inert.
///                      Messages are dialogs now. A dismissed system save sheet
///                      (phones) is treated as neither success nor failure, and
///                      the desktop success message names the written file.

import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';

// REMOVED 25/8/2026: `success_dialog.dart` — its static `show()` was the
// AlertDialog this screen no longer uses. The SuccessDialog *widget* itself is
// unrelated and still used elsewhere.
// ADDED 8/9/2026: `defaultTargetPlatform` (used by _showExportSuccess to decide
// whether a saved path is worth naming) lives in foundation, not material.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
// ADDED 8/9/2026: the in-row export spinner — see the button row in build().
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';


import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';

class RoleExportDialog extends StatefulWidget {
  final List<RoleHistoryModel> roles;

  const RoleExportDialog({
    Key? key,
    required this.roles,
  }) : super(key: key);

  @override
  State<RoleExportDialog> createState() => _RoleExportDialogState();
}

class _RoleExportDialogState extends State<RoleExportDialog> {
  final TextEditingController controller = TextEditingController();
  // REMOVED 8/9/2026: `_overlayEntry` — the full-screen loading overlay it held
  // is gone; the wait is drawn in the button row instead.
  bool _isExporting = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller.text.isEmpty) {
      controller.text = _getDefaultFileName(context);
    }
  }

  String _getDefaultFileName(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        "${now.day} ${_getMonthName(context, now.month)} ${now.year}";
    return "${S.of(context).rolesExport}_$dateStr";
  }

  String _getMonthName(BuildContext context, int month) {
    final s = S.of(context);
    return [
      s.jan,
      s.feb,
      s.mar,
      s.apr,
      s.may,
      s.jun,
      s.jul,
      s.aug,
      s.sep,
      s.oct,
      s.nov,
      s.dec,
    ][month - 1];
  }

  /// How long the in-row spinner stays up at minimum.
  ///
  /// ADDED 8/9/2026. A small export finishes in a few milliseconds, so the
  /// spinner would appear and vanish inside one frame and the dialog would look
  /// like it did nothing at all — the exact complaint this whole flow keeps
  /// producing. Holding it briefly makes the write legible as an action that
  /// ran. It is a floor, never a delay added to a slow export.
  static const Duration _minimumProgressDuration = Duration(milliseconds: 700);

  /// REMOVED 8/9/2026: `_showLoadingIndicator` / `_hideLoadingIndicator`, a
  /// full-screen `OverlayEntry` with its own modal barrier. It dimmed the whole
  /// app and put the spinner in the middle of the screen, far from the button
  /// the user had just pressed. The wait is now shown IN the button row itself
  /// (see build()), which is where the user is already looking; the buttons
  /// disappear while it runs, so there is nothing left to double-tap and the
  /// barrier has nothing to protect.

  /// Lottie shown beside a blocking validation message.
  static const String _warningLottie =
      'assets/lottie_assets/main_lottie_assets/warning.json';

  /// Lottie shown when the export itself failed.
  static const String _errorLottie =
      'assets/lottie_assets/main_lottie_assets/error.json';

  /// Shows a message ON TOP of this dialog.
  ///
  /// REPLACED 8/9/2026 — this was a floating SnackBar via `ScaffoldMessenger`.
  /// A SnackBar is painted by the Scaffold, which sits BELOW this route: with
  /// the export dialog open — and its `barrierDismissible: false` barrier
  /// dimming everything under it — the message came up behind the barrier,
  /// greyed and mostly hidden. So every failure this reports (empty file name,
  /// no roles, and above all the export itself failing) looked like the Export
  /// button doing nothing at all, which is how the bug was reported.
  ///
  /// [CustomDialogManager.showMessage] pushes on the ROOT navigator, so it
  /// stacks above this dialog and has to be acknowledged.
  Future<void> _showMessage(
    BuildContext context, {
    required String title,
    required String message,
    required String lottiePath,
  }) {
    return CustomDialogManager.showMessage(
      context: Navigator.of(context, rootNavigator: true).context,
      lottiePath: lottiePath,
      title: title,
      subtitle: message,
    );
  }

  /// Writes the CSV export.
  ///
  /// The filesystem write and its `try/catch` moved to
  /// `RoleCubit.exportRolesToCsv` — §11.2 forbids try/catch in widgets. This
  /// method now only drives the UI: validate, show progress, react to the
  /// Either the cubit returns.
  Future<void> _exportData(BuildContext context) async {
    if (_isExporting) return;

    setState(() {
      _submitted = true;
    });

    final fileName = controller.text.trim();
    if (fileName.isEmpty) {
      await _showMessage(
        context,
        title: S.of(context).error,
        message: S.of(context).pleaseEnterAFileName,
        lottiePath: _warningLottie,
      );
      return;
    }

    if (widget.roles.isEmpty) {
      await _showMessage(
        context,
        title: S.of(context).noData,
        message: S.of(context).noRolesToExport,
        lottiePath: _warningLottie,
      );
      return;
    }

    // The spinner replaces the buttons from here until the write returns.
    setState(() {
      _isExporting = true;
    });
    final DateTime progressShownAt = DateTime.now();

    final String csvContent = _generateCSVContent(context);
    // The shared cubit, not `context.read`: this dialog is pushed onto the
    // root overlay, so it is not guaranteed to sit under the page's
    // BlocProvider.
    final result = await roleCubit.exportRolesToCsv(
      fileName: fileName,
      csvContent: csvContent,
    );

    // Hold the spinner for the rest of its minimum, if the write beat it.
    final Duration elapsed = DateTime.now().difference(progressShownAt);
    if (elapsed < _minimumProgressDuration) {
      await Future<void>.delayed(_minimumProgressDuration - elapsed);
    }

    if (!mounted) return;

    setState(() {
      _isExporting = false;
    });

    // The success branch is async, so `fold` (which discards what its callbacks
    // return) would drop the await. Reading the error out first keeps the two
    // outcomes readable and lets the success path be awaited properly.
    final String? error = result.fold(
      (String message) => message,
      (String _) => null,
    );

    if (error != null) {
      await _showMessage(
        context,
        title: S.of(context).exportFailed,
        message: '${S.of(context).error}: $error',
        lottiePath: _errorLottie,
      );
      return;
    }

    // ADDED 8/9/2026 — on phones the destination now comes from the system save
    // sheet, and the user can dismiss it. That is neither a success nor a
    // failure: nothing was written, so this dialog simply stays open for
    // another try. Desktop never returns this.
    final String savedPath = result.fold(
      (String _) => RoleCubit.exportCancelled,
      (String path) => path,
    );
    if (savedPath == RoleCubit.exportCancelled) return;

    await _showExportSuccess(context, savedPath);
  }

  /// Close the export dialog, then show the app's own success dialog.
  ///
  /// REPLACED 25/8/2026 — this used to call `SuccessDialog.show(context)`, a
  /// bare Material `AlertDialog` with a title and an OK button. It looked like
  /// nothing else in the app: every other confirmed action in the roles module
  /// ends on [CustomDialogManager]'s success dialog — the Lottie tick, the app
  /// typography, auto-dismissing after ~1.5s — and that is what runs here now.
  ///
  /// The strings and the navigator are resolved BEFORE the pop. Once this
  /// dialog is gone its `context` is defunct, and both `S.of()` and
  /// `showDialog()` would then be reading a dead element — which is why the old
  /// code's `SuccessDialog.show(context)` ran on a context that had just been
  /// popped out from under it.
  ///
  /// ADDED 8/9/2026 — on desktop the destination is chosen for the user (the
  /// Downloads folder), so the success message names the file it just wrote.
  /// "It said success and I found nothing" is the whole history of this
  /// feature. On phones the user picked the destination in the system sheet and
  /// the returned path is an opaque content URI, so it is left out there.
  Future<void> _showExportSuccess(BuildContext context, String savedPath) async {
    final BuildContext rootContext =
        Navigator.of(context, rootNavigator: true).context;
    final String successTitle = S.of(context).success;
    final bool isPhonePlatform =
        defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
    final String successSubtitle = isPhonePlatform || savedPath.isEmpty
        ? S.of(context).exportSuccess
        : '${S.of(context).exportSuccess}\n$savedPath';

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    await CustomDialogManager.showSuccess(
      context: rootContext,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/approved.json',
      title: successTitle,
      subtitle: successSubtitle,
    );
  }

  String _generateCSVContent(BuildContext context) {
    final s = S.of(context);
    List<List<dynamic>> rows = [
      [
        'No',
        s.roleName,
        s.roleNameArabic,
        s.roleDescription,
        s.roleDescriptionArabic,
        s.status,
        s.createdBy,
        s.createdAt,
        s.moduleName,
      ],
    ];

    int rowNumber = 1;
    for (var role in widget.roles) {
      // REMOVED 29/8/2026: the Master Admin role must never appear in an
      // export — same guard the table view already applies.
      if (_isMasterAdminRole(role)) {
        continue;
      }
      List<String> selectedModules = role.currentSelectedModules;
      String createdByName = _extractNameFromEmail(role.currentCreatedBy);

      if (selectedModules.isEmpty) {
        rows.add([
          rowNumber,
          _safeString(role.currentRoleName),
          _safeString(role.currentRoleNameAr),
          _safeString(role.currentRoleDescription),
          _safeString(role.currentRoleDescriptionAr),
          _safeString(role.currentStatus.name),
          _safeString(createdByName),
          _formatDate(context, role.currentCreatedAt.toDate()),
          '-',
        ]);
        rowNumber++;
      } else {
        for (var moduleName in selectedModules) {
          rows.add([
            rowNumber,
            _safeString(role.currentRoleName),
            _safeString(role.currentRoleNameAr),
            _safeString(role.currentRoleDescription),
            _safeString(role.currentRoleDescriptionAr),
            _safeString(role.currentStatus.name),
            _safeString(createdByName),
            _formatDate(context, role.currentCreatedAt.toDate()),
            _safeString(_formatModuleName(moduleName)),
          ]);
          rowNumber++;
        }
      }
    }

    return _convertToCSV(rows);
  }

  String _extractNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return '';
    String username = email.split('@').first;
    username = username
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
    username = username.replaceAll(RegExp(r'\d'), '');
    List<String> words =
    username.split(' ').where((word) => word.isNotEmpty).toList();
    return words
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  /// Whether [role] is the built-in Master Admin role, which is excluded from
  /// exports. Mirrors the guard in `table_widget.dart`.
  bool _isMasterAdminRole(RoleHistoryModel role) {
    final String roleName = role.currentRoleName.toLowerCase().trim();
    final String roleNameAr = role.currentRoleNameAr.toLowerCase().trim();
    final String roleId = role.roleId.toLowerCase();
    return roleName == 'master admin' ||
        roleName == 'masteradmin' ||
        roleName == 'admin' ||
        roleNameAr == 'مسؤول رئيسي' ||
        roleNameAr == 'مدير النظام' ||
        roleId == 'master_admin' ||
        roleId == 'masteradmin';
  }

  String _formatModuleName(String moduleName) {
    return moduleName
        .split('_')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1)}'
        : '')
        .join(' ');
  }

  String _formatDate(BuildContext context, DateTime date) {
    // FIXED 29/8/2026: was `day <localized-month> year hh:mm`, which in Arabic
    // produced an Arabic month beside Latin digits — a mixed AR/EN cell. The
    // CSV date is now a single consistent English form, e.g. "25 Feb 2023".
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    String str = value.toString();
    if (str.contains(',') || str.contains('"') || str.contains('\n')) {
      str = '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  String _convertToCSV(List<List<dynamic>> rows) {
    StringBuffer csvBuffer = StringBuffer();
    for (List<dynamic> row in rows) {
      csvBuffer.writeln(row.join(','));
    }
    return csvBuffer.toString();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    // FIXED 29/8/2026: the file-name field was hard-forced to LTR / start, so
    // the Arabic default name rendered left-aligned in AR mode. It now follows
    // the active locale.
    final bool isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        width: 411.sp,
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: CustomSvgImage(assetPath: 
                      "assets/icons_assets/main_icons_assets/export_arrow.svg",
                      width: 16.sp,
                      height: 16.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                Text(
                  S.of(context).exportRoles,
                  style: StyleText.fontSize16Weight600,
                ),
              ],
            ),
            SizedBox(height: 15.sp),
            CustomTextField(
              label: S.of(context).fileName,
              hint: S.of(context).enterFileName,
              controller: controller,
              onChanged: (_) => setState(() {}),
              textDirection:
                  isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isArabic ? TextAlign.right : TextAlign.start,
            ),
            SizedBox(height: 15.sp),
            // PROGRESS 8/9/2026: while the CSV is being written, Discard and
            // Export CSV are replaced IN PLACE by the app's shared
            // CircleProgressMaster. The SizedBox pins the row to the button
            // height so the dialog does not resize mid-export, and the
            // FittedBox lets the spinner (which sizes itself off the screen
            // height) settle into that row on any device.
            SizedBox(
              height: 38,
              child: _isExporting
                  ? const Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CircleProgressMaster(),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customButton(
                          width: context.isPhone ? 120.sp : 150.sp,
                          title: S.of(context).discard,
                          function: () => Navigator.pop(context),
                          height: 38,
                          color: lightMode
                              ? AppColors.lightGrey
                              : AppColors.darkGrey,
                          textStyle: StyleText.fontSize14Weight400.copyWith(
                            color: lightMode
                                ? AppColors.black
                                : AppColors.white,
                          ),
                        ),
                        Spacer(),
                        customButton(
                          width: context.isPhone ? 120.sp : 150.sp,
                          title: S.of(context).exportCsv,
                          function: () => _exportData(context),
                          height: 38,
                          color: AppColors.primary,
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}