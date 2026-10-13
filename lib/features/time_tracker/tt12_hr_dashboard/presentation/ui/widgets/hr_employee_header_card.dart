/// Module: time_tracker / tt12_hr_dashboard / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: hr_employee_header_card.dart
/// Purpose: Declares `HrEmployeeHeaderCard` — the ONE header card of an
///          employee as HR sees them: the HR view with one employee picked
///          (Figma `661:42895`) and the employee's dashboard (`661:96459`).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — owner finding 14:17 #5:
///            "salma.fathy@dm003.t…" was cut; Message in the TOP-RIGHT
///            corner; the info rows get the full width)
///
/// Updated: 13/10/2026 - owner: name, job title and department stacked and
/// centred with the photo; Email · Phone Number in the rows below.
/// Layout: photo · name on the first row with the
/// yellow "Message" in the top end corner; under it, across the FULL card
/// width, Title · Department · Email · Phone Number — two columns on a
/// tablet, one on a phone — every value in full (wraps, never "…"). Names,
/// titles and departments in proper case and the app language
/// (`TimeTrackerEmployee`). 15 padding, radius 8, no hover / splash; a tap
/// (when given) opens the employee's dashboard with a LOW haptic.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_controls.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_formatters.dart';
import 'package:knowticed_plus/features/time_tracker/presentation/ui/widgets/time_tracker_setup_widgets.dart';
import 'package:knowticed_plus/features/time_tracker/tt12_hr_dashboard/presentation/ui/widgets/hr_message_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HrEmployeeHeaderCard extends StatelessWidget {
  const HrEmployeeHeaderCard({super.key, required this.employee, this.onMessage, this.onTap});

  final TimeTrackerEmployee employee;

  /// "Message" (null = hidden, e.g. one's own dashboard).
  final VoidCallback? onMessage;

  /// Tap on the card (null = not tappable).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool ar = Localizations.localeOf(context).languageCode == 'ar';
    final bool phone = context.isPhone;
    final VoidCallback? message = onMessage;
    final String title = employee.jobTitle(isArabic: ar);
    final String department = employee.department(isArabic: ar).trim();
    // 13/10/2026 (owner): job title and department sit under the name (next
    // to the photo); the rows below keep the contact details.
    final List<Widget> info = <Widget>[
      _Info(icon: const TtGlyph.svg(TtAssets.email), label: s.timeTrackerEmail, value: employee.email, oneLine: true),
      _Info(icon: const TtGlyph.svg(TtAssets.phone), label: s.timeTrackerPhoneNumber, value: employee.phone),
    ];
    final Widget card = Container(
      padding: EdgeInsetsDirectional.all(15.r),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: CardStyles.radius()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 13/10/2026 (owner): name · department · job title centred with
          // the photo.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TimeTrackerAvatar(photo: employee.photo, size: phone ? 52.r : 64.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  key: ValueKey<String>('hrHeaderIdentity_${employee.email}'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(employee.name(isArabic: ar),
                        style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text)),
                    // Same order as the Employees cards (Figma `661:93542`).
                    if (department.isNotEmpty)
                      Text(department, style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
                    if (title.trim().isNotEmpty)
                      Text(title.trim(), style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
              if (message != null) ...<Widget>[
                SizedBox(width: 12.w),
                TtMessageButton(iconOnly: phone, onTap: message),
              ],
            ],
          ),
          SizedBox(height: 14.h),
          if (phone)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8.h,
              children: info,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10.h,
              children: <Widget>[
                for (int i = 0; i < info.length; i += 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: info[i]),
                      SizedBox(width: 20.w),
                      Expanded(child: i + 1 < info.length ? info[i + 1] : const SizedBox.shrink()),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
    final VoidCallback? tap = onTap;
    if (tap == null) return card;
    return GestureDetector(
      key: ValueKey<String>('hrPickedCard_${employee.email}'),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticController.low();
        tap();
      },
      child: card,
    );
  }
}

/// "✉ Email: name@company.com" — the icon sits in the text line (always
/// centred on it, 13/10/2026 owner); [oneLine] keeps the e-mail on one line.
class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value, this.oneLine = false});

  final TtGlyph icon;
  final String label;
  final String value;
  final bool oneLine;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 6.w),
              child: TtIcon(icon, size: 15.r, color: AppColors.secondaryText),
            ),
          ),
          TextSpan(
            text: '$label: ',
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryText),
          ),
          TextSpan(
            text: TimeTrackerFormat.orDash(value),
            style: StyleText.fontSize12Weight500.copyWith(color: AppColors.text),
          ),
        ],
      ),
      maxLines: oneLine ? 1 : null,
      overflow: oneLine ? TextOverflow.ellipsis : null,
    );
  }
}
