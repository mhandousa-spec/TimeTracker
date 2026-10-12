/// Module: settings / se8_watermark / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_screen.dart
/// Purpose: Declares `WatermarkScreen` — Settings › Home Layout › Watermark.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// Source: Figma BuJXLizpGcK5eHVBqQomXc, ROLE MANAGEMENT > Watermark >
/// "Settings Home Page" (node 7524:14303). The controls panel is 7524:14371,
/// the preview pane 7524:14443.
///
/// RESPONSIVE — WHAT IS DESIGNED AND WHAT IS DERIVED
/// -------------------------------------------------
/// Figma has ONE layout for this screen, at 1024 (desktop / iPad horizontal):
/// a fixed 280-wide controls column on the left, the preview filling the rest,
/// and the Reset / Discard / Save bar pinned at the bottom. The iPhone and iPad
/// Vertical frames in that group are Calendar and Notification leftovers from
/// the duplicated template — there is no watermark mockup at 375 or 768.
///
/// So tablet and phone here are DERIVED, following the same rules the rest of
/// this app's settings screens use rather than anything drawn:
///   * ≥ 900 — Figma's two-column layout, verbatim.
///   * 600..900 — same two columns, controls widened to 320 so the sliders and
///     their value chips do not crowd; the preview keeps the remainder.
///   * < 600 — one column: controls first, then the preview as a 16:10 card
///     underneath, and the action bar becomes full-width stacked buttons. A
///     280-wide fixed column inside a 375 phone would leave a dead gutter.
/// If those breakpoints are ever designed, this is the only file to change.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/domain/entities/watermark_settings.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/controller/watermark_cubit.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_layer.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_panel.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/ui/widgets/watermark_preview.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Width below which the screen switches to a single column.
const double kWatermarkPhoneBreakpoint = 600;

/// Width at or above which the controls column takes Figma's 280.
const double kWatermarkDesktopBreakpoint = 900;

class WatermarkScreen extends StatelessWidget {
  const WatermarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CHANGED 25/8/2026 — this used to create its own WatermarkCubit. It now
    // uses the root-level one from main.dart, which is what makes Save take
    // effect everywhere at once: the editor and every `WatermarkLayer` read and
    // write the same instance. A private cubit here would have persisted the
    // change and left every visible stamp stale until the next launch.
    context.read<WatermarkCubit>().ensureLoaded();

    // CHANGED: the page frame is SideFrameMasterServices now — the same
    // breadcrumb frame every other pushed settings page uses — in place of the
    // hand-built Scaffold > SafeArea > Padding > PaginationAppBar stack.
    //
    // TWO breadcrumb entries, not three, and this is load-bearing rather than
    // cosmetic. The Watermark card in the settings list pushes exactly ONE
    // route, so `onFirstTap` pops exactly once. A "Settings > Home Layout >
    // Watermark" trail would read better but would need two pops on
    // "Settings", tearing down SettingsLayout itself.
    //
    // The Scaffold wrapper stays because SideFrameMasterServices only supplies
    // one on phone; on tablet it returns a bare Row. Same shape
    // edit_page_request.dart uses.
    //
    // NoWatermark — ADDED 2/9/2026. THE EDITOR IS NEVER STAMPED.
    //
    // Unwrapping this screen's own route was not enough: on tablet and desktop
    // `custom_drawer.dart` wraps the ENTIRE shell body in a WatermarkLayer, and
    // this page is pushed into the settings module's nested Navigator INSIDE
    // that body. So the stamp came from an ancestor mounted long before this
    // screen existed, and no change to this route could reach it.
    //
    // [NoWatermark] is the signal that travels upwards: while it is mounted
    // every WatermarkLayer in the app hands its child back untouched. See
    // watermark_layer.dart.
    //
    // The preview pane is this screen's watermark, and it shows the DRAFT —
    // which is the point. A second stamp from the SAVED settings sat over the
    // very sliders being dragged and contradicted it.
    return NoWatermark(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          onFirstTap: () => Navigator.of(context).maybePop(),
          secondTitle: S.of(context).watermark,
          child: const _WatermarkView(),
        ),
      ),
    );
  }
}

class _WatermarkView extends StatelessWidget {
  const _WatermarkView();

  @override
  Widget build(BuildContext context) {
    // CHANGED 25/8/2026 — this listener used to raise a SnackBar. Everything
    // here now goes through `CustomDialogManager`, like the rest of the app.
    //
    // Only FAILURES are announced from here. Success is announced by the
    // confirm→success flow the button itself runs (see `_confirmSave`), so a
    // listener that also fired on success would stack a second dialog on top of
    // the first.
    //
    // `showMessage`, not `showSuccess`: it stays until dismissed. A failure is
    // something the user has to read, and showSuccess auto-closes after ~1.5s.
    return BlocConsumer<WatermarkCubit, WatermarkState>(
      listenWhen: (_, current) => current.error != null,
      listener: (BuildContext context, WatermarkState state) {
        final String? message = state.error;
        if (message == null) return;
        CustomDialogManager.showMessage(
          context: context,
          lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
          title: S.of(context).error,
          subtitle: message,
        );
      },
      builder: (BuildContext context, WatermarkState state) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final bool isPhone = width < kWatermarkPhoneBreakpoint;
            final bool isDesktop = width >= kWatermarkDesktopBreakpoint;

            // REMOVED 2/9/2026 — the "Active" switch row that used to sit here
            // (`_buildEnableRow`) and the confirm dialog behind it. The
            // watermark's on/off is the module grid now: clearing every tile in
            // "Watermark Modules" is what switches the stamp off, so a second,
            // higher-priority master switch was a duplicate control that could
            // disagree with the tiles underneath it. `WatermarkSettings.enabled`
            // went with it — see that class's header.
            // PHONE: no Expanded, and the content does not scroll itself.
            //
            // SideFrameMasterServices hands its child UNBOUNDED height on
            // phone — it is already inside the frame's own
            // SingleChildScrollView — so an Expanded here would throw, and a
            // nested scroll view would fight the outer one. The action bar
            // therefore scrolls with the page instead of being pinned; there
            // is nothing to pin it against in a scrolling frame.
            if (isPhone) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildStacked(context, state, scrollable: false),
                  SizedBox(height: 10.sp),
                  _buildActions(context, state, isPhone: true),
                  SizedBox(height: 10.sp),
                ],
              );
            }

            // TABLET / DESKTOP: the frame gives the child a bounded height
            // (`Expanded(child: child)`), so the action bar stays pinned to
            // the bottom exactly as before.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _buildTwoColumn(
                    context,
                    state,
                    isDesktop: isDesktop,
                    // Minus the SingleChildScrollView's own padding.
                    available: width - 32,
                  ),
                ),
                _buildActions(context, state, isPhone: false),
              ],
            );
          },
        );
      },
    );
  }

  // ── Confirm flow ──────────────────────────────────────────────────────────
  //
  // `CustomDialogManager.showDialogFlow` runs confirm → onConfirm → success and
  // only reaches the success step when onConfirm returns true. That is why
  // `save` returns a bool: a failed Firestore write must not be reported as a
  // success.
  //
  // There used to be a second flow here, `_confirmToggle`, behind the "Active"
  // master switch. Both switch and flow were removed on 2/9/2026.

  /// Function Name: [_confirmSave]
  ///
  /// Purpose: Confirm, write the draft, then confirm it landed.
  Future<void> _confirmSave(BuildContext context) async {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
      confirmTitle: l.saveChanges,
      confirmSubtitle: l.watermarkSaveConfirm,
      confirmYesText: l.confirm,
      confirmNoText: l.cancel,
      onConfirm: cubit.save,
      successLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_successful.json',
      successTitle: l.Successful,
      successSubtitle: l.watermarkSaved,
    );
  }

  // ── Layouts ───────────────────────────────────────────────────────────────

  /// Figma's layout: fixed controls column, preview takes the rest.
  ///
  /// SIZES HERE ARE RAW LOGICAL PIXELS, NOT `.w`/`.h`.
  ///
  /// FIXED 25/8/2026 — this column was `SizedBox(width: panelWidth.w)`, which
  /// overflowed the row by ~451,000 pixels and pushed the preview off screen
  /// entirely. `FontConstants.fontSize014` in this codebase is `0.014`, i.e.
  /// the scale extensions here are applied to FRACTIONS of the screen, not to
  /// design-pixel counts — so `280.w` does not mean "280 logical pixels", it
  /// means 280 screen-widths. Figma's numbers are already logical pixels, so
  /// they are used unscaled, and the whole file follows that rule.
  Widget _buildTwoColumn(
    BuildContext context,
    WatermarkState state, {
    required bool isDesktop,
    required double available,
  }) {
    // CHANGED 31/8/2026 — was 280 desktop / 320 tablet, measured off the Figma
    // panel. The measurement was right and the result was still too tight,
    // because the panel now carries a third card: the module grid needs six
    // 56-wide tiles plus five 6-wide gaps plus 30 of card padding = 366. At 280
    // it reflowed to four across and the field chips ellipsised.
    //
    // 380 fits Figma's six-across grid with the chips intact. The tablet value
    // stays a touch wider for the same reason it always did — the Arabic
    // "Quantity (Density)" row and its value chip crowd each other otherwise.
    final double preferred = isDesktop ? 380 : 400;

    // Never let the column out-grow the space it was given. `available` already
    // has the padding taken off, and the preview keeps a 200px floor — below
    // that the caller has switched to the stacked layout anyway, so this only
    // ever bites in the awkward middle.
    final double panelWidth =
        // Floor raised from 220 to 260 on 31/8/2026: 220 is narrower than three
        // module tiles plus padding, so the grid degraded to two across and the
        // card grew taller than the preview beside it. 260 holds four across,
        // which is the narrowest the grid still reads as a grid.
        preferred.clamp(260.0, (available - 16 - 200).clamp(260.0, preferred));

    return SingleChildScrollView(
      // padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: panelWidth,
            child: WatermarkPanel(state: state),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _PreviewCard(
              settings: state.draft,
              text: watermarkStampText(state.draft),
              // Matches the Figma preview pane's proportions at 1024.
              aspectRatio: 618 / 455,
            ),
          ),
        ],
      ),
    );
  }

  /// Phone: one column, preview under the controls.
  ///
  /// [scrollable] false when the caller is already inside a scroll view —
  /// which it is under SideFrameMasterServices on phone. Nesting two scroll
  /// views on the same axis makes the inner one swallow the drag.
  Widget _buildStacked(
    BuildContext context,
    WatermarkState state, {
    bool scrollable = true,
  }) {
    // No padding of its own when the caller is the page frame.
    //
    // SideFrameMasterServices already applies 15.sp on each side and 20.sp
    // above the child, so this `EdgeInsets.all(12)` was stacking on top of it:
    // the cards sat 27 from the edge and 12 below the breadcrumb, out of line
    // with every other settings page. `scrollable` marks exactly that caller,
    // so it decides the padding too — the standalone/tablet path keeps its 12.
    final Widget body = Padding(
      padding: scrollable ? EdgeInsets.all(12) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          WatermarkPanel(state: state),
          SizedBox(height: 12),
          _PreviewCard(
            settings: state.draft,
            text: watermarkStampText(state.draft),
            aspectRatio: 16 / 10,
          ),
        ],
      ),
    );

    return scrollable ? SingleChildScrollView(child: body) : body;
  }

  // ── Action bar ────────────────────────────────────────────────────────────

  Widget _buildActions(
    BuildContext context,
    WatermarkState state, {
    required bool isPhone,
  }) {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    final Widget reset = _ActionButton(
      label: l.resetToDefault,
      onTap: state.busy ? null : cubit.resetToDefault,
      fullWidth: isPhone,
    );

    // Discard is dead unless there is something to discard — the design draws
    // it as a plain grey button, so disabling reads correctly without a
    // separate style.
    final Widget discard = _ActionButton(
      label: l.discardChanges,
      onTap: (state.busy || !state.isDirty) ? null : cubit.discardChanges,
      fullWidth: isPhone,
    );

    final Widget save = _ActionButton(
      label: l.save,
      primary: true,
      busy: state.busy,
      onTap: (state.busy || !state.isDirty)
          ? null
          : () => _confirmSave(context),
      fullWidth: isPhone,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      // PHONE (Settings bug report p.14): the two fixed 150-wide buttons sat
      // edge to edge with no padding, so they touched the screen sides and
      // each other. They now split the bar equally, 16 in from the edges and
      // 12 apart.
      child: isPhone
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
              child: Row(
                children: <Widget>[
                  Expanded(child: discard),
                  SizedBox(width: 12.sp),
                  Expanded(child: save),
                ],
              ),
            )
          // Desktop/tablet: Figma stacks Reset above Discard on the left and
          // pins Save to the right.
          : Column(
            children: [
              SizedBox(height: 12.sp),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[

                        discard,
                      ],
                    ),
                    const Spacer(),
                    save,
                  ],
                ),
              SizedBox(height: 12.sp),
            ],
          ),
    );
  }
}

/// The white preview surface with the stamp over it.
class _PreviewCard extends StatelessWidget {
  final WatermarkSettings settings;
  final String text;
  final double aspectRatio;

  const _PreviewCard({
    required this.settings,
    required this.text,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // The three dots Figma draws top-left, marking this as a preview of
            // a window rather than a live surface.
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: <Widget>[
                  for (final Color dot in <Color>[
                    const Color(0xFFFF5F57),
                    const Color(0xFFFEBC2E),
                    const Color(0xFF28C840),
                  ]) ...<Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: dot, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 5),
                  ],
                ],
              ),
            ),
            Expanded(
              child: WatermarkPreview(settings: settings, text: text),
            ),
          ],
        ),
      ),
    );
  }
}

/// One button in the bottom bar.
///
/// Not `customButton` (core 5): that enforces an app-wide fixed width, and this
/// bar needs a hugging button on desktop and a full-width one on the phone.
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final bool busy;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
    this.busy = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color background = primary
        ? (enabled ? AppColors.primary : AppColors.greyDark)
        // Secondary actions use the shared grey + white Discard treatment.
        : AppColors.darkGrey;
    final Color foreground = primary
        ? AppColors.black
        : AppColors.white.withOpacity(enabled ? 1 : .5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: fullWidth ? double.infinity : 150,
        height: 42,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: busy && primary
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                ),
              )
            : Text(
                label,
                style: StyleText.fontSize16Weight500.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
    );
  }
}
