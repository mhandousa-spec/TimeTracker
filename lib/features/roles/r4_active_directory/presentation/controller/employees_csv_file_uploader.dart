/// Module: roles / r4_active_directory / presentation / controller
///
  /// ********************** FILE INFO ********************///
  /// FILE NAME: employees_csv_file_uploader.dart
  /// Purpose: responsible for uploading the active_directory file of employees after apply validations.
  /// Author: Mohamed Elrashidy
  /// created at: 15/12/2024

  import 'dart:convert';
  import 'dart:io';

  import 'package:csv/csv.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:knowticed_plus/core/services/media_picker_service.dart';
  import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
  import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
  import 'package:knowticed_plus/core/helper/role/csv_enums.dart';
  import 'package:knowticed_plus/features/roles/r4_active_directory/domain/constants/active_directory_constants.dart';
  import 'package:knowticed_plus/features/roles/r4_active_directory/domain/enums/employee_data.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/main.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

  class EmployeesCsvFileUploader {
    String inOrder = '';
    String missing = '';
    List<dynamic> rowInvalid = [];
    CsvStatus? status;
    Map<String, List<List<dynamic>>> usersData = {};

    /// function name: extractExcelFileData
    /// purpose: file responsible for extracting the data from the excel file and apply the needed validations.
    /// parameters:
    ///            length - length of allowed employees to be uploaded.
    /// return: Future<Map<String, List<List>>> which contains the valid and invalid employees data.
    Future<Map<String, List<List>>> extractExcelFileData(
        {required int length}) async
    {

      initUsersData();

      List<List<dynamic>>? result = await getCSVFileData();
      if (result == null) {
        return usersData;
      }

      List<List<dynamic>> data = result;

      if (!validateCSVFileStructure(data)) {
        return usersData;
      }

      validateEachRowFields(data);

      if (!validateIfAdminDataIsUpdated(
          usersData[ActiveDirectoryConstants.validEmployeesData]!)) {
        initUsersData();
    }

      bool isInRange = await checkDemoUsersLength(length);
      if (!isInRange) {
        initUsersData();
    }

      return usersData;
    }

    /// function name: initUsersData
    /// purpose: responsible for initializing the users data.
    void initUsersData() {
      usersData = {};
      usersData.putIfAbsent(
          ActiveDirectoryConstants.validEmployeesData, () => []);
      usersData.putIfAbsent(
          ActiveDirectoryConstants.invalidEmployeesData, () => []);
    }

    /// Owns the picker plugin on this controller's behalf.
    ///
    /// §20/§21 forbid `FilePicker` inside a controller — picking a file is
    /// platform I/O and must go through the shared service.
    final MediaPickerService mediaPickerService = MediaPickerService();

    /// function name: getCSVFileData
    /// purpose: responsible for getting the active_directory file from the user.
    /// return: Future<List<List<dynamic>>?> which contains the data of the
    ///         active_directory file, or null when the user cancels or the file
    ///         cannot be read.
    ///
    /// Was `FilePicker.pickFiles()` called directly here.
    Future<List<List<dynamic>>?> getCSVFileData() async {
      final PickedFileData? picked = await mediaPickerService.pickAnyFile();
      if (picked == null) return null;

      try {
        // Prefer the bytes the service already read; fall back to the path on
        // platforms where only a path is exposed.
        final String fileContent = picked.bytes.isNotEmpty
            ? utf8.decode(picked.bytes, allowMalformed: true)
            : (picked.path == null
                ? ''
                : File(picked.path!).readAsStringSync());

        if (fileContent.isEmpty) return null;
        return Csv(autoDetect: false, skipEmptyLines: false).decode(fileContent);
      } catch (e, stackTrace) {
        debugPrint('getCSVFileData: could not read "${picked.name}": '
            '$e\n$stackTrace');
        return null;
      }
    }

    /// function name: validateCSVFileStructure
    /// purpose: responsible for validating the structure of the active_directory file (order, empty, missing values).
    /// parameters:
    ///            data - data of the active_directory file.
    /// return: bool which indicates if the active_directory file structure is valid or not.
    bool validateCSVFileStructure(List<List<dynamic>> data) {
      bool isValid = true;

      isValid &= validateEmptyTable(data);
      if (!isValid) {
        return isValid;
      }

      isValid &= validateMissingFields(data);
      if (!isValid) {
        return isValid;
      }

      isValid &= validateHeadersOrder(data);

      return isValid;
    }

    /// function name: validateEmptyTable
    /// purpose: responsible for validating if the table is empty or not.
    /// parameters:
    ///              data - data of the active_directory file.
    /// return: bool which indicates if the table is empty or not.
    bool validateEmptyTable(List<List<dynamic>> data) {
      if (data.length <= 1) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: globalNavigatorKey.currentContext!,
          title: "Un Successful",
          subtitle: "The Table Cannot be Empty: $inOrder",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
        return false;
      }
      return true;
    }

    /// function name: validateMissingFields
    /// purpose: responsible for validating the missing fields in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// return: bool which indicates if the missing fields are in order or not.
    bool validateMissingFields(List<List<dynamic>> data) {
      int count = 0;
      missing = '';
      for (var item in EmployeeDataItems.values) {
        if (item.name != '') {
          if (!data[0].contains(item.name)) {
            count++;
            if (count <= 5) {
              missing += '${item.name}, ';
            }
          }
        }
      }

      if (count > 5) {
        missing += ' ${S.current.and} +${count - 5} ${S.current.more}';
      }

      if (missing.isNotEmpty) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: globalNavigatorKey.currentContext!,
          title: "Un Successful",
          subtitle: "The following fields are missing: $missing",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
    }

      return missing.isEmpty ? true : false;
    }

    /// function name: validateHeadersOrder
    /// purpose: responsible for validating the headers order in the active_directory file.
    /// parameters:
    ///            data - data of the active_directory file.
    /// return: bool which indicates if the headers are in order or not.
    bool validateHeadersOrder(List<List<dynamic>> data) {

      inOrder = '';
      int count = 0;

      if (data[0].length != EmployeeDataItems.values.length - 1) {
        return false;
      }

      for (int i = 0; i < EmployeeDataItems.values.length - 1; i++) {
        String expectedName = EmployeeDataItems.values[i].name;
        String actualName = data[0][i].toString();

        // Only print first 5 to avoid spam

        if (expectedName != actualName) {
          count++;
          if (count <= 5) {
            inOrder += '$expectedName, ';
          }
        }
      }

      if (count > 5) {
        inOrder += ' ${S.current.and} +${count - 5} ${S.current.more}';
      }

      if (inOrder.isNotEmpty) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: globalNavigatorKey.currentContext!,
          title: "Un Successful",
          subtitle: "The following fields are not in correct order: $inOrder",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
        return false;
      }

      return true;
    }

    /// function name: validateEachRowFields
    /// purpose: responsible for validating each row in the active_directory file and assign to suitable fields.
    /// parameters:
    ///            data - data of the active_directory file.
    validateEachRowFields(List<List<dynamic>> data) {

      int validCount = 0;
      int invalidCount = 0;

      for (int i = 1; i < data.length; i++) {

        bool isValidRow = validateRowValues(data[i]);

        if (isValidRow) {
          usersData[ActiveDirectoryConstants.validEmployeesData]!.add(data[i]);
          validCount++;
        } else {
          usersData[ActiveDirectoryConstants.invalidEmployeesData]!.add(data[i]);
          invalidCount++;
        }
      }

      // Department consistency is validated by ActiveDirectoryController right
      // after extractExcelFileData(), where the result is awaited and acted on.
      // The previously duplicated (un-awaited) call was removed from here.
    }

    /// function name: validateRowValues
    /// purpose: responsible for validating the values of row in the active_directory file.
    /// parameters:
    ///            data - row data of the active_directory file.
    /// return: bool which indicates if the row values are valid or not.
    bool validateRowValues(List<dynamic> data) {
      bool isValid = true;
      List<String> invalidFields = [];

      // ✅ Check if this is admin ONCE at the start
      bool isAdminRow = adminAccount(data);

      for (int itemIndex = 0; itemIndex < data.length; itemIndex++) {
        // ✅ Skip ALL validations for admin EXCEPT email
        if (isAdminRow) {
          // Only validate email for admin
          if (itemIndex == EmployeeDataItems.email.index) {
            String? validationError = EmployeeDataItems.values[itemIndex].validate
                .call(data[itemIndex].toString());

            if (validationError != null) {
              invalidFields.add("Email (index $itemIndex)");
              isValid = false;
              break;
            }
          }
          // Skip all other validations for admin
          continue;
        }

        // ✅ Regular validation for non-admin rows
        bool fieldValid = true;

        // Special handling for phone numbers
        if (itemIndex == EmployeeDataItems.mobileNumber.index ||
            itemIndex == EmployeeDataItems.homeNumber.index ||
            itemIndex == EmployeeDataItems.officeNumber.index) {
          fieldValid = validatePhoneNumber(itemIndex, data);
        } else {
          String? validationError = EmployeeDataItems.values[itemIndex].validate
              .call(data[itemIndex].toString());
          fieldValid = validationError == null;

        }

        // Check if field is optional and empty
        bool isOptionalField = ActiveDirectoryConstants.optionalItems
            .contains(EmployeeDataItems.values[itemIndex]);
        bool isEmpty = data[itemIndex].toString().trim().isEmpty;

        if (isEmpty && isOptionalField) {
          fieldValid = true;
        }

        if (!fieldValid) {
          invalidFields.add("${EmployeeDataItems.values[itemIndex].name} (index $itemIndex)");
          isValid = false;
          break; // Stop at first invalid field
        }
      }


      return isValid;
    }

    /// function name: validatePhoneNumber
    /// purpose: responsible for validating the phone number.
    /// parameters:
    ///            itemIndex - index of the item in the active_directory file.
    ///            data - data of row in the active_directory file.
    /// return: bool which indicates if the phone number is valid or not.
    bool validatePhoneNumber(int itemIndex, List data) {
      bool isValid = true;
      String phoneNumber = data[itemIndex].toString();
      String originalPhone = phoneNumber;

      if (itemIndex == EmployeeDataItems.mobileNumber.index) {
        phoneNumber =
        '${data[EmployeeDataItems.mobileCountryCode.index]}-$phoneNumber';
      } else if (itemIndex == EmployeeDataItems.homeNumber.index) {
        phoneNumber =
        '${data[EmployeeDataItems.homeCountryCode.index]}-$phoneNumber';
      } else if (itemIndex == EmployeeDataItems.officeNumber.index) {
        phoneNumber =
        '${data[EmployeeDataItems.officeCountryCode.index]}-$phoneNumber';
      }

      String? validationError = EmployeeDataItems.values[itemIndex].validate.call(phoneNumber);
      isValid = validationError == null;


      return isValid;
    }

    checkDemoUsersLength(int length) {

      Set<String> ids = {};

      // Add IDs from valid uploaded data
      for (var item in usersData[ActiveDirectoryConstants.validEmployeesData]!) {
        ids.add(item[EmployeeDataItems.id.index].toString());
      }

      // Add existing employee IDs
      EmployeeController employeeController = AppControllers.employeeDirectory;
      int existingCount = employeeController.allEmployees?.length ?? 0;
      for (int i = 0; i < existingCount; i++) {
        ids.add(employeeController.allEmployees![i].id!);
      }

      // Remove admin (ID='1') from count
      ids.remove('1');

      if (ids.length > length) {
        hideLoadingIndicator();
        CustomDialogManager.showMessage(
          context: globalNavigatorKey.currentContext!,
          title: "Un Successful",
          subtitle: "Employees Numbers are More than allowed ($length). You have ${ids.length} unique employees.",
          lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        );
        return false;
      }

      return true;
    }

    // validateIfAdminDataIsUpdated(List<List> data) {
    //
    //   String? adminEmail;
    //
    //   // Step 1: Get the admin email (employee with ID = '1')
    //   try {
    //     var employeeController = AppControllers.employeeDirectory;
    //
    //     if (employeeController.allEmployees == null) {
    //       return true; // No validation needed if no employees loaded
    //     }
    //
    //     if (employeeController.allEmployees!.isEmpty) {
    //       return true;
    //     }
    //
    //     // Try to find admin
    //     var adminEmployee = employeeController.allEmployees!.firstWhere(
    //           (employee) => employee.id == '1',
    //       orElse: () => null as dynamic,
    //     );
    //
    //     if (adminEmployee == null) {
    //       for (var emp in employeeController.allEmployees!.take(5)) {
    //       }
    //       return true; // No admin found, skip validation
    //     }
    //
    //     adminEmail = adminEmployee.email?.last?.trim().toLowerCase();
    //
    //   } catch (e, stackTrace) {
    //     return true; // If we can't find admin, skip validation
    //   }
    //
    //   // Step 2: Check if adminEmail is null
    //   if (adminEmail == null || adminEmail.isEmpty) {
    //     return true;
    //   }
    //
    //
    //   // Step 3: Check the uploaded Excel data
    //
    //   if (data.isEmpty) {
    //
    //     // Check if admin is in invalid data
    //     for (int i = 0; i < usersData[ActiveDirectoryConstants.invalidEmployeesData]!.length; i++) {
    //       try {
    //         var row = usersData[ActiveDirectoryConstants.invalidEmployeesData]![i];
    //         var rowEmail = row[EmployeeDataItems.email.index].toString().trim().toLowerCase();
    //         if (rowEmail == adminEmail) {
    //           break;
    //         }
    //       } catch (e) {
    //       }
    //     }
    //
    //     return true;
    //   }
    //
    //   for (int i = 0; i < data.length; i++) {
    //     try {
    //       var rowEmail = data[i][EmployeeDataItems.email.index];
    //       var processedEmail = rowEmail.toString().trim().toLowerCase();
    //
    //       // Check if this matches admin email
    //       if (processedEmail == adminEmail) {
    //       }
    //     } catch (e) {
    //     }
    //   }
    //
    //   // Step 4: Try to find admin row
    //
    //   try {
    //     List<dynamic> adminRow = data.firstWhere(
    //           (row) {
    //         String rowEmail = row[EmployeeDataItems.email.index].toString().trim().toLowerCase();
    //         bool matches = rowEmail == adminEmail;
    //
    //         if (matches) {
    //         }
    //
    //         return matches;
    //       },
    //     );
    //
    //     return true;
    //
    //   } catch (e) {
    //
    //     for (int i = 0; i < data.length; i++) {
    //       try {
    //         var email = data[i][EmployeeDataItems.email.index].toString().trim().toLowerCase();
    //       } catch (e) {
    //       }
    //     }
    //
    //
    //     hideLoadingIndicator();
    //     showDialog(
    //       context: globalNavigatorKey.currentContext!,
    //       builder: (contexttt) {
    //         return ResponseDialog(
    //           title: "Un Successful",
    //           subtitle: "Admin Data is not updated, please update it.\n\nThe Excel file must include the admin user:\n$adminEmail",
    //           lottieAsset: "assets/lottie_assets/main_lottie_assets/error.json",
    //         );
    //       },
    //     );
    //     return false;
    //     return false;
    //   }
    // }
    validateIfAdminDataIsUpdated(List<List> data) {

      String? adminEmail;
      bool adminExistsInDatabase = false;

      // Step 1: Check if admin exists in database
      try {
        var employeeController = AppControllers.employeeDirectory;

        if (employeeController.allEmployees == null || employeeController.allEmployees!.isEmpty) {
          adminExistsInDatabase = false;
        } else {
          var adminEmployee = employeeController.allEmployees!.firstWhere(
                (employee) => employee.id == '1',
            orElse: () => null as dynamic,
          );

          if (adminEmployee == null) {
            adminExistsInDatabase = false;
          } else {
            adminEmail = adminEmployee.email?.last?.trim().toLowerCase();
            adminExistsInDatabase = true;
          }
        }
      } catch (e) {
        adminExistsInDatabase = false;
      }

      // Step 2: Handle FIRST UPLOAD vs SUBSEQUENT UPLOAD
      if (!adminExistsInDatabase) {
        // ═══════════════════════════════════════════════════════════
        // FIRST UPLOAD: Admin MUST be included with ID='1'
        // ═══════════════════════════════════════════════════════════

        if (data.isEmpty) {
          hideLoadingIndicator();
          CustomDialogManager.showMessage(
            context: globalNavigatorKey.currentContext!,
            title: "Un Successful",
            subtitle: "No valid data found in CSV file.",
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
          );
          return false;
        }

        // Search for row with ID='1'
        try {
          List<dynamic> adminRow = data.firstWhere(
                (row) {
              String rowId = row[EmployeeDataItems.id.index].toString().trim();
              return rowId == '1';
            },
          );

          String adminEmailInCsv = adminRow[EmployeeDataItems.email.index].toString().trim().toLowerCase();

          return true;

        } catch (e) {

          hideLoadingIndicator();
          CustomDialogManager.showMessage(
            context: globalNavigatorKey.currentContext!,
            title: "First Upload - Admin Required",
            subtitle: "This is your first upload.\n\n"
                    "Your CSV file MUST include the admin user with:\n"
                    "• ID = 1\n"
                    "• Valid email address\n\n"
                    "The admin row was not found in your CSV file.\n"
                    "Please add the admin user and try again.",
            lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
          );
          return false;
        }

      } else {
        // ═══════════════════════════════════════════════════════════
        // SUBSEQUENT UPLOAD: Admin CAN be included to UPDATE data
        // ═══════════════════════════════════════════════════════════

        if (data.isEmpty) {
          return true;
        }

        // ✅ NEW: Check if admin is in CSV with correct ID

        for (int i = 0; i < data.length; i++) {
          try {
            String rowEmail = data[i][EmployeeDataItems.email.index].toString().trim().toLowerCase();
            String rowId = data[i][EmployeeDataItems.id.index].toString().trim();

            if (rowEmail == adminEmail) {

              // ✅ Verify admin has ID='1'
              if (rowId != '1') {

                hideLoadingIndicator();
                CustomDialogManager.showMessage(
                  context: globalNavigatorKey.currentContext!,
                  title: "Invalid Admin ID",
                  subtitle: "Admin user found in CSV with wrong ID.\n\n"
                          "Admin email: $adminEmail\n"
                          "Current ID in CSV: $rowId\n"
                          "Required ID: 1\n\n"
                          "Please change the ID to '1' in your CSV file or remove the admin row.",
                  lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
                );
                return false;
              }

              break; // Admin found and validated, exit loop
            }
          } catch (e) {
            // Was an empty `catch {}` — the failure is deliberately
            // non-fatal here, but it must not vanish silently (§11.5).
            debugPrint('employees_csv_file_uploader.dart: non-fatal failure: $e');
          }
        }

        return true;
      }
    }

    bool adminAccount(data) {
      String email = data[EmployeeDataItems.email.index]
          .toString()
          .trim()
          .toLowerCase();

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
      } catch (e) {
        // Was an empty `catch {}` — the failure is deliberately
        // non-fatal here, but it must not vanish silently (§11.5).
        debugPrint('employees_csv_file_uploader.dart: non-fatal failure: $e');
      }

      bool isAdmin = adminEmail == email;

      return isAdmin;
    }
  }