/// Module: messaging / groups / presentation/ui/widgets/person_state_view.dart
/// Purpose: Selectable member row used when picking people for a group.
///
/// Distinct from home/h1_home_page's PersonStateView, which takes an
/// EmployeeEntityPro. This one takes a MemberEntity, so it lives in the
/// messaging feature.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import '../../../domain/entities/member_entity.dart';

class PersonStateView extends StatelessWidget {
  const PersonStateView({
    required this.person,
    required this.onTap,
    this.isEdit = false,
    super.key,
    this.color,
  });

  final MemberEntity person;
  final VoidCallback? onTap;
  final Color? color;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.field,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsetsDirectional.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: CustomSvgImage(
                  assetPath:
                      "assets/icons_assets/main_icons_assets/assets_male.svg",
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.fill,
                ),
              ),
              horizontalSpace(10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    Expanded(
                      child: Text(
                        person.fullName,
                        style: StyleText.fontSize14Weight500
                            .copyWith(height: 1),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        person.departmentName,
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        person.subInfo,
                        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: CustomCheckBox(
                    isSelected: person.isSelected,
                    borderColor: AppColors.secondaryText.withOpacity(.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
