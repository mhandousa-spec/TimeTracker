/// Module: settings/se1_profile
///
///*************************** FILE INFO ****************************///
/// File Name: personal_data.dart
/// Purpose: The PersonalData card — avatar, name row, and the gender / birth
///          date / marital status row.
/// Author: Mohamed Elrashidy
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE1-N05/N12/N15/N17: [ThreeTextSection] moved
///          to its own file and the unused `NationalitySection` deleted; the
///          date helpers (and their try/catch) moved to
///          data/utils/employee_date_formatter.dart; the widget takes a
///          [PersonalProfile] instead of reading the `employee` global; raw
///          Colors.* routed through AppColors.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/settings/se1_profile/data/utils/employee_date_formatter.dart';
import 'package:knowticed_plus/features/settings/se1_profile/domain/entities/personal_profile.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/controller/personal_information_controller.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/widgets/sections/name_section.dart';
import 'package:knowticed_plus/features/settings/se1_profile/presentation/ui/widgets/sections/three_text_section.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class PersonalData extends StatelessWidget {
  const PersonalData({
    super.key,
    required this.isReadOnly,
    required this.profile,
    required this.controller,
  });

  final bool isReadOnly;

  /// Everything this card displays. Previously read straight off the mutable
  /// `employee` global with force-unwraps (CR-SKEL-SE1-N17).
  final PersonalProfile profile;

  /// Where edits are recorded until the change request is submitted.
  final PersonalInformationController controller;

  @override
  Widget build(BuildContext context) {
    // NOT `ContextExtension(context).isPhone` / `context.isPhone`.
    //
    // This file imports core/helper/main_helper/extensions.dart, whose
    // extension is ALSO called ContextExtension — and its `isPhone` is
    //
    //     bool get isPhone => MediaQuery.of(this).size.width >= 600;
    //
    // i.e. true on WIDE screens, the exact inverse of
    // core/extensions/context_extensions.dart's `shortestSide < 600`. Same
    // name, same target type, opposite meaning, and the file's own comment
    // admits it. Every `isPhone` here was therefore reading FALSE on a phone.
    // Computed inline so it cannot bind to the wrong extension again.
    final bool isMobile = MediaQuery.of(context).size.shortestSide < 600;

    final String? genderKey =
        (controller.selectedGender ?? profile.gender)?.toLowerCase();

    final String? maritalKey =
        (controller.selectedMaritalStatus ?? profile.maritalStatus)
            ?.toLowerCase();

    final DateTime? birthDate = EmployeeDateFormatter.parse(
      controller.birthDate ?? profile.rawBirthDate,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(isMobile ? 8.r : 0.sp),
      ),
      child: Padding(
        // Mobile only: bottom padding so this reads as a closed card, the way
        // each section does on the edit page. Others keep the flush bottom.
        padding: EdgeInsets.only(
          top: 15.sp,
          right: 15.sp,
          left: 15.sp,
          bottom: isMobile ? 15.sp : 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),

            SizedBox(height: 20.sp),

            // ── First / middle / last name ──────────────────────────────────
            NameSection(
              isReadOnly: isReadOnly,
              firstNameHint: S.of(context).firstName,
              firstNameInitialValue: FormatHelper.localizedString(
                englishName: profile.firstName,
                arabicName: profile.firstNameInArabic,
              ),
              middleNameHint: S.of(context).middleName,
              middleNameInitialValue: FormatHelper.localizedString(
                englishName: profile.middleName,
                arabicName: profile.middleNameInArabic,
              ),
              lastNameHint: S.of(context).lastName,
              lastNameInitialValue: FormatHelper.localizedString(
                englishName: profile.lastName,
                arabicName: profile.lastNameInArabic,
              ),
              firstNameOnChanged: controller.firstNameOnChanged,
              middleNameOnChanged: controller.middleNameOnChanged,
              lastNameOnChanged: controller.lastNameOnChanged,
            ),

            // Mobile only: matches the 16.h the edit page uses between fields.
            SizedBox(height: isMobile ? 10.sp : 15.sp),
            // ── Gender / birth date / marital status ────────────────────────
            ThreeTextSection(
              isReadOnly: isReadOnly,
              genderValue: genderKey,
              genderHint: S.of(context).selectGender,
              onGenderChanged: (String value) =>
                  controller.selectedGender = value,
              birthDate: birthDate,
              birthDateHint: S.of(context).enterbirthday,
              // Stored in a machine-parsable form; the field itself renders the
              // locale-appropriate (Arabic-numeral) version.
              onBirthDateChanged: (DateTime? date) =>
                  controller.birthDate = EmployeeDateFormatter.toStorage(date),
              maritalStatusValue: maritalKey,
              maritalStatusHint: S.of(context).maritalStatus,
              onMaritalStatusChanged: (String value) =>
                  controller.selectedMaritalStatus = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    Widget placeholder() => SvgPicture.asset(
          'assets/icons_assets/main_icons_assets/male_avatar.svg',
          width: 64.r,
          height: 64.r,
          fit: BoxFit.cover,
        );

    return Row(
      children: [
        CircleAvatar(
          radius: 32.r,
          backgroundColor:
              profile.hasPhoto ? AppColors.transparent : AppColors.grey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.r),
            child: profile.hasPhoto
                ? Image.network(
                    profile.photoUrl!,
                    fit: BoxFit.cover,
                    width: 64.r,
                    height: 64.r,
                    errorBuilder: (_, __, ___) => placeholder(),
                  )
                : placeholder(),
          ),
        ),
      ],
    );
  }
}
