/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: contact_card.dart
/// Purpose: Declares `ContactCard`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Figma node 6550:9864 — wide contact card (898x110) with Message button.
// Adapts automatically: wide = single row, mobile = stacked layout.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';

/// Contact/employee card: avatar + name + (title, email) + (department,
/// phone) + primary action button.
///
/// ```dart
/// ContactCard(
///   name: 'Mona Mohammed',
///   jobTitle: 'Technician',
///   department: 'IT',
///   email: 'Mona.Mohamed@GulfDev.com',
///   phone: '+2010258963',
///   avatar: NetworkImage(url),
///   onMessage: () {},
/// )
/// ```
class ContactCard extends StatelessWidget {
  final String name;
  final String? jobTitle;
  final String? department;
  final String? email;
  final String? phone;
  final ImageProvider? avatar;
  final String buttonText;
  final VoidCallback? onMessage;
  final double? width;

  /// Below this width the card stacks vertically (mobile).
  final double breakpoint;

  const ContactCard({
    super.key,
    required this.name,
    this.jobTitle,
    this.department,
    this.email,
    this.phone,
    this.avatar,
    this.buttonText = 'Message',
    this.onMessage,
    this.width,
    this.breakpoint = 500,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= breakpoint.w;
          return isWide ? _wideLayout() : _mobileLayout();
        },
      ),
    );
  }

  // ── Wide (tablet / web): avatar | info columns | button ──
  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _avatar(40),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name,
                  style: CardStyles.title(16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 8.h),
              Row(
                children: [
                  if (jobTitle != null)
                    Expanded(child: _info(CardSvg.jobTitle, 'Title:', jobTitle!)),
                  if (department != null)
                    Expanded(
                        child: _info(CardSvg.department, 'Department:',
                            department!)),
                ],
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  if (email != null)
                    Expanded(child: _info(CardSvg.email, 'Email:', email!)),
                  if (phone != null)
                    Expanded(
                        child:
                            _info(CardSvg.phone, 'Phone Number:', phone!)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        _messageButton(),
      ],
    );
  }

  // ── Mobile: stacked ──
  Widget _mobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _avatar(28),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(name,
                  style: CardStyles.title(16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (jobTitle != null) ...[
          _info(CardSvg.jobTitle, 'Title:', jobTitle!),
          SizedBox(height: 6.h),
        ],
        if (department != null) ...[
          _info(CardSvg.department, 'Department:', department!),
          SizedBox(height: 6.h),
        ],
        if (email != null) ...[
          _info(CardSvg.email, 'Email:', email!),
          SizedBox(height: 6.h),
        ],
        if (phone != null) ...[
          _info(CardSvg.phone, 'Phone Number:', phone!),
          SizedBox(height: 6.h),
        ],
        SizedBox(height: 4.h),
        SizedBox(width: double.infinity, child: _messageButton()),
      ],
    );
  }

  Widget _avatar(double radius) => CircleAvatar(
        radius: radius.r,
        backgroundColor: AppColors.barrierColor,
        foregroundImage: avatar,
        child: ClipOval(
          child: CardSvg.icon(CardSvg.male, size: radius * 2),
        ),
      );

  Widget _info(String svgPath, String label, String value) => CardInfoRow(
        info: CardInfo(
          label: label,
          value: value,
          icon: CardSvg.icon(svgPath, color: AppColors.secondaryBlack),
        ),
        fontSize: 14,
        iconSize: 13,
      );

  Widget _messageButton() => customButtonWithSvg(
        title: buttonText,
        function: onMessage ?? () {},
        textStyle: CardStyles.title(16).copyWith(color: AppColors.textButton),
        height: 38.h,
        space: 8.w,
        radius: 8.r,
        color: AppColors.primary,
        image: CardSvg.message,
        widthImage: 24.r,
        heightImage: 24.r,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
      );
}
