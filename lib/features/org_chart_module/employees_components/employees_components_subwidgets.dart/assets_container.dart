// Date Created :21/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :21/November/2023
// Objectives: this is a widget to customize the container of the assets in employee attendance screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_components_subwidgets.dart/employee_content.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class AssetsContainer extends StatelessWidget {
  const AssetsContainer({super.key, this.isEmployeeProfile = false});

  final bool? isEmployeeProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isEmployeeProfile == true ? 0.03.h : 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceVariant),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0.03.h, horizontal: 0.015.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "${S.of(context).asset} ${S.of(context).name}".capitalize as String,
                  
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize014.w,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                ),
                EmployeeContent(
                  title: "Date",
                  value: "23 ${S.of(context).feb} 2023",
                  isAssets: true,
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.02.h),
              child: EmployeeContent(
                title: "${S.of(context).asset} ${S.of(context).iD}",
                value: "324595858588",
                isAssets: true,
              ),
            ),
            EmployeeContent(
                title: "Asset Description",
                isAssets: true,
                isEmployeeProfile: isEmployeeProfile!,
                value:
                    "Loarem Ipsum Loarem Ipsum Loarem Ipsum Loarem Ipsum Loarem Ipsum Loarem Ipsum Loarem ")
          ]),
        ),
      ),
    );
  }
}
