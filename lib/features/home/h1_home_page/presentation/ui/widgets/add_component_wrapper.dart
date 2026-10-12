/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: add_component_wrapper.dart
/// Purpose: Declares `AddComponentWrapper`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';

import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/text_field.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/module_widget/edit_dialogs/open_edit_dialog.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
class AddComponentWrapper extends StatelessWidget {
  AddComponentWrapper(
      {required this.component, required this.model, super.key});
  Widget component;
  HomeComponentModel model;

  void _showSLADialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            width: 330.w,
            padding: EdgeInsets.all(24.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      width: 26.sp,
                      height: 26.sp,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle
                      ),
                      child: Center(
                        child: CustomSvgImage(assetPath: "assets/icons_assets/home_assets/sla_stopwatch.svg",width: 16.w,height: 14.h,fit: BoxFit.scaleDown,)
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'SLA',
                        style: StyleText.fontSize12Weight500.copyWith(
                            color: Theme.of(context).brightness==Brightness.light?AppColors.blackButton : AppColors.white
                        )
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Using CustomValidatedTextField
                CustomTextField(
                  label: 'SLA Percentage',
                  hint: S.of(context).textHere,
                  controller: textController,
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                ),

                SizedBox(height: 20.h),

                // Buttons
                Row(
                  children: [
                    customButton(
                      title: S.of(context).discard,
                      function: () {
                        Navigator.pop(dialogContext);
                      },
                      width: 135.w,
                      height: 38.h,
                      radius: 8,
                      color: Colors.grey.shade300,
                      textStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    customButton(
                      title: S.of(context).save,
                      function: () {
                        // Handle save action
                        String value = textController.text;
                        // Add your save logic here
                        // Example: context.read<HomeCubit>().updateSLAPercentage(model, value);
                        Navigator.pop(dialogContext);
                      },
                      width: 135.w,
                      height: 38.h,
                      radius: 8,
                      color: Colors.yellow.shade700,
                      textStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        splashColor: AppColors.transparent,
        hoverColor: AppColors.transparent,
        onTap: () {
          if (!model.component.isEditable) {
            context.read<AppHomeCubit>().editComponent(model);
            Navigator.pop(context);
          }
        },
        child: Stack(children: [
          Padding(
            // .w/.h rather than .sp so this padding scales on the same
            // axis as the card widths it sits between — together with
            // the Wrap's 3 it makes up Figma's 15 gutter.
            padding: EdgeInsetsDirectional.only(top: 12.h, end: 12.w),
            child: component,
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.transparent,
            ),
          ),
          if (model.component.isEditable)
            PositionedDirectional(
              top: 0,
              end: 0,
              child: InkWell(
                splashColor: AppColors.transparent,
                hoverColor: AppColors.transparent,
                onTap: () {
                  _showSLADialog(context);
                },
                child: Container(
                  width: 25.sp,
                  height: 25.sp,
                  padding: EdgeInsets.all(4.sp),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.greyIcon),
                  child: SvgPicture.asset(
                    'assets/icons_assets/roles_assets/settings_gear.svg',
                    color: AppColors.text,
                  ),
                ),
              ),
            )
        ]),
      ),
    );
  }
}