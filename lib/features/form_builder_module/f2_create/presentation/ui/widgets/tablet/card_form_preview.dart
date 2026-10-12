import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/controllers/field_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/a4_container.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/tablet/card_preview_actions.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/tablet/card_preview_field_builder.dart';
// Date: 22/12/2024
// By: Mohamed Mohy / Amr
// Updated: 10/01/2026
// Objectives: Card preview widget with A4 page breaking and orientation support
class CardFormPreview extends StatelessWidget {
  const CardFormPreview({super.key, this.formModel});

  final FormEntity? formModel;

  static const double a4PortraitWidth = 794.0;
  static const double a4PortraitHeight = 1123.0;
  static const double a4LandscapeWidth = 1123.0;
  static const double a4LandscapeHeight = 794.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
      builder: (context, dataState) {
        if (dataState is! CreateFormDataLoaded) {
          return const CircleProgressMaster();
        }

        return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
          builder: (context, headState) {
            if (headState is! CreateFormHeadLoaded) {
              return const CircleProgressMaster();
            }

            return ValueListenableBuilder(
              valueListenable: headState.horizontalPaddingController,
              builder: (context, horizontalValue, _) {
                return ValueListenableBuilder(
                  valueListenable: headState.verticalPaddingController,
                  builder: (context, verticalValue, _) {
                    return Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPreviewPages(context, dataState, headState),
                          verticalSpace(20),
                          CardPreviewActions(
                            formModel: formModel,
                            dataState: dataState,
                            headState: headState,
                          ),
                          verticalSpace(15),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Builds all preview services_management_module
  Widget _buildPreviewPages(
    BuildContext context,
    CreateFormDataLoaded dataState,
    CreateFormHeadLoaded headState,
  ) {
    final String horizontalPaddingText =
        headState.horizontalPaddingController.text.trim();
    final String verticalPaddingText =
        headState.verticalPaddingController.text.trim();

    final String horizontalPaddingWestern =
        convertArabicNumeralsToWestern(horizontalPaddingText);
    final String verticalPaddingWestern =
        convertArabicNumeralsToWestern(verticalPaddingText);

    final double horizontalPadding = horizontalPaddingWestern.isEmpty
        ? 16.0
        : (double.tryParse(horizontalPaddingWestern) ?? 16.0);

    final double verticalPadding = verticalPaddingWestern.isEmpty
        ? 16.0
        : (double.tryParse(verticalPaddingWestern) ?? 16.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int pageIndex = 0; pageIndex < dataState.pages.length; pageIndex++) ...[
          if (dataState.pages[pageIndex].isPageExpanded) ...[
            if (dataState.pages.length > 1) ...[
              verticalSpace(15),
              _buildPageHeader(context, dataState, pageIndex),
              verticalSpace(15),
            ],
            A4Container(
              key: ValueKey('a4_${pageIndex}_${horizontalPadding}_${verticalPadding}'),
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
              orientation: headState.orientation,
              onOverflow: (isOverflowing) async {
                if (isOverflowing) {
                  await Future.delayed(const Duration(milliseconds: 1));
                  context.read<CreateFormDataCubit>().addPageWithRow(pageIndex);
                }
              },
              watermarkImage: headState.watermark,
              watermarkSize: double.tryParse(
                    convertArabicNumeralsToWestern(
                        headState.watermarkSizeController.text),
                  ) ??
                  100.0,
              watermarkOpacity: double.tryParse(
                    convertArabicNumeralsToWestern(
                        headState.watermarkOpacityController.text),
                  ) ??
                  50.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int indexRow = 0;
                      indexRow < dataState.pages[pageIndex].rows.length;
                      indexRow++) ...[
                    _buildPageRow(
                      context: context,
                      dataState: dataState,
                      pageIndex: pageIndex,
                      rowIndex: indexRow,
                    ),
                    if (indexRow < dataState.pages[pageIndex].rows.length - 1)
                      verticalSpace(15),
                  ],
                ],
              ),
            ),
            if (pageIndex < dataState.pages.length - 1) verticalSpace(30),
          ],
        ],
      ],
    );
  }

  /// Builds a single row with all its field controllers
  Widget _buildPageRow({
    required BuildContext context,
    required CreateFormDataLoaded dataState,
    required int pageIndex,
    required int rowIndex,
  }) {
    final row = dataState.pages[pageIndex].rows[rowIndex];
    final controllers = row.controllers;

    final bool hasMultipleColumns =
        row.numOfColumn?.text != '1' && row.numOfColumn?.text != '١';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < controllers.length; index++) ...[
          if (index != 0) horizontalSpace(15),
          Expanded(
            child: buildPreviewFieldWidget(
              controllers[index].type,
              index,
              rowIndex,
              pageIndex,
              controllers[index],
              hasMultipleColumns,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds page header with hide/expand functionality
  Widget _buildPageHeader(
    BuildContext context,
    CreateFormDataLoaded dataState,
    int pageIndex,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${'Page'} ${pageIndex + 1}',
          style: StyleText.fontSize14Weight500,
        ),
        InkWell(
          onTap: () => context.read<CreateFormDataCubit>().expandedPage(pageIndex),
          child: Text(
            dataState.pages[pageIndex].isPageExpanded
                ? 'Hide'
                : 'Expand',
            style: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.blue,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.blue,
              decorationThickness: 1.0,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
