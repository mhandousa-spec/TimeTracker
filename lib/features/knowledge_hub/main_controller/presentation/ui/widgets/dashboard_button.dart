import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../data/services/dashboard_firebase_services.dart';
import '../../../../k8_dashboard/presentation/controller/dashboard_cubit.dart';
import '../../../../k8_dashboard/presentation/ui/pages/dashboard_screen.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget dashboardButton(BuildContext context) {
  final isMobile = ContextExtension(context).isPhone;
  return SizedBox(
    child: customButton(
      title: S.of(context)!.dashboard,
      function: () {
        log('Dashboard Button Pressed');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => DashboardCubit(DashboardFirebaseServices()),
              child: DashboardScreenKnow(),
            ),
          ),
        );
      },
      width: isMobile ? 100.w : 135.w,
      height: 38.h,
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.textButton,
      ),
    ),
  );
}
