/// Module: Core · Custom · Hover Tooltip
/// Description: Warning icon that reveals a bulleted tooltip in an Overlay on
///              hover (desktop) or tap (touch, auto-hides after 2s). The popup
///              is clamped to the screen and flips below the icon when there
///              isn't room above. Mirrors for RTL.
/// Author: Knowticed Team

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class HoverExample extends StatefulWidget {
  const HoverExample({required this.subtitle, super.key});
  final String subtitle;

  @override
  State<HoverExample> createState() => _HoverExampleState();
}

class _HoverExampleState extends State<HoverExample> {
  OverlayEntry? _overlayEntry;
  final iconKey = GlobalKey();

  void _showPopup(BuildContext context) {
    final renderBox = iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // ── COORDINATE SPACE (fixed 2/9/2026) ────────────────────────────────
    //
    // `Positioned` inside an `OverlayEntry` is laid out in the OVERLAY's
    // coordinate space, not the screen's. This used to pass
    // `renderBox.localToGlobal(Offset.zero)` — a GLOBAL point — straight into
    // it, which is only correct when the overlay happens to start at the
    // window origin.
    //
    // It does not here. The tablet messaging layout nests its own `Navigator`
    // (see home_layout_helper.dart), and a nested Navigator brings a nested
    // Overlay with it, sitting below the sidebar and header. So the overlay's
    // own offset was being added a SECOND time and the popup landed low and
    // to the right of the icon — by exactly the overlay's origin.
    //
    // Measuring against the overlay's RenderBox gives a point already in the
    // space `Positioned` uses, wherever that overlay happens to be.
    final overlayState = Overlay.of(context);
    final overlayBox = overlayState.context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;

    final Offset offset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
    final Size iconSize = renderBox.size;

    // Bound to the OVERLAY too, for the same reason — MediaQuery's size is the
    // whole window and would let the popup clamp itself off the overlay.
    final Size bounds = overlayBox.size;
    final popupWidth = 260.sp;

    // ── PLACEMENT (rewritten 2/9/2026) ───────────────────────────────────
    //
    // The popup now hangs DIRECTLY UNDER the icon, with its leading edge on
    // the icon's leading edge, and only flips above when there is no room
    // below. Both axes were wrong before:
    //
    //   left = offset.dx - popupWidth / 2   (LTR)
    //
    // centred the 260-wide box on a 15-wide icon, so ~122pt of it hung out to
    // the LEFT and the box did not read as belonging to the icon at all —
    // that is the gap in the Create Group screenshot.
    //
    //   top = offset.dy - 30.h
    //
    // put the box 30 ABOVE the icon's top, but the box is taller than 30, so
    // it drew back down over the icon and the row beneath it. The `if (top <
    // 8)` fallback only rescued it within 8pt of the screen top.
    const double gap = 8.0;

    // BESIDE the icon on its trailing side — to the RIGHT in English, to the
    // LEFT in Arabic — and hanging DOWN from the icon's top edge.
    double left = context.isArabic
        ? offset.dx - popupWidth - gap
        : offset.dx + iconSize.width + gap;

    // Clamp to the overlay's bounds with padding
    left = left.clamp(8.0, (bounds.width - popupWidth - 8.0).clamp(8.0, double.infinity));

    // The box is sized by its text, so this is an estimate used ONLY to keep
    // the box on screen — being a little off shifts it slightly, it is never
    // clipped.
    final double estimatedHeight = 80.h;

    // Top-aligned with the icon.
    double top = offset.dy;
    if (top + estimatedHeight > bounds.height - 8) {
      top = bounds.height - estimatedHeight - 8;
    }
    if (top < 8) top = 8;

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: top,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(8),
            width: popupWidth,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '• ',
                    style: TextStyle(fontSize: 18, color: AppColors.text),
                  ),
                  TextSpan(
                    text: widget.subtitle,
                    style: TextStyle(fontSize: 12.sp, color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // The same overlay the coordinates above were measured in.
    overlayState.insert(_overlayEntry!);
  }

  void _hidePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hidePopup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: iconKey,
      onEnter: (event) => _showPopup(context),
      onExit: (event) => _hidePopup(),
      child: InkWell(
        onTap: () {
          if (_overlayEntry != null) {
            _hidePopup();
            return;
          }
          _showPopup(context);
          Future.delayed(const Duration(seconds: 2), _hidePopup);
        },
        splashColor: Colors.transparent,
        child: SvgPicture.asset(
          // Original pointed at main_icons_assets/warning.svg, which doesn't
          // exist in this project. Swap if you'd prefer a different icon.
          "assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg",
          width: 15.w,
          height: 15.h,
          colorFilter: ColorFilter.mode(
            AppColors.text,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
