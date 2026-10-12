/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: my_request_inventory.dart
/// Purpose: Declares `MyRequestInventory`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/widgets/standard_container.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MyRequestInventory extends StatelessWidget {
  MyRequestInventory({required this.model, super.key});
  HomeComponentModel model;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 130.sp,
        child: StandardContainer(
            child: Column(
          spacing: 8.sp,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).myRequest,
                  style: StyleText.fontSize14Weight500
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SvgPicture.asset(
                  'assets/icons_assets/roles_assets/inventory_warehouse.svg',
                  width: 20,
                  height: 20,
                  color: AppColors.primary,
                )
              ],
            ),
            Container(),
            Text(
              S.of(context).total + 100.toString(),
              style: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.secondaryText),
            ),
            Column(
              spacing: 10.sp,
              children: [
                item(
                    color: AppColors.green,
                    number: '10',
                    icon: 'assets/icons_assets/home_assets/approved_stamp_green.svg'),
                item(
                    color: AppColors.yellow,
                    number: '10',
                    icon: 'assets/icons_assets/home_assets/hourglass_pending.svg'),
                item(
                    color: AppColors.red,
                    number: '10',
                    icon: 'assets/icons_assets/home_assets/rejected_ribbon_stamp.svg'),
              ],
            )
          ],
        )));
  }

  Widget item(
      {required Color color, required String number, required String icon}) {
    return Row(
      spacing: 4.sp,
      children: [
        SvgPicture.asset(
          icon,
          width: 15,
          height: 15,
          color: color,
        ),
        Text(
          number,
          style: StyleText.fontSize12Weight400
              .copyWith(fontWeight: FontWeight.bold, color: color),
        )
      ],
    );
  }
}
