/// Module: settings / se8_watermark / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_panel.dart
/// Purpose: Declares `WatermarkPanel` — the "Watermark Content",
///          "Watermark Modules" and "Watermark Style" cards.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
/// Updated: 31/8/2026 - Rebuilt against the Figma frame. Three things the
///          previous build was missing or getting wrong:
///
///          1. THE "WATERMARK MODULES" CARD DID NOT EXIST. Figma draws a grid
///             of module tiles between Content and Style; there was no card
///             here and no field behind it on the entity. The grid is built
///             from `kWatermarkModules` so icons and names come from
///             `modules_enum.dart` rather than being restated in this feature.
///
///          2. THE "STYLE" ROW DID NOT EXIST. Figma opens the Style card with a
///             Text / Bubble radio pair. Added, backed by the new
///             `WatermarkSettings.styleMode`.
///
///          3. NO TEXT ELLIPSISES ANY MORE. The field chips were fixed-width
///             `Expanded` cells with `TextOverflow.ellipsis`, so they rendered
///             "Employee E…", "Employee Ph…", "Employee Na…" — three labels the
///             reader cannot tell apart, which is the entire job of a segmented
///             control. Chips now size to their own text and wrap; slider
///             labels wrap instead of truncating. There is no
///             `TextOverflow.ellipsis` left in this file, deliberately: every
///             string here is a control label, and a truncated control label is
///             a broken control.
///
/// Source: Figma BuJXLizpGcK5eHVBqQomXc, ROLE MANAGEMENT > "Settings Home Page"
/// (node 4717:8596). Cards: radius 8, padding 15, 10 between them.
///
/// TYPOGRAPHY: every `Text` here goes through
/// `StyleText.<token>.copyWith(fontSize: ...)` — never a bare `TextStyle` — so
/// family and weight track the app theme and only the size is local. The sizes
/// themselves live in `_Type` below rather than scattered through the file.
///
/// ICONS: `assets/icons_assets/watermark/`. The checkbox and chevron there are
/// byte-for-byte copies of the app's own `checkbox_checked_yellow`,
/// `checkbox_empty_outline` and `chevron_down` — the same glyphs the design
/// draws. Module tile icons come from `Modules.iconPath`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/61-custom_color_picker.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/domain/entities/watermark_settings.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/presentation/controller/watermark_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The three SVGs this panel draws itself. See the note in this file's header.
abstract class WatermarkSvg {
  static const String checkboxChecked =
      'assets/icons_assets/watermark/watermark_checkbox_checked.svg';
  static const String checkboxUnchecked =
      'assets/icons_assets/watermark/watermark_checkbox_unchecked.svg';
  static const String chevronDown =
      'assets/icons_assets/watermark/watermark_chevron_down.svg';
}

/// The modules from [kWatermarkModules] this account is actually allowed to
/// see.
///
/// ADDED 2/9/2026. The grid used to draw all fifteen tiles regardless of who
/// was looking, so an admin whose role does not include CRM or Inventory was
/// still asked to decide whether those modules carry a watermark — modules they
/// cannot open, and whose tiles do not exist in their drawer.
///
/// The gate is the SAME list the drawer rail is built from,
/// [AppDrawerCubit.allowedDrawerModules] (see `drawer_menu_item.dart` and
/// `custom_drawer.dart`), so this grid can never disagree with the rail beside
/// it: that list is already the role gate AND the company-license gate applied
/// together, and re-deriving either one here would drift the moment the drawer's
/// rules change.
///
/// `Get.find`, not `context.read`: neither cubit is provided in the widget tree
/// — both are registered through GetX — the same reason `DrawerMenuItem` takes
/// its cubit as a constructor argument.
///
/// FALLBACK IS "SHOW EVERYTHING", deliberately. If neither shell controller is
/// registered yet, or the one that is is still resolving the employee's role
/// (`isLoadingModules`), an empty intersection would render an empty card that
/// reads as broken. Showing the full list in that window is the safer failure:
/// it can only offer a choice that has no effect, never hide one the admin
/// needs.
///
/// NOTE: this filters what is DRAWN, not what is stored. A module already in
/// `settings.modules` keeps its stamp even when it is hidden here — an admin
/// who cannot see CRM must not silently un-stamp it for the whole company.
List<Modules> visibleWatermarkModules() {
  final List<Modules>? allowed = _allowedModulesForCurrentShell();
  if (allowed == null || allowed.isEmpty) return kWatermarkModules;

  // Ordered by kWatermarkModules, not by the shell: this grid follows Figma's
  // layout, and the drawer's order is the user's own custom rail order.
  return kWatermarkModules
      .where((Modules module) => allowed.contains(module))
      .toList();
}

/// The modules this account may reach, asked of whichever shell is running.
///
/// FIXED 8/9/2026 — the gate above only ever consulted [AppDrawerCubit], so it
/// worked on tablet and desktop and did nothing at all on a phone: the grid
/// drew every module regardless of role. `HomeResponsivePage._handleSizeChange`
/// DELETES `AppDrawerCubit` when the layout goes mobile and registers
/// [NavBarCubit] in its place, so on a phone the very first line —
/// `Get.isRegistered<AppDrawerCubit>()` — was always false and the function
/// returned the full list before looking at anything.
///
/// Both cubits derive their list the same way (role gate AND company licence
/// applied together), so reading whichever one exists keeps this grid in step
/// with the navigation the user actually has, on either layout, without this
/// feature re-deriving either rule for itself.
///
/// On mobile that list is the union of the bottom-bar tabs and the More page:
/// `navBarModules` holds only the handful that fit in the bar, and everything
/// else the role allows is in `moreListModules`. Either alone would hide
/// modules the user can genuinely open.
///
/// Returns null for "cannot tell yet" — a state the caller must not confuse
/// with "allowed nothing".
List<Modules>? _allowedModulesForCurrentShell() {
  // Tablet / desktop.
  if (Get.isRegistered<AppDrawerCubit>()) {
    final AppDrawerCubit drawer = Get.find<AppDrawerCubit>();
    if (drawer.isLoadingModules) return null;
    return drawer.allowedDrawerModules;
  }

  // Phone.
  if (Get.isRegistered<NavBarCubit>()) {
    final NavBarCubit navBar = Get.find<NavBarCubit>();
    if (navBar.isLoadingModules) return null;
    return <Modules>{
      ...navBar.navBarModules,
      ...navBar.moreListModules,
    }.toList();
  }

  return null;
}

/// One place for every font size in this panel.
///
/// ADDED 31/8/2026. These were bare numbers inside fifteen separate
/// `copyWith(fontSize: ...)` calls, which is how the card titles and the row
/// labels drifted apart in the first place. Sizes are Figma's, in logical
/// pixels — NOT `.sp`: see the note in `watermark_screen.dart` about the scale
/// extensions in this codebase applying to FRACTIONS of the screen rather than
/// to design-pixel counts.
abstract class _Type {
  static const double cardTitle = 14;
  static const double rowLabel = 12;

  /// Raised 11 -> 12 on 31/8/2026. The chips are equal-width `Expanded` cells
  /// with a `FittedBox` scale-down, so a size that is occasionally a touch too
  /// big shrinks gracefully — whereas one that is always too small just reads
  /// as small. 12 matches the row labels beside them.
  static const double chip = 12;
  static const double readout = 10;

  /// Raised 9 -> 10 on 31/8/2026, now that the tile width is derived from the
  /// panel rather than pinned at 56.
  static const double moduleTile = 10;
}

class WatermarkPanel extends StatelessWidget {
  final WatermarkState state;

  const WatermarkPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ContentCard(settings: state.draft),
        const SizedBox(height: 10),
        _ModulesCard(settings: state.draft),
        const SizedBox(height: 10),
        _StyleCard(settings: state.draft),
      ],
    );
  }
}

/// The card all three sections sit in.
class _Card extends StatelessWidget {
  final String title;

  /// Optional control on the title row's trailing edge. The modules card puts
  /// its Select all / Clear all toggle there.
  final Widget? trailing;
  final List<Widget> children;

  const _Card({
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Flexible so a long title wraps rather than overflowing, and no
              // ellipsis: "Watermark Modules" in Arabic ("وحدات العلامة
              // المائية") is wider than the card at this size.
              Flexible(
                child: Text(
                  title,
                  style: StyleText.fontSize16Weight500.copyWith(
                    fontSize: _Type.cardTitle,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
              // if (trailing != null) ...<Widget>[
              //   const SizedBox(width: 8),
              //   trailing!,
              // ],
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

// ── Watermark Content ───────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  final WatermarkSettings settings;

  const _ContentCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    String label(WatermarkField field) {
      switch (field) {
        case WatermarkField.employeeEmail:
          return l.employeeEmail;
        case WatermarkField.employeePhone:
          return l.employeePhone;
        case WatermarkField.employeeName:
          return l.employeeName;
      }
    }

    return _Card(
      title: l.watermarkContent,
      children: <Widget>[
        // FIXED 31/8/2026 (second pass) — the three chips were stacking one per
        // row instead of sitting side by side as Figma draws them.
        //
        // Cause: `_FieldChip` used `Container(alignment: Alignment.center)` with
        // no width. A Container with a non-null `alignment` and no size of its
        // own EXPANDS to `constraints.biggest`, and a Wrap hands its children
        // the full line width as a loose maximum — so every chip claimed the
        // whole row and only one fitted per line. The Wrap was innocent; the
        // Container was the greedy one.
        //
        // Back to a Row of `Expanded` cells, which is what Figma actually
        // shows: three equal-width chips across the card. That was the ORIGINAL
        // layout, and the reason it got replaced was ellipsis — so the fix for
        // that is inside `_FieldChip` (a scale-down instead of a truncation),
        // not a different layout out here.
        Row(
          children: <Widget>[
            for (final WatermarkField field in WatermarkField.values) ...<Widget>[
              if (field != WatermarkField.values.first) const SizedBox(width: 8),
              Expanded(
                child: _FieldChip(
                  label: label(field),
                  selected: settings.field == field,
                  onTap: () => cubit.selectField(field),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Wrap here too: "Display With" plus two labelled checkboxes overflows a
        // narrow card once the Arabic strings are in ("العرض مع", "التاريخ",
        // "الوقت" are all wider than the English).
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              l.displayWith,
              style: StyleText.fontSize16Weight500.copyWith(
                fontSize: _Type.rowLabel,
                color: AppColors.secondaryText,
              ),
            ),
            _CheckOption(
              label: l.date,
              checked: settings.showDate,
              onChanged: cubit.toggleDate,
            ),
            _CheckOption(
              label: l.time,
              checked: settings.showTime,
              onChanged: cubit.toggleTime,
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FieldChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        // Height only. NO `alignment` here — that is what made this widget
        // expand to fill its parent and stack the chips vertically. Centring is
        // done by the `Center` below, which sizes to its parent instead of
        // growing it.
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          // ADDED — an outline on the unselected chips. Their fill is
          // `AppColors.field`, which in dark mode sits almost on top of
          // `AppColors.card`, so the two unselected chips read as bare floating
          // text with no control around them. Figma shows three distinct
          // buttons; the border is what makes that true in both themes.
          border: selected
              ? null
              : Border.all(color: AppColors.border, width: 1),
        ),
        child: Center(
          // FittedBox, not `TextOverflow.ellipsis`. The chips are equal-width
          // cells, so a long label in a narrow panel has to give somewhere —
          // and shrinking a point or two keeps "Employee Phone" readable,
          // whereas "Employee Ph…" does not. scaleDown never ENLARGES, so at
          // normal widths the text renders at exactly _Type.chip.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: StyleText.fontSize16Weight500.copyWith(
                fontSize: _Type.chip,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.black : AppColors.secondaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckOption extends StatelessWidget {
  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _CheckOption({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!checked),
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            checked
                ? WatermarkSvg.checkboxChecked
                : WatermarkSvg.checkboxUnchecked,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: StyleText.fontSize16Weight500.copyWith(
              fontSize: _Type.rowLabel,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Watermark Modules ───────────────────────────────────────────────────────

/// ADDED 31/8/2026. The card that was missing entirely.
///
/// Figma lays the tiles out SIX ACROSS. The first build used a fixed 56px tile
/// in a bare `Wrap`, which fitted only five in the real panel and broke the
/// design's rhythm — the sixth dropped to the next row and every row after it
/// was ragged.
///
/// FIXED 31/8/2026 (second pass): the tile width is now DERIVED from the
/// panel's measured width so six always land in a row, at whatever width the
/// panel happens to be. `LayoutBuilder` supplies that width; the column count
/// steps down only when six would each be narrower than [_minTile], which is
/// the point at which the labels stop being readable.
///
/// Still a `Wrap` rather than a `GridView`: a grid inside the panel's enclosing
/// `SingleChildScrollView` needs `shrinkWrap` plus disabled physics to avoid an
/// unbounded-height assertion, and it would pin a column count regardless.
class _ModulesCard extends StatelessWidget {
  final WatermarkSettings settings;

  const _ModulesCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    // Only the modules this account can see — see [visibleWatermarkModules].
    final List<Modules> modules = visibleWatermarkModules();

    // Measured against the VISIBLE tiles: with the grid filtered, "all" can
    // never mean the fifteen in kWatermarkModules any more.
    final bool allSelected =
        modules.every((Modules module) => settings.stampsModule(module));

    return _Card(
      title: l.watermarkModules,
      // Fifteen tiles is a lot of tapping to reach "all but one", which is the
      // usual shape of this setting.
      trailing: InkWell(
        onTap: () => cubit.setAllModules(!allSelected),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            allSelected ? l.clearAll : l.selectAll,
            style: StyleText.fontSize16Weight500.copyWith(
              fontSize: _Type.readout,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const double gap = 6;
            const double minTile = 46;

            // Six across is Figma's grid. Step down only when six would each be
            // narrower than `minTile` — below that the two-line labels start
            // breaking mid-word, which is worse than a fifth column.
            int columns = 6;
            double tile = 0;
            while (columns > 3) {
              tile = (constraints.maxWidth - gap * (columns - 1)) / columns;
              if (tile >= minTile) break;
              columns--;
            }
            // Recompute for the final column count, and floor it: a fractional
            // width that rounds UP overflows the row by a pixel and drops the
            // last tile to the next line — the exact bug this replaced.
            tile = ((constraints.maxWidth - gap * (columns - 1)) / columns)
                .floorToDouble();

            return Wrap(
              spacing: gap,
              runSpacing: 10,
              children: <Widget>[
                for (final Modules module in modules)
                  _ModuleTile(
                    module: module,
                    width: tile,
                    selected: settings.stampsModule(module),
                    onTap: () => cubit.toggleModule(module),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// One module tile: a square holding the icon, with the name UNDER it.
///
/// CHANGED 31/8/2026 (second pass). The first build drew one bordered box
/// around the icon AND the label, and outlined every tile whether selected or
/// not — fifteen boxes competing for attention, which is not what Figma shows.
///
/// Figma's tile is two separate pieces: a rounded square that holds only the
/// icon and carries the selection colour, and the label sitting below it on the
/// card background with no box of its own. Unselected tiles have NO border at
/// all — the icon and its name simply sit there in grey. That is what makes the
/// selected ones actually stand out at a glance.
class _ModuleTile extends StatelessWidget {
  final Modules module;
  final bool selected;
  final VoidCallback onTap;

  /// Measured by [_ModulesCard] so six land in a row at the panel's real width.
  final double width;

  const _ModuleTile({
    required this.module,
    required this.selected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // A selected tile is a solid brand square, so its icon has to flip to the
    // dark on-primary colour to stay visible — the same pairing the selected
    // field chip and the Save button use.
    final Color iconTint = selected ? AppColors.black : AppColors.secondaryText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // The icon square. Kept square via AspectRatio rather than a fixed
            // height so it tracks the measured tile width instead of drifting
            // out of proportion when the panel resizes.
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: SvgPicture.asset(
                  // `iconPath`, not `iconPathRole`: the two differ only for
                  // `qiyas`, and this screen is not the roles permission matrix.
                  module.iconPath,
                  colorFilter: ColorFilter.mode(iconTint, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              // Localised by `modules_enum.dart` itself, so a tile's name here
              // always matches that module's name everywhere else in the app.
              module.getModuleName,
              textAlign: TextAlign.center,
              // Two lines, and NO ellipsis: "Knowledge Hub" and "Time Tracker"
              // both need the second line, and a module the admin cannot read
              // is a module they cannot decide about.
              maxLines: 2,
              style: StyleText.fontSize16Weight500.copyWith(
                fontSize: _Type.moduleTile,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.text : AppColors.secondaryText,
                // Tightened: 9px Cairo at the default height leaves too much
                // air between the two lines of "Knowledge Hub".
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Watermark Style ─────────────────────────────────────────────────────────

class _StyleCard extends StatelessWidget {
  final WatermarkSettings settings;

  const _StyleCard({required this.settings});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);
    final WatermarkCubit cubit = context.read<WatermarkCubit>();

    return _Card(
      title: l.watermarkStyle,
      children: <Widget>[
        // ADDED 31/8/2026 — the Text / Bubble pair Figma opens this card with.
        // It had no field behind it before, so it could not be drawn at all.
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              l.watermarkStyleLabel,
              style: StyleText.fontSize16Weight500.copyWith(
                fontSize: _Type.rowLabel,
                color: AppColors.secondaryText,
              ),
            ),
            for (final WatermarkStyleMode mode in WatermarkStyleMode.values)
              _RadioOption(
                label: mode == WatermarkStyleMode.text
                    ? l.watermarkStyleText
                    : l.watermarkStyleBubble,
                selected: settings.styleMode == mode,
                onTap: () => cubit.setStyleMode(mode),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _SliderRow(
          label: l.opacity,
          // Localised numerals, like every other figure in the app.
          value:
              '${LocalizedNumber.of(context, (settings.opacity * 100).round())}%',
          slider: Slider(
            value: settings.opacity,
            min: WatermarkSettings.minOpacity,
            max: WatermarkSettings.maxOpacity,
            // Whole percents. Without divisions the slider hands back the raw
            // double and the read-out chip showed things like "23.836 px" — a
            // precision the control does not actually offer.
            divisions: 95,
            onChanged: cubit.setOpacity,
          ),
        ),
        _SliderRow(
          label: l.quantityDensity,
          value: LocalizedNumber.of(context, settings.density),
          slider: Slider(
            value: settings.density.toDouble(),
            min: WatermarkSettings.minDensity.toDouble(),
            max: WatermarkSettings.maxDensity.toDouble(),
            divisions:
                WatermarkSettings.maxDensity - WatermarkSettings.minDensity,
            onChanged: (double v) => cubit.setDensity(v.round()),
          ),
        ),
        _SliderRow(
          label: l.size,
          // Figma reads "12.0 px"; `LocalizedNumber` drops a trailing .0, so
          // this renders "12 px" / "١٢ بكسل". Keeping the numeral localised
          // matters more here than the trailing zero.
          value:
              '${LocalizedNumber.of(context, settings.fontSize.round())} ${l.px}',
          slider: Slider(
            value: settings.fontSize,
            min: WatermarkSettings.minFontSize,
            max: WatermarkSettings.maxFontSize,
            divisions:
                (WatermarkSettings.maxFontSize - WatermarkSettings.minFontSize)
                    .round(),
            onChanged: cubit.setFontSize,
          ),
        ),
        _SliderRow(
          label: l.angle,
          value: '${LocalizedNumber.of(context, settings.angle.round())}°',
          slider: Slider(
            value: settings.angle,
            min: WatermarkSettings.minAngle,
            max: WatermarkSettings.maxAngle,
            divisions: (WatermarkSettings.maxAngle - WatermarkSettings.minAngle)
                .round(),
            onChanged: cubit.setAngle,
          ),
        ),
        _ColorRow(color: settings.color, onChanged: cubit.setColor),
      ],
    );
  }
}

/// A radio option. Figma draws a ring, not Material's filled dot.
class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Drawn rather than a Material `Radio`: Radio carries its own 48px tap
          // target and internal padding, which would break this row's alignment
          // with the checkbox row in the Content card above it.
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // CHANGED 2/9/2026 — the unselected ring was `AppColors.border`,
              // which is the hairline colour used to separate surfaces. At 2px
              // on a card it read as a smudge rather than as the empty half of
              // a radio pair, so "Bubble" looked disabled next to a selected
              // "Text". It is `AppColors.text` now: an empty circle in the same
              // ink as its own label, which is what makes it read as choosable.
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.text,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: StyleText.fontSize16Weight500.copyWith(
              fontSize: _Type.rowLabel,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String value;
  final Slider slider;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.slider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // CHANGED 31/8/2026 — dropped `maxLines: 1` +
              // `TextOverflow.ellipsis`. "Quantity (Density)" is the longest
              // label here and it truncated to "Quantity (Densi…" on a narrow
              // panel. It wraps now: the row grows by a line instead of hiding
              // which control the reader is looking at.
              Expanded(
                child: Text(
                  label,
                  style: StyleText.fontSize16Weight500.copyWith(
                    fontSize: _Type.rowLabel,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // The read-out chip Figma draws on the right of every row.
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value,
                  style: StyleText.fontSize16Weight500.copyWith(
                    fontSize: _Type.readout,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          // The stock Slider reserves a lot of vertical padding; the design's
          // rows are tight, so the track is squeezed back with a narrower theme
          // rather than by fighting the widget's own layout.
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: AppColors.primary,
              // CHANGED 2/9/2026 — the unfilled half of every slider was
              // `AppColors.field`, the same fill the read-out chip beside it
              // uses, so on the card the two ran together and the track's
              // remaining length was hard to judge. `AppColors.background` is
              // the page behind the card, so the empty part now reads as a
              // groove cut into the card rather than as another chip.
              inactiveTrackColor: AppColors.background,
              thumbColor: AppColors.primary,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              trackShape: const RoundedRectSliderTrackShape(),
            ),
            child: SizedBox(height: 24, child: slider),
          ),
        ],
      ),
    );
  }
}

/// "Text Color" plus the colour field.
///
/// CHANGED 2/9/2026 — was a seven-swatch `AlertDialog` written inside this
/// file, on the reasoning that a watermark only ever wants a grey, the brand
/// yellow or a red, and that a full wheel would invite bright green at 5%
/// opacity. That call has been overridden: this now opens the app's own
/// [CustomColorPickerField] (`core/custom/61-custom_color_picker.dart`), the
/// same control the theme editor uses, so there is one colour-picking
/// experience in the app instead of two — and its Save / Discard buttons make
/// cancelling unambiguous, which the local palette dialog never handled.
///
/// The field renders the swatch and the hex code itself, so the old
/// swatch + chevron row is gone with it. `WatermarkSvg.chevronDown` is left
/// declared: the picker draws its own trigger, but the asset stays part of this
/// screen's set.
class _ColorRow extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorRow({required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          l.textColor,
          style: StyleText.fontSize16Weight500.copyWith(
            fontSize: _Type.rowLabel,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        CustomColorPickerField(
          label: l.textColor,
          // Never null here: the settings entity always carries a colour, so
          // the field is always in its filled (swatch + hex) state rather than
          // the hint state it shows in the theme editor.
          color: color,
          dialogTitle: l.textColor,
          onColorSelected: onChanged,
        ),
      ],
    );
  }
}
