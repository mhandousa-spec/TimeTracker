// ***************************** FILE INFO ***************************** //
// File Name: health_insurance_tab_page.dart
// Purpose: Displays the searchable table-only employee health-insurance view.
// Author: Mohamed Elrashidy
// Created At: 2026-08-10
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/constants/app_assets.dart';
import '../../../../../../core/constants/hr_module/hr_assets.dart';
import '../../../../../../core/custom/14-custom_filter_icon.dart';
import '../../../../../../core/custom/35-custom_search_widget_custom.dart';
import '../../../../../../core/custom/6-custom_button_with_svg.dart';
import '../../../../../../core/custom/66-circle_progress.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/helper/hr/hr_routes.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../controller/cubit/health_insurance_cubit.dart';
import '../widgets/health_insurance_filter_dialog.dart';
import '../../../utils/enums/employee_upload_controllers/employee_info.dart';
import '../../../utils/hr_table_display_value.dart';
import '../widgets/hr_table_viewport.dart';
import '../widgets/hr_table_excel_export_action.dart';

/// Renders all employee health-insurance values in a table-only layout.
class HealthInsuranceTabPage extends StatefulWidget {
  const HealthInsuranceTabPage({super.key});

  @override
  State<HealthInsuranceTabPage> createState() => _HealthInsuranceTabPageState();
}

class _HealthInsuranceTabPageState extends State<HealthInsuranceTabPage> {
  late final HealthInsuranceCubit _cubit;
  late final TextEditingController _searchController;
  final HrTableExcelExportAction _exportAction = HrTableExcelExportAction();

  @override
  void initState() {
    super.initState();
    _cubit = HealthInsuranceCubit(dataCubit: context.read<HrModuleDataCubit>());
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<HealthInsuranceCubit, HealthInsuranceState>(
        builder: (context, state) => Column(
          children: [
            _buildToolbar(context, state),
            SizedBox(height: 16.h),
            Expanded(child: _buildTable(context, state)),
          ],
        ),
      ),
    );
  }

  /// Method Name: [_buildToolbar]
  ///
  /// Purpose: Builds the shared table toolbar without view-mode controls.
  ///
  /// Parameters:
  /// - [context]: Provides localization and responsive layout data.
  ///
  /// Returns: Search and action controls for health-insurance data.
  Widget _buildToolbar(BuildContext context, HealthInsuranceState state) {
    final actions = [
      CustomFilterIcon(
        title: S.of(context).filter,
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: _cubit,
            child: const HealthInsuranceFilterDialog(),
          ),
        ),
        color: AppColors.card,
        svgColor: AppColors.inverseBase,
        textStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.inverseBase),
      ),
      customButtonWithSvg(
        title: S.of(context).export,
        function: () => _exportHealthInsurance(context, state),
        textStyle:
            StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: AppAssets.export,
        widthImage: 20.sp,
        heightImage: 20.sp,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      ),
      customButtonWithSvg(
        title: S.of(context).bulkUpload,
        function: () async {
          final updated = await Navigator.of(context)
              .pushNamed(HRRoutes.hrModuleBulkUploadHealthInsurancePage);
          if (updated == true && mounted) {
            await _cubit.refreshInsuranceDetails();
          }
        },
        textStyle:
            StyleText.fontSize14Weight400.copyWith(color: AppColors.textButton),
        color: AppColors.primary,
        image: HRAssets.hrEmployeeOperations,
        widthImage: 20.sp,
        heightImage: 20.sp,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final search = AppSearchTextField(
            controller: _searchController, onChanged: _cubit.updateSearchQuery);
        if (constraints.maxWidth < 720.w) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                SizedBox(height: 12.h),
                Wrap(spacing: 12.w, runSpacing: 12.h, children: actions),
              ]);
        }
        return Row(children: [
          search,
          SizedBox(width: 16.w),
          actions[0],
          SizedBox(width: 12.w),
          actions[1],
          SizedBox(width: 12.w),
          actions[2]
        ]);
      },
    );
  }

  /// Method Name: [_exportHealthInsurance]
  ///
  /// Purpose: Exports the current health-insurance search and filter results.
  ///
  /// Parameters:
  /// - [context]: Provides localized spreadsheet labels.
  /// - [state]: Supplies the displayed health-insurance rows.
  ///
  /// Returns: Completes after the export action finishes.
  Future<void> _exportHealthInsurance(
    BuildContext context,
    HealthInsuranceState state,
  ) {
    final localization = S.of(context);
    return _exportAction.export(
      context: context,
      fileName: 'health_insurance',
      headers: [
        localization.number,
        localization.employeeId,
        EmployeeInfo.firstName.name,
        EmployeeInfo.middleName.name,
        EmployeeInfo.lastName.name,
        EmployeeInfo.firstNameArabic.name,
        EmployeeInfo.middleNameArabic.name,
        EmployeeInfo.lastNameArabic.name,
        localization.insuranceName,
        localization.insurancePolicyNumber,
        localization.insuranceProviderContact,
      ],
      rows: state.rows.indexed.map((entry) {
        final row = entry.$2;
        final employee = row.employee;
        return <String>[
          '${entry.$1 + 1}',
          ...row.employeeIdentityValues,
          employee.insuranceName ?? '',
          employee.insurancePolicyNumber ?? '',
          row.providerContact,
        ];
      }).toList(growable: false),
    );
  }

  /// Method Name: [_buildTable]
  ///
  /// Purpose: Displays joined employee and insurance values in the requested order.
  ///
  /// Parameters:
  /// - [context]: Provides localized headings and theme colors.
  /// - [state]: Contains the search-matched health-insurance rows.
  ///
  /// Returns: The health-insurance data table or its loading state.
  Widget _buildTable(BuildContext context, HealthInsuranceState state) {
    if (state is HealthInsuranceInitial ||
        state is HealthInsuranceLoading && state.rows.isEmpty) {
      return const CircleProgressMaster();
    }
    final labels = [
      S.of(context).number,
      S.of(context).employeeId,
      EmployeeInfo.firstName.name,
      EmployeeInfo.middleName.name,
      EmployeeInfo.lastName.name,
      EmployeeInfo.firstNameArabic.name,
      EmployeeInfo.middleNameArabic.name,
      EmployeeInfo.lastNameArabic.name,
      S.of(context).insuranceName,
      S.of(context).insurancePolicyNumber,
      S.of(context).insuranceProviderContact,
    ];
    return HrTableViewport(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(AppColors.header),
          dataRowMinHeight: 46.h,
          dataRowMaxHeight: 46.h,
          headingRowHeight: 46.h,
          horizontalMargin: 16.w,
          columnSpacing: 36.w,
          dividerThickness: 0,
          columns: labels
              .map((label) => DataColumn(
                    label: _headerCell(context, label),
                  ))
              .toList(),
          rows: List.generate(state.rows.length, (index) {
            final row = state.rows[index];
            final employee = row.employee;
            final values = [
              '${index + 1}',
              ...row.employeeIdentityValues,
              employee.insuranceName ?? '',
              employee.insurancePolicyNumber ?? '',
              row.providerContact,
            ];
            return DataRow(
              color: WidgetStatePropertyAll(
                index.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
              ),
              cells: values
                  .asMap()
                  .entries
                  .map(
                    (entry) => DataCell(
                      Text(
                        HrTableDisplayValue.format(
                          entry.value,
                          capitalize: entry.key != 0 && entry.key != 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight600,
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ),
      ),
    );
  }

  /// Method Name: [_headerCell]
  ///
  /// Purpose: Matches the Employees table header-label contrast in both themes.
  ///
  /// Parameters:
  /// - [context]: Resolves the active application brightness.
  /// - [value]: Localized table heading.
  ///
  /// Returns: A theme-contrast-aware header label.
  Widget _headerCell(BuildContext context, String value) => Text(
        value,
        style: StyleText.fontSize14Weight600.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.white
              : AppColors.textButton,
        ),
      );
}
