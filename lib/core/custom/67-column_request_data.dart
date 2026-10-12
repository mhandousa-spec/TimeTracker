/// Module: core/custom
///
///*************************** FILE INFO ****************************///
/// File Name: column_request_data.dart
/// Purpose: Declares `ColumnRequestData`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Date Created :14/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :14/November/2023
// Objectives: this is a widget to customize column of the requests
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/65-custom_dropdown_button2.dart';

// ignore: must_be_immutable
class ColumnRequestData extends StatefulWidget {
  ColumnRequestData({
    super.key,
    this.dropdownValue,
    this.dropDownValueState,
    required this.title,
    required this.isTextField,
    required this.hint,
    required this.isOptional,
    this.isDescription = false,
    this.maxlength,
    this.hideTitle = false,
    this.hasPrefix = false,
    this.hasSuffix = false,
    this.isRequestDialogMobile = false,
    this.prefixIcon,
    this.suffixUrl,
    this.dropDownItems,
    this.fillColor,
    this.buttonWidth,
    this.controllerState,
    this.validator,
    this.controllerfinishState,
    this.textController,
    this.readOnly,
    this.initialValue,
    this.maxlines,
    this.dropWidth,
    this.enabled = true,
    this.isEdit = false,
    this.isRequired = false,
    this.hassSuffixState,
    this.editField,
    this.prefixUrl,
    this.isPriority,
    this.buttonHeight,
    required this.isExpanded,
    this.suffixColor,
    this.isArabic = false,
    this.textDirection,
    this.contextMenuBuilder,
    this.keyboardType,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.textAlign,
  });
  final MainAxisAlignment? mainAxisAlignment;
  String? dropdownValue;
  ValueChanged<String?>? dropDownValueState;
  final String title;
  bool isTextField;
  bool? isRequired;
  String hint;
  bool isExpanded;

  /// will be deprecated
  bool isOptional;
  int? maxlength;
  List<String>? dropDownItems;
  String? Function(String?)? validator;
  final bool? isDescription;
  final bool hideTitle;
  final bool? hasPrefix;
  bool? hasSuffix;
  final String? suffixUrl;
  final int? maxlines;
  final String? initialValue;
  final Widget? prefixIcon;
  final bool? readOnly;
  final bool? isRequestDialogMobile;
  final Color? fillColor;
  final double? buttonWidth;
  final double? dropWidth;
  final bool? isEdit;
  TextInputType? keyboardType;
  ValueChanged<bool?>? hassSuffixState;
  TextEditingController? textController;
  ValueChanged<String?>? controllerState;
  ValueChanged? controllerfinishState;
  bool enabled;
  ValueChanged<bool>? enabledState;
  void Function()? editField;
  final String? prefixUrl;
  final bool? isPriority;
  final double? buttonHeight;
  bool isArabic;
  final Color? suffixColor;
  final TextDirection? textDirection;
  TextAlign? textAlign;
  Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;
  @override
  State<ColumnRequestData> createState() => _ColumnRequestDataState();
}

class _ColumnRequestDataState extends State<ColumnRequestData> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.hideTitle
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: widget.mainAxisAlignment!,
                children: [
                  widget.isArabic
                      ? RichText(
                          text: TextSpan(
                              text: "*",
                              style: isTablet
                                  ? StyleText.fontSize18Weight600
                                  : StyleText.fontSize14Weight600,
                              children: [
                                WidgetSpan(child: SizedBox(width: 10.w)),
                                TextSpan(
                                  text: widget.title,
                                  style: isTablet
                                      ? StyleText.fontSize18Weight600
                                      : StyleText.fontSize14Weight600,
                                )
                              ]),
                        )
                      : RichText(
                          text: TextSpan(
                              text: widget.title,
                              style: isTablet
                                  ? StyleText.fontSize18Weight600
                                  : StyleText.fontSize14Weight600,
                              children: widget.isOptional
                                  ? [
                                      WidgetSpan(child: SizedBox(width: 10.w)),
                                      TextSpan(
                                        text: "(${S.of(context).optional})",
                                        style: isTablet
                                            ? StyleText.fontSize18Weight600
                                            : StyleText.fontSize14Weight600,
                                      )
                                    ]
                                  : widget.isRequired == true
                                      ? [
                                          WidgetSpan(
                                              child: SizedBox(width: 10.w)),
                                          TextSpan(
                                            text: "*",
                                            style: isTablet
                                                ? StyleText.fontSize18Weight600
                                                : StyleText.fontSize14Weight600,
                                          )
                                        ]
                                      : []),
                        ),
                  if (widget.isEdit == true && !isEditMode) Spacer(),
                  if (widget.isEdit == true && !isEditMode)
                    InkWell(
                      onTap: widget.editField,
                      child: SvgPicture.asset(
                        'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                        height: 20.h,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
        widget.isTextField
            ? widget.isExpanded
                ? widget.isDescription == true
                    // Description variant: the core CustomTextField in
                    // multiline mode. Replaces the former
                    // CustomDescriptionTextField, whose only real differences
                    // were maxLines: 6, a multiline keyboard and a visible
                    // character counter — all supported here.
                    ? CustomTextField(
                        controller:
                            widget.textController ?? TextEditingController(),
                        maxLength: widget.maxlength ?? 200,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                        showCharCount: true,
                        enabled: widget.enabled,
                        fillColor: widget.fillColor,
                        textDirection: widget.textDirection,
                        hint: widget.hint,
                      )
                    : CustomTextField(
                        textAlign: widget.textAlign!,
                        height: isTablet
                            ? widget.maxlength != null
                                ? 48.h
                                : 38.h
                            : widget.maxlength != null
                                ? 58.h
                                : 43.h,
                        textDirection: widget.textDirection,
                        initialValue: widget.initialValue,
                        readOnly: widget.readOnly ?? false,
                        keyboardType: widget.keyboardType,
                        hint: widget.hint,
                        enabled: widget.enabled,
                        maxLength: widget.maxlength,
                        maxLines: widget.maxlines,
                        fillColor: widget.fillColor,
                        controller: widget.textController,
                        // core takes widgets rather than the old
                        // hasPrefix/hasSuffix + suffixUrl/suffixColor combo.
                        prefixIcon: widget.hasPrefix == true
                            ? widget.prefixIcon
                            : null,
                        suffixIcon: (widget.hasSuffix == true &&
                                widget.suffixUrl != null)
                            ? SvgPicture.asset(
                                widget.suffixUrl!,
                                colorFilter: widget.suffixColor == null
                                    ? null
                                    : ColorFilter.mode(
                                        widget.suffixColor!, BlendMode.srcIn),
                              )
                            : null,
                        // Null-aware: the previous code used `!` on callbacks
                        // that most call sites never pass, so typing in a
                        // field would throw (e.g. the System Logs filter).
                        onChanged: (value) {
                          setState(() {
                            widget.controllerState?.call(value);
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            widget.controllerfinishState
                                ?.call(widget.textController);
                          });
                        },
                      )
                : Container(
                    height: 50.h,
                    width: 20.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: context.isEnglish
                                  ? 10.w
                                  : 0,
                              right: context.isEnglish
                                  ? 0
                                  : 10.w),
                          child: Text(
                            widget.hint,
                            style: isPortrait
                                ? StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack)
                                : StyleText.fontSize18Weight500.copyWith(color: AppColors.secondaryBlack),
                          ),
                        ),
                        // ignore: deprecated_member_use
                        widget.hasSuffix == true
                            ? Padding(
                                padding: EdgeInsets.only(
                                    right: context.isEnglish
                                        ? 10.w
                                        : 0,
                                    left: context.isEnglish
                                        ? 0
                                        : 10.w),
                                child: SvgPicture.asset(
                                  widget.suffixUrl as String,
                                  // ignore: deprecated_member_use
                                  color: Theme.of(context).colorScheme.scrim,
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  )
            : CustomDropdownButton2(
                hint: widget.hint,
                prefixUrl: widget.prefixUrl,
                borded: false,
                buttonHeight: widget.buttonHeight ??
                    (isTablet
                        ? widget.maxlength != null
                            ? 48.h
                            : 38.h
                        : widget.maxlength != null
                            ? 58.h
                            : 43.h),
                suffixPaddingDropDown: isPortrait
                    ? isTablet
                        ? 10.w
                        : null
                    : null,
                buttonWidth: widget.buttonWidth ??
                    (isTablet
                        ? isPortrait
                            ? 150.w
                            : 200.w
                        : double.infinity),

                dropdownWidth: widget.dropWidth ?? (300.w),

                buttonPadding: EdgeInsets.symmetric(
                    horizontal: isPortrait
                        ? 4.w
                        : isTablet
                            ? 10.w
                            : 4.w),
                value: widget.dropdownValue, //requestType,
                dropdownItems: widget.dropDownItems ?? [],
                onChanged: (value) {
                  setState(() {
                    if (widget.isPriority != null) {
                      if (widget.isPriority == true) {
                        widget.dropdownValue = value;
                      }
                      widget.dropDownValueState!(widget.dropdownValue);
                    } else {
                      widget.dropdownValue = value;
                      widget.dropDownValueState!(widget.dropdownValue);
                    }

                    //requestType = value;
                  });
                },
              )
      ],
    );
  }
}
