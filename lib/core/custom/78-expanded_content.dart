/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: expanded_content.dart
/// Purpose: Declares `ExpandedContent`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class ExpandedContent extends StatefulWidget {
  ExpandedContent({required this.content, required this.title});
  String title;
  Widget content;
  @override
  State<ExpandedContent> createState() => _ExpandedContentState();
}

class _ExpandedContentState extends State<ExpandedContent> {
  bool isHide = false;
  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: StyleText.fontSize16Weight600.copyWith(
                color:AppColors.text
              ),
            ),
            Spacer(),
            InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTap: () {
                isHide = !isHide;
                setState(() {});
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isHide ? S.of(context).show : S.of(context).hide,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      height: 1,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        if (!isHide) widget.content,
      ],
    );
  }
}
