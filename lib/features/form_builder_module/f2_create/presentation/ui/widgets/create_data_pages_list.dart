import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:get/get.dart'; // Keep for .tr translations only

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/create_data_column_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/drop_down_widget.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart' hide ContextExtension;
class CreateDataPagesList extends StatelessWidget {
  const CreateDataPagesList({
    super.key,
    required this.state,
    required this.isReadOnly,
  });

  final CreateFormDataLoaded state;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        state.pages.length,
        (index) => _buildPage(index, context, state, isReadOnly),
      ),
    );
  }

  Widget _buildPage(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.pages.length > 1 &&
            (!ContextExtension(context).isTablett ||
                (ContextExtension(context).isTablett && state.pages[pageIndex].isPageExpanded)))
          _buildPageHeader(pageIndex, context, state),
        if (state.pages[pageIndex].isPageExpanded)
          ..._buildPageRows(pageIndex, context, state, isReadOnly),
      ],
    );
  }

  Widget _buildPageHeader(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(ContextExtension(context).isTablett ? 15 : 20),
        Row(
          children: [
            Text(
              '${S.of(context).page} ${pageIndex + 1}',
              style: StyleText.fontSize16Weight500,
            ),
            if (!ContextExtension(context).isTablett) ...[
              const Spacer(),
              _buildExpandCollapseButton(pageIndex, context, state),
            ]
          ],
        ),
        verticalSpace(ContextExtension(context).isTablett ? 15 : 20),
      ],
    );
  }

  Widget _buildExpandCollapseButton(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    return InkWell(
      onTap: () => context.read<CreateFormDataCubit>().expandedPage(pageIndex),
      child: Text(
        state.pages[pageIndex].isPageExpanded
            ? S.of(context).hide
            : S.of(context).expand,
        style: StyleText.fontSize14Weight500.copyWith(
          color: AppColors.blue,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.blue,
        ),
      ),
    );
  }

  List<Widget> _buildPageRows(
    int pageIndex,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return List.generate(
      state.pages[pageIndex].rows.length,
      (indexRow) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRowContainer(pageIndex, indexRow, context, state, isReadOnly),
          verticalSpace(16),
        ],
      ),
    );
  }

  Widget _buildRowContainer(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.all(Radius.circular(8.r)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRowHeader(pageIndex, indexRow, context, state),
            if (state.pages[pageIndex].rows[indexRow].isRowExpanded)
              _buildRowBody(pageIndex, indexRow, context, state, isReadOnly),
          ],
        ),
      ),
    );
  }

  Widget _buildRowHeader(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final row = state.pages[pageIndex].rows[indexRow];
    return Row(
      children: [
        Text(
          // Figma names this "First Row" / "Second Row" (node 7444-41775 and
          // siblings), not "1st Row". Arabic puts the ordinal after the noun:
          // "الصف الأول".
          Get.locale?.languageCode == 'ar'
              ? '${S.of(context).rowHeading} ${indexRow.toWordOrdinal()}'
              : '${indexRow.toWordOrdinal()} ${S.of(context).rowHeading}',
          style: StyleText.fontSize16Weight500,
        ),
        const Spacer(),
        if (!row.isRowExpanded) ...[
          _buildRowActionButton(
            icon: AppAssets.copy,
            onTap: () => context.read<CreateFormDataCubit>().duplicateRow(
                  indexRow: indexRow,
                  pageIndex: pageIndex,
                ),
          ),
          horizontalSpace(25),
          _buildRowActionButton(
            icon: AppAssets.delete,
            onTap: () => context.read<CreateFormDataCubit>().deleteRow(
                  rowIndex: indexRow,
                  pageIndex: pageIndex,
                ),
          ),
          horizontalSpace(25),
        ],
        _buildExpandRowButton(pageIndex, indexRow, context, state),
      ],
    );
  }

  Widget _buildRowActionButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        colorFilter: icon == AppAssets.delete
            ? null
            : ColorFilter.mode(
                AppColors.text,
                BlendMode.srcIn,
              ),
      ),
    );
  }

  Widget _buildExpandRowButton(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final row = state.pages[pageIndex].rows[indexRow];
    return InkWell(
      onTap: () => context.read<CreateFormDataCubit>().onExpanded(
            rowIndex: indexRow,
            pageIndex: pageIndex,
          ),
      child: Transform.rotate(
        angle: row.isRowExpanded ? 3.14 : 0,
        child: SvgPicture.asset(
          AppAssets.arrowDown,
          width: 20.sp,
          height: 20.sp,
          colorFilter: ColorFilter.mode(
            AppColors.text,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildRowBody(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verticalSpace(20),
        _buildNumberOfColumnsField(
            pageIndex, indexRow, context, state, isReadOnly),
        ..._buildColumnFields(pageIndex, indexRow, context, state, isReadOnly),
      ],
    );
  }

  Widget _buildNumberOfColumnsField(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    return CustomTextField(
        height: 36,
        readOnly: isReadOnly,
        label: S.of(context).numberOfColumns,
        keyboardType: TextInputType.number,
        controller: state.pages[pageIndex].rows[indexRow].numOfColumn!,
        inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
        onChanged: (value) {
        final englishNumber = value.toEnglishNumber();

        if (englishNumber != null && englishNumber > 0 && englishNumber <= 15) {
          context.read<CreateFormDataCubit>().changeNumberOfColumn(
                value: englishNumber,
                rowIndex: indexRow,
                pageIndex: pageIndex,
              );
        }
      },
      );
  }

  List<Widget> _buildColumnFields(
    int pageIndex,
    int indexRow,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    final numColumnsText = state
        .pages[pageIndex].rows[indexRow].numOfColumn!.text
        .toEnglishNumber();

    final numColumns = numColumnsText ?? 0;

    return List.generate(
      numColumns,
      (columnIndex) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          verticalSpace(20),
          _buildColumnHeader(columnIndex, context),
          verticalSpace(15),
          _buildColumnContent(
              pageIndex, indexRow, columnIndex, context, state, isReadOnly),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(int columnIndex, BuildContext context) {
    return Text(
      // Was "Column 1st" — both the word form AND the word ORDER were wrong.
      // Figma says "First Column" (node 7444-41775), so English leads with the
      // ordinal; Arabic keeps it after the noun ("العمود الأول").
      Get.locale?.languageCode == 'ar'
          ? ' ${S.of(context).columnHeading} ${columnIndex.toWordOrdinal()}'
          : ' ${columnIndex.toWordOrdinal()} ${S.of(context).columnHeading}',
      style: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.primary),
    );
  }

  Widget _buildColumnContent(
    int pageIndex,
    int rowIndex,
    int columnIndex,
    BuildContext context,
    CreateFormDataLoaded state,
    bool isReadOnly,
  ) {
    final numColumnsText = state
        .pages[pageIndex].rows[rowIndex].numOfColumn!.text
        .toEnglishNumber();
    final numColumns = numColumnsText ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldTypeDropdown(
            pageIndex, rowIndex, columnIndex, context, state),
        verticalSpace(15),
        buildColumnFieldWidget(
          state.pages[pageIndex].rows[rowIndex].controllers[columnIndex].type,
          columnIndex,
          rowIndex,
          pageIndex,
          isReadOnly,
        ),
        if (numColumns == 1 && columnIndex == 0) ...[
          verticalSpace(15),
        ],
      ],
    );
  }

  Widget _buildFieldTypeDropdown(
    int pageIndex,
    int rowIndex,
    int columnIndex,
    BuildContext context,
    CreateFormDataLoaded state,
  ) {
    final controller =
        state.pages[pageIndex].rows[rowIndex].controllers[columnIndex];

    final isArabic = Get.locale?.languageCode == 'ar';

    // Figma: "Choose Field of First Column" (node 7444-41775).
    final title = isArabic
        ? '${S.of(context).chooseFieldOf} ${S.of(context).columnHeading} ${columnIndex.toWordOrdinal()}'
        : '${S.of(context).chooseFieldOf} ${columnIndex.toWordOrdinal()} ${S.of(context).columnHeading}';

    return DropDownWidget(
      onChanged: (value) =>
          context.read<CreateFormDataCubit>().changeFieldTypeValue(
                value: value,
                rowIndex: rowIndex,
                columnIndex: columnIndex,
                pageIndex: pageIndex,
              ),
      svgIconPath: controller.type.icon,
      // Per-row glyphs. They used to be baked into the DropdownMenuItem
      // children at the SVG's own intrinsic size — the "very big" menu icons
      // in the report. DropDownWidget now draws them at the same 16 it uses
      // for the trigger, so the two finally agree.
      leadingIconForValue: (value) => FieldTypeExtension.fromName(value)?.icon,
      title: title,
      hint: S.of(context).fieldTypeTextField,
      items: FieldTypeExtension.dropDownItems,
      currentValue: controller.type.name,
    );
  }
}
