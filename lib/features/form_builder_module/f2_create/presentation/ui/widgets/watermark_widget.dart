import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/image_uploaded_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
class WatermarkWidget extends StatelessWidget {
  const WatermarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
      builder: (context, state) {
        if (state is! CreateFormHeadLoaded) {
          return const SizedBox.shrink();
        }

        return ContextExtension(context).isTablett
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Watermark',
                style: StyleText.fontSize14Weight400,
              ),
            ),
            horizontalSpace(20),
            Expanded(
              child: state.watermark == null
                  ? Row(
                children: [
                  customButtonWithSvg(
                    title: S.of(context).uploadWatermark,
                    function: () => context
                        .read<CreateFormHeadCubit>()
                        .pickWatermarkImage(),
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                    color: AppColors.primary,
                    image:
                        "assets/icons_assets/main_icons_assets/export_arrow.svg",
                    widthImage: 20,
                    heightImage: 20,
                    colorBorder: AppColors.transparent,
                    svgColor: AppColors.textButton,
                  ),
                  const Spacer(),
                ],
              )
                  : ImageUploadedWidget(  // ✅ CHANGED: No Row wrapper, takes full Expanded width
                file: state.watermark!,
                onCloseTap: () => context
                    .read<CreateFormHeadCubit>()
                    .removeWatermarkImage(),
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watermark',
              style: StyleText.fontSize14Weight400.copyWith(
                color: AppColors.textButton,
              ),
            ),
            verticalSpace(15),
            state.watermark == null
                ? customButtonWithSvg(
              title: S.of(context).uploadWatermark,
              function: () => context
                  .read<CreateFormHeadCubit>()
                  .pickWatermarkImage(),
              textStyle: StyleText.fontSize14Weight500
                  .copyWith(color: AppColors.textButton),
              color: AppColors.primary,
              image: "assets/icons_assets/main_icons_assets/export_arrow.svg",
              widthImage: 20,
              heightImage: 20,
              colorBorder: AppColors.transparent,
              svgColor: AppColors.textButton,
            )
                : ImageUploadedWidget(
              file: state.watermark!,
              onCloseTap: () => context
                  .read<CreateFormHeadCubit>()
                  .removeWatermarkImage(),
            ),
          ],
        );
      },
    );
  }
}