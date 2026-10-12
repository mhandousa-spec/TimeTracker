// ****************** FILE INFO ******************
// File Name: crm_merge_levels_page.dart
// Purpose: CRM Merge settings and likelihood-level management page.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/58-default_switch_button.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/98-custom_search_filter_sort_bar.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_merge_level_form_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_merge_level_card.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CrmMergeLevelsPage extends StatefulWidget {
  const CrmMergeLevelsPage({super.key});

  @override
  State<CrmMergeLevelsPage> createState() => _CrmMergeLevelsPageState();
}

class _CrmMergeLevelsPageState extends State<CrmMergeLevelsPage> {
  late final TextEditingController _searchController;
  late final TextEditingController _durationController;
  bool _isEditingSettings = false;
  bool _undoEnabled = true;
  MergeDurationUnit _durationUnit = MergeDurationUnit.days;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _durationController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CrmMergeLevelsCubit>().init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _startSettingsEdit(CrmMergeSettingsModel settings) {
    setState(() {
      _isEditingSettings = true;
      _undoEnabled = settings.undoEnabled;
      _durationUnit = settings.durationUnit;
      _durationController.text = settings.durationValue.toString();
    });
  }

  Future<void> _saveSettings() async {
    final int? duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration < 1) return;
    showLoadingIndicator();
    final bool saved = await context.read<CrmMergeLevelsCubit>().saveSettings(
          undoEnabled: _undoEnabled,
          durationValue: duration,
          durationUnit: _durationUnit,
        );
    hideLoadingIndicator();
    if (mounted && saved) setState(() => _isEditingSettings = false);
  }

  List<StatusChipItem> _statusItems(CrmMergeLevelsState state) =>
      <StatusChipItem>[
        StatusChipItem(
          key: 'All',
          label: S.current.crmAll,
          count: state.items.length,
        ),
        StatusChipItem(
          key: 'Active',
          label: S.current.crmActive,
          count: state.items.where((item) => item.isActive).length,
          labelColor: AppColors.green,
        ),
        StatusChipItem(
          key: 'Inactive',
          label: S.current.crmInactive,
          count: state.items.where((item) => !item.isActive).length,
          labelColor: AppColors.orange,
        ),
      ];

  String _unitLabel(MergeDurationUnit unit) => switch (unit) {
        MergeDurationUnit.minutes => S.current.crmMergeMinutes,
        MergeDurationUnit.hours => S.current.crmMergeHours,
        MergeDurationUnit.days => S.current.crmMergeDays,
        MergeDurationUnit.weeks => S.current.crmMergeWeeks,
        MergeDurationUnit.months => S.current.crmMergeMonths,
        MergeDurationUnit.years => S.current.crmMergeYears,
      };

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final int crossAxisCount = isMobile
        ? 1
        : CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmSectionControls,
        thirdTitle: S.current.crmSectionMerge,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocBuilder<CrmMergeLevelsCubit, CrmMergeLevelsState>(
          builder: (BuildContext context, CrmMergeLevelsState state) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildSettings(state.settings, isMobile),
                  SizedBox(height: 24.sp),
                  Text(
                    S.current.crmMergePossibleLevel,
                    style: StyleText.fontSize16Weight600,
                  ),
                  SizedBox(height: 12.sp),
                  if (state.items.isNotEmpty) ...<Widget>[
                    StatusChipFilter(
                      selectedKey: state.selectedStatus,
                      onSelected:
                          context.read<CrmMergeLevelsCubit>().selectStatus,
                      items: _statusItems(state),
                    ),
                    SizedBox(height: 14.sp),
                  ],
                  _buildToolbar(state),
                  SizedBox(height: 16.sp),
                  if (state.isLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.sp),
                      child: const Center(child: CircleProgressMaster()),
                    )
                  else if (state.filteredItems.isEmpty)
                    _buildEmptyState()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent: 96.sp,
                        crossAxisSpacing: 14.sp,
                        mainAxisSpacing: 14.sp,
                      ),
                      itemCount: state.filteredItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final CrmMergeLevelModel item =
                            state.filteredItems[index];
                        return CrmMergeLevelCard(
                          level: item,
                          onTap: () =>
                              CrmNavigationHelper.navigateToControlMergeForm(
                            context,
                            arguments: <String, dynamic>{
                              'mode': CrmMergeLevelFormMode.details,
                              'level': item,
                            },
                          ),
                        );
                      },
                    ),
                  if (state.errorMessage != null) ...<Widget>[
                    SizedBox(height: 12.sp),
                    Text(
                      state.errorMessage!,
                      style: StyleText.fontSize12Weight400
                          .copyWith(color: AppColors.red),
                    ),
                  ],
                  SizedBox(height: 32.sp),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolbar(CrmMergeLevelsState state) {
    return CustomSearchFilterSortBar<String, String>(
      searchController: _searchController,
      searchHint: S.current.crmSearch,
      onSearchChanged: context.read<CrmMergeLevelsCubit>().search,
      showFilter: true,
      filterItems: const <String>['All', 'Active', 'Inactive'],
      selectedFilter: state.selectedStatus,
      filterTitle: S.current.crmFilter,
      filterLabelBuilder: (String value) => value == 'All'
          ? S.current.crmAll
          : value == 'Active'
              ? S.current.crmActive
              : S.current.crmInactive,
      onFilterChanged: (String? value) =>
          context.read<CrmMergeLevelsCubit>().selectStatus(value ?? 'All'),
      showSort: true,
      selectedSort: state.selectedSort,
      sortTitle: S.current.crmSort,
      sortItems: const <String>[
        'name_asc',
        'name_desc',
        'range_asc',
        'range_desc'
      ],
      sortLabelBuilder: (String value) => switch (value) {
        'name_asc' => S.current.crmSortNameAZ,
        'name_desc' => S.current.crmSortNameZA,
        'range_asc' => S.current.crmMergeSortRangeAsc,
        _ => S.current.crmMergeSortRangeDesc,
      },
      onSortChanged: context.read<CrmMergeLevelsCubit>().setSort,
      trailingActionsBuilder: (BuildContext context, bool isPhone) => <Widget>[
        customButtonWithSvg(
          title: isPhone ? '' : S.current.crmAdd,
          function: () => CrmNavigationHelper.navigateToControlMergeForm(
            context,
            arguments: <String, dynamic>{'mode': CrmMergeLevelFormMode.add},
          ),
          textStyle: StyleText.fontSize14Weight600
              .copyWith(color: AppColors.black),
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: AppAssets.add,
          widthImage: 20.sp,
          heightImage: 20.sp,
          svgColor: AppColors.black,
        ),
      ],
    );
  }

  Widget _buildSettings(CrmMergeSettingsModel settings, bool isMobile) {
    if (!_isEditingSettings) return _buildSettingsView(settings, isMobile);
    return CrmSectionCard(
      title: S.current.crmMergeSettings,
      showHideToggle: false,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Text(S.current.crmMergeUndoMode,
                  style: StyleText.fontSize14Weight500),
              SizedBox(width: 16.sp),
              DefaultSwitchButton(
                value: _undoEnabled,
                onChanged: (bool value) => setState(() => _undoEnabled = value),
              ),
            ]),
            SizedBox(height: 16.sp),
            Text(S.current.crmMergeDuration,
                style: StyleText.fontSize14Weight500),
            SizedBox(height: 8.sp),
            Row(children: <Widget>[
              Expanded(
                  child: CustomTextField(
                hint: '1',
                controller: _durationController,
                keyboardType: TextInputType.number,
              )),
              SizedBox(width: 12.sp),
              Expanded(
                  child: CustomDropdown<MergeDurationUnit>(
                value: _durationUnit,
                items: MergeDurationUnit.values
                    .map((unit) => DropdownItem<MergeDurationUnit>(
                          value: unit,
                          label: _unitLabel(unit),
                        ))
                    .toList(),
                onChanged: (MergeDurationUnit unit) =>
                    setState(() => _durationUnit = unit),
              )),
            ]),
            SizedBox(height: 20.sp),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  customButton(
                    title: S.current.crmDiscard,
                    function: () => setState(() => _isEditingSettings = false),
                    color: AppColors.grey,
                    textColor: AppColors.black,
                  ),
                  customButton(
                    title: S.current.crmSave,
                    function: _saveSettings,
                    color: AppColors.primary,
                    textColor: AppColors.black,
                  ),
                ]),
          ]),
    );
  }

  Widget _buildSettingsView(CrmMergeSettingsModel settings, bool isMobile) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: customButtonWithSvg(
              title: isMobile ? '' : S.current.edit,
              function: () => _startSettingsEdit(settings),
              textStyle: StyleText.fontSize14Weight600
                  .copyWith(color: AppColors.black),
              color: AppColors.primary,
              colorBorder: AppColors.transparent,
              image: AppAssets.edit,
              widthImage: 18.sp,
              heightImage: 18.sp,
              svgColor: AppColors.black,
            ),
          ),
          SizedBox(height: 8.sp),
          CrmSectionCard(
            title: S.current.crmMergeSettings,
            showHideToggle: false,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(children: <Widget>[
                    Text(S.current.crmMergeUndoMode,
                        style: StyleText.fontSize14Weight500),
                    SizedBox(width: 16.sp),
                    DefaultSwitchButton(
                        value: settings.undoEnabled, onChanged: (_) {}),
                  ]),
                  SizedBox(height: 16.sp),
                  Text(S.current.crmMergeDuration,
                      style: StyleText.fontSize14Weight500),
                  SizedBox(height: 8.sp),
                  Row(children: <Widget>[
                    Expanded(
                      child: CustomTextField(
                        key: ValueKey<String>(
                          'merge-duration-${settings.durationValue}',
                        ),
                        initialValue: settings.durationValue.toString(),
                        readOnly: true,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: CustomDropdown<MergeDurationUnit>(
                        value: settings.durationUnit,
                        enabled: false,
                        items: MergeDurationUnit.values
                            .map((MergeDurationUnit unit) =>
                                DropdownItem<MergeDurationUnit>(
                                  value: unit,
                                  label: _unitLabel(unit),
                                ))
                            .toList(),
                      ),
                    ),
                  ]),
                ]),
          ),
        ]);
  }

  Widget _buildEmptyState() => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.sp),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            CustomSvgImage(
              assetPath: AppAssets.crmRelationshipEmpty,
              width: 140.sp,
              height: 140.sp,
            ),
            SizedBox(height: 16.sp),
            Text(
              S.current.crmMergeNoLevels,
              style: StyleText.fontSize16Weight600,
            ),
          ]),
        ),
      );
}
