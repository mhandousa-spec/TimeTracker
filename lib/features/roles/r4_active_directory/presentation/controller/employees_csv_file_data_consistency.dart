/// Module: roles / r4_active_directory / presentation / controller
///
  ///************************ FILE INFO ********************///
  /// FILE NAME: employees_csv_file_data_consistency.dart
  /// Purpose: responsible for validating the active_directory file of employees data consistency.
  /// Author: Mohamed Elrashidy
  /// created at: 28/12/2024
  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
  import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/department_reference.dart';
  import 'package:knowticed_plus/features/roles/r4_active_directory/domain/constants/active_directory_constants.dart';

  import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';
  import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data_functions.dart';

import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/custom/77-default_dialog.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/main.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

  class EmployeesCsvFileDataConsistency {
    /// Department lookups are injected; no service locator.
    final MainCoreDepartmentCubit departmentCubit;

    EmployeesCsvFileDataConsistency({required this.departmentCubit});

    bool isRepeatDepartmentValidation = false;
    DepartmentReference departmentReference = DepartmentReference.departmentId;
    String departmentReferenceValue = "";
    String referenceDepartmentId = "";
    String referenceDepartmentEnglishName = "";
    String referenceDepartmentArabicName = "";
    Map<String, String> departmentsIdReference = {};
    Map<String, String> departmentsEnglishNameReference = {};
    Map<String, String> departmentsArabicNameReference = {};

    /// function name: validateDepartmentsConsistency
    /// purpose: responsible for validating the departments consistency in the active_directory file.
    /// parameters:
    ///           data - data of the active_directory file.
    validateDepartmentsConsistency(List<List<dynamic>> data) async {
      bool isValid = true;
      do {
        isValid = true;
        isRepeatDepartmentValidation = false;
        for (int referenceIndex = 0;
            referenceIndex < DepartmentReference.values.length;
            referenceIndex++) {
          departmentsArabicNameReference = {};
          departmentsEnglishNameReference = {};
          departmentsIdReference = {};
          isValid &= await validateDepartmentConflicts(data, referenceIndex);
          if (!isValid) break;
        }
      } while (isRepeatDepartmentValidation);
      return isValid;
    }

    /// function name: validateDepartmentConflicts
    /// purpose: responsible for validating the department conflicts in the active_directory file.
    /// parameters:
    ///             departmentsReference - map contains id, arabic name, and english name of the department with the reference value.
    ///             data - data of the active_directory file.
    ///             referenceIndex - the index of the department reference.
    validateDepartmentConflicts(List<List> data, int referenceIndex) async {
      initDepartmentReference(DepartmentReference.values[referenceIndex]);
      bool isValid = true;
      for (int i = 0; i < data.length; i++) {
        isValid &= await validateNewRowAccordingToDepartment(
            data, DepartmentReference.values[referenceIndex], i);
        if (!isValid) break;
      }
      return isValid;
    }

    /// function name: initDepartmentReference
    /// purpose: responsible for initializing the department reference with values in database.
    /// parameters:
    ///            departmentsIdReference - map contains id, arabic name, and english name of the department with the reference value.
    ///            reference - the reference type of the department.
    void initDepartmentReference(DepartmentReference reference) {
      final departmentController = departmentCubit;
      for (int i = 0; i < departmentController.departmentIds.length; i++) {
        String referenceValue = "";
        switch (reference) {
          case DepartmentReference.departmentId:
            referenceValue = departmentController.departmentIds[i];
            break;
          case DepartmentReference.departmentEnglishName:
            referenceValue = departmentController.departmentsEnglishName[i];
            break;
          case DepartmentReference.departmentArabicName:
            referenceValue = departmentController.departmentsArabicName[i];
            break;
        }

        departmentsIdReference.putIfAbsent(
            departmentController.departmentIds[i], () => referenceValue);
        departmentsEnglishNameReference.putIfAbsent(
            departmentController.departmentsEnglishName[i], () => referenceValue);
        departmentsArabicNameReference.putIfAbsent(
            departmentController.departmentsArabicName[i], () => referenceValue);
      }
    }

    /// function name: validateNewRowAccordingToDepartment
    /// purpose: responsible for validating the new row according to the department and add the department to the reference map if new.
    /// parameters:
    ///             departmentsIdReference - map contains id, arabic name, and english name of the department with the reference value.
    ///             data - specific row to validate.
    ///             reference - the reference type of the department.
    Future<bool> validateNewRowAccordingToDepartment(
        List data, DepartmentReference reference, int selectedRowIndex) async {
      String departmentReference = "";
      List<dynamic> selectedRow = data[selectedRowIndex];
      switch (reference) {
        case DepartmentReference.departmentId:
          departmentReference =
              selectedRow[EmployeeDataItems.departmentId.index] != null
                  ? selectedRow[EmployeeDataItems.departmentId.index].toString()
                  : "";
          break;
        case DepartmentReference.departmentEnglishName:
          departmentReference =
              selectedRow[EmployeeDataItems.departmentEnglishName.index].trim();
          break;
        case DepartmentReference.departmentArabicName:
          departmentReference =
              selectedRow[EmployeeDataItems.departmentArabicName.index].trim();
          break;
      }
      String departmentId =
          selectedRow[EmployeeDataItems.departmentId.index] == null
              ? ""
              : selectedRow[EmployeeDataItems.departmentId.index].toString();
      String departmentEnglishName =
          selectedRow[EmployeeDataItems.departmentEnglishName.index].trim();
      String departmentArabicName =
          selectedRow[EmployeeDataItems.departmentArabicName.index].trim();

      if (departmentsIdReference[departmentId] ==
              departmentsEnglishNameReference[departmentEnglishName] &&
          departmentsIdReference[departmentId] ==
              departmentsArabicNameReference[departmentArabicName]) {
        departmentsIdReference.putIfAbsent(
            departmentId, () => departmentReference);
        departmentsEnglishNameReference.putIfAbsent(
            departmentEnglishName, () => departmentReference);
        departmentsArabicNameReference.putIfAbsent(
            departmentArabicName, () => departmentReference);
        return true;
      }
      hideLoadingIndicator();
      setUpdateDepartmentValues(departmentReference);
      await GetDialogHelper.generalDialog(
        child: DefaultDialog(
          width: ContextExtension(globalNavigatorKey.currentContext!).isPhone ? 343.w : 411.w,
          showButtons: true,
          lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
          title: S.current.unSuccessful,
          subTitle:
              "There is an error at the department for employee with id: ${selectedRow[EmployeeDataItems.id.index]}",
          onConfirm: () {
            updateRowsWithNewDepartmentValues(reference, data);
            Navigator.of(globalNavigatorKey.currentContext!).pop();
          },
        ),
        context: globalNavigatorKey.currentContext!,
      );

      return false;
    }

    /// function name: setUpdateDepartmentValues
    /// purpose: responsible for setting the department values will be used at updating rows
    /// parameters:
    ///            departmentReference - has reference value to get all department values.
    void setUpdateDepartmentValues(String departmentReference) {
      referenceDepartmentArabicName = departmentsArabicNameReference.entries
          .firstWhere((element) => element.value == departmentReference,
              orElse: () => MapEntry("", ""))
          .key;
      referenceDepartmentEnglishName = departmentsEnglishNameReference.entries
          .firstWhere((element) => element.value == departmentReference,
              orElse: () => MapEntry("", ""))
          .key;
      referenceDepartmentId = departmentsIdReference.entries
          .firstWhere((element) => element.value == departmentReference,
              orElse: () => MapEntry("", ""))
          .key;
    }

    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// Replace this function in employees_csv_file_data_consistency.dart

    /// function name: checkUniqueItems
    /// purpose: responsible for checking the unique items in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    // bool checkUniqueItems(List<dynamic> data) {
    //
    //   EmployeeController employeeController = AppControllers.employeeDirectory;
    //
    //
    //   for (int uniqueItemIndex = 0;
    //   uniqueItemIndex < ActiveDirectoryConstants.uniqueItems.length;
    //   uniqueItemIndex++) {
    //
    //     EmployeeDataItems currentUniqueField = ActiveDirectoryConstants.uniqueItems[uniqueItemIndex];
    //
    //     Set<String> uniqueItemsSet = {};
    //     Map<String, String> valueToEmployeeMap = {}; // Track where each value came from
    //
    //     // Initialize with existing database values
    //     if (employeeController.allEmployees != null) {
    //       for (int i = 0; i < employeeController.allEmployees!.length; i++) {
    //         List<String> employeeDataRow =
    //         List.generate(EmployeeDataItems.values.length, (index) => '');
    //
    //         currentUniqueField.getRowDataFromModelItem(
    //           departments: departmentCubit,
    //             employee: employeeController.allEmployees![i],
    //             row: employeeDataRow);
    //
    //         String value = employeeDataRow[currentUniqueField.index]
    //             .toString()
    //             .trim()
    //             .toLowerCase();
    //
    //         if (value.isNotEmpty) {
    //           uniqueItemsSet.add(value);
    //           valueToEmployeeMap[value] = "DB Employee ID: ${employeeController.allEmployees![i].id}";
    //         }
    //       }
    //     }
    //
    //
    //     if (uniqueItemsSet.length > 0 && uniqueItemsSet.length <= 5) {
    //       for (var value in uniqueItemsSet.take(5)) {
    //       }
    //     }
    //
    //
    //     int duplicatesFound = 0;
    //     int emptyCount = 0;
    //     int validCount = 0;
    //
    //     for (int i = 0; i < data.length; i++) {
    //       String fieldValue = '';
    //
    //       try {
    //         fieldValue = data[i][currentUniqueField.index]
    //             .toString()
    //             .trim()
    //             .toLowerCase();
    //       } catch (e) {
    //         continue;
    //       }
    //
    //       // Skip empty values
    //       if (fieldValue.isEmpty) {
    //         emptyCount++;
    //         continue;
    //       }
    //
    //       // Special handling for admin email
    //       if (adminAccount(data[i]) && currentUniqueField == EmployeeDataItems.email) {
    //         uniqueItemsSet.add(fieldValue);
    //         valueToEmployeeMap[fieldValue] = "CSV Row $i (ADMIN)";
    //         validCount++;
    //         continue;
    //       }
    //
    //       // Check for duplicate
    //       if (uniqueItemsSet.contains(fieldValue)) {
    //
    //         duplicatesFound++;
    //
    //         hideLoadingIndicator();
    //         showDialog(
    //           context: globalNavigatorKey.currentContext!,
    //           builder: (context) {
    //             return ResponseDialog(
    //               title: "Duplicate Value Found",
    //               subtitle: "❌ Duplicate detected!\n\n"
    //                   "Field: ${currentUniqueField.name}\n"
    //                   "Value: '$fieldValue'\n\n"
    //                   "CSV Employee: ${data[i][EmployeeDataItems.firstName.index]} ${data[i][EmployeeDataItems.lastName.index]} (ID: ${data[i][EmployeeDataItems.id.index]})\n"
    //                   "Row: ${i + 2} (including header)\n\n"
    //                   "This value already exists in: ${valueToEmployeeMap[fieldValue]}\n\n"
    //                   "Please either:\n"
    //                   "1. Remove this employee from CSV (if duplicate)\n"
    //                   "2. Change the ${currentUniqueField.name} to a unique value",
    //               lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
    //             );
    //           },
    //         );
    //
    //
    //         return false;
    //       }
    //
    //       // Add to set
    //       uniqueItemsSet.add(fieldValue);
    //       valueToEmployeeMap[fieldValue] = "CSV Row $i - ${data[i][EmployeeDataItems.firstName.index]} ${data[i][EmployeeDataItems.lastName.index]}";
    //       validCount++;
    //     }
    //
    //
    //     if (duplicatesFound > 0) {
    //       return false;
    //     }
    //   }
    //
    //
    //   return true;
    // }

    /// function name: initUniqueItemsSet
    /// purpose: responsible for initializing the unique items set.
    /// parameters:
    ///            uniqueItemsSet - the set of unique field items.
    ///            uniqueItem - the unique field.
    /// function name: initUniqueItemsSet
    /// purpose: responsible for initializing the unique items set.
    /// parameters:
    ///            uniqueItemsSet - the set of unique field items.
    ///            uniqueItem - the unique field.
    void initUniqueItemsSet(
        Set<String> uniqueItemsSet, EmployeeDataItems uniqueItem) {
      EmployeeController employeeController = AppControllers.employeeDirectory;

      if (employeeController.allEmployees == null) {
        return;
      }

      for (int i = 0; i < employeeController.allEmployees!.length; i++) {
        List<String> employeeDataRow =
        List.generate(EmployeeDataItems.values.length, (index) => '');

        uniqueItem.getRowDataFromModelItem(
            employee: employeeController.allEmployees![i],
            row: employeeDataRow,
          departmentName: (id, {required arabic}) => (arabic
                  ? departmentCubit.getArabicDepartmentNameFromDepartmentId(
                      departmentId: id)
                  : departmentCubit.getEnglishDepartmentNameFromDepartmentId(
                      departmentId: id)) ??
              '',
        );

        String value = employeeDataRow[uniqueItem.index]
            .toString()
            .trim()
            .toLowerCase();  // ✅ Add toLowerCase()

        if (value.isNotEmpty) {
          uniqueItemsSet.add(value);
        }
      }
    }

    /// function name: updateRowsWithNewDepartmentValues
    /// purpose: responsible for updating the rows with the new department values.
    /// parameters:
    ///            reference - the reference type of the department.
    ///            data - data of the active_directory file.
    updateRowsWithNewDepartmentValues(
        DepartmentReference reference, List<dynamic> data) {
      isRepeatDepartmentValidation = true;
      for (int i = 0; i < data.length; i++) {
        bool isUpdated = false;
        switch (reference) {
          case DepartmentReference.departmentId:
            isUpdated = data[i][EmployeeDataItems.departmentId.index] ==
                referenceDepartmentId;
            break;
          case DepartmentReference.departmentEnglishName:
            isUpdated = data[i][EmployeeDataItems.departmentEnglishName.index] ==
                referenceDepartmentEnglishName;
            break;
          case DepartmentReference.departmentArabicName:
            isUpdated = data[i][EmployeeDataItems.departmentArabicName.index] ==
                referenceDepartmentArabicName;
            break;
        }
        if (isUpdated) {
          data[i][EmployeeDataItems.departmentId.index] = referenceDepartmentId;
          data[i][EmployeeDataItems.departmentEnglishName.index] =
              referenceDepartmentEnglishName;
          data[i][EmployeeDataItems.departmentArabicName.index] =
              referenceDepartmentArabicName;
        }
      }
    }

    bool adminAccount(data) {
      String email =
          data[EmployeeDataItems.email.index].toString().trim().toLowerCase();
      String? adminEmail;
      try {
        adminEmail = AppControllers.employeeDirectory
            .allEmployees!
            .firstWhere(
              (employee) => employee.id == '1',
            )
            .email
            ?.last
            ?.trim()
            .toLowerCase();
      } catch (e, stackTrace) {
        // Was an empty `catch {}` — the admin-email lookup failing silently
        // made every row compare against null, so no row was recognised as the
        // admin's (§11.5).
        debugPrint('admin-email lookup failed: $e\n$stackTrace');
      }
      return adminEmail == email;
    }
  }
