import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/alignment.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/link_field_model.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';

class LinkPdfResultWidget extends StatelessWidget {
  const LinkPdfResultWidget({
    super.key,
    required this.model,
    this.isExpand = false,
  });

  final LinkFieldModel model;
  final bool isExpand; // Not used in this widget, can be removed

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: model.alignment.alignment,
        child: SizedBox(
          width: isExpand ? null : _calculateWidth(context, model),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextRequiredWidget(
                  isRequired: model.isRequired, text: model.title),
              verticalSpace(8),
              _buildLinkTextField(),
            ],
          ),
        ));
  }

  /// Calculate widget width based on alignment and device type
  double _calculateWidth(BuildContext context, LinkFieldModel controllers) {
    return controllers.alignment != AlignmentEnum.expand.name
        ? (ContextExtension(context).isTablett ? 200.w : 365.w)
        : double.infinity;
  }

  /// Build link text input field
  Widget _buildLinkTextField() {
    return CustomTextField(
        height: 36,
        contentPadding: EdgeInsets.symmetric(vertical: 12.sp, horizontal: 10.sp), // form bug report #40
        hint: ' ',
        maxLines: 1,
        prefixIcon: SvgPicture.asset(AppAssets.link),
        enabled: false,
        hintStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
        fillColor: AppColors.background,
        width: double.infinity,
      );
  }
}
