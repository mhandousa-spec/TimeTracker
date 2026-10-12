/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: gallery_image_picker.dart
/// Purpose: Pick one image from the gallery for a change request.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE6-N02. `_pickImage` held the only try/catch on the edit
/// page that guarded something real — the picker throws a `PlatformException`
/// when the gallery permission is denied — but try is forbidden in
/// presentation/ui/ (§20/§21), so it belongs here. The catch was also empty:
/// a denied permission looked identical to the user tapping cancel. This
/// returns a result the caller can tell apart.

import 'dart:io';

import 'package:image_picker/image_picker.dart';

/// The outcome of one pick attempt.
enum ImagePickOutcome {
  /// The user chose a file.
  picked,

  /// The user backed out of the picker.
  cancelled,

  /// The picker itself failed — most often a denied gallery permission.
  failed,
}

class ImagePickResult {
  const ImagePickResult(this.outcome, [this.file]);

  final ImagePickOutcome outcome;
  final File? file;
}

class GalleryImagePicker {
  GalleryImagePicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Function Name: [pick]
  ///
  /// Purpose: Open the gallery and return the chosen file.
  ///
  /// The size and quality limits are the ones the edit page already used.
  Future<ImagePickResult> pick() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      return file == null
          ? const ImagePickResult(ImagePickOutcome.cancelled)
          : ImagePickResult(ImagePickOutcome.picked, File(file.path));
    } catch (_) {
      return const ImagePickResult(ImagePickOutcome.failed);
    }
  }
}
