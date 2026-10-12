// Date: 6/8/2024
// By: Nada Mohammed
// Last update: 28/8/2024
// Objectives: This file is responsible for providing a widget that represents a chat avatar in the direct messaging view.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';

class AvatarChat extends StatelessWidget {
  final String? imageUrl;
  const AvatarChat({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 20.h),
      child: CircleAvatar(
        radius: 20.r,
        backgroundColor: AppColors.mediumGrey,
        backgroundImage: imageUrl != null
            ? (imageUrl!.contains("http"))
                ? NetworkImage(imageUrl!)
                : appImageProvider(imageUrl!)
            : null,
        child: imageUrl == null
            ? Icon(
                Icons.person,
                color: AppColors.moreLightGrey,
                size: 18.r,
              )
            : null,
      ),
    );
  }
}
