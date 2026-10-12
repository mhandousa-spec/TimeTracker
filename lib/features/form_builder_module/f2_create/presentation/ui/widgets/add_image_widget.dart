import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
// CHANGED: the avatar, the placeholder, the camera badge and the picking were
// all hand-rolled here. They are now `CustomImagePicker`, the app's own
// component, which already does the same job everywhere else.
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';

class AddImageWidget extends StatelessWidget {
  const AddImageWidget({super.key, this.isReadOnly = false});

  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
      builder: (context, state) {
        if (state is! CreateFormHeadLoaded) {
          return const SizedBox.shrink();
        }

        final String? cover = state.cover;

        // `CreateFormHeadLoaded.cover` is "the cover URL or path" — a local
        // path straight after a pick, but a SERVER URL when an existing form
        // is opened for editing (`FormEntity` fills it from the form's image
        // list). The old code wrapped it in `FileImage(File(cover))` either
        // way, so a saved form's cover never actually rendered: there is no
        // file at that path on the device. `CustomImagePicker` takes the two
        // through separate slots, so this now splits them.
        final bool isRemote =
            cover != null && (cover.startsWith('http://') || cover.startsWith('https://'));

        return CustomImagePicker(
          // Figma: 65px diameter.
          radius: 32.5.sp,
          badgeRadius: 12.sp,
          // The component drops the badge entirely when read-only rather than
          // leaving a camera icon that still looks tappable.
          readOnly: isReadOnly,
          imageFile: (cover == null || isRemote) ? null : File(cover),
          imageUrl: isRemote ? cover : null,
          placeholderSvg:
              'assets/icons_assets/main_icons_assets/image_placeholder_large.svg',
          badgeSvg: AppAssets.camera,
          onImagePicked: (File file) =>
              context.read<CreateFormHeadCubit>().setCoverImage(file),
        );
      },
    );
  }
}
