// ***************************** FILE INFO ***************************** //
// File Name: hr_image_upload_field.dart
// Purpose: Renders direct image upload controls for HR document fields.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/custom/6-custom_button_with_svg.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Displays a direct image upload button or the selected document card.
class HrImageUploadField extends StatefulWidget {
  const HrImageUploadField({
    super.key,
    required this.label,
    required this.file,
    required this.onChanged,
    this.imageUrl,
    this.isReadOnly = false,
    this.isRequired = false,
  });

  final String label;
  final File? file;
  final String? imageUrl;
  final ValueChanged<File?> onChanged;
  final bool isReadOnly;
  final bool isRequired;

  @override
  State<HrImageUploadField> createState() => _HrImageUploadFieldState();
}

class _HrImageUploadFieldState extends State<HrImageUploadField> {
  static const _validExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif',
    'bmp',
    'heic',
  };

  int? _fileSizeBytes;

  @override
  void initState() {
    super.initState();
    _loadFileSize(widget.file);
  }

  @override
  void didUpdateWidget(covariant HrImageUploadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file?.path != widget.file?.path) {
      _loadFileSize(widget.file);
    }
  }

  /// Method Name: [_loadFileSize]
  ///
  /// Purpose: Loads local image metadata without blocking widget rendering.
  ///
  /// Parameters:
  /// - [file]: Local image whose byte size should be loaded.
  ///
  /// Returns: A future completed after the optional file size is stored.
  Future<void> _loadFileSize(File? file) async {
    if (file == null) {
      if (mounted) setState(() => _fileSizeBytes = null);
      return;
    }
    try {
      final size = await file.length();
      if (mounted && widget.file?.path == file.path) {
        setState(() => _fileSizeBytes = size);
      }
    } on FileSystemException {
      if (mounted && widget.file?.path == file.path) {
        setState(() => _fileSizeBytes = null);
      }
    }
  }

  /// Method Name: [_pickImage]
  ///
  /// Purpose: Picks and validates one image before sending it to the source.
  ///
  /// Returns: A future completed after selection, validation, or cancellation.
  Future<void> _pickImage(ValueChanged<File> onSelected) async {
    try {
      final selected = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      if (selected == null) return;

      final extension = selected.name.split('.').last.toLowerCase();
      if (!_validExtensions.contains(extension)) {
        _showUploadError();
        return;
      }

      final file = File(selected.path);
      if (!await file.exists()) {
        _showUploadError();
        return;
      }

      onSelected(file);
    } catch (_) {
      _showUploadError();
    }
  }

  /// Method Name: [_showUploadError]
  ///
  /// Purpose: Displays the localized image-upload failure message.
  ///
  /// Returns: No value; a snackbar is shown when the widget is mounted.
  void _showUploadError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).uploadFailed)),
    );
  }

  /// Method Name: [build]
  ///
  /// Purpose: Builds the upload control or selected image card.
  ///
  /// Parameters:
  /// - [context]: Build context used for localization and theme values.
  ///
  /// Returns: The rendered HR document upload field.
  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return FormField<File>(
      key: ValueKey('${widget.file?.path}:${widget.imageUrl}'),
      initialValue: widget.file,
      validator: widget.isRequired
          ? (value) =>
              _hasSelectedImage(value) ? null : localization.fieldRequired
          : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: StyleText.fontSize14Weight500,
          ),
          SizedBox(height: 6.h),
          if (!_hasSelectedImage(field.value))
            _buildUploadButton(
              localization,
              onSelected: (file) {
                field.didChange(file);
                widget.onChanged(file);
              },
            )
          else
            _buildSelectedCard(
              context,
              localization,
            ),
          if (field.errorText != null) ...[
            SizedBox(height: 4.h),
            Text(
              field.errorText!,
              style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Method Name: [_hasSelectedImage]
  ///
  /// Purpose: Reports whether the field has a local or persisted image value.
  ///
  /// Parameters:
  /// - [file]: Current local file tracked by the form field.
  ///
  /// Returns: Whether a selected image exists.
  bool _hasSelectedImage(File? file) {
    return file != null || (widget.imageUrl?.trim().isNotEmpty ?? false);
  }

  /// Method Name: [_buildUploadButton]
  ///
  /// Purpose: Provides direct access to the image picker for an empty slot.
  ///
  /// Parameters:
  /// - [localization]: Localized labels for the upload action.
  ///
  /// Returns: A primary-colored upload button.
  Widget _buildUploadButton(
    S localization, {
    required ValueChanged<File> onSelected,
  }) {
    final button = SizedBox(
      width: double.infinity,
      child: customButtonWithSvg(
        title: localization.upload,
        function: () => _pickImage(onSelected),
        textStyle: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.textButton,
        ),
        color: AppColors.primary,
        image: AppAssets.upload,
        widthImage: 18.sp,
        heightImage: 18.sp,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
        fixedRadius: 4.r,
      ),
    );

    return IgnorePointer(
      ignoring: widget.isReadOnly,
      child: SizedBox(
        width: double.infinity,
        child: Center(child: button),
      ),
    );
  }

  /// Method Name: [_buildSelectedCard]
  ///
  /// Purpose: Shows selected-file metadata for an uploaded image.
  ///
  /// Parameters:
  /// - [context]: Build context used for locale resolution.
  /// - [localization]: Localized date label.
  ///
  /// Returns: A card containing the temporary image thumbnail and metadata.
  Widget _buildSelectedCard(
    BuildContext context,
    S localization,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final uploadDate = DateFormat('dd MMM yyyy', locale).format(DateTime.now());
    final file = widget.file;
    final imageUrl = widget.imageUrl;
    final fileName = file == null
        ? Uri.tryParse(imageUrl ?? '')?.pathSegments.last
        : file.path.split(Platform.pathSeparator).last;
    final fileSize =
        _fileSizeBytes == null ? null : (_fileSizeBytes! / 1024).ceil();

    return Container(
      height: 60.sp,
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        children: [
          _buildImage(file: file, imageUrl: imageUrl),
          SizedBox(width: 8.sp),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fileName ?? localization.document,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize12Weight400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (fileSize != null)
                      Text(
                        '$fileSize KB',
                        style: StyleText.fontSize10Weight400.copyWith(color: AppColors.lightGrey),
                      ),
                    Spacer(),
                    Text(
                      '${localization.date}: ',
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.lightGrey),
                    ),
                    Text(
                      uploadDate,
                      style: StyleText.fontSize12Weight500,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Method Name: [_buildImage]
  ///
  /// Purpose: Resolves the local, remote, or placeholder image source.
  ///
  /// Parameters:
  /// - [file]: Optional local image selected by the user.
  /// - [imageUrl]: Optional remote image URL.
  ///
  /// Returns: The image widget for the selected source.
  Widget _buildImage({File? file, String? imageUrl}) {
    return SvgPicture.asset(
      "assets/icons_assets/main_icons_assets/image_placeholder_large.svg",
      width: 38.w,
      height: 38.h,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(AppColors.field, BlendMode.srcIn),
    );
  }
}
