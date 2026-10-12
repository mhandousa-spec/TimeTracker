import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_analytics_extension.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/address_analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/analytics_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/address_analytics_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/analytics_main_widget.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Generate analytics data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResultCubit>().getAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const CircleProgressMaster();
        }

        if (state.submittedUsers.isEmpty) {
          return Center(
            child: Column(
              children: [
                Lottie.asset(AppAssets.noData, width: 400.sp),
                verticalSpace(20),
                Text(
                  'No Submission Found',
                  style: StyleText.fontSize16Weight500,
                ),
              ],
            ),
          );
        }

        return Column(
          spacing: 10.h,
          children: [
            verticalSpace(10),
            for (AnalyticsEntity entity in state.analyticsData)
              (entity.type == FormFieldType.address)
                  ? AddressAnalyticsWidget(data: entity as AddressAnalyticsEntity)
                  : AnalyticsMainWidget(data: entity)
          ],
        );
      },
    );
  }
}