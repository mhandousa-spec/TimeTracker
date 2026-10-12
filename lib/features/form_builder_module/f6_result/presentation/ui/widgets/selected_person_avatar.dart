/// ************************** FILE INFO **************************
/// File Name: selected_person_avatar.dart
/// Purpose: small widget to show selected person avatar
/// Created By: Mohamed Elrashidy
/// Created On: 7/5/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';

class SelectedPersonAvatar extends StatelessWidget {
  SelectedPersonAvatar(
      {required this.personEntity, required this.onTap, super.key});
  PersonEntity personEntity;
  var onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(end: 8),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: personEntity.image.contains('http')
                ? NetworkImage(personEntity.image)
                : appImageProvider(personEntity.image),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                splashColor: AppColors.transparent,
                onTap: () {
                  onTap();
                },
                child: ClipOval(
                  child: SizedBox(
                      height: 14.sp,
                      width: 14.sp,
                      child: SvgPicture.asset(
                        AppAssets.close,
                        width: 12.sp,
                        height: 12.sp,
                      )),
                ),
              )),
        ],
      ),
    );
  }
}
