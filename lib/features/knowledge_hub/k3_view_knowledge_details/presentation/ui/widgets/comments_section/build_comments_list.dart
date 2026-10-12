/// Module: knowledge_hub / presentation / s3_view_knowledge_details / master_page/widgets/comments_section/build_comments_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_comments_list.dart
/// Purpose: Contains the comments created for each file in knowledge hub.
/// Author: Youssef Khaled
/// Created At: 11/10/2025
/// Updated: Refactored to pass cubit for user data access

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../controller/create_comment_cubit.dart';
import '../../../controller/create_comment_states.dart';
import './build_comments_text_field.dart';
import './comments_list_view.dart';

Widget buildCommentsSection(
  BuildContext context, {
  required bool showFullComments,
  required String knowledgeId,
}) {
  final lightMode = Theme.of(context).brightness == Brightness.light;
  return Expanded(
    flex: showFullComments ? 3 : 1,
    child: Column(
      children: [
        Expanded(child: _buildCommentsList(context, lightMode)),
        SizedBox(height: 10.h),
        buildCommentInput(context, knowledgeId: knowledgeId),
      ],
    ),
  );
}

Widget _buildCommentsList(BuildContext context, bool lightMode) {
  return Container(
    decoration: BoxDecoration(
      color: lightMode ? AppColors.white : AppColors.chatBackground,
      borderRadius: BorderRadius.circular(8.r),
    ),
    padding: EdgeInsets.all(15.w),
    child: BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        // Get cubit instance for accessing user cache
        final cubit = context.read<CommentsCubit>();

        if (state is CommentsLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CommentsLoadedSuccess) {
          if (state.comments.isEmpty) {
            return Center(
              child: Text(
                'No comments yet. Be the first to comment!',
                style: TextStyle(fontSize: 14.sp, color: AppColors.colorGrey),
              ),
            );
          }
          // ✅ Pass cubit to access user data cache
          return commentsListView(comments: state.comments, cubit: cubit);
        } else if (state is CommentsLoadedFailure) {
          return Center(
            child: Text(
              'Failed to load comments',
              style: TextStyle(fontSize: 14.sp, color: AppColors.red),
            ),
          );
        }

        // For other states, show the current comments list
        if (cubit.commentsList.isEmpty) {
          return Center(
            child: Text(
              'No comments yet. Be the first to comment!',
              style: TextStyle(fontSize: 14.sp, color: AppColors.colorGrey),
            ),
          );
        }
        // ✅ Pass cubit to access user data cache
        return commentsListView(comments: cubit.commentsList, cubit: cubit);
      },
    ),
  );
}
