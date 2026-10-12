import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
class AddImageWidget extends StatelessWidget {
  const AddImageWidget({this.isPickerEnabled = true, super.key});

  final bool isPickerEnabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormsGroupCubit, FormsGroupState>(
      builder: (context, state) {
        if (state is! FormsGroupLoaded) {
          return _buildPlaceholder(context);
        }

        return InkWell(
          onTap: isPickerEnabled
              ? () => context.read<FormsGroupCubit>().pickGroupImage()
              : null,
          child: Stack(
            children: [
              _buildCoverImage(context, state),
              _buildCameraIcon(context),
            ],
          ),
        );
      },
    );
  }

  /// Build placeholder when state is not loaded
  Widget _buildPlaceholder(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.grey,
          radius: 32.5,
          child: SvgPicture.asset(AppAssets.image),
        ),
        _buildCameraIcon(context),
      ],
    );
  }

  /// Build cover image or placeholder
  Widget _buildCoverImage(BuildContext context, FormsGroupLoaded state) {
    return CircleAvatar(
      backgroundColor: AppColors.grey,
      radius: 32.5,
      backgroundImage: _getCoverImage(state),
      child: !_hasImage(state) ? SvgPicture.asset(AppAssets.image) : null,
    );
  }

  /// Build camera icon overlay
  Widget _buildCameraIcon(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: CircleAvatar(
        backgroundColor: AppColors.primary,
        radius: 12,
        child: SvgPicture.asset(AppAssets.camera),
      ),
    );
  }

  /// Get the appropriate image provider based on state
  ImageProvider? _getCoverImage(FormsGroupLoaded state) {
    // Priority 1: New image picked by user
    if (state.groupImage != null) {
      return FileImage(state.groupImage!);
    }

    if (state.selectedGroup != null && state.selectedGroup!.groupImage != null) {
      return NetworkImage(state.selectedGroup!.groupImage!);
    }

    // Priority 3: Default placeholder
    return appImageProvider(AppAssets.image) as ImageProvider;
  }

  /// Check if group has an image
  bool _hasImage(FormsGroupLoaded state) {
    if (state.groupImage != null) {
      return true;
    }

    if (state.selectedGroup != null && state.selectedGroup!.groupImage != null) {
      return true;
    }

    return false;
  }
}