// ******************* FILE INFO *******************
// File Name: show_request_details_shimmer
// Description: Show request details shimmer.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


Widget shimmerPlaceholder(  BuildContext context ,{double width = double.infinity, double height = 20}) {
  return Shimmer.fromColors(
    baseColor: Theme.of(context).brightness == Brightness.light ? AppColors.white : AppColors.background,
    highlightColor: Theme.of(context).brightness == Brightness.light ? AppColors.background : AppColors.chatBackground,
    direction: ShimmerDirection.ltr,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? AppColors.white : AppColors.chatBackground,
        //borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}