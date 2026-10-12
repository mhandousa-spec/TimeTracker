// ****************** FILE INFO ******************
// File Name: crm_deal_category_form_dialog.dart
// Purpose: Modal dialog for adding or editing CRM Deal Categories
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDealCategoryFormDialog extends StatefulWidget {
  final CrmDealCategoryModel? category;
  final bool isEditing;

  const CrmDealCategoryFormDialog({
    super.key,
    this.category,
    this.isEditing = false,
  });

  /// Function Name: show
  ///
  /// Purpose: Static helper to display the Add/Edit Category modal dialog.
  static Future<CrmDealCategoryModel?> show({
    required BuildContext context,
    CrmDealCategoryModel? category,
    bool isEditing = false,
  }) {
    return showDialog<CrmDealCategoryModel>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => CrmDealCategoryFormDialog(
        category: category,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<CrmDealCategoryFormDialog> createState() =>
      _CrmDealCategoryFormDialogState();
}

class _CrmDealCategoryFormDialogState extends State<CrmDealCategoryFormDialog> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  String? _nameEnError;
  String? _nameArError;

  bool get _hasChanges {
    if (!widget.isEditing) return true;
    final String currentEn = _nameEnController.text.trim();
    final String currentAr = _nameArController.text.trim();
    final String initialEn = widget.category?.nameEn.trim() ?? '';
    final String initialAr = widget.category?.nameAr.trim() ?? '';
    return currentEn != initialEn || currentAr != initialAr;
  }

  bool get _canSubmit =>
      _nameEnController.text.trim().isNotEmpty &&
      _nameArController.text.trim().isNotEmpty &&
      _hasChanges;

  @override
  void initState() {
    super.initState();
    _nameEnController =
        TextEditingController(text: widget.category?.nameEn ?? '');
    _nameArController =
        TextEditingController(text: widget.category?.nameAr ?? '');
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
        _nameEnError = S.current.crmPleaseEnterCategoryNameEn;
      });
      hasError = true;
    }
    if (ar.isEmpty) {
      setState(() {
        _nameArError = S.current.crmPleaseEnterCategoryNameAr;
      });
      hasError = true;
    }

    if (hasError) return;

    final CrmDealCategoryModel resultCategory =
        (widget.category ?? CrmDealCategoryModel.getEmptyModel()).copyWith(
      nameEn: en,
      nameAr: ar,
      status: widget.category?.status ?? 'active',
    );

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSave,
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () {
        Navigator.of(context).pop(resultCategory);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.isEditing ? S.current.crmEditCategory : S.current.crmAddCategory;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.sp),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 24.sp),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440.sp),
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
                    assetPath: AppAssets.crmSections,
                    width: 26.sp,
                    height: 26.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10.sp),
                  Text(
                    title,
                    style: StyleText.fontSize18Weight600,
                  ),
                ],
              ),
              SizedBox(height: 20.sp),

              // Name EN Field
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Name',
                  style: StyleText.fontSize14Weight400,
                ),
              ),
              SizedBox(height: 6.sp),
              CustomTextField(
                controller: _nameEnController,
                hint: 'Text Here',
                errorText: _nameEnError,
                textDirection: TextDirection.ltr,
                onChanged: (_) => setState(() => _nameEnError = null),
              ),
              SizedBox(height: 14.sp),

              // Name AR Field
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اسم الفئة',
                  style: StyleText.fontSize14Weight400,
                ),
              ),
              SizedBox(height: 6.sp),
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
              SizedBox(height: 24.sp),

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
                  SizedBox(width: 12.sp),
                  Expanded(
                    child: customButton(
                      title: widget.isEditing
                          ? S.current.crmSave
                          : S.current.crmAdd,
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
