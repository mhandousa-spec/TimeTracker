/// Module: messaging / groups / presentation/ui/widgets/group_image_editor.dart
/// ************************* FILE INFO *************************** ///
/// File Name: group_image_editor.dart
/// Purpose: Group image editor — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025
/// Updated: 2/9/2026 - now a thin wrapper over CustomImagePicker.
///
/// REWRITTEN 2/9/2026. This used to hand-roll the whole control: a CircleAvatar
/// with a ClipOval, a three-way `Image.file` / `Image.network` / placeholder
/// chain, a camera badge in a Stack, and a direct MediaPickerService call. All
/// of that is what `core/custom/46-custom_image_picker.dart` already does —
/// including the bits this copy did NOT: file-format validation, an error
/// callback, and web-safe bytes preview.
///
/// So it now just wires the group's image state to [CustomImagePicker] and
/// keeps its own job, which is telling GroupsCubit about the new file.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import '../../controller/groups_controller.dart';

class GroupImageEditor extends StatefulWidget {
  const GroupImageEditor({super.key});

  @override
  State<GroupImageEditor> createState() => _GroupImageEditorState();
}

class _GroupImageEditorState extends State<GroupImageEditor> {
  @override
  Widget build(BuildContext context) {
    final controller = context.read<GroupsCubit>();

    // The stored photo only applies when EDITING a group. While creating one
    // there is nothing on the server yet, so the picker falls through to its
    // placeholder.
    final String? storedImage = controller.isCreateGroup
        ? null
        : controller.selectedGroup?.groupImage;

    return CustomImagePicker(
      // A freshly picked file wins over the stored URL — CustomImagePicker
      // already ranks them that way.
      imageFile: controller.groupImage,
      imageUrl: storedImage,
      radius: 32.r,
      badgeRadius: 12.r,
      // Keep the camera glyph this control has always used; the picker's own
      // default points at a different asset.
      badgeSvg: AppAssets.camera,
      onImagePicked: (file) {
        controller.setGroupImage(file);
        // GroupsCubit holds the image outside its emitted state, so this
        // widget still has to rebuild itself to show it.
        setState(() {});
      },
    );
  }
}
