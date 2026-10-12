part of 'department_dashboard_cubit.dart';

enum DepartmentLoadStatus { initial, loading, loaded, failure }

/// "14 Policies" / "7 Controls" switch.
enum DepartmentListTab { policies, controls }

/// "Table" / "Analytics" switch.
enum DepartmentView { table, analytics }

/// class name: [DepartmentDashboardState]
///
/// purpose: immutable snapshot. Nullable filters are passed to [copyWith]
///          as `() => value` so they can be cleared back to null.
class DepartmentDashboardState {
  final DepartmentLoadStatus status;
  final DepartmentDashboardData? data;
  final String? message;

  final String? department;
  final DepartmentListTab tab;
  final DepartmentView view;
  final String search;

  /// Status value ('Active', 'Expired', ...) the table is narrowed to.
  final String? statusFilter;

  final String? chartPolicyId;
  final String? chartControlId;

  final String? reportPolicyId;
  final String? reportControlId;

  const DepartmentDashboardState({
    this.status = DepartmentLoadStatus.initial,
    this.data,
    this.message,
    this.department,
    this.tab = DepartmentListTab.policies,
    this.view = DepartmentView.table,
    this.search = '',
    this.statusFilter,
    this.chartPolicyId,
    this.chartControlId,
    this.reportPolicyId,
    this.reportControlId,
  });

  DepartmentDashboardState copyWith({
    DepartmentLoadStatus? status,
    DepartmentDashboardData? data,
    String? message,
    String? Function()? department,
    DepartmentListTab? tab,
    DepartmentView? view,
    String? search,
    String? Function()? statusFilter,
    String? Function()? chartPolicyId,
    String? Function()? chartControlId,
    String? Function()? reportPolicyId,
    String? Function()? reportControlId,
  }) {
    return DepartmentDashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      department: department != null ? department() : this.department,
      tab: tab ?? this.tab,
      view: view ?? this.view,
      search: search ?? this.search,
      statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      chartPolicyId:
          chartPolicyId != null ? chartPolicyId() : this.chartPolicyId,
      chartControlId:
          chartControlId != null ? chartControlId() : this.chartControlId,
      reportPolicyId:
          reportPolicyId != null ? reportPolicyId() : this.reportPolicyId,
      reportControlId:
          reportControlId != null ? reportControlId() : this.reportControlId,
    );
  }
}
