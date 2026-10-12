import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/drop_down_field_model.dart';

import '../../../../../f2_create/presentation/ui/widgets/text_required_widget.dart' show TextRequiredWidget;

class DropDownPdfPreviewWidget extends StatelessWidget {
  const DropDownPdfPreviewWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });

  final bool isExpand; // Not used in this widget, can be removed
  final DropDownFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: model.alignment.alignment,
      child: SizedBox(
        width: isExpand ? null : _calculateWidth(context, model),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRequiredWidget(isRequired: model.isRequired, text: model.title),
            // Bug report p.8: same 8 gap as the text/email/link fields, so a
            // dropdown box lines up with the text box beside it in a row.
            verticalSpace(8),
            _buildEmptyContainer(),
            verticalSpace(8),
            _buildHorizontalCheckBoxes(model),
          ],
        ),
      ),
    );
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context, DropDownFieldModel model) {
    return model.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  ///Build Empty Container
  Widget _buildEmptyContainer() {
    return Container(
      width: double.infinity,
      height: 36.sp, // #40: same scale as CustomTextField
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  /// Build horizontal checkbox options
  Wrap _buildHorizontalCheckBoxes(DropDownFieldModel model) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: _buildCheckBoxRows(model),
    );
  }

  /// Generate checkbox rows with options
  List<Widget> _buildCheckBoxRows(DropDownFieldModel model) {
    return model.hints.asMap().entries.map<Widget>((entry) {
      var option = entry.value;

      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          SvgPicture.asset(AppAssets.checkbox),
          Flexible(
            child: Text(
              option,
              style: StyleText.fontSize14Weight400,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }).toList();
  }
}
