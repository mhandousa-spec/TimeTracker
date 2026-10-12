/// Module: messaging / chat / presentation/ui/widgets/dialogs/chat_dialog_widgets.dart
/// Purpose: Building blocks shared by the chat dialogs from Figma section
///          6290:740 — Schedule Message, Mute Notifications, Disappearing
///          Messages, Contact and Poll.
/// Created At: 30/9/2026
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

bool chatDialogIsAr(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

void chatDialogToast(String msg) => Fluttertoast.showToast(
      msg: msg,
      backgroundColor: AppColors.primary,
      textColor: AppColors.textButton,
    );

/// Opens [child] in the app's dialog shell with the Figma radius.
Future<T?> showChatDialog<T>({
  required BuildContext context,
  required Widget child,
  required double width,
  double radius = 8,
}) {
  return CustomDialogManager.showContent<T>(
    context: context,
    width: width,
    padding: EdgeInsets.zero,
    borderRadius: BorderRadius.circular(radius.r),
    child: child,
  );
}

/// Centered 20 Medium title ("Schedule Message", "Mute Notifications", …).
class ChatDialogTitle extends StatelessWidget {
  const ChatDialogTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: StyleText.fontSize20Weight500.copyWith(color: AppColors.text),
      );
}

/// Centered 12 Regular grey subtitle.
class ChatDialogSubtitle extends StatelessWidget {
  const ChatDialogSubtitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        textAlign: TextAlign.center,
        style: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryBlack),
      );
}

/// Header with a 30px yellow badge + icon and a 16 Medium title
/// (Contact / Poll dialogs).
class ChatDialogBadgeHeader extends StatelessWidget {
  const ChatDialogBadgeHeader({
    super.key,
    required this.icon,
    required this.title,
  });
  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: CustomSvgImage(
            assetPath: icon,
            fit: BoxFit.contain,
            color: AppColors.textButton,
          ),
        ),
        SizedBox(width: 8.w),
        Text(title,
            style:
                StyleText.fontSize16Weight500.copyWith(color: AppColors.text)),
      ],
    );
  }
}

/// Figma radio option: 16px ring, 5px gap, 14 Medium label — dark when
/// selected, grey otherwise.
class ChatRadioOption<T> extends StatelessWidget {
  const ChatRadioOption({
    super.key,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  final T value;
  final T groupValue;
  final String label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              width: 16.r,
              height: 16.r,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.secondaryPrimary
                      : AppColors.secondaryBlack,
                  width: 1.5.r,
                ),
              ),
              child: selected
                  ? Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondaryPrimary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: StyleText.fontSize14Weight500.copyWith(
                color: selected ? AppColors.text : AppColors.secondaryBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cancel (grey) + primary (yellow) buttons, 135x38, radius 8.
class ChatDialogButtons extends StatelessWidget {
  const ChatDialogButtons({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.onCancel,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: _button(
            label: isAr ? 'إلغاء' : 'Cancel',
            color: AppColors.disabledButton.withValues(alpha: 0.8),
            textColor: AppColors.black,
            onTap: onCancel ?? () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: _button(
            label: primaryLabel,
            color: AppColors.primary,
            textColor: AppColors.textButton,
            onTap: onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _button({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 135.w,
        height: 38.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(label,
            style: StyleText.fontSize14Weight500.copyWith(color: textColor)),
      ),
    );
  }
}

/// Small label above a field (14 Medium).
class ChatFieldLabel extends StatelessWidget {
  const ChatFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Text(text,
            style:
                StyleText.fontSize14Weight500.copyWith(color: AppColors.text)),
      );
}

/// Grey #f5f5f5 text field of the Figma dialogs.
class ChatTextField extends StatelessWidget {
  const ChatTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.radius = 4,
    this.height,
    this.prefix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final double radius;
  final double? height;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final Widget field = TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      onChanged: onChanged,
      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.field,
        hintText: hint,
        hintStyle: StyleText.fontSize12Weight400
            .copyWith(color: AppColors.secondaryBlack),
        prefixIcon: prefix,
        prefixIconConstraints: BoxConstraints(minWidth: 32.w),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
    return height == null ? field : SizedBox(height: height, child: field);
  }
}

/// "Choose Date" field with the calendar icon.
class ChatDateField extends StatelessWidget {
  const ChatDateField({super.key, required this.value, required this.onPicked});
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    return _PickerBox(
      text: value == null
          ? (isAr ? 'اختر التاريخ' : 'Choose Date')
          : DateFormat('dd MMM yyyy').format(value!),
      hasValue: value != null,
      icon: 'assets/icons_assets/roles_assets/calendar.svg',
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime? d = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year, now.month, now.day),
          lastDate: DateTime(now.year + 5),
        );
        if (d != null) onPicked(d);
      },
    );
  }
}

/// "Choose time" field with the clock icon.
class ChatTimeField extends StatelessWidget {
  const ChatTimeField({super.key, required this.value, required this.onPicked});
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onPicked;

  @override
  Widget build(BuildContext context) {
    final bool isAr = chatDialogIsAr(context);
    return _PickerBox(
      text: value == null
          ? (isAr ? 'اختر الوقت' : 'Choose time')
          : value!.format(context),
      hasValue: value != null,
      icon: 'assets/icons_assets/main_icons_assets/clock_circle.svg',
      onTap: () async {
        final TimeOfDay? t = await showTimePicker(
          context: context,
          initialTime: value ?? TimeOfDay.now(),
        );
        if (t != null) onPicked(t);
      },
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.text,
    required this.hasValue,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final bool hasValue;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize12Weight400.copyWith(
                  color: hasValue ? AppColors.text : AppColors.secondaryBlack,
                ),
              ),
            ),
            CustomSvgImage(
              assetPath: icon,
              width: 16.r,
              height: 16.r,
              fit: BoxFit.contain,
              color: AppColors.secondaryBlack,
            ),
          ],
        ),
      ),
    );
  }
}

/// Joins a picked date and time; null when either is missing.
DateTime? combineDateTime(DateTime? date, TimeOfDay? time) {
  if (date == null || time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
