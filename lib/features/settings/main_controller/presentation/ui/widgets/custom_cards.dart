/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: custom_cards.dart
/// Purpose: The settings menu row — label + icon, selectable or switchable.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - Moved out of widgets/shared/ (CR-SKEL-SEMAIN-N03);
///          commented-out print() lines deleted (N22) and the raw Colors.* /
///          Color(0xFF…) values routed through AppColors (N23).

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'dart:math' as math;


import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/pages/settings_screen.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
class CustomCard extends StatefulWidget {
  final String name;
  final Widget? icon;
  final bool isSwitchTile;
  final bool hideIcon;
  final bool showCurrency;

  /// The switch's value. Was a mutable widget field written from
  /// `onToggle` — widget fields must be final (§16); the live value now lives
  /// in [CustomCardState._switchValue] and this is only the initial value.
  final bool currentValue;

  final Function(bool)? onSwitchChanged;
  final Function()? onTap;
  final int index;

  /// Index of the currently selected card. Was mutable; nothing ever wrote it.
  final int? selectIndex;

  // NEW: Add a property to track if this card is selected
  final bool isSelected;

  CustomCard({
    super.key,
    required this.name,
    this.icon,
    this.isSwitchTile = false,
    this.currentValue = false,
    this.hideIcon = false,
    this.showCurrency = false,
    this.onSwitchChanged,
    this.onTap,
    this.index = 0,
    this.selectIndex,
    this.isSelected = false, // NEW: Default to false
  });

  @override
  CustomCardState createState() => CustomCardState();
}

class CustomCardState extends State<CustomCard> {
  /// Live switch value. Seeded from the widget and updated locally, so the
  /// widget itself stays immutable.
  late bool _switchValue = widget.currentValue;

  @override
  void didUpdateWidget(covariant CustomCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep following the parent when it pushes a new value (e.g. the theme
    // controller rebuilding the menu after a toggle).
    if (oldWidget.currentValue != widget.currentValue) {
      _switchValue = widget.currentValue;
    }
  }
  ThemeController themeController = Get.put(ThemeController());
  bool isEnglish = Get.locale.toString().contains('en');
  final HapticController hapticController = Get.put(HapticController());

  // NEW: Method to check if this card is currently selected
  bool get isCurrentlySelected {
    return widget.selectIndex == widget.index || widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final orientation = MediaQuery.of(context).orientation;

    return LayoutBuilder(
      builder: (context, constraints) {
        var isMobile = ContextExtension(context).isPhone;
        var lightMode = Theme.of(context).brightness == Brightness.light;

        // NEW: Determine colors based on selection state
        final bool isSelected = isCurrentlySelected;
        final Color backgroundColor = isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.transparent;









        // Replace the existing FlutterSwitch widget in CustomCard with this:

        final trailingWidget = widget.isSwitchTile
            ? Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(
              Get.locale.toString().contains('en') ? 0 : math.pi),
          child: FlutterSwitch(
            // New styling
            activeColor: AppColors.secondaryPrimary,
            height: 22.sp,
            width: 38.sp,
            padding: 3.sp,
            borderRadius: 20.sp,
            toggleSize: 16.sp,
            toggleColor: AppColors.white, // White toggle/circle
            inactiveColor: AppColors.switchTrackOff.withOpacity(0.16),
            value: _switchValue,
            onToggle: (newValue) {
              setState(() => _switchValue = newValue);
              widget.onSwitchChanged?.call(newValue);
            },
          ),
        )
            : Transform.rotate(
          // chevron_right.svg points right natively: leave it as-is in English
          // and flip it 180° in Arabic so it always points "forward".
          angle: Get.locale.toString().contains('en') ? 0 : math.pi,
          child: Transform.scale(
            scale: MediaQuery.of(context).size.shortestSide > 600
                ? (orientation == Orientation.portrait ? 0.7 : 1)
                : 1.3,
            child: SvgPicture.asset(
              // ignore: deprecated_member_use
              color: AppColors.text,
              themeController.currentTheme == AppColors.darkTheme
                      ? 'assets/icons_assets/main_icons_assets/chevron_right.svg'
                      : 'assets/icons_assets/main_icons_assets/chevron_right.svg',
            ),
          ),
        );

        return GestureDetector(
          onTap: () {
            hapticController.triggerHapticFeedback(
                vibration: VibrateType.mediumImpact,
                hapticFeedback: HapticFeedback.mediumImpact);

            // FIRST: Check if it's a switch - don't do anything for selection
            if (widget.isSwitchTile) {
              return;
            }

            // SECOND: If onTap is provided, call it (this is for mobile navigation)
            if (widget.onTap != null) {
              widget.onTap!();
              return; // Important: return here to prevent further execution
            }

            // THIRD: Only update selection for tablet mode (when onTap is null)
            if (!widget.hideIcon) {
              final SettingsScreenState? state =
              context.findAncestorStateOfType<SettingsScreenState>();
              if (state != null) {
                state.setSelectedContainerIndex(widget.index);
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 10.sp,
            ),
            child: Container(
              // NEW: Apply background color based on selection
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 0.01.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.icon != null)
                      Center(
                        child: Container(
                            // .sp on both axes so the tile stays a true square:
                            // 40.w and 40.h scale by different factors, which
                            // was stretching the icon background.
                            width: 40.sp,
                            height: 40.sp,
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(4.r),
                              // NEW: Change icon background color when selected
                              color: isSelected
                                  ? AppColors.primary.withOpacity(.5)
                                  : AppColors.primary.withOpacity(.15),
                            ),
                            child: SizedBox(
                              // NEW: Apply icon color based on selection
                                child: Center(child: widget.icon)
                            )
                        ),
                      ),
                    if (widget.icon != null)
                      SizedBox(
                          width: isTablet
                              ? (orientation == Orientation.portrait
                              ? 0.01.h
                              : 0.02.h)
                              : 0.015.h),
                    Container(
                      width: widget.icon != null
                          ? isTablet
                          ? (orientation == Orientation.portrait
                          ? 0.2.w
                          : 0.17.w)
                          : 0.55.w
                          : isTablet
                          ? (orientation == Orientation.portrait
                          ? widget.isSwitchTile == true
                          ? 0.2.w
                          : 0.25.w
                          : 0.19.w)
                          : 0.65.w,
                      padding: EdgeInsets.only(
                        top: isTablet
                            ? (orientation == Orientation.portrait
                            ? 0.002.h
                            : 0.008.h)
                            : 0,
                        bottom: isTablet
                            ? (orientation == Orientation.portrait
                            ? 0.002.h
                            : 0.008.h)
                            : 0,
                      ),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Get.locale.toString().contains('en')
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          // NEW: Apply text color based on selection
                          child: Text(
                            widget.name,
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          )
                      ),
                    ),
                    if (widget.showCurrency == true) const Spacer(),
                    if (widget.showCurrency == true)
                      Container(
                        height: MediaQuery.of(context).size.shortestSide > 600
                            ? (orientation == Orientation.landscape
                            ? 0.04.h
                            : 0.04.w)
                            : null,
                        decoration: BoxDecoration(
                          color: MediaQuery.of(context).size.shortestSide > 600
                              ? AppColors.transparent
                              : AppColors.signOut,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color:
                            MediaQuery.of(context).size.shortestSide > 600
                                ? AppColors.colorBlack
                                : AppColors.transparent,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.01.w,
                              vertical:
                              MediaQuery.of(context).size.shortestSide < 600
                                  ? 0.01.w
                                  : 0),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale:
                                MediaQuery.of(context).size.shortestSide >
                                    600
                                    ? 1
                                    : 0.7,
                                child:
                                MediaQuery.of(context).size.shortestSide >
                                    600
                                    ? (orientation == Orientation.portrait
                                    ? SizedBox(
                                  width: 0.04.w,
                                  height: 0.02.h,
                                  child: SvgPicture.asset(
                                    '',
                                    package: 'country_icons',
                                  ),
                                )
                                    : SizedBox(
                                  width: 0.027.w,
                                  height: 0.03.h,
                                  child: SvgPicture.asset(
                                    '',
                                    package: 'country_icons',
                                  ),
                                ))
                                    : SizedBox(
                                  width: 0.075.w,
                                  height: 0.025.h,
                                  child: SvgPicture.asset(
                                    '',
                                    package: 'country_icons',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 0.01.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.showCurrency == true &&
                        MediaQuery.of(context).size.shortestSide < 600)
                      SizedBox(
                        width: 0.05.w,
                      ),
                    Spacer(),
                    if (widget.hideIcon == false)
                      Container(
                        width: widget.isSwitchTile == true ? null : isMobile ? 0.055.w:  0.020.w,
                        height: widget.isSwitchTile == true ? null :isMobile ? 0.030.h: 0.030.h,
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: trailingWidget,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}