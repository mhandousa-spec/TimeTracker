/// Module: knowledge_hub / presentation / s2_view_knowledge_hub / widgets/inner_list_view.dart
/// ************************* FILE INFO *************************** ///
/// File Name: inner_list_view.dart
/// Purpose: Inner list view for displaying knowledge items in the hub.
/// Author: Knowticed Team
/// Created At: 11/10/2025


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';

Widget innerListView(
  BuildContext context, {
  required bool isMobile,
  required bool isLightMode,
  required int innerIndex,
}) {
  final cubit = context.read<CreateKnowledgeCubit>();

  List<Map<String, String>> innerCategories = [
    {
      'label': S.of(context)!.all,
      'value': 'all', // ✅ Use constant English value
    },
    {
      'label': S.of(context)!.owner,
      'value': 'owner', // ✅ Use constant English value
    },
    {
      'label': S.of(context)!.contributor,
      'value': 'contributor', // ✅ Use constant English value
    },
  ];

  return SizedBox(
    height:  28.h,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: innerCategories.length,
      itemBuilder: (context, index) {
        final category = innerCategories[index];

        return GestureDetector(
          onTap: () {
            cubit.filterByInnerCategory(category['value']!, index);
          },
          child: Padding(
            padding: EdgeInsetsDirectional.only(end: 10.w),
            child: Container(
              height: 28.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: innerIndex == index
                    ? AppColors.primary
                    : isLightMode
                    ? AppColors.white
                    : AppColors.chatBackground,
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Center(
                child: Text(
                  category['label']!, // Display localized label
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: innerIndex == index
                        ? AppColors.textButton
                        : isLightMode
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
