/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_customexceltextfield.dart
/// Purpose: Declares `CustomExcelTextField`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/upload_file_details.dart';

class CustomExcelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final double width;
  final double height;
  final bool showHeader;
  final FocusNode? focusNode;
  final String headerLabel;
  final String placeholder;
  final Function(String value)? onChanged;
  final int? rowIndex;
  final Function(String key, int index)? validator;

  const CustomExcelTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.errorText,
    this.width = 200,
    this.height = 36,
    this.showHeader = false,
    this.headerLabel = '',
    this.onChanged,
    this.focusNode,
    this.rowIndex,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isEmail = placeholder.toLowerCase().contains('email');
    final isPhone = placeholder.toLowerCase().contains('phone');

    return Container(
      width: width, // Example: 250
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.only(bottom: 8,),
              child: Align(
                alignment: headerLabel.trim().contains(RegExp(r'[\u0600-\u06FF]'))
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  headerLabel,
                  style:  TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.totalBlack,
                  ),
                ),
              ),
            ),

          SizedBox(
            width: width,
            child: Directionality(
              textDirection: placeholder.trim().contains(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                children: [
                  // ❗ Always reserve icon space (clickable if errorText exists)
                  GestureDetector(
                    onTap: () {
                      if (errorText != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: EdgeInsets.symmetric(vertical: 24.sp, horizontal: 16.sp),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            content: Container(
                              width: 410.sp,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Lottie.asset('assets/lottie_assets/roles_lottie_assets/rejected.json', width: 70.sp, height: 70.sp),
                                  SizedBox(height: 16.sp),
                                  Text(
                                    'Warning $placeholder',
                                    style: StyleText.fontSize20Weight600.copyWith(
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16.sp),
                                  Text(
                                    'The specified $placeholder $errorText! .Please verify the entry',
                                    style: StyleText.fontSize14Weight400.copyWith(color: AppColors.darkGrey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: errorText != null
                        ? Container(
                      width: 20.sp,
                      height: height,
                      alignment: Alignment.center,
                      child: CustomSvgImage(assetPath: 
                        "assets/icons_assets/main_icons_assets/warning_exclamation_circle.svg",
                        width: 20.sp,
                        height: 20.sp,
                        fit: BoxFit.cover,
                      ),
                    )
                        : SizedBox(),
                  ),

                  errorText != null? SizedBox(width: 8.sp) : SizedBox(),

                  // 📦 TextField — core CustomTextField.
                  //
                  // The red outline stays on this wrapper rather than being
                  // driven by CustomTextField's own `errorText`: in this dense
                  // Excel grid the error is surfaced by the tappable icon +
                  // dialog above, and letting the field render its own inline
                  // error message would change every row's height.
                  Expanded(
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: errorText != null
                              ? AppColors.red
                              : AppColors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: CustomTextField(
                        controller: controller,
                        focusNode: focusNode,
                        hint: placeholder,
                        height: height,
                        onChanged: (value) {
                          if (validator != null && rowIndex != null) {
                            validator!(placeholder, rowIndex!);
                          }
                          if (onChanged != null) onChanged!(value);
                        },
                        inputFormatters: isEmail
                            ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
                            : null,
                        keyboardType:
                            isPhone ? TextInputType.phone : TextInputType.text,
                        fillColor: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        valueStyle: StyleText.fontSize14Weight500.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppColors.blackButton
                                    : AppColors.white),
                        hintStyle: TextStyle(
                            fontSize: 13, color: AppColors.darkGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
