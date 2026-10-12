// ******************* FILE INFO *******************
// File Name: empty_state_widget
// Description: Empty state widget.
// Module: services_management_module / presentation/s6_services_requests/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 500.sp, // ✅ gives Column a bounded height to center within
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
            width: 400.sp,
            height: 400.sp,
            fit: BoxFit.fill,
            repeat: true,
            animate: true,
          ),
        ],
      ),
    );
  }
}