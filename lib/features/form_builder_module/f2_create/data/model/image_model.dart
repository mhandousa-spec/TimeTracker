import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of image model
class ImageModel {
  List<String?>? image;

  ImageModel({
    this.image,
  });

  ImageModel copyWith({
    List<String?>? image,
    List<Timestamp?>? timestamps,
  }) {
    return ImageModel(
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Image': image,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      image: map['Image'] != null
          ? List<String?>.from(
              (map['Image']),
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageModel.fromJson(String source) =>
      ImageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
