/// Module: GRC shared services
/// Description: The two per-module switches on the Departments tab.
///
/// ADDED 28/9/2026 (GRC bug report p5, "add 2 switches"):
///   * Show_Dashboard            — whether the Departments dashboard is shown
///                                 to the module's users at all;
///   * Allow_Department_Switching — whether they may pick another department,
///                                 or are held to their own.
///
/// Stored in one small document per module,
/// `{GRC_Modules}/{Module_ID}/Settings/Department_Dashboard`, so the module
/// record itself (a history-list model) is untouched. A missing document or
/// field reads as `true` — exactly today's behaviour.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';

class GrcDepartmentDashboardSettings {
  final bool showDashboard;
  final bool allowDepartmentSwitching;

  const GrcDepartmentDashboardSettings({
    this.showDashboard = true,
    this.allowDepartmentSwitching = true,
  });

  static const String _showKey = 'Show_Dashboard';
  static const String _switchKey = 'Allow_Department_Switching';

  static DocumentReference<Map<String, dynamic>> _doc(String moduleId) =>
      FirebaseFirestore.instance
          .collection(GrcFirebasePaths.modulesCollection)
          .doc(moduleId)
          .collection('Settings')
          .doc('Department_Dashboard');

  static Future<GrcDepartmentDashboardSettings> load(String moduleId) async {
    try {
      final snap = await _doc(moduleId).get();
      final data = snap.data() ?? const <String, dynamic>{};
      return GrcDepartmentDashboardSettings(
        showDashboard: data[_showKey] as bool? ?? true,
        allowDepartmentSwitching: data[_switchKey] as bool? ?? true,
      );
    } catch (_) {
      // Unreadable settings must never lock anyone out of the dashboard.
      return const GrcDepartmentDashboardSettings();
    }
  }

  static Future<void> save(
    String moduleId,
    GrcDepartmentDashboardSettings settings,
  ) {
    return _doc(moduleId).set(<String, dynamic>{
      _showKey: settings.showDashboard,
      _switchKey: settings.allowDepartmentSwitching,
      'Modification_Date': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  GrcDepartmentDashboardSettings copyWith({
    bool? showDashboard,
    bool? allowDepartmentSwitching,
  }) =>
      GrcDepartmentDashboardSettings(
        showDashboard: showDashboard ?? this.showDashboard,
        allowDepartmentSwitching:
            allowDepartmentSwitching ?? this.allowDepartmentSwitching,
      );
}
