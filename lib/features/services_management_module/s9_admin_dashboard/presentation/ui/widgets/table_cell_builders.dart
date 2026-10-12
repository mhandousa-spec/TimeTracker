// ******************* FILE INFO *******************
// File Name: table_cell_builders.dart
// Description: Widget-level cell builders for ServiceRequestTableWidget.
// Module: services_management_module / presentation / s9_admin_dashboard / ui / widgets
//              Receives already-resolved strings — no data reading here.
// Created by: Amr Mesbah

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

class TableCellBuilders {
  const TableCellBuilders._();

  // ─── Styles ────────────────────────────────────────────────────────────────

  static TextStyle headerStyle() =>
      StyleText.fontSize14Weight600.copyWith(color: AppColors.white);

  static TextStyle cellStyle(BuildContext context) =>
      StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.blackButton
            : AppColors.white,
      );

  // ─── Base cell ─────────────────────────────────────────────────────────────

  static Widget cell(
      BuildContext context,
      Widget child, {
        EdgeInsets? padding,
      }) {
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: cellStyle(context),
        child: child,
      ),
    );
  }

  // ─── Text cell ─────────────────────────────────────────────────────────────

  static Widget textCell(
      BuildContext context,
      String text, {
        int maxLines = 2,
        TextAlign textAlign = TextAlign.start,
        Color? textColor,
        FontWeight? fontWeight,
      }) {
    return cell(
      context,
      Text(
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: cellStyle(context).copyWith(
          color: textColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  // ─── Person cell (name + avatar) ───────────────────────────────────────────

  static Widget personCell(
      BuildContext context,
      String name,
      bool isMale, {
        required bool isArabic,
      }) {
    final avatar = ClipOval(
      child: SvgPicture.asset(
        isMale ? 'assets/icons_assets/main_icons_assets/male_avatar.svg' : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
        width: 22.sp,
        height: 22.sp,
      ),
    );

    final nameText = Flexible(
      child: Text(
        FormatHelper.capitalize(name),
        overflow: TextOverflow.ellipsis,
        textAlign: isArabic ? TextAlign.end : TextAlign.start,
        style: cellStyle(context),
      ),
    );

    // In Arabic: name → avatar. In English: avatar → name.
    final children = isArabic
        ? <Widget>[nameText, SizedBox(width: 6.w), avatar]
        : <Widget>[avatar, SizedBox(width: 6.w), nameText];

    return cell(
      context,
      Directionality(
        textDirection:
        isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  // ─── Tap wrapper ───────────────────────────────────────────────────────────

  static Widget tappable(Widget child, VoidCallback onTap) =>
      InkWell(onTap: onTap, child: child);
}
