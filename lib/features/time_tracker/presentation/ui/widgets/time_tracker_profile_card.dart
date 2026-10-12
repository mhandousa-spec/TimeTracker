/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_profile_card.dart
/// Purpose: Declares `TimeTrackerProfileCard` — the white card of the main
///          page header: avatar · name · department · job title, with the
///          check-in control at the end.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma `661:12276`: 100 high, radius 8; avatar 70 circle; name Medium 18
/// #2D2D2D, department + job title Medium 16 #797979 ("Marketing Manager" —
/// the Figma "Manger" typo is not carried over: the real job title is
/// shown). Phone (`661:24056`): the control sits under the text, at the end.
/// The check-in control appears only with `Check_In_And_Out`.
/// Updated: 9/10/2026 - phase 5: optional [TimeTrackerProfileCard.trailing]
/// (the employee dashboard `661:96459` shows "Message" where the check-in
/// control sits); it replaces the check-in control when given.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_control.dart';

/// The app's default avatar (same as `MainCoreEmployeeController`).
const String _defaultAvatar = 'assets/icons_assets/main_icons_assets/male_avatar.png';

class TimeTrackerProfileCard extends StatelessWidget {
  const TimeTrackerProfileCard({
    super.key,
    required this.identity,
    required this.showCheckIn,
    this.trailing,
  });

  final TimeTrackerIdentity identity;
  final bool showCheckIn;

  /// Shown at the end instead of the check-in control (null = none).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget? end = trailing ?? (showCheckIn ? const CheckInControl() : null);
    final bool ar = context.isArabic;
    final bool phone = context.isPhone;
    final String name = identity.name(isArabic: ar);
    final String title = identity.jobTitle(isArabic: ar);
    final Widget person = Row(
      children: <Widget>[
        _Avatar(photo: identity.photo, size: phone ? 56.r : 70.r),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
              ),
              if (identity.department.isNotEmpty)
                Text(
                  identity.department,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.secondaryText),
                ),
              if (title.isNotEmpty)
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: AppColors.secondaryText),
                ),
            ],
          ),
        ),
      ],
    );
    return Container(
      key: const ValueKey<String>('timeTrackerProfileCard'),
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(15.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: phone
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                person,
                if (end != null) ...<Widget>[
                  SizedBox(height: 12.h),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: end,
                  ),
                ],
              ],
            )
          : Row(
              children: <Widget>[
                Expanded(child: person),
                if (end != null) ...<Widget>[
                  SizedBox(width: 15.w),
                  end,
                ],
              ],
            ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photo, required this.size});

  final String photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget fallback = Image.asset(_defaultAvatar, width: size, height: size, fit: BoxFit.cover);
    final Widget image = photo.startsWith('http')
        ? Image.network(
            photo,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          )
        : Image.asset(
            photo.isEmpty ? _defaultAvatar : photo,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => fallback,
          );
    return ClipOval(child: SizedBox(width: size, height: size, child: image));
  }
}
