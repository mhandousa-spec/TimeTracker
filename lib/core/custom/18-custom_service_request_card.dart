/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: service_request_card.dart
/// Purpose: Declares `ServiceRequestCard`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Figma node 6550:9751 — service request card (321x201) with action button.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

/// Card: icon box + title + icon info rows + full-width primary button.
///
/// ```dart
/// ServiceRequestCard(
///   title: 'Market Research Service',
///   icon: Icon(Icons.headset_mic_outlined),
///   infoRows: const [
///     CardInfo(label: 'Service Provider:', value: 'Ahmed Mohammed',
///         icon: Icon(Icons.person_add_alt)),
///     CardInfo(label: 'Job Title:', value: 'Marketing Manager',
///         icon: Icon(Icons.work_outline)),
///     CardInfo(label: 'Duration of Service:', value: '1 Week',
///         icon: Icon(Icons.timelapse)),
///     CardInfo(label: 'Approval:', value: 'Needs Approval',
///         icon: Icon(Icons.note_add_outlined)),
///   ],
///   buttonText: 'Request',
///   onPressed: () {},
/// )
/// ```
class ServiceRequestCard extends StatelessWidget {
  final String title;
  final Widget? icon;
  final List<CardInfo> infoRows;
  final String buttonText;
  final VoidCallback? onPressed;
  final Color? buttonColor;
  final double? width;

  const ServiceRequestCard({
    super.key,
    required this.title,
    this.icon,
    this.infoRows = const [],
    this.buttonText = 'Request',
    this.onPressed,
    this.buttonColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 321.w,
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: CardStyles.radius(),
        boxShadow: CardStyles.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: icon box + title.
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  // Figma: #D9D9D9, radius 4 (node 6550:9774).
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: FittedBox(
                      child: icon ?? CardSvg.icon(CardSvg.services),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: CardStyles.title(16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          for (final info in infoRows)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: CardInfoRow(info: info, fontSize: 14),
            ),
          SizedBox(height: 4.h),
          // Primary action button — Figma node 6550:9771 "new student button":
          // full width, height 30, radius 8, bg #FFDE59, Cairo Medium 16.
          // Built inline (not customButton) because this card requires the
          // exact Figma layout, not the app-wide ButtonSizing rule.
          GestureDetector(
            onTap: () {
              HapticController.medium(); // primary action button
              (onPressed ?? () {})();
            },
            child: Container(
              width: double.infinity,
              height: 30.h,
              decoration: BoxDecoration(
                color: buttonColor ?? AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: CardStyles.title(16)
                      .copyWith(color: AppColors.textButton),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
