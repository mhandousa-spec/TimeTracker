// ******************* FILE INFO *******************
// File Name: w4_limited_services_section
// Description: W4 limited services section.
// Module: services_management_module / presentation/s10_services_provider/ui/widgets
// *************************************************

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';







class LimitedServiceAvailabilityWidget extends StatelessWidget {
   LimitedServiceAvailabilityWidget({super.key});
  final List<String> special = ["Marketing", "HR", "Finance"];
  @override
  Widget build(BuildContext context) {
    return   Row(
      children: [
        SvgPicture.asset(
          "assets/icons_assets/services_assets/building_office.svg",
          semanticsLabel: 'Dart Logo',
        ),
        SizedBox(width: 2.w),
        Text(
          "Limited Service Availability:",
          style: StyleText.fontSize14Weight400,
        ),
        SizedBox(width: 11.w),

        SizedBox(
          height: 30.h,
          width: 300.w,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  // Add some spacing
                  height: 28.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:AppColors.grey
                  ),
                  child: Center(
                    child: Text(
                      special[index],
                      style: StyleText.fontSize12Weight400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
