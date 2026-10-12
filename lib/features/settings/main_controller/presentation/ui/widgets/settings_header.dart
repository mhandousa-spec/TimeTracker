/// Module: settings/main_controller
///
///*************************** FILE INFO ****************************///
/// File Name: settings_header.dart
/// Purpose: Section heading (icon + title) reused by every settings section,
///          plus the section overflow menu.
/// Author: Amr Mesbah
/// Created at: 10/11/2024
/// Updated: 11/8/2026 - Moved out of widgets/shared/ (CR-SKEL-SEMAIN-N03);
///          raw colours routed through AppColors (N23); header added.

import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
// Subscription dialogs (stubs — subscription module not included in knowticed)
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/generated/l10n.dart';
class SettingsHeader extends StatefulWidget {
  final String imagePath;
  final String text;
  final bool hideDiv;
  final bool isRequestDialog;
  final bool isRequestDialogSmallSize;
  final bool isSettings;

  /// Horizontal inset around the header row.
  ///
  /// ADDED. Null keeps the historical behaviour — 15.sp on phone, 0 elsewhere
  /// — which every existing call site relies on. Pass 0 when the CARD around
  /// this header already applies its own horizontal padding: the two stacked,
  /// so the icon sat 15.sp further in than the fields underneath it.
  /// (`academic_history.dart` avoids this the other way round, by padding each
  /// child instead of the card.)
  final double? horizontalPadding;

  SettingsHeader(
      {required this.imagePath,
      required this.text,
      this.hideDiv = false,
      this.isRequestDialog = false,
      this.isSettings = false,
      this.horizontalPadding,
      this.isRequestDialogSmallSize = false});

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool orientation =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            widget.horizontalPadding ?? (context.isPhone ? 15.sp : 0.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                widget.imagePath,
                height: 25.h,
                width: 25.w,
                // ignore: deprecated_member_use
              ),
              SizedBox(
                width:
                    isTablet ? (orientation == true ? 0.015.w : 0.008.w) : 0.03.w,
              ),
              Text(
                widget.text,
                style: StyleText.fontSize18Weight500.copyWith(
                    color: AppColors.text
                 )
              ),
              if (widget.isRequestDialog == true) Spacer(),
              if (widget.isRequestDialog == true)
                InkWell(
                  onTap: () {
                    Navigator.pop(context, false);
                  },
                  child: SvgPicture.asset(
                    "assets/icons_assets/messaging_assets/close_x_teal.svg",
                  ),
                ),
              widget.isSettings ? Spacer() : const SizedBox.shrink(),
              widget.isSettings
                  ? widget.hideDiv
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTapUp: (details) {
                            final iconPosition = details.globalPosition;
                            _showSortMenu(context, iconPosition);
                          },
                          child: Container(
                            //width: orientation ?!isTablet?0.1.w :0.07.w : 0.06.w,
                            height: orientation
                                ? !isTablet
                                    ? 0.035.h
                                    : 0.021.h
                                : 0.045.h,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.signOut),
                            child: !isTablet
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 0.01.h),
                                    child: SvgPicture.asset(
                                        "assets/icons_assets/main_icons_assets/plus.svg"),
                                  )
                                : Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 0.01.w),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons_assets/main_icons_assets/plus.svg",
                                          color: AppColors.textButton,
                                        ),
                                        SizedBox(
                                          width: 0.007.w,
                                        ),
                                        Text(
                                          S.of(context).add,
                                          style: AppFontStyle.cairoRegularStyle
                                              .copyWith(
                                            fontSize: orientation
                                                ? FontConstants.fontSize011.h
                                                : FontConstants.fontSize022.h,
                                            fontWeight: FontWeight.w500,
                                            height: 1.5,
                                            color: AppColors.textButton,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        )
                  : const SizedBox.shrink()
            ],
          ),
          if (widget.isRequestDialog == true)
            SizedBox(
              height: 0.005.h,
            ),
          // widget.hideDiv == true
          //     ? const SizedBox.shrink()
          //     : Padding(
          //         padding: EdgeInsets.only(top: isTablet ? 0.01.h : 0.005.h),
          //         child: Container(
          //           height: 0.5,
          //           width: double.infinity,
          //         ),
          //       ),
        ],
      ),
    );
  }
}

enum StatusWant {
  // ignore: constant_identifier_names
  credit,
  // ignore: constant_identifier_names
  transfer,
  partner,
  // ignore: constant_identifier_names
}

void _showSortMenu(BuildContext context, Offset iconPosition) async {
  final List<StatusWant> sortOptions = [
    StatusWant.credit,
    StatusWant.transfer,
    StatusWant.partner
  ];
  // AddEmployeeController addEmployeeController = Get.find();
  //  AddDepartmentController addDepartmentController = Get.find();
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final double menuOffsetX = iconPosition.dx - (-9.0);
  final double menuOffsetY = iconPosition.dy - (-7.0);

  final RelativeRect position = RelativeRect.fromLTRB(
    menuOffsetX,
    menuOffsetY,
    overlay.size.width - menuOffsetX,
    overlay.size.height,
  );

  selectedOption = await showMenu(
    elevation: 0,
    shadowColor: AppColors.transparent,
    color: Theme.of(context).colorScheme.onPrimary,
    context: context,
    constraints: BoxConstraints(
      maxWidth: 0.5.w,
      minHeight: 0.0.h,
    ),
    position: position,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.signOut,
        )),
    items: sortOptions.map((option) {
      return CustomPopupMenuItem<StatusWant>(
          first: option.index == 0,
          last: option.index == sortOptions.length - 1,
          color: Theme.of(context).colorScheme.onPrimary,
          value: option,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getSortOptionLabel(option, context),
            ],
          ));
    }).toList(),
  );

  if (selectedOption != null) {
    switch (selectedOption!) {
      case StatusWant.credit:
        showDialog(
            context: context,
            builder: (context) {
              return const CreditCardDialog();
            });

        break;
      case StatusWant.transfer:
        showDialog(
            context: context,
            builder: (context) {
              return const BankTransferDialog();
            });

        break;
      case StatusWant.partner:
        showDialog(
            context: context,
            builder: (context) {
              return const TransactionalPartnerDialog();
            });
        break;
    }
  }
}

StatusWant? selectedOption;
Widget _getSortOptionLabel(StatusWant option, BuildContext context) {
  switch (option) {
    case StatusWant.credit:
      return const SortOptionWidget(
        iconAddress: '',
        text: "Credit Card",
        hasImage: false,
      );
    case StatusWant.transfer:
      return const SortOptionWidget(
        iconAddress: '',
        hasImage: false,
        iconColor: AppColors.neutralIconGrey,
        text: "Bank Transfer",
      );
    case StatusWant.partner:
      return const SortOptionWidget(
        iconAddress: '',
        iconColor: AppColors.neutralIconGrey,
        hasImage: false,
        text: "Transactional Partner",
      );
  }
}

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;
  final bool first;
  final bool last;

  const CustomPopupMenuItem({
    Key? key,
    required T value,
    bool enabled = true,
    required Widget child,
    required this.color,
    this.first = false,
    this.last = false,
  }) : super(key: key, value: value, enabled: enabled, child: child);

  @override
  // ignore: library_private_types_in_public_api
  _CustomPopupMenuItemState<T> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T>
    extends PopupMenuItemState<T, CustomPopupMenuItem<T>> {
  late BorderRadius borderRadius;
  double radius = 10;
  @override
  Widget build(BuildContext context) {
    if (widget.first) {
      borderRadius = BorderRadius.only(
          topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    } else if (widget.last) {
      borderRadius = BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius));
    } else {
      borderRadius = BorderRadius.zero;
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        color: widget.color,
        child: super.build(context),
      ),
    );
  }
}

// ─── Subscription dialog stubs (module not available in knowticed) ───────────

class CreditCardDialog extends StatelessWidget {
  const CreditCardDialog({super.key});
  @override
  Widget build(BuildContext context) => const AlertDialog(
        title: Text('Credit Card'),
        content: Text('Subscription module not available.'),
      );
}

class BankTransferDialog extends StatelessWidget {
  const BankTransferDialog({super.key});
  @override
  Widget build(BuildContext context) => const AlertDialog(
        title: Text('Bank Transfer'),
        content: Text('Subscription module not available.'),
      );
}

class TransactionalPartnerDialog extends StatelessWidget {
  const TransactionalPartnerDialog({super.key});
  @override
  Widget build(BuildContext context) => const AlertDialog(
        title: Text('Transactional Partner'),
        content: Text('Subscription module not available.'),
      );
}


// Moved here from core/helper/settings/core_widgets/main_widget/sort_option_widget.dart,
// which was removed. This file is its only consumer, so it is no longer a
// shared "custom" widget.
// Date Created :22/November/2023
// Developer Name : Mazen shabaan
// Objectives: this is a widget to the sort widget in messages screen
class SortOptionWidget extends StatelessWidget {
  const SortOptionWidget(
      {super.key,
      required this.text,
      required this.iconAddress,
      this.hasImage = true,
      this.iconColor});
  final String text;
  final String iconAddress;
  final Color? iconColor;
  final bool hasImage;
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Row(
      mainAxisAlignment:
          hasImage ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: <Widget>[
        hasImage
            ? Padding(
                padding: EdgeInsets.only(
                    right: Get.locale.toString().contains('en') ? 0.02.w : 0,
                    left: Get.locale.toString().contains('en') ? 0 : 0.02.w),
                child: Transform.scale(
                  scale: isTablet ? 1.2 : 1.1,
                  child: Container(
                    width: isTablet ? null : 0.06.w,
                    child: SvgPicture.asset(
                      iconAddress,
                      // ignore: deprecated_member_use
                      color: iconColor ?? Theme.of(context).colorScheme.scrim,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        Text(
          text,
          style: AppFontStyle.cairoRegularStyle.copyWith(
              fontSize: isTablet
                  ? isPortrait
                      ? FontConstants.fontSize014.h
                      : FontConstants.fontSize014.w
                  : FontConstants.fontSize035.w,
              color: Theme.of(context).colorScheme.inverseSurface,
              fontWeight: FontWeight.w400,
              height: isTablet ? (isPortrait ? 1.8 : 0.0022.h) : 0.0022.h),
        ),
      ],
    );
  }
}
