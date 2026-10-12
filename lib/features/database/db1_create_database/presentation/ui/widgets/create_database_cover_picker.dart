/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_cover_picker.dart
/// Purpose: Declares `CreateDatabaseCoverPicker`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The 65x65 avatar with the yellow camera badge at the top of the card
/// (Figma `Group 1000004310`, node 7398:6198).
///
/// This is a thin wrapper over `core/custom/46-custom_image_picker.dart` —
/// it exists only to pin the two radii to the Figma numbers and to keep the
/// error path (a rejected file) going through the cubit instead of a raw
/// SnackBar. No picking logic is duplicated here.

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';

class CreateDatabaseCoverPicker extends StatelessWidget {
  const CreateDatabaseCoverPicker({
    super.key,
    required this.metrics,
    required this.onPicked,
    this.imageFile,
    this.onError,
  });

  final CreateDatabaseMetrics metrics;
  final ValueChanged<File> onPicked;
  final File? imageFile;
  final ValueChanged<String>? onError;

  @override
  Widget build(BuildContext context) {
    return Align(
      // The picker sits at the leading edge of the card, which flips with the
      // locale — left in English, right in Arabic. `centerStart` rather than
      // `centerLeft` is what makes that automatic.
      alignment: AlignmentDirectional.centerStart,
      child: CustomImagePicker(
        imageFile: imageFile,
        onImagePicked: onPicked,
        onError: onError,
        radius: metrics.avatarRadius,
        badgeRadius: metrics.badgeRadius,
        // Defaults already point at the two assets the Figma uses
        // (image_photo_rounded.svg placeholder, camera.svg badge); named here
        // so a change to the shared defaults cannot silently redesign this
        // screen.
        placeholderSvg:
            'assets/icons_assets/main_icons_assets/image_photo_rounded.svg',
        badgeSvg: 'assets/icons_assets/messaging_assets/camera.svg',
      ),
    );
  }
}
