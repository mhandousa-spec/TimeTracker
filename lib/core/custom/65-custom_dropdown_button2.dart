/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_dropdown_button2.dart
/// Purpose: Declares `CustomDropdownButton2`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
class CustomDropdownButton2 extends StatefulWidget {
  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final ValueChanged<String?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final double? buttonHeight, buttonWidth, iconHeight;
  final EdgeInsetsGeometry? buttonPadding;
  final int? buttonElevation;
  final Widget? icon;
  final TextStyle? dropDownTextStyle;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final EdgeInsetsGeometry? itemPadding;
  final double? dropdownHeight, dropdownWidth;
  final EdgeInsetsGeometry? dropdownPadding;
  final BoxDecoration? dropdownDecoration;
  final int? dropdownElevation;
  final Offset offset;
  final bool? borded;
  final bool isBottomSheet;
  final bool hasPrefix;
  final String? prefixUrl;
  final bool? isCompany;
  final Color? backgroundColor;
  double? suffixPaddingDropDown;
  CustomDropdownButton2({
    this.isCompany,
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.iconHeight,
    this.selectedItemBuilder,
    this.backgroundColor,
    this.borded = false,
    this.prefixUrl,
    this.hasPrefix = false,
    this.isBottomSheet = false,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonElevation,
    this.icon,
    this.dropDownTextStyle,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemPadding,
    this.suffixPaddingDropDown,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.dropdownElevation,
    this.offset = const Offset(0, 0),
    Key? key,
  }) : super(key: key);

  @override
  State<CustomDropdownButton2> createState() => _CustomDropdownButton2State();
}

class _CustomDropdownButton2State extends State<CustomDropdownButton2> {
  final HapticController hapticController = Get.put(HapticController());

  bool filled = false;
  Color _borderColor = AppColors.grey;
  final FocusNode _focusNode = FocusNode();
  ThemeController themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
  
    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        hint: Row(
          children: [
            Focus(
              focusNode: _focusNode,
              onFocusChange: (hasFocus) {
                setState(() {});
              },
              child: Container(
                color: widget.backgroundColor ?? Colors.transparent,
                child: Text(widget.hint,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: widget.dropDownTextStyle ??
                        (isTablet
                            ? StyleText.fontSize16Weight400
                            : StyleText.fontSize14Weight400).copyWith(height: 1.6)),
              ),
            ),
          ],
        ),
        value: widget.value,
        items: widget.dropdownItems.map((item) {
          bool isSelected = item == widget.value;
          return DropdownMenuItem<String>(
            value: item,
            child: Row(
              children: [
                Expanded(
                  child: AutoSizeText(item,
                      maxLines: 1,
                      style: (isTablet
                              ? StyleText.fontSize16Weight400
                              : StyleText.fontSize14Weight400)
                          .copyWith(
                              color: isSelected
                                  ? AppColors.text
                                  : AppColors.darkGrey)),
                )
              ],
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
        selectedItemBuilder: widget.selectedItemBuilder,
        buttonStyleData: ButtonStyleData(
          height: widget.buttonHeight ?? 40.h,
          width: widget.buttonWidth ?? 12.w,
          padding: widget.buttonPadding ?? EdgeInsets.only(left: 20.w),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.borded == true ? _borderColor : Colors.transparent,
              width: 1.0,
            ),
          ),
          elevation: widget.buttonElevation,
        ),
        iconStyleData: IconStyleData(
          icon: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isTablet
                    ? widget.suffixPaddingDropDown ?? 0
                    : widget.suffixPaddingDropDown ?? 4.w),
            child: SvgPicture.asset(
              'assets/icons_assets/main_icons_assets/chevron_down.svg',
              height: widget.iconHeight??(orientation == Orientation.portrait
                  ? isTablet
                      ? 20.h
                      : 20.h
                  :  20.h),
              color: widget.value != null
                  ? AppColors.greyIcon
                  : null,
            ),
          ),
          iconEnabledColor: widget.iconEnabledColor,
          iconDisabledColor: widget.iconDisabledColor,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: widget.dropdownHeight ?? 250.h, //200,
          width: widget.dropdownWidth ?? 250.w,
          padding: widget.dropdownPadding,
          decoration: widget.dropdownDecoration ??
              BoxDecoration(
                // color:Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.transparent),
              ),
          elevation: widget.dropdownElevation ?? 8,
          //Null or Offset(0, 0) will open just under the button. You can edit as you want.
          offset: widget.offset,
          //Default is false to show menu below button
          isOverButton: false,
        ),
        menuItemStyleData: MenuItemStyleData(
          height: orientation == Orientation.portrait
              ? isTablet
                  ? 45.h
                  : 25.h
              : 30.h,
          padding: widget.itemPadding ??
              EdgeInsets.only(
                left: isTablet ? 10.w : 25.w,
                right: isTablet ? 10.w : 25.w,
              ),
        ),
      ),
    );
  }
}
