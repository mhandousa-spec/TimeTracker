/// Module: database / db2_database_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: database_details_metrics.dart
/// Purpose: Declares `DatabaseDetailsMetrics`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The one place this section's layout numbers live — the same job
/// `CreateDatabaseMetrics` does for the create wizard, and the same rule:
/// if a number came off the Figma, it is named here with the node it came
/// from, not typed into a widget.
///
/// FRAMES MEASURED (Editing Database Access, the densest screen in the section)
/// ---------------------------------------------------------------------------
///   1024 x 802   7398:10176   cards view
///    768 x 802   7398:10458   cards view
///    768 x 802   7398:19187   list view (the view toggle lives here; the
///                             768 cards frame simply omits it)
///
/// WHAT THE TWO WIDTHS ACTUALLY SHARE
/// ----------------------------------
/// Almost everything. Stacked side by side the frames differ in exactly two
/// ways — the card is 865 wide against 655, and the page inset is 30 against
/// 15 — and BOTH of those already fall out of `CreateDatabaseMetrics`. So this
/// class delegates to it rather than restating them, and adds only what the
/// details section introduces.
///
/// The numbers that are NOT proportional are the interesting ones. The person
/// card's three fields measure 150 / 150 / 135 in the 655-wide card AND in the
/// 865-wide one, left-aligned, leaving 141pt of empty card at 768 and 351pt at
/// 1024. That is deliberate in the design — a date field does not get more
/// readable by being 280pt wide — and it is why this file exists: laid out
/// with `Expanded` the row looks "responsive" and looks nothing like the
/// design. Same story for the Department filter (150 in both) and the two view
/// toggles (38 x 38 in both).

import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';

class DatabaseDetailsMetrics {
  const DatabaseDetailsMetrics._(this.base);

  /// Everything the create wizard already measured — card padding, card
  /// radius, the page inset, the 150pt action buttons, `blockGap`,
  /// `cardToActions`. Exposed rather than re-wrapped so a caller can reach
  /// `metrics.base.cardPadding` and get the SAME value the create card uses.
  final CreateDatabaseMetrics base;

  factory DatabaseDetailsMetrics.of(BuildContext context) =>
      DatabaseDetailsMetrics._(CreateDatabaseMetrics.of(context));

  bool get isPhone => base.isPhone;

  // ── Breadcrumb ───────────────────────────────────────────────────────────

  /// Whether the editing screens show the "Database" root crumb.
  ///
  /// The two frames genuinely disagree, and it is not an oversight — it is the
  /// crumb row running out of room. `Frame 1597882407` is 672 wide at 1024
  /// and reads "Database > Database Name > Editing Database Access"
  /// (7398:10209); the same frame is 519 wide at 768 and reads
  /// "Database Name > Editing Database Access" (7398:10491). Three crumbs plus
  /// two chevrons do not fit beside a 66pt nav rail at 768.
  ///
  /// `isLandscape` separates them exactly: the 1024 frames are 1024 x 768 and
  /// the 768 ones are 768 x 802, so this is the orientation the design is
  /// keyed to, not a width guess. Dropping the root crumb costs nothing —
  /// tapping the record's own name leaves the editor either way.
  bool get showRootCrumb => base.isLandscape && !base.isPhone;

  // ── Rows above the people list ───────────────────────────────────────────

  /// Height of the search box and the Department filter beside it.
  /// Figma 7398:10496 / 10501 (768) and 7398:10215 / 10220 (1024): 38 in both.
  double get toolbarFieldHeight => 38.h;

  /// FIXED width of the Department filter — 150 at 768 (7398:10500) and 150 at
  /// 1024 (7398:10220). It does not grow with the card, so the search box
  /// takes the remainder and this is a `SizedBox`, not a flex weight.
  ///
  /// Below 600px the row stacks instead (the filter would be about 63pt here,
  /// narrower than the word "Department"), so this is unused on a phone.
  double get departmentFilterWidth => 150.w;

  /// Gap between the search box and the filter. Figma: 556 -> 571 at 768,
  /// 781 -> 796 at 1024.
  double get toolbarGap => 15.w;

  /// The list / grid toggle buttons. Figma 7398:19230 / 19234 (768) and
  /// 7398:10325 / 10329 (1024): 38 x 38, 15 apart, right-aligned to the card's
  /// inner edge.
  ///
  /// `ButtonSizing.iconButtonSize` is also 38.sp, so `customTableButton` and
  /// `customGridButton` already come out at this size — the value is named
  /// here so a change to the shared sizing shows up as a design decision
  /// rather than as a screen quietly drifting.
  double get viewToggleGap => 15.w;

  /// Gap under the toggle row, before the avatar strip. Figma 1024: toggle
  /// ends 408, avatars start 418.
  double get toggleToAvatars => 10.h;

  // ── Picked-avatar strip ──────────────────────────────────────────────────

  /// Figma `Ellipse 230`: 32 x 32 at x = 111, 151, 191, 231, 271 — a 40pt
  /// pitch, so 32 wide with an 8pt gap.
  double get avatarSize => 32.r;
  double get avatarGap => 8.w;

  /// The red remove badge on each face. Figma `Close Circle`: 10 x 10, pinned
  /// to the avatar's trailing top corner.
  double get avatarBadgeSize => 10.r;

  // ── One person's card (Figma `Frame 1597881880`) ─────────────────────────

  /// 127 in both widths — the card does not grow, only the empty space to the
  /// right of its fields does.
  double get personCardHeight => 127.h;

  /// Gap between two person cards. Figma 768: 402 + 127 = 529, next at 544.
  double get personCardGap => 15.h;

  /// Uniform padding inside a person card. Figma: card at x = 96, avatar at
  /// 111 -> 15; fields end at 112 of 127 -> 15.
  EdgeInsets get personCardPadding => EdgeInsets.all(15.sp);

  /// Figma `Ellipse 226`: 40 x 40 at (15, 15).
  double get personAvatarSize => 40.r;

  /// Gap between the avatar and the name. Figma: avatar ends at 55, name
  /// starts at 60.
  double get personAvatarGap => 5.w;

  /// The identity row's fixed columns, measured from the card's own left edge:
  /// name at 60, "Job Title:" at 208, "Department:" at 354. Those are the same
  /// offsets in the 655 card and the 865 one, so they are widths, not
  /// fractions.
  double get personNameWidth => 148.w; // 208 - 60
  double get personJobWidth => 200.w; // 354 - 208

  /// Figma `Group 1597882873`: 20 x 20, 15 from the card's trailing edge
  /// (x = 590 in the 625 card, x = 800 in the 835 one).
  double get personCheckSize => 20.r;

  /// Gap between the identity row and the field labels. Figma: avatar ends 55,
  /// "Access Begins" starts 60.
  double get personRowGap => 5.h;

  /// The three rule fields, left-aligned at FIXED widths — see this file's
  /// header for why they are not `Expanded`.
  /// Figma: Input 150 at x = 15, Input 150 at x = 180, permissions 135 at
  /// x = 349.
  double get ruleDateFieldWidth => 170.w;
  double get rulePermissionFieldWidth => 200.w;
  double get ruleFieldGap => 15.w;

  /// Below this width the three fields stop fitting side by side and stack.
  ///
  /// 150 + 15 + 150 + 15 + 135 = 465 of card width, and the card is 625 at the
  /// narrowest iPad — so this only ever triggers on a phone, which is the
  /// point: the iPad frames must never reflow into a column.
  static const double ruleRowMinWidth = 465;
}
