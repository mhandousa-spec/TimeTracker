// ******************* FILE INFO *******************
// File Name: w3_info_screen
// Description: W3 info screen.
// Module: services_management_module / presentation/s10_services_provider/ui/widgets
// *************************************************

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';






class InfoScreenWidget extends StatelessWidget {
  const InfoScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomRowDetails(
              data: "Ahmed Wael",
              image: "assets/icons_assets/main_icons_assets/person_outline.svg",
              title: "Service Provider:",
              imagePerson: "assets/icons_assets/main_icons_assets/person_outline.png",
            ),
            SizedBox(height: 5.h),
            CustomRowDetails(
              data: "ahmedmohammed548@gmail.com",
              image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
              title: "Email:",
            ),
            SizedBox(height: 5.h),
            CustomRowDetails(
              data: "4 Week",
              image: "assets/icons_assets/services_assets/clock_dashed.svg",
              title: "Duration of Service:",
            ),
          ],
        ),

        SizedBox(width: MediaQuery.sizeOf(context).width * .05),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomRowDetails(
              data: "IT Systems Administrator",
              image: "assets/icons_assets/main_icons_assets/Case.svg",
              title: "Job Title::",
            ),
            SizedBox(height: 5.h),
            CustomRowDetails(
              data: "+201094597362",
              image: "assets/icons_assets/services_assets/phone_handset.svg",
              title: "Phone Number:",
            ),
            SizedBox(height: 5.h),
            CustomRowDetails(
              data: "Needs P12_Approval_tablet",
              image: "assets/icons_assets/main_icons_assets/doc_file_blue.svg",
              title: "Approval:",
            ),
          ],
        ),
      ],
    );
  }
}
class CustomRowDetails extends StatelessWidget {
  const CustomRowDetails({
    super.key,
    required this.image,
    required this.title,
    required this.data,
    this.imagePerson, // ✅ optional
  });

  final String image;
  final String title;
  final String data;
  final String? imagePerson; // ✅ nullable

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          image, // uses passed SVG icon
          semanticsLabel: 'Icon',
          width: 20.w,
          height: 20.h,
        ),
        SizedBox(width: 8.w),
        Text(title, style: StyleText.fontSize14Weight400),
        SizedBox(width: 8.w),

        // ✅ Only show person image if it's provided
        if (imagePerson != null)
          Row(
            children: [
              appImageWidget(imagePerson!, width: 32.w, height: 32.h),
              SizedBox(width: 5.w),
            ],
          ),

        // Data Text
        Text(data, style: StyleText.fontSize14Weight400),
      ],
    );
  }
}
