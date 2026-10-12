// ***************************** FILE INFO ***************************** //
// File Name: emergency_contacts_tab_page.dart
// Purpose: Displays searchable first and second employee emergency contacts.
// Author: Mohamed Elrashidy
// Created At: 2026-08-11
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
import '../../../../../../core/helper/hr/hr_routes.dart';
import '../../../../../../core/theme/app_colors.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../main_controller/presentation/controller/hr_module_data_cubit.dart';
import '../../../utils/enums/employee_upload_controllers/employee_info.dart';
import '../../../utils/hr_table_display_value.dart';
import '../../controller/cubit/emergency_contacts_cubit.dart';
import '../widgets/emergency_contacts_filter_dialog.dart';
import '../widgets/hr_table_excel_export_action.dart';
import '../widgets/hr_table_viewport.dart';

/// Renders all employee emergency contacts in one searchable wide table.
class EmergencyContactsTabPage extends StatefulWidget {
  const EmergencyContactsTabPage({super.key});

  @override
  State<EmergencyContactsTabPage> createState() =>
      _EmergencyContactsTabPageState();
}

class _EmergencyContactsTabPageState extends State<EmergencyContactsTabPage> {
  late final EmergencyContactsCubit _cubit;
  late final TextEditingController _searchController;
  final HrTableExcelExportAction _exportAction = HrTableExcelExportAction();

  @override
  void initState() {
    super.initState();
    _cubit =
        EmergencyContactsCubit(dataCubit: context.read<HrModuleDataCubit>());
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
        value: _cubit,
        child: BlocBuilder<EmergencyContactsCubit, EmergencyContactsState>(
          builder: (context, state) => Column(
            children: [
              _buildToolbar(context, state),
              SizedBox(height: 16.h),
              Expanded(child: _buildTable(context, state)),
            ],
          ),
        ),
      );

  /// Method Name: [_buildToolbar]
  ///
  /// Purpose: Builds the Health Insurance-style emergency-contact toolbar.
  Widget _buildToolbar(BuildContext context, EmergencyContactsState state) {
    final actions = [
      CustomFilterIcon(
        title: S.of(context).filter,
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: _cubit,
            child: const EmergencyContactsFilterDialog(),
          ),
        ),
        color: AppColors.card,
        svgColor: AppColors.inverseBase,
        textStyle: StyleText.fontSize14Weight400
            .copyWith(color: AppColors.inverseBase),
      ),
      customButtonWithSvg(
        title: S.of(context).export,
        function: () => _exportEmergencyContacts(context, state),
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
          final updated = await Navigator.of(context).pushNamed(
            HRRoutes.hrModuleBulkUploadEmergencyContactsPage,
          );
          if (updated == true && mounted) {
            await _cubit.refreshEmergencyDetails();
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
          controller: _searchController,
          onChanged: _cubit.updateSearchQuery,
        );
        if (constraints.maxWidth < 720.w) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              SizedBox(height: 12.h),
              Wrap(spacing: 12.w, runSpacing: 12.h, children: actions),
            ],
          );
        }
        return Row(children: [
          search,
          SizedBox(width: 16.w),
          actions[0],
          SizedBox(width: 12.w),
          actions[1],
          SizedBox(width: 12.w),
          actions[2],
        ]);
      },
    );
  }

  /// Method Name: [_exportEmergencyContacts]
  ///
  /// Purpose: Exports the current emergency-contact search and filter results.
  ///
  /// Parameters:
  /// - [context]: Provides localized spreadsheet labels.
  /// - [state]: Supplies the displayed emergency-contact rows.
  ///
  /// Returns: Completes after the export action finishes.
  Future<void> _exportEmergencyContacts(
    BuildContext context,
    EmergencyContactsState state,
  ) {
    final localization = S.of(context);
    final contactHeaders = <String>[
      EmployeeInfo.firstName.name,
      EmployeeInfo.middleName.name,
      EmployeeInfo.lastName.name,
      EmployeeInfo.firstNameArabic.name,
      EmployeeInfo.middleNameArabic.name,
      EmployeeInfo.lastNameArabic.name,
      localization.relationship,
      localization.email,
      localization.mobilePhone,
      localization.country,
      localization.province,
      localization.city,
      localization.street,
      localization.language,
    ];
    return _exportAction.export(
      context: context,
      fileName: 'emergency_contacts',
      headers: [
        localization.number,
        localization.employeeId,
        EmployeeInfo.firstName.name,
        EmployeeInfo.middleName.name,
        EmployeeInfo.lastName.name,
        EmployeeInfo.firstNameArabic.name,
        EmployeeInfo.middleNameArabic.name,
        EmployeeInfo.lastNameArabic.name,
        localization.firstEmergencyContact,
        ...contactHeaders,
        localization.secondEmergencyContact,
        ...contactHeaders,
      ],
      rows: state.rows.indexed.map((entry) {
        final row = entry.$2;
        return <String>[
          '${entry.$1 + 1}',
          ...row.employeeIdentityValues,
          '',
          ...row.firstValues,
          '',
          ...row.secondValues,
        ];
      }).toList(growable: false),
    );
  }

  /// Method Name: [_buildTable]
  ///
  /// Purpose: Displays joined first and second emergency contacts in one row.
  Widget _buildTable(BuildContext context, EmergencyContactsState state) {
    if (state is EmergencyContactsInitial ||
        state is EmergencyContactsLoading && state.rows.isEmpty) {
      return const CircleProgressMaster();
    }
    if (state is EmergencyContactsError && state.rows.isEmpty) {
      return Center(child: Text(state.message));
    }

    final localization = S.of(context);
    final employeeLabels = [
      localization.number,
      localization.employeeId,
      EmployeeInfo.firstName.name,
      EmployeeInfo.middleName.name,
      EmployeeInfo.lastName.name,
      EmployeeInfo.firstNameArabic.name,
      EmployeeInfo.middleNameArabic.name,
      EmployeeInfo.lastNameArabic.name,
    ];
    final contactLabels = [
      EmployeeInfo.firstName.name,
      EmployeeInfo.middleName.name,
      EmployeeInfo.lastName.name,
      EmployeeInfo.firstNameArabic.name,
      EmployeeInfo.middleNameArabic.name,
      EmployeeInfo.lastNameArabic.name,
      localization.relationship,
      localization.email,
      localization.mobilePhone,
      localization.country,
      localization.province,
      localization.city,
      localization.street,
      localization.language,
    ];
    final labels = [
      ...employeeLabels,
      localization.firstEmergencyContact,
      ...contactLabels,
      localization.secondEmergencyContact,
      ...contactLabels,
    ];

    return HrTableViewport(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
        child: Table(
          defaultColumnWidth: FixedColumnWidth(145.w),
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.transparent),
          ),
          children: [
            _headerRow(context, labels),
            ...List.generate(state.rows.length, (index) {
              final row = state.rows[index];
              return _dataRow(
                index,
                [
                  '${index + 1}',
                  ...row.employeeIdentityValues,
                  '',
                  ...row.firstValues,
                  '',
                  ...row.secondValues,
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Method Name: [_headerRow]
  ///
  /// Purpose: Builds a header row with the Employees table's theme contrast.
  ///
  /// Parameters:
  /// - [context]: Resolves the active application brightness.
  /// - [values]: Ordered header labels.
  ///
  /// Returns: The styled emergency-contact table header.
  TableRow _headerRow(BuildContext context, List<String> values) => TableRow(
        decoration: BoxDecoration(color: AppColors.header),
        children: values
            .map((value) => _tableCell(
                  value,
                  isHeader: true,
                  height: 46.h,
                  headerTextColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.white
                          : AppColors.textButton,
                ))
            .toList(),
      );

  TableRow _dataRow(int index, List<String> values) => TableRow(
        decoration: BoxDecoration(
          color: index.isEven ? AppColors.evenRowColor : AppColors.oddRowColor,
        ),
        children: values
            .asMap()
            .entries
            .map((entry) => _tableCell(
                  entry.value,
                  capitalize: entry.key != 0 && entry.key != 1,
                ))
            .toList(),
      );

  Widget _tableCell(
    String value, {
    bool isHeader = false,
    bool capitalize = true,
    double? height,
    Color? headerTextColor,
  }) =>
      SizedBox(
        height: height ?? 46.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              HrTableDisplayValue.format(value, capitalize: capitalize),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isHeader
                  ? StyleText.fontSize14Weight600
                      .copyWith(color: headerTextColor ?? AppColors.textButton)
                  : StyleText.fontSize14Weight600,
            ),
          ),
        ),
      );
}
