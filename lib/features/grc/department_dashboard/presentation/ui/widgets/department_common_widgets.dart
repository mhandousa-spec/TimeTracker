/// Module: GRC / Dashboard Of All Departments
/// Description: Small pieces shared by the Departments tab and the Reporting
///              and Audit page: the Department / Policy / Control pickers
///              (CustomDropdown, core/custom/1), the white stat chips
///              ("Compliance Score 100"), and the score colour bands.
/// Author: Knowticed Plus team
/// Date: 2026-09-16
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/department_dashboard/domain/entities/department_dashboard_data.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Score colour bands used by the chart bars and the score cells:
/// 75+ green, 50–74 orange, below 50 red.
Color departmentScoreColor(double score) {
  if (score >= 75) return AppColors.green;
  if (score >= 50) return AppColors.orange;
  return AppColors.red;
}

/// Whole-number score text with the app's digit localisation.
String departmentScoreText(BuildContext context, double score) =>
    LocalizedNumber.digits(context, score.round().toString());

/// Value used in the pickers' item lists for "no filter".
const String kDepartmentAllValue = '';

/// Height (raw design number, apply `.sp`) of the Departments tab's
/// top controls on a phone: Dashboard, Department picker, Reporting and
/// Audit, Table | Analytics.
const double kDepartmentPhoneControlHeight = 33;

/// class name: [DepartmentPicker]
///
/// purpose: compact [CustomDropdown] with an "All" first entry. Choosing
///          "All" reports null, and a null value shows [hint] — so the
///          trigger reads "Department" / "Choose Policy" until something
///          real is picked, exactly as the design draws it.
class DepartmentPicker extends StatelessWidget {
  final String hint;
  final String? value;
  final List<DropdownItem<String>> items;
  final ValueChanged<String?> onChanged;
  final double width;
  final Color? fillColor;
  final bool includeAll;

  const DepartmentPicker({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 150,
    this.fillColor,
    this.includeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.sp,
      child: CustomDropdown<String>(
        hint: hint,
        value: value,
        // Raw value — CustomDropdown applies .sp. 33 on a phone.
        height: screenSizeOf(context) == ScreenSize.mobile
            ? kDepartmentPhoneControlHeight
            : 38,
        fillColor: fillColor ?? AppColors.card,
        enforceTypeScale: false,
        items: [
          if (includeAll)
            DropdownItem<String>(
              value: kDepartmentAllValue,
              label: S.of(context).all,
            ),
          ...items,
        ],
        onChanged: (v) => onChanged(v == kDepartmentAllValue ? null : v),
      ),
    );
  }

  /// Items for every department in [data].
  static List<DropdownItem<String>> departmentItems(
    BuildContext context,
    DepartmentDashboardData data,
  ) =>
      [
        for (final d in data.departments)
          DropdownItem<String>(value: d, label: grcTr(context, d)),
      ];

  /// Items for the policies in [department].
  static List<DropdownItem<String>> policyItems(
    BuildContext context,
    DepartmentDashboardData data,
    String? department,
  ) {
    final bool ar = context.isArabic;
    return [
      for (final p in data.policiesFor(department: department))
        DropdownItem<String>(
          value: p.id,
          label: ar && p.policyNameAr.trim().isNotEmpty
              ? p.policyNameAr
              : p.policyNameEn,
        ),
    ];
  }

  /// Items for the controls of [policyId] (all policies when null) in
  /// [department].
  static List<DropdownItem<String>> controlItems(
    BuildContext context,
    DepartmentDashboardData data,
    String? department,
    String? policyId,
  ) {
    final bool ar = context.isArabic;
    return [
      for (final r in data.controlsFor(department: department, policyId: policyId))
        DropdownItem<String>(
          value: r.control.id,
          label: ar && r.control.controlsNameAr.trim().isNotEmpty
              ? r.control.controlsNameAr
              : r.control.controlsNameEn,
        ),
    ];
  }
}

/// class name: [DepartmentStatChip]
///
/// purpose: "Compliance Score  100" — label in the secondary colour, value
///          after it, on a white (or grey, inside a card) rounded box.
class DepartmentStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Color? background;

  const DepartmentStatChip({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final TextStyle base = isMobile
        ? StyleText.fontSize14Weight400
        : StyleText.fontSize16Weight400.copyWith(fontSize: 20.sp);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: background ?? AppColors.card,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: base.copyWith(color: AppColors.secondaryText)),
          SizedBox(width: isMobile ? 10.sp : 20.sp),
          Text(
            value,
            style: base.copyWith(color: valueColor ?? AppColors.text),
          ),
        ],
      ),
    );
  }
}

/// class name: [DepartmentStatsRow]
///
/// purpose: Compliance Score / Applied Policies / Applied Controls for the
///          chosen department, wrapping onto a second line when narrow.
class DepartmentStatsRow extends StatelessWidget {
  final DepartmentDashboardData data;
  final String? department;
  final Color? chipBackground;

  const DepartmentStatsRow({
    super.key,
    required this.data,
    required this.department,
    this.chipBackground,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final double score = data.complianceScore(department: department);
    return Wrap(
      spacing: 15.sp,
      runSpacing: 10.sp,
      children: [
        DepartmentStatChip(
          label: s.complianceScore,
          value: departmentScoreText(context, score),
          valueColor: departmentScoreColor(score),
          background: chipBackground,
        ),
        DepartmentStatChip(
          label: s.appliedPolicies,
          value: LocalizedNumber.of(
              context, data.appliedPolicies(department: department)),
          background: chipBackground,
        ),
        DepartmentStatChip(
          label: s.appliedControls,
          value: LocalizedNumber.of(
              context, data.appliedControls(department: department)),
          background: chipBackground,
        ),
      ],
    );
  }
}
