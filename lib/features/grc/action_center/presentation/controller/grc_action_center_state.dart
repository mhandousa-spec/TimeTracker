part of 'grc_action_center_cubit.dart';

enum GrcActionCenterStatus { initial, loading, loaded, failure }

/// The four Figma tabs.
enum GrcActionCenterTab { allIssues, errors, recommendations, expired }

class GrcActionCenterState {
  final GrcActionCenterStatus status;
  final String? message;
  final List<GrcActionIssue> issues;
  final GrcActionCenterTab tab;

  /// All Issues tab: Errors (errors + expired) or Recommendations.
  final GrcIssueKind allIssuesKind;
  final String search;

  /// Raw department key; null = all departments.
  final String? department;

  /// Module id; null = all modules.
  final String? moduleId;

  const GrcActionCenterState({
    this.status = GrcActionCenterStatus.initial,
    this.message,
    this.issues = const <GrcActionIssue>[],
    this.tab = GrcActionCenterTab.allIssues,
    this.allIssuesKind = GrcIssueKind.error,
    this.search = '',
    this.department,
    this.moduleId,
  });

  // ── counts (the All Issues summary; ignore search / pickers) ─────────

  int get errorCount =>
      issues.where((i) => i.kind != GrcIssueKind.recommendation).length;

  int get recommendationCount =>
      issues.where((i) => i.kind == GrcIssueKind.recommendation).length;

  int get totalCount => issues.length;

  // ── what the table shows ─────────────────────────────────────────────

  bool _ofTab(GrcActionIssue i) {
    switch (tab) {
      case GrcActionCenterTab.allIssues:
        return allIssuesKind == GrcIssueKind.recommendation
            ? i.kind == GrcIssueKind.recommendation
            : i.kind != GrcIssueKind.recommendation;
      case GrcActionCenterTab.errors:
        return i.kind == GrcIssueKind.error;
      case GrcActionCenterTab.recommendations:
        return i.kind == GrcIssueKind.recommendation;
      case GrcActionCenterTab.expired:
        return i.kind == GrcIssueKind.expired;
    }
  }

  List<GrcActionIssue> get visible {
    final q = search.trim().toLowerCase();
    return issues.where((i) {
      if (!_ofTab(i)) return false;
      if (moduleId != null && i.module.moduleId != moduleId) return false;
      if (tab != GrcActionCenterTab.allIssues &&
          department != null &&
          !i.departments.contains(department)) {
        return false;
      }
      return q.isEmpty || i.searchText.contains(q);
    }).toList();
  }

  /// Every department that appears on an issue, first-seen order.
  List<String> get departments {
    final out = <String>[];
    for (final i in issues) {
      for (final d in i.departments) {
        if (!out.contains(d)) out.add(d);
      }
    }
    return out;
  }

  GrcActionCenterState copyWith({
    GrcActionCenterStatus? status,
    String? message,
    List<GrcActionIssue>? issues,
    GrcActionCenterTab? tab,
    GrcIssueKind? allIssuesKind,
    String? search,
    String? Function()? department,
    String? Function()? moduleId,
  }) =>
      GrcActionCenterState(
        status: status ?? this.status,
        message: message ?? this.message,
        issues: issues ?? this.issues,
        tab: tab ?? this.tab,
        allIssuesKind: allIssuesKind ?? this.allIssuesKind,
        search: search ?? this.search,
        department: department != null ? department() : this.department,
        moduleId: moduleId != null ? moduleId() : this.moduleId,
      );
}
