/// Module: knowledge_hub / presentation / s4_submissions / widgets/search_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: search_section.dart
/// Purpose: Search section — Submissions (S4) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/knowledge_hub/k4_submissions/presentation/ui/widgets/status_filter_dialog.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/submissions_cubit.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

Widget searchWithStatusFilters(
    BuildContext context, {
      required TextEditingController searchCategoryController,
    }) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  final isMobile = ContextExtension(context).isPhone; // ✅ Check if mobile

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      AppSearchTextField(
        controller: searchCategoryController,
        fillColor: lightMode
            ? AppColors.white
            : AppColors.chatBackground,
        onChanged: (query) {
          context.read<SubmissionsCubit>().searchKnowledge(query);
        },
      ),
      SizedBox(width: 10.w),

      //Show icon only on mobile, icon + text on tablet/desktop
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => Center(
              child: BlocProvider.value(
                value: context.read<SubmissionsCubit>(),
                child: StatusFilterDialog(),
              ),
            ),
          );
        },
        child: Container(
          height: 38.h,
          // Dynamic width based on device
          width: isMobile ? 38.w : null, // Auto width for text on non-mobile
          padding: isMobile
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: 12.w), // Padding for text
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: lightMode
                ? AppColors.white
                : AppColors.chatBackground,
          ),
          child: isMobile
              ? // ✅ Mobile: Icon only (centered)
          Center(
            child: CustomSvgImage(
              assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_filter.svg',
              height: 23.h,
              width: 23.w,
            ),
          )
              : // ✅ Tablet/Desktop: Icon + Text
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSvgImage(
                assetPath: 'assets/icons_assets/knowledge_hub_assets/svg_filter.svg',
                height: 20.h,
                color: AppColors.secondaryText,
                width: 20.w,
              ),
              SizedBox(width: 6.w),
              Text(
                S.of(context).filter ?? 'Filter',
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}