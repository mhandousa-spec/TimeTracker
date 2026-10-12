// Date: 2/9/2024
// By: Youssef Ashraf
// Last update: 2/9/2024
// Objectives: This file is responsible for providing a model for the image.



import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';

class ImageModel {
  String img;
  DateTime date;

  ///used to be grouped to a specific sort label date based on its value
  String? sortCategory;
  ImageModel({required this.date, required this.img, this.sortCategory}) {
    sortCategory = DateTimeHelper.sortDate(date);
  }
  String? get sortedCategory => sortCategory;

  ImageModel copyWith({
    String? img,
    DateTime? date,
  }) {
    return ImageModel(
      img: img ?? this.img,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'img': img,
      'date': date,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      img: map['img'] as String,
      date: map['date'] as DateTime,
    );
  }
}
