// Date: 5/9/2024
// By: Nada Mohammed
// Last update: 5/9/2024
// Objectives: This file is responsible for providing a common group tile used in the group chat profile screen.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../data/models/legacy_group_model.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';

class CommonGroupTile extends StatelessWidget {
  final GroupModel group;

  const CommonGroupTile({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        group.groupName,
        style: StyleText.fontSize12Weight400,
      ),
      subtitle: Text(
        group.groupMembers.map((e) => e.firstName).join(', '),
        overflow: TextOverflow.ellipsis,
        style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.mediumGrey,
        backgroundImage:
            group.groupImage != null ? appImageProvider(group.groupImage!) : null,
        child: group.groupImage == null
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
