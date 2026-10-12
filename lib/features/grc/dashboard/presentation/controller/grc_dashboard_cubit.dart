/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_dashboard_cubit.dart
/// Purpose: Declares `GrcDashboardCubit` — loads the dashboard (one module or
///          all), holds every card's filter and the Color Coding rules.
/// Author: Amr Mesbah
/// Created: 16/9/2026
///
/// Same shape as DashboardMasterCubit on the services side: the page owns a
/// cubit, the cards only read state and call the setters below. Filters are
/// applied in memory (GrcDashboardData), so changing one never re-reads
/// Firestore. Registered as a factory in grc_get_it.dart.
library;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_color_coding.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/use_cases/get_grc_dashboard_use_case.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/controller/grc_dashboard_state.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';

class GrcDashboardCubit extends Cubit<GrcDashboardState> {
  GrcDashboardCubit({required GetGrcDashboardUseCase getGrcDashboardUseCase})
      : _getDashboard = getGrcDashboardUseCase,
        super(const GrcDashboardInitial());

  final GetGrcDashboardUseCase _getDashboard;

  bool _loaded = false;
  GRCModuleEntity? _module;

  /// Loads [module]'s dashboard, or every module's when null.
  Future<void> load({GRCModuleEntity? module}) async {
    _module = module;
    _loaded = true;
    // Keep filters / colour rules across a reload.
    final previous = state;
    emit(const GrcDashboardLoading());

    try {
      final result = module == null
          ? await _getDashboard.forAllModules()
          : await _getDashboard.forModule(module);
      if (isClosed) return;
      result.fold(
        (failure) => emit(GrcDashboardFailure(failure.message)),
        (data) => emit(previous is GrcDashboardLoaded
            ? GrcDashboardLoaded(
                data: data,
                filters: previous.filters,
                colorRules: previous.colorRules,
              )
            : GrcDashboardLoaded(data: data)),
      );
    } catch (error, stackTrace) {
      debugPrint('[grc-dashboard] load failed: $error');
      debugPrint('$stackTrace');
      if (!isClosed) emit(GrcDashboardFailure(error.toString()));
    }
  }

  Future<void> reload() async {
    if (_loaded) await load(module: _module);
  }

  // ── Filters ────────────────────────────────────────────────────────────

  void _update(
    GrcDashboardFilters Function(GrcDashboardFilters f) change,
  ) {
    final s = state;
    if (s is! GrcDashboardLoaded) return;
    emit(s.copyWith(filters: change(s.filters)));
  }

  void setDepartment(String? v) => _update((f) => f.copyWith(department: v));

  void setComplianceSort(bool? ascending) =>
      _update((f) => f.copyWith(complianceAscending: ascending));

  /// Changing the policy clears a control that belongs to another policy.
  void setDepartmentsPolicy(String? v) => _update((f) =>
      f.copyWith(departmentsPolicyId: v, departmentsControlId: null));

  void setDepartmentsControl(String? v) =>
      _update((f) => f.copyWith(departmentsControlId: v));

  void setDepartmentsSort(bool? ascending) =>
      _update((f) => f.copyWith(departmentsAscending: ascending));

  void setPerformancePolicy(String? v) => _update((f) =>
      f.copyWith(performancePolicyId: v, performanceControlId: null));

  void setPerformanceControl(String? v) =>
      _update((f) => f.copyWith(performanceControlId: v));

  void setPerformanceTop(bool top) =>
      _update((f) => f.copyWith(performanceTop: top));

  void toggleTimelineBaseline() =>
      _update((f) => f.copyWith(timelineBaseline: !f.timelineBaseline));

  void setTimelinePolicy(String? v) => _update(
      (f) => f.copyWith(timelinePolicyId: v, timelineControlId: null));

  void setTimelineControl(String? v) =>
      _update((f) => f.copyWith(timelineControlId: v));

  void setTimelineDepartment(String? v) =>
      _update((f) => f.copyWith(timelineDepartment: v));

  // ── Color Coding ───────────────────────────────────────────────────────

  void saveColorRule(GrcColorRule rule) {
    final s = state;
    if (s is! GrcDashboardLoaded) return;
    emit(s.copyWith(colorRules: {...s.colorRules, rule.category: rule}));
  }
}
