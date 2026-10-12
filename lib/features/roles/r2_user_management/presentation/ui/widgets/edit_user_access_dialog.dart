/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: edit_user_access_dialog.dart
/// Purpose: Part of the user-management feature.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/grc/core/widgets/custom_botton.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/roles/r2_user_management/domain/entities/user_permission_entity.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import '../pages/edit_select.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
/// Shows the Edit User Access Dialog
/// Returns Map<String, dynamic> with 'role', 'accessGranted', 'accessRevoked' on success
/// Returns null on discard
Future<dynamic> showEditUserAccessDialog({
  required BuildContext context,
  required UserPermissionEntity userPermission,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<UserManagementAccessCubit>()),
        BlocProvider.value(value: context.read<RoleCubit>()),
      ],
      child: _EditUserAccessDialogContent(
        userPermission: userPermission,
      ),
    ),
  );
}

class _EditUserAccessDialogContent extends StatefulWidget {
  final UserPermissionEntity userPermission;

  const _EditUserAccessDialogContent({required this.userPermission});

  @override
  State<_EditUserAccessDialogContent> createState() =>
      _EditUserAccessDialogContentState();
}

class _EditUserAccessDialogContentState
    extends State<_EditUserAccessDialogContent> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final controller = context.read<UserManagementAccessCubit>();
      final roleCubit = context.read<RoleCubit>();

      final activeRoles = roleCubit.roles
          .where((r) => r.currentStatus == RoleStatus.active)
          .toList();

      // ── One entry per role ────────────────────────────────────────────
      //
      // FIXED 28/8/2026: the Role Type dropdown listed some roles TWICE
      // ("مراجعة سياسات الامتثال" appeared twice).
      //
      // `roleCubit.roles` is the concatenation of two Firestore collections —
      // `RoleRepository.getUnDeletedRoles` reads `Subscription_Admin` and then
      // `Roles`, appending both to one list with no de-duplication — so a role
      // present in both arrives here twice, and both copies are active.
      //
      // De-duplicating on the ROLE NAME (not the document id) is what this
      // dropdown needs, and it loses nothing: the value this dialog returns is
      // the name itself — `_onSaveTapped` pops `newAccessSelectedRole`, which
      // is handed to `updateUserPermission(accessName: ...)`. Two entries with
      // the same name therefore save the identical value; keeping both only
      // gives the user an indistinguishable second line to pick from. The
      // first occurrence wins, so the paired `rolesNameAr` entry stays aligned
      // with its English name (access_details.dart pairs them by index).
      final Set<String> seenRoleNames = <String>{};
      final List<String> uniqueRolesName = <String>[];
      final List<String> uniqueRolesNameAr = <String>[];

      for (final role in activeRoles) {
        final String name = role.currentRoleName.trim();
        if (name.isEmpty) continue;
        if (!seenRoleNames.add(name.toLowerCase())) continue;

        uniqueRolesName.add(role.currentRoleName);
        uniqueRolesNameAr.add(role.currentRoleNameAr);
      }

      controller.rolesName = uniqueRolesName;
      controller.rolesNameAr = uniqueRolesNameAr;

      if (widget.userPermission.accessName != null) {
        controller.newAccessSelectedRole = widget.userPermission.accessName;
      }

      if (widget.userPermission.startDate != null &&
          widget.userPermission.startDate!.isNotEmpty &&
          widget.userPermission.startDate != '-') {
        final parsed = _parseDate(widget.userPermission.startDate!);
        if (parsed != null) controller.accessGranted = parsed;
      }

      if (widget.userPermission.endDate != null &&
          widget.userPermission.endDate!.isNotEmpty &&
          widget.userPermission.endDate != '-') {
        final parsed = _parseDate(widget.userPermission.endDate!);
        if (parsed != null) controller.accessRevoked = parsed;
      }

      controller.emit(UserPermissionsDataLoaded());

      // 9/10/2026 — the user limits, so Save can refuse a role this user
      // cannot be given before the dialog closes.
      controller.loadLicenceUsage();
    });
  }

  DateTime? _parseDate(String dateString) {
    if (dateString.isEmpty || dateString == '-') return null;

    String normalized = dateString;
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const westernNums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < arabicNums.length; i++) {
      normalized = normalized.replaceAll(arabicNums[i], westernNums[i]);
    }

    try {
      if (normalized.contains('T') ||
          (normalized.contains('-') && !normalized.contains(' '))) {
        return DateTime.parse(normalized);
      }

      if (normalized.contains('/')) {
        final parts = normalized.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }

      if (normalized.contains(' ')) {
        final formats = [
          'dd MMM yyyy',
          'MMM dd, yyyy',
          'dd MMMM yyyy',
          'MMMM dd, yyyy',
          'MMM dd yyyy',
        ];
        for (final fmt in formats) {
          try {
            return DateFormat(fmt, 'en').parse(normalized);
          } catch (_) {}
        }

        final arabicMonths = {
          'يناير': 1, 'فبراير': 2, 'مارس': 3, 'أبريل': 4,
          'مايو': 5, 'يونيو': 6, 'يوليو': 7, 'أغسطس': 8,
          'سبتمبر': 9, 'أكتوبر': 10, 'نوفمبر': 11, 'ديسمبر': 12,
        };
        for (final entry in arabicMonths.entries) {
          if (normalized.contains(entry.key)) {
            final cleaned = normalized
                .replaceAll(entry.key, '')
                .replaceAll(',', '')
                .trim();
            final parts = cleaned.split(RegExp(r'\s+'));
            if (parts.length == 2) {
              final nums = parts.map((p) => int.tryParse(p)).toList();
              if (nums[0] != null && nums[1] != null) {
                final day = nums[0]! < 100 ? nums[0]! : nums[1]!;
                final year = nums[0]! > 100 ? nums[0]! : nums[1]!;
                return DateTime(year, entry.value, day);
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('edit_user_access_dialog: date parse failed: $e\n$stackTrace');
    }

    return null;
  }

  void _onSaveTapped() {
    final controller = context.read<UserManagementAccessCubit>();
    final s = S.of(context);

    if (controller.newAccessSelectedRole == null ||
        controller.newAccessSelectedRole!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.pleaseSelectARoleType),   // ← use S.of(context) key
        backgroundColor: AppColors.red,
      ));
      return;
    }

    if (controller.accessGranted == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.pleaseSelectAccessGrantedDate),
        backgroundColor: AppColors.red,
      ));
      return;
    }

    if (controller.accessRevoked == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.pleaseSelectAccessRevokedDate),
        backgroundColor: AppColors.red,
      ));
      return;
    }

    // 9/10/2026 — user limits (Knowticed Admin). Re-checked inside the
    // transaction on save; this only spares the admin a round trip.
    final String? limitMessage = controller.limitMessageFor(
        <String>[widget.userPermission.employeeId],
        controller.newAccessSelectedRole!);
    if (limitMessage != null) {
      if (controller.licenceUsageFailed) controller.loadLicenceUsage();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(limitMessage),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 5),
      ));
      return;
    }

    setState(() => _isSaving = true);

    Future.microtask(() {
      if (!mounted) return;
      Navigator.of(context).pop({
        'role': controller.newAccessSelectedRole,
        'accessGranted': controller.accessGranted,
        'accessRevoked': controller.accessRevoked,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    // ── Detect locale direction ────────────────────────────────────────────
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textDir = isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: Dialog(
        backgroundColor: AppColors.transparent,
        child: Container(
          width: 330.w,
          // Taller by the header row added below (Role QA p.9).
          height: 340.h,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          // ── Pass hint color down via Theme so EditAccessDetails picks it up ──
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme:
              Theme.of(context).inputDecorationTheme.copyWith(
                hintStyle: TextStyle(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ────────────────────────────────────────────────
                // Role QA p.9: the dialog had no icon or title; it now opens
                // with the same badge + "Editing Access Details" header as the
                // User Access dialogs.
                Padding(
                  padding: EdgeInsetsDirectional.only(
                      start: 15.sp, end: 15.sp, top: 15.sp),
                  child: Row(
                    children: [
                      Container(
                        width: 30.sp,
                        height: 30.sp,
                        padding: EdgeInsets.all(6.sp),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: CustomSvgImage(
                          assetPath:
                              'assets/icons_assets/roles_assets/edit_access.svg',
                          fit: BoxFit.contain,
                          color: AppColors.textButton,
                        ),
                      ),
                      SizedBox(width: 10.sp),
                      Expanded(
                        child: Text(
                          S.of(context).editingAccessDetails,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize16Weight400
                              .copyWith(color: AppColors.text),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Form ──────────────────────────────────────────────────
                Expanded(
                  child: EditAccessDetails(),
                ),

                // ── Buttons ───────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Row(
                    children: [
                      if (!_isSaving)
                        customButton(
                          title: S.of(context).discard,
                          textStyle: StyleText.fontSize16Weight400.copyWith(
                            color: AppColors.blackButton,
                          ),
                          function: () => Navigator.pop(context),
                          color: AppColors.secondaryButton,
                          width: 135.w,
                          height: 38.h,
                        ),

                      const Spacer(),

                      if (_isSaving)
                        SizedBox(
                          width: 38.h,
                          height: 38.h,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        )
                      else
                        customButton(
                          title: S.of(context).save,
                          function: _onSaveTapped,
                          color: AppColors.primary,
                          width: 135.w,
                          height: 38.h,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}