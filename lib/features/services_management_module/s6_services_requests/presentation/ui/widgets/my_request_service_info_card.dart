/// Module: services_management_module
/// Description: Service image + name/description card body for the "my
///              request" details page (mobile shows a compact description
///              row inline; tablet shows the fuller two-column layout via
///              the caller composing this with RequestProviderSection).
///              Extracted from MyRequestDetails (audit fix #1).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: cached_network_image, shimmer
/// Revision History: Initial version.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class MyRequestServiceInfoCard extends StatelessWidget {
  const MyRequestServiceInfoCard({
    super.key,
    required this.imageUrl,
    required this.isMobile,
    required this.isTablet,
    required this.isTabletLandscape,
    required this.serviceNameToDisplay,
    required this.serviceDescriptionToDisplay,
    required this.isLoadingServiceDetails,
  });

  final String imageUrl;
  final bool isMobile;
  final bool isTablet;
  final bool isTabletLandscape;
  final String serviceNameToDisplay;
  final String serviceDescriptionToDisplay;
  final bool isLoadingServiceDetails;

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return Row(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Container(
          width: isMobile ? 40.sp : (!isTabletLandscape ? 80.sp : 100.sp),
          height: isMobile ? 40.sp : (!isTabletLandscape ? 80.sp : 100.sp),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.background,
          ),
          child: imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 40.sp,
                    height: 40.sp,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.secondaryText.withOpacity(.3),
                      highlightColor: lightMode
                          ? AppColors.background
                          : AppColors.background.withOpacity(0.5),
                      child: Container(
                        width: 40.sp,
                        height: 40.sp,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryText.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => SvgPicture.asset(
                      'assets/icons_assets/services_assets/clock_dashed.svg',
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.secondaryText,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                )
              : Center(
                  child: SvgPicture.asset(
                    "assets/icons_assets/services_assets/headset_support.svg",
                    width: isMobile ? 24.sp : 50.sp,
                    height: isMobile ? 24.sp : 50.sp,
                    color: AppColors.secondaryText,
                    fit: BoxFit.contain,
                    semanticsLabel: 'Headphone Icon',
                  ),
                ),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isMobile
                  ? (isLoadingServiceDetails
                      ? Shimmer.fromColors(
                          baseColor: AppColors.secondaryText.withOpacity(.3),
                          highlightColor: AppColors.background.withOpacity(.5),
                          child: Container(
                            height: 14.sp,
                            width: 150.sp,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryText.withOpacity(.5),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        )
                      : Text(
                          FormatHelper.capitalize(serviceNameToDisplay),
                          style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
                        ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/icons_assets/services_assets/building_office.svg",
                                  width: 14.sp,
                                  height: 14.sp,
                                  color: AppColors.text,
                                  fit: BoxFit.fill,
                                  semanticsLabel: 'Dart Logo',
                                ),
                                SizedBox(width: 3.sp),
                                Text(
                                  S.of(context).serviceDescription,
                                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5.h),
                        isLoadingServiceDetails
                            ? Shimmer.fromColors(
                                baseColor: AppColors.secondaryText.withOpacity(.3),
                                highlightColor: AppColors.background.withOpacity(.5),
                                child: Container(
                                  height: 40.sp,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryText.withOpacity(.5),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              )
                            : Text(
                                FormatHelper.capitalize(serviceDescriptionToDisplay),
                                style: StyleText.fontSize13Weight400.copyWith(
                                  height: 1.5,
                                  color: AppColors.text,
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
    );
  }
}

/// Mobile-only compact description row shown below the header when
/// [isMobile] is true (kept separate to preserve exact original layout
/// ordering — full description block appears twice with different styling
/// per breakpoint).
class MyRequestDescriptionWidget extends StatelessWidget {
  const MyRequestDescriptionWidget({
    super.key,
    required this.serviceDescriptionToDisplay,
    required this.isLoadingServiceDetails,
  });

  final String serviceDescriptionToDisplay;
  final bool isLoadingServiceDetails;

  @override
  Widget build(BuildContext context) {
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
                width: 16.w,
                height: 16.h,
                color: AppColors.secondaryText.withOpacity(.5),
                fit: BoxFit.scaleDown,
                semanticsLabel: 'Dart Logo',
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              "${S.of(context).serviceDescription}:",
              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
        SizedBox(height: 5.sp),
        isLoadingServiceDetails
            ? Shimmer.fromColors(
                baseColor: AppColors.secondaryText.withOpacity(.3),
                highlightColor: AppColors.background.withOpacity(.5),
                child: Container(
                  height: 40.sp,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryText.withOpacity(.5),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              )
            : Text(
                FormatHelper.capitalize(serviceDescriptionToDisplay),
                style: isMobile
                    ? StyleText.fontSize10Weight400.copyWith(
                        wordSpacing: -1.sp,
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      )
                    : StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                        color: lightMode ? AppColors.blackButton : AppColors.white,
                      ),
                textAlign: TextAlign.start,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
      ],
    );
  }
}
