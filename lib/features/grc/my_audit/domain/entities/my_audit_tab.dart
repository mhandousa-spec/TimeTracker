import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

/// The 6 tabs shown on the Owner's My Audits list. Unlike [MyAuditStatus],
/// `overdue` here is a real, always re-derived UI state — see
/// `computeMyAuditTab` and `buildMyAuditItems` in my_audit_resolver.dart.
enum MyAuditTab {
  pending,
  outstanding,
  scored,
  rejected,
  overdue;

  String get label {
    switch (this) {
      case MyAuditTab.pending:
        return 'Pending';
      case MyAuditTab.outstanding:
        return 'Outstanding';
      case MyAuditTab.scored:
        return 'Scored';
      case MyAuditTab.rejected:
        return 'Rejected';
      case MyAuditTab.overdue:
        return 'Overdue';
    }
  }
}

/// Visual identity (color + icon) for one [MyAuditTab], shared by the
/// status pill on the card, tab bar, and details page — same convention as
/// `AssignmentControlTabStyle`/`ApprovalStatusStyle`.
class MyAuditTabStyle {
  final Color color;
  final IconData icon;

  /// Figma (MAGDY › My Audit) status badge glyph and border/label color.
  final String svgAsset;
  final Color pillColor;

  const MyAuditTabStyle({
    required this.color,
    required this.icon,
    required this.svgAsset,
    required this.pillColor,
  });

  static const String _main = 'assets/icons_assets/main_icons_assets';
  static const String _watermark = 'assets/icons_assets/watermark';

  static MyAuditTabStyle of(MyAuditTab tab) {
    switch (tab) {
      case MyAuditTab.pending:
        return MyAuditTabStyle(
          color: AppColors.warning,
          icon: Icons.schedule,
          svgAsset: '$_main/status_pending_check_cross_orange.svg',
          pillColor: const Color(0xFFFF814A),
        );
      case MyAuditTab.outstanding:
        return MyAuditTabStyle(
          color: AppColors.warning,
          icon: Icons.hourglass_bottom,
          svgAsset: '$_watermark/Outstanding.svg',
          pillColor: const Color(0xFFFFDE59),
        );
      case MyAuditTab.scored:
        return const MyAuditTabStyle(
          color: Colors.green,
          icon: Icons.check_circle,
          svgAsset: '$_main/approve_icon.svg',
          pillColor: Color(0xFF4BB609),
        );
      case MyAuditTab.rejected:
        return const MyAuditTabStyle(
          color: Colors.red,
          icon: Icons.block,
          svgAsset: '$_main/status_rejected_stamp_red.svg',
          pillColor: Color(0xFFDF1C1C),
        );
      case MyAuditTab.overdue:
        return const MyAuditTabStyle(
          color: Colors.red,
          icon: Icons.alarm,
          svgAsset: '$_watermark/Overdue.svg',
          pillColor: Color(0xFFA51515),
        );
    }
  }
}
