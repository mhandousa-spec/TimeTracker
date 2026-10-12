// ******************* FILE INFO *******************
// File Name: sla_notification_widgets.dart
// Description: UI widgets for SLA notification screen
// Created by: Amr Mesbah
// Last Update: 30/8/2025
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';


class SlaNotificationWidgets {
  static double _fieldWidth(BuildContext context) =>
      ContextExtension(context).isPhone ? 100.sp : 150.sp;

  /// The SLA percentage input.
  ///
  /// ✅ No fixed `height` and no `contentPadding` override — the field keeps
  /// CustomTextField's own default box, exactly like every other field in the
  /// app. Sizing it by hand is what made these fields look different from the
  /// rest of the form and forced the "%" and the remove icon to be nudged into
  /// place with magic offsets.
  static Widget slaPercentageField({
    required BuildContext context,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: _fieldWidth(context),
      child: CustomTextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        hint: S.of(context).EnterPercentage,
        // Invalid state is shown by the message under the row, so no inline
        // errorText here.
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4),
        // ✅ The typed value is real content — it reads at full strength.
        // Only the placeholder is dimmed. (The value used to inherit the
        // hint's 50%-opacity grey, so entered percentages looked disabled.)
        valueStyle: StyleText.fontSize10Weight400
            .copyWith(color: AppColors.text),
        hintStyle: StyleText.fontSize10Weight400
            .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
      ),
    );
  }

  /// One complete SLA line: `label   [ field ] %   ⊖`, with the validation
  /// message on its own line underneath.
  ///
  /// ✅ FIX: the extra ("Add notification") rows used to be hand-built inline
  /// in sla_screen_page_part2.dart with their own copy of the text field and
  /// hardcoded `Padding(top: 4)` / `Padding(bottom: 10)` offsets, so they never
  /// lined up with the first row.
  ///
  /// Alignment is now structural instead of numeric: the label, the field, the
  /// "%" and the remove icon sit in ONE [Row] with
  /// [CrossAxisAlignment.center], so they centre on the tallest item (the
  /// field) whatever height it happens to be — no constant to keep in sync with
  /// the field's padding.
  ///
  /// Moving the validation message out of the field's own column is what makes
  /// that work: while it lived under the field, "centre" meant the centre of
  /// field *plus* message, which is exactly why the "%" and the icon floated
  /// below the middle of the input.
  static Widget slaRow({
    required BuildContext context,
    required TextEditingController controller,
    required bool isInvalid,
    required ValueChanged<String> onChanged,
    String? label,
    TextStyle? labelStyle,
    VoidCallback? onRemove,
  }) {
    final isMobile = ContextExtension(context).isPhone;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) ...[
                Flexible(
                  child: Text(
                    label,
                    style: labelStyle ??
                        StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.text,
                          letterSpacing: .34,
                        ),
                  ),
                ),
                SizedBox(width: 10.sp),
              ],
              slaPercentageField(
                context: context,
                controller: controller,
                onChanged: onChanged,
              ),
              SizedBox(width: 5.sp),
              Text("%", style: StyleText.fontSize15Weight400),
              if (onRemove != null && !isMobile) ...[
                SizedBox(width: 10.sp),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.remove_circle,
                      color: AppColors.red, size: 18.sp),
                ),
              ],
            ],
          ),

          // Validation message. The space stays reserved whether or not it is
          // showing, so a row never jumps and every row keeps the same height
          // as its neighbours.
          SizedBox(height: 3.sp),
          AnimatedOpacity(
            opacity: isInvalid ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              controller.text.contains('.') || controller.text.contains(',')
                  ? (Localizations.localeOf(context).languageCode == 'ar'
                      ? "الأرقام العشرية غير مسموحة"
                      : "Decimals are not allowed")
                  : S.of(context).Onlynumbersareallowed,
              style: StyleText.fontSize14Weight400.copyWith(
                fontSize: 10.sp,
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget addSlaButton({
    required BuildContext context,
    required VoidCallback onTap,
    required VoidCallback onSave,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.only(left: isArabic ? 0 : 30.w, bottom: 0.sp, right: isArabic ? 30.w : 0),
      child: GestureDetector(
        onTap: () {
          onTap();
          onSave();
        },
        child: Container(
          width: 110.sp,
          height: 28.sp,
          decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(4.r)),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons_assets/database_builder_assets/plus_head.svg", width: 12.sp, height: 12.sp,color: Colors.white,),
                SizedBox(width: 8.sp),
                Text(S.of(context).notifications,
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget addSlaButtonAlt({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.only(left: isArabic ? 0 : 30.w, bottom: 0.sp, right: isArabic ? 30.w : 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 110.sp,
          height: 28.sp,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons_assets/database_builder_assets/plus_head.svg",
                  width: 12.sp,
                  height: 12.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 8.sp),
                Text(
                  S.of(context).notifications,
                  style: StyleText.fontSize12Weight500.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void showSlaValidationError(BuildContext context, String sectionName) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 411.w,
            height: 200.h,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.all(15.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/lottie_assets/main_lottie_assets/lottie_attension.json",
                  width: 70.w,
                  height: 70.h,
                  fit: BoxFit.fill,
                  repeat: true,
                ),
                SizedBox(height: 10.h),
                Text(
                  S.of(context).warning,
                  style: StyleText.fontSize18Weight500.copyWith(
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      isArabic
            ? "لا يمكنك إلغاء تحديد '$sectionName' لأنك أدخلت بيانات نسبة اتفاقية مستوى الخدمة. يرجى مسح حقول اتفاقية مستوى الخدمة أولاً أو  إبقاء المربع محددًا."
            : "You cannot uncheck '$sectionName' because you have entered SLA percentage data. Please clear the SLA fields first or keep the checkbox checked.",
                      style: StyleText.fontSize14Weight500.copyWith(
                        height: 1.6,
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showValidationError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          content: SizedBox(
            height: 200.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                    'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                    width: 70.sp,
                    height: 70.sp,
                    repeat: true
                ),
                SizedBox(height: 10.sp),
                Text(
                  S.of(context).validationError ?? "Validation Error",
                  style: StyleText.fontSize18Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                SizedBox(height: 10.sp),
                Expanded(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 20.sp),
                customButton(
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.textButton
                  ),
                  title: S.of(context).ok,
                  function: () { Navigator.of(context).pop(); },
                  width: 135.sp,
                  height: 38.sp,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
