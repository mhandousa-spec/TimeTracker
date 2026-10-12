// ***************************** FILE INFO ***************************** //
// File Name: hr_position_details_step.dart
// Purpose: Renders and validates the position-details add-employee step.
// Author: Mohamed Elrashidy
// Created At: 2026-08-09
// ********************************************************************* //

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/custom/1-custom_dropdwon.dart';
import '../../../../../../core/custom/54-custom_grid_view.dart';
import '../../../../../../core/helper/hr/validator.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../../roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import '../../../utils/add_employee_form_options.dart';
import '../../../utils/enum_bulk_value.dart';
import '../../../utils/add_employee_step.dart';
import '../../controller/add_employee_cubit.dart';
import '../../controller/add_employee_state.dart';
import 'add_employee_date_field.dart';
import 'add_employee_dropdown.dart';
import 'add_employee_read_only_scope.dart';
import 'add_employee_text_field.dart';
import 'add_employee_time_field.dart';
import '../../../../main_controller/presentation/ui/widgets/dynamic_height_grid.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

/// Renders the controlled position form for a new employee.
class HrPositionDetailsStep extends StatefulWidget {
  const HrPositionDetailsStep({
    super.key,
    this.isReadOnly = false,
    this.useForm = true,
    this.scrollable = true,
  });

  final bool isReadOnly;
  final bool useForm;
  final bool scrollable;

  @override
  State<HrPositionDetailsStep> createState() => _HrPositionDetailsStepState();
}

class _HrPositionDetailsStepState extends State<HrPositionDetailsStep> {
  late final MainCoreDepartmentCubit _departmentCubit;

  @override
  void initState() {
    super.initState();
    _departmentCubit = Get.find<MainCoreDepartmentCubit>();
    if (_departmentCubit.departmentModels.isEmpty) {
      _departmentCubit.getAllDepartments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    final cubit = context.read<AddEmployeeCubit>();
    return BlocBuilder<AddEmployeeCubit, AddEmployeeState>(
      builder: (_, __) =>
          BlocBuilder<MainCoreDepartmentCubit, MainCoreDepartmentState>(
        bloc: _departmentCubit,
        builder: (_, __) {
          final fields = <Widget>[
            AddEmployeeTextField(
                controller: cubit.employeeIdController,
                label: localization.employeeId,
                hint: localization.textHere,
                isRequired: true,
                readOnly: cubit.isEditMode,
                validator: HrValidator.number(localization, maxLength: 20),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(20),
                ]),
            AddEmployeeTextField(
                controller: cubit.titleController,
                label: localization.jobTitle,
                hint: localization.textHere,
                isRequired: true,
                validator: HrValidator.required(localization)),
            AddEmployeeDropdown<String>(
                value: _emptyToNull(cubit.departmentIdController.text),
                items: _departmentItems,
                label: localization.department,
                hint: localization.select,
                isRequired: true,
                onChanged: (value) =>
                    cubit.updateValue(cubit.departmentIdController, value),
                validator: (value) =>
                    HrValidator.requiredSelection(value, localization)),
            _optionDropdown(
                context,
                cubit.jobTypeController,
                localization.jobType,
                AddEmployeeStandardOptions.jobTypes,
                (option) => option.title),
            _optionDropdown(
                context,
                cubit.workArrangementController,
                localization.workArrangement,
                AddEmployeeStandardOptions.workArrangements,
                (option) => option.title),
            _optionDropdown(
                context,
                cubit.remoteStatusController,
                localization.remoteStatus,
                AddEmployeeStandardOptions.remoteStatuses,
                (option) => option.title),
            _optionDropdown(
                context,
                cubit.workLocationController,
                localization.jobLocation,
                AddEmployeeStandardOptions.jobLocations,
                (option) => option.title),
            _optionDropdown(
                context,
                cubit.employeeGradeController,
                localization.employeeGrade,
                AddEmployeeStandardOptions.grades,
                (option) => option.title),
            AddEmployeeDateField(
                value: DateTime.tryParse(cubit.startDateController.text),
                label: localization.startDate,
                hint: localization.selectDate,
                isRequired: true,
                onChanged: (date) => cubit.updateValue(
                    cubit.startDateController, _formatDate(date)),
                validator: (value) =>
                    HrValidator.requiredSelection(value, localization)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: localization.workingHours,
                    style: StyleText.fontSize14Weight500,
                  ),
                ),
                // Match the visual label-to-field spacing used by the shared
                // labeled HR fields while keeping one label for both times.
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AddEmployeeTimeField(
                        controller: cubit.startTimeController,
                        hint: localization.startTime,
                        isRequired: true,
                        onChanged: (value) =>
                            cubit.updateValue(cubit.startTimeController, value),
                        validator: HrValidator.required(localization),
                      ),
                    ),
                    SizedBox(width: 16.sp),
                    Expanded(
                      child: AddEmployeeTimeField(
                        controller: cubit.endTimeController,
                        hint: localization.endTime,
                        isRequired: true,
                        onChanged: (value) =>
                            cubit.updateValue(cubit.endTimeController, value),
                        validator: HrValidator.required(localization),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _optionDropdown(
                context,
                cubit.daysOffController,
                localization.daysOff,
                AddEmployeeStandardOptions.daysOff,
                (option) => option.title),
            _salaryCurrencyField(context, cubit, localization),
          ];
          final content = DynamicHeightGrid(
              widgets: fields,
              crossAxisCount: CrossAxisCountHelperResponsive
                  .getCrossAxisCountForDefaultTabletResponsive(context),
              horizontalSpacing: 16.sp,
              verticalSpacing: 20.sp);
          final formContent = widget.useForm
              ? Form(
                  key:
                      cubit.stepFormKeys[AddEmployeeStep.positionDetails.index],
                  child: content,
                )
              : content;
          return AddEmployeeReadOnlyScope(
            isReadOnly: widget.isReadOnly,
            child: widget.scrollable
                ? SingleChildScrollView(child: formContent)
                : formContent,
          );
        },
      ),
    );
  }

  List<DropdownItem<String>> get _departmentItems =>
      _departmentCubit.departmentModels
          .where((department) => department.departmentID != null)
          .map((department) => DropdownItem(
              value: department.departmentID!,
              label: _departmentCubit.getDepartmentName(
                  department.departmentID!, null)))
          .toList();

  /// Method Name: [_optionDropdown]
  ///
  /// Purpose: Builds a required position selection with localized validation.
  ///
  /// Parameters:
  /// - [context]: Context used for localization and Cubit access.
  /// - [controller]: Controller that stores the selected option value.
  /// - [label]: Localized field label.
  /// - [options]: Available enum-backed options.
  /// - [title]: Resolves a localized display label for each option.
  ///
  /// Returns: A required position dropdown.
  Widget _optionDropdown<T extends Enum>(
    BuildContext context,
    TextEditingController controller,
    String label,
    List<T> options,
    String Function(T) title,
  ) {
    final localization = S.of(context);
    return AddEmployeeDropdown<String>(
        value: _emptyToNull(controller.text),
        items: options
            .map((option) =>
                DropdownItem(value: option.value, label: title(option)))
            .toList(),
        label: label,
        hint: localization.select,
        isRequired: true,
        onChanged: (value) =>
            context.read<AddEmployeeCubit>().updateValue(controller, value),
        validator: (value) =>
            HrValidator.requiredSelection(value, localization));
  }

  /// Method Name: [_currencyDropdown]
  ///
  /// Purpose: Builds the required salary currency selector.
  ///
  /// Parameters:
  /// - [context]: Context used for localization and Cubit access.
  /// - [controller]: Controller that stores the selected currency value.
  /// - [label]: Localized field label.
  /// - [options]: Available currency options.
  ///
  /// Returns: A required currency dropdown.
  Widget _currencyDropdown(
    BuildContext context,
    TextEditingController controller,
    String label,
    List<CurrencyOption> options,
  ) {
    final localization = S.of(context);
    return AddEmployeeDropdown<String>(
      value: _emptyToNull(controller.text),
      items: options
          .map((option) => DropdownItem(
                value: option.value,
                label: option.title,
              ))
          .toList(),
      label: label,
      hint: localization.select,
      isRequired: true,
      onChanged: (value) =>
          context.read<AddEmployeeCubit>().updateValue(controller, value),
      validator: (value) => HrValidator.requiredSelection(value, localization),
    );
  }

  /// Method Name: [_salaryCurrencyField]
  ///
  /// Purpose: Renders salary and currency together with a 2:1 width ratio.
  ///
  /// Parameters:
  /// - [context]: Build context used for dropdown and Cubit access.
  /// - [cubit]: Flow Cubit containing salary and currency controllers.
  /// - [localization]: Localized labels and validation messages.
  ///
  /// Returns: A responsive salary/currency form row.
  Widget _salaryCurrencyField(
    BuildContext context,
    AddEmployeeCubit cubit,
    S localization,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: AddEmployeeTextField(
            controller: cubit.salaryController,
            label: localization.salary,
            hint: localization.textHere,
            isRequired: true,
            validator: HrValidator.number(localization),
            keyboardType: TextInputType.number,
            inputFormatters: _numberFormatters,
          ),
        ),
        SizedBox(width: 16.sp),
        Expanded(
          flex: 3,
          child: _currencyDropdown(
            context,
            cubit.currencyController,
            localization.currency,
            AddEmployeeStandardOptions.currencies,
          ),
        ),
      ],
    );
  }

  String? _emptyToNull(String value) => value.isEmpty ? null : value;
  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;
  List<TextInputFormatter> get _numberFormatters => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10)
      ];
}
