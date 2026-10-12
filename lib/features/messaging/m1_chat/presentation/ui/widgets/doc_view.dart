/// Module: messaging / chat / presentation/ui/widgets/doc_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import '../../../data/models/message/doc_message_model.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

//Youssef Ashraf
class DocView extends StatelessWidget {
  final DocMessageModel model;
  const DocView({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final pdfController =
        PdfController(document: PdfDocument.openFile(model.docPath));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PdfView(
              controller: pdfController,
              renderer: (page) =>
                  page.render(width: page.width, height: page.height),
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