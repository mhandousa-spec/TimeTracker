/// Module: services_management_module
/// Description: Entry-point router for the admin dashboard. Always resolves
///              to AdminDashBoardMasterTablet — the old width-based
///              LayoutBuilder branches all pointed at the same widget so the
///              variant router was dead code (§17).
/// Author: Amr Mesbah / Knowticed Team
/// Date: 30/8/2025
/// Dependencies: AdminDashBoardMasterTablet
/// Revision History: 30/8/2025 (Amr Mesbah) — initial version.
///                    2026-07-02 (Knowticed Team) — audit fix item 4: deleted
///                    the dead commented-out LayoutBuilder block and the
///                    unused get/get.dart import.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/pages/dashboard_admin.dart';

class AdminDashBordLayout extends StatelessWidget {
  const AdminDashBordLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // S9-P04/016: every responsive branch resolved to the same widget — the
    // variant router was dead code (§17).
    return Scaffold(
      body: AdminDashBoardMasterTablet(),
    );
  }
}
