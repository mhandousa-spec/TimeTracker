/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: image_picker_cubit.dart
/// Purpose: Declares `ImagePickerState`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// ******************* FILE INFO *******************
// File Name: image_picker_cubit
// Description: Cubit wrapper around MediaPickerService that holds the most
//              recently picked image as state, for screens that need to pick
//              once and read the result later.
// Module: core / services
// *************************************************
//
// Originally messaging/core/packages/image_picker. Restored here because it has
// no messaging dependencies. Picking is delegated to MediaPickerService rather
// than touching ImagePicker directly (§16 / §20 / §21).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;

import 'package:knowticed_plus/core/services/media_picker_service.dart';

/// State class
class ImagePickerState {
  final File? pickedFile;
  final Image? pickedImage;
  final bool isPicking;
  final String? error;

  ImagePickerState({
    this.pickedFile,
    this.pickedImage,
    this.isPicking = false,
    this.error,
  });

  ImagePickerState copyWith({
    File? Function()? pickedFile,
    Image? Function()? pickedImage,
    bool? isPicking,
    String? Function()? error,
  }) {
    return ImagePickerState(
      pickedFile: pickedFile != null ? pickedFile() : this.pickedFile,
      pickedImage: pickedImage != null ? pickedImage() : this.pickedImage,
      isPicking: isPicking ?? this.isPicking,
      error: error != null ? error() : this.error,
    );
  }
}

/// Cubit
class ImagePickerCubit extends Cubit<ImagePickerState> {
  final MediaPickerService _picker = MediaPickerService();

  ImagePickerCubit() : super(ImagePickerState());

  /// Method Name: takeImage
  /// Purpose: Take image from camera
  Future<void> takeImage([
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  ]) =>
      pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

  /// Method Name: uploadImage
  /// Purpose: Pick image from gallery
  Future<void> uploadImage(double maxWidth, double maxHeight) => pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

  /// Method Name: pickImage
  /// Purpose: Generic method to pick image from either source
  Future<void> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    emit(state.copyWith(isPicking: true, error: () => null));

    try {
      String? path;
      if (source == ImageSource.camera) {
        final picked = await _picker.pickImage(
          fromCamera: true,
          imageQuality: imageQuality ?? 100,
        );
        path = picked?.path;
      } else {
        final picked = await _picker.pickGalleryImage(
          maxWidth: maxWidth ?? 1024,
          maxHeight: maxHeight ?? 1024,
          imageQuality: imageQuality ?? 80,
        );
        path = picked?.path;
      }

      if (path == null) {
        emit(state.copyWith(
          isPicking: false,
          error: () => 'No image selected',
        ));
        return;
      }

      final file = File(path);
      emit(state.copyWith(
        pickedFile: () => file,
        pickedImage: () => Image.file(file),
        isPicking: false,
        error: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isPicking: false,
        error: () => 'Failed to pick image. Please try again.',
      ));
    }
  }

  /// Method Name: clearPickedImage
  /// Purpose: Clear the picked image
  void clearPickedImage() {
    emit(state.copyWith(
      pickedFile: () => null,
      pickedImage: () => null,
      error: () => null,
    ));
  }

  /// Method Name: showImageOptionsDialog
  /// Purpose: Show dialog to choose camera or gallery
  Future<void> showImageOptionsDialog({
    required BuildContext context,
    String? title,
    TextStyle? titleStyle,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title ?? 'Choose Image Source',
            style: titleStyle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(dialogContext).pop();
                  await takeImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.of(dialogContext).pop();
                  await uploadImage(1920, 1080);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: () => null));
  }

  /// Check if an image is picked
  bool get hasPickedImage => state.pickedFile != null;
}
