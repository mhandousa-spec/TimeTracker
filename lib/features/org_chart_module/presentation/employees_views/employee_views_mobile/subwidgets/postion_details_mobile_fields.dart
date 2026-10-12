import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/org_chart_module/widgets/cupertino_time_picker.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';

import '../../../../../home/h2_nav_bar/presentation/ui/pages/nav_bar.dart';
import '../employee_personal_info.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart' hide themeController;



// ✅ NEW: Single import for the updated model

class PostionDetailsMobileFields extends StatefulWidget {
  PostionDetailsMobileFields({
    super.key,
    this.compensation,
    this.compensationState,
    this.currency,
    this.currencyState,
    this.department,
    this.departmentState,
    this.jobLocation,
    this.jobLocationState,
    this.jobType,
    this.jobTypeState,
    this.role,
    this.roleState,
    this.value = 0,
    this.valueState,
    this.salary,
    this.supervisor,
    this.title,
    this.titleInArabic,
    this.endTime,
    this.startTime,
  });

  String? department;
  TextEditingController? title;
  TextEditingController? titleInArabic;
  ValueChanged<String?>? departmentState;
  String? role;
  ValueChanged<String?>? roleState;
  String? jobLocation;
  ValueChanged<String?>? jobLocationState;
  String? jobType;
  ValueChanged<String?>? jobTypeState;
  String? compensation;
  ValueChanged<String?>? compensationState;
  String? currency;
  String? worksDays;
  ValueChanged<String?>? currencyState;
  ValueChanged<String?>? workDaysState;
  double value;
  ValueChanged<double>? valueState;
  TextEditingController? salary;
  TextEditingController? supervisor;
  TextEditingController? startTime;
  TextEditingController? endTime;

  @override
  State<PostionDetailsMobileFields> createState() =>
      _PostionDetailsMobileFieldsState();
}

class _PostionDetailsMobileFieldsState
    extends State<PostionDetailsMobileFields> {
  /// Guarded lookup — the controller may not be registered yet when this
  /// widget builds, which used to throw `"AddDepartmentController" not found`.
  AddDepartmentController get _departments =>
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());

  String? supervisor;

  @override
  void initState() {
    supervisor = null;
    super.initState();
  }

  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

  List<MultiSelectDropdownItem<dynamic>> get _dayItems =>
      <MultiSelectDropdownItem<dynamic>>[
        MultiSelectDropdownItem(value: '1', label: S.current.saturday),
        MultiSelectDropdownItem(value: '2', label: S.current.sunday),
        MultiSelectDropdownItem(value: '3', label: S.current.monday),
        MultiSelectDropdownItem(value: '4', label: S.current.tuesday),
        MultiSelectDropdownItem(value: '5', label: S.current.wednesday),
        MultiSelectDropdownItem(value: '6', label: S.current.thursday),
        MultiSelectDropdownItem(value: '7', label: S.current.friday),
      ];

  /// Update supervisor based on role and department
  void _updateSupervisor() {
    if (widget.role == null || widget.department == null) {
      supervisor = null;
      widget.supervisor!.clear();

      addEmployeeController.employeePhone =
          addEmployeeController.employeePhone.copyWithUpdateSynchronized(
            supervisor: null,
            addTimestamp: DateTime.now().millisecondsSinceEpoch,
          );
      return;
    }

    final department = widget.department!.toLowerCase();
    final role = widget.role!.toLowerCase();

    try {
      NewEmployeeModelHistory? supervisorEmployee;

      // Find supervisor based on role hierarchy
      if (role == 'employee') {
        // Employee reports to Team Lead in same department
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
              (employee) =>
          employee.departmentId.isNotEmpty &&
              employee.departmentId.last == department &&
              employee.role.isNotEmpty &&
              employee.role.last == 'team lead',
        );
      } else if (role == 'team lead') {
        // Team Lead reports to Admin in same department
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
              (employee) =>
          employee.departmentId.isNotEmpty &&
              employee.departmentId.last == department &&
              employee.role.isNotEmpty &&
              employee.role.last == 'admin',
        );
      } else if (role == 'admin') {
        // Admin reports to General Admin in same department
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
              (employee) =>
          employee.departmentId.isNotEmpty &&
              employee.departmentId.last == department &&
              employee.role.isNotEmpty &&
              employee.role.last == 'general admin',
        );
      } else if (role == 'general admin') {
        // General Admin reports to CEO
        supervisorEmployee = addEmployeeController.allEmployees!.firstWhere(
              (employee) =>
          employee.role.isNotEmpty && employee.role.last == 'ceo',
        );
      }

      if (supervisorEmployee != null) {
        // Set supervisor name in text field
        final firstName = supervisorEmployee.firstName.isNotEmpty
            ? supervisorEmployee.firstName.last
            : '';
        final lastName = supervisorEmployee.lastName.isNotEmpty
            ? supervisorEmployee.lastName.last
            : '';
        widget.supervisor!.text = capitalize('$firstName $lastName');

        // Store supervisor email
        supervisor = supervisorEmployee.email.isNotEmpty
            ? supervisorEmployee.email.last
            : null;

        // Update employee model
        if (supervisor != null) {
          addEmployeeController.employeePhone =
              addEmployeeController.employeePhone.copyWithUpdateSynchronized(
                supervisor: supervisor!,
                addTimestamp: DateTime.now().millisecondsSinceEpoch,
              );
        }
      }
    } catch (e) {
      supervisor = null;
      widget.supervisor!.clear();

      addEmployeeController.employeePhone =
          addEmployeeController.employeePhone.copyWithUpdateSynchronized(
            supervisor: null,
            addTimestamp: DateTime.now().millisecondsSinceEpoch,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    final orientation = MediaQuery.of(context).orientation;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double heightSpacer = isPortrait ? 0.007.h : 0.013.h;
    double heightSpacerTextField = 0.003.h;

    Color backColor = themeController.currentTheme == AppColors.lightTheme
        ? const Color(0xFFF6F6F6)
        : AppColors.colorBlack;

    Color buttonColor = themeController.currentTheme == AppColors.lightTheme
        ? const Color(0xFFF6F6F6)
        : AppColors.colorBlack;

    EdgeInsets dropdownPadding = EdgeInsets.symmetric(
      horizontal: orientation == Orientation.portrait ? 0.04.w : 0.01.w,
    );

    TextStyle dropDownTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isTablet
          ? (isPortrait
          ? FontConstants.fontSize014.h
          : FontConstants.fontSize018.h)
          : FontConstants.fontSize017.h,
      color: AppColors.colorGrey,
      fontWeight: FontWeight.w400,
      height: orientation == Orientation.portrait ? 0.0014.h : 0.002.h,
    );

    double buttonWidth = MediaQuery.of(context).size.shortestSide > 600
        ? (orientation == Orientation.portrait ? 0.620.w : 0.850.h)
        : 0.42.w;

    double dropdownWidth = isTablet ? 0.43.w : 0.88.w;

    double buttonHeight = MediaQuery.of(context).size.shortestSide > 600
        ? (orientation == Orientation.portrait ? 0.04.h : 0.04.w)
        : 0.05.h;

    double? dropdownHeight =
    MediaQuery.of(context).size.shortestSide > 600 ? null : 0.2.h;

    EdgeInsets? itemPadding = MediaQuery.of(context).size.shortestSide > 600
        ? null
        : EdgeInsets.symmetric(vertical: 0.003.h);

    EdgeInsets buttonPadding = EdgeInsets.symmetric(
      horizontal: orientation == Orientation.landscape
          ? 0.022.h
          : isTablet
          ? 0.02.w
          : (0.025.w),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(horizontal: 0.02.w, vertical: 0.01.h),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Department and Role section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Department dropdown
                CustomDropdown<String>(
  valueStyle: dropDownTextStyle,
  maxOverlayHeight: dropdownHeight,
  hint: S.of(context).department,
  items: (_departments
                      .departmentsEnglishName)
    .map((e) => DropdownItem<String>(value: e, label: e))
    .toList(),
  triggerPadding: buttonPadding,
  value: widget.department,
  onChanged: (value) {
                    setState(() {
                      widget.department = value;

                      // Get department ID
                      final addDepartmentController = _departments;
                      String? deptId = addDepartmentController
                          .getDepartmentIdFromDepartmentName(
                        departmentName: value,
                      );

                      // Update employee model
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                            departmentId: deptId,
                            addTimestamp: DateTime.now().millisecondsSinceEpoch,
                          );

                      // Update supervisor based on role and department
                      _updateSupervisor();

                      widget.departmentState!(widget.department);
                      widget.value += (1 / 9);
                      widget.valueState!(widget.value);
                    });
                  },
),
                SizedBox(height: heightSpacer),

                // Role dropdown
                CustomDropdown<String>(
  valueStyle: dropDownTextStyle,
  maxOverlayHeight: dropdownHeight,
  hint: S.of(context).role,
  items: ([
                    S.of(context).cEO,
                    S.of(context).generalManager,
                    S.of(context).manager,
                    S.of(context).teamLead,
                    S.of(context).employee,
                  ])
    .map((e) => DropdownItem<String>(value: e, label: e))
    .toList(),
  triggerPadding: buttonPadding,
  value: widget.role,
  onChanged: (value) {
                    setState(() {
                      widget.role = value;

                      // Update employee model
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                            role: value.toLowerCase(),
                            addTimestamp: DateTime.now().millisecondsSinceEpoch,
                          );

                      // Update supervisor based on role and department
                      _updateSupervisor();

                      widget.roleState!(widget.role);
                      widget.value += (1 / 9);
                      widget.valueState!(widget.value);
                    });
                  },
),
                SizedBox(height: heightSpacerTextField),

                // Title field
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
  onChanged: (value) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                            title: value.toLowerCase(),
                            addTimestamp: DateTime.now().millisecondsSinceEpoch,
                          );
                    },
  hint: S.of(context).title,
  readOnly: false,
  onSubmitted: (value) {
                      setState(() {
                        widget.value += (1 / 13);
                        widget.valueState!(widget.value);
                      });
                    },
),
                ),

                // Title in Arabic field
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
  onChanged: (value) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                            titleInArabic: value!.toLowerCase(),
                            addTimestamp: DateTime.now().millisecondsSinceEpoch,
                          );
                    },
  hint: S.of(context).titleInArabic,
  readOnly: false,
  onSubmitted: (value) {
                      setState(() {
                        widget.value += (1 / 13);
                        widget.valueState!(widget.value);
                      });
                    },
),
                ),
              ],
            ),

            // Supervisor and Job Location section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Supervisor field (read-only)
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
  onChanged: (value) {},
  hint: S.of(context).superVisor,
  initialValue: capitalize(widget.supervisor!.text ?? ''),
  readOnly: true,
  onSubmitted: (value) {
                      setState(() {
                        widget.supervisor!.text = value;
                        widget.value += (1 / 9);
                        widget.valueState!(widget.value);
                      });
                    },
),
                ),
                SizedBox(height: heightSpacerTextField),

                // Job Location dropdown
                CustomDropdown<String>(
  valueStyle: dropDownTextStyle,
  maxOverlayHeight: dropdownHeight,
  hint: S.of(context).jobLocation,
  items: ([S.of(context).onSite, S.of(context).remote, S.of(context).hybrid])
    .map((e) => DropdownItem<String>(value: e, label: e))
    .toList(),
  triggerPadding: buttonPadding,
  value: widget.jobLocation,
  onChanged: (value) {
                    setState(() {
                      widget.jobLocation = value;

                      // Update employee model
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                            workLocation: value.toLowerCase(),
                            addTimestamp: DateTime.now().millisecondsSinceEpoch,
                          );

                      widget.jobLocationState!(widget.jobLocation);
                      widget.value += (1 / 9);
                      widget.valueState!(widget.value);
                    });
                  },
),
              ],
            ),
            SizedBox(height: heightSpacer),

            // Job Type and Compensation section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Job Type dropdown
                CustomDropdown<String>(
  valueStyle: dropDownTextStyle,
  maxOverlayHeight: dropdownHeight,
  hint: S.of(context).jobType,
  items: ([
                    S.of(context).fixed,
                    S.of(context).hourly,
                    S.of(context).fixedBonus,
                  ])
    .map((e) => DropdownItem<String>(value: e, label: e))
    .toList(),
  triggerPadding: buttonPadding,
  value: widget.jobType,
  onChanged: (value) {
                    setState(() {
                      widget.jobType = value;
                      // Note: jobType not in NewEmployeeModelHistory
                      // Store in local state only or add to model if needed
                      widget.jobTypeState!(widget.jobType);
                      widget.value += (1 / 9);
                      widget.valueState!(widget.value);
                    });
                  },
),
                SizedBox(height: heightSpacer),

                // Compensation dropdown
                CustomDropdown<String>(
  valueStyle: dropDownTextStyle,
  maxOverlayHeight: dropdownHeight,
  hint: S.of(context).compensation,
  items: ([
                    S.of(context).fullTime,
                    S.of(context).partTime,
                    S.of(context).contract,
                  ])
    .map((e) => DropdownItem<String>(value: e, label: e))
    .toList(),
  triggerPadding: buttonPadding,
  value: widget.compensation,
  onChanged: (value) {
                    setState(() {
                      widget.compensation = value;
                      // Note: jobCompensation not in NewEmployeeModelHistory
                      // Store in local state only or add to model if needed
                      widget.compensationState!(widget.compensation);
                      widget.value += (1 / 9);
                      widget.valueState!(widget.value);
                    });
                  },
),
              ],
            ),
            SizedBox(height: heightSpacerTextField),

            // Salary and Currency section
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Salary field
                SizedBox(
                  width: double.infinity,
                  child: CustomTextField(
  onChanged: (value) {
                      addEmployeeController.employeePhone =
                          addEmployeeController.employeePhone
                              .copyWithUpdateSynchronized(
                            // salary: value,
                            addTimestamp: DateTime.now().millisecondsSinceEpoch,
                          );
                    },
  hint: S.of(context).salary,
  readOnly: false,
  onSubmitted: (value) {
                      setState(() {
                        widget.salary!.text = value;
                        widget.value += (1 / 13);
                        widget.valueState!(widget.value);
                      });
                    },
),
                ),
                SizedBox(height: heightSpacerTextField),

                // Currency dropdown
                CustomDropdown<String>(
  valueStyle: dropDownTextStyle,
  maxOverlayHeight: dropdownHeight,
  hint: S.of(context).currency,
  items: ([S.of(context).uSD, S.of(context).eGP, S.of(context).eUR])
    .map((e) => DropdownItem<String>(value: e, label: e))
    .toList(),
  triggerPadding: buttonPadding,
  value: widget.currency,
  onChanged: (value) {
                    setState(() {
                      widget.currency = value;
                      // Note: currency not in NewEmployeeModelHistory
                      // Store in local state only or add to model if needed
                      widget.currencyState!(widget.currency);
                      widget.value += (1 / 9);
                      widget.valueState!(widget.value);
                    });
                  },
),
              ],
            ),
            SizedBox(height: heightSpacer),

            // Work Days multi-select
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: CustomMultiSelectDropdown<dynamic>(
                hint: S.of(context).enterTheWorkDays,
                items: _dayItems,
                values: addEmployeeController.selectedDaysOptions
                    .map((e) => e.value)
                    .toList(),
                onChanged: (values) {
                  final selected = _dayItems
                      .where((it) => values.contains(it.value))
                      .toList();
                  addEmployeeController.selecteItem(selected);
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: heightSpacerTextField),

            // Start Time field
            SizedBox(
              width: double.infinity,
              child: CustomTextField(
  onChanged: (value) {},
  hint: // validator
                S.of(context).startTime,
  readOnly: true,
  suffixIcon: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: (isTablet ? 0.022.w : 0.038.w),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoTimePicker(
                            onDateTimeChanged: (DateTime newDateTime) {
                              setState(() {
                                widget.startTime!.text =
                                    DateFormat('hh:mm a').format(newDateTime);

                                // Note: startTime not in NewEmployeeModelHistory
                                // Store in local state only or add to model if needed
                              });
                            },
                          );
                        },
                      );
                    },
                    child: SvgPicture.asset(
                      "assets/icons_assets/main_icons_assets/newTimeIconFixed.svg",
                      height: orientation == Orientation.portrait
                          ? isTablet
                          ? 0.02.h
                          : 0.02.h
                          : 0.02.h,
                      color: AppColors.colorGrey,
                    ),
                  ),
                ),
  onSubmitted: (value) {
                  setState(() {
                    widget.value += (1 / 13);
                    widget.valueState!(widget.value);
                  });
                },
),
            ),

            // End Time field
            CustomTextField(
  onChanged: (value) {},
  hint: // validator
              S.of(context).endTime,
  readOnly: true,
  suffixIcon: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (isTablet ? 0.022.w : 0.038.w),
                ),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoTimePicker(
                          onDateTimeChanged: (DateTime newDateTime) {
                            setState(() {
                              widget.endTime!.text =
                                  DateFormat('hh:mm a').format(newDateTime);

                              // Note: endTime not in NewEmployeeModelHistory
                              // Store in local state only or add to model if needed
                            });
                          },
                        );
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    "assets/icons_assets/main_icons_assets/newTimeIconFixed.svg",
                    height: orientation == Orientation.portrait
                        ? isTablet
                        ? 0.02.h
                        : 0.02.h
                        : 0.02.h,
                    color: AppColors.colorGrey,
                  ),
                ),
              ),
  onSubmitted: (value) {
                setState(() {
                  widget.value += (1 / 13);
                  widget.valueState!(widget.value);
                });
              },
),
          ],
        ),
      ),
    );
  }
}