// Date: 15/2/2025
// By: Fouad
// Last update: 15/2/2025
// Objectives: Implementation of form model
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/watermark_model.dart';

class FormModel {
  static const String fieldId = 'Id';
  static const String fieldCreatedAt = 'Timestamps';
  static const String fieldNumberUsed = 'Number_Used';
  static const String fieldCreatedByEmail = 'Created_By_Email';
  static const String fieldImage = 'Image';
  static const String fieldEnglishTitle = 'English_Title';
  static const String fieldArabicTitle = 'Arabic_Title';
  static const String fieldEnglishDescription = 'English_Description';
  static const String fieldArabicDescription = 'Arabic_Description';
  static const String fieldAccessMangement = 'Access_Management';
  static const String fieldOrientation = 'Orientation';
  static const String fieldHorizontalPadding = 'Horizontal_Padding';
  static const String fieldVerticalPadding = 'Vertical_Padding';
  static const String fieldPages = 'Pages';
  static const String fieldFormStatus = 'Form_Status';
  static const String fieldWatermark = 'Watermark';

  final String id;
  final List<Timestamp> timestamps ;

  final String createdByEmail;
  List<String>? image;
  final List<String> title;
  final List<String> arabicTitle;
  final List<String> description;
  final List<String> arabicDescription;
  final List<String> accessMangement;
  final List<String> orientation;
  final List<String> horizontalPadding;
  final List<String> verticalPadding;
  final List<PageModel> pages;
  final List<String> formStatus;
  final WatermarkModel watermark;

  FormModel({
    required this.id,
    required this.timestamps,
    required this.createdByEmail,
    required this.image,
    required this.title,
    required this.arabicTitle,
    required this.description,
    required this.arabicDescription,
    required this.accessMangement,
    required this.orientation,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.pages,
    required this.formStatus,
    required this.watermark,
  });

  Map<String, dynamic> toMap() {
    return {
      fieldCreatedAt: timestamps,
      fieldId: id,
      fieldCreatedByEmail: createdByEmail,
      fieldArabicDescription: arabicDescription,
      fieldArabicTitle: arabicTitle,
      fieldEnglishDescription: description,
      fieldEnglishTitle: title,
      fieldImage: image,
      fieldAccessMangement: accessMangement,
      fieldOrientation: orientation,
      fieldHorizontalPadding: horizontalPadding,
      fieldVerticalPadding: verticalPadding,
      fieldPages: pages?.map((x) => x.toMap()).toList(),
      fieldFormStatus: formStatus,
      fieldWatermark: watermark?.toMap(),
    };
  }

  factory FormModel.fromMap(Map<String, dynamic> map) {
    return FormModel(
      id: map[fieldId] as String,
      timestamps:  List<Timestamp>.from(map[fieldCreatedAt] as List),

      createdByEmail: map[fieldCreatedByEmail] as String,
      image: map[fieldImage] != null
          ? List<String>.from(map[fieldImage] as List)
          : null,
      title: List<String>.from(map[fieldEnglishTitle] as List),
      arabicTitle: List<String>.from(map[fieldArabicTitle] as List),
      description: List<String>.from(map[fieldEnglishDescription] as List),
      arabicDescription: List<String>.from(map[fieldArabicDescription] as List),
      accessMangement: List<String>.from(map[fieldAccessMangement] as List),
      orientation: List<String>.from(map[fieldOrientation] as List),
      horizontalPadding: List<String>.from(map[fieldHorizontalPadding] as List),
      verticalPadding: List<String>.from(map[fieldVerticalPadding] as List),
      formStatus: List<String>.from(map[fieldFormStatus] as List),
      pages: List<PageModel>.from(
          (map[fieldPages] as List).map((x) => PageModel.fromMap(x))),
      watermark: WatermarkModel.fromMap(map[fieldWatermark]),
    );
  }
}
