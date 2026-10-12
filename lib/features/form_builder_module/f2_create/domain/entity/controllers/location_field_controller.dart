import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/location_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/location_drop_down.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
class LocationFieldController extends FieldController {
  /// Controllers for hint text in latitude, longitude, and link fields
  TextEditingController? hintLatitude, hintLongitude, hintLink;

  /// Type of location (e.g., latitude and longitude)
  String? locationType;

  TextEditingController? title;

  /// Alignment of the location field
  String? alignment;

  /// Flag to determine if the field is required
  bool? isRequired;

  String? answerLatitude, answerLongitude, answerLink;

  /// Constructor initializing the FieldController with location type
  LocationFieldController() : super(FormFieldType.location) {
    init();
  }

  /// Initializes the hint text controllers and other properties
  @override
  init() {
    hintLatitude = TextEditingController(text: 'Latitude');
    hintLongitude = TextEditingController(text: 'Longitude');
    hintLink = TextEditingController(text: 'Link');
    title = TextEditingController();

    locationType = LocationDropDown.latitudeAndLongitude.name;
    alignment = AlignmentEnum.center.name;
    isRequired = false;
    return super.init();
  }

  /// Disposes the hint text controllers
  @override
  dispose() {
    hintLatitude!.dispose();
    hintLongitude!.dispose();
    hintLink!.dispose();
    title!.dispose();
    return super.dispose();
  }

  /// Prints the details of the location field model
  @override
  printModel() {

    
    return super.printModel();
  }

  /// Duplicates the current controller instance
  @override
  duplicate() {
    var newController = LocationFieldController();
    newController.title?.text = title?.text ?? '';
    newController.isRequired = isRequired;
    newController.hintLatitude?.text = hintLatitude?.text ?? '';
    newController.hintLongitude?.text = hintLongitude?.text ?? '';
    newController.hintLink?.text = hintLink?.text ?? '';
    newController.locationType = locationType;
    newController.alignment = alignment;
    return newController;
  }

  @override

  /// Converts the location field controller to a model
  LocationFieldModel toModel({bool isSetAnswer = false}) {
    return LocationFieldModel(
      title: title!.text,
      hintLatitude: hintLatitude?.text ?? '',
      hintLongitude: hintLongitude?.text ?? '',
      hintLink: hintLink?.text ?? '',
      locationType: locationType!,
      alignment: alignment!,
      isRequired: isRequired!,
      latitudeLocationAnswer: isSetAnswer ? answerLatitude : null,
      longitudeLocationAnswer: isSetAnswer ? answerLongitude : null,
      linkLocationAnswer: isSetAnswer ? answerLink : null,
    );
  }
}
