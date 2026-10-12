/// Module: GRC Policy Management
/// Description: Widget for adding and managing policy controls in a new policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK, AppColors, AppTheme, PolicyControlItemWidget, PolicyControlModel
/// Revision History: 2026-07-01 - Initial creation
library;

/// ************************* FILE INFO *************************** ///
/// File Name: add_policy_controls.dart
/// Purpose: Contains AddPolicyControlsPage, the controls list widget
///          embedded inside CreateNewPolicyPage as step 2.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:knowticed_plus/features/grc/shared/helpers/grc_document_picker.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_item_widget.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_control_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/custom/52-custom_upload_document.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [AddPolicyControlsPage]
///
/// purpose: renders the list of policy control cards for step 2 of the
///          Create New Policy flow. Manages adding, removing, and updating
///          individual PolicyControlModel entries.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 1/7/2026
class AddPolicyControlsPage extends StatefulWidget {
  final bool isArabicEnabled;
  final List<PolicyControlModel> controls;
  final DateTime? policyStartDate;
  final DateTime? policyEndDate;
  final bool controlsSubmitted;
  final VoidCallback? onChanged;

  const AddPolicyControlsPage({
    super.key,
    required this.isArabicEnabled,
    required this.controls,
    required this.policyStartDate,
    required this.policyEndDate,
    required this.controlsSubmitted,
    this.onChanged,
  });

  @override
  State<AddPolicyControlsPage> createState() => _AddPolicyControlsPageState();
}

class _AddPolicyControlsPageState extends State<AddPolicyControlsPage> {
  List<PolicyControlModel> get _controls => widget.controls;

  void _addControl() {
    setState(() => _controls.add(PolicyControlModel()));
  }

  void _removeControl(int index) {
    setState(() {
      _controls[index].dispose();
      _controls.removeAt(index);
    });
  }

  void _onControlStartDateChanged(int index, DateTime? date) {
    setState(() {
      _controls[index].startDate = date;
      final end = _controls[index].endDate;
      if (end != null && date != null && end.isBefore(date)) {
        _controls[index].endDate = null;
      }
    });
  }

  void _onControlEndDateChanged(int index, DateTime? date) {
    setState(() => _controls[index].endDate = date);
  }

  void _onUploadDocumentEn(int index) {
    // GRC bug report p16: straight to the file picker — the old
    // upload dialog's Document Title was never used.
    pickGrcDocument(context, (file) {
        setState(() => _controls[index].documentEn =
            PolicyDocumentInfo.fromPlatformFile(file));
    });
  }

  void _onUploadDocumentAr(int index) {
    // GRC bug report p16: straight to the file picker — the old
    // upload dialog's Document Title was never used.
    pickGrcDocument(context, (file) {
        setState(() => _controls[index].documentAr =
            PolicyDocumentInfo.fromPlatformFile(file));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).addPolicyControls,
          style: StyleText.fontSize16Weight400.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < _controls.length; i++)
                    PolicyControlItemWidget(
                      key: ValueKey(_controls[i]),
                      index: i,
                      control: _controls[i],
                      isArabicEnabled: widget.isArabicEnabled,
                      controlsSubmitted: widget.controlsSubmitted,
                      showRemoveButton: _controls.length > 1,
                      onRemove: () => _removeControl(i),
                      onUploadDocumentEn: () => _onUploadDocumentEn(i),
                      onUploadDocumentAr: () => _onUploadDocumentAr(i),
                      onRemoveDocumentEn: () =>
                          setState(() => _controls[i].documentEn = null),
                      onRemoveDocumentAr: () =>
                          setState(() => _controls[i].documentAr = null),
                      onFrequencyChanged: (value) =>
                          setState(() => _controls[i].frequency = value),
                      policyStartDate: widget.policyStartDate,
                      policyEndDate: widget.policyEndDate,
                      onStartDateChanged: (date) =>
                          _onControlStartDateChanged(i, date),
                      onEndDateChanged: (date) =>
                          _onControlEndDateChanged(i, date),
                      onChanged: widget.onChanged,
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: customButtonWithSvg(
                      width: 100.sp,
                      fixedHeight: 30.sp,
                      colorBorder: Colors.transparent,
                      widthImage: 16.sp,
                      heightImage: 16.sp,
                      function: _addControl,
                      title: S.of(context).control,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.white),
                      image:
                          'assets/icons_assets/database_builder_assets/plus_head.svg',
                      color: Colors.black,
                      svgColor: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
