part of '../../../pages/mobile_media_view.dart';

//Youssef Ashraf
///defaul docs card in media docs
class DocsCard extends StatelessWidget {
  final DocInfoModel model;
  const DocsCard({super.key, required this.model});


  @override
  Widget build(BuildContext context) {
    final isXls = model.fileName.split('.')[1].toLowerCase() == 'xls';
    return Container(
      height: ContextExtension(context).isTablett ? 80.h : 75.h,
      width: ContextExtension(context).isTablett ? double.infinity : 312.w,
      padding: EdgeInsets.only(
        right: ContextExtension(context).isTablett ? 16.46.w : 8.w,
        left: 8.w,
        top: 8.h,
      ),
      decoration: BoxDecoration(
          color: ContextExtension(context).isTablett ? AppColors.background : AppColors.field,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.transparent)),
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                isXls ? AppAssets.xls : AppAssets.pdf,
                width: ContextExtension(context).isTablett ? 48.w : 40.w,
                height: ContextExtension(context).isTablett ? 48.h : 40.h,
              ),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.fileName,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize16Weight400,
                    ),
                    Flexible(
                      child: Text(
                        model.fileInfo,
                        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.lightGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 8.h,
            child: Text(
              DateFormat(
                'd MMMM yyyy, h:mm a', /*  Get.locale.toString() */
              )
                  .format(
                    model.date,
                  )
                  .toLowerCase(),
              style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey),
            ),
          ),
        ],
      ),
    );
  }
}
