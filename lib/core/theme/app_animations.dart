// ******************* FILE INFO *******************
// File Name: app_animations
// Description: Reusable, drop-in animation widgets used across the app.
//              These wrappers are PURELY visual. They never change business
//              logic: they wrap an existing `child` and animate it.
//
// Mapping (as requested):
//   • Slide  -> page components (content slides in when a page opens)
//   • Bounce -> switching the main screen view (list <-> grid)
//   • Shake  -> "are you sure" dialogs (delete/remove + logout + login errors),
//               shakes ONCE only (not continuous, to avoid being annoying)
//   • Scale  -> all other dialog boxes (except delete/remove)
//   • Size   -> tables (animate size changes)
//   • Yellow buttons -> shrink (get smaller) on press
//   • Implicit Animation -> expand/collapse with a button
//
// Module: core/animation
// *************************************************

import 'dart:math' as math;

import 'package:flutter/material.dart';

// ============================================================================
// 1. SLIDE  ->  PAGE COMPONENTS
// ----------------------------------------------------------------------------
// Wrap a page's body (or any section) with [SlideInContent]. When the widget
// is first built (i.e. the page opens) the child slides into place while
// fading in. Direction and timing are configurable.
// ============================================================================

enum SlideFrom { left, right, top, bottom }

class SlideInContent extends StatefulWidget {
  final Widget child;
  final SlideFrom from;
  final Duration duration;
  final Duration delay;
  final double offset; // distance to travel, as a fraction of the child size
  final Curve curve;
  final bool fade;

  const SlideInContent({
    Key? key,
    required this.child,
    this.from = SlideFrom.bottom,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.offset = 0.25,
    this.curve = Curves.easeOutCubic,
    this.fade = true,
  }) : super(key: key);

  @override
  State<SlideInContent> createState() => _SlideInContentState();
}

class _SlideInContentState extends State<SlideInContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  Offset get _beginOffset {
    switch (widget.from) {
      case SlideFrom.left:
        return Offset(-widget.offset, 0);
      case SlideFrom.right:
        return Offset(widget.offset, 0);
      case SlideFrom.top:
        return Offset(0, -widget.offset);
      case SlideFrom.bottom:
        return Offset(0, widget.offset);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _slide = Tween<Offset>(begin: _beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SlideTransition(position: _slide, child: widget.child);
    return widget.fade
        ? FadeTransition(opacity: _fade, child: content)
        : content;
  }
}

// ============================================================================
// 2. BOUNCE  ->  LIST / GRID VIEW SWITCH
// ----------------------------------------------------------------------------
// Wrap the area that switches between list and grid. Whenever [triggerValue]
// changes (e.g. isGridView toggles), the child bounces in.
// ============================================================================

class BounceSwitcher extends StatefulWidget {
  final Widget child;

  /// Any value that changes when the view is toggled (e.g. isGridView).
  final Object? triggerValue;
  final Duration duration;

  const BounceSwitcher({
    Key? key,
    required this.child,
    required this.triggerValue,
    this.duration = const Duration(milliseconds: 700),
  }) : super(key: key);

  @override
  State<BounceSwitcher> createState() => _BounceSwitcherState();
}

class _BounceSwitcherState extends State<BounceSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _bounce = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant BounceSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.triggerValue != widget.triggerValue) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _bounce, child: widget.child);
  }
}

/// Small helper that bounces an icon/button when tapped (for the toggle icons
/// themselves). It does NOT consume the tap — it just adds a bounce reaction.
class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const BounceTap({
    Key? key,
    required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 1.2)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap == null ? null : _play,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ============================================================================
// 3. SHAKE  ->  "ARE YOU SURE" DIALOGS / LOGIN ERRORS  (SHAKES ONCE)
// ----------------------------------------------------------------------------
// Wrap the confirm-dialog content (delete / remove / logout) with [ShakeOnce].
// By default it shakes a single time when shown. To trigger a shake on demand
// (e.g. a login error), give it a GlobalKey<ShakeOnceState> and call
// `key.currentState?.shake()`.
// ============================================================================

class ShakeOnce extends StatefulWidget {
  final Widget child;

  /// Shake one time automatically when first shown.
  final bool autoPlay;
  final Duration duration;
  final double magnitude; // max horizontal travel in logical pixels

  const ShakeOnce({
    Key? key,
    required this.child,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 500),
    this.magnitude = 12.0,
  }) : super(key: key);

  @override
  State<ShakeOnce> createState() => ShakeOnceState();
}

class ShakeOnceState extends State<ShakeOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) shake();
      });
    }
  }

  /// Trigger a single shake. Safe to call multiple times.
  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 3 oscillations that decay to zero -> "shake once" feel.
        final dx = math.sin(_controller.value * math.pi * 3) *
            widget.magnitude *
            (1 - _controller.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

// ============================================================================
// 4. SCALE  ->  ALL OTHER DIALOGS (except delete/remove)
// ----------------------------------------------------------------------------
// Wrap the dialog content with [ScaleInContent]; it scales up + fades in when shown.
// You can also use [showScaleDialog] as a drop-in for showDialog when you want
// the scale entrance handled by the route transition.
// ============================================================================

class ScaleInContent extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final Curve curve;
  final bool fade;

  const ScaleInContent({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.beginScale = 0.85,
    this.curve = Curves.easeOutBack,
    this.fade = true,
  }) : super(key: key);

  @override
  State<ScaleInContent> createState() => _ScaleInContentState();
}

class _ScaleInContentState extends State<ScaleInContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scale = Tween<double>(begin: widget.beginScale, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaled = ScaleTransition(scale: _scale, child: widget.child);
    return widget.fade
        ? FadeTransition(opacity: _fade, child: scaled)
        : scaled;
  }
}

/// Drop-in replacement for showDialog that adds a scale + fade entrance.
/// Use for non-destructive dialogs. Keeps the same return type as showDialog.
Future<T?> showScaleDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel:
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: duration,
    pageBuilder: (ctx, a1, a2) => builder(ctx),
    transitionBuilder: (ctx, anim, secondary, child) {
      final curved =
          CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return Transform.scale(
        scale: Tween<double>(begin: 0.85, end: 1.0).evaluate(curved),
        child: Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: child,
        ),
      );
    },
  );
}

// ============================================================================
// 5. SIZE  ->  TABLES
// ----------------------------------------------------------------------------
// Wrap a table with [AnimatedSizeWrap] so that whenever its size changes
// (rows added/removed, expand/collapse) the change is animated smoothly.
// ============================================================================

class AnimatedSizeWrap extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const AnimatedSizeWrap({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.topCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: child,
    );
  }
}

// ============================================================================
// 6. YELLOW BUTTONS  ->  SHRINK ON PRESS
// ----------------------------------------------------------------------------
// Wrap a yellow button with [ShrinkOnTap]. It scales the button down slightly
// while pressed, then springs back. It uses Listener (pointer events) so it
// does NOT consume the button's own onTap/onPressed — the underlying button
// still works exactly as before.
// ============================================================================

class ShrinkOnTap extends StatefulWidget {
  final Widget child;
  final double scale; // pressed scale (e.g. 0.92 = 8% smaller)
  final Duration duration;

  const ShrinkOnTap({
    Key? key,
    required this.child,
    this.scale = 0.92,
    this.duration = const Duration(milliseconds: 120),
  }) : super(key: key);

  @override
  State<ShrinkOnTap> createState() => _ShrinkOnTapState();
}

class _ShrinkOnTapState extends State<ShrinkOnTap> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// 7. IMPLICIT ANIMATION  ->  BUTTON EXPAND
// ----------------------------------------------------------------------------
// Wrap collapsible content with [ImplicitExpand] and flip [expanded] from a
// button to expand/collapse it with a smooth implicit size+fade animation.
// ============================================================================

class ImplicitExpand extends StatelessWidget {
  final bool expanded;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const ImplicitExpand({
    Key? key,
    required this.expanded,
    required this.child,
    this.duration = const Duration(milliseconds: 350),
    this.curve = Curves.easeInOut,
    this.alignment = Alignment.topCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      child: AnimatedOpacity(
        duration: duration,
        opacity: expanded ? 1.0 : 0.0,
        child: expanded
            ? child
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }
}
