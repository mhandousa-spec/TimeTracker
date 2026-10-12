/// Module: roles / shared_mobile_export
///
///*************************** FILE INFO ****************************///
/// File Name: mobile_export_widgets.dart
/// Purpose: The mobile-only export chrome shared by Active Directory (r4) and
///          System Logs (r5).
/// Author: Knowticed Plus team
/// Created At: 9/9/2026
///
/// WHY THIS FILE EXISTS
/// The phone export screens in Figma (MESBAH / page ROLE MANAGEMENT) are a
/// different LAYOUT from the desktop dialogs, not a narrower one: the desktop
/// export is a two-pane `Dialog` (filters on the left, preview on the right),
/// the phone export is a page of stacked fields inside one white card followed
/// by a second full-screen step. Squeezing the dialog down could never produce
/// it, so the phone gets its own screens and the dialog is left untouched for
/// tablet and desktop.
///
/// Both phone flows draw the same nine pieces, so they live here once rather
/// than being copied into r4 and r5.
///
/// EVERY VISUAL IS BUILT FROM `lib/core/custom`
/// `CustomDropdown`, `CustomTextField`, `customButton`, `customButtonWithSvg`,
/// `CustomCheckBox` and `CustomSvgImage` — no bespoke fields, no bespoke
/// buttons. What this file adds is only the Figma GEOMETRY around them.
///
/// SIZES ARE THE FIGMA NUMBERS, UNSCALED
/// `main.dart::_getDesignSize` sets ScreenUtil's design size to 375x812 in
/// phone portrait, and the Figma frames are 375 wide — so a raw design pixel
/// and a `.w` / `.h` / `.sp` unit are the same thing here. Every number below
/// is read straight off the frame; see the doc on each widget for its node.

// `hide State`: dartz exports a `State` monad that collides with
// `StatefulWidget`'s `State`, which this file declares several of. The same
// spelling every widget file in the app that touches dartz uses.
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/csv_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/features/roles/shared_mobile_export/mobile_export_person.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GEOMETRY
// ═══════════════════════════════════════════════════════════════════════════

/// The one place the Figma numbers are written down.
///
/// They are raw design pixels; call sites apply `.w` / `.h` / `.sp` so a value
/// is never scaled twice.
abstract class MobileExportMetrics {
  /// Page gutter. Every frame starts its content at x = 15 and ends it at
  /// x = 360 on a 375-wide screen.
  static const double pagePadding = 15;

  /// The white panel behind the fields — 345 wide (375 - 2*15), radius 8.
  static const double cardRadius = 8;

  /// Padding inside that panel. The first label sits 15 below the card's top
  /// edge (card top 193, first label 208) and the last field ends 15 above its
  /// bottom edge.
  static const double cardPadding = 15;

  /// Field box: 315x36, radius 4, 9 horizontal / 7 vertical padding.
  static const double fieldHeight = 36;
  static const double fieldRadius = 4;

  /// Gap between one field's bottom and the next field's label. The frame puts
  /// 69 between consecutive label tops: label (~21) + `kFieldLabelGap` (6) +
  /// field (36) leaves 6.
  static const double fieldGap = 6;

  /// Action buttons: 135x38, radius 8, 20 below the card.
  static const double buttonWidth = 135;
  static const double buttonsTopGap = 20;

  /// Employee card: 345x65, radius 8, 10 between consecutive cards
  /// (tops at 200 / 275 / 350 / …).
  static const double personCardHeight = 65;
  static const double personCardGap = 10;
  static const double avatarSize = 40;

  /// The remove badge stacked on a picked employee's avatar.
  static const double removeBadgeSize = 16;

  // Search bar: the frame's 345x38 is what `AppSearchTextField` already
  // renders (its own `height ?? 38`), so no constant is kept for it here.

  /// Date-range chip: 150x36, two per row with 15 between the columns
  /// (x = 30 and x = 195 inside a card whose content starts at x = 30).
  static const double chipWidth = 150;
  static const double chipGap = 15;
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADERS
// ═══════════════════════════════════════════════════════════════════════════

// REMOVED 9/9/2026: `MobileExportHeader`.
//
// It drew the "Controls and Management" title and the Active Directory /
// System Logs tab row from the frame. Those belong to `RoleScreen`, which
// already draws both above whichever tab is selected — the frame simply shows
// them because it is a picture of the whole phone screen, not of the tab body
// alone. Rendering them again inside the tab put a second title and a second
// tab row under the real ones.
//
// REMOVED 9/9/2026: `MobileExportBackHeader`.
//
// Both pushed screens now wear `SideFrameMasterServices`
// (core/custom/50-custom_side_frame_master.dart), the same frame Adding New
// Access and User Access Details wear. It draws the back chevron, the
// breadcrumb title, the Scaffold and the 15.sp horizontal page padding, so a
// hand-rolled header here was a second, slightly different version of all four.

// ═══════════════════════════════════════════════════════════════════════════
// CARD + FIELDS
// ═══════════════════════════════════════════════════════════════════════════

/// The white panel the export fields sit in — Figma 6975:23549 (345x705) and
/// 6976:24655 (345x688). Height is left to the content: the two frames differ
/// only by how many fields they hold.
class MobileExportCard extends StatelessWidget {
  const MobileExportCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(MobileExportMetrics.cardPadding.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(MobileExportMetrics.cardRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// "Export Details" — Figma 6975:23556, Cairo Medium 16 with -0.5061 tracking,
/// sitting between the tabs and the card.
class MobileExportSectionTitle extends StatelessWidget {
  const MobileExportSectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.text,
        letterSpacing: -0.5061,
      ),
    );
  }
}

/// One labelled dropdown row of the export form.
///
/// This is `CustomDropdown` with the frame's geometry applied and nothing
/// else: 36 tall, radius 4, filled with `AppColors.background` (#F5F5F5 —
/// the field fill inside the white card), and left on `enforceTypeScale`,
/// which is what already pins the label to 14 and the hint to 12 exactly as
/// Figma draws them.
class MobileExportDropdownField extends StatelessWidget {
  const MobileExportDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final List<DropdownItem<String>> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      label: label,
      hint: hint,
      items: items,
      value: value,
      enabled: enabled,
      onChanged: onChanged,
      height: MobileExportMetrics.fieldHeight,
      fillColor: AppColors.background,
      borderRadius:
          BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
      triggerPadding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
    );
  }
}

/// The multi-select twin of [MobileExportDropdownField].
///
/// ADDED 10/9/2026. Some of the export form's fields name a SET, not a value —
/// "Column To Export" above all, whose Arabic label has always been the plural
/// "الأعمدة المراد تصديرها". A single-value dropdown there let the admin ask
/// for exactly one column or for all twelve and for nothing in between, so the
/// three columns they actually wanted were not expressible.
///
/// `CustomMultiSelectDropdown` is the app's multi-select — it mirrors
/// `CustomDropdown` in look and behaviour, ticks each row with `CustomCheckBox`
/// and keeps the overlay open while picking. This wrapper adds exactly the same
/// Figma geometry [MobileExportDropdownField] adds and nothing else, so the two
/// field kinds are indistinguishable until the overlay opens.
///
/// THE TRIGGER ALWAYS SHOWS THE HINT (10/9/2026)
/// `alwaysShowHint: true` — the box keeps saying "Select Country" however many
/// countries are ticked, and the ticks in the overlay are the read-back. The
/// default comma-joined preview is wrong for a 36-tall box: it says the field's
/// name and its answer in the same 315 points, so the second pick ellipsises it
/// into "France, Ger…" and the field stops naming what it is for.
///
/// THE BOX MEASURES 36 AND CENTRES ITS HINT, LIKE ITS SINGLE-VALUE TWIN
/// `CustomMultiSelectDropdown` applies `height` to the decorator's CHILD by
/// default, where `CustomDropdown` wraps the whole decorator. That difference
/// cost two things: the same 9/7 padding drew a 36 box next to a 50 one,
/// because a vertical inset is ADDED to a sized child rather than absorbed by
/// it; and a 36-tall child has no text in it to take a baseline from, so
/// `InputDecorator` baseline-aligned `hintText` to the child's bottom edge and
/// the placeholder sat ON the bottom border.
///
/// `heightSizesWholeTrigger: true` puts it on `CustomDropdown`'s footing —
/// the box is clamped from outside, the child keeps its natural height, and the
/// hint is centred. Everything below is then byte-identical to
/// [MobileExportDropdownField], which is the point: the two field kinds must
/// measure and read alike sitting one above the other.
class MobileExportMultiSelectField extends StatelessWidget {
  const MobileExportMultiSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.values,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final List<MultiSelectDropdownItem<String>> items;

  /// The current picks. Empty is a legal, meaningful state — each caller says
  /// what it means; for Column To Export it means "every column".
  final List<String> values;

  /// Fires with the WHOLE new selection, not with the item that changed.
  final ValueChanged<List<String>> onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return CustomMultiSelectDropdown<String>(
      label: label,
      hint: hint,
      items: items,
      values: values,
      enabled: enabled,
      onChanged: onChanged,
      alwaysShowHint: true,
      // `CustomMultiSelectDropdown` is the one field in the app that never came
      // onto `kDropdownHintColor` — it defaults to `text` at 40% where every
      // other field uses `secondaryText` at 50%. That was invisible while the
      // hint disappeared on the first pick; with [alwaysShowHint] the hint IS
      // the field's permanent face, and these boxes sit directly under the two
      // date calendars, which do use the shared grey.
      hintStyle:
          StyleText.fontSize12Weight400.copyWith(color: kDropdownHintColor),
      height: MobileExportMetrics.fieldHeight,
      heightSizesWholeTrigger: true,
      fillColor: AppColors.background,
      borderRadius:
          BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
      triggerPadding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
    );
  }
}

/// A one line of quiet explanation between two blocks of the form — Cairo
/// Regular 12 on `secondaryText`, the same pairing the unselected chip uses.
/// It carries "No matches found" under the card and "No employees found" under
/// the search box.
///
/// ADDED 10/9/2026. "Next" enables itself only when the filters above actually
/// match something, and a filter set CAN match nothing while every field on the
/// form is filled in — Country and City are drawn from the employee directory,
/// so nothing stops the admin from asking for a city that is not in the country
/// they picked. Before this the button simply sat there grey with no way to
/// tell a contradictory filter from a broken screen.
class MobileExportNote extends StatelessWidget {
  const MobileExportNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        text,
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryText),
      ),
    );
  }
}

/// The gap between two consecutive fields inside [MobileExportCard].
class MobileExportFieldGap extends StatelessWidget {
  const MobileExportFieldGap({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: MobileExportMetrics.fieldGap.h);
}

/// A label drawn above something that is not a `CustomDropdown` — the date
/// range chips. Same 14 Cairo Medium and same `kFieldLabelGap` the dropdown
/// puts above its own box, so a chip row lines up with the fields under it.
class MobileExportFieldLabel extends StatelessWidget {
  const MobileExportFieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: kFieldLabelGap.sp),
      child: Text(
        text,
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      ),
    );
  }
}

/// One date-range chip — Figma 6976:24689..6976:24696.
///
/// Selected: `primary` fill, Cairo SemiBold 12 on `text`.
/// Unselected: `background` fill, Cairo Regular 12 on `secondaryText`.
class MobileExportChip extends StatelessWidget {
  const MobileExportChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MobileExportMetrics.fieldHeight.sp,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius:
              BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
        ),
        child: FittedBox(
          child: Text(
            label,
            style: selected
                ? StyleText.fontSize12Weight600
                    .copyWith(color: AppColors.textButton)
                : StyleText.fontSize12Weight400
                    .copyWith(color: AppColors.secondaryText),
          ),
        ),
      ),
    );
  }
}

/// The four date-range chips, two per row — Figma 6976:24687.
///
/// `Expanded` rather than a pinned 150: the frame's two columns are 150 wide
/// inside a 315 content width with 15 between them, which is exactly what two
/// equal columns and a 15 gap give — and it survives a wider phone, which a
/// hard 150 would not.
class MobileExportChipGrid extends StatelessWidget {
  const MobileExportChipGrid({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    for (int i = 0; i < labels.length; i += 2) {
      if (i > 0) {
        // 226 -> 277 between the two chip rows: 36 of chip and 15 of gap.
        rows.add(SizedBox(height: MobileExportMetrics.chipGap.h));
      }
      rows.add(
        Row(
          children: [
            Expanded(
              child: MobileExportChip(
                label: labels[i],
                selected: selectedIndex == i,
                onTap: () => onSelected(i),
              ),
            ),
            SizedBox(width: MobileExportMetrics.chipGap.w),
            Expanded(
              child: i + 1 < labels.length
                  ? MobileExportChip(
                      label: labels[i + 1],
                      selected: selectedIndex == i + 1,
                      onTap: () => onSelected(i + 1),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH + PEOPLE
// ═══════════════════════════════════════════════════════════════════════════

// REMOVED 9/9/2026: `MobileExportSearchBar`.
//
// `AppSearchTextField` (core/custom/35-custom_search_widget_custom.dart) is the
// app's one search box — it is what every other search row in the module uses,
// it already owns the magnifier, the hint colour and the 38 height, and it
// carries the fixes made to that field over time. A second search box built
// here out of `CustomTextField` would drift from it on the first change.
//
// Callers pass `expanded: false`: that widget wraps itself in an `Expanded` by
// default, which is right for the search rows that sit in a `Row` next to
// filter buttons and illegal for these two, where it is a direct child of a
// `Column`.

/// One employee row — Figma 6975:23900 (preview) and 6976:24560 (selectable).
///
/// 345x65, white, radius 8; a 40 avatar 10 in from the leading edge, then the
/// name (Cairo Medium 14 on `text`) over the department and the job title
/// (Cairo Medium 12 on `secondaryText`), and — when [onTap] is given — a tick
/// pinned to the top trailing corner.
///
/// The avatar is [MobileExportAvatar] — extracted 10/9/2026 so the picked-people
/// row can draw the same circle; the rule it applies is unchanged.
///
/// The three lines are given `height: 1.15` so all of them fit the fixed 65
/// card: Figma trims each text box to its cap height, which Flutter's default
/// ~1.4 line box does not, and at the default the third line would overflow.
class MobileExportPersonCard extends StatelessWidget {
  const MobileExportPersonCard({
    super.key,
    required this.person,
    this.onTap,
    this.selected = false,
    this.showTick = true,
  });

  final MobileExportPerson person;

  /// Null renders a read-only row (the Active Directory preview); non-null
  /// adds the tick and makes the whole card the tap target (System Logs).
  final VoidCallback? onTap;

  final bool selected;

  /// Whether a tappable card also draws the tick.
  ///
  /// ADDED 10/9/2026 for the export form's search results: those rows ARE
  /// tappable, but tapping one moves that person into the avatar row and takes
  /// the row out of the list, so a checkbox that could only ever be drawn empty
  /// would misdescribe what the row does. Defaults to true, so the picker on
  /// step 2 keeps its ticks.
  final bool showTick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: MobileExportMetrics.personCardHeight.sp,
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.circular(MobileExportMetrics.cardRadius.r),
        ),
        child: Row(
          children: [
            MobileExportAvatar(person: person),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Role QA p.48 / p.49: shown capitalised.
                    FormatHelper.capitalize(person.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.text,
                      height: 1.15,
                      letterSpacing: -0.8224,
                    ),
                  ),
                  Text(
                    // Role QA p.48 / p.49: shown capitalised.
                    FormatHelper.capitalize(person.department),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.15,
                      letterSpacing: -0.8224,
                    ),
                  ),
                  Text(
                    // Role QA p.48 / p.49: shown capitalised.
                    FormatHelper.capitalize(person.jobTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight500.copyWith(
                      color: AppColors.secondaryText,
                      height: 1.15,
                      letterSpacing: -0.8224,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null && showTick) ...[
              SizedBox(width: 10.w),
              // Top-aligned: the frame puts the 25 tick at y = 10 inside a 65
              // card, not on the vertical centre.
              //
              // The SizedBox is load-bearing. A bare `Align` in a Row is laid
              // out with an UNBOUNDED main-axis constraint, which throws — it
              // has no intrinsic width to fall back on. Pinning the slot to the
              // tick's own size and the row's content height gives the Align
              // something to align inside.
              SizedBox(
                width: 25.sp,
                height:
                    (MobileExportMetrics.personCardHeight - 20).sp,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: CustomCheckBox(isSelected: selected, size: 25.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}

/// The picked employees, drawn as a wrapping row of avatars under the search
/// box — each one carrying a remove badge stacked on its top trailing corner.
///
/// ADDED 10/9/2026. The export form can now be narrowed to named people, and a
/// list of names would cost a line each; a 40 avatar is the same identity in
/// one row-height, which is how the rest of the module shows a set of people.
///
/// The avatar itself is [MobileExportAvatar], the same http-or-gender-SVG rule
/// `MobileExportPersonCard` follows, so a picked person looks identical here
/// and on the next step.
///
/// `Wrap`, not a scrolling `Row`: an off-screen pick is a pick the user cannot
/// remove, and there is no count on screen to tell them it is there. Wrapping
/// grows the block downward instead and keeps every badge reachable.
///
/// Draws NOTHING at all when nothing is picked — no empty band, no placeholder
/// — so the form looks exactly as it did before the first pick.
class MobileExportSelectedAvatars extends StatelessWidget {
  const MobileExportSelectedAvatars({
    super.key,
    required this.people,
    required this.onRemove,
  });

  final List<MobileExportPerson> people;

  /// Fires with the id of the person whose badge was tapped.
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Wrap(
        spacing: MobileExportMetrics.personCardGap.w,
        runSpacing: MobileExportMetrics.personCardGap.h,
        children: [
          for (final MobileExportPerson person in people)
            // `Clip.none` so the badge may sit half outside the avatar's box,
            // which is what puts it ON the rim rather than inside the photo.
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Padded by the badge's overhang so the Wrap reserves room for
                // it: an unclipped child does not enlarge its parent, so
                // without this the badge of one avatar would be painted over by
                // the next avatar in the row.
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: MobileExportMetrics.removeBadgeSize.sp / 3,
                    end: MobileExportMetrics.removeBadgeSize.sp / 3,
                  ),
                  child: MobileExportAvatar(person: person),
                ),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: GestureDetector(
                    onTap: () => onRemove(person.id),
                    // The glyph is 16 but the finger target must not be: an
                    // opaque transparent pad around it takes the taps that land
                    // just off the badge, which on a 16 target is most of them.
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4.sp),
                      child: CustomSvgImage(
                        assetPath: AppAssets.cancel,
                        width: 14.sp,
                        height: 14.sp,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// One 40 circular avatar — a real photo when [MobileExportPerson.imagePath] is
/// an http(s) URL, the gender SVG otherwise.
///
/// EXTRACTED 10/9/2026 from `MobileExportPersonCard._avatar`, unchanged. The
/// picked-avatars row draws the same circle without the card around it, and two
/// copies of the URL-or-SVG rule would drift the first time one is fixed —
/// `EmployeeHelper.getEmployeeImage` hands back an .svg NAME for anyone with no
/// photo, and `AssetImage` cannot decode one, which is the whole reason the
/// rule exists.
class MobileExportAvatar extends StatelessWidget {
  const MobileExportAvatar({super.key, required this.person});

  final MobileExportPerson person;

  @override
  Widget build(BuildContext context) {
    final double radius = MobileExportMetrics.avatarSize.sp / 2;

    if (person.imagePath.startsWith('http')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary,
        backgroundImage: NetworkImage(person.imagePath),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.transparent,
      child: ClipOval(
        child: CustomSvgImage(
          assetPath: person.gender == 'male'
              ? 'assets/icons_assets/main_icons_assets/male_avatar.svg'
              : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
          width: MobileExportMetrics.avatarSize.sp,
          height: MobileExportMetrics.avatarSize.sp,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// The two action buttons every step ends with — Figma 6975:23577 / 6975:23715
/// (Clear Filter + Preview N Matches), 6976:24707 / 6976:24709 (Clear Filter +
/// Next) and 6975:23853 / 6975:24025 (Discard + Export).
///
/// The secondary sits at x = 15 and the primary's right edge at x = 360, both
/// 135x38 — so the row is a `spaceBetween` inside the page gutter. Sizes come
/// from `customButton`, which pins 38 tall and radius 8 app-wide; the 135 is
/// asked for through `width`, which that helper honours.
class MobileExportActions extends StatelessWidget {
  const MobileExportActions({
    super.key,
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryEnabled = true,
    this.primaryIcon,
    this.secondaryWidth,
    this.primaryHugsContent = false,
  });

  final String secondaryLabel;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final VoidCallback onPrimary;

  /// A disabled primary keeps its place and greys out rather than disappearing,
  /// so the row never reflows while the user is filling the form in.
  final bool primaryEnabled;

  /// Asset path for the 16 glyph the Export button carries; null draws a
  /// text-only button (Preview / Next).
  final String? primaryIcon;

  /// Width of the secondary button when it is not the standard 135 — the
  /// Active Directory frame draws its Clear Filter 150 wide (x = 15 to 165).
  final double? secondaryWidth;

  /// Lets the primary button size to its own label instead of being pinned.
  ///
  /// Needed by "Preview 142 Matches": the frame hugs that one (8 of padding,
  /// right edge on the 360 gutter) precisely because the label is longer than
  /// 135, and `customButton` centres its text inside whatever `width` it is
  /// given rather than shrinking it — so a pinned 135 would clip the count.
  final bool primaryHugsContent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: secondaryLabel,
          function: onSecondary,
          width: (secondaryWidth ?? MobileExportMetrics.buttonWidth).w,
          color: AppColors.secondaryButton,
          textColor: AppColors.text,
        ),
        if (primaryIcon == null)
          customButton(
            title: primaryLabel,
            function: primaryEnabled ? onPrimary : () {},
            // null width + wrapContent is what makes the button hug; a width
            // is only passed when the label is known to fit it.
            width: primaryHugsContent
                ? null
                : MobileExportMetrics.buttonWidth.w,
            wrapContent: primaryHugsContent,
            color:
                primaryEnabled ? AppColors.primary : AppColors.secondaryButton,
            textColor:
                primaryEnabled ? AppColors.textButton : AppColors.secondaryText,
          )
        else
          // Not `customButtonWithSvg`: that helper measures its own width from
          // the title and only honours `fixedWidth`, and the icon+label here
          // has to land on the same 135 as the button beside it. `customButton`
          // takes `width` directly, so the glyph is composed into the title row
          // through a Stack-free Row inside a SizedBox of that exact width.
          SizedBox(
            width: MobileExportMetrics.buttonWidth.w,
            child: GestureDetector(
              onTap: primaryEnabled ? onPrimary : null,
              child: Container(
                height: 38.sp,
                decoration: BoxDecoration(
                  color: primaryEnabled
                      ? AppColors.primary
                      : AppColors.secondaryButton,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomSvgImage(
                      assetPath: primaryIcon!,
                      width: 16.sp,
                      height: 16.sp,
                      color: primaryEnabled
                          ? AppColors.textButton
                          : AppColors.secondaryText,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      primaryLabel,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: primaryEnabled
                            ? AppColors.textButton
                            : AppColors.secondaryText,
                        letterSpacing: -0.5061,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILE NAME DIALOG
// ═══════════════════════════════════════════════════════════════════════════

/// The "Select All" button both list steps carry — Figma 6976:24796.
///
/// 135x38 on the trailing edge, `secondaryButton` fill, Cairo Medium 16 on
/// `text`. It is `customButton` with the frame's width, same as every other
/// button in this flow; the toggle behaviour lives in the pages, since only
/// they know what "everything" currently means.
class MobileExportSelectAllButton extends StatelessWidget {
  const MobileExportSelectAllButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return customButton(
      title: S.of(context).selectAll,
      function: onTap,
      width: MobileExportMetrics.buttonWidth.w,
      color: AppColors.secondaryButton,
      textColor: AppColors.text,
    );
  }
}

/// The "Export → File Name → Discard / Download" card both flows end on.
///
/// Figma 6975:24036 / 6976:24238: 340x192, white, radius 8, a
/// (-3, 4) blur-20 shadow at 2% black, a 30 primary disc holding the export
/// glyph, the word "Export" in Cairo Medium 16, a labelled 310-wide field and
/// the two 135x38 buttons.
///
/// REWORKED 10/9/2026 — "export page not work". It did nothing a user could
/// find, for the reason `CSVHelper.exportForUser` documents at length: the
/// phone flows wrote through `CSVHelper.exportToCSV`, which on Android throws
/// under scoped storage and on iOS succeeds into a folder no app can open. The
/// card then reported "Your CSV file has been saved" either way, because it was
/// told only true/false and false never arrived.
///
/// So this card now works the way `RoleExportDialog` does — the one export in
/// the module that has been through this bug twice and come out fixed:
///
///  * The field opens with a DEFAULT NAME ([defaultFileName]), so Download is
///    live on the first frame instead of waiting for the user to invent one.
///  * The card OWNS the export ([onExport]) instead of popping and letting the
///    caller run it. That is what lets it show the wait, keep itself open on
///    failure, and tell the three outcomes apart.
///  * The wait is drawn IN THE BUTTON ROW, held for at least
///    [_minimumProgressDuration]. A small export finishes inside one frame,
///    and a card that flickers and closes is indistinguishable from a card that
///    did nothing — which is how this keeps getting reported.
///  * A DISMISSED SAVE SHEET is neither success nor failure: nothing was
///    written and nothing broke, so the card just stays open for another try.
///  * Messages go through `CustomDialogManager` on the ROOT navigator, so they
///    stack above this card rather than under its own barrier.
class MobileExportFileNameDialog extends StatefulWidget {
  const MobileExportFileNameDialog({
    super.key,
    required this.defaultFileName,
    required this.onExport,
  });

  /// Prefills the field. Build it with [mobileExportDefaultFileName].
  final String defaultFileName;

  /// Writes the file. Left = an error message; Right = the saved path, or
  /// `CSVHelper.exportCancelled` when the user dismissed the save sheet.
  final Future<Either<String, String>> Function(String fileName) onExport;

  /// Opens the card. Resolves TRUE when a file was actually written — the
  /// caller pops its own page on true and does nothing otherwise.
  ///
  /// `useRootNavigator: true` matches `CustomDialogManager`: the roles module
  /// runs inside its own nested navigator, and a dialog pushed there would be
  /// clipped by the module frame instead of covering the screen.
  static Future<bool> show(
    BuildContext context, {
    required String defaultFileName,
    required Future<Either<String, String>> Function(String fileName) onExport,
  }) async {
    final bool? exported = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (_) => MobileExportFileNameDialog(
        defaultFileName: defaultFileName,
        onExport: onExport,
      ),
    );
    return exported ?? false;
  }

  @override
  State<MobileExportFileNameDialog> createState() =>
      _MobileExportFileNameDialogState();
}

class _MobileExportFileNameDialogState
    extends State<MobileExportFileNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.defaultFileName);

  bool _isExporting = false;

  /// How long the in-row spinner stays up at minimum. A floor, never a delay
  /// added to a slow export — see the note on the widget.
  static const Duration _minimumProgressDuration = Duration(milliseconds: 700);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _message({
    required String title,
    required String subtitle,
    required String lottiePath,
  }) {
    return CustomDialogManager.showMessage(
      context: Navigator.of(context, rootNavigator: true).context,
      title: title,
      subtitle: subtitle,
      lottiePath: lottiePath,
    );
  }

  Future<void> _download() async {
    if (_isExporting) return;

    final String fileName = _controller.text.trim();
    if (fileName.isEmpty) {
      await _message(
        title: S.of(context).error,
        subtitle: S.of(context).pleaseEnterAFileName,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
      );
      return;
    }

    setState(() => _isExporting = true);
    final DateTime shownAt = DateTime.now();

    final Either<String, String> result = await widget.onExport(fileName);

    // Hold the spinner for the rest of its minimum, if the write beat it.
    final Duration elapsed = DateTime.now().difference(shownAt);
    if (elapsed < _minimumProgressDuration) {
      await Future<void>.delayed(_minimumProgressDuration - elapsed);
    }
    if (!mounted) return;
    setState(() => _isExporting = false);

    final String? error = result.fold((String message) => message, (_) => null);
    if (error != null) {
      await _message(
        title: S.of(context).exportFailed,
        subtitle: '${S.of(context).error}: $error',
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
      );
      return;
    }

    final String savedPath =
        result.fold((_) => CSVHelper.exportCancelled, (String path) => path);
    // The user closed the save sheet without picking anywhere. Nothing was
    // written and nothing failed, so the card stays open for another try.
    if (savedPath == CSVHelper.exportCancelled) return;

    // Resolved BEFORE the pop: once this card is gone its `context` is defunct,
    // and both `S.of()` and `showDialog()` would be reading a dead element.
    final BuildContext rootContext =
        Navigator.of(context, rootNavigator: true).context;
    final String title = S.of(context).success;
    // On a phone the user chose the destination in the system sheet and the
    // path that comes back is an opaque content URI, so naming it would say
    // nothing. On desktop the folder was chosen FOR them, and "it said success
    // and I found nothing" is the whole history of this feature.
    final bool isPhone = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final String subtitle = isPhone
        ? S.of(context).exportSuccess
        : '${S.of(context).exportSuccess}\n$savedPath';

    Navigator.of(context).pop(true);

    await CustomDialogManager.showSuccess(
      context: rootContext,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/approved.json',
      title: title,
      subtitle: subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return Dialog(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 17.w),
      child: Container(
        width: 340.w,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.circular(MobileExportMetrics.cardRadius.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.02),
              offset: Offset(-3.w, 4.h),
              blurRadius: 20.r,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.sp,
                  height: 30.sp,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: CustomSvgImage(
                    assetPath: AppAssets.export,
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.textButton,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  s.export,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.text,
                    letterSpacing: -0.5061,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _controller,
              label: s.fileName,
              hint: s.textHere,
              maxLines: 1,
              // Nothing to type into while the write is running, and nothing
              // to gain from renaming a file that is already being saved.
              enabled: !_isExporting,
              height: MobileExportMetrics.fieldHeight,
              fillColor: AppColors.background,
              borderRadius:
                  BorderRadius.circular(MobileExportMetrics.fieldRadius.r),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
              // Typing has to redraw the row so Download can enable itself the
              // moment the field stops being empty.
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 11.h),
            // The wait replaces the buttons rather than covering the screen:
            // it is where the user is already looking, and with the buttons
            // gone there is nothing left to double-tap.
            if (_isExporting)
              SizedBox(height: 38.sp, child: const CircleProgressMaster())
            else
              MobileExportActions(
                secondaryLabel: s.discard,
                onSecondary: () => Navigator.of(context).pop(false),
                primaryLabel: s.download,
                primaryEnabled: _controller.text.trim().isNotEmpty,
                onPrimary: _download,
              ),
          ],
        ),
      ),
    );
  }
}

/// The name an export card opens with — "<what> Export_12 Sep 2026".
///
/// The shape `RoleExportDialog` uses, lifted here so the phone flows open with
/// a usable name too rather than an empty field the user has to fill before
/// anything can happen. The month is localized; the digits are not, which
/// matches the desktop export and keeps the name safe as a file name.
String mobileExportDefaultFileName(BuildContext context, String subject) {
  final S s = S.of(context);
  final DateTime now = DateTime.now();
  final String month = [
    s.jan, s.feb, s.mar, s.apr, s.may, s.jun,
    s.jul, s.aug, s.sep, s.oct, s.nov, s.dec,
  ][now.month - 1];
  return '${subject}_${now.day} $month ${now.year}';
}
