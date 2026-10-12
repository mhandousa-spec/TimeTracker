/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: home_widget_shell.dart
/// Purpose: The card shell and small parts every Adding Widget card is built
///          from — `HomeWidgetCard`, `HomeCardButton`, `HomeStatTile`,
///          `HomeEntityRow`, `HomeProgressRow` and the grid constants.
/// Author: Knowticed Plus team
/// Created at: 23/8/2026
///
/// Figma lays these cards on a fixed grid inside the 1024-wide iPad
/// Horizontal frame: card widths 125 / 265 / 405 / 545 with a 15 gutter, and
/// a card height of 120 (200 for the taller progress-bar card).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

/// One grid column.
const double kHomeWidgetNarrowWidth = 125;

/// The THREE-STAT card width — Role Management's, and the narrower of the two
/// widths a stat card may take.
///
/// ADDED 28/8/2026. Role Management carried this as a bare `260` while the
/// cards beside it reached for whichever grid constant looked close, so a row
/// of otherwise identical three-stat cards came out at three different widths.
/// The stat cards now use exactly two widths — this one for three stats and
/// [kHomeWidgetWideWidth] for four — so they line up in the picker and on the
/// home layout. Named here, with the other grid constants, rather than repeated
/// as a literal in each card.
const double kHomeWidgetCompactWidth = 260;

/// Two grid columns — the most common card width.
const double kHomeWidgetWidth = 320;

/// Three grid columns.
const double kHomeWidgetWideWidth = 405;

/// Four grid columns.
const double kHomeWidgetFullWidth = 600;

/// Standard card height.
const double kHomeWidgetHeight = 120;

/// Height of the taller card (Figma: "Services Status").
const double kHomeWidgetTallHeight = 200;

/// SVG assets these cards use. Every path is inside a directory declared in
/// pubspec's `assets:` block, so none of them can fail at runtime.
abstract class HomeWidgetSvg {
  static const String service =
      'assets/icons_assets/services_assets/headset_support.svg';
  static const String serviceRequest =
      'assets/icons_assets/home_assets/service_requests_document.svg';
  static const String serviceTap =
      'assets/icons_assets/home_assets/service_tap_finger.svg';
  static const String sla = 'assets/icons_assets/home_assets/sla_stopwatch.svg';
  static const String done =
      'assets/icons_assets/home_assets/todo_done_stamp.svg';
  static const String approved = 'assets/icons_assets/watermark/Approved.svg';
  static const String closed = 'assets/icons_assets/watermark/Closed.svg';
  static const String fixed = 'assets/icons_assets/watermark/Fixed.svg';
  static const String open = 'assets/icons_assets/watermark/Open.svg';

  static const String pending = 'assets/icons_assets/watermark/Pending.svg';
  static const String rejected = 'assets/icons_assets/watermark/Rejected.svg';
  static const String hourglass =
      'assets/icons_assets/home_assets/hourglass_pending.svg';
  static const String checkGreen =
      'assets/icons_assets/main_icons_assets/check_circle_green.svg';
  static const String rejectedStamp =
      'assets/icons_assets/home_assets/rejected_stamp_red.svg';
  static const String chat =
      'assets/icons_assets/main_icons_assets/chat_bubble_dots.svg';
  static const String messages =
      'assets/icons_assets/main_icons_assets/roles_icons_Messages.svg';
  static const String avatar =
      'assets/icons_assets/main_icons_assets/male_avatar.svg';
  static const String group =
      'assets/icons_assets/main_icons_assets/users_group_three.svg';
  static const String bell =
      'assets/icons_assets/main_icons_assets/notification_bell.svg';
  static const String lowStock =
      'assets/icons_assets/home_assets/inventory_damaged_box.svg';

  // ── Lifecycle statuses ────────────────────────────────────────────────────
  // ADDED 25/8/2026 for the four Roles cards (home_roles_widgets.dart), whose
  // tiles are role / access-grant / account states rather than the request
  // states above. Unlike [approved] / [pending] / [rejected], which carry their
  // own green-orange-red, these are monochrome and are meant to be tinted by
  // the caller with the feature's own status colour (`RoleStatus.color`,
  // `EmployeeStatusStyle.color`) so a tile and its module's screens agree.

  static const String statusActive =
      'assets/icons_assets/watermark/active_roles.svg';
  static const String statusInactive =
      'assets/icons_assets/watermark/inactice_roles.svg';

  /// A draft is something still being written — hence the pencil. Figma draws a
  /// bookmark here; there is no bookmark glyph in the app's icon set, and
  /// adding one for a single tile would leave the app with two marks for the
  /// same idea.
  static const String statusDraft = 'assets/icons_assets/watermark/draft.svg';

  /// Both "Scheduled" (a grant that has not started) and "Scheduled
  /// Deactivation" — in each case the state is *waiting on a date*.
  static const String statusScheduled =
      'assets/icons_assets/watermark/Scheduled Deactivation.svg';
  static const String statusDeactivated =
      'assets/icons_assets/watermark/Deactivate.svg';
  static const String statusLocked = 'assets/icons_assets/watermark/Locked.svg';
}

/// The white rounded card every Adding Widget entry sits in.
///
/// Header is `Title ................ [module icon]`, matching Figma, with the
/// body filling whatever height is left.
class HomeWidgetCard extends StatelessWidget {
  final String title;

  /// Module glyph drawn at the top-right. Null renders no icon.
  final String? icon;

  /// Replaces [icon] when the card needs something richer up there
  /// (Figma: the "20%" on Near Breached SLA).
  final Widget? trailing;

  final Widget child;
  final double width;

  /// Figma's card height, applied as a MINIMUM rather than a fixed size.
  ///
  /// A fixed height would overflow the moment a translation runs longer than
  /// the English string — Arabic labels here are routinely wider — so the card
  /// grows instead of throwing a RenderFlex error. Null removes the floor.
  final double? minHeight;

  const HomeWidgetCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.trailing,
    this.width = kHomeWidgetWidth,
    this.minHeight = kHomeWidgetHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      constraints:
          minHeight == null ? null : BoxConstraints(minHeight: minHeight!.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null)
                trailing!
              else if (icon != null)
                CustomSvgImage(
                  assetPath: icon!,
                  width: 16.r,
                  height: 16.r,
                  color: AppColors.primary,
                ),
            ],
          ),
          SizedBox(height: 8.h),
          // No Flexible/Expanded here: inside a Wrap the card's height is
          // unbounded, and a flexed child in an unbounded main axis asserts.
          child,
        ],
      ),
    );
  }
}

/// The small yellow pill button used inside the cards.
///
/// Deliberately not `customButton` (core 5): that one enforces a 135/150.sp
/// app-wide width, which is wider than these 125-wide cards.
class HomeCardButton extends StatelessWidget {
  final String label;

  /// Optional leading glyph, as Figma draws on "Create Form", "Asset", etc.
  final String? icon;

  final VoidCallback? onTap;
  final Color? color;

  /// Stretch to the parent's width. Figma's stacked action buttons do.
  final bool fullWidth;

  const HomeCardButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.color,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          CustomSvgImage(
            assetPath: icon!,
            width: 12.r,
            height: 12.r,
            color: AppColors.textButton,
          ),
          SizedBox(width: 4.w),
        ],
        Flexible(
          child: Text(
            label,
            style: StyleText.fontSize10Weight500
                .copyWith(color: AppColors.textButton),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: content,
      ),
    );
  }
}

/// One boxed metric: glyph on top, label, then value.
///
/// Figma uses this inside the "Services" / "Inventory" / "Knowledge Hub"
/// totals cards, where several tiles sit side by side with a hairline between.
class HomeStatTile extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  /// Tint for the glyph. Null keeps the asset's own colors, which is right
  /// for the status icons that are already green/orange/red.
  final Color? iconColor;

  /// How many lines the label may wrap onto. ADDED 25/8/2026.
  ///
  /// Pass 1 for a card whose labels must stay on one line. The TYPE SIZE DOES
  /// NOT ADAPT — 9pt always — so a label that will not fit ellipses. That is
  /// deliberate: shrinking one label leaves the tiles in a row at different
  /// sizes, which reads as a bug rather than as a long word. If a label does
  /// not fit, the card is too narrow; widen it. Size against the ARABIC label,
  /// which runs wider than the English here.
  final int labelMaxLines;

  const HomeStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.labelMaxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomSvgImage(
          assetPath: icon,
          width: 20.r,
          fit: BoxFit.fill,
          height: 20.r,
          color: iconColor,
        ),
        SizedBox(height: 10.h),
        // CHANGED 28/9/2026 (bug report p.23 — "titles must show completely
        // not three dots"): a one-line label is now scaled DOWN to fit its
        // tile instead of being cut off with "...". It is only ever shrunk,
        // never grown, so a label that already fits is drawn exactly as before.
        // This reverses the "type size does not adapt" rule documented on
        // [labelMaxLines] above for the one-line case.
        if (labelMaxLines == 1)
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              label,
              style:
                  StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              maxLines: 1,
            ),
          )
        else
          Text(
            label,
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
            maxLines: labelMaxLines,
            overflow: TextOverflow.ellipsis,
          ),
        SizedBox(height: 10.h),
        Text(value,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
      ],
    );
  }
}

/// A row of [HomeStatTile]s separated by the vertical hairline Figma draws.
class HomeStatTileRow extends StatelessWidget {
  final List<HomeStatTile> tiles;

  const HomeStatTileRow({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    // CHANGED 28/9/2026 (bug report p.23 — "padding between them must be
    // equal"): each tile used to take an equal-width `Expanded` slot with its
    // text pinned to the start of it, so the visible gap after a short label
    // ("Active") was far wider than after a long one ("Deactivated"). Tiles
    // now take their own width (capped at an equal share, loose flex) and
    // `spaceBetween` hands out the leftover room evenly, so every gap matches.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int i = 0; i < tiles.length; i++) ...<Widget>[
          // if (i > 0)
          //   Container(
          //     width: 1,
          //     height: 40.h,
          //     margin: EdgeInsets.symmetric(horizontal: 6.w),
          //     color: AppColors.border.withOpacity(.5),
          //   ),
          Flexible(
            // A floor under the even gap, so two labels that both need their
            // whole share still do not touch.
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                  end: i == tiles.length - 1 ? 0 : 6.w),
              child: tiles[i],
            ),
          ),
        ],
      ],
    );
  }
}

/// `[glyph] Name / subtitle .......... [action]` — the two-line list row used
/// by the Requested Service and Near Breached SLA cards.
class HomeEntityRow extends StatelessWidget {
  final String icon;
  final String name;
  final String subtitle;

  /// Right-hand affordance: a [HomeCardButton] or a small icon button.
  final Widget? trailing;

  const HomeEntityRow({
    super.key,
    required this.icon,
    required this.name,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: <Widget>[
          CustomSvgImage(
            assetPath: icon,
            width: 18.r,
            height: 18.r,
            color: AppColors.primary,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  name,
                  style: CardStyles.value(10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: CardStyles.label(8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...<Widget>[
            SizedBox(width: 6.w),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// `Label .... [track/fill] .... value` — one line of the Services Status card.
class HomeProgressRow extends StatelessWidget {
  final String label;
  final String value;

  /// 0..1 fill fraction.
  final double fraction;
  final Color color;

  const HomeProgressRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: CardStyles.label(9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(value, style: CardStyles.value(9)),
            ],
          ),
          SizedBox(height: 2.h),
          Stack(
            children: <Widget>[
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20.r),
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

/// `[glyph] value` — the compact count line on the My Request / Stocks cards.
class HomeCountLine extends StatelessWidget {
  final String icon;
  final String value;

  const HomeCountLine({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: <Widget>[
          CustomSvgImage(assetPath: icon, width: 16.sp, height: 16.sp,fit: BoxFit.fill,),
          SizedBox(width: 4.w),
          Text(value, style: CardStyles.value(11)),
        ],
      ),
    );
  }
}
