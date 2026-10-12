/// Module: knowledge_hub / presentation / s2_view_knowledge_hub / widgets/build_search_section.dart
/// ************************* FILE INFO *************************** ///
/// File Name: build_search_section.dart
/// Purpose: Created to contains search bar and filter data in home screen.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../main_controller/presentation/ui/widgets/search_with_filters.dart';

Widget FilterSection(
  BuildContext context, {
  required TextEditingController searchController,
  required List<DepartmentModelPro> departments,
}) {
  return searchWithFilters(
    context,
    searchController: searchController,
    departments: departments,
    onSearchChanged: (query) {
      context.read<CreateKnowledgeCubit>().searchKnowledge(query);
    },
  );
}
