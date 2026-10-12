import 'package:get/get.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
// Date: 14/1/2025
// By: Mohamed Mohy
// Last update: 18/1/2025
// Objectives:  A widget for displaying the uploaded image with its details.

class ImageUploadedWidget extends StatelessWidget {
  const ImageUploadedWidget({super.key, required this.file, this.onCloseTap});

  /// The uploaded image file.
  final String file;
  final void Function()? onCloseTap;

  @override
  Widget build(BuildContext context) {
    // Initialize the controller for handling actions.

    // Extract metadata about the file.
    final String fileName = _getFileName(file);
    final String formattedDate = _getFormattedDate();

    return _buildContainer(fileName, formattedDate, !ContextExtension(context).isTablett);
  }

  /// Extracts the file name from the file path.
  String _getFileName(String file) {
    String filePath = file;
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
  Widget _buildContainer(String fileName, String formattedDate, bool isMobile) {
    return Container(
      width: double.infinity,  // ✅ CHANGED: Take full width instead of fixed 283
      decoration: _buildBoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            _buildWatermarkIcon(fileName),
            horizontalSpace(8),
            Expanded(child: _buildFileDetails(fileName)),
            horizontalSpace(10),
            _buildActions(formattedDate),
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
  Widget _buildFileDetails(String fileName) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fileName,
          style: StyleText.fontSize14Weight500
              .copyWith(overflow: TextOverflow.ellipsis),
        ),
        /*     verticalSpace(12),
        Text(
          '$fileSize KB',
          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.lighterGrey),
        ),*/
      ],
    );
  }

  /// Builds the actions section with delete and date information.
  Widget _buildActions(String formattedDate) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 3.h),
        InkWell(
          onTap: onCloseTap,
          child: SvgPicture.asset(AppAssets.cancel,width: 16.w,height: 16.h,fit: BoxFit.fill,),
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
    // Remove query parameters if it's a URL
    String cleanFileName = fileName.split('?').first;

    // Get the extension
    final extension = cleanFileName.toLowerCase().split('.').last;

    if (extension == 'pdf') {
      return SvgPicture.asset(AppAssets.pdf,width: 35.w,height: 35.h,fit: BoxFit.fill,);
    } else if (['xlsx', 'xls', 'csv'].contains(extension)) {
      return SvgPicture.asset(AppAssets.excel,width: 35.w,height: 35.h,fit: BoxFit.fill,);
    } else if (['ppt', 'pptx'].contains(extension)) {
      return SvgPicture.asset(AppAssets.powerPoint,width: 35.w,height: 35.h,fit: BoxFit.fill,);
    } else if (['mp4', 'mov', 'avi', 'wmv', 'mkv'].contains(extension)) {
      return SvgPicture.asset(AppAssets.vedio,width: 35.w,height: 35.h,fit: BoxFit.fill,);
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension)) {
      return SvgPicture.asset(AppAssets.imageWatermark,width: 35.w,height: 35.h,fit: BoxFit.fill,);
    } else {
      return SvgPicture.asset(AppAssets.word,width: 35.w,height: 35.h,fit: BoxFit.fill,);
    }
  }
}