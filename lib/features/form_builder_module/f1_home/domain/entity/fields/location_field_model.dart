import 'package:get/get.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/location_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a location field, including latitude, longitude, link hints, location type, alignment, and requirement status.

/// Represents the model for a location field
class LocationFieldModel extends FieldModel {
  /// Hint text for latitude
  String? hintLatitude;

  /// Hint text for longitude
  String? hintLongitude;

  /// Hint text for link
  String? hintLink;

  /// Type of the location (e.g., latitude and longitude)
  String locationType;

  /// Alignment of the location field
  String alignment;

  /// Flag to determine if the field is required
  bool isRequired;
  String title;

  /// Link of the answer
  String? linkLocationAnswer;

  /// Latitude of the answer
  String? latitudeLocationAnswer;

  /// Longitude of the answer
  String? longitudeLocationAnswer;

  /// Constructor for initializing the LocationFieldModel instance
  LocationFieldModel({
    required this.alignment,
    required this.isRequired,
    this.hintLink,
    required this.locationType,
    this.hintLongitude,
    this.hintLatitude,
    this.linkLocationAnswer,
    this.latitudeLocationAnswer,
    this.longitudeLocationAnswer,
    required this.title,
  }) : super(FormFieldType.location);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hint: locationType == LocationDropDown.link.name
          ? hintLink
          : '$hintLatitude, $hintLongitude',
      fieldType: FormFieldType.location.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: locationType,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: locationType == LocationDropDown.link.name
          ? linkLocationAnswer
          : '$latitudeLocationAnswer, $longitudeLocationAnswer',
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return LocationFieldModel(
      title: model.title ?? '',
      isRequired: model.isRequired!,
      alignment: model.alignment!.capitalize!,
      hintLink: model.hint ?? '',
      locationType: model.locationType!,
      hintLongitude: model.locationType == LocationDropDown.link.name
          ? null
          : model.hint?.split(',')[0],
      hintLatitude: model.locationType == LocationDropDown.link.name
          ? null
          : model.hint?.split(',')[1],
    );
  }

  /// Method to duplicate the location field model
  /// Returns a new instance of LocationFieldModel with the same properties
  @override
  duplicate() {
    LocationFieldModel newModel = LocationFieldModel(
      title: title,
      alignment: alignment,
      isRequired: isRequired,
      hintLink: hintLink,
      locationType: locationType,
      hintLongitude: hintLongitude,
      hintLatitude: hintLatitude,
    );
    return newModel;
  }

  @override
  LocationFieldController toController({bool isSetData = false}) {
    LocationFieldController controller = LocationFieldController();
    controller.title!.text = title;
    controller.hintLatitude?.text = hintLatitude ?? '';
    controller.hintLongitude?.text = hintLongitude ?? '';
    controller.hintLink?.text = hintLink ?? '';
    controller.isRequired = isRequired;
    controller.locationType = locationType;
    controller.alignment = alignment;
    if (isSetData) {
      controller.answerLatitude = latitudeLocationAnswer;
      controller.answerLongitude = longitudeLocationAnswer;
      controller.answerLink = linkLocationAnswer;
    }
    return controller;
  }
}
