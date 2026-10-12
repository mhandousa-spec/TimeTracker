import 'dart:convert';

// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of watermark model
class WatermarkModel {
  List<String> imageName;
  List<String> imageUrl;
  List<String> size;
  List<String> opacity;

  WatermarkModel({
    required this.imageName,
    required this.imageUrl,
    required this.size,
    required this.opacity,
  });

  WatermarkModel copyWith({
    required List<String> imageName,
    required List<String> imageUrl,
    required List<String> size,
    required List<String> opacity,
  }) {
    return WatermarkModel(
      imageName: imageName ?? this.imageName,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Watermark_Name': imageName,
      'Watermark_Url': imageUrl,
      'Watermark_Size': size,
      'Watermark_Opacity': opacity,
    };
  }

  factory WatermarkModel.fromMap(Map<String, dynamic> map) {
    return WatermarkModel(
      imageName: List<String>.from((map['Watermark_Name'])),
      imageUrl: List<String>.from((map['Watermark_Url'])),
      size: List<String>.from((map['Watermark_Size'])),
      opacity: List<String>.from((map['Watermark_Opacity'])),
    );
  }

  String toJson() => json.encode(toMap());

  factory WatermarkModel.fromJson(String source) =>
      WatermarkModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
