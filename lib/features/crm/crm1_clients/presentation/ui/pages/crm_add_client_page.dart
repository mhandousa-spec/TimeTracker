// ****************** FILE INFO ******************
// File Name: crm_add_client_page.dart
// Purpose: Page for creating/editing a CRM client using dynamic form engine with custom confirmation and success dialogs
// Author: Mohand Adel
// Created At: 03/08/2026

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_form_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_dynamic_form_renderer.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmAddClientPage extends StatefulWidget {
  const CrmAddClientPage({
    super.key,
    this.templateName = 'Add New Client',
    this.clientType,
    this.clientTypeId,
    this.templateId,
    this.editingRecord,
  });

  final String templateName;
  final String? clientType;
  final String? clientTypeId;
  final String? templateId;
  final CrmClientRecordModel? editingRecord;

  @override
  State<CrmAddClientPage> createState() => _CrmAddClientPageState();
}

class _CrmAddClientPageState extends State<CrmAddClientPage> {
  List<CrmTemplateFieldModel> _submittableFields = <CrmTemplateFieldModel>[];

  @override
  void initState() {
    super.initState();
    final CrmClientFormCubit cubit = context.read<CrmClientFormCubit>();
    cubit.init(
      clientTypeId: widget.clientTypeId,
      clientTypeName: widget.clientType ?? widget.templateName,
      templateId: widget.templateId,
      editingRecord: widget.editingRecord,
    );
  }

  void _onSavePressed(BuildContext context) {
    CrmControlDialogs.showSaveDialog(
      context: context,
      title: S.current.crmSaveClientRecord,
      subtitle: S.current.crmSaveClientConfirm,
      onConfirm: () => _submitAfterConfirmation(context),
    );
  }

  Future<void> _submitAfterConfirmation(BuildContext context) async {
    if (!mounted) return;
    final CrmClientFormCubit cubit = context.read<CrmClientFormCubit>();
    final List<CrmTemplateFieldModel> validationFields =
        _submittableFields.isEmpty ? cubit.state.fields : _submittableFields;
    if (!cubit.validateForm(fields: validationFields)) return;

    showLoadingIndicator();
    final bool saved = await cubit.submitClientRecord(
      validationFields: validationFields,
    );
    hideLoadingIndicator();

    if (!mounted || !saved) return;
    final String? clientId = cubit.state.clientId;
    await CrmControlDialogs.showSuccessDialog(
      context: this.context,
      title: S.current.crmClientAddedSuccessfully,
      subtitle: S.current.crmClientAddedSubtitle,
      onComplete: () {
        if (!mounted) return;
        CrmNavigationHelper.pop(this.context, clientId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmClients,
        thirdTitle: widget.templateName,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocBuilder<CrmClientFormCubit, CrmClientFormState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const CircleProgressMaster();
            }

            if (state.errorMessage != null && !state.isLoaded) {
              return _buildErrorState(context);
            }

            if (!state.isLoaded) {
              return const SizedBox.shrink();
            }

            return _buildForm(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final String? message =
        context.read<CrmClientFormCubit>().state.errorMessage;
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message ?? S.current.crmFieldRequired,
              textAlign: TextAlign.center,
              style: StyleText.fontSize16Weight600.copyWith(
                color: AppColors.red,
              ),
            ),
            SizedBox(height: 16.sp),
            customButton(
              title: S.current.crmAddNewClient,
              function: () {
                context.read<CrmClientFormCubit>().init(
                      clientTypeId: widget.clientTypeId,
                      clientTypeName: widget.clientType ?? widget.templateName,
                      templateId: widget.templateId,
                    );
              },
              color: AppColors.primary,
              textStyle: StyleText.fontSize16Weight600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CrmClientFormState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrmDynamicFormRenderer(
            sections: state.sections,
            fields: state.fields,
            layout: state.layout,
            formValues: state.formValues,
            formErrors: state.formErrors,
            isSubmitting: state.isSubmitting,
            onFieldValueChanged: (String fieldId, dynamic value) =>
                context.read<CrmClientFormCubit>().onFieldValueChanged(
                      fieldId,
                      value,
                    ),
            onValidatePageFields: (List<CrmTemplateFieldModel> fields) =>
                context.read<CrmClientFormCubit>().validateFields(fields),
            onRenderableFieldsChanged: (List<CrmTemplateFieldModel> fields) {
              _submittableFields = fields;
            },
            actionsBuilder: (_) => _buildActions(
              context,
              isSubmitting: state.isSubmitting,
              canSubmit: context.read<CrmClientFormCubit>().canSubmit(
                    fields: _submittableFields.isEmpty
                        ? state.fields
                        : _submittableFields,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context, {
    required bool isSubmitting,
    required bool canSubmit,
  }) {
    final bool isAddEnabled = canSubmit && !isSubmitting;
    return Padding(
      padding: EdgeInsets.only(top: 16.sp, bottom: 24.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              customButton(
                title: S.current.crmDiscard,
                function: () => CrmNavigationHelper.pop(context),
                color: AppColors.lightGrey,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.black,
                ),
              ),
              customButton(
                title: S.current.crmAdd,
                function: isAddEnabled ? () => _onSavePressed(context) : () {},
                color:
                    isAddEnabled ? AppColors.primary : AppColors.disabledGrey,
                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: isAddEnabled ? AppColors.black : AppColors.darkGrey,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.sp),
          customButton(
            title: S.current.crmSaveForLater,
            function: isSubmitting ? () {} : () => _onSavePressed(context),
            color: AppColors.darkGrey,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
