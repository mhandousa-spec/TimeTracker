import 'dart:convert';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of form title model
class FormTitleModel {
  List<String?>? title;

  FormTitleModel({
    this.title,
  });

  FormTitleModel copyWith({
    List<String?>? title,
  }) {
    return FormTitleModel(
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Title': title,
    };
  }

  factory FormTitleModel.fromMap(Map<String, dynamic> map) {
    return FormTitleModel(
      title: map['Title'] != null
          ? List<String?>.from(
              (map['Title']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FormTitleModel.fromJson(String source) =>
      FormTitleModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
