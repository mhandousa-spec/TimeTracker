// ****************** FILE INFO ******************
// File Name: crm_deal_stage_form_dialog.dart
// Purpose: Modal dialog for adding or editing CRM Deal Stages
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deal_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deal_form_state.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/controller/crm_deals_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmDealStageFormDialog extends StatefulWidget {
  final CrmDealStageModel? stage;
  final bool isEditing;
  final CrmDealFormCubit formCubit;

  const CrmDealStageFormDialog({
    super.key,
    this.stage,
    this.isEditing = false,
    required this.formCubit,
  });

  /// Function Name: show
  ///
  /// Purpose: Static helper to display the Add/Edit Stage modal dialog.
  static void show({
    required BuildContext context,
    required CrmDealsCubit dealsCubit,
    CrmDealStageModel? stage,
    bool isEditing = false,
  }) {
    final CrmDealFormCubit formCubit = CrmDealFormCubit(dealsCubit: dealsCubit)
      ..prepareStage(stage: stage, isEditing: isEditing);
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => CrmDealStageFormDialog(
        stage: stage,
        isEditing: isEditing,
        formCubit: formCubit,
      ),
    );
  }

  @override
  State<CrmDealStageFormDialog> createState() => _CrmDealStageFormDialogState();
}

class _CrmDealStageFormDialogState extends State<CrmDealStageFormDialog> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final TextEditingController _probabilityController;

  bool get _hasChanges {
    if (!widget.isEditing) return true;
    final String currentEn = _nameEnController.text.trim();
    final String currentAr = _nameArController.text.trim();
    final String currentProb = _probabilityController.text.trim();
    final String initialEn = widget.stage?.nameEn.trim() ?? '';
    final String initialAr = widget.stage?.nameAr.trim() ?? '';
    final String initialProb = widget.stage?.probability.toString() ?? '';
    return currentEn != initialEn ||
        currentAr != initialAr ||
        currentProb != initialProb;
  }

  bool get _canSubmit =>
      _nameEnController.text.trim().isNotEmpty &&
      _nameArController.text.trim().isNotEmpty &&
      _hasChanges;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.stage?.nameEn ?? '');
    _nameArController = TextEditingController(text: widget.stage?.nameAr ?? '');
    _probabilityController = TextEditingController(
      text: widget.formCubit.state.probabilityText,
    );
    _nameEnController.addListener(_refreshSubmitState);
    _nameArController.addListener(_refreshSubmitState);
    _probabilityController.addListener(_refreshSubmitState);
  }

  void _refreshSubmitState() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _probabilityController.dispose();
    widget.formCubit.close();
    super.dispose();
  }

  void _onSave() {
    widget.formCubit.submitStage(
      stage: widget.stage,
      nameEn: _nameEnController.text,
      nameAr: _nameArController.text,
      probabilityText: _probabilityController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        widget.isEditing ? S.current.crmEditStage : S.current.crmAddStage;

    return BlocConsumer<CrmDealFormCubit, CrmDealFormState>(
      bloc: widget.formCubit,
      listener: (BuildContext context, CrmDealFormState state) {
        if (state.submitSucceeded) Navigator.of(context).pop();
      },
      builder: (BuildContext context, CrmDealFormState state) => Dialog(
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
                      assetPath: AppAssets.crmTagField,
                      width: 26.sp,
                      height: 26.sp,
                      color: AppColors.black,
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
                  errorText: state.nameEnError,
                  textDirection: TextDirection.ltr,
                  onChanged: (_) {
                    widget.formCubit.clearNameEnError();
                    setState(() {});
                  },
                ),
                SizedBox(height: 14.sp),

                // Name AR Field
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اسم المرحلة',
                    style: StyleText.fontSize14Weight400,
                  ),
                ),
                SizedBox(height: 6.sp),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomTextField(
                    controller: _nameArController,
                    hint: 'اكتب هنا',
                    errorText: state.nameArError,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    onChanged: (_) {
                      widget.formCubit.clearNameArError();
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(height: 14.sp),

                // Probability Field (%)
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
                  hint: '0 - 100 %',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textDirection: TextDirection.ltr,
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
