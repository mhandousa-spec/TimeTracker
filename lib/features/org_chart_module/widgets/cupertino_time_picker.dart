import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CupertinoTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeChanged;

  const CupertinoTimePicker({
    Key? key,
    required this.onDateTimeChanged,
  }) : super(key: key);

  @override
  _CupertinoTimePickerState createState() => _CupertinoTimePickerState();
}

class _CupertinoTimePickerState extends State<CupertinoTimePicker> {
  TimeOfDay endTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return AlertDialog(
      content: SizedBox(
        height: 0.15.h,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: DateTime.now(),
          onDateTimeChanged: widget.onDateTimeChanged,
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 0.025.h),
          child: Container(
            height: isVertical ? 0.04.h : null,
            child: Row(
              // direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: customButton(
                    title: S.of(context).Cancel,
                    color: AppColors.colorGreydark,
                    function: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Container(width: 0.025.w),
                Expanded(
                  child: customButton(
                    title: S.of(context).setTime,
                    color: AppColors.bubbleColor,
                    function: () {
                      setState(() {
                        widget.onDateTimeChanged;
                      });

                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
