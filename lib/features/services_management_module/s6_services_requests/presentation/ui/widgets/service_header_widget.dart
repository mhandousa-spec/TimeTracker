// ******************* FILE INFO *******************
// File Name: service_header_widget
// Description: Service header widget.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/description_widget.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class ServiceHeaderWidget extends StatelessWidget {
  const ServiceHeaderWidget({required this.requestModel, super.key});
  final ServicesHistoryModel requestModel;

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    return Column(
      children: [
        Row(
          crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            // image
            Column(
              children: [
                Container(
                  width: isMobile
                      ? 40.sp
                      : !isTabletLandscape(context)
                      ? 80.sp
                      : 100.sp,
                  height: isMobile
                      ? 40.sp
                      : !isTabletLandscape(context)
                      ? 80.sp
                      : 100.sp,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: lightMode ? AppColors.background : AppColors.background,
                  ),
                  child: (requestModel.currentImageUrl.isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: requestModel.currentImageUrl,
                      width: 40.sp,
                      height: 40.sp,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: lightMode
                            ? AppColors.secondaryText.withOpacity(0.3)
                            : AppColors.grey.withOpacity(0.3),
                        highlightColor: lightMode
                            ? AppColors.background
                            : AppColors.background.withOpacity(0.5),
                        child: Container(
                          width: 40.sp,
                          height: 40.sp,
                          decoration: BoxDecoration(
                            color: lightMode
                                ? AppColors.secondaryText.withOpacity(0.1)
                                : AppColors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return SvgPicture.asset(
                          'assets/icons_assets/services_assets/clock_dashed.svg',
                          width: 38.w,
                          height: 38.h,
                          color: lightMode ? AppColors.secondaryText : AppColors.grey,
                          fit: BoxFit.fill,
                        );
                      },
                    ),
                  )
                      : Center(  // Add Center widget
                    child: SvgPicture.asset(
                      "assets/icons_assets/services_assets/headset_support.svg",
                      width: isMobile ? 24.sp : 50.sp,  // Bigger size
                      height: isMobile ? 24.sp : 50.sp,
                      color: AppColors.secondaryText,
                      fit: BoxFit.contain,  // Use contain
                      semanticsLabel: 'Headphone Icon',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            // details text
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isMobile
                      ? Text(
                    isArabic
                        ? requestModel.currentServiceNameArabic
                        : requestModel.currentServiceNameEnglish,
                    style: StyleText.fontSize14Weight400.copyWith(
                        color: lightMode ? AppColors.blackButton : AppColors.white),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                // Services mobile QA p.32: the three-lines glyph read as a menu /
              // sort icon. Same document-description icon Knowledge Hub uses;
              // QA p.27: the label now ends with ":" like every other row.
              "assets/icons_assets/knowledge_hub_assets/document_description_icon.svg",
                                width: 14.sp,
                                height: 14.sp,
                                color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                fit: BoxFit.fill,
                                semanticsLabel: 'Dart Logo',
                              ),
                              SizedBox(width: 3.sp),
                              Text(
                                "${S.of(context).serviceDescription}:",
                                style: StyleText.fontSize14Weight400.copyWith(
                                  color: lightMode ? AppColors.secondaryText : AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        FormatHelper.capitalize(
                          isArabic
                              ? requestModel.currentServiceDescriptionArabic
                              : requestModel.currentServiceDescriptionEnglish,
                        ),
                        style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                          height: 1.5,
                          color: lightMode ? AppColors.blackButton : AppColors.white,
                        ),
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isMobile) SizedBox(height: 18.sp),
        if (isMobile)
          descriptionWidget(
            context,
            requestModel.currentServiceDescriptionArabic,
            requestModel.currentServiceDescriptionEnglish,
          ),
        if (isMobile) SizedBox(height: 20.sp),
      ],
    );
  }
}
