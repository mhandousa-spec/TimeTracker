
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/text_required_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/time_selector_field_model.dart';

import 'package:knowticed_plus/core/constants/space_helper.dart';

class TimeSelectorPdfPreviewWidget extends StatelessWidget {
  const TimeSelectorPdfPreviewWidget({super.key, required this.model});
  final TimeSelectorFieldModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and required indicator
        TextRequiredWidget(
          isRequired: _getIsRequired(),
          text: _getTitle(),
        ),
        verticalSpace(8), // #40: same title gap as every other field

        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              Container(
                height: 36.sp, // #40: same scale as CustomTextField
                width: 60.w,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              horizontalSpace(10),

              Container(
                height: 36.sp, // #40: same scale as CustomTextField
                width: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _getIsRequired() {
    bool flag = false;
    flag = model.isRequired ?? false;
    return flag;
  }

  String _getTitle() {
    return model.title ?? '';
  }
}
