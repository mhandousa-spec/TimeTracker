/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_person_card.dart
/// Purpose: List item for one employee on the Control Champions and Control
///          Owners tabs of GrcModuleDetailsPage.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026
/// Updated: 15/9/2026 - Redrawn from MAGDY at 375 / 768 / 1024: the compact
///          champion tile, and the wide owner row with its Policies /
///          Controls chips. Message now opens the chat.
library;

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcModulePersonCard]
///
/// purpose: one employee, identified by [email].
///
///   * [policyNames] / [controlNames] null -> the compact champion tile
///     (avatar, name, department, job title, Message) that the tab lays out
///     1 / 2 / 3 up.
///   * both set -> the wide owner row: name, Job Title and Department on one
///     line (stacked on the phone), then a "Policies" and a "Controls" chip
///     row.
class GrcModulePersonCard extends StatelessWidget {
  final String email;
  final VoidCallback? onTap;
  final List<String>? policyNames;
  final List<String>? controlNames;

  const GrcModulePersonCard({
    super.key,
    required this.email,
    this.onTap,
    this.policyNames,
    this.controlNames,
  });

  bool get _isOwnerRow => policyNames != null && controlNames != null;

  @override
  Widget build(BuildContext context) {
    // GestureDetector, not InkWell: no hover / splash overlay on the card.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: CardStyles.radius(),
        ),
        child: _isOwnerRow ? _ownerRow(context) : _championTile(context),
      ),
    );
  }

  // ── shared bits ─────────────────────────────────────────────────────

  Widget _avatar() {
    final String photo = findEmployeeByEmail(email).displayPhoto;
    final bool hasPhoto =
        photo.isNotEmpty && photo != AppAssets.defaultEmployeeAvatar;
    return CircleAvatar(
      radius: 20.r,
      backgroundColor: AppColors.moreLightGrey,
      foregroundImage: hasPhoto ? appImageProvider(photo) : null,
      child: ClipOval(child: CardSvg.icon(CardSvg.male, size: 40)),
    );
  }

  Widget _message(BuildContext context,
      {required bool withTitle, bool compact = false}) {
    // Icon-only on mobile, whatever the layout asked for.
    final bool showTitle =
        withTitle && screenSizeOf(context) != ScreenSize.mobile;
    return customButtonWithSvg(
      title: showTitle ? S.of(context).message : '',
      function: () => openGrcChat(context, email),
      textStyle:
          StyleText.fontSize12Weight400.copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: CardSvg.message,
      widthImage: 18.sp,
      heightImage: 18.sp,
      space: 6.w,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
      fixedWidth: (compact && showTitle) ? 100.w : null,
      fixedHeight: compact ? 30.sp : null,
    );
  }

  Text _line(String text, TextStyle style) => Text(
        FormatHelper.capitalize(text),
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  // ── champion tile ───────────────────────────────────────────────────

  Widget _championTile(BuildContext context) {
    final employee = findEmployeeByEmail(email);
    final String department = employee.localizedDepartment(context);
    final String jobTitle = employee.localizedJobTitle(context);
    final TextStyle sub = CardStyles.label(10);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: _avatar(),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _line(employeeDisplayName(context, email),
                  CardStyles.title(12)),
              if (department.isNotEmpty) _line(department, sub),
              if (jobTitle.isNotEmpty) _line(jobTitle, sub),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // GRC bug report p29: smaller button on the champion card.
        _message(context, withTitle: true, compact: true),
      ],
    );
  }

  // ── owner row ───────────────────────────────────────────────────────

  Widget _ownerRow(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final employee = findEmployeeByEmail(email);
    final String name = employeeDisplayName(context, email);
    final String department = employee.localizedDepartment(context);
    final String jobTitle = employee.localizedJobTitle(context);
    final S s = S.of(context);

    final Widget header = isMobile
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(),
              SizedBox(width: 5.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line(name, CardStyles.title(14)),
                    _labelValue('${s.jobTitle}:', jobTitle, 10),
                    _labelValue('${s.department}:', department, 10),
                  ],
                ),
              ),
              _message(context, withTitle: false),
            ],
          )
        // GRC bug report p30: the Message button belongs at the row's end.
        // With three flex-3 Flexibles and a flex-1 Spacer the Spacer only got
        // a tenth of the free space, so the button sat mid-row. The info now
        // lives in an Expanded, which pins the button to the edge.
        : Row(
            children: [
              _avatar(),
              SizedBox(width: 5.w),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                        flex: 3, child: _line(name, CardStyles.title(16))),
                    SizedBox(width: 20.w),
                    Flexible(
                        flex: 3,
                        child: _labelValue('${s.jobTitle}:', jobTitle, 12)),
                    SizedBox(width: 20.w),
                    Flexible(
                        flex: 3,
                        child:
                            _labelValue('${s.department}:', department, 12)),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              _message(context, withTitle: true),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        SizedBox(height: 8.h),
        _chipRow(context, s.policies, policyNames!, isMobile),
        SizedBox(height: 5.h),
        _chipRow(context, s.controls, controlNames!, isMobile),
      ],
    );
  }

  Widget _labelValue(String label, String value, double size) => Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(size),
          children: [
            TextSpan(
              text: FormatHelper.capitalize(value),
              style: CardStyles.value(size),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

  Widget _chipRow(BuildContext context, String label, List<String> names,
      bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isMobile ? 45.w : 60.w,
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: _line(label, CardStyles.label(12)),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 5.w,
            runSpacing: 5.h,
            children: [
              for (final String n in names)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(FormatHelper.capitalize(n),
                      style: CardStyles.value(10)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
