/// Module: database / db3_create_table / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_metrics.dart
/// Purpose: Declares `CreateTableMetrics`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The measurements the Creating Table card adds on top of db1's.
///
/// Figma frames measured:
///   iPad HORIZONTAL  1024 x 1142  (7398:6533 creating, 7398:6934 editing)
///   iPad VERTICAL     768 x 1142  (7398:6732 creating, 7398:7121 editing)
///   PHONE             375 x 1314  (7398:11704 creating, 7398:11833 editing)
///
/// PHONE, added 17/8/2026 from the 375-wide band of the same section (every
/// frame at x >= 31974 under banner 7398:6135). See "The phone band" below for
/// the frame-by-frame list. Three shapes change and nothing else does:
///
///   column blocks    open, side by side   ->  a collapsible accordion
///   Edit / Delete    labelled buttons     ->  38 x 38 icon squares
///   toolbars         field + control      ->  stacked, each full width
///
/// Everything else that looks phone-specific in those frames — the 15pt page
/// margin, the 8pt radius, the 36pt fields, the 135pt buttons — is a number
/// `CreateDatabaseMetrics` already carries, so it is read through `base`
/// rather than restated here.
///
/// SAME SHAPE AS `DatabaseDetailsMetrics`: it wraps `CreateDatabaseMetrics`
/// rather than re-deriving it, exposes it as [base], and adds ONLY numbers that
/// do not already exist there. The card padding, the corner radius, the block
/// gap, the 36pt field height, the 150pt buttons and the page inset are all
/// identical to the Create Database card — the Figma reuses that card wholesale
/// — so restating them here would create a second source of truth that drifts.
///
/// WHAT ACTUALLY DIFFERS BETWEEN THE TWO ORIENTATIONS
/// --------------------------------------------------
/// Only the width of the two fields inside a column block:
///
///   H: block 816 wide, fields 250 + 15 gap + 250, 15 right margin  (7398:6667)
///   V: block 616 wide, fields 200 + 15 gap + 200, 15 right margin  (7398:6869)
///
/// Everything else in the block — the 15pt inset, the 20pt icons, the 85pt
/// height — is the same number in both frames.

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';

class CreateTableMetrics {
  const CreateTableMetrics._(this.base);

  factory CreateTableMetrics.of(BuildContext context) => CreateTableMetrics._(
        CreateDatabaseMetrics.of(context),
      );

  /// Everything the Create Database card already measures. Read through this
  /// rather than duplicating: `base.cardPadding`, `base.cardRadius`,
  /// `base.blockGap`, `base.cardToActions`, `base.extraHorizontalInset`,
  /// `base.actionButtonWidth`, and the static `CreateDatabaseMetrics.pageScroll`.
  final CreateDatabaseMetrics base;

  bool get isLandscape => base.isLandscape;
  bool get isPhone => base.isPhone;

  /// The layout switch every screen in this section reads.
  ///
  /// WINDOW width, not device size — see `CreateDatabaseMetrics.isNarrow` for
  /// why those are different questions and why a phone in landscape answers
  /// them differently. Everything below that reads `isNarrow` is about whether
  /// two things fit beside each other; the touch-target sizes read [isPhone].
  bool get isNarrow => base.isNarrow;

  // ── The phone band (Figma, 375-wide frames of banner 7398:6135) ──────────
  //
  // Measured off 7398:11704 (Creating Table) and 7398:11833 (Editing Table
  // Name), cross-checked against 7398:1701 / 11517 / 12402 (Table Name
  // Details), 7398:1580 (the table card list), 7398:11623 / 12091 (the rows
  // grid), 7398:12154 (Editing Table), 7398:12254 (Import Table), 7398:12691
  // (Table Access), 7398:17598 / 17661 (Comments) and 7398:17719 / 17843
  // (Editing Table Access + Viewable Fields).
  //
  // The card is 345 wide inside a 375 frame — 15pt page margins, the same
  // margin the portrait tablet uses — so almost nothing here is a new number.
  // What genuinely changes on a phone is only ever SHAPE: things that sat in a
  // row sit in a column, and two buttons lose their labels. Those are the
  // getters below. Anything that is still just "15" reads through `base`.

  /// Whether a column block draws as a COLLAPSIBLE tile rather than as a row.
  ///
  /// The Figma's phone frames draw the blocks as an accordion (7398:11775 /
  /// 11757 collapsed at 43pt, 7398:11789 expanded at 220pt) where the iPad
  /// draws them open and side by side. That is not decoration: four open blocks
  /// at phone width are roughly 800pt of card before the buttons, so the two
  /// count fields that size them scroll off the top while you are typing into
  /// the blocks they created.
  ///
  /// `isNarrow || isPhone` rather than `isNarrow` alone — the ONE getter in
  /// this file that asks both. A phone in landscape is 812 x 375: wide enough
  /// for the iPad's row, and only 375 tall, so four open blocks bury the card
  /// under six screenfuls of scrolling. Width is why the fields stack; height
  /// is why the blocks fold. Both orientations of a phone want the accordion,
  /// so both get it.
  bool get collapsibleColumns => isNarrow || isPhone;

  /// Height of a COLLAPSED column tile. Figma 7398:11775: 43.
  double get collapsedColumnHeight => 43.h;

  /// The chevron on a collapsed tile. Figma 7398:11759: 16 x 7, so it is a
  /// wide glyph — sized off the icon scale rather than squared.
  double get columnChevronSize => 16.r;

  /// Gap between the two fields once they are stacked. Figma 7398:11789: the
  /// Data Type box ends at 101 and "Column Name" starts at 116.
  double get stackedFieldGap => 15.h;

  /// Gap between the last stacked field and the icon row under it. Figma
  /// 7398:11789: the Column Name box ends at 170, the icons sit at 185.
  double get columnIconsTopGap => 15.h;

  /// Gap between the duplicate and remove glyphs when they sit UNDER the
  /// fields. Figma 7398:11809 at x=15 and 7398:11803 at x=55 — 40 apart, wider
  /// than the 25 the iPad uses because on a phone they are the only two things
  /// on their line and a fat finger has to pick one.
  double get stackedIconGap => 20.w;

  /// Whether Edit and Delete drop their labels and become square icon buttons.
  ///
  /// Figma 7398:1701: "Access" keeps its label at 105 wide on the leading edge,
  /// while Edit (7398:1714) and Delete (7398:1753) are 38 x 38 icon squares on
  /// the trailing one. Three labelled buttons do not fit across 345, and
  /// shrinking the type until they do makes the destructive one hardest to
  /// read.
  bool get iconOnlyRowActions => isNarrow;

  /// The square those icon-only buttons occupy. Figma: 38 x 38 — which is also
  /// `ButtonSizing.iconButtonSize`, so the pair matches every other icon button
  /// in the app rather than being its own size.
  double get rowActionButtonSize => 38.sp;

  /// Whether a "field + button" or "field + filter" toolbar stacks.
  ///
  /// Below 600 the search box and the control beside it split roughly 190/150,
  /// and at that width "Deselect All" and "Department" both ellipsise to
  /// nothing useful. The Figma agrees: 7398:1580 puts the search bar at 302
  /// with only a 38pt icon beside it, and gives "+ Table" the full 345.
  bool get toolbarStacks => isNarrow;

  /// Vertical gap between the two halves of a stacked toolbar. The card's own
  /// rhythm, so a stacked toolbar spaces like the fields above it.
  double get toolbarStackGap => base.blockGap;

  // ── Column block (Figma 7398:6667 / 7398:6869) ───────────────────────────

  /// Uniform inset inside one grey column block. Figma: block x=130 w=816,
  /// first content x=145 -> 15 on every side, both orientations.
  EdgeInsets get columnBlockPadding => EdgeInsets.all(15.sp);

  /// Figma corner radius on the block's rounded rectangle. Same 8 as the card,
  /// read from `base` so the two cannot diverge.
  double get columnBlockRadius => base.cardRadius;

  /// Vertical gap between one block and the next. Figma: blocks start 681, 781,
  /// 880, 979 — 85 tall with ~15 between, the card's own rhythm.
  double get columnBlockGap => base.blockGap;

  /// Width of the Data Type dropdown and the Column Name field inside a block.
  ///
  /// The one number that moves between the two frames. Below 600px the two
  /// fields stack and run full width instead, so this is not consulted there —
  /// see `TableColumnBlock`.
  double get columnFieldWidth => isLandscape ? 250.w : 200.w;

  /// Horizontal gap between those two fields. Figma: 15 in both frames, the
  /// same gap `buildResponsiveFields` puts between the EN/AR columns.
  double get columnFieldGap => 15.w;

  /// The duplicate and remove glyphs. Figma: 20x20, sitting 45pt apart
  /// (x=16 and x=61 landscape, x=14 and x=59 portrait).
  double get columnIconSize => 20.r;
  double get columnIconGap => 25.w;

  /// Gap between the "1st Column" heading and the icon row beneath it.
  /// Figma: heading at y=15 (11 tall), icons at y=49/50.
  double get columnHeadingToIcons => 12.h;

  /// Minimum width the leading part of a block (heading + icons) is given
  /// before the two fields start to squeeze. Figma: the heading occupies 86pt
  /// in the portrait frame, the widest of the two.
  double get columnLeadingWidth => 90.w;

  // ── Card body ────────────────────────────────────────────────────────────

  /// Gap between the last labelled field of the card and the first column
  /// block. Figma H: the column-number field ends at 666, the first block
  /// starts at 681.
  double get countsToColumns => 15.h;
}
