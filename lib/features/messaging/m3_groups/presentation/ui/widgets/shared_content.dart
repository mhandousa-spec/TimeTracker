// Date: 23/9/2024
// By: Nada Mohammed
// Last update: 23/9/2024
// Objectives: This file is responsible for providing the shared content for the group chat profile feature.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/presentation/controller/media_controller.dart';
import 'package:lottie/lottie.dart';


import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../m1_chat/data/models/media/media_model.dart';
import '../../../../m1_chat/presentation/ui/pages/mobile_media_view.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

class SharedContent extends StatelessWidget {
  const SharedContent({
    super.key,
    required this.model,
    required this.verticalSpacing,
  });

  final MediaModel model;
  final double verticalSpacing;

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;
    return BlocBuilder<MediaCubit, MediaState>(
        builder: (context, state) {
          final cubit = context.read<MediaCubit>();
          final selectedMediaTab = state is MediaLoaded
              ? state.selectedMediaTab
              : cubit.selectedMediaTab;

          return Column(
            children: [
              const MediaTabbar(),
              SizedBox(
                height: ContextExtension(context).isTablett ? 40.h : 24.h,
              ),
              if ((model.images == null || model.images!.isEmpty) &&
                  selectedMediaTab == S.of(context).media)
                Column(
                  children: [
                    verticalSpace(verticalSpacing),
                    LottieBuilder.asset(
                      AppAssets.media,
                      width: 170.w,
                      height: 170.h,
                      frameRate: const FrameRate(120),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      S.of(context).noMedia,
                      style: StyleText.fontSize18Weight600,
                    ),
                  ],
                ),
              if ((model.links == null || model.links!.isEmpty) &&
                  selectedMediaTab == S.of(context).links)
                Column(
                  children: [
                    verticalSpace(verticalSpacing),
                    LottieBuilder.asset(
                      AppAssets.links,
                      width: 170.w,
                      height: 170.h,
                      frameRate: const FrameRate(120),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      S.of(context).noLinks,
                      style: StyleText.fontSize18Weight600,
                    ),
                  ],
                ),
              if ((model.pdfs == null || model.pdfs!.isEmpty) &&
                  selectedMediaTab == S.of(context).documents)
                Column(
                  children: [
                    verticalSpace(verticalSpacing),
                    LottieBuilder.asset(
                      AppAssets.docs,
                      width: 170.w,
                      height: 170.h,
                      frameRate: const FrameRate(120),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Text(
                      S.of(context).noDocs,
                      style: StyleText.fontSize18Weight600,
                    ),
                  ],
                ),
              Padding(
                padding: EdgeInsets.only(bottom: isTablet ? 24.w : 16.w),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: cubit
                        .filterDates(
                      model: model,
                      tab: selectedMediaTab,
                    )
                        ?.map(
                          (sortedDateLabel) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sortedDateLabel,
                              style: ContextExtension(context).isTablett
                                  ? StyleText.fontSize23Weight500.copyWith(color: AppColors.darkGrey)
                                  : StyleText.fontSize16Weight500.copyWith(color: AppColors.darkGrey),
                            ),
                            SizedBox(
                              height: ContextExtension(context).isTablett ? 24.h : 16.h,
                            ),
                            StaggeredGrid.count(
                              mainAxisSpacing: 16.h,
                              crossAxisSpacing: isTablet ? 16.w : 8.w,
                              crossAxisCount:
                              selectedMediaTab ==
                                  S.of(context).media
                                  ? isTablet
                                  ? 5
                                  : 4
                                  : 1,
                              children: cubit
                                  .filterTabs(
                                model: model,
                                sortedDateLabel: sortedDateLabel,
                                tab: selectedMediaTab,
                              )
                                  ?.map(
                                    (obj) {
                                  return FilterCard(
                                    tab: selectedMediaTab,
                                    obj: obj,
                                  );
                                },
                              ).toList() ??
                                  [],
                            ),
                            SizedBox(
                              height: ContextExtension(context).isTablett ? 40.h : 24.h,
                            ),
                          ],
                        );
                      },
                    ).toList() ??
                        [],
                  ),
                ),
              ),
            ],
          );
        });
  }
}