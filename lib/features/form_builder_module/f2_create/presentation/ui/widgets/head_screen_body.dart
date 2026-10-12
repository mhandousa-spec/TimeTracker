import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // Keep for .tr translations and extensions
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/utils/helper_format.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/create_form_data_screen.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart' hide FormatHelper;
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/orientation.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/head_form_fields.dart';

class HeadScreenBody extends StatefulWidget {
  const HeadScreenBody({super.key, this.formModel});
  final FormEntity? formModel;

  @override
  State<HeadScreenBody> createState() => _HeadScreenBodyState();
}

/// ADDED 19/8/2026 — the "hide and expand" item from the bug report (page 2).
///
/// `_buildHideSection` was already a `Row` with `spaceBetween` and a single
/// child, i.e. the header had been built to hold a trailing control that was
/// never added. This is that control.
///
/// The state is local and deliberately NOT in `CreateFormHeadCubit`: collapsing
/// the panel is a view preference, it must not survive a rebuild of the form
/// data, and putting it in the cubit would emit a form state change (and so a
/// dirty/unsaved signal) for something the user has not edited.
class _HeadScreenBodyState extends State<HeadScreenBody> {
  /// Expanded on entry — the point of the screen is filling these fields in.
  bool _isExpanded = true;

  FormEntity? get formModel => widget.formModel;

  @override
  Widget build(BuildContext context) {
    final isReadOnly = _isReadOnly();

    return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
      builder: (context, state) {
        if (state is! CreateFormHeadLoaded) {
          return const CircleProgressMaster();
        }

        return ContextExtension(context).isTablett
            ? _buildFormDeckTobContainer(context, state, isReadOnly)
            : _buildFormMobileContainer(context, state, isReadOnly);
      },
    );
  }

  Widget _buildFormMobileContainer(
      BuildContext context,
      CreateFormHeadLoaded state,
      bool isReadOnly,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: _formContainerDecoration(context),
          child: _buildFormContent(context, state, isReadOnly),
        ),
        verticalSpace(15),
        Row(
          children: [
            if (formModel != null && formModel!.status == FormStatus.deleted) ...[
              _buildRestoreButton(context),
              const Spacer(),
            ],
            _buildSubmitButton(context),
          ],
        ),
        verticalSpace(60)
      ],
    );
  }

  Widget _buildFormDeckTobContainer(
      BuildContext context,
      CreateFormHeadLoaded state,
      bool isReadOnly,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildHideSection(context),
        verticalSpace(10),
        // AnimatedSize + the align-to-top child gives the panel a real
        // collapse rather than a pop: the card keeps its full width and
        // shrinks its height to zero, so the rows below it slide up.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? Container(
                  width: double.infinity,
                  decoration: _formContainerDecoration(context),
                  child: _buildFormContent(context, state, isReadOnly),
                )
              // Full width, zero height — collapsing to `SizedBox.shrink()`
              // would drop the width to 0 too and make the card appear to fly
              // in from the side on the way back out.
              : const SizedBox(width: double.infinity, height: 0),
        ),
        verticalSpace(5),
        verticalSpace(10),
      ],
    );
  }

  Widget _buildHideSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          S.of(context).formDetails,
          style: StyleText.fontSize16Weight500,
        ),
        _buildExpandToggle(context),
      ],
    );
  }

  /// The hide / expand control at the end of the "Form Details" row.
  ///
  /// CHANGED 19/8/2026: this was a 36pt circle holding a rotating chevron.
  /// It is a plain "Hide" / "Expand" text link now, matching the identical
  /// control on the Preview screen (`preview_screen.dart`) — the two sit one
  /// step apart in the same flow, so an icon in one place and a word in the
  /// other read as two different controls.
  ///
  /// Same construction as Preview's, and for the same reason: NOT an `InkWell`,
  /// which paints a hover highlight and a ripple behind the text on desktop.
  /// `MouseRegion` keeps the pointer cursor, `GestureDetector` keeps the tap.
  ///
  /// `AlignmentDirectional` is not needed — this sits in a `spaceBetween` Row,
  /// so it follows the text direction on its own and lands on the left in
  /// Arabic, which is what the design shows.
  Widget _buildExpandToggle(BuildContext context) {
    return Semantics(
      button: true,
      expanded: _isExpanded,
      label: _isExpanded ? S.of(context).hideFormDetails : S.of(context).showFormDetails,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            _isExpanded ? S.of(context).hide : S.of(context).expand,
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.blue,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.blue,
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _formContainerDecoration(BuildContext context) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }

  Widget _buildFormContent(
      BuildContext context,
      CreateFormHeadLoaded state,
      bool isReadOnly,
      )
  {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: HeadFormFields(state: state, isReadOnly: isReadOnly),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: customButtonWithSvg(
        title: 'Next',
        function: () {
          final cubit = context.read<CreateFormHeadCubit>();
          Navigator.push(context, MaterialPageRoute(builder: (_){
            return CreateFormDataScreen();
          }));
        },
        textStyle: StyleText.fontSize16Weight500
            .copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: '',
        widthImage: 0,
        heightImage: 0,
        colorBorder: AppColors.transparent,
      ),
    );
  }

  Widget _buildRestoreButton(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: customButtonWithSvg(
        title: 'Restore',
        function: () {
          context.read<HomeCubit>().restoreForm(
            model: formModel!,
            context: context,
          );
        },
        textStyle: StyleText.fontSize16Weight500
            .copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: '',
        widthImage: 0,
        heightImage: 0,
        colorBorder: AppColors.transparent,
      ),
    );
  }

  bool _isReadOnly() {
    
    if (formModel?.status == FormStatus.deleted) {
      
      return true;
    }
    return false;
  }
}