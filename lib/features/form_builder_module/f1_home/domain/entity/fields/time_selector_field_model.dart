import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/column_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';

// Date: 21/1/2025
// By: Mohamed Mohy
// Last update: 22/1/2025
// Objectives: Represents the model for a time selector field, including title, hint, and requirement status.

/// Represents the model for a time selector field
class TimeSelectorFieldModel extends FieldModel {
  String? time, amOrPm;

  /// Title of the time selector field
  String? title;

  /// Flag to determine if the field is required
  bool? isRequired;

  /// Constructor for initializing the TimeSelectorFieldModel instance
  TimeSelectorFieldModel({
    this.time,
    this.amOrPm,
    this.isRequired,
    this.title,
  }) : super(FormFieldType.timeSelector);
  @override
  ColumnModel toModel() {
    return ColumnModel(
      title: title,
      alignment: null,
      isRequired: isRequired,
      hint: null,
      fieldType: FormFieldType.timeSelector.name.toLowerCase(),
      arrangement: null,
      options: null,
      locationType: null,
      limitation: null,
      textSize: null,
      isBold: null,
      isItalic: null,
      isUnderLine: null,
      color: null,
      maxSelection: null,
      response: time == null ? null : '$time, $amOrPm',
    );
  }

  static FieldModel fromColumnModel(ColumnModel model) {
    return TimeSelectorFieldModel(
      title: model.title,
      isRequired: model.isRequired,
      time: model.response?.split(',').first,
      amOrPm: model.response?.split(',').last,
    );
  }

  /// Method to duplicate the time selector field model
  /// Returns a new instance of TimeSelectorFieldModel with the same properties
  @override
  duplicate() {
    TimeSelectorFieldModel newModel = TimeSelectorFieldModel(
      amOrPm: amOrPm,
      time: time,
      isRequired: isRequired,
      title: title,
    );
    return newModel;
  }

  @override
  TimeSelectorFieldController toController({bool isSetData = false}) {
    TimeSelectorFieldController controller = TimeSelectorFieldController();

    controller.isRequired = isRequired;
    controller.amOrPM = amOrPm ?? 'AM';
    controller.time = time;
    controller.title!.text = title ?? '';

    return controller;
  }
}
