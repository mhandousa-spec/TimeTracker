/// Module: messaging / chat / presentation/ui/widgets/confirm_caption_view.dart
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:mime/mime.dart';

import 'package:video_player/video_player.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import '';
import 'package:knowticed_plus/core/network/message_module/routes/app_routes.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../data/models/message/video_message_model.dart';
import '../../controller/main_controllers/master_chat_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part './confirm_caption/custom_pagination.dart';
part './confirm_caption/caption_field.dart';


//Youssef Ashraf
///Where user select captions for one/ multible images & videos
class ConfirmCaptionView extends GetView<MasterChatCubit> {
  final List<PlatformFile> files;

  const ConfirmCaptionView({
    required this.files,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        // Access swiperIndex through state and update it through the method
        controller.updateSwiperIndex(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ContextExtension(context).isTablett ? 24.w : 16.0.w),
            child: SizedBox(
              height: double.infinity,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Swiper(
                      controller: controller.swiperController,
                      itemCount: files.length,
                      onIndexChanged: (value) {
                        // Update through the method instead of direct property access
                        controller.updateSwiperIndex(value);
                      },
                      loop: false,
                      pagination: SwiperCustomPagination(
                        builder:
                            (BuildContext context, SwiperPluginConfig config) {
                          return Visibility(
                            visible:
                            MediaQuery.of(context).viewInsets.bottom == 0,
                            child: CustomPagination(
                              files: files,
                              controller: controller,
                              config: config,
                            ),
                          );
                        },
                      ),
                      itemBuilder: (context, index) {
                        final mimeType = lookupMimeType(files[index].path!);
                        bool isVideo = mimeType?.startsWith('video/') ?? false;

                        if (isVideo) {
                          final model = VideoMessageModel(
                              videoFilePath: files[index].path!,
                              caption: controller.captionControllers[index].text);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                width: double.infinity,
                                child: VideoPlayer(
                                  model.playerController,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor:
                                AppColors.grey.withOpacity(0.3),
                                child: SvgPicture.asset(
                                  AppAssets.play,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Image.file(
                            File(files[index].path!),
                            height: MediaQuery.of(context).size.height / 2,
                            width: double.infinity,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 100.h,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: CaptionField(
                        controller: controller,
                        files: files,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}