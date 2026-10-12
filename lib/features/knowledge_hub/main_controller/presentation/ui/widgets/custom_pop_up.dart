import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CustomPopupMenuButton extends StatelessWidget {
  final String title;
  final String iconPath;
  final List<PopupOption> options;
  final Function(String) onSelected;
  final Color backgroundColor;
  final Color iconColor;
  final double width;
  final double height;

  const CustomPopupMenuButton({
    super.key,
    required this.title,
    required this.iconPath,
    required this.options,
    required this.onSelected,
    required this.backgroundColor,
    required this.iconColor,
    this.width = 135,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ContextExtension(context).isPhone;
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: Offset(0, height + 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : AppColors.chatBackground,
      itemBuilder: (context) => options.map((option) {
        return HoverablePopupMenuItem(value: option.value, label: option.label);
      }).toList(),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.transparent),
        ),
        padding: EdgeInsets.symmetric(horizontal: 0.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              width: isMobile ? 14.w : 16.w,
              height: isMobile ? 14.h : 16.h,
              color: iconColor,
            ),
            isMobile ? SizedBox(width: 0.sp) : SizedBox(width: 8.sp),
            Text(
              title,
              style: isMobile
                  ? StyleText.fontSize14Weight500.copyWith(color: iconColor)
                  : StyleText.fontSize16Weight500.copyWith(color: iconColor),
            ),
            //  SizedBox(width: 4.sp),
          ],
        ),
      ),
    );
  }
}

class PopupOption {
  final String value;
  final String label;

  PopupOption({required this.value, required this.label});
}

// ✅ Custom hoverable item
class HoverablePopupMenuItem extends StatefulWidget
    implements PopupMenuEntry<String> {
  final String value;
  final String label;
  final double _height;

  const HoverablePopupMenuItem({
    super.key,
    required this.value,
    required this.label,
    double height = kMinInteractiveDimension,
  }) : _height = height;

  @override
  _HoverablePopupMenuItemState createState() => _HoverablePopupMenuItemState();

  @override
  double get height => _height;

  @override
  bool represents(String? value) => value == this.value;
}

class _HoverablePopupMenuItemState extends State<HoverablePopupMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () => Navigator.pop(context, widget.value),
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 12.sp),
        decoration: BoxDecoration(
          color: isHovered ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: StyleText.fontSize14Weight500.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
