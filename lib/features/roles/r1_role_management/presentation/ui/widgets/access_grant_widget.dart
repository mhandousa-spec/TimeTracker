/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: access_grant_widget.dart
/// Purpose: Declares `AccessGrantorWidget`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

class AccessGrantorWidget extends StatelessWidget {
  final String title;
  final String name;
  final String? imagePath;

  /// Draw the person avatar beside [name].
  ///
  /// ADDED 28/8/2026. This widget renders two KINDS of box in the employee
  /// details row: the ones naming a PERSON (access grantor, supervisor) and the
  /// ones carrying a date or a count (access granted/revoked, last login, total
  /// modules). Only the person boxes get a face, so this is opt-in per call
  /// site rather than always-on — a date with an avatar beside it would read as
  /// a person.
  final bool showAvatar;

  const AccessGrantorWidget({
    super.key,
    required this.title,
    required this.name,
    this.imagePath,
    this.showAvatar = false,
  });

  /// The default person avatar.
  ///
  /// [imagePath] is honoured when it is a real photo URL; anything else falls
  /// back to the shared male-avatar SVG, which is what the rest of the app
  /// draws for an employee with no photo (see PersonStateView).
  Widget _buildAvatar() {
    final String? photo = imagePath;

    if (photo != null && photo.contains('http')) {
      return CircleAvatar(
        radius: 12.sp,
        backgroundColor: AppColors.primary,
        backgroundImage: NetworkImage(photo),
      );
    }

    return CircleAvatar(
      radius: 12.sp,
      backgroundColor: AppColors.transparent,
      child: ClipOval(
        child: SvgPicture.asset(
          'assets/icons_assets/main_icons_assets/male_avatar.svg',
          fit: BoxFit.cover,
          width: 24.sp,
          height: 24.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        // Role QA p.8: on a phone four of these share one row; with 12 of
        // padding each, "Access Granted" / "23 Sep 2026" broke onto two lines.
        padding: EdgeInsets.symmetric(
            horizontal: showAvatar ? 12.sp : 4.sp, vertical: 12.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title — one line; scaled down only if it cannot fit.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: StyleText.fontSize10Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),

            SizedBox(height: 6.sp),

            // Name/Value — with the person avatar when this box names someone.
            if (showAvatar)
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(),
                  SizedBox(width: 6.sp),
                  Flexible(
                    child: Text(
                      // Role QA p.8: "demo company" / "ali al-najjar" were
                      // shown in lower case.
                      FormatHelper.capitalize(name),
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: lightMode
                            ? AppColors.totalBlack
                            : AppColors.darkWhite,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              // Role QA p.8: dates on one line ("23 Sep 2026").
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  style: StyleText.fontSize12Weight500.copyWith(
                    // Was two inline hex literals (§12 forbids colours outside
                    // core/theme) — these are the theme's dark-ink /
                    // light-paper text tokens.
                    color:
                        lightMode ? AppColors.totalBlack : AppColors.darkWhite,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}