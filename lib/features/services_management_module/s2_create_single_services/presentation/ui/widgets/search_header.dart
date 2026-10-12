// ******************* FILE INFO *******************
// File Name: search_header
// Description: Search header.
// Module: services_management_module / presentation/s2_create_single_services/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_state.dart';


class SearchHeader extends StatelessWidget {
  final TextEditingController controller;

  const SearchHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderSelectionCubit, ProviderSelectionState>(
      builder: (context, state) {
        return Row(
          children: [
            AppSearchTextField(
              fillColor: AppColors.background,
              controller: controller,
              onChanged: (value) {
                context.read<ProviderSelectionCubit>().updateSearch(value);
              },
            ),
          ],
        );
      },
    );
  }
}
