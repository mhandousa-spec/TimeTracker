// ******************* FILE INFO *******************
// File Name: save_for_later_button
// Description: Save for later button.
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

import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/details_switch_widgets.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/provider_selection_state.dart';

class SaveForLaterButton extends StatelessWidget {
  const SaveForLaterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderSelectionCubit, ProviderSelectionState>(
      builder: (context, state) {
        if (state is! ProviderSelectionLoaded) return const SizedBox.shrink();

        final data = state.data;

        final isEditingSubmittedService =
            data.editingModel != null && data.editingModel!.state != "submitted";

        final isDraft = data.editingModel != null &&
            (data.editingModel!.currentState == "draft" ||
                data.editingModel!.currentDurationOfServices == "-" ||
                data.editingModel!.currentDurationOfServices.isEmpty);

        final shouldShow = !isEditingSubmittedService || isDraft;

        if (!shouldShow) return const SizedBox.shrink();

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            customButton(
              title: isEditingSubmittedService && isDraft
                  ? S.of(context).saveForLater
                  : isEditingSubmittedService
                  ? S.of(context).discardChange
                  : S.of(context).saveForLater,
              function: () => _handleSaveForLater(context, isEditingSubmittedService, isDraft),
              textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.onSecondaryAction),
              width: 150.sp,
              height: 38.sp,
              radius: 8.r,
              color: AppColors.secondaryAction,
            ),
          ],
        );
      },
    );
  }

  void _handleSaveForLater(BuildContext context, bool isEditingSubmittedService, bool isDraft) {
    final cubit = context.read<ProviderSelectionCubit>();

    if (isEditingSubmittedService && !isDraft) {
      // Navigate to details without saving
      return;
    }

    // Show confirmation and save to FIREBASE (not local)
    _showDraftConfirmation(context, cubit, isDraft);
  }

  void _showDraftConfirmation(BuildContext context, ProviderSelectionCubit cubit, bool isDraft) {
    // ✅ FIX (bug report p24 "not bold and add svg"): this was a raw AlertDialog
    // with a blue Icons.save and AlertDialog's default bold title style, while
    // the other save-for-later entry point (details_switch_screen) already used
    // the shared ConfirmationDialog with the Edit Document lottie.
    //
    // Reuse that component so both paths render identically.
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ConfirmationDialog(
        lottiePath:
            "assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json",
        title: S.of(context).saveForLater,
        message: S.of(context).areYouSureYouWantToSaveAsDraft,
        noText: S.of(context).no,
        yesText: S.of(context).yes,
        onConfirm: () async {
          await cubit.handleSaveForLaterToFirebase();
        },
      ),
    );
  }
}
