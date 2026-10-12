/// Module: messaging / chat / presentation/ui/widgets/confirm_caption/caption_field.dart
part of '../confirm_caption_view.dart';

//Youssef Ashraf
//Captions default form field

class CaptionField extends StatelessWidget {
  const CaptionField({
    super.key,
    required this.controller,
    required this.files,
  });

  final MasterChatCubit controller;
  final List<PlatformFile> files;

  @override
  Widget build(BuildContext context) {
    bool isArabic = Get.locale?.languageCode == 'ar';
    return Obx(
          () => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                ),
                child: CustomTextField(
                  minLines: 1,
                  height: 36,
                  textAlign: isArabic == null
                      ? TextAlign.start
                      : isArabic == true
                      ? TextAlign.right
                      : TextAlign.left,
                  hint: S.of(context).addCaption,
                  maxLines: 1,
                  showCharCount: false,
                  hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                  fillColor: AppColors.card,
                  width: double.infinity,
                  controller: controller
                      .captionControllers[controller.state.swiperIndex], // Fixed: access through state
                  contentPadding: const EdgeInsetsDirectional.only(
                      top: 7, bottom: 7, start: 9, end: 9),
                  onChanged: controller.setCurrentMessage,)),
          ),
          SizedBox(
            width: 30.w,
          ),
          GestureDetector(
              onTap: () {
                if (ContextExtension(context).isTablett || ContextExtension(context).isLandscape) {
                  Get.back();
                } else {
                  Get.until(
                        (route) => Get.currentRoute == Routes.message,
                  );
                }
                for (int i = 0; i < files.length; i++) {
                  final mimeType = lookupMimeType(files[i].path!);
                  controller.applySelectedMessageAction(context); // Fixed: pass context
                }
              },
              child: Container(
                width: 52.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    5.91.r,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  S.of(context).send,
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton),
                ),
              )),
        ],
      ),
    );
  }
}