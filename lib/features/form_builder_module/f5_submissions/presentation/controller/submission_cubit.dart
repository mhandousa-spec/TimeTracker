import 'dart:async';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/address_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/date_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/email_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/link_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/domain/use_case/send_response_use_case.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/controller/submission_state.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_digital_signature_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/attachment_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/check_box_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/drop_down_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/image_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/phone_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/radio_text_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/time_selector_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/domain/repo/response_repo.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';

// Date: 14/1/2025
// By: mohamed Mohy
// Last update: 21/1/2025

class FormSubmissionsCubit extends Cubit<SubmissionsState> {
  final ResponseRepo responseRepo;

  FormSubmissionsCubit({required this.responseRepo}) : super(SubmissionsInitial());

  late List<PageControllerModel> pages;

  // Form validation state (GlobalKey<FormState>) belongs to the page's
  // StatefulWidget, not the cubit (§16).

  bool isSubmitted = false;
  bool isReadOnly = false;
  bool _isSubmitting = false;  // ✅ Add submission lock

  // initializes the controller with a default page containing one row and one text field
  void init({required FormEntity model}) {
    isSubmitted = model.status == FormStatus.submissions;
    isReadOnly = model.status == FormStatus.submissions;
    _isSubmitting = false;  // ✅ Reset submission lock on init
    pages = [];

    for (var element in model.pages) {
      pages.add(element.toController(
          isSetData: model.status == FormStatus.submissions));
    }

    emit(SubmissionsLoaded(
      pages: pages,
      isSubmitted: isSubmitted,
      isReadOnly: isReadOnly,
      isSubmitting: false,  // ✅ Initially not submitting
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
    bool flag = false;

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
      if (numberSelected < controller.maximumSelection!.text.toEnglishNumber()) {  // ✅ ADDED '<'
        return true;
      }
    }
    return flag;
  }

  void changeCheckBoxValue(
      CheckboxOptions optionCheckBox,
      CheckBoxFieldController controller,
      ) {
    
    if (checkChangeCheckBoxValue(optionCheckBox, controller)) {
      optionCheckBox.value = !optionCheckBox.value;
      _emitLoadedState();
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
    File? file = await MediaPickerService().pickImageFile();
    if (file != null) {
      controller.attachmentEntity = AttachmentEntity.fromFile(file);
    } else {
      controller.attachmentEntity = null;
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
    if (file != null) {
      controller.attachmentEntity = AttachmentEntity.fromFile(file);
    } else {
      controller.attachmentEntity = null;
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
  /// (`GlobalKey<FormState>`) is performed by the page (§16). Returns `false`
  /// while a submission is already in flight to prevent double submits.
  bool prepareSubmit() {
    if (_isSubmitting) {
      return false;
    }
    isSubmitted = true;
    final bool isCustomValid = _checkCustomValidation();
    _emitLoadedState();
    return isCustomValid;
  }

  /// Runs the actual submission flow. The page calls this only after both
  /// [prepareSubmit] and the Form widget's validation have passed.
  ///
  /// CHANGED 1/9/2026 — this drove the dialogs by hand: it popped routes with
  /// `Navigator.of(context).pop()` from inside the callback (the confirm dialog
  /// was still open, so the pops were counting on an exact route stack), showed
  /// the success dialog BEFORE the response was inspected, and closed the flow
  /// on a 2-second `Timer` racing that dialog's own auto-close. A failure also
  /// emitted [SubmissionsError], and the page renders anything that is not
  /// [SubmissionsLoaded] as a spinner — so a rejected submission left the user
  /// on an endless loading screen with their answers gone.
  ///
  /// `AppDialogs.submitForm` (i.e. `CustomDialogManager.showDialogFlow`) owns
  /// the route stack now: it closes the confirm dialog itself, awaits the
  /// callback below, and only then shows the success dialog — and only when the
  /// callback returned true. So this method pops nothing, and a failure keeps
  /// the filled-in form on screen behind a message dialog.
  Future<void> submit(
      BuildContext context,
      FormEntity model,
      bool isEdit,
      HomeCubit homeCubit,
      ) async {
    // ✅ CRITICAL FIX: Prevent double submission
    if (_isSubmitting) {
      return;
    }

    // Snapshot the answers before the dialog opens.
    final FormEntity newForm = createFormHomeModel(model);

    await AppDialogs.submitForm(
      context,
      () async {
        // Runs after the confirm dialog has closed. Must NOT pop anything, and
        // must report whether the response actually reached the server.
        _isSubmitting = true;
        _emitLoadedState();

        try {
          final response = await SendResponseUseCase(responseRepo: responseRepo)
              .execute(model: newForm, isEdit: isEdit);

          return response.fold(
            (failure) {
              _isSubmitting = false; // ✅ Unlock on failure
              _emitLoadedState();
              if (context.mounted) {
                AppDialogs.submitFormFailed(context, failure.message);
              }
              return false;
            },
            (r) {
              homeCubit.getForms();
              return true;
            },
          );
        } catch (e) {
          _isSubmitting = false; // ✅ Unlock on exception
          _emitLoadedState();
          if (context.mounted) {
            AppDialogs.submitFormFailed(context, e.toString());
          }
          return false;
        }
      },
      onSuccessComplete: () {
        // The success dialog has auto-closed by now, so this is the one safe
        // place to leave the screen.
        _isSubmitting = false; // ✅ Unlock after success
        _emitLoadedState();
        if (context.mounted) {
          context.popToFirst();
        }
      },
    );
  }

  FormEntity createFormHomeModel(FormEntity oldModel) {
    FormEntity formModel = FormEntity(
      personEntity: oldModel.personEntity,
      pages: [],
      id: oldModel.id,
      status: oldModel.status,
      formHeadModel: oldModel.formHeadModel,
      createDate: oldModel.createDate,
      requestedBy: oldModel.requestedBy,
    );
    for (var element in pages) {
      formModel.pages.add(element.toModel(isSetData: true));
    }

    return formModel;
  }

  /// True when every REQUIRED field has an answer — Submit is locked until
  /// then (form bug report #16/#22).
  bool get allRequiredAnswered {
    for (var page in pages) {
      for (var row in page.rows) {
        for (var controllerModel in row.controllers) {
          if (controllerModel.getIsRequired() &&
              !controllerModel.isAnswerFilled()) {
            return false;
          }
        }
      }
    }
    return true;
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

  void editClicked() {
    isReadOnly = false;
    _emitLoadedState();
  }

  void changeTextResultValue({
    required TextFieldController controller,
    required String value,
  }) {
    controller.answer = value;
  }

  void changeEmailResultValue({
    required EmailFieldController controller,
    required String value,
  }) {
    controller.answer = value;
  }

  void changePhoneResultValue({
    required PhoneFieldController controller,
    required String value,
  }) {
    controller.phoneAnswer = value;
  }

  void changeLinkResultValue({
    required LinkFieldController controller,
    required String value,
  }) {
    controller.answer = value;
  }

  void changeDateResultValue({
    required DateFieldController controller,
    required DateTime value,
  }) {
    controller.answerDate = value;
  }

  void changeAddressResultValue({
    required AddressFieldController controller,
    required String value,
    required int index,
  }) {
    if (controller.answers == null || controller.answers!.isEmpty) {
      controller.answers = List.generate(
        controller.hints!.length,
            (index) => '',
      );
    }
    controller.answers![index] = value;
  }

  void _emitLoadedState() {
    if (state is SubmissionsLoaded) {
      emit(SubmissionsLoaded(
        pages: pages,
        isSubmitted: isSubmitted,
        isReadOnly: isReadOnly,
        isSubmitting: _isSubmitting,  // ✅ Pass submission lock state to UI
      ));
    }
  }
}