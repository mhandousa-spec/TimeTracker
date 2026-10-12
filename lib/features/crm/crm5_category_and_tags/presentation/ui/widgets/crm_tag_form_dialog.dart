// ****************** FILE INFO ******************
// File Name: crm_tag_form_dialog.dart
// Purpose: Modal dialog for adding or editing CRM Activity Tags
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTagFormDialog extends StatefulWidget {
  final CrmTagModel? tag;
  final bool isEditing;

  const CrmTagFormDialog({
    super.key,
    this.tag,
    this.isEditing = false,
  });

  static Future<CrmTagModel?> show({
    required BuildContext context,
    CrmTagModel? tag,
    bool isEditing = false,
  }) {
    return showDialog<CrmTagModel>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => CrmTagFormDialog(
        tag: tag,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CrmTagFormDialog> createState() => _CrmTagFormDialogState();
}

class _CrmTagFormDialogState extends State<CrmTagFormDialog> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  String? _nameEnError;
  String? _nameArError;

  bool get _hasChanges {
    if (!widget.isEditing) return true;
    final String currentEn = _nameEnController.text.trim();
    final String currentAr = _nameArController.text.trim();
    final String initialEn = widget.tag?.nameEn.trim() ?? '';
    final String initialAr = widget.tag?.nameAr.trim() ?? '';
    return currentEn != initialEn || currentAr != initialAr;
  }

  bool get _canSubmit =>
      _nameEnController.text.trim().isNotEmpty &&
      _nameArController.text.trim().isNotEmpty &&
      _hasChanges;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.tag?.nameEn ?? '');
    _nameArController = TextEditingController(text: widget.tag?.nameAr ?? '');
    _nameEnController.addListener(_refreshSubmitState);
    _nameArController.addListener(_refreshSubmitState);
  }

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    super.dispose();
  }

  void _onSave() {
    final String en = _nameEnController.text.trim();
    final String ar = _nameArController.text.trim();

    bool hasError = false;
    if (en.isEmpty) {
      setState(() {
        _nameEnError = 'Please enter tag name';
      });
      hasError = true;
    }
    if (ar.isEmpty) {
      setState(() {
        _nameArError = 'يرجى إدخال اسم الوسم';
      });
      hasError = true;
    }

    if (hasError) return;

    final CrmTagModel resultTag =
        (widget.tag ?? CrmTagModel.getEmptyModel()).copyWith(
      nameEn: en,
      nameAr: ar,
      status: widget.tag?.status ?? 'active',
    );

    Navigator.of(context).pop(resultTag);
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.isEditing ? S.current.crmEditTag : S.current.crmAddTag;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440.w),
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Header: Icon + Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomSvgImage(
                    assetPath: AppAssets.crmTagField,
                    width: 28.sp,
                    height: 28.sp,
                    color: AppColors.black,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    title,
                    style: StyleText.fontSize18Weight600,
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Name EN Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Name',
                  style: StyleText.fontSize14Weight400,
                ),
              ),
              SizedBox(height: 6.h),
              CustomTextField(
                controller: _nameEnController,
                hint: 'Text Here',
                errorText: _nameEnError,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() => _nameEnError = null),
              ),
              SizedBox(height: 14.h),

              // Name AR Field
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اسم الوسم',
                  style: StyleText.fontSize14Weight400,
                ),
              ),
              SizedBox(height: 6.h),
              Directionality(
                textDirection: TextDirection.rtl,
                child: CustomTextField(
                  controller: _nameArController,
                  hint: 'اكتب هنا',
                  errorText: _nameArError,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  onChanged: (_) => setState(() => _nameArError = null),
                ),
              ),
              SizedBox(height: 24.h),

              // Action Buttons: Discard & Save
              Row(
                children: <Widget>[
                  Expanded(
                    child: customButton(
                      title: S.current.crmDiscard,
                      function: () => Navigator.of(context).pop(),
                      color: AppColors.grey,
                      textColor: AppColors.black,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: customButton(
                      title: S.current.crmSave,
                      function: _canSubmit ? _onSave : () {},
                      color: _canSubmit
                          ? AppColors.primary
                          : AppColors.disabledGrey,
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color:
                            _canSubmit ? AppColors.black : AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
