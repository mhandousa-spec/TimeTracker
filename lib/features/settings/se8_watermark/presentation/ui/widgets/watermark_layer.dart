/// Module: settings / se8_watermark / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_layer.dart
/// Purpose: Declares `WatermarkLayer` — stamps the saved watermark over any
///          page, as a layer on top of it.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// This is the piece that makes the feature real. `WatermarkScreen` only
/// CONFIGURES the stamp; [WatermarkLayer] is what actually puts it over the
/// app, so a screenshot of any wrapped page carries the viewer's identity.
///
/// WHERE IT IS APPLIED
/// -------------------
/// Choke points, chosen because everything downstream of them is covered for
/// free — not page by page:
///   * `get_pages.dart` — all eleven pushed `Routes.settingsX` destinations go
///     through one `.map(...)`, so wrapping there covers the lot.
///   * `settings_layout.dart` — the settings shell, which covers the list and
///     every embedded right-hand panel on desktop and tablet.
///   * `home_responsive_page.dart` — the ONE widget `Modules.home` builds, on
///     every form factor. ADDED 25/8/2026.
///   * `role_screen.dart` (`RoleScreenHost`) — the ONE widget `Modules.roles`
///     builds. It hosts the module's nested Navigator, so wrapping ABOVE that
///     Navigator also stamps every page pushed inside the module (AddingNewRole,
///     RoleDetailsPage, the user-management detail pages, …). ADDED 25/8/2026.
///   * `adding_widget_page.dart` and `preview_page.dart` — home pages that are
///     pushed onto an outer navigator on the phone branch and so sit OUTSIDE
///     HomeResponsivePage's subtree. ADDED 25/8/2026.
/// Adding a settings or roles page later needs no change here: a new route
/// joins that map, a new panel sits inside the shell, a new roles page is
/// pushed into the module navigator — all already covered.
///
/// NESTING IS SAFE
/// ---------------
/// A [WatermarkLayer] inside another one hands its child straight back — see
/// [_WatermarkScope]. That is what makes the belt-and-braces wrapping above
/// correct rather than reckless: `AddingWidgetPage` is wrapped for the phone
/// path, and on tablet it is ALSO a descendant of the wrapped
/// `HomeResponsivePage` — without the guard that page would be stamped twice,
/// at double opacity and with the two grids fighting each other.
///
/// IT SHOWS THE SAVED SETTINGS, NOT THE DRAFT
/// ------------------------------------------
/// Deliberate. While an admin drags the sliders on the Watermark screen, the
/// stamp around them stays at the last saved value instead of thrashing — the
/// live preview of the draft is the preview pane's job, and having the whole
/// screen restyle under a moving thumb is disorienting.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/controller/watermark_cubit.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_preview.dart';

/// Marks a subtree as already stamped, so an inner [WatermarkLayer] does
/// nothing.
///
/// ADDED 25/8/2026. Without it, wrapping both a module shell and one of the
/// pages inside it draws the grid twice: the opacities multiply out to a much
/// darker stamp and the two staggered grids interleave into the unreadable
/// smear this feature already had to be fixed once for. With it, the OUTERMOST
/// layer wins and every inner one is a no-op — which means a call site never
/// has to know whether some ancestor already wrapped it.
class _WatermarkScope extends InheritedWidget {
  const _WatermarkScope({required this.active, required super.child});

  /// Whether the layer that placed this scope is drawing the stamp right now.
  /// CHANGED 21/9/2026: the scope is always in the tree (see [WatermarkLayer]
  /// "ONE TREE SHAPE"), so "an ancestor is stamping" is this flag, not the
  /// scope's mere presence.
  final bool active;

  @override
  bool updateShouldNotify(_WatermarkScope oldWidget) =>
      oldWidget.active != active;
}

/// How many [NoWatermark] widgets are currently mounted.
///
/// ADDED 2/9/2026. Every [WatermarkLayer] in the app watches this and hands its
/// child back untouched while it is above zero.
///
/// WHY THIS IS NOT AN InheritedWidget: the layer that stamps the Watermark
/// editor is not an ancestor the editor can reach past — it is
/// `custom_drawer.dart`'s wrap around the WHOLE shell body, mounted long before
/// the editor is pushed into the settings module's nested Navigator. The editor
/// is a DESCENDANT of the thing painting over it, and a descendant cannot
/// un-paint an ancestor's overlay. So the signal has to travel upwards, and a
/// listenable outside the tree is the only thing that does that.
///
/// A COUNTER, not a bool: two suppressing widgets can overlap during a route
/// transition (the outgoing editor is still mounted while the incoming one
/// initialises), and a bool would be cleared by the first one to dispose.
final ValueNotifier<int> watermarkSuppressionCount = ValueNotifier<int>(0);

/// Wrap a page in this and NO watermark is drawn anywhere while it is on
/// screen — including by layers above it.
///
/// ADDED 2/9/2026 for the Watermark editor, which must never be stamped: the
/// stamp is drawn from the SAVED settings, so it sat over the controls at
/// whatever the last save said while the admin was busy choosing something
/// else, competing with the live draft in the preview pane beside it.
///
/// USE THIS SPARINGLY. It suppresses the stamp app-wide for as long as it is
/// mounted, which is a security control switched off — it is right for the one
/// screen whose whole job is configuring that control, and almost certainly
/// wrong anywhere else.
class NoWatermark extends StatefulWidget {
  final Widget child;

  const NoWatermark({super.key, required this.child});

  @override
  State<NoWatermark> createState() => _NoWatermarkState();
}

class _NoWatermarkState extends State<NoWatermark> {
  /// Whether THIS widget's increment actually landed. Without it, a widget
  /// disposed before its post-frame callback ran would decrement somebody
  /// else's increment and leave the counter permanently negative-biased — the
  /// stamp would come back while an editor was still open.
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    // Deferred to after the frame, NOT called straight from initState. Bumping
    // the notifier here rebuilds the ancestor ValueListenableBuilder inside
    // `WatermarkLayer` — and that ancestor may already have been built in this
    // same pass, which is the "markNeedsBuild() called during build" assertion.
    // The cost is one frame with the stamp still up, at the very start of the
    // push transition where the page is barely on screen yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _counted = true;
      watermarkSuppressionCount.value++;
    });
  }

  @override
  void dispose() {
    if (_counted) watermarkSuppressionCount.value--;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class WatermarkLayer extends StatelessWidget {
  final Widget child;

  /// Which module this subtree belongs to, for the per-module opt-out.
  ///
  /// ADDED 31/8/2026, alongside the "Watermark Modules" grid. When set, the
  /// stamp is drawn only if that module is ticked in the saved settings.
  ///
  /// NULL MEANS ALWAYS STAMP, and that default is deliberate. Every existing
  /// call site omits it, so they all keep stamping exactly as they did — this
  /// change cannot quietly un-watermark a screen somebody forgot to update.
  /// Pass it only where the module is genuinely known: guessing wrong disables
  /// a security control, which is a worse failure than a redundant stamp.
  final Modules? module;

  const WatermarkLayer({super.key, required this.child, this.module});

  /// True when some ancestor is already stamping this subtree.
  ///
  /// Exposed for call sites that build their own overlay and want to avoid
  /// doubling up; [WatermarkLayer] itself consults it first thing in [build].
  static bool isActiveIn(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_WatermarkScope>()?.active ??
      false;

  // ── ONE TREE SHAPE (fixed 21/9/2026) ────────────────────────────────────
  //
  // Settings bug report p.4: "when press on watermark it load and open
  // personal information". This layer used to return the bare `child` when it
  // was not stamping, and `WatermarkPreview(child: _WatermarkScope(child:
  // child))` when it was. Those are different widget trees, so every switch
  // between them made Flutter throw away and REBUILD the entire subtree below.
  // The outermost layer wraps the whole app shell (custom_drawer.dart), and
  // opening the Watermark editor mounts a [NoWatermark], which turns every
  // layer off — so the shell, the Settings screen and the navigator the editor
  // had just been pushed onto were all rebuilt from scratch: a spinner, then
  // Settings on its default pane (Personal Information), editor gone. Saving
  // a watermark, or toggling a module, did the same.
  //
  // Now the tree is always `_WatermarkScope > Stack[child, stamp?]`. `child`
  // is always the Stack's first child at the same depth, so it keeps its state
  // whether the stamp is drawn, hidden or suppressed; only the painter after
  // it comes and goes.
  @override
  Widget build(BuildContext context) {
    // ADDED 2/9/2026 — the app-wide off switch, watched rather than read so a
    // [NoWatermark] mounting or disposing rebuilds every layer. It has to be
    // the OUTERMOST thing here: the layer that stamps the Watermark editor is
    // this shell's own wrap in `custom_drawer.dart`, mounted long before the
    // editor exists, so the editor cannot be excluded by anything it does
    // inside its own subtree.
    return ValueListenableBuilder<int>(
      valueListenable: watermarkSuppressionCount,
      builder: (BuildContext context, int suppressed, Widget? _) {
        final _Stamp? stamp = suppressed > 0 ? null : _stampFor(context);
        return _WatermarkScope(
          // An inner layer under an ACTIVE outer one must not stamp again; an
          // inner layer under an inactive one stamps for itself, as before.
          active: stamp != null || isActiveIn(context),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              child,
              if (stamp != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: WatermarkPainter(
                        settings: stamp.cubit.state.saved,
                        text: stamp.text,
                        textDirection: Directionality.of(context),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// What this layer should draw, or null when it should draw nothing.
  /// Same rules, in the same order, as before the 21/9/2026 change.
  _Stamp? _stampFor(BuildContext context) {
    // Already inside a stamped subtree — draw nothing here. Checked first: it
    // is cheaper than the cubit lookup and must hold while settings load.
    if (isActiveIn(context)) return null;

    // The cubit is provided at the root in main.dart. Guarded so that removing
    // it degrades to "no watermark" rather than crashing every settings page.
    final WatermarkCubit cubit;
    try {
      cubit = context.watch<WatermarkCubit>();
    } catch (_) {
      return null;
    }

    // Lazy: nothing is read from Firestore until the first wrapped page is
    // actually built, and only once for the whole app.
    cubit.ensureLoaded();

    // Per-module opt-out, checked against SAVED settings. A NULL `module`
    // still means always stamp.
    final Modules? scope = module;
    if (scope != null && !cubit.state.saved.stampsModule(scope)) return null;

    final String text = watermarkStampText(cubit.state.saved);
    if (text.trim().isEmpty) return null;

    return _Stamp(cubit, text);
  }
}

class _Stamp {
  const _Stamp(this.cubit, this.text);
  final WatermarkCubit cubit;
  final String text;
}
