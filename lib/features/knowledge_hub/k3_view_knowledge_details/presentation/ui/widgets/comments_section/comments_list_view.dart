/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/comments_list_view.dart
/// ************************* FILE INFO *************************** ///
/// File Name: comments_list_view.dart
/// Purpose: Contains all the comments on specific file in knowledge hub.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Refactored to fetch user data from cubit cache

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../../../main_controller/data/models/create_new_comment_model.dart';
import '../../../controller/create_comment_cubit.dart';
import './comments_item.dart';

Widget commentsListView({
  required List<CreateNewCommentModel> comments,
  required CommentsCubit cubit, // ✅ Required to access user data cache
}) {
  final employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity!;
  log(employeeEntity.id ?? 'No id found', name: 'Employee Id');
  
  return ListView.builder(
    shrinkWrap: true,
    itemBuilder: (context, index) {
      final comment = comments[index];
      
      // ✅ Check if this is the current user's comment
      final isMyComment = comment.currentCreatedById == employeeEntity.id;

      return Padding(
        padding: EdgeInsets.only(bottom: 36.h),
        child: commentItem(
          comment: comment,
          isMyComment: isMyComment,
          cubit: cubit, // ✅ Pass cubit to access user data
        ),
      );
    },
    itemCount: comments.length,
  );
}