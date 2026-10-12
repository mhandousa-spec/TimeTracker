/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: schedule_message.dart
/// Purpose: Declares `ScheduleMessage`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';

class ScheduleMessage extends StatelessWidget {
  ScheduleMessage({required this.model, super.key});
  final HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    var l = S.of(context);
    return StandardContainer(
        // FIXED 13/9/2026 — dropped `height: 142.sp`. Nothing in this card
        // needs a bounded height (no Expanded, no Spacer), and the number was
        // a guess that stopped being right the moment the two labels wrapped
        // or the text scaled, clipping the second button. The card now hugs
        // its content and HomeCardMetrics.fitBox lets it grow.
        child: SizedBox(
          width: 140.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10.sp,
            children: [
              Text(
                l.scheduleMessage,
                style: StyleText.fontSize14Weight500.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                spacing: 5.sp,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.forGroup,
                    style: StyleText.fontSize12Weight400
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  // See the note on the second button below.
                  HomeCardButton(label: l.createNew, onTap: () {})
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5.sp,
                children: [
                  Text(
                    l.forDirectMessage,
                    style: StyleText.fontSize12Weight400
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  // CHANGED 12/9/2026 — the action buttons are `HomeCardButton`, not
                  // `customButton` / `customButtonWithSvg`.
                  //
                  // Those two enforce the app-wide ButtonSizing rule: 135.sp on tablet, 38.sp on
                  // mobile, or — when the label does not fit that — no width at all, in which
                  // case the button hugs its own text. So every button in a card came out a
                  // different width from the one above it, and narrower than the card holding
                  // them. `HomeCardButton` is the component the newer home cards already use
                  // (home_widget_shell.dart); it is full-width by default, which is what Figma
                  // draws for stacked card actions and what makes every card agree.
                  HomeCardButton(label: l.createNew, onTap: () {})
                ],
              ),
            ],
          ),
        ));
  }
}