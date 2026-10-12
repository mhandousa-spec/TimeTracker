/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: import_page_methods1.dart
/// Purpose: Declares `ImportPageMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/import_page.dart';

extension ImportPageMethods1 on _UploadFileTabletRolesState {
  // NOTE: the cell-validation predicates (isArabic/isEnglish/hasSpecialChars/
  // hasNumbers/containsArabic/containsEnglish) live inside [validateCell].
  // An extension-level copy used to be declared here too, but every call site
  // sits inside validateCell and therefore bound to the local copies \u2014 the
  // outer set was unreachable, and its hasSpecialChars additionally treated
  // digits as special characters, so keeping it around was misleading.

  bool validateHeaders(List<String> headers) {
    if (headers.length != expectedHeaders.length) return false;
    for (int i = 0; i < headers.length; i++) {
      if (headers[i].trim() != expectedHeaders[i].trim()) return false;
    }
    return true;
  }
  String? validateCell(String key, String? value, {Map<String, TextEditingController>? rowData}) {
    // Handle conditional fields that can be empty based on other field values
    if (key == 'Access Granted') {
      final statusCtrl = rowData?['Status'];
      final status = statusCtrl?.text.trim().toLowerCase() ?? '';
      if (status == 'revoke') {
        // When status is "revoke", Access Granted can be empty - no validation
        return null;
      }
    }

    if (key == 'Access Revoked') {
      final statusCtrl = rowData?['Status'];
      final status = statusCtrl?.text.trim().toLowerCase() ?? '';
      if (status == 'grant') {
        // When status is "grant", Access Revoked can be empty - no validation
        return null;
      }
    }

    if (value == null || value.trim().isEmpty) return 'Required';
    value = value.trim();

    if (value.toLowerCase() == 'null') return 'Warning Wrong Entry';

    // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
    bool hasExtraSpaces(String val) => RegExp(r'\s{2,}').hasMatch(val);
    // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
    bool isEnglish(String text) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);
    bool hasSpecialChars(String text) => RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$]').hasMatch(text);
    bool hasNumbers(String text) => RegExp(r'\d').hasMatch(text);
    bool containsArabic(String text) => RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).

    // ✅ Detect duplicate for Employee ID only
    if (['Employee ID'].contains(key)) {
      final currentValue = value.toLowerCase().trim();
      int count = 0;

      for (var row in formData) {
        final otherValue = row[key]?.text.toLowerCase().trim();
        if (otherValue == currentValue) count++;
      }

      if (count > 1) return 'Duplicate value – must be unique';
    }

    switch (key.trim()) {
      case 'Employee ID':
      // Employee ID should be alphanumeric, no special chars, no spaces
        if (value.contains(' ')) return 'Warning Format Issue';
        if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%$]').hasMatch(value)) {
          return 'Warning Format Issue';
        }
        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
          return 'Warning Format Issue';
        }
        if (value.length < 2) return 'Warning Format Issue';
        break;

      case 'Current Role Type':
      // Should be English text only, no numbers, no Arabic, allow spaces
        if (containsArabic(value)) return 'Warning Language Check';
        if (hasNumbers(value)) return 'Warning Format Issue';
        if (hasSpecialChars(value)) return 'Warning Format Issue';
        if (!isEnglish(value)) return 'Warning Language Check';
        if (hasExtraSpaces(value)) return 'Warning Format Issue';
        if (value.length < 2) return 'Warning Format Issue';
        break;

      case 'Desired Role Type':
      // Should be English text only, no numbers, no Arabic, allow spaces
        if (containsArabic(value)) return 'Warning Language Check';
        if (hasNumbers(value)) return 'Warning Format Issue';
        if (hasSpecialChars(value)) return 'Warning Format Issue';
        if (!isEnglish(value)) return 'Warning Language Check';
        if (hasExtraSpaces(value)) return 'Warning Format Issue';
        if (value.length < 2) return 'Warning Format Issue';
        break;

      case 'Access Granted':
        final statusCtrl = rowData?['Status'];
        final status = statusCtrl?.text.trim().toLowerCase() ?? '';

        // Only validate if Status is "grant"
        if (status == 'grant') {
          // Validate comma-separated permissions
          if (value.startsWith(',') || value.endsWith(',')) {
            return 'Warning Misplaced Comma';
          }

          if (value.contains(',,')) {
            return 'Warning Misplaced Comma';
          }

          // Check for spaces around commas
          if (RegExp(r'\s*,\s*').hasMatch(value) && value.contains(' ')) {
            return 'Warning Format Issue';
          }

          // Check for invalid characters (only allow letters, numbers, and commas)
          if (RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$\s]').hasMatch(value)) {
            return 'Warning Format Issue';
          }

          final permissions = value.split(',').map((e) => e.trim()).toList();

          for (final perm in permissions) {
            if (perm.isEmpty) {
              return 'Warning Misplaced Comma';
            }

            if (perm.length < 2) {
              return 'Warning Format Issue';
            }

            // Each permission should be alphanumeric
            if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(perm)) {
              return 'Warning Format Issue';
            }
          }
        }
        break;

      case 'Access Revoked':
        final statusCtrl = rowData?['Status'];
        final status = statusCtrl?.text.trim().toLowerCase() ?? '';

        // Only validate if Status is "revoke"
        if (status == 'revoke') {
          // Validate comma-separated permissions
          if (value.startsWith(',') || value.endsWith(',')) {
            return 'Warning Misplaced Comma';
          }

          if (value.contains(',,')) {
            return 'Warning Misplaced Comma';
          }

          // Check for spaces around commas
          if (RegExp(r'\s*,\s*').hasMatch(value) && value.contains(' ')) {
            return 'Warning Format Issue';
          }

          // Check for invalid characters (only allow letters, numbers, and commas)
          if (RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$\s]').hasMatch(value)) {
            return 'Warning Format Issue';
          }

          final permissions = value.split(',').map((e) => e.trim()).toList();

          for (final perm in permissions) {
            if (perm.isEmpty) {
              return 'Warning Misplaced Comma';
            }

            if (perm.length < 2) {
              return 'Warning Format Issue';
            }

            // Each permission should be alphanumeric
            if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(perm)) {
              return 'Warning Format Issue';
            }
          }
        }
        break;

      case 'Status':
        final normalized = value.toLowerCase();
        if (!['grant', 'revoke'].contains(normalized)) {
          return 'Warning Wrong Entry';
        }
        break;
    }

    return null;
  }
  // Enhanced method to handle both file picker and drag-drop
  Future<void> processFile(List<int> bytes, String fileName) async {
    selectedFileName = fileName;

    // Show loading with a key to track it
    final dialogKey = GlobalKey();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        key: dialogKey,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Processing file..."),
          ],
        ),
      ),
    );

    try {
      var excel = Excel.decodeBytes(bytes);

      if (excel.tables.isEmpty) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading
        await Future.delayed(Duration(milliseconds: 100));
        _showErrorDialog('No worksheets found in the Excel file.');
        return;
      }

      List<Map<String, TextEditingController>> parsedFormData = [];
      List<Map<String, String>> parsedValidationErrors = [];

      bool fileProcessed = false;

      for (var tableName in excel.tables.keys) {
        var sheet = excel.tables[tableName];
        if (sheet == null || sheet.rows.isEmpty) continue;

        var rows = sheet.rows;
        if (rows.length < 2) {
          continue;
        }

        List<String> actualHeaders = [];
        if (rows.isNotEmpty && rows[0].isNotEmpty) {
          actualHeaders = rows[0]
              .map((cell) => cell?.value?.toString()?.trim() ?? '')
              .where((header) => header.isNotEmpty)
              .toList();
        }

        if (actualHeaders.isEmpty) {
          continue;
        }

        List<String> missingHeaders = expectedHeaders
            .where((h) => !actualHeaders.contains(h))
            .toList();
        List<String> unknownHeaders = actualHeaders
            .where((h) => !expectedHeaders.contains(h))
            .toList();


        if (missingHeaders.length >= 3) {
          Navigator.of(context, rootNavigator: true).pop(); // Close loading
          await Future.delayed(Duration(milliseconds: 100));
          _showHeaderErrorDialog(missingHeaders);
          return;
        }

        if (missingHeaders.isNotEmpty && missingHeaders.length < 3) {
          _showMissingHeadersWarning(missingHeaders);
        }

        if (unknownHeaders.isNotEmpty) {
          _showAdditionalColumnsWarning(unknownHeaders);
        }

        for (int i = 1; i < rows.length; i++) {
          if (rows[i].isEmpty) continue;

          Map<String, TextEditingController> rowControllers = {};
          Map<String, String> rowErrors = {};

          for (final header in expectedHeaders) {
            String cellValue = '';

            if (actualHeaders.contains(header)) {
              int colIndex = actualHeaders.indexOf(header);
              if (colIndex < rows[i].length && rows[i][colIndex] != null) {
                var cellData = rows[i][colIndex]!.value;
                cellValue = cellData?.toString().trim() ?? '';
              }
            }

            rowControllers[header] = TextEditingController(text: cellValue);

            String? error = validateCell(header, cellValue.isEmpty ? null : cellValue, rowData: rowControllers);
            if (error != null) {
              rowErrors[header] = error;
            }

            if (!actualHeaders.contains(header)) {
              rowErrors[header] = 'Warning Invalid Column Title';
            }
          }

          parsedFormData.add(rowControllers);
          parsedValidationErrors.add(rowErrors);
        }

        fileProcessed = true;
        break;
      }

      // Close loading dialog FIRST
      Navigator.of(context, rootNavigator: true).pop();
      await Future.delayed(Duration(milliseconds: 300));

      if (!fileProcessed) {
        _showErrorDialog('No valid data found in the Excel file.');
        return;
      }

      if (parsedFormData.isEmpty) {
        _showErrorDialog('No data rows found in the Excel file.');
        return;
      }

      if (!mounted) return;

      // Set formData for future reference
      setState(() {
        formData = parsedFormData;
        validationErrors = parsedValidationErrors;
      });


      // Navigate to details page
      navigateTo(
        context,
        UploadFileDetailsTabletRoles(
          formData: parsedFormData,
          validationErrors: parsedValidationErrors,
          selectedFileName: selectedFileName,
        ),
      );

    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Close loading
      await Future.delayed(Duration(milliseconds: 100));
      _showErrorDialog('Failed to process Excel file: ${e.toString()}');
    }
  }
  // Drag and drop handlers
  void _onDragEntered() {
    setState(() {
      _isDragging = true;
    });
  }
  void _onDragExited() {
    setState(() {
      _isDragging = false;
    });
  }
  // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie_assets/roles_lottie_assets/rejected.json',
              width: 90.sp,
              height: 90.sp,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.sp),
            Text(
              "Error",
              style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text
              ),
            ),
            SizedBox(height: 16.sp),
            Text(
              message,
              style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.secondaryText
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
