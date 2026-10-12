import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../m2_connections/presentation/controller/community_controller.dart';
import '../../controller/message_controller.dart';
import '../../../data/models/media/media_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

//Youssef Ashraf
///Part of chat profile view .. contains the whole media section
///
class MediaSection extends StatelessWidget {
  final MediaModel mediaModel;
  final String title;

  const MediaSection({
    super.key,
    required this.mediaModel,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (ContextExtension(context).isTablett) {
                      // Use BLoC instead of GetX
                      final communityCubit = context.read<CommunityCubit>();
                      communityCubit.toggleShowAdditionalInfo(true);
                      // Note: You may need to add methods to CommunityCubit for these
                      // For now, calling refreshCommunity to trigger state update
                      communityCubit.refreshCommunity();
                    } else {
                      Get.toNamed(
                        Routes.media,
                        arguments: {
                          'media': mediaModel,
                          'recieverName': title,
                        },
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          S.of(context).mediaLinksAndDocs,
                          style: StyleText.fontSize16Weight500,
                        ),
                      ),
                      Text(
                        mediaModel.totalMediaItems != null
                            ? mediaModel.totalMediaItems.toString()
                            : '0',
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.secondaryBlack,
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Get.locale.toString().contains('en')
                          ? SvgPicture.asset(
                        AppAssets.arrowForward,
                        color: AppColors.text,
                        width: ContextExtension(context).isTablett ? 24.w : 16.w,
                        height: ContextExtension(context).isTablett ? 24.h : 16.h,
                      )
                          : SvgPicture.asset(
                        AppAssets.mobileArrowBack,
                        color: AppColors.text,
                        width: ContextExtension(context).isTablett ? 24.w : 16.w,
                        height: ContextExtension(context).isTablett ? 24.h : 16.h,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16.h,
            ),
            mediaModel.images == null
                ? const SizedBox()
                : SizedBox(
              height: 76.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => SizedBox(
                  width: 8.w,
                ),
                itemCount: (mediaModel.images!.length / 2).floor(),
                itemBuilder: (context, index) => Container(
                  clipBehavior: Clip.antiAlias,
                  height: 76.h,
                  width: 76.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      8.r,
                    ),
                  ),
                  child: Image.asset(
                    mediaModel.images![index].img,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}