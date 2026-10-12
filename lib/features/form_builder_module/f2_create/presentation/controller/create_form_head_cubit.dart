import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/orientation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';

String convertArabicNumeralsToWestern(String input) {
  const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  const westernNumerals = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  String result = input;
  for (int i = 0; i < arabicNumerals.length; i++) {
    result = result.replaceAll(arabicNumerals[i], westernNumerals[i]);
  }
  return result;
}

class CreateFormHeadCubit extends Cubit<CreateFormHeadState> {
  late GlobalKey<FormState> formKey;
  Timer? _paddingDebounceTimer; // ✅ Add debounce timer

  CreateFormHeadCubit() : super(CreateFormHeadInitial());

  // ✅ Debounced padding update - only emits state after user stops typing
  void _debouncedPaddingUpdate() {
    _paddingDebounceTimer?.cancel();
    _paddingDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (state is CreateFormHeadLoaded) {
        final currentState = state as CreateFormHeadLoaded;
        emit(currentState.copyWith());
      }
    });
  }

  void updateHorizontalPadding(String value) {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;
    // ✅ Just update the controller text, don't emit immediately
    currentState.horizontalPaddingController.text = value;
    // ✅ Debounce the state emission
    _debouncedPaddingUpdate();
  }

  void updateVerticalPadding(String value) {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;
    // ✅ Just update the controller text, don't emit immediately
    currentState.verticalPaddingController.text = value;
    // ✅ Debounce the state emission
    _debouncedPaddingUpdate();
  }

  void init({FormEntity? editFormModel}) {

    formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final arTitleController = TextEditingController();
    final arDescriptionController = TextEditingController();
    final horizontalPaddingController = TextEditingController();
    final verticalPaddingController = TextEditingController();
    final watermarkOpacityController = TextEditingController();
    final watermarkSizeController = TextEditingController();

    String? cover;
    String? watermark;
    String? accessManagement;  // ✅ Changed to null - shows hint for new forms
    String? orientation;        // ✅ Changed to null - shows hint for new forms

    if (editFormModel != null) {

      titleController.text = editFormModel.formHeadModel.title ?? '';
      descriptionController.text = editFormModel.formHeadModel.description ?? '';
      arTitleController.text = editFormModel.formHeadModel.arTitle ?? '';
      arDescriptionController.text = editFormModel.formHeadModel.arDescription ?? '';

      horizontalPaddingController.text = editFormModel.formHeadModel.horizontalPadding.toString();
      verticalPaddingController.text = editFormModel.formHeadModel.verticalPadding.toString();
      watermarkOpacityController.text = editFormModel.formHeadModel.watermarkOpacity.toString();
      watermarkSizeController.text = editFormModel.formHeadModel.watermarkSize.toString();

      cover = editFormModel.formHeadModel.cover;
      watermark = editFormModel.formHeadModel.watermark;
      accessManagement = editFormModel.formHeadModel.accessManagement;  // ✅ Only set when editing
      orientation = editFormModel.formHeadModel.orientation;             // ✅ Only set when editing

    } else {
      
    }

    emit(CreateFormHeadLoaded(
      titleController: titleController,
      descriptionController: descriptionController,
      arTitleController: arTitleController,
      arDescriptionController: arDescriptionController,
      horizontalPaddingController: horizontalPaddingController,
      verticalPaddingController: verticalPaddingController,
      watermarkOpacityController: watermarkOpacityController,
      watermarkSizeController: watermarkSizeController,
      cover: cover,
      watermark: watermark,
      accessManagement: accessManagement,  // ✅ null for new forms, value for editing
      orientation: orientation,             // ✅ null for new forms, value for editing
    ));

  }

  void updateOrientation(String orientation) {

    if (state is! CreateFormHeadLoaded) {
      
      return;
    }

    final currentState = state as CreateFormHeadLoaded;
    
    emit(currentState.copyWith(orientation: orientation));
    
  }

  void updateAccessManagement(String accessManagement) {

    

    if (state is! CreateFormHeadLoaded) {

      return;
    }

    final currentState = state as CreateFormHeadLoaded;

    // Check what type of access management

      // ✅ FIXED
          // ✅ FIXED

    // Just update the state - the dialog will be shown when clicking publish
    emit(currentState.copyWith(accessManagement: accessManagement));

  }

  void updateWatermarkOpacity(String opacity) {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;
    currentState.watermarkOpacityController.text = opacity;
    emit(currentState.copyWith(
      watermarkOpacityController: currentState.watermarkOpacityController,
    ));
  }

  void updateWatermarkSize(String size) {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;
    currentState.watermarkSizeController.text = size;
    emit(currentState.copyWith(
      watermarkSizeController: currentState.watermarkSizeController,
    ));
  }

  /// Stores an already-picked cover image.
  ///
  /// ADDED: `AddImageWidget` now renders `CustomImagePicker`
  /// (`46-custom_image_picker.dart`), which owns the picking itself — it runs
  /// the format and decode checks and then hands back a validated [File] — so
  /// the widget needs a way to store a result rather than a way to start a
  /// pick. [pickCoverImage] is the older flow that does both at once; it has
  /// no caller left in this module.
  void setCoverImage(File file) {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;

    emit(currentState.copyWith(cover: file.path));
  }

  Future<void> pickCoverImage() async {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;

    final file = await MediaPickerService().pickImage(fromCamera: false);

    if (file != null) {

      emit(currentState.copyWith(cover: file.path));
    }
  }

  Future<void> pickWatermarkImage() async {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;

    final file = await MediaPickerService().pickImage(fromCamera: false);

    if (file != null) {
      
      emit(currentState.copyWith(watermark: file.path));
    }
  }

  void removeCoverImage() {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;
    
    emit(currentState.copyWith(clearCover: true));
  }

  void removeWatermarkImage() {
    if (state is! CreateFormHeadLoaded) return;
    final currentState = state as CreateFormHeadLoaded;
    
    emit(currentState.copyWith(clearWatermark: true));
  }

  FormHeadData createFormHeadModel() {

    if (state is! CreateFormHeadLoaded) {
      
      throw Exception('Cannot create form head model - state not loaded');
    }

    final currentState = state as CreateFormHeadLoaded;

    // ✅ Convert Arabic numerals before parsing
    final horizontalPaddingText = convertArabicNumeralsToWestern(
        currentState.horizontalPaddingController.text
    );
    final verticalPaddingText = convertArabicNumeralsToWestern(
        currentState.verticalPaddingController.text
    );
    final watermarkOpacityText = convertArabicNumeralsToWestern(
        currentState.watermarkOpacityController.text
    );
    final watermarkSizeText = convertArabicNumeralsToWestern(
        currentState.watermarkSizeController.text
    );

    

    

    

    

    final formHeadData = FormHeadData(
      title: currentState.titleController.text,
      description: currentState.descriptionController.text,
      arTitle: currentState.arTitleController.text,
      arDescription: currentState.arDescriptionController.text,
      cover: currentState.cover,
      watermark: currentState.watermark,
      // These two defaults are STABLE stored values, not display text — see the
      // note on AccessManagementExtension.name.
      accessManagement:
          currentState.accessManagement ?? AccessManagement.openAccess.name,
      orientation: currentState.orientation ?? OrientationEnum.portrait.name,
      horizontalPadding: double.tryParse(horizontalPaddingText) ?? 16.0,
      verticalPadding: double.tryParse(verticalPaddingText) ?? 16.0,
      watermarkOpacity: int.tryParse(watermarkOpacityText) ?? 50,
      watermarkSize: int.tryParse(watermarkSizeText) ?? 100,
    );

    return formHeadData;
  }

  bool validateForm() {
    final isValid = formKey.currentState?.validate() ?? false;
    
    return isValid;
  }

  void resetController() {

    if (state is CreateFormHeadLoaded) {
      final currentState = state as CreateFormHeadLoaded;
      currentState.titleController.clear();
      currentState.descriptionController.clear();
      currentState.arTitleController.clear();
      currentState.arDescriptionController.clear();
      currentState.horizontalPaddingController.clear();
      currentState.verticalPaddingController.clear();
      currentState.watermarkOpacityController.clear();
      currentState.watermarkSizeController.clear();
    }

    emit(CreateFormHeadInitial());
  }

  @override
  Future<void> close() {
    
    _paddingDebounceTimer?.cancel(); // ✅ Clean up timer

    if (state is CreateFormHeadLoaded) {
      final currentState = state as CreateFormHeadLoaded;
      currentState.titleController.dispose();
      currentState.descriptionController.dispose();
      currentState.arTitleController.dispose();
      currentState.arDescriptionController.dispose();
      currentState.horizontalPaddingController.dispose();
      currentState.verticalPaddingController.dispose();
      currentState.watermarkOpacityController.dispose();
      currentState.watermarkSizeController.dispose();
    }
    return super.close();
  }
}