/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/document_info/build_app_bar.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_app_bar.dart
/// Purpose: Contains the app bar widget for file info in mobile view.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

PreferredSizeWidget buildAppBar(BuildContext context,{required String documentName}) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.colorBlack),
          ),
          SizedBox(width: 8.5.w,),
          Text(documentName, style: StyleText.fontSize20Weight600),
        ],
      ),
    );
  }