import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

Widget uploadImageWidget({
  required BuildContext context,
  void Function()? pickImage,
  void Function()? removeImage,
  File? selectedImage,
  Uint8List? webImage, // For web support
  String? imageUrl,
  bool isUploadingImage = false,
}) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  var lightMode = Theme.of(context).brightness == Brightness.light;

  // Get image provider based on available image sources
  ImageProvider? _getImageProvider() {
    if (webImage != null) {
      return MemoryImage(webImage);
    } else if (selectedImage != null) {
      return FileImage(selectedImage);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    }
    return null;
  }

  // Get child widget for CircleAvatar
  Widget? _getImageChild() {
    if (webImage != null || selectedImage != null || (imageUrl != null && imageUrl.isNotEmpty)) {
      return null; // Image will be shown via backgroundImage
    }

    // Show placeholder icon when no image
    return CustomSvgImage(
      assetPath: 'assets/icons_assets/knowledge_hub_assets/knowlege_module_Gallery.svg',
      height: 35.h,
      width: 35.w,
      fit: BoxFit.scaleDown,
      color: lightMode ? Colors.grey[600] : AppColors.grey,
    );
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: isUploadingImage ? null : pickImage,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor:  AppColors.background,
              backgroundImage: _getImageProvider(),
              child: _getImageChild(),
            ),

            // Show camera icon always (before and after upload) when not uploading
            if (!isUploadingImage)
              Positioned(
                right: isArabic ? 30.sp : 0,
                left: isArabic ? 0 : null,
                bottom: 0,
                child: Container(
                  width: 20.sp,
                  height: 20.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/images_Camera.svg",
                    width: 12.sp,
                    height: 12.sp,
                    color: AppColors.textButton,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),

            // Show loading indicator while uploading
            if (isUploadingImage)
              Positioned(
                right: isArabic ? 30.sp : 0,
                left: isArabic ? 0 : null,
                bottom: 0,
                child: Container(
                  width: 20.sp,
                  height: 20.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 12.sp,
                    height: 12.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}