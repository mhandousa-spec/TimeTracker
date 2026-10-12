/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_card.dart
/// Purpose: THE notification card. Every notification list in the app renders
///          this one — the inbox, the Pinned page and the Cleared page.
/// Author: Knowticed Plus team
/// Created at: 26/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// There were three cards: the inbox's — the design, Figma 4717:10740 — and a
/// hand-copied one on each of the Pinned and Cleared pages. The copies had
/// drifted, because every fix only ever landed on the page someone happened to
/// be looking at:
///
///   * no timestamp in the corner (the inbox grew one on 22/8/2026);
///   * 10.r body padding against the inbox's 8.r;
///   * no mobile type ramp — the sender chip kept its desktop 12/10/10 sizes
///     and its 40pt avatar at 375px;
///   * sender name / department / job title with no Flexible and no ellipsis,
///     so a long job title overflowed the chip;
///   * action buttons at the app-wide 135.sp rather than the shared width;
///   * the system-sender case handled differently again on each page.
///
/// So this file is the inbox's card, and the pages pass in the only part that
/// genuinely differs — the three action buttons:
///
///   inbox    Message  / Pin    / View
///   pinned   Message  / Unpin  / View
///   cleared  Restore  / Delete / View
///
/// Anything else that differs between the three lists is a bug in one of them,
/// not a reason to fork this widget.
///
/// Updated: 7/10/2026 - Owner round 4: the body shows the FULL message up to
///          3 lines (ellipsis only past the 3rd); action buttons and the
///          module icon box use corner radius 2; To-Do notifications never
///          draw the sender section ([hasSenderSection]) — a to-do is the
///          reader's own card.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_sender_info.dart';

/// One button in a card's action area.
///
/// A description, not a widget: the card owns the sizing — see
/// [NotificationCard.actionButtonWidth] — so a page cannot accidentally hand
/// in a button at a different width and re-open the drift this file exists to
/// close.
class NotificationCardAction {
  const NotificationCardAction({
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.background,
    this.foreground,
  });

  final String title;
  final String iconPath;
  final VoidCallback onTap;

  /// Fill. Defaults to [AppColors.primary] — pass one only for a button that
  /// means something else, like Unpin (grey) or Delete (red).
  final Color? background;

  /// Label and icon colour. Defaults to [AppColors.textButton].
  final Color? foreground;
}

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.employeeController,
    required this.isMobile,
    required this.onTap,
    required this.leadingAction,
    required this.trailingAction,
    this.primaryAction,
  });

  final NotificationModelSystem notification;

  /// Resolves the sender's name, department and job title, and decides whether
  /// a person or the system raised this.
  final MainCoreEmployeeController employeeController;

  final bool isMobile;

  /// Tapping anywhere on the card. Every page opens the notification.
  final VoidCallback onTap;

  /// The wide button above the pair — Message on the inbox and the Pinned
  /// page, Restore on the Cleared page.
  ///
  /// Null draws no button at all. The inbox and the Pinned page pass null for
  /// a SYSTEM notification: Message would have nobody to message.
  final NotificationCardAction? primaryAction;

  /// The pair beneath: Pin / Unpin / Delete on the leading side, View on the
  /// trailing side.
  final NotificationCardAction leadingAction;
  final NotificationCardAction trailingAction;

  /// Shared width for [leadingAction] and [trailingAction]. TIGHTENED
  /// 26/8/2026 from the app-wide 135.sp — these labels are short and the cards
  /// are grid tiles.
  ///
  /// Going lower needs more than a smaller number: ButtonSizing.width() only
  /// honours a fixed width while `label + icon + 12.sp padding either side`
  /// fits inside it and otherwise falls back to sizing each button to its own
  /// content — at which point the two stop matching. [_actionButton] gets
  /// under that floor by pinning the box here and passing
  /// `fixedWidth: double.infinity`; see the note there.
  static double get actionButtonWidth => 65.sp;

  /// Icon/label metrics for the action buttons, trimmed to fit
  /// [actionButtonWidth].
  static double get _actionIconSize => 14.sp;
  static double get _actionIconGap => 4.sp;

  /// Function Name: [moduleIconPath]
  ///
  /// Purpose: The glyph for the module a notification came from.
  ///
  /// Lives here rather than on each page — all three had the same private
  /// copy. Falls back to the generic document glyph for a stored module key
  /// that resolves to no drawer module.
  static String moduleIconPath(String storedModuleKey) {
    final Modules? module =
        NotificationRouting.moduleForStoredKey(storedModuleKey);
    return module?.iconPath ??
        "assets/icons_assets/notification_assets/document_search.svg";
  }

  /// The reader's language — NOT the sender's.
  ///
  /// ADDED 30/8/2026 with the bilingual notification document. A stored
  /// notification now carries both renderings, and the card is where the
  /// choice is made, so switching the app to Arabic re-renders the whole inbox
  /// rather than only affecting notifications sent from then on. See the
  /// language note in `notification_data_model.dart`.
  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  /// Lines of body text a card shows before it ellipsises. Owner round 4
  /// (7/10/2026): "make it fit as a sentence, max 3 lines".
  static const int bodyMaxLines = 3;

  /// Corner radius of the action buttons and the module icon box (owner
  /// round 4, 7/10/2026).
  static double get _smallRadius => 2.r;

  /// Function Name: [hasSenderSection]
  ///
  /// Purpose: Whether a card draws the sender section (avatar chip and the
  /// Message button). The three notification pages use this too, so the card
  /// and the page's `primaryAction` can never disagree.
  ///
  /// False for a system sender, and ALWAYS false for a To-Do notification:
  /// to-dos are personal, so the card is the reader's own (owner, 7/10/2026)
  /// — including To-Do notifications written before they were system-sent,
  /// whose sender is the reader themself.
  ///
  /// Parameters:
  ///   [NotificationModelSystem] notification
  ///   [MainCoreEmployeeController] employeeController
  ///
  /// Return type: [bool]
  static bool hasSenderSection(
    NotificationModelSystem notification,
    MainCoreEmployeeController employeeController,
  ) {
    if (notification.nameOfModule.trim().toLowerCase() == AppModule.todo.key) {
      return false;
    }
    return employeeController.isKnownEmployee(notification.senderEmail);
  }

  @override
  Widget build(BuildContext context) {
    final String senderName =
        employeeController.getEmployeeName(notification.senderEmail);
    // NotificationSenderInfo, not getEmployeeDepartmentName — FIXED 7/10/2026.
    // The core helper bangs a null department id / name, which threw inside
    // this build for every notification the company owner (no department)
    // sent: the red "Null check operator" box on all To-Do notifications.
    final String senderDepartment = NotificationSenderInfo.departmentName(
      employeeController,
      notification.senderEmail,
      isEnglish: !_isArabic(context),
    );
    final String senderJobTitle =
        employeeController.getEmployeeJobTitle(notification.senderEmail);

    // Whether a person sent this, or the system raised it.
    //
    // A system notification is drawn WITHOUT the avatar chip. Rendering the
    // person variant for everything is what produced the empty "No Name / No
    // Department / No Job" chip on every account-status alert.
    final bool hasHumanSender =
        hasSenderSection(notification, employeeController);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The design puts a solid accent stripe down the leading edge of
            // every card. Painted as a child rather than a BorderDirectional
            // side: Flutter asserts a border with non-uniform colors cannot
            // carry a borderRadius, and this card is rounded — the assertion
            // aborts the paint and the tile comes out empty. Row order follows
            // text direction, so the stripe still mirrors to the right-hand
            // edge in Arabic, and Clip.antiAlias above rounds its ends.
            Container(width: 4.w, color: AppColors.primary),
            Expanded(
              child: Padding(
                    padding: EdgeInsets.all(8.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              NotificationRouting.formatTimestamp(
                                  context, notification.timestamp),
                              style: StyleText.fontSize10Weight500
                                  .copyWith(color: AppColors.secondaryText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 2.sp),
                        _titleRow(context),
                        SizedBox(height: 5.sp),
                        // Expanded, not a fixed height: the card lives in a
                        // grid tile of a fixed mainAxisExtent, so the body has
                        // to absorb whatever room is left over instead of
                        // forcing the column past the tile.
                        // The body shows up to [bodyMaxLines] (3) lines and
                        // is ellipsised only at the end of the third — owner
                        // round 4, 7/10/2026 (was a fixed two). The grid
                        // tiles in the three notification pages grew by one
                        // line (172/195 → 190/212.sp) to guarantee the room.
                        //
                        // FIXED 13/9/2026, twice. First: `Expanded` hands the
                        // Text a TIGHT height, and a Text whose lines do not
                        // fit that height is CLIPPED — `maxLines` and
                        // `overflow` act on the line COUNT, never on the box —
                        // so at `height: 1.6` the second line was drawn and
                        // then sliced in half. Then: capping maxLines to what
                        // fit turned that into a single line ending in "…",
                        // which loses half the sentence.
                        //
                        // So the room is guaranteed instead of the line count
                        // negotiated: 1.35 line height here, and the grid tile
                        // in the three notification pages is 195.sp rather
                        // than 185.sp.
                        //
                        // CHANGED 13/9/2026 — Flexible, not Expanded. Expanded
                        // is TIGHT: it forced this box to eat every spare
                        // pixel in the tile, and since the text sits at the
                        // top of that box the slack showed up UNDER the
                        // message as a gap far wider than the 8.sp below.
                        // Flexible is loose, so the box is two lines tall, the
                        // 8.sp gap is the real distance to the sender row, and
                        // what slack the tile still has falls to the bottom of
                        // the card. It keeps Expanded's guarantee that the
                        // column can never overflow the tile.
                        Flexible(
                          child: Text(
                            // displayBodyFor — the "Reason: …" clause is not
                            // shown on cards in any module, and the language
                            // follows the READER. See the model.
                            notification.displayBodyFor(_isArabic(context)),
                            maxLines: bodyMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: StyleText.fontSize12Weight500.copyWith(
                              height: 1.35,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.sp),
                        _actions(
                          hasHumanSender: hasHumanSender,
                          senderName: senderName,
                          senderDepartment: senderDepartment,
                          senderJobTitle: senderJobTitle,
                        ),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Module glyph + title + the arrival stamp.
  ///
  /// CHANGED 26/8/2026: the stamp used to float in a Stack pinned to the
  /// card's top-right corner, over the title. That was fine while it read
  /// `26 Aug 2026`, but it now carries the clock time as well and a floating
  /// child takes no space from the title's Expanded — so a long title would
  /// have run underneath it. As a real child of this Row it takes its width
  /// first and the title ellipsises around it, which is what the design shows
  /// anyway: they sit on one line.
  Widget _titleRow(BuildContext context) => Row(
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              // Radius 2 (owner round 4, 7/10/2026) — was a circle.
              borderRadius: BorderRadius.circular(_smallRadius),
            ),
            // Center, not a bare child: a Container with an explicit
            // width/height hands its child TIGHT constraints, and
            // BoxConstraints.enforce lets a tight parent override the icon's
            // own width/height — so the glyph was blown up to the full 30
            // circle. Center loosens them, and the SizedBox is then honoured.
            child: Center(
              child: SizedBox(
                width: 16.sp,
                height: 16.sp,
                child: CustomSvgImage(
                  assetPath: moduleIconPath(notification.nameOfModule),
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.textButton,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.sp),
          Expanded(
            child: Text(
              notification.titleFor(_isArabic(context)),
              style: StyleText.fontSize12Weight500
                  .copyWith(color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        ],
      );

  /// The action area, in the two shapes the design draws:
  ///
  ///   person  → avatar chip on the leading side, then the primary button on
  ///             top with the pair beneath it;
  ///   system  → no chip; the buttons SPAN the card, leading edge to trailing
  ///             edge, on one row.
  ///
  /// FIXED 26/8/2026. The system shape used to be conditional on there being
  /// no primary button as well as no chip, so the Cleared page — which passes
  /// Restore for a system notification, since a cleared system alert is just
  /// as restorable as one from a person — fell into the PERSON shape with the
  /// chip slot collapsed to a Spacer. That stacked its three buttons in a
  /// column hugging the trailing edge with half the card empty beside them,
  /// which is not what any other page draws and is not the design.
  ///
  /// Now the rule is simply: no chip means the buttons spread across the card.
  /// With no primary that is the original leading/trailing pair; with one, the
  /// primary takes the leading edge and the pair the trailing edge. Either way
  /// there is no dead space, and a system card reads the same on all three
  /// pages.
  Widget _actions({
    required bool hasHumanSender,
    required String senderName,
    required String senderDepartment,
    required String senderJobTitle,
  }) {
    if (!hasHumanSender) {
      // Two buttons: one at each edge. Unchanged — this is the inbox's and the
      // Pinned page's system card.
      if (primaryAction == null) {
        return Row(
          children: [
            _actionButton(leadingAction),
            const Spacer(),
            _actionButton(trailingAction),
          ],
        );
      }

      // Three buttons: the primary takes the leading edge, the pair the
      // trailing edge, and the Spacer takes what is left — so the row fills
      // the card exactly like the two-button version above.
      //
      // _actionButton, not _primaryButton: there is no IntrinsicWidth column
      // here to stretch the primary against, so it takes the same fixed width
      // as the other two.
      return Row(
        children: [
          _actionButton(primaryAction!),
          const Spacer(),
          _actionButton(leadingAction),
          SizedBox(width: 6.sp),
          _actionButton(trailingAction),
        ],
      );
    }

    // FIXED 13/9/2026 — the sender chip was shorter than the button block
    // beside it, so the card showed a band of empty card colour above and
    // below it. The Row defaulted to CrossAxisAlignment.center and the chip
    // took its own content height (avatar + padding ~56) against the buttons'
    // ~70.
    //
    // `stretch` alone cannot do this: a Row that stretches sizes itself to its
    // incoming maxHeight, and here that is UNBOUNDED — this Row is a non-flex
    // child of the card's Column. IntrinsicHeight measures the tallest child
    // first and gives the Row that height, which stretch then hands to the
    // chip. Nothing in this subtree is a ListView, so the intrinsic pass is
    // safe (a ListView throws when asked for one).
    return IntrinsicHeight(
      child: Row(
        // No Spacer between the chip and the buttons: a Spacer is a flex child,
        // so it claimed half the free width and squeezed the sender's name /
        // department / job title into an ellipsis. spaceBetween parks the
        // buttons at the trailing edge instead and leaves every spare pixel to
        // the chip, which still only grows as far as its own text needs.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Unconditional: every path without a chip returned above.
          Flexible(
            child: Padding(
              // Keeps the gap the Spacer used to guarantee, for when the chip
              // does grow all the way over.
              padding: EdgeInsetsDirectional.only(end: 8.sp),
              child: _senderChip(
                senderName: senderName,
                senderDepartment: senderDepartment,
                senderJobTitle: senderJobTitle,
              ),
            ),
          ),
          // IntrinsicWidth + CrossAxisAlignment.stretch: the column is exactly
          // as wide as its widest child — the two-button row — and the primary
          // button is stretched to that same width, so it spans both instead of
          // sitting at its own width.
          //
          // mainAxisSize.min, and still NOT an Expanded around the primary
          // button. The IntrinsicHeight above now bounds this Column's height,
          // but the intrinsic pass itself measures with an UNBOUNDED height, so
          // a flex child here would throw during that pass, leave the card with
          // no size, and the grid would then assert 'child.hasSize' in paint
          // (sliver_multi_box_adaptor line 629).
          IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (primaryAction != null) ...[
                  _primaryButton(primaryAction!),
                  SizedBox(height: 5.sp),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton(leadingAction),
                    SizedBox(width: 6.sp),
                    _actionButton(trailingAction),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Avatar + name / department / job title.
  ///
  /// REVERTED 13/9/2026. An attempt to stretch the avatar to the chip's full
  /// height — `CrossAxisAlignment.stretch` plus `CustomSvgImage.natural` with
  /// no width or height — overflowed the card by 680px and took the text with
  /// it: with no size of its own the SVG resolved to its intrinsic size
  /// against the Row's unbounded main axis, and `mainAxisSize: min` had
  /// nothing left to shrink to.
  ///
  /// The avatar is a FIXED square again. The chip as a whole still matches the
  /// button block's height — that comes from the IntrinsicHeight in
  /// [_actions], which is untouched.
  Widget _senderChip({
    required String senderName,
    required String senderDepartment,
    required String senderJobTitle,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: isMobile ? 4.sp : 11.sp,end:isMobile ? 4.sp: 20.sp),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FIXED 13/9/2026 — the avatar drew as a square. Your 60.sp box
              // is kept; what was wrong was inside it:
              //
              //   * the artwork was a 40.w x 40.h SVG CENTRED in a 60.sp box,
              //     so it never reached the edges the clip works on — what you
              //     saw was the asset's own square backdrop sitting inside an
              //     untouched circular clip. It now fills the box.
              //   * ClipRRect used a RAW `20`, unscaled. Half of 60.sp is well
              //     past 20, so that radius is a rounded rectangle by
              //     definition. ClipOval always clips to the box's oval, so
              //     there is no radius left to keep in step with the size.
              //   * mobile was `30.sp` wide by `30.h` tall — under ScreenUtil
              //     those scale against different axes and are not the same
              //     pixel count, which makes an ellipse rather than a circle.
              //     Both sides are .sp now, as your desktop pair already was.
              SizedBox(
                width: isMobile ? 30.sp : 60.sp,
                height: isMobile ? 30.sp : 60.sp,
                child: ClipOval(
                  child: CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/male_avatar.svg",
                    width: isMobile ? 30.sp : 60.sp,
                    height: isMobile ? 30.sp : 60.sp,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 5.sp),
              // Flexible + single-line ellipsis: long names and job titles
              // used to push this column past the chip.
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      FormatHelper.capitalize(senderName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isMobile
                          ? StyleText.fontSize10Weight500
                              .copyWith(color: AppColors.text)
                          : StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.text),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      FormatHelper.capitalize(senderDepartment),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isMobile
                          ? StyleText.fontSize8Weight400
                              .copyWith(color: AppColors.secondaryText)
                          : StyleText.fontSize10Weight500
                              .copyWith(color: AppColors.secondaryText),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      FormatHelper.capitalize(senderJobTitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isMobile
                          ? StyleText.fontSize8Weight400
                              .copyWith(color: AppColors.secondaryText)
                          : StyleText.fontSize10Weight500
                              .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  /// Button height on MOBILE: a quarter off the app-wide 38.sp.
  ///
  /// ADDED 13/9/2026. Note this is `fixedHeight`, not `height` —
  /// customButtonWithSvg documents `height:` as accepted and IGNORED, because
  /// dozens of call sites pass a stale value that ButtonSizing is meant to
  /// override. So the `height: isMobile ? 20.sp : 25.h` this file has been
  /// passing all along never did anything; every button was 38.sp, which is
  /// why they looked oversized on a phone. `fixedHeight` is the documented
  /// opt-out and is honoured.
  ///
  /// Null on tablet and desktop, so those keep ButtonSizing.height untouched.
  ///
  /// The sender chip needs no matching change: the IntrinsicHeight in
  /// [_actions] measures whatever the button column comes to and stretches the
  /// chip to it, so shrinking these pulls the chip down with them and the two
  /// stay level.
  double? get _mobileButtonHeight => isMobile ? ButtonSizing.height * 0.75 : null;

  /// The wide button. No fixed width — the enclosing IntrinsicWidth stretches
  /// it to the width of the pair below.
  Widget _primaryButton(NotificationCardAction action) => customButtonWithSvg(
        title: action.title,
        function: action.onTap,
        height:isMobile ? 20.sp : 25.h,
        fixedHeight: _mobileButtonHeight,
        color: action.background ?? AppColors.primary,
        svgColor: action.foreground ?? AppColors.textButton,
        textStyle: isMobile ?
        StyleText.fontSize12Weight500
            .copyWith(color: action.foreground ?? AppColors.textButton):

        StyleText.fontSize14Weight500
            .copyWith(color: action.foreground ?? AppColors.textButton),
        space: 8,
        // `radius:` is ignored by customButtonWithSvg (ButtonSizing
        // enforces 8); `fixedRadius` is its documented opt-out.
        fixedRadius: _smallRadius,
        image: action.iconPath,
        widthImage: 16.sp,
        heightImage: 16.sp,
        colorBorder: AppColors.transparent,
      );

  /// One of the pair, at [actionButtonWidth].
  ///
  /// The SizedBox is what sets the width: it hands the button a TIGHT width
  /// constraint, which the widget's own Container yields to. Passing
  /// `fixedWidth: double.infinity` is the other half — it keeps
  /// ButtonSizing.width() on its fixed-width branch (nothing is wider than
  /// infinity, so it never returns null), which is what stops it wrapping the
  /// content in 12.sp horizontal padding. Without it, a width below that
  /// padding floor makes the padded content overflow this box.
  Widget _actionButton(NotificationCardAction action) => SizedBox(
        width: actionButtonWidth,
        child: customButtonWithSvg(
          title: action.title,
          function: action.onTap,
          height: 25.h,
          fixedHeight: _mobileButtonHeight,
          fixedWidth: double.infinity,
          color: action.background ?? AppColors.primary,
          svgColor: action.foreground ?? AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500
              .copyWith(color: action.foreground ?? AppColors.textButton),
          space: _actionIconGap,
          // `radius:` is ignored by customButtonWithSvg (ButtonSizing
          // enforces 8); `fixedRadius` is its documented opt-out.
          fixedRadius: _smallRadius,
          image: action.iconPath,
          widthImage: _actionIconSize,
          heightImage: _actionIconSize,
          colorBorder: AppColors.transparent,
        ),
      );
}
