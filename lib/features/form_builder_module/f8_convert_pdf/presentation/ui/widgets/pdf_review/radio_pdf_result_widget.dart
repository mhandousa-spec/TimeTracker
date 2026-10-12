import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/arrangement.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/radio_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';

class RadioPdfResultWidget extends StatelessWidget {
  const RadioPdfResultWidget({
    super.key,
    required this.model,
  });

  final RadioFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: model.alignment.alignment,
        child: SizedBox(
          width: _calculateWidth(context, model),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextRequiredWidget(
                  isRequired: model.isRequired, text: model.title),
              verticalSpace(8),
              _buildRadioOptions(model),
            ],
          ),
        ));
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context, RadioFieldModel model) {
    return model.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ?  200.w:365.w)
        : double.infinity;
  }

  /// Build radio options based on arrangement (vertical or horizontal)
  Widget _buildRadioOptions(RadioFieldModel model) {
    return model.arrangement == Arrangement.vertical.name
        ? _buildVerticalRadios(model)
        : _buildHorizontalRadios(model);
  }

  /// Build vertical radio options
  Column _buildVerticalRadios(RadioFieldModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: model.hints.map((option) => _buildRadioRow(option)).toList(),
    );
  }

  /// Build horizontal radio options
  Wrap _buildHorizontalRadios(RadioFieldModel model) {
    return Wrap(
      children: model.hints.map((option) => _buildRadioRow(option)).toList(),
    );
  }

  /// Build individual radio row with radio button and text
  Widget _buildRadioRow(String option) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8.0, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(onTap: () {}, child: SvgPicture.asset(AppAssets.radio)),
          horizontalSpace(5),
          Flexible(
            child: Text(
              option,
              style: StyleText.fontSize14Weight500,
            ),
          ),
        ],
      ),
    );
  }
}
