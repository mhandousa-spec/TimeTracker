// ******************* FILE INFO *******************
// File Name: select_provider_action_buttons_row
// Description: Select provider action buttons row.
// Module: services_management_module / presentation/s2_create_single_services/ui/widgets
// *************************************************

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_state.dart';

class ActionButtonsRow extends StatelessWidget {
  const ActionButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderSelectionCubit, ProviderSelectionState>(
      builder: (context, state) {
        if (state is! ProviderSelectionLoaded) return const SizedBox.shrink();

        final cubit = context.read<ProviderSelectionCubit>();
        final data = state.data;
        final isEditProvider = data.editProvider != null;

        return Row(
          children: [
            customButton(
              // ✅ "Discard" in editProvider mode, "Back" otherwise
              title: isEditProvider
                  ? (Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تجاهل'
                  : 'Discard')
                  : S.of(context).back,
              function: () {
                // ✅ Both Discard and Back just pop — no saving
                Navigator.pop(context);
              },
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.white),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: AppColors.secondaryAction,
            ),
            const Spacer(),
            customButton(
              title: isEditProvider
                  ? S.of(context).Save
                  : S.of(context).next,
              function: () => cubit.handleNextNavigation(),
              width: 150.sp,
              height: 38.sp,
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.textButton,
              ),
              radius: 8.r,
            ),
          ],
        );
      },
    );
  }
}
