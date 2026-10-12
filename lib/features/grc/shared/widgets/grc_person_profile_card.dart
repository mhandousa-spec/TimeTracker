/// Module: GRC shared widgets
/// Description: The employee profile card at the top of the Control
///              Champion / Control Owner details, Reassign and Request
///              Details screens, drawn the way MAGDY lays it out at each of
///              the three design widths.
/// Author: Knowticed Plus team
/// Date: 2026-09-15
/// Dependencies: CardInfoRow / CardSvg (16), customButtonWithSvg (6),
///               ResponsiveHelper breakpoints (38), grc_messaging
library;

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_messaging.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcPersonProfileCard]
///
/// purpose: white card with the person's avatar, name, title, department,
///          phone and email plus a Message action. Three layouts, one per
///          Figma width:
///
///   * desktop (1024): `Title | Department` over `Email | Phone`, and a
///     labelled "Message" button on the trailing edge.
///   * tablet (768):   `Title` over `Department` beside `Phone` over
///     `Email`, and an icon-only message button.
///   * mobile (375):   all four lines stacked under the name, the icon-only
///     message button pinned to the top trailing corner.
///
/// [children] are drawn inside the same card under the profile row — the
/// Request Details screen keeps a person's assigned controls, dates and note
/// in the card with them.
///
/// It replaces `ContactCard` (21) on these screens because ContactCard's own
/// breakpoint (500.w of the card) puts the tablet design into its "mobile"
/// branch, with a full-width Message button the design does not have.
class GrcPersonProfileCard extends StatelessWidget {
  final String email;
  final List<Widget> children;

  const GrcPersonProfileCard({
    super.key,
    required this.email,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final employee = findEmployeeByEmail(email);
    final String name = employeeDisplayName(context, email);
    final String jobTitle = employee.localizedJobTitle(context);
    final String department = employee.localizedDepartment(context);
    final _Person person = _Person(
      name: name,
      title: jobTitle.isNotEmpty
          ? jobTitle
          : grcTr(context, grcMockJobTitleFallback),
      department: department.isNotEmpty
          ? department
          : grcTr(context, grcMockDepartmentFallback),
      phone: employee.displayPhone,
      email: email,
      photo: employee.displayPhoto,
    );

    final ScreenSize size = screenSizeOf(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          switch (size) {
            ScreenSize.desktop => _desktop(context, person),
            ScreenSize.tablet => _tablet(context, person),
            ScreenSize.mobile => _mobile(context, person),
          },
          if (children.isNotEmpty) ...[
            SizedBox(height: 15.h),
            ...children,
          ],
        ],
      ),
    );
  }

  // ── 1024 ────────────────────────────────────────────────────────────
  Widget _desktop(BuildContext context, _Person p) {
    return Row(
      children: [
        _avatar(p.photo, 32),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _name(p.name),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(child: _title(context, p)),
                  Expanded(child: _department(context, p)),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(child: _email(context, p)),
                  Expanded(child: _phone(context, p)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        _messageButton(context, withTitle: true),
      ],
    );
  }

  // ── 768 ─────────────────────────────────────────────────────────────
  Widget _tablet(BuildContext context, _Person p) {
    return Row(
      children: [
        _avatar(p.photo, 30),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _name(p.name),
              SizedBox(height: 8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title(context, p),
                        SizedBox(height: 6.h),
                        _department(context, p),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _phone(context, p),
                        SizedBox(height: 6.h),
                        _email(context, p),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        _messageButton(context, withTitle: false),
      ],
    );
  }

  // ── 375 ─────────────────────────────────────────────────────────────
  Widget _mobile(BuildContext context, _Person p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _avatar(p.photo, 20),
        SizedBox(width: 5.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _name(p.name),
              SizedBox(height: 2.h),
              _title(context, p),
              SizedBox(height: 2.h),
              _department(context, p),
              SizedBox(height: 2.h),
              _phone(context, p),
              SizedBox(height: 2.h),
              _email(context, p),
            ],
          ),
        ),
        SizedBox(width: 5.w),
        _messageButton(context, withTitle: false),
      ],
    );
  }

  // ── pieces ──────────────────────────────────────────────────────────

  /// `foregroundImage` over an SVG child: the default silhouette is an SVG
  /// that an ImageProvider cannot decode, so it has to be the child.
  Widget _avatar(String photo, double radius) {
    final bool hasPhoto =
        photo.isNotEmpty && photo != AppAssets.defaultEmployeeAvatar;
    return CircleAvatar(
      radius: radius.r,
      backgroundColor: AppColors.moreLightGrey,
      foregroundImage: hasPhoto ? appImageProvider(photo) : null,
      child: ClipOval(child: CardSvg.icon(CardSvg.male, size: radius * 2)),
    );
  }

  Widget _name(String name) => Text(
        FormatHelper.capitalize(name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize16Weight400.copyWith(color: AppColors.text),
      );

  Widget _info(String svg, String label, String value) => CardInfoRow(
        info: CardInfo(
          label: '$label:',
          // The email is left as typed -- capitalising it would change it.
          value: svg == CardSvg.email ? value : FormatHelper.capitalize(value),
          icon: CardSvg.icon(svg, color: AppColors.secondaryText),
        ),
        fontSize: 12,
        iconSize: 12,
      );

  Widget _title(BuildContext context, _Person p) =>
      _info(CardSvg.jobTitle, S.of(context).title, p.title);

  Widget _department(BuildContext context, _Person p) =>
      _info(CardSvg.department, S.of(context).department, p.department);

  Widget _phone(BuildContext context, _Person p) =>
      _info(CardSvg.phone, S.of(context).phoneNumber, p.phone);

  Widget _email(BuildContext context, _Person p) =>
      _info(CardSvg.email, S.of(context).email, p.email);

  Widget _messageButton(BuildContext context, {required bool withTitle}) {
    return customButtonWithSvg(
      title: withTitle ? S.of(context).message : '',
      function: () => openGrcChat(context, email),
      textStyle:
          StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: CardSvg.message,
      widthImage: 20.sp,
      heightImage: 20.sp,
      space: 8.w,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }
}

class _Person {
  final String name, title, department, phone, email, photo;

  const _Person({
    required this.name,
    required this.title,
    required this.department,
    required this.phone,
    required this.email,
    required this.photo,
  });
}

/// class name: [GrcAvatarName]
///
/// purpose: small "(avatar) Name" pair used inside table cells and list
///          cards (Control Owner column, Department Manager line, ...).
class GrcAvatarName extends StatelessWidget {
  final String email;
  final double avatarRadius;
  final TextStyle? style;

  const GrcAvatarName({
    super.key,
    required this.email,
    this.avatarRadius = 12,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (email.isEmpty) {
      return Text('-', style: style ?? CardStyles.value(12));
    }
    final String photo = findEmployeeByEmail(email).displayPhoto;
    final bool hasPhoto =
        photo.isNotEmpty && photo != AppAssets.defaultEmployeeAvatar;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarRadius.r,
          backgroundColor: AppColors.moreLightGrey,
          foregroundImage: hasPhoto ? appImageProvider(photo) : null,
          child: ClipOval(
            child: CardSvg.icon(CardSvg.male, size: avatarRadius * 2),
          ),
        ),
        SizedBox(width: 5.w),
        Flexible(
          child: Text(
            FormatHelper.capitalize(employeeDisplayName(context, email)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style ?? CardStyles.value(12),
          ),
        ),
      ],
    );
  }
}
