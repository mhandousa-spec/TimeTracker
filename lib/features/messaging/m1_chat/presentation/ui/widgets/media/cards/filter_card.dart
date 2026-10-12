part of '../../../pages/mobile_media_view.dart';

class FilterCard extends StatelessWidget {
  final String tab;
  final dynamic obj;

  const FilterCard({
    super.key,
    required this.tab,
    required this.obj,
  });

  @override
  Widget build(BuildContext context) {
    if (tab == S.of(context).media) {
      return ImageGridCard(
        width: 76.w,
        height: 76.h,
        image: obj.img,
      );
    }
    if (tab == S.of(context).documents) {
      return DocsCard(
        model: obj as DocInfoModel,
      );
    }
    return LinkCard(
      model: obj as LinkModel,
    );
  }
}
