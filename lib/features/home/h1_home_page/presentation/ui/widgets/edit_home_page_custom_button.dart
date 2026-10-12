/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: edit_home_page_custom_button.dart
/// Purpose: Preview / Save / Discard actions for the home-layout editor.
/// Author: Amr Mesbah
/// Created at: 21/9/2025
/// Updated: 24/8/2026 - Save now runs the shared confirm -> success dialog flow
///          and stays disabled until the layout actually differs from what is
///          stored.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_cubit.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/home_state.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/pages/preview_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class EditHomePageCustomButton extends StatelessWidget {
  const EditHomePageCustomButton({super.key});

  /// Save = confirm dialog -> write -> success dialog.
  ///
  /// It used to call `updateHomeComponents()` straight from the tap, with no
  /// confirmation and no feedback: a successful save looked identical to doing
  /// nothing. `CustomDialogManager.showDialogFlow` only shows the success step
  /// when [onConfirm] returns true, and `updateHomeComponents()` already
  /// returns whether the write landed — so a failed save cannot report success.
  /// (The page's own BlocListener still shows the error snackbar.)
  Future<void> _save(BuildContext context) async {
    final AppHomeCubit cubit = context.read<AppHomeCubit>();

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
      confirmTitle: S.of(context).applyChanges,
      confirmSubtitle: S.of(context).areYouSureYouWantToSaveTheseChanges,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () => cubit.updateHomeComponents(),
      successLottie: 'assets/lottie_assets/main_lottie_assets/correct.json',
      successTitle: S.of(context).Successful,
      successSubtitle: S.of(context).dataHasBeenSavedSuccessfully,
    );
  }

  /// Save, greyed out and untappable until the layout differs from the stored
  /// one — the same disabled treatment used across Settings.
  ///
  /// Rebuilt from the cubit rather than a local flag: every edit path
  /// (`addHeaderIcon`, `removeHeaderIcon`, `editComponent`, `removeComponent`)
  /// already emits, so `hasChanges` is re-read the moment anything moves.
  Widget _buildSaveButton(BuildContext context, {bool fullWidth = false}) {
    return BlocBuilder<AppHomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final bool enabled = context.read<AppHomeCubit>().hasChanges;

        return Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !enabled,
            child: customButton(
              width: 150.w,
              fullWidth: fullWidth,
              title: S.of(context).Save,
              color: enabled ? AppColors.primary : AppColors.grey,
              function: () => _save(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscardButton(BuildContext context, {bool fullWidth = false}) {
    return customButton(
      width: 150.w,
      fullWidth: fullWidth,
      title: S.of(context).discardChange,
      function: () {
        Navigator.of(context).pop();
      },
      color: AppColors.secondaryButton,
      textStyle: StyleText.fontSize16Weight400,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Phone: no Preview — the editor already IS the phone-width layout, so
    // Preview showed the same screen again. Save and Discard sit side by side
    // and share the row equally so neither is squeezed or runs off the edge.
    if (context.isPhone) {
      return Row(
        children: [
          Expanded(child: _buildSaveButton(context, fullWidth: true)),
          SizedBox(width: 12.sp),
          Expanded(child: _buildDiscardButton(context, fullWidth: true)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            customButton(
              width: 150.w,
              function: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HomePreview()),
                );
              },
              title: S.of(context).preview,
            ),
            const Spacer(),
            _buildSaveButton(context),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            _buildDiscardButton(context),
          ],
        )
      ],
    );
  }
}
