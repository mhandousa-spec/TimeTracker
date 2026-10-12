// Date Created :21/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :21/November/2023
// Objectives: this is a widget to customize the title and the value in the employee content container
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

class EmployeeContent extends StatelessWidget {
  const EmployeeContent(
      {super.key,
      required this.title,
      required this.value,
      this.isAssets = false,
      this.textColor,
      this.isEmployeeProfile = false});
  final String title;
  final String? value;
  final bool isAssets;
  final bool isEmployeeProfile;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Row(
      children: <Widget>[
        Text(
          "${title}: ",
          style: AppFontStyle.cairoRegularStyle.copyWith(
            fontSize: isAssets == true
                ? isTablet
                    ? isPortrait
                        ? FontConstants.fontSize018.h
                        : FontConstants.fontSize017.w
                    : FontConstants.fontSize012.h
                : isPortrait
                    ? FontConstants.fontSize018.h
                    : FontConstants.fontSize013.w,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.scrim,
          ),
        ),
        if (isEmployeeProfile == false)
          Flexible(
            child: Text(
              value?.capitalize ?? '',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: isAssets == true
                    ? isTablet
                        ? isPortrait
                            ? FontConstants.fontSize018.h
                            : FontConstants.fontSize017.w
                        : FontConstants.fontSize014.h
                    : isPortrait
                        ? FontConstants.fontSize018.h
                        : FontConstants.fontSize013.w,
                fontWeight: isAssets ? FontWeight.w600 : FontWeight.w500,
                color:textColor?? Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          ),
        if (isEmployeeProfile == true)
          Flexible(
            child: Text(
              value!,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: isAssets == true
                    ? FontConstants.fontSize014.w
                    : FontConstants.fontSize013.w,
                fontWeight: isAssets ? FontWeight.w600 : FontWeight.w500,
                color: Theme.of(context).colorScheme.inverseSurface,
              ),
            ),
          ),
      ],
    );
  }
}
