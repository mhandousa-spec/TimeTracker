
import 'package:get/get.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/attachment_entity.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
// Date: 14/1/2025
// By: Mohamed Mohy
// Last update: 18/1/2025
// Objectives:  A widget for displaying the uploaded image with its details.

class AttachmentUploadedWidget extends StatelessWidget {
  AttachmentUploadedWidget(
      {super.key,
      required this.attachmentEntity,
      this.onCloseTap,
      this.isReadOnly = false});

  /// The uploaded image file.
  AttachmentEntity attachmentEntity;
  bool isReadOnly;
  final void Function()? onCloseTap;

  @override
  Widget build(BuildContext context) {
    // Initialize the controller for handling actions.

    // Extract metadata about the file.

    final String formattedDate = _getFormattedDate();

    return _buildContainer(attachmentEntity, formattedDate, !ContextExtension(context).isTablett);
  }

  /// Extracts the file name from the file path.
  String _getFileName(File file) {
    String filePath = file.path;
    if (filePath.contains('/')) {
      return filePath.split('/').last;
    } else if (filePath.contains('\\')) {
      return filePath.split('\\').last;
    } else {
      return S.current.unknownFilePathFormat;
    }
  }

  /// Calculates the file size in kilobytes.
  int _getFileSizeInKB(File file) => (file.lengthSync() / 1024).round();

  /// Gets the current date formatted as 'dd MMM yyyy'.
  String _getFormattedDate() =>
      DateFormat('dd MMM yyyy').format(DateTime.now());

  /// Builds the main container with the widget's layout.
  Widget _buildContainer(
      AttachmentEntity attachment, String formattedDate, bool isMobile) {
    return Container(
      width: 283,
      decoration: _buildBoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            _buildWatermarkIcon(attachment.name),
            horizontalSpace(8),
            Expanded(
                child: _buildFileDetails(attachment.name, attachment.size)),
            horizontalSpace(10),
            if (!isReadOnly) _buildActions(formattedDate),
          ],
        ),
      ),
    );
  }

  /// Builds the box decoration for the container.
  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      border: Border.all(color: AppColors.borderGrey),
    );
  }

  /// Builds the watermark icon.
  Widget _buildWatermarkIcon(String fileName) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: _getFileIcon(fileName),
    );
  }

  /// Builds the file details section displaying the name and size.
  Widget _buildFileDetails(String fileName, int fileSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fileName,
          style: StyleText.fontSize14Weight500
              .copyWith(overflow: TextOverflow.ellipsis),
        ),
        verticalSpace(12),
        Text(
          '$fileSize KB',
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.lighterGrey),
        ),
      ],
    );
  }

  /// Builds the actions section with delete and date information.
  Widget _buildActions(String formattedDate) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        InkWell(
          onTap: onCloseTap,
          child: SvgPicture.asset(AppAssets.cancel),
        ),
        verticalSpace(21),
        _buildDateText(formattedDate),
      ],
    );
  }

  /// Builds the date information as a RichText widget.
  Widget _buildDateText(String formattedDate) {
    return RichText(
      text: TextSpan(
        text: '${'Date'}: ',
        style: StyleText.fontSize10Weight500.copyWith(color: AppColors.lighterGrey)
            .copyWith(letterSpacing: -0.51),
        children: [
          TextSpan(
            text: FormDateTimeHelper.formatDate(DateTime.now()),
            style: StyleText.fontSize10Weight400
                .copyWith(letterSpacing: -0.51),
          ),
        ],
      ),
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    if (extension == 'pdf') {
      return SvgPicture.asset(AppAssets.pdf);
    } else if (['xlsx', 'xls', 'csv'].contains(extension)) {
      return SvgPicture.asset(AppAssets.excel);
    } else if (['ppt', 'pptx'].contains(extension)) {
      return SvgPicture.asset(AppAssets.powerPoint);
    } else if (['mp4', 'mov', 'avi', 'wmv', 'mkv'].contains(extension)) {
      return SvgPicture.asset(AppAssets.vedio);
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
        .contains(extension)) {
      return SvgPicture.asset(AppAssets.imageWatermark);
    } else {
      return SvgPicture.asset(AppAssets.word);
    }
  }
}
