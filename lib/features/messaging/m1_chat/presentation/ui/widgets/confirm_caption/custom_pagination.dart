/// Module: messaging / chat / presentation/ui/widgets/confirm_caption/custom_pagination.dart
part of '../confirm_caption_view.dart';

//Youssef Ashraf

///custom pagination for swiper
class CustomPagination extends StatelessWidget {
  const CustomPagination({
    super.key,
    required this.files,
    required this.controller,
    required this.config,
  });

  final List<PlatformFile> files;
  final SwiperPluginConfig config;
  final MasterChatCubit controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            files.length,
            (index) {
              final mimeType = lookupMimeType(files[index].path!);
              bool isVideo = mimeType?.startsWith('video/') ?? false;
              if (isVideo) {
                final model =
                    VideoMessageModel(videoFilePath: files[index].path!,);
                return GestureDetector(
                  onTap: () {
                    if (index != config.activeIndex) {
                      controller.swiperController.move(index);
                    }
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    margin: EdgeInsetsDirectional.only(end: 5.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: config.activeIndex == index
                            ? AppColors.primary
                            : AppColors.transparent,
                      ),
                    ),
                    child: VideoPlayer(
                      model.playerController,
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () {
                    if (index != config.activeIndex) {
                      controller.swiperController.move(index);
                    }
                  },
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    margin: EdgeInsetsDirectional.only(end: 5.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      image: DecorationImage(
                          image: FileImage(
                        File(files[index].path!),
                      )),
                      border: Border.all(
                        color: config.activeIndex == index
                            ? AppColors.secondaryPrimary
                            : AppColors.transparent,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}