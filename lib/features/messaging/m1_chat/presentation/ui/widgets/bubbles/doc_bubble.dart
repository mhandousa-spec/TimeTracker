/// Module: messaging / chat / presentation/ui/widgets/bubbles/doc_bubble.dart
// By: Youssef Ashraf
// Last update: 8/9/2024
// Objectives: This file is responsible for providing a widget that represents a Doc bubble in the direct messaging view.

part of '../../pages/chat_mobile_view.dart';

class DocBubble extends StatelessWidget {
  final MessageEntity messageModel;
  final bool isGroup;
  final int index;

  const DocBubble({
    super.key,
    required this.messageModel,
    required this.isGroup,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    var isMe = messageModel.isMe;
    final masterChatCubit = context.read<MasterChatCubit>();

    return BlocBuilder<MasterChatCubit, MasterChatState>(
      bloc: masterChatCubit,
      builder: (context, state) {
        return DefaultBubble(
          index: index,
          isGroup: isGroup,
          messageModel: messageModel,
          content: /*messageModel.docMessageModel!.firstPageBytes != null
              ? */
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  //   if (messageModel.docMessageModel.messageType == MessageTypes.doc) {
                  Get.toNamed(
                    Routes.docView,
                    arguments: {
                      'docMessageModel': messageModel.docMessageModel!
                    },
                  );
                },
                child: Container(
                    padding: EdgeInsets.all(8.sp),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: /*isTablet ? AppColors.background :*/
                      AppColors.field,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      spacing: 8.sp,
                      children: [
                        // Bug report #18: file-type svg (pdf.svg for PDFs).
                        // Detected from the file NAME first — the stored
                        // path is a storage URL whose query hides the
                        // extension.
                        CustomSvgImage(
                          assetPath: FileTypes.getFileIcon(
                              messageModel.docMessageModel!.fileName ??
                                  messageModel.docMessageModel!.docPath!),
                          width: 40.sp,
                          height: 40.sp,
                          fit: BoxFit.contain,
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
                                          messageModel.docMessageModel!.fileName!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: StyleText.fontSize14Weight500
                                              .copyWith(fontWeight: FontWeight.w600),
                                        )),
                                  ],
                                ),
                                /* Text(
                                messageModel.docMessageModel!.totalPages.toString() +
                                    ' Pages'.tr +
                                    ' - ' +
                                    (messageModel.docMessageModel!.totalSize! / 1024)
                                        .toStringAsFixed(2) +
                                    ' KB' +
                                    '.${FileHandler.getFileExtension(messageModel.docMessageModel!)}',
                                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack))*/
                              ],
                            ))
                      ],
                    )),
              )
              /*     GestureDetector(
                onTap: () {
                  Get.toNamed(
                    Routes.docView,
                    arguments: {
                      'docMessageModel': messageModel.docMessageModel!
                    },
                  );
                },
                child: Image.memory(
                  messageModel.docMessageModel!.firstPage!,
                  fit: BoxFit.cover,
                  height: 100.h,
                  width: double.infinity,
                ),
              ),
              Text(
                messageModel.docMessageModel!.fileName!,
                style: isMe
                    ? StyleText.fontSize14Weight400
                        .copyWith(color: AppColors.textButton)
                    : StyleText.fontSize14Weight400,
                softWrap: true,
              ),
              Wrap(
                children: [
                  Text(
                    '${messageModel.docMessageModel!.totalPages} ${'pages'.tr} • ',
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.inputColor)
                        .copyWith(color: AppTheme.contrastGreyColor()),
                  ),
                  horizontalSpace(2),
                  Text(
                    '${messageModel.docMessageModel!.totalSize.toStringAsFixed(2)} ${'MB'.tr} • ',
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.inputColor)
                        .copyWith(color: AppTheme.contrastGreyColor()),
                  ),
                  horizontalSpace(2),
                  Text(
                    messageModel.docMessageModel!.extension,
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.inputColor)
                        .copyWith(color: AppTheme.contrastGreyColor()),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),*/
            ],
          )
          /*         : LinearProgressIndicator(
                  color: AppColors.base,
                  backgroundColor: AppColors.inverseBase,
                )*/
          ,
        );
      },
    );
  }
}