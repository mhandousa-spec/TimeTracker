/// Module: messaging / chat / presentation/ui/widgets/media_links_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart'; // Keep for .tr and context extensions
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/84-messaging_custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:video_player/video_player.dart';


import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/file_handler.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../domain/entity/message_entity.dart';
import '../../../domain/enum/chat_actions.dart';
import '../../../domain/enum/file_types.dart';
import '../../../domain/enum/media_type.dart';
import '../../controller/main_controllers/master_chat_cubit.dart';
import './video_player_view.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class MediaLinksWidget extends StatefulWidget {
  const MediaLinksWidget({super.key});

  @override
  State<MediaLinksWidget> createState() => _MediaLinksWidgetState();
}

class _MediaLinksWidgetState extends State<MediaLinksWidget> {
  MediaType selectedMediaType = MediaType.media;
  late bool isTablet;

  @override
  void initState() {
    super.initState();
    // Filter media messages when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MasterChatCubit>().filterMessagesMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    isTablet = ContextExtension(context).isTablet;

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      builder: (context, state) {
        final cubit = context.read<MasterChatCubit>();

        return Container(
          margin: EdgeInsetsDirectional.only(
            start: 16.sp,
            end: isTablet ? 0 : 16.sp,
            top: 24.h,
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isTablet ? AppColors.field : AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
          ),
          width: ContextExtension(context).isTablet ? 269.sp : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    ChatActionsEnum.mediaLinksAndDocs.getLabel(context.isArabic),
                    style: StyleText.fontSize16Weight500,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      cubit.toggleMediaState();
                    },
                    child: SvgPicture.asset(
                      AppAssets.close,
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.secondaryBlack,
                    ),
                  )
                ],
              ),
              verticalSpace(24),
              Container(
                padding: EdgeInsets.all(4.sp),
                decoration: BoxDecoration(
                  color: isTablet ? AppColors.background : AppColors.field,
                  borderRadius: BorderRadius.circular(4.sp),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (MediaType type in MediaType.values)
                      CustomButton(
                        verticalPadding: 4.sp,
                        horizontalPadding: 8.sp,
                        borderRadius: 4.r,
                        // Bug report #17: was the raw enum name
                        // ("media"); capitalised via FormatHelper, Arabic
                        // under Arabic.
                        buttonText: context.isArabic
                            ? _mediaTypeArabic(type)
                            : FormatHelper.capitalize(type.name),
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: (selectedMediaType == type)
                              ? AppColors.textButton
                              : AppColors.text,
                        ),
                        buttonColor: (selectedMediaType == type)
                            ? AppColors.primary
                            : isTablet
                            ? AppColors.background
                            : AppColors.field,
                        onTap: () {
                          setState(() {
                            selectedMediaType = type;
                          });
                        },
                      ),
                  ],
                ),
              ),
              verticalSpace(16),
              _buildMediaList(state),
            ],
          ),
        );
      },
    );
  }

  String _mediaTypeArabic(MediaType type) {
    switch (type) {
      case MediaType.media:
        return 'الوسائط';
      case MediaType.links:
        return 'الروابط';
      case MediaType.documents:
        return 'المستندات';
    }
  }

  String _getEmptyMediaLabel(MediaType type) {
    final isArabic = Get.locale?.languageCode == 'ar';
    switch (type) {
      case MediaType.media:
        return isArabic ? 'لا توجد وسائط' : 'No Media Found';
      case MediaType.links:
        return isArabic ? 'لا توجد روابط' : 'No Links Found';
      case MediaType.documents:
        return isArabic ? 'لا توجد مستندات' : 'No Documents Found';
    }
  }

  Widget _buildMediaList(MasterChatState state) {
    // Access mediaMessages from state
    final mediaMessages = state.mediaMessages[selectedMediaType] ?? {};

    if (mediaMessages.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            _getEmptyMediaLabel(selectedMediaType),
            style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.sp,
          children: [
            for (var monthKey in mediaMessages.keys)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthKey,
                    style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                  ),
                  verticalSpace(8),
                  Wrap(
                    spacing: 8.sp,
                    runSpacing: 8.sp,
                    children: [
                      for (var media in mediaMessages[monthKey]!)
                        _buildMediaItem(media),
                    ],
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(MessageEntity media) {
    if (media.messageType == MessageTypes.galleryImage ||
        media.messageType == MessageTypes.cameraImage) {
      return InkWell(
        onTap: () {},
        child: Container(
          width: 70.sp,
          height: 70.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            image: DecorationImage(
              image: NetworkImage(media.mediaLink!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (media.messageType == MessageTypes.video) {
      return InkWell(
        onTap: () {
          context.read<MasterChatCubit>()
              .imageMessageCubit
              .playVideo(media.videoMessageModel!);

          Get.to(
            VideoPlayerView(
              model: media.videoMessageModel!,
            ),
          );
        },
        child: Container(
          width: 70.sp,
          height: 70.sp,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: VideoPlayer(
              media.videoMessageModel!.playerController,
            ),
          ),
        ),
      );
    } else if (media.messageType == MessageTypes.doc) {
      return _buildDocumentMessage(media);
    } else if (media.messageType == MessageTypes.text) {
      return _buildLinkWidget(media);
    }

    return const SizedBox.shrink();
  }

  Widget _buildDocumentMessage(MessageEntity media) {
    return InkWell(
      onTap: () {
        if (media.messageType == MessageTypes.doc) {
          Get.toNamed(
            Routes.docView,
            arguments: {'docMessageModel': media.docMessageModel!},
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.sp),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isTablet ? AppColors.background : AppColors.field,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          spacing: 8.sp,
          children: [
            Container(
              width: 40.sp,
              height: 40.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                image: DecorationImage(
                  image: appImageProvider(
                    FileTypes.getFileIcon(media.mediaLink!),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2.sp,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.yMMMd().format(media.time.toDate()) +
                            S.current.at +
                            DateFormat.jm().format(media.time.toDate()),
                        style: StyleText.fontSize10Weight400.copyWith(
                          color: AppColors.secondaryBlack,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          media.docMessageModel!.fileName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    media.docMessageModel!.totalPages.toString() +
                        S.current.pages +
                        ' - ' +
                        (media.docMessageModel!.totalSize! / 1024)
                            .toStringAsFixed(2) +
                        ' KB' +
                        '.${FileHandler.getFileExtension(media.mediaLink!)}',
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLinkWidget(MessageEntity media) {
    return Container(
      padding: EdgeInsets.all(8.sp),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isTablet ? AppColors.background : AppColors.field,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.sp,
        children: [
          SvgPicture.asset(
            AppAssets.link,
            width: 15.sp,
            height: 15.sp,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.sp,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        media.messageContent!,
                        style: StyleText.fontSize14Weight500.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue,
                          height: 1.05,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.yMMMd().format(media.time.toDate()) +
                          S.current.at +
                          DateFormat.jm().format(media.time.toDate()),
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.secondaryBlack,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}