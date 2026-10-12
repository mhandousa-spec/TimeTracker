import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart'
   ;
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_state.dart';

// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 10/1/2026 - Fixed state emission with timestamp

class FillOutCubit extends Cubit<FillOutState> {
  FillOutCubit() : super(FillOutInitial());

  late List<PageControllerModel> pages;

  // Form state (GlobalKey<FormState>) belongs to the page's StatefulWidget,
  // not the cubit (§16) — the cubit only holds business state.

  bool isSubmitted = false;

  // Initializes the cubit with a form model
  void init({required FormEntity model}) {
    isSubmitted = false;
    pages = [];

    for (var element in model.pages) {
      pages.add(element.toController());
    }

    emit(FillOutLoaded(
      pages: pages,
      isSubmitted: isSubmitted,
    ));
  }

  // Cleans up resources by disposing all controllers in the form hierarchy
  void dispose() {
    for (var page in pages) {
      for (var row in page.rows) {
        row.numOfColumn!.dispose();
        for (var controllerModel in row.controllers) {
          controllerModel.dispose();
        }
      }
    }
  }

  // Updates dropdown selection value
  void changeDropResultValue({
    required DropDownFieldController controller,
    required String value,
  }) {
    controller.currentValue = value;
    _emitLoadedState();
  }

  void changeRadioValue({
    required RadioFieldController controller,
    required String value,
  }) {
    controller.selectedRadio = value;
    _emitLoadedState();
  }

  Future<void> changeImage({
    required ImageFieldController controller,
    required int imageIndex,
  }) async {
    controller.images[imageIndex] = await MediaPickerService().pickImageFile();
    if (controller.images[imageIndex] != null) {
      controller.imagesLink![imageIndex] = controller.images[imageIndex]?.path;
    }
    _emitLoadedState();
  }

  Future<void> selectCountry({
    required PhoneFieldController controller,
    required Country country,
  }) async {
    controller.currentCountry = country.countryCode;
    _emitLoadedState();
  }

  bool checkChangeCheckBoxValue(
      CheckboxOptions optionCheckBox,
      CheckBoxFieldController controller,
      ) {
    if (optionCheckBox.value == true ||
        controller.maximumSelection?.text.toEnglishNumber() == 0) {
      return true;
    } else {
      int numberSelected = 0;
      for (var element in controller.options) {
        if (element.value) {
          numberSelected++;
        }
      }
      if (numberSelected < controller.maximumSelection!.text.toEnglishNumber()) {
        return true;
      }
    }
    return false;
  }

  void changeCheckBoxValue(
      CheckboxOptions optionCheckBox,
      CheckBoxFieldController controller,
      ) {

    

    if (checkChangeCheckBoxValue(optionCheckBox, controller)) {
      optionCheckBox.value = !optionCheckBox.value;

      _emitLoadedState();
    } else {
      
    }
  }

  void onTimeClicked({
    TimeOfDay? value,
    required TimeSelectorFieldController controller,
  }) {
    if (value != null) {
      String formattedTime = FormDateTimeHelper.formatTime(
          FormDateTimeHelper.formatTimeOfDayToDateTime(value, null));
      controller.time = formattedTime.split(" ")[0];
      controller.amOrPM = formattedTime.split(" ")[1];
      _emitLoadedState();
    }
  }

  void onTimeAmClicked({required TimeSelectorFieldController controller}) {
    if (controller.amOrPM == "AM") {
      controller.amOrPM = 'PM';
      _emitLoadedState();
      return;
    }
    controller.amOrPM = 'AM';
    _emitLoadedState();
  }

  void changeRadioTextValue({
    required RadioTextFieldController controller,
    required String value,
  }) {
    controller.selectedRadio = value;
    _emitLoadedState();
  }

  Future<void> selectAttachment({
    required AttachmentFieldController controller,
  }) async {
    File? file = await MediaPickerService().pickAnyFileAsFile();
    if (file == null) {
      controller.attachmentEntity = null;
    } else {
      controller.attachmentEntity = AttachmentEntity.fromFile(file);
    }
    _emitLoadedState();
  }

  Future<void> removeAttachment({
    required AttachmentFieldController controller,
  }) async {
    controller.attachmentEntity = null;
    _emitLoadedState();
  }

  Future<void> selectSignature({
    required AttachmentDigitalSignatureFieldController controller,
  }) async {
    File? file = await MediaPickerService().pickImageFile();
    if (file == null) {
      controller.attachmentEntity = null;
    } else {
      controller.attachmentEntity = AttachmentEntity.fromFile(file);
    }
    _emitLoadedState();
  }

  Future<void> removeSignature({
    required AttachmentDigitalSignatureFieldController controller,
  }) async {
    controller.attachmentEntity = null;
    _emitLoadedState();
  }

  /// Marks the form as submitted and runs custom (non-Form) validation.
  ///
  /// Returns `true` when custom validation passes. Form-widget validation
  /// (`GlobalKey<FormState>`) and navigation are handled by the page — the
  /// cubit no longer touches BuildContext or navigation (§16).
  bool prepareSubmit() {
    isSubmitted = true;
    final bool isCustomValid = _checkCustomValidation();
    _emitLoadedState();
    return isCustomValid;
  }

  bool _checkCustomValidation() {
    for (var page in pages) {
      for (var row in page.rows) {
        for (var controllerModel in row.controllers) {
          if (controllerModel.getIsValidated() == false) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // ✅ CRITICAL FIX: Must pass timestamp to force state change
  void _emitLoadedState() {
    if (state is FillOutLoaded) {
      final newTimestamp = DateTime.now();
      
      emit(FillOutLoaded(
        pages: pages,
        isSubmitted: isSubmitted,
        timestamp: newTimestamp, // ✅ THIS IS CRITICAL
      ));
      
    } else {
      
    }
  }
}