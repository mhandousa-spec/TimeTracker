import 'dart:convert';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of form description model
class FormDescriptionModel {
  List<String?>? description;

  FormDescriptionModel({
    required this.description,
  });

  FormDescriptionModel copyWith({
    List<String?>? description,
  }) {
    return FormDescriptionModel(
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Description': description,
    };
  }

  factory FormDescriptionModel.fromMap(Map<String, dynamic> map) {
    return FormDescriptionModel(
      description: map['Description'] != null
          ? List<String?>.from(
              (map['Description']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FormDescriptionModel.fromJson(String source) =>
      FormDescriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
