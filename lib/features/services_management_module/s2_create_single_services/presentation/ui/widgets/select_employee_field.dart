// ******************* FILE INFO *******************
// File Name: select_employee_field
// Description: Select employee field.
// Module: services_management_module / presentation/s2_create_single_services/ui/widgets
// *************************************************

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for clipboard functionality
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';



bool _isArabic(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar';

String _capIfEn(BuildContext context, String s) =>
    _isArabic(context) ? s : FormatHelper.capitalize(s);

Widget buildFormSection({
  required BuildContext context,
  required String title,
  required String name,
  required String job,
  required String email,
  required String phone,
  required String avatar,
  required String gender,
}) {
  final isAr = _isArabic(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _capIfEn(context, title),
        style: StyleText.fontSize16Weight600.copyWith(
          color: AppColors.text,
        ),
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      ),
      SizedBox(height: 8.sp),

      buildResponsiveFields(
        context: context,
        left: _buildInputField(
          context,
          S.of(context).name,
          name,
          icon: avatar,
          gender: gender,
        ),
        right: _buildInputField(context, S.of(context).jobTitle, job),
      ),

      SizedBox(height: 15.sp),
      buildResponsiveFields(
        context: context,
        left: _buildCopyableField(context, S.of(context).email, email),
        right: _buildCopyableField(context, S.of(context).phone, phone),
      ),
    ],
  );
}

Widget _buildInputField(
    BuildContext context,
    String label,
    String value, {
      String? icon,
      String? gender,
    }) {
  final isAr = _isArabic(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _capIfEn(context, label),
        style: StyleText.fontSize14Weight400.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400,color: AppColors.text,),
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      ),
      SizedBox(height: 6.sp),
      CustomTextField(
        // ✅ FIX (bug report p13/p15): CustomTextField builds its controller in
        // initState from `initialValue` and has no didUpdateWidget, so once the
        // field exists the text never changes again. On rebuild Flutter reuses
        // the same State (same widget type, same position), so selecting a
        // different provider left Name and Job Title showing the *first*
        // provider's values while Email and Phone — plain Text widgets — updated
        // correctly. That is the "data switched" mismatch.
        //
        // Keying on the value forces a fresh State whenever the value changes.
        key: ValueKey('$label|$value'),
        readOnly: true,
        initialValue: _capIfEn(context, value),
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isAr ? TextAlign.right : TextAlign.left,
        fillColor: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
        contentPadding: EdgeInsets.symmetric(horizontal: 9.sp, vertical: 9.sp),
        valueStyle: StyleText.fontSize12Weight400.copyWith(
          color: AppColors.secondaryText,
        ),
        prefixIcon: gender != null
            ? Padding(
                padding: EdgeInsets.only(left: 6.sp, right: 4.sp),
                child: CircleAvatar(
                  radius: 13.r,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: SvgPicture.asset(
                      gender == "male"
                          ? 'assets/icons_assets/main_icons_assets/male_avatar.svg'
                          : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
                      semanticsLabel: 'Gender Icon',
                      fit: BoxFit.cover,
                      width: 24.sp,
                      height: 24.sp,
                    ),
                  ),
                ),
              )
            : null,
      ),
    ],
  );
}

Widget _buildCopyableField(BuildContext context, String label, String value) {
  final isAr = _isArabic(context);
  final isEmail = label.toLowerCase().contains('email') || label.toLowerCase().contains('بريد');
  final isPhone = label.toLowerCase().contains('phone') || label.toLowerCase().contains('هاتف');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _capIfEn(context, label),
        style: StyleText.fontSize14Weight400.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400,color: AppColors.text),
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      ),
      SizedBox(height: 6.sp),
      GestureDetector(
        onTap: () async {
          if (value.isNotEmpty) {
            await Clipboard.setData(ClipboardData(text: value));

            String message;
            if (isEmail) {
              message = isAr ? 'تم نسخ البريد الإلكتروني' : 'Copied Email';
            } else if (isPhone) {
              message = isAr ? 'تم نسخ رقم الهاتف' : 'Copied Phone';
            } else {
              message = isAr ? 'تم النسخ' : 'Copied';
            }

            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext dialogContext) {


                return AlertDialog(
                  backgroundColor: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  content: SizedBox(
                    width: 411.sp,
                    height: 130.sp,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                          width: 70.sp,
                          height: 70.sp,
                        ),
                        SizedBox(height: 25.sp),
                        Text(
                          S.of(context).copyDone,
                          textAlign: TextAlign.center,
                          style: StyleText.fontSize20Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

          }
        },
        child: Container(
          height: 36.sp,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
              color: Colors.transparent,
            ),
          ),
          child: Row(
            children: [


              // Value text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 9.sp, vertical: 8.sp),
                  child: Text(
                    value.isNotEmpty ? value : (isAr ? 'غير متوفر' : 'Not available'),
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: isAr ? TextAlign.right : TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    ],
  );
}
