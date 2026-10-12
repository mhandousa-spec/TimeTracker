import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';

class ExpandableContainer extends StatefulWidget {
  final bool expanded;
  final String title;
  final Color? color;
  final Color? textColor;
  final double? paddingV;
  final bool isOpened;

  const ExpandableContainer(
      {Key? key,
      required this.expanded,
      required this.title,
      this.color,
      this.paddingV,
      this.isOpened = false,
      this.textColor})
      : super(key: key);

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Container(
      decoration: BoxDecoration(

        borderRadius:   widget.expanded == false 
            ? BorderRadius.all(
                Radius.circular(4),
              )
            : BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(4),
                 bottomRight: Radius.circular(4),
              ),
        color: widget.color ?? AppColors.colorBlack,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isPortrait ? 0.02.w : 0.02.h,
        vertical: widget.paddingV ?? (isPortrait ? 0.007.h : 0.012.h),
      ),
      // FIXED 8/9/2026 — "A RenderFlex overflowed by 89 pixels on the right."
      //
      // The chevron was sized `height: isPortrait ? 0.4.h : null`. In this file
      // `.h` is the fraction extension from app_font_size.dart, NOT
      // flutter_screenutil: `0.4.h` is forty percent of the SCREEN HEIGHT. On a
      // phone that is a ~350px-tall arrow, and SvgPicture preserves the aspect
      // ratio, so it also claimed ~350px of width inside a row roughly 355px
      // wide. The title took the remainder and the Row overflowed.
      //
      // It looked phone-only because the landscape branch is `null` (the
      // asset's natural size) and a tablet is normally landscape — the same
      // 0.4.h would break a tablet held in portrait just as badly.
      //
      // 0.024.h is ~21px on a phone and ~25px on a tablet in portrait, which
      // sits with the title beside it and with the natural size landscape uses.
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Expanded so the title yields to the chevron rather than pushing
            // it out of the row. This widget takes an arbitrary caller-supplied
            // title, so a long or translated one could overflow on its own even
            // with the icon sized correctly.
            Expanded(
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: isTablet
                        ? isPortrait
                            ? FontConstants.fontSize018.h
                            : FontConstants.fontSize024.h
                        : FontConstants.fontSize018.h,
                    // ignore: unrelated_type_equality_checks
                    color: widget.textColor ??
                        (themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorWhite
                            : AppColors.colorGreydark),
                    fontWeight: FontWeight.w500,
                    height: 1.6),
              ),
            ),
            SizedBox(width: 0.01.w),
            widget.expanded
                ? SvgPicture.asset(
                    'assets/icons_assets/organization_chart_assets/AltArrowUp.svg',
                    // ignore: deprecated_member_use
                    color: widget.textColor,
                    height: isPortrait ? 0.024.h : null,
                  )
                : Transform.rotate(
                    angle: 3.14159,
                    child: SvgPicture.asset(
                      'assets/icons_assets/organization_chart_assets/AltArrowUp.svg',
                      height: isPortrait ? 0.024.h : null,
                      // ignore: deprecated_member_use
                      color: widget.textColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
