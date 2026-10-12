import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_text_field_model.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';

class RadioTextFieldPdfResultWidget extends StatelessWidget {
  const RadioTextFieldPdfResultWidget({
    super.key,
    required this.model,
  });

  final RadioTextFieldModel model;

  @override
  Widget build(BuildContext context) {
    // Build the main widget container
    return _buildContainer(context);
  }

  /// Build the container with alignment and sizing
  Widget _buildContainer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _getWidgets(),
    );
  }

  /// Build the radio button with text field
  Widget _buildRadioTextField(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Container(
            color: AppColors.background,
            height: 36.sp, // #40
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Ensure Row shrinks to fit content
              children: [
                SvgPicture.asset(AppAssets.radio),
                horizontalSpace(5),
                Flexible(
                  // Allows content to shrink if needed
                  child: Text(
                    text,
                    style: StyleText.fontSize14Weight400,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getWidgets() {
    List<Widget> widgets = [];

    for (int i = 0; i < model.hints.length; i++) {
      widgets.add(Expanded(
          child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 8.0, end: 8),
        child: _buildRadioTextField(model.hints[i]),
      )));
    }
    return widgets;
  }
}
