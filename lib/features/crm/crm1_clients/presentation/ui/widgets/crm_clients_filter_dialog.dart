// ****************** FILE INFO ******************
// File Name: crm_clients_filter_dialog.dart
// Purpose: Filter bottom sheet / modal for CRM clients list matching design specs
// Author: Mohand Adel
// Created At: 24/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmClientsFilterDialog extends StatefulWidget {
  final String? initialStatus;
  final DateTime? initialCreationDate;
  final DateTime? initialLastUpdate;
  final String? initialClientCountRange;
  final void Function({
    String? status,
    DateTime? creationDate,
    DateTime? lastUpdate,
    String? clientCountRange,
  }) onApply;

  const CrmClientsFilterDialog({
    super.key,
    this.initialStatus,
    this.initialCreationDate,
    this.initialLastUpdate,
    this.initialClientCountRange,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialStatus,
    DateTime? initialCreationDate,
    DateTime? initialLastUpdate,
    String? initialClientCountRange,
    required void Function({
      String? status,
      DateTime? creationDate,
      DateTime? lastUpdate,
      String? clientCountRange,
    }) onApply,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 24.sp),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420.sp),
          child: CrmClientsFilterDialog(
            initialStatus: initialStatus,
            initialCreationDate: initialCreationDate,
            initialLastUpdate: initialLastUpdate,
            initialClientCountRange: initialClientCountRange,
            onApply: onApply,
          ),
        ),
      ),
    );
  }

  @override
  State<CrmClientsFilterDialog> createState() => _CrmClientsFilterDialogState();
}

class _CrmClientsFilterDialogState extends State<CrmClientsFilterDialog> {
  String? _status;
  DateTime? _creationDate;
  DateTime? _lastUpdate;
  String? _clientCountRange;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _creationDate = widget.initialCreationDate;
    _lastUpdate = widget.initialLastUpdate;
    _clientCountRange = widget.initialClientCountRange;
  }

  void _reset() {
    setState(() {
      _status = null;
      _creationDate = null;
      _lastUpdate = null;
      _clientCountRange = null;
    });
  }

  void _apply() {
    widget.onApply(
      status: _status,
      creationDate: _creationDate,
      lastUpdate: _lastUpdate,
      clientCountRange: _clientCountRange,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Yellow circle with Filter Icon + Filter text
            Row(
              children: [
                Container(
                  width: 32.sp,
                  height: 32.sp,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: CustomSvgImage(
                    assetPath: AppAssets.filter,
                    width: 16.sp,
                    height: 16.sp,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(width: 10.sp),
                Text(
                  S.current.filter,
                  style: StyleText.fontSize16Weight600,
                ),
              ],
            ),
            SizedBox(height: 16.sp),

            // Status Dropdown
            CustomDropdown<String>(
              label: S.current.crmStatus,
              hint: S.current.crmChoose,
              value: _status,
              items: [
                DropdownItem(value: 'active', label: S.current.crmActive),
                DropdownItem(value: 'inactive', label: S.current.crmInactive),
                DropdownItem(value: 'prospect', label: S.current.crmProspect),
                DropdownItem(value: 'archived', label: S.current.crmArchived),
              ],
              onChanged: (val) => setState(() => _status = val),
              fillColor: AppColors.background,
            ),
            SizedBox(height: 12.sp),

            // Creation Date
            CustomDropdownCalendar(
              label: S.current.crmCreationDateLabel,
              hint: S.current.crmCreationDateLabel,
              value: _creationDate,
              onChanged: (val) => setState(() => _creationDate = val),
              fillColor: AppColors.background,
            ),
            SizedBox(height: 12.sp),

            // Last Update
            CustomDropdownCalendar(
              label: S.current.crmLastUpdate,
              hint: S.current.crmLastUpdate,
              value: _lastUpdate,
              onChanged: (val) => setState(() => _lastUpdate = val),
              fillColor: AppColors.background,
            ),
            SizedBox(height: 12.sp),

            // Number of Clients
            CustomDropdown<String>(
              label: S.current.crmClients,
              hint: S.current.crmChoose,
              value: _clientCountRange,
              items: const [
                DropdownItem(value: '1-10', label: '1 - 10'),
                DropdownItem(value: '11-50', label: '11 - 50'),
                DropdownItem(value: '50+', label: '50+'),
              ],
              onChanged: (val) => setState(() => _clientCountRange = val),
              fillColor: AppColors.background,
            ),
            SizedBox(height: 24.sp),

            // Actions Row: Reset & Apply
            Row(
              children: [
                Expanded(
                  child: customButton(
                    title: S.current.reset,
                    function: _reset,
                    color: AppColors.lightGrey,
                    textStyle: StyleText.fontSize14Weight500,
                  ),
                ),
                SizedBox(width: 14.sp),
                Expanded(
                  child: customButton(
                    title: S.current.apply,
                    function: _apply,
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize14Weight600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.sp),
          ],
        ),
      ),
    );
  }
}
