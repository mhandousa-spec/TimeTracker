/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_picked_employees.dart
/// Purpose: Declares `HrPickedEmployees` — the employee card(s) the HR view
///          shows under the filters once employees are picked: one wide card
///          (Figma `661:42895`) or a grid of compact cards (`661:43247`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (phase 5)
///
/// Wide card: photo 80 · name · Title / Department · Email / Phone Number ·
/// yellow "Message". Compact card: photo · name · Title · Department ·
/// Phone · Email · a yellow message square. Two columns (Figma), one on a
/// phone.
/// Tapping a card opens that employee's dashboard (`661:96459`); "Message"
/// opens the chat. No splash (owner rule), LOW haptic.
/// Updated: 9/10/2026 - code review: Material icons → the app's SVG line
/// icons (`TtAssets` / `TtGlyph`) where an equivalent asset exists.
/// Updated: 9/10/2026 - owner review: names / titles take up to two lines
/// (no "…" on a normal name such as "Bayanatz Transformation").
/// Updated: 9/10/2026 - UI quality pass (owner 14:17 #5): one picked
/// employee = the shared `HrEmployeeHeaderCard` (Message top-right, values
/// in full); compact cards hug their content and wrap their values.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_dashboard_navigation.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_employee_header_card.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_message_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';

class HrPickedEmployees extends StatelessWidget {
  const HrPickedEmployees({super.key, required this.people});

  final List<TimeTrackerEmployee> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    if (people.length == 1) {
      // UI quality pass (owner 14:17 #5): the shared header card — Message
      // top-right, every value in full.
      final TimeTrackerEmployee e = people.first;
      return HrEmployeeHeaderCard(
        employee: e,
        onTap: () => HrDashboardNavigation.openEmployee(context, e),
        onMessage: () => openTimeTrackerChat(context, e.email),
      );
    }
    // 13/10/2026 (owner): more than four picked → ONE row that scrolls
    // sideways (the cards no longer push the dashboard down).
    if (people.length > 4) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double w = context.isPhone ? c.maxWidth * 0.85 : (c.maxWidth - 15.w) / 2;
          return SingleChildScrollView(
            key: const ValueKey<String>('hrPickedRow'),
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < people.length; i++) ...<Widget>[
                    if (i > 0) SizedBox(width: 15.w),
                    SizedBox(width: w, child: _CompactCard(employee: people[i])),
                  ],
                ],
              ),
            ),
          );
        },
      );
    }
    // Cards hug their content (`TtCardGrid`; the fixed 112.h cut values).
    return TtCardGrid(
      key: const ValueKey<String>('hrPickedGrid'),
      columns: context.isPhone ? 1 : 2,
      children: <Widget>[for (final TimeTrackerEmployee e in people) _CompactCard(employee: e)],
    );
  }
}

/// "Title: Technician" with a small leading icon.
/// 13/10/2026 (owner): the icon sits in the text line (always centred on
/// it); [oneLine] keeps a value on one line ("…" — the e-mail).
class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value, this.oneLine = false});

  final TtGlyph icon;
  final String label;
  final String value;
  final bool oneLine;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 3.h),
      child: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: 5.w),
                child: TtIcon(icon, size: 14.r, color: AppColors.secondaryText),
              ),
            ),
            TextSpan(
              text: '$label: ',
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
            ),
            TextSpan(
              text: value.trim().isEmpty ? TimeTrackerFormat.dash : value,
              style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
            ),
          ],
        ),
        maxLines: oneLine ? 1 : null,
        overflow: oneLine ? TextOverflow.ellipsis : null,
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.employee});

  final TimeTrackerEmployee employee;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    return GestureDetector(
      key: ValueKey<String>('hrPickedCard_${employee.email}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => HrDashboardNavigation.openEmployee(context, employee),
      child: Container(
        padding: EdgeInsetsDirectional.all(10.r),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TimeTrackerAvatar(photo: employee.photo, size: 40.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(employee.name(isArabic: ar),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  // 13/10/2026 (owner): the job-title icon of the Figma
                  // request details (a briefcase line icon).
                  _Info(icon: const TtGlyph.svg(TtAssets.reqJob), label: s.timeTrackerTitleLabel, value: employee.jobTitle(isArabic: ar)),
                  _Info(icon: const TtGlyph.svg(TtAssets.department), label: s.timeTrackerDepartment, value: employee.department(isArabic: ar)),
                  _Info(icon: const TtGlyph.svg(TtAssets.phone), label: s.timeTrackerPhoneNumber, value: employee.phone),
                  _Info(icon: const TtGlyph.svg(TtAssets.email), label: s.timeTrackerEmail, value: employee.email, oneLine: true),
                ],
              ),
            ),
            TtMessageButton(iconOnly: true, onTap: () => openTimeTrackerChat(context, employee.email)),
          ],
        ),
      ),
    );
  }
}
