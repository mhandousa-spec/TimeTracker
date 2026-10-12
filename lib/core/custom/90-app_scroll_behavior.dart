/// Module: Core · Custom · Scroll Behavior
///
///*************************** FILE INFO ****************************///
/// File Name: 90-app_scroll_behavior.dart
/// Purpose: Declares `AppScrollBehavior` and `NoScrollbar`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// One scroll style for a whole subtree: no scrollbar track, no overscroll
/// glow, and a bouncing list that can always be dragged.
///
/// WHY THIS EXISTS
/// ---------------
/// Flutter draws a scrollbar on desktop and web for every `Scrollable` whose
/// `ScrollBehavior` allows it, so a page that scrolls by a few pixels grows a
/// grey track down its right edge — over the card, over the action row, and
/// on top of anything the design put there. Half a dozen screens around the
/// app already fixed it locally with the same
/// `ScrollConfiguration(behavior: …copyWith(scrollbars: false))` incantation,
/// each one covering only itself and only until the next screen is written.
///
/// A `ScrollConfiguration` is inherited, so ONE of these near the root of a
/// module covers every list, grid and scroll view inside it — including
/// screens that do not exist yet.
///
/// PHYSICS
/// -------
/// `AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())` — iOS-style
/// bounce, and scrollable even when the content is shorter than the viewport,
/// so a pull-to-refresh gesture and a short page still respond to a drag.
///
/// A scroll view that passes its OWN `physics:` still wins: explicit physics on
/// a widget override the behavior's. That is deliberate — the nested lists that
/// set `NeverScrollableScrollPhysics` to defer to their parent must keep doing
/// so, and this must not turn them into independent scrollers.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  /// Drag with a mouse as well as a finger. Without this a desktop build with
  /// no scrollbar has no way at all to move a list — the track was the only
  /// affordance, and removing it would have taken the interaction with it.
  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.unknown,
      };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  /// No blue stretch/glow at the ends either. The bounce below is the overscroll
  /// feedback; two at once reads as a rendering fault.
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());
}

/// Applies [AppScrollBehavior] to everything below it.
///
/// Wrap a MODULE ROOT with this, not individual pages — the point is that a
/// screen added next month inherits the rule instead of having to remember it.
class NoScrollbar extends StatelessWidget {
  const NoScrollbar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
        behavior: const AppScrollBehavior(),
        child: child,
      );
}
