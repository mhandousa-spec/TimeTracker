/// Module: messaging / home / presentation/ui/widgets/category_filter.dart
/// ************************* FILE INFO *************************** ///
/// File Name: category_filter.dart
/// Purpose: Category filter — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart' show FilterBarItem;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';

import '../../../../../../core/helper/message_module/interface/entity/user_category.dart';


class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionsCubit, ConnectionsState>(
      builder: (context, connectionsState) {
        // Get the cubit to access properties
        final connectionsCubit = context.read<ConnectionsCubit>();

        // Add null check for categories
        if (connectionsCubit.categories == null ||
            connectionsCubit.categories!.isEmpty) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<MessagingHomeCubit, MessagingHomeState>(
          builder: (context, homeState) {
            final homeCubit = context.read<MessagingHomeCubit>();

            return Theme(
              data: Theme.of(context).copyWith(
                splashColor: AppColors.transparent,
                highlightColor: AppColors.transparent,
                hoverColor: AppColors.transparent,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 30.sp,
                  children: [
                    for (UserCategory category in connectionsCubit.categories!)
                      if (connectionsCubit.categoriesUsersCount[category.categoryId] != null &&
                          connectionsCubit.categoriesUsersCount[category.categoryId]! > 0)
                        FilterBarItem(
                          isSelected: homeCubit.selectedTab.categoryId == category.categoryId,
                          title: category.name,
                          numberOfItems: connectionsCubit.categoriesUsersCount[category.categoryId] ?? 0,
                          onTap: () {
                            homeCubit.filterByCategory(category);
                          },
                        )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}