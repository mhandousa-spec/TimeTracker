// ****************** FILE INFO ******************
// File Name: crm_template_builder_page.dart
// Purpose: CRM template builder details page inside controls.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/13-custom_edit_icon.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_details_content.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_section_card.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_shared_widgets.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_state_view.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_statistics_grid.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';

class CrmTemplateBuilderPage extends StatefulWidget {
  const CrmTemplateBuilderPage({
    required this.templateId,
    required this.templateName,
    required this.clientTypeId,
    required this.clientType,
    super.key,
  });

  final String templateId;
  final String templateName;
  final String clientTypeId;
  final String clientType;

  @override
  State<CrmTemplateBuilderPage> createState() => _CrmTemplateBuilderPageState();
}

class _CrmTemplateBuilderPageState extends State<CrmTemplateBuilderPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isReadOnly = true;
  String? _selectedCategory;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.templateId.isNotEmpty && widget.clientTypeId.isNotEmpty) {
      context.read<CrmTemplateBuilderCubit>().init(
            templateId: widget.templateId,
            clientTypeId: widget.clientTypeId,
          );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = _fieldCardCrossAxisCount(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crmSectionControls,
        secondTitle: S.current.crmControlTemplates,
        thirdTitle: widget.templateName,
        onFirstTap: () => CrmNavigationHelper.pop(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocConsumer<CrmTemplateBuilderCubit, CrmTemplateBuilderState>(
          listener: (context, state) {},
          builder: (context, state) {
            final bool isMobile = MediaQuery.of(context).size.width < 600;
            final CrmTemplateModel? template = state.template;
            final String templateName = template?.nameEn ?? widget.templateName;
            final String templateNameAr = template?.nameAr ?? 'الاسم';

            return CrmTemplateStateView(
              overlayLoading: false,
              isLoading: state.isLoading && state.template == null,
              errorMessage: state.template == null &&
                      state.sections.isEmpty &&
                      state.fields.isEmpty
                  ? state.errorMessage
                  : null,
              onRetry: () => context.read<CrmTemplateBuilderCubit>().init(
                    templateId: widget.templateId,
                    clientTypeId: widget.clientTypeId,
                  ),
              minHeight: MediaQuery.sizeOf(context).height - 160.sp,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.sp,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CrmTemplateStatusButton(
                            initialStatus: _statusLabel(template?.status),
                            onChanged: (String newStatus) =>
                                _confirmTemplateStatus(context, newStatus),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomEditIcon(
                                onTap: () => _showEditTemplateDialog(
                                  context,
                                  nameEn: templateName,
                                  nameAr: templateNameAr,
                                ),
                              ),
                              SizedBox(width: isMobile ? 8.sp : 12.w),
                              CustomDeleteIcon(
                                color: AppColors.red,
                                svgColor: AppColors.black,
                                onTap: () => _confirmRemoveTemplate(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14.sp),
                      CrmTemplateSectionShell(
                        title: 'Template Details',
                        child: CrmTemplateDetailsContent(
                          isReadOnly: _isReadOnly,
                          nameEn: templateName,
                          nameAr: templateNameAr,
                        ),
                      ),
                      SizedBox(height: 24.sp),
                      Text(
                        'Fields & Sections',
                        style: StyleText.fontSize16Weight600.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: 14.sp),
                      CrmTemplateStatisticsGrid(fields: state.fields),
                      SizedBox(height: 24.sp),
                      if (isMobile) ...[
                        Row(
                          children: [
                            Expanded(
                              child: AppSearchTextField(
                                // expanded: false — AppSearchTextField supplies its own Expanded;
                                // nesting it inside this one throws ParentDataWidget.
                                expanded: false,
                                controller: _searchController,
                                onChanged: context
                                    .read<CrmTemplateBuilderCubit>()
                                    .search,
                                hintText: S.current.crmSearch,
                              ),
                            ),
                            SizedBox(width: 8.sp),
                            customButtonWithSvg(
                              title: '',
                              function: () {
                                CrmNavigationHelper
                                    .navigateToControlTemplateLayout(
                                  context,
                                  templateId: widget.templateId,
                                  templateName: templateName,
                                  clientTypeId: widget.clientTypeId,
                                  clientType: widget.clientType,
                                );
                              },
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                              color: AppColors.primary,
                              image: AppAssets.crmTemplate,
                              widthImage: 18.sp,
                              heightImage: 18.sp,
                              colorBorder: AppColors.primary,
                              svgColor: AppColors.black,
                            ),
                            SizedBox(width: 8.sp),
                            customButtonWithSvg(
                              title: '',
                              function: () {
                                CrmNavigationHelper
                                    .navigateToControlTemplateElementForm(
                                  context,
                                  templateId: widget.templateId,
                                  templateName: templateName,
                                  clientTypeId: widget.clientTypeId,
                                  clientType: widget.clientType,
                                );
                              },
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                              color: AppColors.primary,
                              image: AppAssets.crmPlusBold,
                              widthImage: 18.sp,
                              heightImage: 18.sp,
                              colorBorder: AppColors.primary,
                              svgColor: AppColors.black,
                            ),
                          ],
                        ),
                        if (state.sections.isNotEmpty ||
                            state.fieldTypes.isNotEmpty) ...[
                          SizedBox(height: 10.sp),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 38.sp,
                                  child: CustomDropdown<String>(
                                    value: _selectedCategory,
                                    hint: 'Category',
                                    items: <String>[
                                      'All',
                                      ...state.sections.map((s) =>
                                          s.nameEn.isEmpty
                                              ? s.nameAr
                                              : s.nameEn),
                                    ]
                                        .map(
                                          (opt) => DropdownItem<String>(
                                            value: opt,
                                            label: opt,
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() => _selectedCategory = val);
                                      context
                                          .read<CrmTemplateBuilderCubit>()
                                          .search(val == 'All' ? '' : val);
                                    },
                                    fillColor: AppColors.card,
                                    borderRadius: BorderRadius.circular(8.sp),
                                    valueStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                        .copyWith(color: AppColors.black),
                                    hintStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                        .copyWith(
                                            color: AppColors.secondaryBlack),
                                    itemStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                        .copyWith(color: AppColors.black),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.sp),
                              Expanded(
                                child: SizedBox(
                                  height: 38.sp,
                                  child: CustomDropdown<String>(
                                    value: _selectedType,
                                    hint: 'Type',
                                    items: <String>[
                                      'All',
                                      ...state.fieldTypes.map((ft) =>
                                          ft.nameEn.isEmpty
                                              ? ft.nameAr
                                              : ft.nameEn),
                                    ]
                                        .map(
                                          (opt) => DropdownItem<String>(
                                            value: opt,
                                            label: opt,
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      setState(() => _selectedType = val);
                                      context
                                          .read<CrmTemplateBuilderCubit>()
                                          .search(val == 'All' ? '' : val);
                                    },
                                    fillColor: AppColors.card,
                                    borderRadius: BorderRadius.circular(8.sp),
                                    valueStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                        .copyWith(color: AppColors.black),
                                    hintStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                        .copyWith(
                                            color: AppColors.secondaryBlack),
                                    itemStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                        .copyWith(color: AppColors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: AppSearchTextField(
                                // expanded: false — AppSearchTextField supplies its own Expanded;
                                // nesting it inside this one throws ParentDataWidget.
                                expanded: false,
                                controller: _searchController,
                                onChanged: context
                                    .read<CrmTemplateBuilderCubit>()
                                    .search,
                                hintText: S.current.crmSearch,
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            SizedBox(
                              width: 130.sp,
                              height: 38.sp,
                              child: CustomDropdown<String>(
                                value: _selectedCategory,
                                hint: 'Category',
                                items: <String>[
                                  'All',
                                  ...state.sections.map((s) =>
                                      s.nameEn.isEmpty ? s.nameAr : s.nameEn),
                                ]
                                    .map(
                                      (opt) => DropdownItem<String>(
                                        value: opt,
                                        label: opt,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _selectedCategory = val);
                                  context
                                      .read<CrmTemplateBuilderCubit>()
                                      .search(val == 'All' ? '' : val);
                                },
                                fillColor: AppColors.card,
                                borderRadius: BorderRadius.circular(8.sp),
                                valueStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                    .copyWith(color: AppColors.black),
                                hintStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                    .copyWith(color: AppColors.secondaryBlack),
                                itemStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                    .copyWith(color: AppColors.black),
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            SizedBox(
                              width: 130.sp,
                              height: 38.sp,
                              child: CustomDropdown<String>(
                                value: _selectedType,
                                hint: 'Type',
                                items: <String>[
                                  'All',
                                  ...state.fieldTypes.map((ft) =>
                                      ft.nameEn.isEmpty
                                          ? ft.nameAr
                                          : ft.nameEn),
                                ]
                                    .map(
                                      (opt) => DropdownItem<String>(
                                        value: opt,
                                        label: opt,
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => _selectedType = val);
                                  context
                                      .read<CrmTemplateBuilderCubit>()
                                      .search(val == 'All' ? '' : val);
                                },
                                fillColor: AppColors.card,
                                borderRadius: BorderRadius.circular(8.sp),
                                valueStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                    .copyWith(color: AppColors.black),
                                hintStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                    .copyWith(color: AppColors.secondaryBlack),
                                itemStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack)
                                    .copyWith(color: AppColors.black),
                              ),
                            ),
                            SizedBox(width: 12.sp),
                            customButtonWithSvg(
                              title: 'Layout',
                              function: () {
                                CrmNavigationHelper
                                    .navigateToControlTemplateLayout(
                                  context,
                                  templateId: widget.templateId,
                                  templateName: templateName,
                                  clientTypeId: widget.clientTypeId,
                                  clientType: widget.clientType,
                                );
                              },
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                              color: AppColors.primary,
                              image: AppAssets.crmTemplate,
                              widthImage: 18.sp,
                              heightImage: 18.sp,
                              colorBorder: AppColors.primary,
                              svgColor: AppColors.black,
                            ),
                            SizedBox(width: 12.sp),
                            customButtonWithSvg(
                              title: S.current.crmAdd,
                              function: () {
                                CrmNavigationHelper
                                    .navigateToControlTemplateElementForm(
                                  context,
                                  templateId: widget.templateId,
                                  templateName: templateName,
                                  clientTypeId: widget.clientTypeId,
                                  clientType: widget.clientType,
                                );
                              },
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                              color: AppColors.primary,
                              image: AppAssets.crmPlusBold,
                              widthImage: 18.sp,
                              heightImage: 18.sp,
                              colorBorder: AppColors.primary,
                              svgColor: AppColors.black,
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 28.sp),
                      // The full-page state view above handles loading and
                      // errors for the whole page (status button included); this
                      // wrapper only keeps the grid/empty area tall.
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height - 460.sp,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: state.filteredSections.isEmpty &&
                                  state.filteredFields.isEmpty
                              ? const Center(child: CrmTemplateEmptyState())
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 14.sp,
                                    mainAxisSpacing: 14.sp,
                                    mainAxisExtent: 40.sp,
                                  ),
                                  itemCount: state.filteredSections.length +
                                      state.filteredFields.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < state.filteredSections.length) {
                                      final CrmTemplateSectionModel section =
                                          state.filteredSections[index];
                                      return CrmTemplateSectionCard(
                                        title: section.nameEn,
                                        fieldCount: context
                                            .read<CrmTemplateBuilderCubit>()
                                            .fieldCountForSection(section.id),
                                        onTap: () {
                                          CrmNavigationHelper
                                              .navigateToControlTemplateElementForm(
                                            context,
                                            templateId: widget.templateId,
                                            templateName: templateName,
                                            clientTypeId: widget.clientTypeId,
                                            clientType: widget.clientType,
                                            sectionId: section.id,
                                            isSection: true,
                                          );
                                        },
                                      );
                                    }
                                    final CrmTemplateFieldModel field = state
                                            .filteredFields[
                                        index - state.filteredSections.length];
                                    final CrmFieldTypeModel? fieldType =
                                        _fieldTypeById(
                                            state, field.fieldTypeId);
                                    return CrmTemplateFieldCard(
                                      title: field.nameEn,
                                      fieldTypeLabel: fieldType?.nameEn ??
                                          _fieldTypeFallback(field),
                                      iconKey: fieldType?.iconKey ??
                                          field.fieldTypeId,
                                      onTap: () {
                                        CrmNavigationHelper
                                            .navigateToControlTemplateElementForm(
                                          context,
                                          templateId: widget.templateId,
                                          templateName: templateName,
                                          clientTypeId: widget.clientTypeId,
                                          clientType: widget.clientType,
                                          fieldId: field.id,
                                          isSection: false,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _statusLabel(String? status) {
    final String value = (status ?? '').trim().toLowerCase();
    if (value.isEmpty || value == 'draft' || value == 'inactive') {
      return 'Inactive';
    }
    if (value == 'deleted') return 'Deleted';
    return 'Active';
  }

  int _fieldCardCrossAxisCount(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= 1500.sp) return 5;
    if (width >= 1180.sp) return 4;
    if (width >= 760.sp) return 3;
    return 1;
  }

  Future<bool> _confirmTemplateStatus(
    BuildContext context,
    String newStatus,
  ) async {
    final CrmTemplateBuilderCubit cubit =
        context.read<CrmTemplateBuilderCubit>();
    final String currentStatus = _statusLabel(cubit.state.template?.status);
    if (currentStatus == newStatus) return true;

    bool changed = false;
    await CrmControlDialogs.showChangeStatusDialog(
      context: context,
      onConfirm: () async {
        changed = await cubit.updateTemplateStatus(newStatus);
        if (!mounted || !changed) return;
        await CrmControlDialogs.showSuccessDialog(
          context: this.context,
          title: 'Successful!',
          subtitle: 'submit successfully.',
        );
      },
    );
    return changed;
  }

  Future<void> _confirmRemoveTemplate(BuildContext context) async {
    await CrmControlDialogs.showRemoveDialog(
      context: context,
      title: 'Delete Template',
      subtitle: 'Are you sure to delete this template?',
      onConfirm: () async {
        final CrmTemplateBuilderCubit cubit =
            this.context.read<CrmTemplateBuilderCubit>();
        final bool removed = await cubit.updateTemplateStatus('Deleted');
        if (!mounted || !removed) return;
        await CrmControlDialogs.showSuccessDialog(
          context: this.context,
          title: 'Successful!',
          subtitle: 'Removed successfully.',
        );
      },
    );
  }

  Future<void> _showEditTemplateDialog(
    BuildContext context, {
    required String nameEn,
    required String nameAr,
  }) async {
    await CrmControlDialogs.showEditTemplateDialog(
      context: context,
      nameEn: nameEn,
      nameAr: nameAr,
      onConfirm: (String updatedNameEn, String updatedNameAr) {
        _updateTemplateNames(context, updatedNameEn, updatedNameAr);
      },
    );
  }

  Future<void> _updateTemplateNames(
    BuildContext context,
    String nameEn,
    String nameAr,
  ) async {
    final CrmTemplateBuilderCubit cubit =
        context.read<CrmTemplateBuilderCubit>();
    final bool updated =
        await cubit.updateTemplateNames(nameEn: nameEn, nameAr: nameAr);
    if (!mounted || !updated) return;
    setState(() => _isReadOnly = true);
    await CrmControlDialogs.showSuccessDialog(
      context: this.context,
      title: 'Successful!',
      subtitle: 'submit successfully.',
    );
  }

  CrmFieldTypeModel? _fieldTypeById(
    CrmTemplateBuilderState state,
    String fieldTypeId,
  ) {
    for (final CrmFieldTypeModel type in state.fieldTypes) {
      if (type.id == fieldTypeId) return type;
    }
    return null;
  }

  String _fieldTypeFallback(CrmTemplateFieldModel field) {
    if (field.fieldTypeId.trim().isEmpty) return 'Field Type';
    return field.fieldTypeId;
  }
}
