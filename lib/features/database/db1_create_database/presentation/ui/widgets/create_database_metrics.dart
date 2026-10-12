/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_metrics.dart
/// Purpose: Declares `CreateDatabaseMetrics`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The one place the three layouts differ.
///
/// Figma frames measured:
///   iPad HORIZONTAL  1024 x 782  (node 7398:6137)
///   iPad VERTICAL     768 x 782  (node 7398:6214)
///   PHONE             375 x 912  (nodes 7398:12919 / 12978 / 13037)
///
/// Every other number in the card is identical between the two — same 15pt
/// card padding, same 36pt field height, same 72pt description box, same
/// 150x38 buttons. Only the outer inset and the resulting field width move,
/// and the field width falls out of the layout on its own because the two
/// title fields sit in `buildResponsiveFields`, which splits the row into two
/// `Expanded`s:
///
///   H: (865 - 30 padding - 15 gap) / 2 = 410  <- matches Figma 7398:6177
///   V: (665 - 30 padding - 15 gap) / 2 = 310  <- matches Figma 7398:6262
///
/// So there is no per-orientation field width here on purpose. Hard-coding
/// one would fight the layout instead of describing it.
///
/// PHONE, added 15/8/2026 from the mobile band of the same Figma section.
/// The card is 345 wide inside a 375 frame — 15pt page margins — and every
/// field runs full width, because `buildResponsiveFields` already stacks its
/// two slots below 600px. So the phone tier changes only three numbers: no
/// extra inset, the standard 135pt buttons instead of the iPad's 150, and a
/// 65pt avatar that happens to match the tablet one. Everything else is the
/// same card, which is why this stayed one class rather than becoming a
/// phone-specific layout file.

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/90-app_scroll_behavior.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CreateDatabaseMetrics {
  const CreateDatabaseMetrics._({
    required this.isLandscape,
    required this.isPhone,
    required this.isNarrow,
  });

  /// Reads the orientation the same way the rest of the app does —
  /// `context.isTabletLandscape` keys off width >= 600 && landscape, NOT
  /// `isTablet` (shortestSide). See ContextExtension's note on why those two
  /// are not interchangeable.
  factory CreateDatabaseMetrics.of(BuildContext context) =>
      CreateDatabaseMetrics._(
        isLandscape: context.isTabletLandscape,
        isPhone: context.isPhone,
        isNarrow: CreateDatabaseMetrics.isNarrowWindow(context),
      );

  final bool isLandscape;

  /// True on a phone-sized DEVICE (shortestSide < 600) — in either orientation.
  final bool isPhone;

  /// True when the WINDOW is under 600pt wide, whatever device it is on.
  ///
  /// NOT the same question as [isPhone], and the difference is the whole reason
  /// this exists. A phone held sideways is 812 x 375: `isPhone` is true (the
  /// device is small) and `isNarrow` is false (the window is not). Every layout
  /// decision in this module is about how much WIDTH there is — whether two
  /// fields fit side by side, whether a toolbar has to stack — so those read
  /// this. Decisions about the device itself (touch targets, button width)
  /// read [isPhone].
  ///
  /// 600 is the shell's own number, not a new one: see [pageScroll].
  final bool isNarrow;

  /// The predicate `SideFrameMasterServices` itself branches on.
  ///
  /// Named rather than inlined so the two cannot drift: if the shell's
  /// breakpoint ever moves, this is the one place that follows it.
  static bool isNarrowWindow(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  /// Wraps a page body in its own scroll view — EXCEPT inside the shell's own.
  ///
  /// `SideFrameMasterServices` has two shells and picks between them on
  /// `screenWidth < 600`. The WIDE shell hands its child a BOUNDED height
  /// (`Expanded(child: child!)`), so each page has to scroll itself or a tall
  /// card overflows. The NARROW shell IS a `SingleChildScrollView` and hands
  /// the child UNBOUNDED height — and a second scroll view inside that throws
  /// "Vertical viewport was given unbounded height" the moment the page opens.
  ///
  /// Both wizard screens hit this, so the rule lives here once rather than as
  /// three copies of the same ternary.
  ///
  /// KEYED OFF WINDOW WIDTH, NOT `isPhone` (17/8/2026). It used to ask
  /// `context.isPhone`, which is `shortestSide < 600` — a DEVICE question. The
  /// shell asks `width < 600`, a WINDOW one. They agree on a tablet and on a
  /// phone held upright, and disagree on exactly one configuration: a phone in
  /// LANDSCAPE, 812 x 375. There `isPhone` was true, so this returned the child
  /// bare, while the shell saw 812 and took the wide branch — a bounded height
  /// with nothing to scroll it. Every screen in this module was clipped at the
  /// fold in phone landscape with no way to reach the buttons. Asking the same
  /// question the shell asks is what makes the two halves agree.
  /// NO SCROLLBAR TRACK (16/8/2026). On desktop and web Flutter draws one down
  /// the right edge of every scroll view, over the card and the action row.
  /// [NoScrollbar] also supplies the bouncing, always-draggable physics and
  /// restores mouse dragging, which the track was the only substitute for.
  ///
  /// Belt and braces with the `NoScrollbar` at `DatabaseModuleEntry`: that one
  /// covers the module's own Navigator, but on a PHONE the entry has no
  /// Navigator and the wizard's routes are pushed to the root — outside it.
  /// This is inside every page either way.
  static Widget pageScroll(BuildContext context, {required Widget child}) =>
      NoScrollbar(
        child: isNarrowWindow(context)
            ? child
            : SingleChildScrollView(child: child),
      );

  // ── Page ─────────────────────────────────────────────────────────────────

  /// Horizontal inset added on top of the 15.sp the page shell already
  /// applies. Figma: card starts 30pt right of the nav rail on landscape,
  /// 15pt on portrait, and 15pt on the phone — so the phone adds nothing,
  /// same as the portrait tablet.
  double get extraHorizontalInset => (isLandscape && !isPhone) ? 0.w : 0;

  /// Gap between the breadcrumb row and the card. Figma: 173 -> 203 (H).
  double get breadcrumbToCard => 30.h;

  /// Gap between the card and the action row. Figma: card ends 690,
  /// buttons start 710 (H) / card ends 675, buttons start 695 (V).
  double get cardToActions => 20.h;

  // ── Card ─────────────────────────────────────────────────────────────────

  /// Uniform padding inside the white card. Figma: card x=96 w=865, first
  /// content x=111 -> 15 on every side, both orientations.
  EdgeInsets get cardPadding => EdgeInsets.all(15.sp);

  /// Figma corner radius on `Rectangle 34625249`.
  double get cardRadius => 8.r;

  // ── Fields ───────────────────────────────────────────────────────────────

  /// Unscaled Figma heights. `CustomTextField.height` is documented as
  /// "interpreted in .h" and applies `.h` internally, so it must be handed the
  /// raw design value — the scaled getters below are for callers that size a
  /// plain box themselves.
  static const double figmaFieldHeight = 36;
  static const double figmaDescriptionHeight = 72;

  /// Single-line field height (title, dropdown). Figma: 36.
  double get fieldHeight => figmaFieldHeight.h;

  /// Multiline description box height. Figma: 72.
  double get descriptionHeight => figmaDescriptionHeight.h;

  /// Horizontal gap between the English and Arabic columns. Figma: 15.
  double get columnGap => 15.w;

  /// Vertical gap between one labelled block and the next. Figma: ~15.
  double get blockGap => 15.h;

  // ── Cover picker ─────────────────────────────────────────────────────────

  /// Figma `Ellipse 544` is 65x65 -> radius 32.5.
  double get avatarRadius => 32.5.r;

  /// Figma `Ellipse 545` (the camera badge) is 24x24 -> radius 12.
  double get badgeRadius => 12.r;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Figma buttons are 150 wide on both iPad orientations, which is wider
  /// than ButtonSizing's 135.sp tablet default — so it is passed as
  /// `exactWidth` rather than left to ButtonSizing. Height and radius still
  /// come from ButtonSizing, so these buttons stay in step with the rest of
  /// the app.
  ///
  /// The phone frame draws them at 135 (`Discard` x=15 w=135, primary
  /// x=225 w=135 in a 375 frame). That is passed explicitly too: left to
  /// ButtonSizing, a phone button whose label does not fit its 38.sp mobile
  /// width falls back to hugging its text, so "Discard" and "Create" would
  /// come out two different widths and stop lining up with the page margins.
  double get actionButtonWidth => isPhone ? 135.w : 150.w;

  /// Gap between the breadcrumb/back row and the card, phone included.
  ///
  /// Figma phone: title centred at y=80.5, card at y=129 — call it 30, the
  /// same rhythm the tablet uses, rather than a second number that only
  /// differs by rounding.
  double get headerToCard => breadcrumbToCard;
}
