import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:get/get.dart'; // Keep for .tr translations and locale
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/title_field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
class TitleTextFormattingSection extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;
  final CreateFormDataLoaded state;

  const TitleTextFormattingSection({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    required this.isReadOnly,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final TitleFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TitleFieldController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Text Formatting Styles',
          style: StyleText.fontSize14Weight400,
        ),
        verticalSpace(8),
        _buildStyleRow(controllers, context)
      ],
    );
  }

  Widget _buildStyleRow(
    TitleFieldController controllers,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStyleButton(
          asset: AppAssets.bold,
          isActive: controllers.isBold!,
          onTap: () => context.read<CreateFormDataCubit>().changeTitleStyle(
                pageIndex: pageIndex,
                columnIndex: columnIndex,
                rowIndex: rowIndex,
                style: 'bold',
              ),
        ),
        horizontalSpace(16),
        _buildStyleButton(
          asset: AppAssets.italic,
          isActive: controllers.isItalic!,
          onTap: () => context.read<CreateFormDataCubit>().changeTitleStyle(
                pageIndex: pageIndex,
                columnIndex: columnIndex,
                rowIndex: rowIndex,
                style: 'italic',
              ),
        ),
        horizontalSpace(16),
        _buildStyleButton(
          asset: AppAssets.underLine,
          isActive: controllers.isUnderLine!,
          onTap: () => context.read<CreateFormDataCubit>().changeTitleStyle(
                pageIndex: pageIndex,
                columnIndex: columnIndex,
                rowIndex: rowIndex,
                style: 'underLine',
              ),
        ),
      ],
    );
  }

  Widget _buildStyleButton({
    required String asset,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isReadOnly ? null : onTap,
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              )
            : null,
        child: SvgPicture.asset(
          width: 15.w,
          height: 15.h,
          asset,
          colorFilter: ColorFilter.mode(
            isActive ? AppColors.black : AppColors.text,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class TitleColorSection extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;
  final CreateFormDataLoaded state;

  const TitleColorSection({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    required this.isReadOnly,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final TitleFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TitleFieldController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: StyleText.fontSize14Weight400,
        ),
        verticalSpace(8),
        _buildColorPickerButton(context, controllers)
      ],
    );
  }

  Widget _buildColorPickerButton(
    BuildContext context,
    TitleFieldController controllers,
  ) {
    return InkWell(
      onTap: () async {
        if (isReadOnly) return;

        final Color? pickedColor = await showDialog<Color>(
          context: context,
          builder: (BuildContext context) {
            Color tempColor = controllers.titleColor!;

            return AlertDialog(
              backgroundColor: AppColors.background,
              title: Text(
                context.isArabic ? 'اختر اللون' : 'Pick Color',
                style: StyleText.fontSize16Weight600
                    .copyWith(color: AppColors.text),
              ),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: controllers.titleColor!,
                  onColorChanged: (Color color) {
                    tempColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(tempColor),
                  child: Text(S.of(context).ok),
                ),
              ],
            );
          },
        );

        // Bug report #5: the colour was written onto the controller with no
        // state change, so nothing repainted. Go through the cubit so the
        // swatch and the A4 preview both rebuild.
        if (pickedColor != null && context.mounted) {
          context.read<CreateFormDataCubit>().setTitleColor(
                pageIndex: pageIndex,
                rowIndex: rowIndex,
                columnIndex: columnIndex,
                color: pickedColor,
              );
        }
      },
      child: Container(
        width: 77.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
          child: Row(
            children: [
              SvgPicture.asset(
                AppAssets.colorIcon,
                colorFilter: ColorFilter.mode(
                  controllers.titleColor!,
                  BlendMode.srcIn,
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                AppAssets.arrowDownBold,
                colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
              ),
              horizontalSpace(4),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleTextSizeSection extends StatelessWidget {
  final int columnIndex;
  final int rowIndex;
  final int pageIndex;
  final bool isReadOnly;
  final CreateFormDataLoaded state;

  const TitleTextSizeSection({
    super.key,
    required this.columnIndex,
    required this.rowIndex,
    required this.pageIndex,
    required this.isReadOnly,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final TitleFieldController controllers = state
        .pages[pageIndex]
        .rows[rowIndex]
        .controllers[columnIndex] as TitleFieldController;

    return Container(
      // Bug report #5: 80.w clipped two-digit sizes ("19" read as "1").
      width: 110.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Size',
            style: StyleText.fontSize14Weight400,
          ),
          verticalSpace(8),
          _buildTextSizeControl(controllers, context)
        ],
      ),
    );
  }

  Widget _buildTextSizeControl(
    TitleFieldController controllers,
    BuildContext context,
  ) {
    return Container(
      width: 110.w,
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSizeButton(
            asset: AppAssets.minus,
            onTap: () => context.read<CreateFormDataCubit>().setTitleTextSize(
                  pageIndex: pageIndex,
                  columnIndex: columnIndex,
                  rowIndex: rowIndex,
                  isAdd: false,
                ),
          ),
          _buildSizeInput(controllers, context),
          _buildSizeButton(
            asset: AppAssets.add,
            onTap: () => context.read<CreateFormDataCubit>().setTitleTextSize(
                  pageIndex: pageIndex,
                  columnIndex: columnIndex,
                  rowIndex: rowIndex,
                  isAdd: true,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton({
    required String asset,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(4),
          right: Radius.circular(4),
        ),
        onTap: isReadOnly ? null : onTap,
        child: SizedBox(
          width: 24,
          height: 38.h,
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: 12.w,
              height: 12.h,
              colorFilter: ColorFilter.mode(AppColors.text, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeInput(
    TitleFieldController controllers,
    BuildContext context,
  ) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: CustomTextField(
          controller: controllers.textSize!,
          readOnly: isReadOnly,
          inputFormatters: [if (context.isArabic) ArabicNumberFormatter()],
          onChanged: (p0) {},
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          valueStyle: StyleText.fontSize12Weight400,
          contentPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 6.h),
        ),
      ),
    );
  }
}
