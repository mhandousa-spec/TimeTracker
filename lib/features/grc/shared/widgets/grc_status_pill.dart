import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

/// Bordered, colored pill showing a status icon + label — the small badge
/// used on both the Assignment Controls and Approvals cards/details pages
/// (e.g. "Approved", "Rejected", "In Review"). Extracted because both
/// features built the exact same pill markup independently.
class GrcStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  /// Optional Figma status glyph (filled colored circle + white mark). When
  /// set it replaces [icon] and is rendered with its own colors.
  final String? svgAsset;

  const GrcStatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    this.svgAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgAsset != null)
            CustomSvgImage(assetPath: svgAsset!, width: 16.r, height: 16.r, fit: BoxFit.contain)
          else
            Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(label, style: CardStyles.value(12).copyWith(color: color)),
        ],
      ),
    );
  }
}
