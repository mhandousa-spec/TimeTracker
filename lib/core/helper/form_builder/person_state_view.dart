import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';

import '../main_helper/format_title.dart';

class FormPersonStateView extends StatelessWidget {
  FormPersonStateView(
      {required this.person,
      required this.onTap,
      this.isEdit = false,
      super.key,
      this.color});
  PersonEntity person;
  var onTap;
  Color? color;
  bool isEdit;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsetsDirectional.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20.sp,
                backgroundColor: AppColors.primary,
                backgroundImage: appImageProvider("assets/icons_assets/main_icons_assets/male_avatar.svg")
              ),
              horizontalSpace(10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        FormatHelper.capitalize(person.name),
                        style: StyleText.fontSize14Weight500,
                      ),
                    ),
                    Expanded(
                        child: Text(
                      FormatHelper.capitalize(person.departmentName),
                      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                    )),
                    Expanded(
                        child: Text(
                      FormatHelper.capitalize(person.title),
                      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                    )),
                  ],
                ),
              ),
              if (onTap != null)
                Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: (isEdit)
                        ? SvgPicture.asset(AppAssets.minusCircle)
                        : CustomCheckBox(isSelected: person.isSelected))
            ],
          ),
        ),
      ),
    );
  }
}
