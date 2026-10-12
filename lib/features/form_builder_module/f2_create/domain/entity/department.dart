import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class DepartmentEntity {
  final String name, nameAr, id;

  DepartmentEntity({
    required this.name,
    required this.nameAr,
    required this.id,
  });
}

extension DropdownMenuItemListExtension on List<DepartmentEntity> {
  List<DropdownMenuItem<String>> toDropdownMenuItemList() {
    return map((department) {
      return DropdownMenuItem<String>(
        value: department.id,
        child: Text(
          Get.locale.toString().contains('en')
              ? department.name
              : department.nameAr,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
        ),
      );
    }).toList();
  }
}
