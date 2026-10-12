/// Module: knowledge_hub / presentation / s2_view_knowledge_hub / widgets/departments_list.dart
/// ************************* FILE INFO *************************** ///
/// File Name: departments_list.dart
/// Purpose: Contains the Departments view in Home Page.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';


import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import '../../../../k3_view_knowledge_details/presentation/controller/create_knowledge_state.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../main_controller/presentation/ui/widgets/departments_list_view.dart';

Widget buildDepartmentsList({
  required int selectedIndex,
  required void Function()? onPressed,
}) {
  return BlocBuilder<CreateKnowledgeCubit, CreateKnowledgeState>(
    buildWhen: (previous, current) =>
        current is FetchingDepartmentLoadingState ||
        current is FetchingDepartmentErrorState ||
        current is FetchingDepartmentSuccessState,
    builder: (context, state) {
      return switch (state) {
        FetchingDepartmentLoadingState() => _buildLoadingIndicator(),
        FetchingDepartmentErrorState() => _buildErrorWidget(
          context,
          error: state.error,
          onPressed: onPressed,
        ),
        FetchingDepartmentSuccessState() => _buildDepartmentsListView(
          context,
          departments: state.departmentList,
          selectedIndex: selectedIndex,
        ),
        _ => const Center(child: SizedBox.shrink()),
      };
    },
  );
}

Widget _buildLoadingIndicator() {
  return const SizedBox.shrink();
}

Widget _buildErrorWidget(
  BuildContext context, {
  required String error,
  required void Function()? onPressed,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 60, color: AppColors.red),
        SizedBox(height: 16.h),
        Text(
          'Error: $error',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: onPressed,
          // onPressed: _initializeData,
          child: Text(S.of(context)!.retry),
        ),
      ],
    ),
  );
}

Widget _buildDepartmentsListView(
  BuildContext context, {
  required List<DepartmentModelPro> departments,
  required int selectedIndex,
}) {
  log('Departments fetched successfully');
  return departmentsListView(
    context,
    selectedIndex: selectedIndex,
    cubit: context.read<CreateKnowledgeCubit>(),
    departmentNames: departments,
  );
}
