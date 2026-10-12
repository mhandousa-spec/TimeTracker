// ****************** FILE INFO ******************
// File Name: crm_deal_stage_view_dialog.dart
// Purpose: Modal dialog for viewing CRM Deal Stage details with status toggle and edit action
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDealStageViewDialog extends StatefulWidget {
  final CrmDealStageModel stage;
  final VoidCallback onEdit;
  final ValueChanged<String> onStatusChanged;
  final String initialStatus;
  final String probabilityLabel;

  const CrmDealStageViewDialog({
    super.key,
    required this.stage,
    required this.onEdit,
    required this.onStatusChanged,
    required this.initialStatus,
    required this.probabilityLabel,
  });

  /// Function Name: show
  ///
  /// Purpose: Static helper to display the Stage Details view dialog.
  static void show({
    required BuildContext context,
    required CrmDealStageModel stage,
    required VoidCallback onEdit,
    required ValueChanged<String> onStatusChanged,
    required String initialStatus,
    required String probabilityLabel,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => CrmDealStageViewDialog(
        stage: stage,
        onEdit: onEdit,
        onStatusChanged: onStatusChanged,
        initialStatus: initialStatus,
        probabilityLabel: probabilityLabel,
      ),
    );
  }

  @override
  State<CrmDealStageViewDialog> createState() => _CrmDealStageViewDialogState();
}

class _CrmDealStageViewDialogState extends State<CrmDealStageViewDialog> {
  late String _selectedStatus;
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final TextEditingController _probabilityController;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _nameEnController = TextEditingController(text: widget.stage.nameEn);
    _nameArController = TextEditingController(text: widget.stage.nameAr);
    _probabilityController = TextEditingController(
      text: widget.probabilityLabel,
    );
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _probabilityController.dispose();
    super.dispose();
  }

  void _handleStatusSelected(String newStatus) {
    setState(() => _selectedStatus = newStatus);
    Navigator.of(context).pop();
    widget.onStatusChanged(newStatus);
  }

  @override
  Widget build(BuildContext context) {
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
              // Header: Icon (Primary Yellow) + Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomSvgImage(
                    assetPath: AppAssets.crmTagField,
                    width: 26.sp,
                    height: 26.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10.sp),
                  Text(
                    S.current.crmStageDetails,
                    style: StyleText.fontSize18Weight600,
                  ),
                ],
              ),
              SizedBox(height: 16.sp),

              // Status Dropdown and Edit Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildStatusDropdownButton(),
                  CustomEditIcon(
                    title: S.current.edit,
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onEdit();
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.sp),

              // Name EN Field (Read-only)
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
                textDirection: TextDirection.ltr,
                readOnly: true,
              ),
              SizedBox(height: 14.sp),

              // Name AR Field (Read-only)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الاسم',
                  style: StyleText.fontSize14Weight400,
                ),
              ),
              SizedBox(height: 6.sp),
              Directionality(
                textDirection: TextDirection.rtl,
                child: CustomTextField(
                  controller: _nameArController,
                  hint: 'اكتب هنا',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  readOnly: true,
                ),
              ),
              SizedBox(height: 14.sp),

              // Probability Field (Read-only)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  S.current.crmProbability,
                  style: StyleText.fontSize14Weight400,
                ),
              ),
              SizedBox(height: 6.sp),
              CustomTextField(
                controller: _probabilityController,
                hint: '0%',
                textDirection: TextDirection.ltr,
                readOnly: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdownButton() {
    final bool isActive = _selectedStatus.toLowerCase() == 'active';
    final Color bgColor = isActive ? AppColors.green : AppColors.orange;
    final String label = isActive ? S.current.crmActive : S.current.crmInactive;

    return PopupMenuButton<String>(
      onSelected: _handleStatusSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.sp),
      ),
      color: AppColors.white,
      itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'Active',
          child: Row(
            children: [
              Container(
                width: 8.sp,
                height: 8.sp,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.sp),
              Text(
                S.current.crmActive,
                style: StyleText.fontSize14Weight400,
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'Inactive',
          child: Row(
            children: [
              Container(
                width: 8.sp,
                height: 8.sp,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.sp),
              Text(
                S.current.crmInactive,
                style: StyleText.fontSize14Weight400,
              ),
            ],
          ),
        ),
      ],
      child: Container(
        height: 38.sp,
        padding: EdgeInsets.symmetric(horizontal: 14.sp),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6.sp),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: StyleText.fontSize16Weight500.copyWith(color: AppColors.white).copyWith(
                fontSize: 14.sp,
                color: AppColors.white,
              ),
            ),
            SizedBox(width: 14.sp),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
