/// Module: home/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_dashboard_stub.dart
/// Purpose: Declares `DashboardStates`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// ============================================================================
// Knowledge Hub dashboard stub
// ----------------------------------------------------------------------------
// The real "knowledge_hub_module" was removed from this (demo) copy of the app.
// This file re-declares ONLY the Bloc cubit + states that the kept home widgets
// (knowledge_hub_overview.dart, approval_knowledge.dart) still reference, so the
// project compiles WITHOUT copying the real module from the master app.
//
// The cubit holds no documents (getAllDocuments() returns an empty list) and
// stays in the "empty" state, so the knowledge cards render their "No data"
// branch instead of crashing.
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

// ---- States ---------------------------------------------------------------
abstract class DashboardStates {}

class DashboardInitial extends DashboardStates {}

class DashboardLoading extends DashboardStates {}

class DashboardEmpty extends DashboardStates {}

class DashboardError extends DashboardStates {}

class DashboardLoaded extends DashboardStates {
  // Read by the home widgets as `state.statusCounts`.
  final Map<String, int> statusCounts;
  DashboardLoaded({this.statusCounts = const {}});
}

// ---- Cubit ----------------------------------------------------------------
class DashboardCubit extends Cubit<DashboardStates> {
  DashboardCubit() : super(DashboardEmpty());

  // No-op: there is no knowledge module to load in this build.
  void loadDashboard() => emit(DashboardEmpty());

  // No documents in this build. `dynamic` items satisfy the `doc.status` /
  // `doc.currentCreatedByEmail` member access in the kept widgets.
  List<dynamic> getAllDocuments() => <dynamic>[];
}
