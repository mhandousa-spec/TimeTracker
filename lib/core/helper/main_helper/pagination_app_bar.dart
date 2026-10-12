/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: pagination_app_bar.dart
/// Purpose: Declares `PaginationAppBar`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/knowledge_hub_module/core/theming/new_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/helper/main_helper/custom_app_bar.dart';

class PaginationAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PaginationAppBar({
    super.key,
    required this.screensTitles,
    this.padding,
  });
  final List<String> screensTitles;

  /// Padding around the breadcrumb row on tablet/desktop.
  ///
  /// ADDED 18/8/2026. Null keeps the historical behaviour — 15.sp (phone) or
  /// 30.sp top and bottom, and **zero horizontal**, which is why the title
  /// rendered flush against the page edge. This widget is shared with other
  /// modules, so that default is left as it was; `form_builder_module` passes
  /// `formBuilderTitlePadding` (20.sp all round) at every call site.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isTablet
        ? _buildTabletAppBar(context)
        : _buildMobileAppBar();
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  _buildMobileAppBar() {
    return CustomAppBar(
      title: screensTitles.last,
      paddedLeading: false,
      hideLeading: screensTitles.length == 1,
      centerTitle: false,
    );
  }

  _buildTabletAppBar(BuildContext context) {
    final List<String> visibleTitles = screensTitles.length > 3
        ? screensTitles.sublist(screensTitles.length - 3)
        : screensTitles;
    final int startIndex = screensTitles.length - visibleTitles.length;

    return Padding(
        padding: padding ??
            EdgeInsetsDirectional.only(
              top: ContextExtension(context).isPhone ? 15.sp : 30.sp,
              bottom: ContextExtension(context).isPhone ? 15.sp : 30.sp,
            ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: context.isArabic, // ✅ this makes it start from right in RTL
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                spacing: 15.sp,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  visibleTitles.length,
                      (index) => _buildAppBarItem(context,
                      title: visibleTitles[index],
                      originalIndex: startIndex + index,
                      isLast: ((index + 1) == visibleTitles.length)),
                ),
              ),
              Container()
            ],
          ),
        ));
  }

  _buildAppBarItem(BuildContext context,
      {required String title, required int originalIndex, required bool isLast}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 15.sp,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: isLast
                ? null
                : () {
              int manyPop = screensTitles.length - (originalIndex + 1);
              for (int i = 0; i < manyPop; i++) {
                Navigator.of(context).pop();
              }
            },
            child: Text(screensTitles[originalIndex],
                style: StyleText.fontSize28Weight600.copyWith(
                    color: AppColors.text)),
          ),
          if (!isLast)
            Transform.rotate(
              angle: context.isArabic ? -3.14 : 0,
              child: Container(
                margin: EdgeInsets.only(top: 3.sp),
                child: SvgPicture.asset(
                  height: 25.sp,
                  width: 25.sp,
                  "assets/icons_assets/main_icons_assets/chevron_right.svg",
                  fit: BoxFit.fill,
                  colorFilter:
                  ColorFilter.mode(AppColors.text, BlendMode.srcIn),
                ),
              ),
            ),
        ],
      ),
    );
  }
}