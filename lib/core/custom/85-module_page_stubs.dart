/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: module_page_stubs.dart
/// Purpose: Declares `GrcResponsivePage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Stub services_management_module for modules not included in knowticed.
// All module entry-point page stubs live here so there is one place to find them.
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart'
    show SettingsScreen;
import 'package:knowticed_plus/generated/l10n.dart';

// ── GRC ──────────────────────────────────────────────────────────────────────

class GrcResponsivePage extends StatelessWidget {
  const GrcResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(S.current.grcresponsivepage)));
}

class GrcResponsivePageRefactor extends StatelessWidget {
  const GrcResponsivePageRefactor({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(S.current.grc)));
}

// ── Form Builder ─────────────────────────────────────────────────────────────

class FormResponsivePage extends StatelessWidget {
  const FormResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(S.current.formresponsivepage)));
}

// ── Tracker ───────────────────────────────────────────────────────────────────

class TrackerPageResponsivePageRefactor extends StatelessWidget {
  const TrackerPageResponsivePageRefactor({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(S.current.trackerpageresponsivepagerefactor)));
}

// ── Task Management ───────────────────────────────────────────────────────────

class TasksResponsivePage extends StatelessWidget {
  const TasksResponsivePage({super.key});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(S.current.tasksresponsivepage)));
}

// ── Settings (backward-compat wrapper) ───────────────────────────────────────

class Settings extends StatelessWidget {
  const Settings({super.key});
  @override
  Widget build(BuildContext context) => SettingsScreen();
}
