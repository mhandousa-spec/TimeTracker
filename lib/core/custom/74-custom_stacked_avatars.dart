/// Module: Core · Custom · Custom Stacked Avatars
/// Description: Compact end-aligned stack of svg avatars used for message
///              reactions. Shows up to three, then a "+N" chip for the rest.
///              For the larger member-list variant that also handles network
///              and asset images, see stacked_avatars.dart.
/// Author: Knowticed Team

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

//By: Youssef Ashraf
class CustomStackedAvatars extends StatelessWidget {
  const CustomStackedAvatars({
    super.key,
    this.height,
    this.width,
    this.fontSize,
    this.avatarColor,
    required this.avatars,
    this.avatarTextColor,
  });

  final double? height;
  final Color? avatarColor;
  final Color? avatarTextColor;
  final double? width;
  final double? fontSize;
  final List<String> avatars;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      clipBehavior: Clip.none,
      children: List.generate(
        avatars.length > 3 ? 4 : avatars.length,
        (index) {
          //only used if length is >4
          final isLast = index == 3;

          return isLast && avatars.length > 3
              ? PositionedDirectional(
                  end: -8.w * index,
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: avatarColor ?? AppColors.lightGrey,
                    child: Text(
                      '+${avatars.length - 3}',
                      style: GoogleFonts.roboto(
                        fontSize: fontSize ?? 8.sp,
                        fontWeight: FontWeight.w700,
                        color: avatarTextColor ?? AppColors.black,
                      ),
                    ),
                  ),
                )
              : PositionedDirectional(
                  end: index != 0 ? (-8.w * index) : null,
                  child: CircleAvatar(
                    radius: 10.r,
                    backgroundColor: avatarColor ?? AppColors.lightGrey,
                    child: SvgPicture.asset(
                      avatars[index],
                    ),
                  ),
                );
        },
      ).toList(),
    );
  }
}
