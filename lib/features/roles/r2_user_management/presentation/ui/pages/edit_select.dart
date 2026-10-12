/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: edit_select.dart
/// Purpose: Declares `EditAccessDetails`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Access dates now render in Arabic (month + numerals).

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/localized_digits.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
class EditAccessDetails extends StatefulWidget {
  const EditAccessDetails({super.key});

  @override
  State<EditAccessDetails> createState() => _EditAccessDetailsState();
}

class _EditAccessDetailsState extends State<EditAccessDetails> {
  late TextEditingController _grantedDateController;
  late TextEditingController _revokedDateController;
  String? _selectedRole;

  final DatePicker _datePicker = DatePicker();

  @override
  void initState() {
    super.initState();
    _grantedDateController = TextEditingController();
    _revokedDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    try {
      final userAccessCubit = context.read<UserManagementAccessCubit>();

      if (userAccessCubit.newAccessSelectedRole != null &&
          userAccessCubit.newAccessSelectedRole!.isNotEmpty) {
        setState(() {
          _selectedRole = userAccessCubit.newAccessSelectedRole!;
        });
      }

      if (userAccessCubit.accessGranted != null) {
        setState(() {
          _grantedDateController.text = _formatDateForDisplay(
              userAccessCubit.accessGranted!,
              isArabic: _isArabic);
        });
      }

      if (userAccessCubit.accessRevoked != null) {
        setState(() {
          _revokedDateController.text = _formatDateForDisplay(
              userAccessCubit.accessRevoked!,
              isArabic: _isArabic);
        });
      }
    } catch (e, stackTrace) {
      // Was an empty `catch {}` — the date fields silently stayed blank.
      debugPrint('edit_select: prefilling access dates failed: $e\n$stackTrace');
    }
  }

  @override
  void dispose() {
    _grantedDateController.dispose();
    _revokedDateController.dispose();
    super.dispose();
  }

  // ── Returns EN role names sorted alphabetically ──────────────────────────
  List<String> _getSortedRolesEn() {
    try {
      final roles = context.read<RoleCubit>().roles;
      if (roles.isEmpty) return [];
      return roles
          .map((r) => r.currentRoleName)
          .where((name) => name.isNotEmpty)
          .toList()
        ..sort((a, b) => a.compareTo(b));
    } catch (e) {
      return [];
    }
  }

  // ── Returns AR role names in the SAME order as _getSortedRolesEn ─────────
  List<String> _getSortedRolesAr() {
    try {
      final roles = context.read<RoleCubit>().roles;
      if (roles.isEmpty) return [];
      final sorted = roles
          .where((r) => r.currentRoleName.isNotEmpty)
          .toList()
        ..sort((a, b) => a.currentRoleName.compareTo(b.currentRoleName));
      return sorted.map((r) => r.currentRoleNameAr).toList();
    } catch (e) {
      return [];
    }
  }

  /// Whether the app is currently in Arabic.
  ///
  /// `build` reads the same thing from its own builder context; this getter is
  /// for the paths that run outside it — `_initializeControllers`, which fires
  /// from a post-frame callback.
  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  /// The date as the user should read it, in the active language.
  ///
  /// LOCALIZED 25/8/2026: this hardcoded an English month table and Western
  /// digits, so both date fields read "Aug 22, 2026" inside an otherwise fully
  /// Arabic dialog. Arabic now gets Arabic month names AND Arabic-Indic
  /// numerals ("٢٢ أغسطس ٢٠٢٦").
  ///
  /// DISPLAY ONLY — and that is what makes the change safe. What gets SAVED is
  /// the `DateTime` in the cubit (`accessGranted` / `accessRevoked`);
  /// `_onSaveTapped` pops those, and `employee_details_methods2` serialises
  /// them with an explicit 'en' format because the stored string is on-disk
  /// vocabulary that every reader parses back. Nothing parses the text held in
  /// these two controllers.
  String _formatDateForDisplay(DateTime date, {required bool isArabic}) {
    if (!isArabic) {
      return DateFormat('MMM d, y', 'en').format(date);
    }

    // `LocalizedDigits` only rewrites ASCII digits, so it is a no-op on
    // anything the 'ar' date symbols already rendered in Arabic-Indic
    // numerals — safe either way.
    return LocalizedDigits.apply(
      DateFormat('d MMMM y', 'ar').format(date),
      'ar',
    );
  }

  Future<DateTime?> _openDatePicker({DateTime? currentDate}) async {
    final result = await _datePicker.showDatePicker(
      context,
      [currentDate],
      currentDate ?? DateTime.now(),
      CalendarDatePicker2Type.single,
    );
    if (result != null && result.isNotEmpty && result.first != null) {
      return result.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
      builder: (context, state) {
        final userAccessCubit = context.read<UserManagementAccessCubit>();
        final isArabic = Localizations.localeOf(context).languageCode == 'ar';

        // ── Role lists ────────────────────────────────────────────────────
        final rolesEn = _getSortedRolesEn();
        final rolesAr = _getSortedRolesAr();

        return Padding(
          padding: EdgeInsets.all(15.sp),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Access Revoked Date ───────────────────────────────────
                Text(
                  isArabic ? 'تاريخ إلغاء الوصول' : 'Access Revoked Date',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 8.h),

                GestureDetector(
                  onTap: () async {
                    final pickedDate = await _openDatePicker(
                      currentDate: userAccessCubit.accessRevoked,
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _revokedDateController.text =
                            _formatDateForDisplay(pickedDate,
                                isArabic: isArabic);
                        userAccessCubit.accessRevoked = pickedDate;
                      });
                      userAccessCubit.emit(UserPermissionsDataLoaded());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColors.background,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _revokedDateController.text.isNotEmpty
                                ? _revokedDateController.text
                                : (isArabic ? 'اختر تاريخًا' : 'Select a date'),
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: _revokedDateController.text.isNotEmpty
                                  ? AppColors.text
                                  : AppColors.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        CustomSvgImage(
                          assetPath: 'assets/icons_assets/roles_assets/calendar.svg',
                          width: 15.w,
                          height: 15.h,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                // ── Access Granted Date ───────────────────────────────────
                Text(
                  isArabic ? 'تاريخ منح الوصول' : 'Access Granted Date',
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 8.h),

                GestureDetector(
                  onTap: () async {
                    final pickedDate = await _openDatePicker(
                      currentDate: userAccessCubit.accessGranted,
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _grantedDateController.text =
                            _formatDateForDisplay(pickedDate,
                                isArabic: isArabic);
                        userAccessCubit.accessGranted = pickedDate;
                      });
                      userAccessCubit.emit(UserPermissionsDataLoaded());
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColors.background,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _grantedDateController.text.isNotEmpty
                                ? _grantedDateController.text
                                : (isArabic ? 'اختر تاريخًا' : 'Select a date'),
                            style: StyleText.fontSize12Weight500.copyWith(
                              color: _grantedDateController.text.isNotEmpty
                                  ? AppColors.text
                                  : AppColors.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        CustomSvgImage(
                          assetPath: 'assets/icons_assets/roles_assets/calendar.svg',
                          width: 15.w,
                          height: 15.h,
                          fit: BoxFit.fill,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                // ── Role Dropdown ─────────────────────────────────────────
                CustomDropdown<String>(
                  label: isArabic ? 'نوع الدور' : 'Role Type',
                  hint: isArabic ? 'اختر دورًا' : 'Select role',
                  labelStyle: StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  hintStyle: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  // Items are always EN keys (used for storage & matching)
                  items: rolesEn.map((role) {
                    final index = rolesEn.indexOf(role);
                    final label =
                        (isArabic && index >= 0 && index < rolesAr.length)
                            ? rolesAr[index]
                            : role;
                    return DropdownItem<String>(value: role, label: label);
                  }).toList(),
                  // Value is always the EN key
                  value: _selectedRole,
                  required: false,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                      userAccessCubit.newAccessSelectedRole = value;
                    });
                    userAccessCubit.emit(UserPermissionsDataLoaded());
                  },
                  itemStyle: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.text,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                  fillColor: AppColors.background,
                  triggerPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}