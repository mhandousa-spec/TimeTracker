// ****************** FILE INFO ******************
// File Name: crm_controls_template_card.dart
// Purpose: Template card used in CRM controls templates listing page.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_demo_data.dart';

class CrmControlsTemplateCard extends StatelessWidget {
  const CrmControlsTemplateCard({
    required this.template,
    required this.onTap,
    super.key,
  });

  final CrmTemplateSummaryData template;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (template.status.toLowerCase()) {
      case 'active':
        return AppColors.green;
      case 'inactive':
        return AppColors.orange;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 10.sp : 12.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Placeholder Image Container
            Container(
              width: isMobile ? 60.sp : 72.sp,
              height: isMobile ? 60.sp : 72.sp,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: CustomSvgImage(
                assetPath: AppAssets.crmTemplate,
                width: isMobile ? 32.sp : 48.sp,
                height: isMobile ? 32.sp : 48.sp,
                color: AppColors.text,
              ),
            ),
            SizedBox(width: isMobile ? 10.sp : 12.sp),

            // Right Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row 1: Title & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style:
                              StyleText.fontSize14Weight600.copyWith(
                            fontSize: isMobile ? 13.sp : 14.sp,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.sp,
                          vertical: 2.sp,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          template.status,
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.background).copyWith(
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isMobile ? 3.sp : 5.sp),

                  if (isMobile) ...[
                    // Mobile Row 2: Fields (Left) and By (Right) side-by-side
                    Row(
                      children: [
                        // Fields
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSvgImage(
                              assetPath: AppAssets.crmSections,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            SizedBox(width: 4.sp),
                            Text.rich(
                              TextSpan(
                                style: StyleText.fontSize12Weight500
                                    .copyWith(
                                  fontSize: 10.sp,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Fields: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text: '${template.fieldCount}',
                                    style: TextStyle(
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // By
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomSvgImage(
                              assetPath: AppAssets.crmPerson,
                              width: 12.sp,
                              height: 12.sp,
                              color: AppColors.darkGrey,
                            ),
                            SizedBox(width: 4.sp),
                            Text.rich(
                              TextSpan(
                                style: StyleText.fontSize12Weight500
                                    .copyWith(
                                  fontSize: 10.sp,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'By : ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  TextSpan(
                                    text: FormatHelper.formatEmailToName(
                                      template.author,
                                    ),
                                    style: TextStyle(
                                      color: AppColors.darkGrey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(width: 4.sp),
                      ],
                    ),
                    SizedBox(height: 2.sp),

                    // Mobile Row 3: Creation Date
                    Row(
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.calendar,
                          width: 12.sp,
                          height: 12.sp,
                          color: AppColors.darkGrey,
                        ),
                        SizedBox(width: 4.sp),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style:
                                  StyleText.fontSize12Weight500.copyWith(
                                fontSize: 10.sp,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Creation Date: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: template.createdAt,
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Desktop / Tablet Row 2: Fields
                    Row(
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.crmSections,
                          width: 14.sp,
                          height: 14.sp,
                          color: AppColors.darkGrey,
                        ),
                        SizedBox(width: 5.sp),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style:
                                  StyleText.fontSize12Weight500.copyWith(
                                fontSize: 12.sp,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Fields: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: '${template.fieldCount}',
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.sp),

                    // Desktop / Tablet Row 3: By
                    Row(
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.crmPerson,
                          width: 14.sp,
                          height: 14.sp,
                          color: AppColors.darkGrey,
                        ),
                        SizedBox(width: 5.sp),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style:
                                  StyleText.fontSize12Weight500.copyWith(
                                fontSize: 12.sp,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'By: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: FormatHelper.formatEmailToName(
                                    template.author,
                                  ),
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.sp),

                    // Desktop / Tablet Row 4: Creation Date
                    Row(
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.calendar,
                          width: 14.sp,
                          height: 14.sp,
                          color: AppColors.darkGrey,
                        ),
                        SizedBox(width: 5.sp),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style:
                                  StyleText.fontSize12Weight500.copyWith(
                                fontSize: 12.sp,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Creation Date: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: template.createdAt,
                                  style: TextStyle(
                                    color: AppColors.darkGrey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
