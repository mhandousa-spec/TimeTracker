// ******************* FILE INFO *******************
// File Name: create_service_state
// Description: Create service state.
// Module: services_management_module / presentation/s4_bulk_upload_services/controller
// *************************************************

import 'dart:typed_data';
import 'dart:io';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/data/create_service_form_data.dart';

abstract class CreateServiceState {
  const CreateServiceState();
}


// 🔥 NEW: Draft saving in progress
class CreateServiceDraftSaving extends CreateServiceState {
  const CreateServiceDraftSaving();
}

class CreateServiceInitial extends CreateServiceState {
  const CreateServiceInitial();
}

class CreateServiceDraftSaved extends CreateServiceState {
  final String draftId;

  const CreateServiceDraftSaved({required this.draftId});

  @override
  List<Object?> get props => [draftId];
}

class CreateServiceLoading extends CreateServiceState {
  const CreateServiceLoading();
}

class CreateServiceLoaded extends CreateServiceState {
  final CreateServiceFormData formData;
  final File? selectedImage;
  final Uint8List? webImage;
  final bool isUploadingImage;
  final bool submitted;

  const CreateServiceLoaded({
    required this.formData,
    this.selectedImage,
    this.webImage,
    this.isUploadingImage = false,
    this.submitted = false,
  });



  /// ⚠️ [clearSelectedImage] / [clearWebImage] exist because `??` cannot
  /// express "set this back to null".
  ///
  /// Added 26/8/2026. `selectedImage: selectedImage ?? this.selectedImage`
  /// reads as though passing null clears the field; it does the opposite —
  /// null is precisely the value that falls through to the old one. So
  /// `CreateServiceCubit.removeImage()`, which passed
  /// `selectedImage: null, webImage: null`, kept both, and a locally picked
  /// image could not be removed however many times the user confirmed the
  /// dialog. Pass the flag to clear; the plain parameter still sets a value.
  CreateServiceLoaded copyWith({
    CreateServiceFormData? formData,
    File? selectedImage,
    Uint8List? webImage,
    bool clearSelectedImage = false,
    bool clearWebImage = false,
    bool? isUploadingImage,
    bool? submitted,
  }) {
    return CreateServiceLoaded(
      formData: formData ?? this.formData,
      selectedImage:
          clearSelectedImage ? null : (selectedImage ?? this.selectedImage),
      webImage: clearWebImage ? null : (webImage ?? this.webImage),
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      submitted: submitted ?? this.submitted,
    );
  }
}

class CreateServiceError extends CreateServiceState {
  final String message;
  const CreateServiceError(this.message);
}

class CreateServiceDuplicateName extends CreateServiceState {
  final String duplicateField;
  final String duplicateValue;
  final CreateServiceFormData? formData; // ✅ ADD THIS

  const CreateServiceDuplicateName({
    required this.duplicateField,
    required this.duplicateValue,
    this.formData, // ✅ ADD THIS
  });

  @override
  List<Object?> get props => [duplicateField, duplicateValue, formData]; // ✅ UPDATE THIS
}

class CreateServiceNavigateToProviders extends CreateServiceState {
  final String? docId;
  final CreateServiceFormData formData;

  const CreateServiceNavigateToProviders({
    required this.docId,
    required this.formData,
  });
}

class CreateServiceImageUploaded extends CreateServiceState {
  final String imageUrl;
  const CreateServiceImageUploaded(this.imageUrl);
}

class CreateServiceStatusChanged extends CreateServiceState {
  final bool isActive;
  const CreateServiceStatusChanged(this.isActive);
}
