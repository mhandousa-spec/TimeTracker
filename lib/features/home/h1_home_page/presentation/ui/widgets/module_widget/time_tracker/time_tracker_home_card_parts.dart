/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_home_card_parts.dart
/// Purpose: Declares the pieces the seven Time Tracker home cards share —
///          `TimeTrackerHomeCardScope` (cubit + gate + loading / no-access /
///          error states inside the standard `HomeWidgetCard`),
///          `TimeTrackerTile` (Figma's grey boxed tile), `TimeTrackerQuickButton`
///          (the stacked yellow buttons) and `openTimeTrackerModule`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026
///
/// Time Tracker phase 6 (brief §A). Same shell as every other module's home
/// card (`home_widget_shell.dart`: title + module icon, 10 padding, radius 8,
/// minimum height 120), the header icon is the Time Tracker MODULE icon
/// (`Modules.timeTracker.iconPath`, tinted like the other modules — the
/// Figma "My Request" card carried the Services headset by mistake). Every
/// card declares its own width (owner decision 7/10/2026): 125 / 260 / 405.
/// Showing a card also runs the throttled reminder sweep
/// (`TimeTrackerReminderSweeper.runFromUi`).
/// Updated: 9/10/2026 - UI quality pass (QA KP-TT-014): the Absence /
/// Total Requests calendar glyph is drawn red in dark mode (its dark strokes
/// vanished on the dark tile) and at the Figma 22.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/time_tracker_home_cards_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_reminder_sweeper.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/time_tracker_tab.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_module_entry.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The Figma tile glyphs (same files as the personal dashboard's Overall).
abstract final class TimeTrackerHomeSvg {
  static const String _tt = 'assets/icons_assets/time_tracker_assets';
  static const String present = '$_tt/tt_overall_present.svg';
  static const String absence = '$_tt/tt_overall_absence.svg';
  static const String late = '$_tt/tt_overall_late.svg';
  static const String vacation = '$_tt/tt_overall_vacation.svg';

  /// Canceled tile (no "canceled" stamp in the set — the closed stamp,
  /// tinted red).
  static const String canceled = 'assets/icons_assets/watermark/Closed.svg';
}

/// Function Name: [openTimeTrackerModule]
///
/// Purpose: Low haptic, then open the Time Tracker module — on [tab], or
/// with [requestId]'s details (the approver's when [asApproval]) on top.
///
/// Return type: [void]
void openTimeTrackerModule(
  BuildContext context, {
  TimeTrackerTab? tab,
  String? requestId,
  bool asApproval = false,
}) {
  HapticController.low();
  navigateTo(
    context,
    TimeTrackerModuleEntry(initialTab: tab, initialRequestId: requestId, initialAsApproval: asApproval),
  );
}

/// Provides a [TimeTrackerHomeCardsCubit] for [card], draws the standard
/// card frame (title + Time Tracker icon) and hands [builder] the loaded
/// state; until then the body shows the loading / no-access / error state.
/// Tapping the card runs [onTap] (usually: open the module).
class TimeTrackerHomeCardScope extends StatelessWidget {
  const TimeTrackerHomeCardScope({
    required this.card,
    required this.title,
    required this.width,
    required this.builder,
    this.onTap,
    super.key,
  });

  final TimeTrackerHomeCard card;
  final String title;

  /// Grid width before `.w` (`kHomeWidgetNarrowWidth` / `Compact` / `Wide`).
  final double width;
  final Widget Function(BuildContext context, TimeTrackerHomeCardsState state) builder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return BlocProvider<TimeTrackerHomeCardsCubit>(
      create: (_) {
        TimeTrackerReminderSweeper.runFromUi(isArabic: isArabic);
        return TimeTrackerHomeCardsCubit()..init(card);
      },
      child: BlocBuilder<TimeTrackerHomeCardsCubit, TimeTrackerHomeCardsState>(
        builder: (BuildContext context, TimeTrackerHomeCardsState state) {
          final bool usable = state.status != TimeTrackerHomeCardsStatus.noAccess;
          return GestureDetector(
            key: ValueKey<String>('timeTrackerHomeCard_${card.name}'),
            behavior: HitTestBehavior.opaque,
            onTap: usable ? onTap : null,
            child: HomeWidgetCard(
              title: title,
              icon: Modules.timeTracker.iconPath,
              width: width,
              child: _body(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, TimeTrackerHomeCardsState state) {
    switch (state.status) {
      case TimeTrackerHomeCardsStatus.noAccess:
        return _message(S.of(context).timeTrackerNoAccess);
      case TimeTrackerHomeCardsStatus.failure:
        return _message(S.of(context).timeTrackerLoadError);
      case TimeTrackerHomeCardsStatus.loading:
      case TimeTrackerHomeCardsStatus.loaded:
        // Loading draws the real body with "—" figures (no reflow when the
        // numbers land — same rule as the Services cards).
        return builder(context, state);
    }
  }

  Widget _message(String text) => Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize12Weight500.copyWith(color: AppColors.red),
      );
}

/// Function Name: [timeTrackerFigure]
///
/// Purpose: [value] in the reader's numerals, or "—" while not [ready].
///
/// Return type: [String]
String timeTrackerFigure(BuildContext context, int value, {required bool ready}) =>
    ready ? LocalizedNumber.of(context, value) : '—';

/// Figma's boxed tile (Presence / Totals): grey box, glyph, label, value.
class TimeTrackerTile extends StatelessWidget {
  const TimeTrackerTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    super.key,
  });

  final String icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null
          ? null
          : () {
              HapticController.low();
              onTap!();
            },
      child: Container(
        padding: EdgeInsetsDirectional.all(5.r),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // QA KP-TT-014 (9/10/2026): the absence calendar is drawn with
            // #2D2D2D strokes that vanish on the dark tile (only its red marks
            // showed — "a tiny red four-dot glyph"); in dark mode it is drawn
            // red, like the module dashboard's Absence tile. 22 (Figma).
            CustomSvgImage(
              assetPath: icon,
              width: 22.r,
              height: 22.r,
              fit: BoxFit.contain,
              color: AppTheme.isDark && icon == TimeTrackerHomeSvg.absence ? AppColors.red : null,
            ),
            SizedBox(height: 3.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                label,
                maxLines: 1,
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              maxLines: 1,
              style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            ),
          ],
        ),
      ),
    );
  }
}

/// A row of [TimeTrackerTile]s sharing the width evenly.
class TimeTrackerTileRow extends StatelessWidget {
  const TimeTrackerTileRow({required this.tiles, super.key});

  final List<TimeTrackerTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < tiles.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: 6.w),
          Expanded(child: tiles[i]),
        ],
      ],
    );
  }
}

/// One stacked button of the quick cards: yellow when enabled, the grey
/// secondary fill when not (readable in both themes).
class TimeTrackerQuickButton extends StatelessWidget {
  const TimeTrackerQuickButton({
    required this.label,
    this.onTap,
    super.key,
  });

  final String label;

  /// Null = disabled.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
              HapticController.medium();
              onTap!();
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.secondaryButton,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: StyleText.fontSize10Weight500.copyWith(
              color: enabled ? AppColors.textButton : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
