
//Youssef Ashraf
import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import './doc_info_model.dart';
import './image_model.dart';
import './link_model.dart';

/// A Model for media data in every chat including images,links and docs with date of sending/recieving
///
///
class MediaModel {
  List<ImageModel>? images;
  List<DocInfoModel>? pdfs;
  List<LinkModel>? links;
  Set<String>? imageSortedDates;
  Set<String>? pdfsSortedDates;
  Set<String>? linksSortedDates;
  int? totalMediaItems;
  MediaModel({
    this.images,
    this.pdfs,
    this.links,
  });

  ///we get all available sorted dates for each type(link-doc-media)
  sortImageDates() {
    //first we sort date to display the image sort dates appropriately
    images?.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    ///then we store all available sorted dates of images
    imageSortedDates = images!.map((e) {
      return DateTimeHelper.sortDate(e.date);
    }).toSet();
  }

  sortPdfDates() {
    pdfs?.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    pdfsSortedDates = pdfs!.map((e) {
      return DateTimeHelper.sortDate(e.date);
    }).toSet();
  }

  sortLinksDates() {
    links?.sort(
      (a, b) => b.date.compareTo(a.date),
    );

    linksSortedDates = links!.map((e) {
      return DateTimeHelper.sortDate(e.date);
    }).toSet();
  }

  calcTotalMediaItems() {
    totalMediaItems =
        (links?.length ?? 0) + (pdfs?.length ?? 0) + (images?.length ?? 0);
  }

  MediaModel copyWith({
    List<ImageModel>? images,
    List<DocInfoModel>? pdfs,
    List<LinkModel>? links,
  }) {
    return MediaModel(
      images: images ?? this.images,
      pdfs: pdfs ?? this.pdfs,
      links: links ?? this.links,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'images': images,
      'pdfs': pdfs?.map((x) => x.toMap()).toList(),
      'links': links,
    };
  }

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      images: List<ImageModel>.from(
        (map['images'] as List).map(
          (x) => ImageModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      pdfs: List<DocInfoModel>.from(
        (map['pdfs'] as List).map<DocInfoModel>(
          (x) => DocInfoModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      links: List<LinkModel>.from(
        (map['links'] as List).map<LinkModel>(
          (x) => LinkModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
