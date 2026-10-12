// ****************** FILE INFO ******************
// File Name: crm_deal_stage_edit_page.dart
// Purpose: Full-page view and form for CRM Deal Stages with read-only view and edit mode
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deal_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deal_form_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deals_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_deal_stage_checklist_item_row.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDealStageEditPage extends StatefulWidget {
  final CrmDealStageModel? stage;
  final bool isEditing;
  final bool isReadOnly;
  final CrmDealsCubit cubit;

  const CrmDealStageEditPage({
    super.key,
    this.stage,
    this.isEditing = false,
    this.isReadOnly = false,
    required this.cubit,
  });

  @override
  State<CrmDealStageEditPage> createState() => _CrmDealStageEditPageState();
}

class _CrmDealStageEditPageState extends State<CrmDealStageEditPage> {
  late bool _isReadOnly;
  late String _currentStatus;
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final CrmDealFormCubit _formCubit;

  bool get _hasChanges {
    final String currentEn = _nameEnController.text.trim();
    final String currentAr = _nameArController.text.trim();
    final String initialEn = widget.stage?.nameEn.trim() ?? '';
    final String initialAr = widget.stage?.nameAr.trim() ?? '';
    final String initialStatus = widget.stage?.status ?? 'active';
    return currentEn != initialEn ||
        currentAr != initialAr ||
        _currentStatus != initialStatus;
  }

  bool get _canSubmit =>
      _nameEnController.text.trim().isNotEmpty &&
      _nameArController.text.trim().isNotEmpty &&
      _hasChanges;

  @override
  void initState() {
    super.initState();
    _isReadOnly = widget.isReadOnly;
    _currentStatus = widget.stage?.status ?? 'active';
    _nameEnController = TextEditingController(text: widget.stage?.nameEn ?? '');
    _nameArController = TextEditingController(text: widget.stage?.nameAr ?? '');
    _nameEnController.addListener(_refreshSubmitState);
    _nameArController.addListener(_refreshSubmitState);
    _formCubit = CrmDealFormCubit(dealsCubit: widget.cubit)
      ..prepareStage(
          stage: widget.stage,
          isEditing: widget.isEditing || widget.stage != null);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _formCubit.close();
    super.dispose();
  }

  void _onToggleStatus(String newStatus) async {
    if (widget.stage == null) return;
    final bool shouldBeActive = newStatus.toLowerCase() == 'active';
    if ((_currentStatus.toLowerCase() == 'active') == shouldBeActive) return;

    showLoadingIndicator();
    final bool saved = await widget.cubit.toggleStageStatus(widget.stage!);
    hideLoadingIndicator();
    if (saved && mounted) {
      setState(() => _currentStatus = newStatus);
      CrmControlDialogs.showSuccessDialog(
        context: context,
        title: S.current.crmSuccess,
        subtitle: S.current.crmStageUpdatedSuccess,
      );
    }
  }

  void _onDeleteStage() {
    if (widget.stage == null) return;
    CrmControlDialogs.showRemoveDialog(
      context: context,
      title: S.current.crmDeleteStage,
      subtitle: S.current.crmDeleteStageConfirm,
      onConfirm: () async {
        showLoadingIndicator();
        final bool deleted = await widget.cubit.deleteStage(widget.stage!);
        hideLoadingIndicator();
        if (deleted && mounted) {
          Navigator.of(context).pop();
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: S.current.crmStageDeletedSuccess,
          );
        }
      },
    );
  }

  void _onSave() {
    final String en = _nameEnController.text.trim();
    final String ar = _nameArController.text.trim();

    if (en.isEmpty || ar.isEmpty) {
      _formCubit.submitStage(
        stage: widget.stage,
        nameEn: en,
        nameAr: ar,
      );
      return;
    }

    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSave,
      subtitle: S.current.crmSaveSubtitle,
      onConfirm: () {
        showLoadingIndicator();
        _formCubit.submitStage(
          stage: widget.stage,
          nameEn: en,
          nameAr: ar,
        );
      },
    );
  }

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final String thirdTitle = _isReadOnly
        ? (widget.stage?.nameEn.isNotEmpty == true
            ? widget.stage!.nameEn
            : S.current.crmStageDetails)
        : (widget.stage != null
            ? S.current.crmEditStage
            : S.current.crmAddStage);

    return BlocConsumer<CrmDealFormCubit, CrmDealFormState>(
      bloc: _formCubit,
      listener: (BuildContext context, CrmDealFormState state) {
        if (state.submitSucceeded) {
          hideLoadingIndicator();
          Navigator.of(context).pop();
          CrmControlDialogs.showSuccessDialog(
            context: context,
            title: S.current.crmSuccess,
            subtitle: widget.stage != null
                ? S.current.crmStageUpdatedSuccess
                : S.current.crmStageSavedSuccess,
          );
        } else if (state.nameEnError != null || state.nameArError != null) {
          hideLoadingIndicator();
        }
      },
      builder: (BuildContext context, CrmDealFormState state) => Scaffold(
        backgroundColor: AppColors.background,
        body: SideFrameMasterServices(
          titleText: S.current.crm,
          secondTitle: S.current.crmControlDeals,
          thirdTitle: thirdTitle,
          onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
          onSecondTap: () => Navigator.of(context).pop(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Top Read-Only Action Bar (Status Dropdown + Edit & Delete Buttons)
                if (_isReadOnly) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildStatusDropdownButton(),
                      Row(
                        children: <Widget>[
                          CustomEditIcon(
                            title: S.current.edit,
                            onTap: () => setState(() => _isReadOnly = false),
                          ),
                          SizedBox(width: 12.sp),
                          CustomDeleteIcon(
                            title: S.current.delete,
                            onTap: _onDeleteStage,
                            color: AppColors.red,
                            svgColor: AppColors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.sp),
                ],

                // Section Title: Details
                Text(
                  S.current.crmDetails,
                  style: StyleText.fontSize16Weight600,
                ),
                SizedBox(height: 8.sp),

                // Details White Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8.sp),
                  ),
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 1. Stage Name bilingual fields (side by side)
                      buildResponsiveFields(
                        context: context,
                        left: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Stage Name',
                              style: StyleText.fontSize14Weight400,
                            ),
                            SizedBox(height: 6.sp),
                            CustomTextField(
                              controller: _nameEnController,
                              hint: 'Text Here',
                              errorText: state.nameEnError,
                              readOnly: _isReadOnly,
                              textDirection: TextDirection.ltr,
                              onChanged: (_) => _formCubit.clearNameEnError(),
                            ),
                          ],
                        ),
                        right: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'اسم المرحلة',
                              style: StyleText.fontSize14Weight400,
                            ),
                            SizedBox(height: 6.sp),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: CustomTextField(
                                controller: _nameArController,
                                hint: 'اكتب هنا',
                                errorText: state.nameArError,
                                readOnly: _isReadOnly,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                onChanged: (_) => _formCubit.clearNameArError(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.sp),

                      // 2. Display Order Dropdown (Half-row layout on large screen)
                      buildResponsiveFields(
                        context: context,
                        left: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Display Order',
                              style: StyleText.fontSize14Weight400,
                            ),
                            SizedBox(height: 6.sp),
                            CustomDropdown<int>(
                              value: state.selectedOrder,
                              hint: 'Choose',
                              items: state.orderOptions
                                  .map(
                                    (CrmDealOrderOption option) =>
                                        DropdownItem<int>(
                                      value: option.value,
                                      label: option.label,
                                    ),
                                  )
                                  .toList(),
                              onChanged: _isReadOnly
                                  ? null
                                  : (int? val) {
                                      if (val != null) {
                                        _formCubit.selectOrder(val);
                                      }
                                    },
                            ),
                          ],
                        ),
                        right: const SizedBox.shrink(),
                      ),
                      SizedBox(height: 20.sp),

                      // 3. Checklist Progress Section
                      Text(
                        'Checklist Progress',
                        style: StyleText.fontSize14Weight400,
                      ),
                      SizedBox(height: 10.sp),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.checklistInputs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CrmDealChecklistInput item =
                              state.checklistInputs[index];
                          return CrmDealStageChecklistItemRow(
                            key: ValueKey<int>(item.id),
                            index: index,
                            initialNameEn: item.nameEn,
                            initialNameAr: item.nameAr,
                            isReadOnly: _isReadOnly,
                            onNameEnChanged: (String value) => _formCubit
                                .updateChecklistNameEn(item.id, value),
                            onNameArChanged: (String value) => _formCubit
                                .updateChecklistNameAr(item.id, value),
                            onDelete: () =>
                                _formCubit.removeChecklistItem(item.id),
                            canDelete: state.checklistInputs.length > 1,
                          );
                        },
                      ),

                      if (!_isReadOnly) ...[
                        SizedBox(height: 8.sp),
                        // Add Checklist Progress button (dark styled button)
                        customButtonWithSvg(
                          title: 'Checklist Progress',
                          function: _formCubit.addChecklistItem,
                          color: AppColors.black,
                          image: AppAssets.add,
                          widthImage: 12.sp,
                          heightImage: 12.sp,
                          colorBorder: AppColors.transparent,
                          svgColor: AppColors.white,
                          textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.background),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 24.sp),

                // Action Buttons: Discard & Save (Visible only in Edit / Add mode)
                if (!_isReadOnly) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      customButton(
                        title: S.current.crmDiscard,
                        function: () {
                          if (widget.isReadOnly) {
                            setState(() => _isReadOnly = true);
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        color: AppColors.grey,
                        textColor: AppColors.black,
                      ),
                      customButton(
                        title: S.current.crmSave,
                        function:
                            _canSubmit && !state.isSubmitting ? _onSave : () {},
                        color: _canSubmit && !state.isSubmitting
                            ? AppColors.primary
                            : AppColors.disabledGrey,
                        textStyle:
                            StyleText.fontSize14Weight500.copyWith(
                          color: _canSubmit && !state.isSubmitting
                              ? AppColors.black
                              : AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.sp),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdownButton() {
    final bool isActive = _currentStatus.toLowerCase() == 'active';
    final Color bgColor = isActive ? AppColors.green : AppColors.orange;
    final String label = isActive ? S.current.crmActive : S.current.crmInactive;

    return PopupMenuButton<String>(
      onSelected: _onToggleStatus,
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
