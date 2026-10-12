/// Module: knowledge_hub / presentation / s5_submission_details / widgets/comments_section/build_comments_section_on_submitted_file.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_comments_section_on_submitted_file.dart
/// Purpose: Build comments section on submitted file — Submission Details (S5) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import '../../../../../k4_submissions/presentation/controller/submissions_cubit.dart';
import '../../../../../k4_submissions/presentation/controller/submissions_states.dart';
import './comments_list_view_on_submitted_file.dart';

Widget buildCommentsSectionOnSubmittedFile(
    BuildContext context, {
      required bool showFullComments,
      required String knowledgeId,
      required bool lightMode,
    }) {
  return BlocBuilder<SubmissionsCubit, SubmissionsStates>(
    builder: (context, state) {
      final cubit = context.read<SubmissionsCubit>();

      // Loading state
      if (state is FetchingCommentsLoadingState) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }

      // Get comments from cubit
      final comments = cubit.currentComments;

      // Use the enhanced widget
      return commentsListViewOnSubmittedFile(
        context: context,
        lightMode: lightMode,
        comments: comments,
        cubit: cubit,
        knowledgeId: knowledgeId,
      );
    },
  );
}