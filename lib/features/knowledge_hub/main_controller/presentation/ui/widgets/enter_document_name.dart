import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/44-custom_validated_textfield.dart';


Widget enterDocumentName({
  required String text,
  required TextEditingController controller,
  required Function(String?) validator,
  required GlobalKey<FormState> formKey,
  required String hintText,
  bool isArabic = false,
}) {
  return CustomValidatedTextFieldMaster(
    label: text,
    hint: hintText,
    controller: controller,
  );
  // return Form(
  //   key: formKey,
  //   // autovalidateMode: AutovalidateMode.onUserInteraction,
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
  //               ),
  //               validator: (value) {
  //                 return validator(value);
  //               },
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
  // return Form(
  //   key: formKey,
  //   autovalidateMode: AutovalidateMode.onUserInteraction,
  //   child: Column(
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
  //       SizedBox(
  //         height: 36,
  //         child: TextFormField(
  //           controller: controller,
  //           decoration: InputDecoration(
  //             hintText: 'Text here',
  //             hintStyle: TextStyles.font12GreyCairow400,
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(4),
  //               borderSide: BorderSide(color: Colors.transparent, width: 1),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(4),
  //               borderSide: BorderSide(color: Colors.transparent, width: 1),
  //             ),
  //             fillColor: AppColors.offWhite,
  //             filled: true,
  //             errorBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(4),
  //               borderSide: BorderSide(color: Colors.red, width: 1),
  //             ),
  //             focusedErrorBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(4),
  //               borderSide: BorderSide(color: Colors.red, width: 1),
  //             ),
  //           ),
  //           validator: (value) {
  //             return validator(value);
  //           },
  //         ),
  //       ),
  //       ValueListenableBuilder<TextEditingValue>(
  //         valueListenable: controller,
  //         builder: (context, value, child) {
  //           final error = validator(value.text);
  //           return error != null
  //               ? Padding(
  //                   padding: const EdgeInsets.only(top: 4),
  //                   child: Text(
  //                     error,
  //                     style: const TextStyle(
  //                       color: Colors.red,
  //                       fontSize: 12,
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
