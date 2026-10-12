// Date: 2/9/2024
// By: Youssef Ashraf
// Last update: 2/9/2024
// Objectives: This file is responsible for providing  a model for the document info.



import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';

class DocInfoModel {
  String fileName;
  String fileInfo;
  DateTime date;

  ///used to be grouped to a specific sort label date based on its value
  String? sortCategory;

  DocInfoModel({
    required this.fileName,
    required this.fileInfo,
    required this.date,
  }) {
    sortCategory = DateTimeHelper.sortDate(date);
  }
  String? get sortedCategory => sortCategory;

  DocInfoModel copyWith({
    String? fileName,
    String? fileInfo,
    DateTime? date,
  }) {
    return DocInfoModel(
      fileName: fileName ?? this.fileName,
      fileInfo: fileInfo ?? this.fileInfo,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fileName': fileName,
      'fileInfo': fileInfo,
      'date': date,
    };
  }

  factory DocInfoModel.fromMap(Map<String, dynamic> map) {
    return DocInfoModel(
      fileName: map['fileName'] as String,
      fileInfo: map['fileInfo'] as String,
      date: map['date'] as DateTime,
    );
  }
}
