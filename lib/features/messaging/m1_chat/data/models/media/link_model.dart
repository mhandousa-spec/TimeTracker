// Date: 2/9/2024
// By: Youssef Ashraf
// Last update: 2/9/2024
// Objectives: This file is responsible for providing a model for the link.

import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';

class LinkModel {
  String link;
  DateTime date;

  ///used to be grouped to a specific sort label date based on its value
  String? sortCategory;

  LinkModel({required this.date, required this.link}) {
    sortCategory = DateTimeHelper.sortDate(date);
  }
  String? get sortedCategory => sortCategory;
  LinkModel copyWith({
    String? link,
    DateTime? date,
  }) {
    return LinkModel(
      link: link ?? this.link,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'link': link,
      'date': date,
    };
  }

  factory LinkModel.fromMap(Map<String, dynamic> map) {
    return LinkModel(
      link: map['link'] as String,
      date: map['date'] as DateTime,
    );
  }
}
