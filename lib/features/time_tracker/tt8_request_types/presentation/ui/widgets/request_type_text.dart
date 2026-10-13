/// Module: time_tracker / tt8_request_types / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: request_type_text.dart
/// Purpose: Declares `RequestTypeText` — the localized values of one request
///          type shared by the card, the table, the details page and Export
///          — and `RequestTypeStatusText` (Active green · Inactive red ·
///          Removed grey).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Figma `661:35833` (card: HR Approval / Manager Approval "Required |
/// Not Required", Description / Attachments "Required | Optional") and
/// `661:36293` (table). The Figma column "Requested Name" is fixed to
/// "Request Name" (owner: fix every copy mistake). Dates "14 Apr 2024".

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/core/custom/24-custom_chart_card.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_table.dart';
import 'package:knowticed_plus/features/time_tracker/tt8_request_types/presentation/controller/request_types_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class RequestTypeText {
  const RequestTypeText._();

  static bool _ar(BuildContext context) => Localizations.localeOf(context).languageCode == 'ar';

  static String name(BuildContext context, RequestType t) => t.name(isArabic: _ar(context));

  static String required(BuildContext context, bool v) =>
      v ? S.of(context).timeTrackerRequired : S.of(context).timeTrackerNotRequired;

  static String optional(BuildContext context, bool v) =>
      v ? S.of(context).timeTrackerRequired : S.of(context).timeTrackerOptional;

  static String status(BuildContext context, RequestTypeStatus status) {
    final S s = S.of(context);
    switch (status) {
      case RequestTypeStatus.active:
        return s.timeTrackerActive;
      case RequestTypeStatus.inactive:
        return s.timeTrackerInactive;
      case RequestTypeStatus.removed:
        return s.timeTrackerRemoved;
    }
  }

  static String addedBy(BuildContext context, RequestType t, RequestTypesState state) {
    final String email = t.audit.createdBy;
    if (email.isEmpty) return TimeTrackerFormat.dash;
    return state.employeeByEmail(email)?.name(isArabic: _ar(context)) ?? email;
  }

  static String locations(BuildContext context, RequestType t, RequestTypesState state) {
    if (t.locationIds.isEmpty) return S.of(context).timeTrackerAll;
    final bool ar = _ar(context);
    return <String>[
      for (final String id in t.locationIds)
        _locationName(state.locations, id, ar),
    ].join(ar ? '، ' : ', ');
  }

  static String _locationName(List<WorkLocation> all, String id, bool ar) {
    for (final WorkLocation l in all) {
      if (l.id == id) return l.name(isArabic: ar);
    }
    return id;
  }

  static String departments(BuildContext context, RequestType t, RequestTypesState state) {
    if (t.departmentIds.isEmpty) return S.of(context).timeTrackerAll;
    return <String>[for (final String id in t.departmentIds) state.departments[id] ?? id]
        .join(_ar(context) ? '، ' : ', ');
  }

  /// Column titles, in table order (without "No").
  static List<String> headers(BuildContext context) {
    final S s = S.of(context);
    return <String>[
      s.timeTrackerRequestName,
      s.timeTrackerStatus,
      s.timeTrackerCreationDate,
      s.timeTrackerAddedBy,
      s.timeTrackerLastUpdate,
      s.timeTrackerHrApproval,
      s.timeTrackerManagerApproval,
      s.timeTrackerDescription,
      s.timeTrackerAttachments,
      s.timeTrackerDeductsFromVacation,
      s.timeTrackerLimitLocationAvailability,
      s.timeTrackerLocationAvailability,
      s.timeTrackerLimitDepartmentAvailability,
      s.timeTrackerDepartmentAvailability,
    ];
  }

  /// Function Name: [cells]
  ///
  /// Purpose: The row's values in [headers] order (Export + table).
  ///
  /// Return type: [List<String>]
  static List<String> cells(BuildContext context, RequestType t, RequestTypesState state) {
    final S s = S.of(context);
    return <String>[
      name(context, t),
      status(context, t.status),
      TimeTrackerFormat.date(context, t.audit.createdAt),
      addedBy(context, t, state),
      TimeTrackerFormat.date(context, t.audit.updatedAt),
      required(context, t.isHrApprovalRequired),
      required(context, t.isManagerApprovalRequired),
      optional(context, t.isDescriptionRequired),
      optional(context, t.isAttachmentRequired),
      t.isDeductedFromVacationBalance ? s.yes : s.no,
      t.locationIds.isNotEmpty ? s.yes : s.no,
      locations(context, t, state),
      t.departmentIds.isNotEmpty ? s.yes : s.no,
      departments(context, t, state),
    ];
  }

  static const List<double> _widths = <double>[
    50, 170, 100, 130, 170, 130, 120, 150, 120, 120, 200, 190, 190, 210, 190,
  ];

  /// Table columns: "No" + [headers].
  static List<TtColumn> columns(BuildContext context) {
    final List<String> h = <String>[S.of(context).timeTrackerColumnNo, ...headers(context)];
    return <TtColumn>[for (int i = 0; i < h.length; i++) TtColumn(h[i], _widths[i])];
  }

  /// Table cells: index + [cells], status coloured.
  static List<TtCell> tableCells(BuildContext context, int index, RequestType t, RequestTypesState state) {
    final List<String> c = cells(context, t, state);
    return <TtCell>[
      TtCell(TimeTrackerFormat.count(context, index + 1)),
      for (int i = 0; i < c.length; i++)
        TtCell(c[i], color: i == 1 ? RequestTypeStatusText.colorOf(t.status) : null),
    ];
  }
}

/// "Active" (green) / "Inactive" (red) / "Removed" (grey).
class RequestTypeStatusText extends StatelessWidget {
  const RequestTypeStatusText({super.key, required this.status, this.maxLines, this.small = false});

  final RequestTypeStatus status;

  /// ADDED 9/10/2026 (UI pass): the card's 12 value size (Figma 661:35833).
  final bool small;

  /// ADDED 9/10/2026: one line on a card (null = wrap).
  final int? maxLines;

  static Color colorOf(RequestTypeStatus status) {
    switch (status) {
      case RequestTypeStatus.active:
        return AppColors.lightGreen;
      case RequestTypeStatus.inactive:
        return AppColors.red;
      case RequestTypeStatus.removed:
        return AppColors.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context) => Text(
        RequestTypeText.status(context, status),
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: (small ? StyleText.fontSize12Weight500 : StyleText.fontSize14Weight500)
            .copyWith(color: colorOf(status)),
      );
}

/// ADDED 12/10/2026 (owner J1 / J2): the status as a COLOURED CHIP (a tinted
/// container with a dot) — Active green, Inactive orange, Removed red — on
/// the cards and the details page.
class RequestTypeStatusChip extends StatelessWidget {
  const RequestTypeStatusChip({super.key, required this.status});

  final RequestTypeStatus status;

  @override
  Widget build(BuildContext context) {
    final Color c = RequestTypeStatusText.colorOf(status);
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(width: 6.r, height: 6.r, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          SizedBox(width: 6.w),
          Text(RequestTypeText.status(context, status), style: StyleText.fontSize12Weight500.copyWith(color: c)),
        ],
      ),
    );
  }
}

/// ADDED 12/10/2026 (owner J1 / R12): one rule of a request type as an icon
/// chip — blue with a tick when it applies ("HR Approval"), grey with a dash
/// when it does not.
class RequestTypeRuleChip extends StatelessWidget {
  const RequestTypeRuleChip({super.key, required this.icon, required this.label, required this.on});

  final TtGlyph icon;
  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final Color c = on ? AppColors.blue : AppColors.secondaryText;
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: on ? AppColors.blue.withValues(alpha: 0.12) : AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TtIcon(icon, size: 13.r, color: c),
          SizedBox(width: 5.w),
          Text(label, style: StyleText.fontSize10Weight500.copyWith(color: on ? AppColors.text : AppColors.secondaryText)),
          SizedBox(width: 4.w),
          Icon(on ? Icons.check_rounded : Icons.remove_rounded, size: 13.r, color: c),
        ],
      ),
    );
  }
}

/// ADDED 12/10/2026 (owner J1): the coloured icon tile of a request type —
/// yellow calendar when it uses the vacation balance, blue document else.
class RequestTypeIconTile extends StatelessWidget {
  const RequestTypeIconTile({super.key, required this.type, this.size});

  final RequestType type;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double side = size ?? 40.r;
    final bool vacation = type.isDeductedFromVacationBalance;
    final Color c = vacation ? AppColors.primary : AppColors.blue;
    return Container(
      width: side,
      height: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: vacation ? c : c.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TtIcon(
        TtGlyph.svg(vacation ? TtAssets.calendar : ChartSvg.request),
        size: side * 0.5,
        color: vacation ? AppColors.textButton : AppColors.blue,
      ),
    );
  }
}
