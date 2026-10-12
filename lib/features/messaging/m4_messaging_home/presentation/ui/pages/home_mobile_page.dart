/// Module: messaging / home / presentation/ui/pages/home_mobile_page.dart
/// ************************* FILE INFO *************************** ///
/// File Name: home_mobile_page.dart
/// Purpose: Home mobile page — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 16/9/2024
// By: Youssef Ashraf
// Objectives: This file is responsible for providing the community page used in the community feature.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/messaging/m5_support/presentation/support_chat_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/community_controller.dart';

import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/helper/main_helper/custom_app_bar.dart';
import '../../../../m2_connections/presentation/ui/pages/community_mobile_layout.dart';
import '../widgets/category_filter.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomeMobilePage extends StatefulWidget {
  const HomeMobilePage({super.key});

  @override
  State<HomeMobilePage> createState() => _HomeMobilePageState();
}

class _HomeMobilePageState extends State<HomeMobilePage> {
  @override
  void initState() {
    super.initState();
    // Initialize tab controller index after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CommunityCubit>();
      if (cubit.tabController.index != 0) {
        cubit.tabController.index = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityCubit, CommunityState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CustomAppBar(
                    title: S.of(context).messages,
                    centerTitle: false,
                    hideLeading: true,
                  ),
                ),
                SizedBox(height: 11.h),
                // Knowticed Support: feedback + replies (23/9/2026).
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                //   child: const SupportChatTile(),
                // ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: const CategoryFilter(),
                ),
                verticalSpace(16),
                const Expanded(child: CommunityMobileLayout()),
              ],
            ),
          ),
        );
      },
    );
  }
}