/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: access_details.dart
/// Purpose: Declares `AccessDetails`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 29/8/2026 - Role Type, Access Granted and Access Revoked now share
///          one label gap, one field height and one horizontal padding, so the
///          three read as a single row.

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/78-expanded_content.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/custom_drop_down.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';


import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Geometry the three Access Details fields share.
///
/// ADDED 29/8/2026. Role Type is a `CustomDropdown` while Access Granted and
/// Access Revoked are hand-rolled `Container`s in this file, and the three had
/// drifted apart on every axis at once: the dropdown sized itself from an 11
/// vertical padding while the dates were pinned to 36; the dropdown padded 12
/// horizontally and the dates 10; and their label gaps were 3 and 8. Three
/// fields, three heights, and labels and boxes all starting at a different y.
///
/// Raw, not `.sp` — `.sp` is applied at each point of use, and
/// `CustomDropdown.height` documents that it takes an UNSCALED value and scales
/// it internally, so a pre-scaled constant would be scaled twice there.
///
/// The label gap is deliberately not declared here: it is [kFieldLabelGap],
/// shared with `CustomDropdown` and `CustomDropdownCalendar`. A gap only this
/// screen agreed on is how these drifted in the first place.
const double _kAccessFieldHeight = 36;
const double _kAccessFieldHPadding = 10;

class AccessDetails extends StatefulWidget {
  AccessDetails({super.key});

  @override
  State<AccessDetails> createState() => _AccessDetailsState();
}

class _AccessDetailsState extends State<AccessDetails> {
  late UserManagementAccessCubit controller;

  /// Function Name: [_formatAccessDate]
  ///
  /// Purpose: An access date as the two fields below show it.
  ///
  /// ADDED 28/8/2026. Both fields formatted with
  /// `DateFormat('d MMM yyyy', 'ar')`, which translates the MONTH but leaves
  /// the day and the year in Latin digits — `intl` does no digit substitution
  /// of its own — so an Arabic session read "28 أغسطس 2026" with Western
  /// numerals. Arabic-Indic digits are what the rest of the app renders (see
  /// the character counters in the shared dialogs), so the formatted string is
  /// mapped over here.
  ///
  /// English is returned untouched.
  String _formatAccessDate(BuildContext context, DateTime date) {
    final bool isArabic = context.isArabic;
    final String formatted =
        DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en').format(date);

    if (!isArabic) return formatted;

    const List<String> western = <String>[
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ];
    const List<String> eastern = <String>[
      '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
    ];

    String result = formatted;
    for (int i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], eastern[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    controller = context.read<UserManagementAccessCubit>();
    bool isTablet = MediaQuery.of(context).size.width > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return ExpandedContent(
      title: S.of(context).accessDetails,
      content: BlocBuilder<UserManagementAccessCubit, UserManagementAccessState>(
        builder: (context, state) {
          return Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: (isTablet)
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 390.w, child: roleSelector()),


                // accessGranted
                SizedBox(
                    width: isPortrait ? 150.w : 390.w,
                    child: accessGranted(context)),
                // accessRevoked
                SizedBox(
                    width: isPortrait ? 150.w : 390.w,
                    child: accessRevoked(context))
              ],
            )
                : Column(
              children: [
                SizedBox(width: double.infinity, child: roleSelector()),
                SizedBox(height: 15.sp),
                SizedBox(
                    width: double.infinity,
                    child: accessGranted(context)),
                SizedBox(height: 15.sp),
                SizedBox(
                    width: double.infinity,
                    child: accessRevoked(context))
              ],
            ),
          );
        },
      ),
    );
  }

    Widget roleSelector() {

    // Build roles list filtering out 'master admin'
    //
    // ── One entry per role ────────────────────────────────────────────────
    //
    // FIXED 28/8/2026: this dropdown listed some roles TWICE ("Compliance
    // Policy Review" appeared twice).
    //
    // `rolesName` is filled from `RoleCubit.roles`, which is the concatenation
    // of two Firestore collections — `RoleRepository.getUnDeletedRoles` reads
    // `Subscription_Admin` and then `Roles` and appends both to one list with
    // no de-duplication — so a role present in both arrives here twice. Both
    // callers that populate `rolesName` hand it straight over:
    // `initNewAccessController` (the Access button on user_management_home)
    // and the edit dialog.
    //
    // The guard lives HERE, at the point of render, so it holds no matter
    // which of those filled the list. De-duplicating on the name is what this
    // dropdown needs and loses nothing: the value it stores is
    // `newAccessSelectedRole`, the role NAME itself, so two entries with the
    // same name select the identical value — the second line is an
    // indistinguishable duplicate. First occurrence wins, which also keeps the
    // Arabic pairing below (matched by `indexOf`) pointing at the same record.
    // TIGHTENED 21/9/2026 — the list still showed "Compliance Policy Review"
    // twice. The old key was `trim().toLowerCase()`, which misses names that
    // differ only in inner whitespace (double / non-breaking spaces) or in an
    // invisible character — two role documents that render identically. The
    // key now collapses every run of whitespace and drops zero-width marks.
    //
    // When two names collide, the one the employee currently HOLDS wins:
    // `newAccessSelectedRole` is matched by exact string, so dropping that
    // spelling would leave the dropdown with a value no row carries.
    final String? current = controller.newAccessSelectedRole;
    final List<String> filteredRoles = [];
    final Map<String, int> indexByKey = <String, int>{};

    for (int i = 0; i < controller.rolesName.length; i++) {
      final String enName = controller.rolesName[i];
      final String key = _roleNameKey(enName);
      if (key.isEmpty || key == 'master admin') continue;

      final int? existing = indexByKey[key];
      if (existing == null) {
        indexByKey[key] = filteredRoles.length;
        filteredRoles.add(enName);
      } else if (enName == current) {
        filteredRoles[existing] = enName;
      }
    }

    if (filteredRoles.isEmpty) {
      filteredRoles.add('No Roles');
    }

    // Get corresponding Arabic names
    List<String> filteredRolesAr = [];
    for (String enRole in filteredRoles) {
      int originalIndex = controller.rolesName.indexOf(enRole);
      if (originalIndex >= 0 && originalIndex < controller.rolesNameAr.length) {
        filteredRolesAr.add(controller.rolesNameAr[originalIndex]);
      } else {
        filteredRolesAr.add(enRole); // Fallback to EN if no AR available
      }
    }

    // Get current language
    bool isArabic = context.isArabic;

    return CustomDropdown<String>(
      label: isArabic ? 'نوع الدور' : 'Role Type',
      hint: isArabic ? 'اختر نوع الدور' : 'Select Role Type',
      items: filteredRoles.map((role) {
        int index = filteredRoles.indexOf(role);
        final label = (index >= 0 && index < filteredRolesAr.length)
            ? (isArabic ? filteredRolesAr[index] : role)
            : role;
        return DropdownItem<String>(value: role, label: label);
      }).toList(),
      value: controller.newAccessSelectedRole,
      onChanged: (selectedRole) {
        controller.newAccessSelectedRole = selectedRole;
        controller.emit(UserPermissionsDataLoaded());
      },
      fillColor: AppColors.background,
      itemStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.text,
      ),
      // `height`, not a vertical padding, is what pins the trigger to the same
      // box as the two date fields beside it — padding can only grow the input
      // area, never hold it to a target height (see `CustomDropdown._sized`).
      // With the height pinned, the vertical padding has nothing left to do.
      height: _kAccessFieldHeight,

      borderRadius: BorderRadius.circular(4.r),
      required: false,
    );
  }

  // REPLACED 29/8/2026 — both date fields were hand-rolled: an `InkWell` around
  // a `Container`, its own label `Text`, its own calendar SVG, and a direct call
  // to `DatePicker().showDatePicker`. `CustomDropdownCalendar` is the shared
  // widget for exactly this, and it is what the Role Type field beside them is
  // already a sibling of, so the three now share one label gap, one trigger
  // height and one inset by construction rather than by three call sites
  // agreeing on the same numbers.
  //
  // Behaviour kept: `firstDate: DateTime.now()` (no back-dating an access
  // window) and `_formatAccessDate`, which is what renders Arabic-Indic digits
  // — the widget's own default formatter does not.
  //
  // One deliberate difference: the placeholder now draws in the shared
  // `kDropdownHintColor` instead of `AppColors.text`, so "Select Access
  // Granted" reads as a placeholder rather than as a value, matching Role Type.

  Widget accessGranted(BuildContext context) {
    return _accessDateField(
      context,
      label: S.of(context).access_granted,
      hint: S.of(context).selectAccessGranted,
      value: controller.accessGranted,
      onPicked: (DateTime date) => controller.accessGranted = date,
    );
  }

  Widget accessRevoked(BuildContext context) {
    return _accessDateField(
      context,
      label: S.of(context).access_revoked,
      hint: S.of(context).selectAccessRevoked,
      value: controller.accessRevoked,
      onPicked: (DateTime date) => controller.accessRevoked = date,
    );
  }

  /// The two date fields differ only in their label, hint and which controller
  /// field they write, so they share one builder.
  Widget _accessDateField(
    BuildContext context, {
    required String label,
    required String hint,
    required DateTime? value,
    required void Function(DateTime) onPicked,
  }) {
    return CustomDropdownCalendar(
      label: label,
      labelStyle:
          StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
      hint: hint,
      value: value,
      firstDate: DateTime.now(),
      dateFormatter: (DateTime date) => _formatAccessDate(context, date),
      valueStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)
          .copyWith(color: AppColors.text),
      fillColor: AppColors.background,
      borderRadius: BorderRadius.circular(4.r),
      height: _kAccessFieldHeight,
      // contentPadding:
      //     EdgeInsets.symmetric(horizontal: _kAccessFieldHPadding.sp),
      onChanged: (DateTime? date) {
        if (date == null) return;
        onPicked(date);
        controller.emit(UserPermissionsDataLoaded());
      },
    );
  }
}

/// The de-duplication key for a role name: lower-case, every run of whitespace
/// (including non-breaking spaces) collapsed to one space, zero-width and
/// direction marks removed. See the note in `roleSelector`.
String _roleNameKey(String name) => name
    .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060\uFEFF]'), '')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim()
    .toLowerCase();
