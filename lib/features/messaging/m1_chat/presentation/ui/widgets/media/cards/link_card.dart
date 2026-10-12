part of '../../../pages/mobile_media_view.dart';

//Youssef Ashraf
///defaul links card in media links
class LinkCard extends StatelessWidget {
  final LinkModel model;
  const LinkCard({super.key, required this.model});

  @override

  Widget build(BuildContext context) {
    return Container(
      height: ContextExtension(context).isTablett ? 114.h : 73.h,
      width: double.infinity,
      padding: EdgeInsets.only(
        right: 13.w,
        left: 8.w,
        top: 7.h,
        bottom: 8.h,
      ),
      decoration: BoxDecoration(
          color: ContextExtension(context).isTablett ? AppColors.background : AppColors.field,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.transparent)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  AppAssets.link,
                  width: ContextExtension(context).isTablett ? 48.w : 40.w,
                  height: ContextExtension(context).isTablett ? 48.h : 40.h,
                ),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: Text(
                    model.link,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.blue),
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat(
              'd MMMM yyyy, h:mm a', /* Get.locale.toString() */
            )
                .format(
                  model.date,
                )
                .toLowerCase(),
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
          ),
        ],
      ),
    );
  }
}
