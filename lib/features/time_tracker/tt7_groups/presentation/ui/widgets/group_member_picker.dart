/// Module: time_tracker / tt7_groups / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: group_member_picker.dart
/// Purpose: Declares `GroupMemberPicker` — the Members field of Create /
///          Edit Group: Search + Department on ONE row, then the employees
///          as rows with a tick box (photo · name · job title · department)
///          and how many are selected.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (owner review)
///
/// Owner review (9/10/2026, "Creating New Group" on iPad portrait): the
/// "Choose Members" dropdown + chips became the same pattern as the approved
/// employee picker (`HrEmployeePicker`, Figma `661:93462`) — inline in the
/// form. Selected members are always listed FIRST and stay visible (a search
/// or Department filter only narrows the others), so a tick is never hidden.
/// Tapping a row toggles it (LOW haptic). Names are shown as stored, proper
/// case (`TimeTrackerEmployee.name`). Two columns on iPad, one on iPhone;
/// each row of cards is as tall as its longest text (no fixed cell height).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt5_locations/presentation/ui/widgets/location_form_fields.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class GroupMemberPicker extends StatefulWidget {
  const GroupMemberPicker({
    super.key,
    required this.people,
    required this.departments,
    required this.selected,
    required this.onChanged,
    this.error,
  });

  final List<TimeTrackerEmployee> people;

  /// Department id → name (the filter; hidden when empty).
  final Map<String, String> departments;

  /// Lower-cased e-mails of the members.
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  /// "Choose at least one member" (null = none).
  final String? error;

  @override
  State<GroupMemberPicker> createState() => _GroupMemberPickerState();
}

class _GroupMemberPickerState extends State<GroupMemberPicker> {
  final TextEditingController _search = TextEditingController();
  String? _department;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Set<String> get _picked => <String>{for (final String e in widget.selected) e.trim().toLowerCase()};

  /// Selected first (always shown), then the others matching the filters.
  List<TimeTrackerEmployee> _rows(bool ar) {
    final Set<String> picked = _picked;
    final String q = _search.text.trim().toLowerCase();
    int byName(TimeTrackerEmployee a, TimeTrackerEmployee b) =>
        a.name(isArabic: ar).toLowerCase().compareTo(b.name(isArabic: ar).toLowerCase());
    final List<TimeTrackerEmployee> chosen = <TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in widget.people)
        if (picked.contains(e.email.trim().toLowerCase())) e,
    ]..sort(byName);
    final List<TimeTrackerEmployee> others = <TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in widget.people)
        if (!picked.contains(e.email.trim().toLowerCase()) &&
            (q.isEmpty || e.searchText.contains(q)) &&
            (_department == null || e.departmentId == _department))
          e,
    ]..sort(byName);
    return <TimeTrackerEmployee>[...chosen, ...others];
  }

  void _toggle(String email) {
    HapticController.low();
    final String key = email.trim().toLowerCase();
    final List<String> next = <String>[
      for (final String e in widget.selected)
        if (e.trim().toLowerCase() != key) e.trim().toLowerCase(),
    ];
    if (next.length == widget.selected.length) next.add(key);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final bool phone = context.isPhone;
    final List<TimeTrackerEmployee> rows = _rows(ar);
    final int cols = phone ? 1 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(s.timeTrackerMembers,
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
            ),
            Text(
              s.timeTrackerMembersSelected(TimeTrackerFormat.count(context, _picked.length)),
              key: const ValueKey<String>('groupMembersCount'),
              style: StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            TtSearchField(
              key: const ValueKey<String>('groupMembersSearch'),
              controller: _search,
              fillColor: AppColors.background,
              onChanged: (_) => setState(() {}),
            ),
            if (widget.departments.isNotEmpty) ...<Widget>[
              SizedBox(width: 15.w),
              SizedBox(width: phone ? 140.w : 160.w, child: _departmentFilter(s)),
            ],
          ],
        ),
        // 13/10/2026 (owner U2): who is selected, as chips (avatar + ✕).
        if (_picked.isNotEmpty) ...<Widget>[
          SizedBox(height: 10.h),
          SingleChildScrollView(
            key: const ValueKey<String>('groupSelectedChips'),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final TimeTrackerEmployee e in rows)
                  if (_picked.contains(e.email.trim().toLowerCase())) ...<Widget>[
                    TtPersonChip(
                      key: ValueKey<String>('groupSelectedChip_${e.email}'),
                      name: e.name(isArabic: ar),
                      photo: e.photo,
                      onRemove: () => _toggle(e.email),
                    ),
                    SizedBox(width: 8.w),
                  ],
              ],
            ),
          ),
        ],
        SizedBox(height: 10.h),
        if (rows.isEmpty)
          Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: 20.h),
            child: Text(s.noEmployeesFound,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 360.h),
            // Rows of [cols] cards that grow with their text (a two-line name
            // never overflows a fixed cell height); built lazily.
            child: ListView.separated(
              key: const ValueKey<String>('groupMembersList'),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: (rows.length + cols - 1) ~/ cols,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (BuildContext context, int line) => IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (int j = 0; j < cols; j++) ...<Widget>[
                      if (j > 0) SizedBox(width: 12.w),
                      Expanded(
                        child: line * cols + j < rows.length
                            ? _row(rows[line * cols + j], ar)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        TtFieldError(widget.error),
      ],
    );
  }

  Widget _departmentFilter(S s) => CustomDropdown<String>(
        key: const ValueKey<String>('groupMembersDepartment'),
        hint: s.timeTrackerDepartment,
        height: TtToolbar.height,
        borderRadius: TtToolbar.radius,
        fillColor: AppColors.background,
        itemStyle: StyleText.fontSize12Weight400,
        value: _department,
        items: <DropdownItem<String>>[
          DropdownItem<String>(value: '', label: s.timeTrackerAll),
          for (final MapEntry<String, String> d in widget.departments.entries)
            DropdownItem<String>(value: d.key, label: d.value),
        ],
        onChanged: (String v) {
          HapticController.low();
          setState(() => _department = v.isEmpty ? null : v);
        },
      );

  /// photo · name (two lines) · job title · department · tick box.
  Widget _row(TimeTrackerEmployee e, bool ar) {
    final bool on = _picked.contains(e.email.trim().toLowerCase());
    final TextStyle small = StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText);
    final String title = e.jobTitle(isArabic: ar);
    return GestureDetector(
      key: ValueKey<String>('groupMemberRow_${e.email}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggle(e.email),
      child: Container(
        padding: EdgeInsetsDirectional.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: CardStyles.radius(),
          border: Border.all(color: on ? AppColors.primary : AppColors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TimeTrackerAvatar(photo: e.photo, size: 40.r),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(e.name(isArabic: ar),
                      key: ValueKey<String>('groupMemberName_${e.email}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
                  Text(title.isEmpty ? TimeTrackerFormat.dash : title,
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: small),
                  Text(TimeTrackerFormat.orDash(e.department(isArabic: ar)),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: small),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            CustomCheckBox(key: ValueKey<String>('groupMemberTick_${e.email}'), isSelected: on),
          ],
        ),
      ),
    );
  }
}
