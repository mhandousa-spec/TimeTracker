/// Module: messaging / connections / presentation/ui/pages/community_mobile_layout.dart
/// ************************* FILE INFO *************************** ///
/// File Name: community_mobile_layout.dart
/// Purpose: Community mobile layout — messaging Connections sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 16/9/2024
// By: Youssef Ashraf
// Objectives: This file is responsible for providing the community mobile layout used in the community feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/domain/enums/sort_enum.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/ui/widgets/layouts/widgets/tablet_chats_list.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';

class CommunityMobileLayout extends StatelessWidget {
  const CommunityMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: BlocBuilder<MessagingHomeCubit, MessagingHomeState>(
          builder: (context, state) {
            final controller = context.read<MessagingHomeCubit>();

            return Column(
              children: [
                Row(
                  spacing: 10.sp,
                  children: [

                    // search
                    AppSearchTextField(
                      controller: controller.searchController,
                      onChanged: (text) {
                        controller.filterAllChats();
                      },
                    ),
                    SizedBox(
                      width: 36.h,
                      height: 36,
                      child: CustomSortButton<SortEnum>(
                        value: controller.sort,
                        items: SortEnum.values,
                        labelBuilder: (sort) => sort.label(context),
                        title: 'Sort',
                        showTitle: false,
                        svgPath: AppAssets.sort,
                        width: double.infinity,
                        height: 36,
                        yOffset: 94,
                        onChanged: controller.sortChats,
                      ),
                    ),
                  ],
                ),
                const TabletChatList(),
                verticalSpace(80),
              ],
            );
          },
        ),
      ),
    );
  }
}