/// Module: time_tracker / tt6_employees / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employees_filter_dialog.dart
/// Purpose: Declares `EmployeesFilterDialog` — the Employees "Filter" popup:
///          Department · Location · Reset / Apply.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Not drawn in Figma; same shell as the other Time Tracker filters
/// (`TtFilterFrame`). Pops an [EmployeesFilterResult] ('' = all). Scales in.
/// Updated: 12/10/2026 - owner T2: Department moved here from the toolbar,
/// next to Location; each field shows only when the caller passes its
/// options (Department needs `Employees_All_Departments`, Location is for
/// the Assigned list only).

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_filter_frame.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// What the Employees filter applies ('' = all).
typedef EmployeesFilterResult = ({String location, String department});

class EmployeesFilterDialog extends StatefulWidget {
  const EmployeesFilterDialog({
    super.key,
    required this.location,
    required this.department,
    this.locations,
    this.departments,
  });

  final String location;
  final String department;

  /// Null = no Location field.
  final List<WorkLocation>? locations;

  /// Department id → name; null = no Department field.
  final Map<String, String>? departments;

  @override
  State<EmployeesFilterDialog> createState() => _EmployeesFilterDialogState();
}

class _EmployeesFilterDialogState extends State<EmployeesFilterDialog> {
  late String _location = widget.location;
  late String _department = widget.department;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final List<WorkLocation>? locations = widget.locations;
    final Map<String, String>? departments = widget.departments;
    final Widget? department = departments == null
        ? null
        : TtFilterDropdown<String>(
            key: const ValueKey<String>('employeesDepartmentFilter'),
            label: s.timeTrackerDepartment,
            value: _department.isEmpty ? null : _department,
            items: <(String, String)>[for (final MapEntry<String, String> d in departments.entries) (d.key, d.value)],
            onChanged: (String? v) => setState(() => _department = v ?? ''),
          );
    final Widget? location = locations == null
        ? null
        : TtFilterDropdown<String>(
            key: const ValueKey<String>('employeesLocationFilter'),
            label: s.timeTrackerLocation,
            value: _location.isEmpty ? null : _location,
            items: <(String, String)>[
              for (final WorkLocation l in locations)
                if (l.status != LocationStatus.deleted) (l.id, l.name(isArabic: ar)),
            ],
            onChanged: (String? v) => setState(() => _location = v ?? ''),
          );
    return TtFilterFrame(
      applyKey: const ValueKey<String>('employeesFilterApply'),
      rows: <Widget>[
        if (department != null && location != null)
          TtPair(start: department, end: location)
        else if (department != null)
          department
        else if (location != null)
          location,
      ],
      onReset: () => Navigator.of(context).pop((location: '', department: '')),
      onApply: () => Navigator.of(context).pop((location: _location, department: _department)),
    );
  }
}
