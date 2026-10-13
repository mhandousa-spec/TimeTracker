/// Module: time_tracker / tt6_employees / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_card.dart
/// Purpose: Declares `EmployeeCard` — ONE employee card for every Time
///          Tracker employee list (Employees tab Assigned / Unassigned,
///          Location details → Assigned Employees) — plus
///          `EmployeeCardAction`, `EmployeeCardRemove` and `EmployeeCardGrid`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Redesigned 9/10/2026 (UI quality pass — owner findings 13:45 #5 / #6,
/// Figma `661:93542` / `661:39620`):
///   header  photo 40 · name (14 Medium, up to 2 lines) · department ·
///           job title (12 grey)                       · [tick box | trash]
///   footer  Assign Date · Location (full, wraps) · rules line + small
///           "From location" / "Custom" tag            · ONE action button
/// - ONE action area: the yellow primary action (Reassign / Assign /
///   Message) at the bottom end; Remove is a small RED square with a WHITE
///   trash at the top end ([EmployeeCardRemove]) — never a red + yellow pair
///   side by side.
/// - Normal values are never cut: name 2 lines, location / rules wrap.
/// - The card hugs its content (`EmployeeCardGrid` = `TtCardGrid`), no
///   empty space; no hover / splash; names / titles / departments through
///   the module's proper-case helper (`TimeTrackerEmployee`).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/effective_rules.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/location_rules_panel.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_card_grid.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({
    super.key,
    required this.employee,
    this.assignment,
    this.locationName = '',
    this.rules,
    this.action,
    this.onRemove,
    this.removeKey,
    this.selected,
    this.onSelect,
    this.onTap,
  });

  final TimeTrackerEmployee employee;
  final LocationAssignment? assignment;

  /// '' = no "Location:" line.
  final String locationName;

  /// The effective rules + their source (null = no rules line).
  final EffectiveRules? rules;

  /// The ONE primary action at the bottom end (Reassign / Assign / Message).
  final Widget? action;

  /// Shows the red trash at the top end (null = hidden).
  final VoidCallback? onRemove;
  final Key? removeKey;

  /// Tick-box state (null = no tick box).
  final bool? selected;
  final VoidCallback? onSelect;

  /// Tap on the card (e.g. open the employee's dashboard); LOW haptic.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final LocationAssignment? a = assignment;
    final bool? tick = selected;
    final EffectiveRules? effective = rules;
    final VoidCallback? remove = onRemove;
    final Widget? primary = action;
    final TextStyle small = StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);
    final String title = employee.jobTitle(isArabic: ar);
    final DateTime? assigned = a != null && a.isAssigned ? a.startDate : null;
    final bool hasFooter = assigned != null || locationName.isNotEmpty || effective != null || primary != null;
    final bool custom = effective != null && !effective.isFromLocation;
    final Widget body = Container(
      padding: EdgeInsetsDirectional.all(10.r),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 12/10/2026 (owner T3): room for the "Custom" corner ribbon.
              if (custom) SizedBox(width: 18.w),
              TimeTrackerAvatar(photo: employee.photo, size: 40.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(employee.name(isArabic: ar),
                        key: ValueKey<String>('employeeName_${employee.email}'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                    if (employee.department(isArabic: ar).isNotEmpty)
                      Text(employee.department(isArabic: ar), style: small),
                    if (title.isNotEmpty) Text(title, style: small),
                  ],
                ),
              ),
              if (tick != null) ...<Widget>[
                SizedBox(width: 8.w),
                GestureDetector(
                  key: ValueKey<String>('employeeTick_${employee.email}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticController.low();
                    onSelect?.call();
                  },
                  child: CustomCheckBox(isSelected: tick),
                ),
              ] else if (remove != null) ...<Widget>[
                SizedBox(width: 8.w),
                EmployeeCardRemove(key: removeKey, onTap: remove),
              ],
            ],
          ),
          if (hasFooter) ...<Widget>[
            SizedBox(height: 10.h),
            // Fills only when a neighbour in the row is taller (TtCardGrid).
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 12/10/2026 (owner T4 / R12): every line has its icon.
                      if (assigned != null)
                        _Pair(
                          icon: TtAssets.calendar,
                          label: s.timeTrackerAssignDateLabel,
                          value: TimeTrackerFormat.date(context, assigned),
                        ),
                      if (locationName.isNotEmpty)
                        _Pair(icon: TtAssets.location, label: s.timeTrackerLocation, value: locationName),
                      if (effective != null)
                        Padding(
                          key: ValueKey<String>('employeeRules_${employee.email}'),
                          padding: EdgeInsetsDirectional.only(top: 4.h),
                          child: Row(
                            children: <Widget>[
                              TtIcon(const TtGlyph.svg(TtAssets.clock), size: 14.r, color: AppColors.secondaryText),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(LocationRulesText.rules(context, effective.rules),
                                    style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryText)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                if (primary != null) ...<Widget>[SizedBox(width: 10.w), primary],
              ],
            ),
          ],
        ],
      ),
    );
    final Widget card = TtCustomRibbon(
      key: custom ? ValueKey<String>('employeeCustomRibbon_${employee.email}') : null,
      show: custom,
      child: body,
    );
    final VoidCallback? tap = onTap;
    if (tap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        tap();
      },
      child: card,
    );
  }
}

/// [icon] "Label: value" — the value wraps (never "…").
class _Pair extends StatelessWidget {
  const _Pair({required this.icon, required this.label, required this.value});

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(top: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(top: 1.h),
            child: TtIcon(TtGlyph.svg(icon), size: 14.r, color: AppColors.secondaryText),
          ),
          SizedBox(width: 6.w),
          Expanded(child: _text()),
        ],
      ),
    );
  }

  Widget _text() {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
        children: <InlineSpan>[
          TextSpan(text: value, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}

/// The card's primary action: a compact yellow button ("Reassign" /
/// "Assign" / "Message"), MEDIUM haptic, shrinks on tap.
class EmployeeCardAction extends StatelessWidget {
  const EmployeeCardAction({super.key, required this.title, required this.onTap, this.icon});

  final String title;
  final VoidCallback onTap;

  /// Optional leading icon (Message).
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final String? svg = icon;
    return Semantics(
      button: true,
      label: title,
      child: ShrinkOnTap(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticController.medium();
            onTap();
          },
          child: Container(
            height: 32.sp,
            padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadiusDirectional.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (svg != null) ...<Widget>[
                  CustomSvgImage(assetPath: svg, width: 16.r, height: 16.r, color: AppColors.textButton),
                  SizedBox(width: 6.w),
                ],
                Text(title, style: StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Remove: a small RED square with a WHITE trash (destructive house style),
/// HIGH haptic, read as "Remove".
class EmployeeCardRemove extends StatelessWidget {
  const EmployeeCardRemove({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.of(context).timeTrackerRemove,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticController.high();
          onTap();
        },
        child: Container(
          width: 30.r,
          height: 30.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadiusDirectional.circular(8.r),
          ),
          child: CustomSvgImage(assetPath: TtAssets.trash, width: 16.r, height: 16.r, color: AppColors.white),
        ),
      ),
    );
  }
}

/// The responsive grid of [EmployeeCard]s — cards hug their content.
class EmployeeCardGrid extends StatelessWidget {
  const EmployeeCardGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => TtCardGrid(children: children);
}
