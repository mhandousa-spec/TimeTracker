/// Module: todo / t3_todo_details / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: todo_details_actions.dart
/// Purpose: Declares `TodoDetailsActions` — the yellow Edit + red Delete row
///          above the card — and `TodoDetailsRestoreButton`, the yellow
///          Restore button drawn BELOW the card of a deleted to-do.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
///
/// Figma (1:31079): Edit 135 × 38 yellow, Delete 135 × 38 red (#DF1C1C),
/// radius 8, 10 apart, Cairo 16 medium. Phone (1:34479): icon-only 38 × 38.
/// Deleted (1:32256): no Edit/Delete; yellow "Restore" at the end, under the
/// card.
///
/// Haptics come from the core widgets themselves: `CustomEditIcon` fires
/// Medium, `CustomDeleteIcon` fires High, `customButton` fires Medium — so
/// nothing here adds another.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Edit / Delete, aligned to the end. A null callback hides that button
/// (no permission); with both null the row draws nothing.
///
/// API: `TodoDetailsActions(onEdit: canEdit ? … : null, onDelete: …)`.
class TodoDetailsActions extends StatelessWidget {
  const TodoDetailsActions({super.key, this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? edit = onEdit;
    final VoidCallback? delete = onDelete;
    if (edit == null && delete == null) return const SizedBox.shrink();
    final S s = S.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (edit != null)
          ShrinkOnTap(
            child: CustomEditIcon(
              title: s.edit,
              onTap: edit,
              color: AppColors.primary,
              svgColor: AppColors.textButton,
              textStyle: StyleText.fontSize16Weight500
                  .copyWith(color: AppColors.textButton),
            ),
          ),
        if (edit != null && delete != null) SizedBox(width: 15.sp),
        if (delete != null)
          CustomDeleteIcon(
            title: s.delete,
            onTap: delete,
            color: AppColors.red,
            svgColor: AppColors.white,
            textStyle:
                StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
          ),
      ],
    );
  }
}

/// The yellow "Restore" button of a deleted to-do, aligned to the end.
///
/// API: `TodoDetailsRestoreButton(onRestore: _restore)`.
class TodoDetailsRestoreButton extends StatelessWidget {
  const TodoDetailsRestoreButton({super.key, required this.onRestore});

  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: ShrinkOnTap(
        child: customButton(
          title: S.of(context).restore,
          function: onRestore,
          color: AppColors.primary,
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
