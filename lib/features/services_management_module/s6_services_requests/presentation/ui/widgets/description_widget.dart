// ******************* FILE INFO *******************
// File Name: description_widget
// Description: Description widget.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';


Widget descriptionWidget (BuildContext context , String descriptionAr, String descriptionEn)
{
  var lightMode = Theme.of(context).brightness == Brightness.light;
  var isMobile = ContextExtension(context).isPhone;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          SizedBox(
            child: SvgPicture.asset(
              // Services mobile QA p.32: the three-lines glyph read as a menu /
              // sort icon. Same document-description icon Knowledge Hub uses;
              // QA p.27: the label now ends with ":" like every other row.
              "assets/icons_assets/knowledge_hub_assets/document_description_icon.svg",
              width: 16.sp,
              height: 16.sp,
              color:
              AppColors.secondaryText.withOpacity(.4),
              fit: BoxFit.scaleDown,
              semanticsLabel: 'Dart Logo',
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            "${S.of(context).serviceDescription}:",
            style: isMobile ? StyleText.fontSize12Weight400.copyWith(
              color:
              lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ) :   StyleText.fontSize12Weight400.copyWith(
              color:
              lightMode
                  ? AppColors.secondaryText
                  : AppColors.grey,
            ),

          ),
        ],
      ),
      SizedBox(height: 5.sp),
      Text(
        FormatHelper.capitalize(
          Localizations.localeOf(context).languageCode ==
              'ar'
              ? descriptionAr??
              ''
              : descriptionEn ??
              '',
        ),
        style: isMobile ?  StyleText.fontSize12Weight400.copyWith(

          wordSpacing: -1.sp,
          color:
          lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ) :  StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
          color:
          lightMode
              ? AppColors.blackButton
              : AppColors.white,
        ),
        textAlign: TextAlign.start,
        softWrap: true,

        overflow: TextOverflow.visible,
      ),
    ],
  );
}
