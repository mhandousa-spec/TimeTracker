import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/84-messaging_custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:get/get.dart'; // Keep for .tr translations only

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
/// ── Figma spec: MESBAH / node 7444-41775 (Create New Form, 1024 frame) ──────
///
/// The action buttons, measured from the frame origin:
///
///   + Row            x 96,  y 1568,  80 × 30
///   Break Page       x 280, y 1568, 100 × 30
///   Preview          x 395, y 1349, 150 × 38
///   Save For Later   x 395, y 1402, 150 × 38   (15 under Preview)
///   Publish          x 811, y 1349, 150 × 38
///
/// So the small pair is 30 tall and the three primary actions are 150 × 38 —
/// none of which the code was producing. `+ Row` asked for 80 × 33 and
/// `customButtonWithSvg` discarded both (its `width:`/`height:`/`radius:` are
/// ignored by design), giving 135 × 38 with an 8 radius; Break Page asked for
/// 80 × 35 against Figma's 100 × 30; and Preview / Publish / Save For Later
/// passed no size at all, so they came out 135 wide instead of 150.
/// Shared height of the "+ Row" / "Break Page" pair.
///
/// SCALE IT WITH `.sp` AT BOTH CALL SITES — not `.h` at one and `.sp` at the
/// other (19/8/2026). The two buttons are built from different widgets that
/// take their height differently:
///
///   `customButtonWithSvg(fixedHeight:)` uses the number VERBATIM, so the call
///   site scales it.
///   `CustomButton(height:)` applies `.sp` ITSELF, inside the widget.
///
/// "+ Row" passed `30.h` and Break Page passed a raw `30` that became `30.sp`,
/// and `.h` (screen-height ratio) and `.sp` (text-scale ratio) are only equal
/// when the window happens to match the design aspect ratio. On the desktop
/// window they don't, so two buttons both "30 tall" in Figma rendered at
/// visibly different heights side by side.
const double _kSmallButtonHeight = 30;
const double _kSmallButtonRadius = 4;
const double _kAddRowWidth = 80;
const double _kBreakPageWidth = 100;

const double _kPrimaryButtonWidth = 150;
const double _kPrimaryButtonHeight = 38;

class CreateDataActionButtons extends StatelessWidget {
  const CreateDataActionButtons({super.key, this.formModel});

  final FormEntity? formModel;

  @override
  Widget build(BuildContext context) {
    if (formModel?.status.name != FormStatus.deleted.name) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(15),
          _buildRowAndPageAddButtons(context),
          verticalSpace(25),
          if (!ContextExtension(context).isTablett) ...[
            _buildSaveAndPublishButtons(context),
            verticalSpace(25),
            _buildPreviewButton(context),
          ]
        ],
      );
    } else if (!ContextExtension(context).isTablett &&
        formModel?.status.name == FormStatus.deleted.name) {
      return _buildRestoreButtons(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildRowAndPageAddButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAddRowButton(context),
        _buildAddPageButton(context),
      ],
    );
  }

  Widget _buildAddRowButton(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return customButtonWithSvg(
      // Figma 80 × 30, radius 4. `width:`/`height:`/`radius:` below are the
      // parameters customButtonWithSvg ignores — the `fixed*` ones are what
      // actually apply. They are left in place so the call site still reads
      // the same as its neighbours.
      fixedWidth: _kAddRowWidth.w,
      // `.sp`, matching what CustomButton applies to Break Page's height
      // internally — see the note on _kSmallButtonHeight.
      fixedHeight: _kSmallButtonHeight.sp,
      fixedRadius: _kSmallButtonRadius.r,
      colorBorder: AppColors.transparent,
      space: ContextExtension(context).isPhone ? 0.sp : 8.sp,
      image: "assets/icons_assets/main_icons_assets/plus.svg",
      widthImage: 14,
      heightImage: 14,
      radius: 4.r,
      svgColor: AppColors.text,
      textStyle: StyleText.fontSize14Weight500
          .copyWith(color: lightMode ? AppColors.white : AppColors.white),
      color: AppColors.card,
      title: S.of(context).row,
      function: () {
        context.read<CreateFormDataCubit>().addRow();
      },
    );
  }

  Widget _buildAddPageButton(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return CustomButton(
      // Figma 100 × 30 (was 80 × 35). Unlike customButtonWithSvg, CustomButton
      // does honour width/height, so these apply directly. The default
      // 24 / 8 padding would fight the fixed height, so it is pinned too.
      // Raw numbers on purpose: CustomButton scales width with `.w` and height
      // with `.sp` inside its own build. Pre-scaling here would scale twice.
      width: _kBreakPageWidth,
      height: _kSmallButtonHeight,
      horizontalPadding: 12.sp,
      verticalPadding: 0,
      textStyle: StyleText.fontSize14Weight500
          .copyWith(color: lightMode ? AppColors.white : AppColors.white),
      buttonColor: AppColors.card,
      // Bug report #1: same 4.r corner as "+ Row" (CustomButton's own
      // default is 2.r).
      borderRadius: _kSmallButtonRadius.r,
      buttonText: S.of(context).breakPage,
      // FIXED 19/8/2026 — "break page not brake it make new row".
      //
      // This called `addRow()`, the identical call the "+ Row" button two
      // methods up makes, so the two buttons did the same thing and a page
      // break was impossible to insert. Almost certainly a copy-paste when the
      // button was added: the method is even named `_buildAddPageButton`.
      //
      // `addPage()` is the right one — it appends a new PageControllerModel
      // seeded with one row, which is what starting a new page means.
      // NOT `addPageWithRow(pageIndex)`: that MOVES the current page's last
      // row onto the next page, which is the "push this row over the break"
      // operation, not "start a new page here".
      onTap: () {
        context.read<CreateFormDataCubit>().addPage();
      },
    );
  }

  Widget _buildSaveAndPublishButtons(BuildContext context) {
    if (formModel == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSaveForLaterButton(context),
          _buildPublishButton(context),
        ],
      );
    }
    return _buildEditButtons(context);
  }

  Widget _buildEditButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDiscardButton(context),
        _buildPublishEditButton(context),
      ],
    );
  }

  Widget _buildRestoreButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDiscardButton(context),
        _buildRestoreButton(context),
      ],
    );
  }

  Widget _buildSaveForLaterButton(BuildContext context) {
    return CustomButton(
      // Figma 150 × 38, same box as Preview and Publish — it had no size at
      // all, so it wrapped to its label and sat narrower than the pair above.
      width: _kPrimaryButtonWidth,
      height: _kPrimaryButtonHeight,
      horizontalPadding: 12.sp,
      verticalPadding: 0,
      buttonText: S.of(context).saveForLater,
      // Bug report p.31: darkGrey + white text, like Back / Discard.
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
      buttonColor: AppColors.darkGrey,
      onTap: () {
        context.read<HomeCubit>().draftNewForm(
              model: context.read<CreateFormDataCubit>().createFormHomeModel(),
              context: context,
            );
      },
    );
  }

  Widget _buildPublishButton(BuildContext context) {
    bool _isProcessing = false;

    return customButtonWithSvg(
      fixedWidth: _kPrimaryButtonWidth.w,
      title: S.of(context).publish,
      function: () async {
        if (_isProcessing) {
          return;
        }

        _isProcessing = true;

        final createFormDataCubit = context.read<CreateFormDataCubit>();
        final homeCubit = context.read<HomeCubit>();

        if (createFormDataCubit.formCreateDataKey.currentState?.validate() ??
            false) {
          try {
            final formEntity = createFormDataCubit.createFormHomeModel();

            homeCubit.publishNewForm(
              model: formEntity,
              context: context,
              createFormDataCubit: createFormDataCubit,
            );
          } catch (e, stackTrace) {
            _isProcessing = false;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${S.of(context).error}: $e'),
                backgroundColor: AppColors.red,
              ),
            );
          }
        } else {
          _isProcessing = false;
        }
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.black),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildDiscardButton(BuildContext context) {
    return customButtonWithSvg(
      fixedWidth: _kPrimaryButtonWidth.w,
      title: S.of(context).discard,
      function: () {
        context.pop();
        context.pop();
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.white),
      color: AppColors.darkGrey,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildPublishEditButton(BuildContext context) {
    return customButtonWithSvg(
      fixedWidth: _kPrimaryButtonWidth.w,
      title: S.of(context).publish,
      function: () {
        var newFormModel =
            context.read<CreateFormDataCubit>().createFormHomeModel();
        context.read<HomeCubit>().publishEdit(
              oldFormModel: formModel!,
              newFormModel: newFormModel,
              context: context,
            );
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.black),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    return customButtonWithSvg(
      fixedWidth: _kPrimaryButtonWidth.w,
      title: S.of(context).restore,
      function: () {
        context.read<HomeCubit>().restoreForm(
              model: formModel!,
              context: context,
            );
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.black),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildPreviewButton(BuildContext context) {
    return customButtonWithSvg(
      fixedWidth: _kPrimaryButtonWidth.w,
      title: S.of(context).preview,
      function: () => context.read<CreateFormDataCubit>().preview(context),
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.black),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }
}
