/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_tab_strip.dart
/// Purpose: Declares `TimeTrackerTabStrip` — the main page's tab strip
///          (Overview · Attendance · Requests · Approvals · Request Types ·
///          Locations · Employees · …), the core underlined `CustomTabs`
///          (10) — and `TtOverflowFade`, which keeps any one-row horizontal
///          strip (the tabs, the status counters) readable when it does not
///          fit: the selected item is scrolled into view and the edge that
///          hides more items fades out.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI fix round 1 — owner finding 9)
///
/// Figma HR iPad landscape `661:86558`: Cairo 18 Medium tabs, 24 apart
/// (14 / 14 on a phone), active tab yellow + underline. With all the HR
/// switches on, the tabs do not fit an iPad portrait / iPhone width (or an
/// iPad landscape one when the shell is narrow), and the strip used to end
/// in a half-cut tab with nothing telling the user it scrolls. Now:
/// - when everything fits, the strip is a plain row (nothing moves);
/// - when it does not, it scrolls sideways, the SELECTED item is always
///   scrolled fully into view (on open and on every change, with a small
///   margin so the next one peeks in), and the edge that hides more items
///   fades out instead of cutting a word in half.
/// The Figma iPad-portrait counters row (`661:20465`) also runs past the
/// frame, so the Requests / Approvals counters get the same treatment.
/// RTL: the scroll view and the fades follow the reading direction.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class TimeTrackerTabStrip extends StatelessWidget {
  const TimeTrackerTabStrip({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// Visible tab titles (already translated, unique).
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool phone = context.isPhone;
    final int index = labels.isEmpty ? 0 : selectedIndex.clamp(0, labels.length - 1);
    return TtOverflowFade(
      revealText: labels.isEmpty ? null : labels[index],
      child: CustomTabs(
        tabs: labels,
        selectedValue: selectedIndex,
        spacing: phone ? 14.w : 24.w,
        textStyle: (phone ? StyleText.fontSize14Weight500 : StyleText.fontSize18Weight500)
            .copyWith(color: AppColors.secondaryText),
        selectedColor: AppColors.yellow,
        unselectedColor: AppColors.secondaryText,
        onChanged: onChanged,
      ),
    );
  }
}

/// Wraps a [child] that holds ONE horizontal scroll view (core `CustomTabs`,
/// `StatusChipFilter`, …): fades the edge(s) that hide more content and
/// scrolls the `Text` reading [revealText] fully into view whenever it
/// changes. Nothing happens while the content fits.
class TtOverflowFade extends StatefulWidget {
  const TtOverflowFade({super.key, required this.child, this.revealText});

  final Widget child;

  /// Text of the selected item (unique inside [child]); null = no reveal.
  final String? revealText;

  @override
  State<TtOverflowFade> createState() => _TtOverflowFadeState();
}

class _TtOverflowFadeState extends State<TtOverflowFade> {
  /// More content hidden before (start side) / after (end side).
  bool _moreBefore = false;
  bool _moreAfter = false;

  @override
  void initState() {
    super.initState();
    _reveal(animate: false);
  }

  @override
  void didUpdateWidget(TtOverflowFade old) {
    super.didUpdateWidget(old);
    if (old.revealText != widget.revealText) _reveal(animate: true);
  }

  /// Function Name: [_reveal]
  ///
  /// Purpose: After the frame, scroll just enough for the selected item to
  /// be fully visible (+ a margin), never past the ends.
  ///
  /// Return type: [void]
  void _reveal({required bool animate}) {
    final String? text = widget.revealText;
    if (text == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? target = _findText(context, text);
      final RenderObject? box = target?.findRenderObject();
      final ScrollableState? scrollable = target == null ? null : Scrollable.maybeOf(target);
      if (box == null || scrollable == null || !box.attached) return;
      final ScrollPosition position = scrollable.position;
      if (!position.hasContentDimensions || position.maxScrollExtent <= 0) return;
      final RenderAbstractViewport viewport = RenderAbstractViewport.of(box);
      final double margin = 32.w;
      final double atStart = viewport.getOffsetToReveal(box, 0).offset - margin;
      final double atEnd = viewport.getOffsetToReveal(box, 1).offset + margin;
      final double kept = position.pixels.clamp(math.min(atStart, atEnd), math.max(atStart, atEnd));
      final double to = kept.clamp(position.minScrollExtent, position.maxScrollExtent);
      if ((to - position.pixels).abs() < 0.5) return;
      if (animate) {
        position.animateTo(to, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      } else {
        position.jumpTo(to);
      }
    });
  }

  /// The element of the `Text` showing [text] under [root].
  BuildContext? _findText(BuildContext root, String text) {
    BuildContext? found;
    void visit(Element e) {
      if (found != null) return;
      final Widget w = e.widget;
      if (w is Text && w.data == text) {
        found = e;
        return;
      }
      e.visitChildElements(visit);
    }

    root.visitChildElements(visit);
    return found;
  }

  bool _onMetrics(ScrollMetrics m) {
    if (m.axis != Axis.horizontal) return false;
    final bool before = m.extentBefore > 0.5;
    final bool after = m.extentAfter > 0.5;
    if (before != _moreBefore || after != _moreAfter) {
      // Metrics notifications arrive after layout; repaint on the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _moreBefore = before;
          _moreAfter = after;
        });
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection dir = Directionality.of(context);
    final double fade = 32.w;
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (ScrollMetricsNotification n) => n.depth == 0 && _onMetrics(n.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (ScrollUpdateNotification n) => n.depth == 0 && _onMetrics(n.metrics),
        // Always behind the mask (fully opaque when nothing overflows) so
        // the scroll view below keeps its state when a fade appears.
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect r) {
            final double f = r.width <= 0 ? 0 : (fade / r.width).clamp(0.0, 0.5);
            return LinearGradient(
              begin: AlignmentDirectional.centerStart.resolve(dir),
              end: AlignmentDirectional.centerEnd.resolve(dir),
              colors: <Color>[
                _moreBefore ? AppColors.transparent : AppColors.white,
                AppColors.white,
                AppColors.white,
                _moreAfter ? AppColors.transparent : AppColors.white,
              ],
              stops: <double>[0, f, 1 - f, 1],
            ).createShader(r);
          },
          child: widget.child,
        ),
      ),
    );
  }
}
