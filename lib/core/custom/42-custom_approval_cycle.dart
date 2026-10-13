/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: approval_cycle.dart
/// Purpose: Declares `ApprovalStep`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Reusable approval-cycle chain (extracted from
// services_management_module ApprovalCycleWidget / ApprovalCycleWidgetServices).
//
// - Mobile  : vertical chain — avatar + name/title, connected by a curved
//             elbow arrow (RTL aware).
// - Tablet  : horizontal chain wrapped into rows of [itemsPerRow], steps
//             separated by forward arrows.
//
// Self-contained: brings its own _CurvedArrowPainter so lib/core does not
// depend on feature modules.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// One approver in the cycle.
class ApprovalStep {
  final String name;
  final String title;

  /// Optional custom avatar; defaults to the shared person SVG.
  final Widget? avatar;

  const ApprovalStep({required this.name, this.title = '', this.avatar});
}

/// ```dart
/// CustomApprovalCycle(
///   steps: const [
///     ApprovalStep(name: 'Ahmed Mohammed', title: 'Marketing Manager'),
///     ApprovalStep(name: 'Sara Ali', title: 'HR Specialist'),
///   ],
/// )
/// ```
class CustomApprovalCycle extends StatelessWidget {
  static const String _defaultAvatar =
      'assets/icons_assets/main_icons_assets/male_avatar.svg';

  final List<ApprovalStep> steps;

  /// Steps per row in the tablet layout. Default 3.
  final int itemsPerRow;

  /// Force one layout regardless of screen size (null = auto by device).
  final bool? forceMobileLayout;

  /// Opt-in Figma connectors (Time Tracker owner I4, 13/10/2026): the mobile
  /// elbow arrow in [arrowColor] with a FILLED head, and [tabletArrow]
  /// (e.g. the Figma → SVG) between tablet steps instead of the chevron.
  /// Null keeps the original look for every other module.
  final Color? arrowColor;
  final Widget? tabletArrow;

  const CustomApprovalCycle({
    super.key,
    required this.steps,
    this.itemsPerRow = 3,
    this.forceMobileLayout,
    this.arrowColor,
    this.tabletArrow,
  });

  bool _isMobile(BuildContext context) =>
      forceMobileLayout ??
      MediaQuery.of(context).size.shortestSide < 600;

  bool _isArabic(BuildContext context) =>
      Localizations.maybeLocaleOf(context)?.languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return _isMobile(context)
        ? _mobileChain(context)
        : _tabletChain(context);
  }

  // ── Mobile: vertical chain with curved elbow connectors ────────────────
  Widget _mobileChain(BuildContext context) {
    final bool isArabic = _isArabic(context);
    final bool isLight = Theme.of(context).brightness == Brightness.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index != 0)
              Padding(
                padding: EdgeInsets.only(left: 25.sp, right: 25.sp),
                child: CustomPaint(
                  size: const Size(0, 60),
                  painter: _CurvedArrowPainter(
                    color: arrowColor ??
                        (isLight
                            ? AppColors.blackButton
                            : AppColors.whiteShadow),
                    isArabic: isArabic,
                    filledHead: arrowColor != null,
                  ),
                ),
              )
            else
              SizedBox(width: 2.sp),
            Padding(
              padding: EdgeInsets.only(top: 10.sp),
              child: _avatar(step, 25.sp),
            ),
            SizedBox(width: 8.sp),
            Padding(
              padding: EdgeInsets.only(top: 12.sp),
              child: _nameAndTitle(context, step),
            ),
          ],
        );
      }),
    );
  }

  // ── Tablet: rows of [itemsPerRow] steps with forward arrows ───────────
  Widget _tabletChain(BuildContext context) {
    final rows = <List<int>>[];
    for (var i = 0; i < steps.length; i += itemsPerRow) {
      rows.add(List<int>.generate(
          (i + itemsPerRow).clamp(0, steps.length) - i, (j) => i + j));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(rows.length, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(
            top: rowIndex == 0 ? 0 : 10.h,
            left: rowIndex == 0 ? 0 : 30.w,
          ),
          child: Row(
            children: [
              for (final index in rows[rowIndex]) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _avatar(steps[index], 35.r),
                    SizedBox(width: 4.w),
                    _nameAndTitle(context, steps[index]),
                  ],
                ),
                if (index != steps.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: tabletArrow ??
                        CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/chevron_right.svg",color: AppColors.secondaryText,),
                  ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // ── Shared pieces ──────────────────────────────────────────────────────
  Widget _avatar(ApprovalStep step, double size) {
    return ClipOval(
      child: step.avatar ??
          CustomSvgImage(
            assetPath: _defaultAvatar,
            width: size,
            height: size,
            fit: BoxFit.scaleDown,
          ),
    );
  }

  Widget _nameAndTitle(BuildContext context, ApprovalStep step) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.name,
          style: StyleText.fontSize12Weight500.copyWith(
            color: isLight ? AppColors.blackButton : AppColors.white,
          ),
        ),
        if (step.title.isNotEmpty) ...[
          SizedBox(height: 3.sp),
          Text(
            step.title,
            style: StyleText.fontSize10Weight400.copyWith(
              color:
                  isLight ? AppColors.secondaryText : AppColors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

/// Elbow connector with an arrowhead (RTL aware) — private copy of the
/// painter used by the services / inventory approval cycles.
class _CurvedArrowPainter extends CustomPainter {
  final Color color;
  final bool isArabic;

  /// Figma style: thinner line and a solid triangular head.
  final bool filledHead;

  _CurvedArrowPainter({required this.color, required this.isArabic, this.filledHead = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = filledHead ? 2 : 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    const double arrowSize = 6.0;
    final arrowPath = Path();

    if (isArabic) {
      // ⬅️ RTL arrow
      path.moveTo(size.width / 2 + 10, 0);
      path.lineTo(size.width / 2 + 10, size.height / 2);
      path.lineTo(size.width / 2 - 10, size.height / 2);

      arrowPath.moveTo(
          size.width / 2 - 10 + arrowSize, size.height / 2 - arrowSize);
      arrowPath.lineTo(size.width / 2 - 10, size.height / 2);
      arrowPath.lineTo(
          size.width / 2 - 10 + arrowSize, size.height / 2 + arrowSize);
    } else {
      // ➡️ LTR arrow
      path.moveTo(size.width / 2 - 10, 0);
      path.lineTo(size.width / 2 - 10, size.height / 2);
      path.lineTo(size.width / 2 + 10, size.height / 2);

      arrowPath.moveTo(
          size.width / 2 + 10 - arrowSize, size.height / 2 - arrowSize);
      arrowPath.lineTo(size.width / 2 + 10, size.height / 2);
      arrowPath.lineTo(
          size.width / 2 + 10 - arrowSize, size.height / 2 + arrowSize);
    }

    canvas.drawPath(path, paint);
    if (filledHead) {
      arrowPath.close();
      canvas.drawPath(arrowPath, Paint()..color = color..style = PaintingStyle.fill);
    } else {
      canvas.drawPath(arrowPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedArrowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.isArabic != isArabic ||
      oldDelegate.filledHead != filledHead;
}
