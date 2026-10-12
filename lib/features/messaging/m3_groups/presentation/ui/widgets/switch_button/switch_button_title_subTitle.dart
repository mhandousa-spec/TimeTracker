import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/81-hover_example.dart';

import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';

class SwitchButtonTitleSubTitle extends StatelessWidget {
  const SwitchButtonTitleSubTitle({
    super.key,
    required this.title,
    required this.subTitle,
    required this.value,
    required this.onChanged,
    this.labelWidth,
  });
  final String title;
  final String subTitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth ?? 120.w,
          child: Text(
            title,
            style: StyleText.fontSize14Weight500,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        HoverExample(subtitle: subTitle),
        Spacer(),
        DefaultSwitchButton(value: value, onChanged: onChanged),
      ],
    );
  }
}