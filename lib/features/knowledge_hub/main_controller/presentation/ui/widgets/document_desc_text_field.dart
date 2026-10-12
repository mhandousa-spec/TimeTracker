import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

Widget documentDescTextField({
  required String text,
  required AlignmentDirectional alignment,
  required TextEditingController controller,
  required Function(String?) validator,
  required GlobalKey<FormState> formKey,
  required String hintText,
  bool isArabic = false,
  int maxLength = 500,
  int currentLength = 0,
}) {
  String getCounterText(bool isArabic, int current, int max) {
    if (isArabic) {
      // Convert numbers to Arabic numerals and use Arabic format
      final arabicNumerals = {
        '0': '٠',
        '1': '١',
        '2': '٢',
        '3': '٣',
        '4': '٤',
        '5': '٥',
        '6': '٦',
        '7': '٧',
        '8': '٨',
        '9': '٩',
      };

      String currentArabic = current
          .toString()
          .split('')
          .map((digit) => arabicNumerals[digit] ?? digit)
          .join();
      String maxArabic = max
          .toString()
          .split('')
          .map((digit) => arabicNumerals[digit] ?? digit)
          .join();

      return '$maxArabic/$currentArabic';
    }
    return '$currentLength/$maxLength';
  }

  return Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: alignment,
          child: Text(text, style: StyleText.fontSize14Weight400),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          maxLines: 5, // Make the field taller
          maxLength: maxLength,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.grey,
            ),
            hintTextDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.transparent, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.transparent, width: 1),
            ),
            fillColor: AppColors.background,
            filled: true,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            errorStyle: TextStyle(height: 0, fontSize: 0),
            counterText: '', // Hide default counter
          ),
          validator: (value) {
            return validator(value);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Align(
            alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              getCounterText(isArabic, currentLength, maxLength),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            final error = validator(value.text);
            return error != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    ),
  );
  // return Form(
  //   key: formKey,
  //   child: Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Align(
  //         alignment: alignment,
  //         child: Text(
  //           text,
  //           style: TextStyles.font14BlackCairoSemiBold.copyWith(
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ),
  //       verticalSpace(8),
  //       Stack(
  //         children: [
  //           SizedBox(
  //             height: 36,
  //             child: TextFormField(
  //               controller: controller,
  //               autovalidateMode: AutovalidateMode.onUserInteraction,
  //               textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
  //               textAlign: isArabic ? TextAlign.right : TextAlign.left,
  //               maxLines: null,
  //               maxLength: maxLength,
  //               keyboardType: TextInputType.multiline,
  //               decoration: InputDecoration(
  //                 hintText: hintText,
  //                 hintStyle: TextStyles.font12GreyCairow400,
  //                 hintTextDirection: isArabic
  //                     ? TextDirection.rtl
  //                     : TextDirection.ltr,
  //                 enabledBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(4),
  //                   borderSide: BorderSide(color: Colors.transparent, width: 1),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(4),
  //                   borderSide: BorderSide(color: Colors.transparent, width: 1),
  //                 ),
  //                 fillColor: AppColors.offWhite,
  //                 filled: true,
  //                 errorBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(4),
  //                   borderSide: BorderSide(color: Colors.red, width: 1),
  //                 ),
  //                 focusedErrorBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(4),
  //                   borderSide: BorderSide(color: Colors.red, width: 1),
  //                 ),
  //                 errorStyle: TextStyle(
  //                   height: 0,
  //                   fontSize: 0,
  //                 ), // Hide the error completely
  //                 counterText: '',
  //               ),
  //               validator: (value) {
  //                 return validator(value);
  //               },
  //             ),
  //           ),
  //           Align(
  //             alignment: Alignment.bottomRight,
  //             child: Text(
  //               '$currentLength/$maxLength',
  //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
  //             ),
  //           ),
  //         ],
  //       ),
  //       ValueListenableBuilder<TextEditingValue>(
  //         valueListenable: controller,
  //         builder: (context, value, child) {
  //           if (value.text.isEmpty) return const SizedBox.shrink();
  //           final error = validator(value.text);
  //           return error != null
  //               ? Padding(
  //                   padding: const EdgeInsets.only(top: 4),
  //                   child: Align(
  //                     alignment: isArabic
  //                         ? Alignment.centerRight
  //                         : Alignment.centerLeft,
  //                     child: Text(
  //                       error,
  //                       style: const TextStyle(color: Colors.red, fontSize: 12),
  //                       textDirection: isArabic
  //                           ? TextDirection.rtl
  //                           : TextDirection.ltr,
  //                     ),
  //                   ),
  //                 )
  //               : const SizedBox.shrink();
  //         },
  //       ),
  //     ],
  //   ),
  // );
}
