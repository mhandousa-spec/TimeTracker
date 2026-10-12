/// Module: messaging / chat / presentation/ui/widgets/image_interact_view.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:pdfx/pdfx.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

//Youssef Ashraf
///Interact with image view.. comes from Image Bubble
class ImageInteractView extends StatelessWidget {
  final File image;
  const ImageInteractView({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Hero(
              tag: image.path,
              child: PhotoView(
                imageProvider: FileImage(image),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: AppColors.inverseBase,
                  size: ContextExtension(context).isTablett ? 32.w : 24.w,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}