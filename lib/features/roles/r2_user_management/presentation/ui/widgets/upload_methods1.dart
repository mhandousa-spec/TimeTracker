/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: upload_methods1.dart
/// Purpose: Declares `UploadMethods1`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/upload_file_details.dart';

extension UploadMethods1 on _UploadFileDetailsTabletRolesState {
  bool isValidEmail(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  bool isArabic(String text) => RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text);
  bool isEnglish(String text) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);
  bool hasSpecialChars(String text) => RegExp(r'[!@#<>?":_~;[\]\\|=+)(*&^%0-9]').hasMatch(text);
  bool hasNumbers(String text) => RegExp(r'\d').hasMatch(text);
  bool hasNoSpaceBetweenWords(String text) => !text.trim().contains(' ');
  bool containsArabic(String text) => RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  bool containsEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);
  bool validateHeaders(List<String> headers) {
    if (headers.length != expectedHeaders.length) return false;
    for (int i = 0; i < headers.length; i++) {
      if (headers[i].trim() != expectedHeaders[i].trim()) return false;
    }
    return true;
  }
  double getColumnWidth(int rowIndex, String header) {
    return validationErrors.length > rowIndex &&
        validationErrors[rowIndex].containsKey(header)
        ? 230
        : 250;
  }
  String? validateCell(String key, String? value, {Map<String, TextEditingController>? rowData}) {
    // No conditional validation - Access Granted and Access Revoked are always independent

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
      // Always validate - independent of Status
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
        break;

      case 'Access Revoked':
      // Always validate - independent of Status
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
        break;

      case 'Status':
      // Status must be one of: Active, Inactive, Scheduled, Expiring Soon (case insensitive)
        final normalized = value.toLowerCase();
        const allowedStatuses = ['active', 'inactive', 'scheduled', 'expiring soon'];
        if (!allowedStatuses.contains(normalized)) {
          return 'Warning Wrong Entry';
        }
        break;
    }

    return null;
  }
  Future<void> pickAndParseExcel() async {
    await requestStoragePermission();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      selectedFileName = file.path.split('/').last; // Extract just the file name
      setState(() {});
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, TextEditingController>> parsedFormData = [];
      List<Map<String, String>> parsedValidationErrors = [];

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;
        if (rows.length < 2) continue;

        List<String> actualHeaders =
        rows[0].map((e) => e?.value.toString().trim() ?? '').toList();
        List<String> missingHeaders = expectedHeaders
            .where((h) => !actualHeaders.contains(h))
            .toList();
        List<String> unknownHeaders = actualHeaders
            .where((h) => !expectedHeaders.contains(h))
            .toList();

        // 🔍 Always print this BEFORE any return

        // ❌ Reject file if 3+ expected headers are missing
        if (missingHeaders.length >= 3) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Warning Invalid Column Title"),
              content: Text(
                "The Excel file is not accepted.\n\nMissing columns: ${missingHeaders.join(', ')}\nUnknown columns: ${unknownHeaders.join(', ')}",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
          return;
        }

        // ✅ Allow preview if 1–2 columns missing
        if (missingHeaders.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning Invalid Column Title: ${missingHeaders.join(', ')}'),
              backgroundColor: AppColors.orange,
            ),
          );
        }

        if (unknownHeaders.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning Additional Column: ${unknownHeaders.join(', ')}'),
              backgroundColor: AppColors.orange,
            ),
          );
        }

        // 📦 Parse rows
        for (int i = 1; i < rows.length; i++) {
          Map<String, TextEditingController> rowControllers = {};
          Map<String, String> rowErrors = {};

          for (final header in expectedHeaders) {
            if (actualHeaders.contains(header)) {
              int colIndex = actualHeaders.indexOf(header);
              String value = rows[i][colIndex]?.value.toString() ?? '';
              rowControllers[header] = TextEditingController(text: value);
              String? error = validateCell(header, value, rowData: rowControllers);
              if (error != null) rowErrors[header] = error;
            } else {
              rowControllers[header] = TextEditingController(text: '');
              rowErrors[header] = 'Warning Invalid Column Title';
            }
          }

          parsedFormData.add(rowControllers);
          parsedValidationErrors.add(rowErrors);
        }
      }

      navigateTo(
        context,
        ToggleUploadFileDetails(
          formData: parsedFormData,
          validationErrors: parsedValidationErrors,
          selectedFileName: selectedFileName, // ✅ Pass the file name
        ),
      );
    }
  }
  Future<void> uploadToFirebase() async {
    // ADDED 9/10/2026 — this legacy page (no longer navigated to since
    // 21/9/2026, see user_management_home.dart) wrote grants straight to
    // Firestore with no user-limit check. The whole file is now checked
    // first and refused if any Knowticed Admin limit would be exceeded or the
    // limits cannot be read. Not transactional — the writes below are
    // individual; the Import page that replaced this one is.
    final List<ProposedAssignment> seatChange = <ProposedAssignment>[
      for (final Map<String, TextEditingController> row in formData)
        if ((row[primaryKey]?.text.trim() ?? '').isNotEmpty &&
            (row['Desired Role Type']?.text.trim() ?? '').isNotEmpty)
          ProposedAssignment(
            employeeId: row[primaryKey]!.text.trim(),
            role: row['Desired Role Type']!.text.trim(),
          ),
    ];
    if (seatChange.isNotEmpty) {
      final pre = await UserManagementAccessRepository()
          .precheckAssignments(seatChange);
      if (pre.isLeft()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(pre.fold((f) => f.errMessage, (_) => '')),
          backgroundColor: AppColors.red,
        ));
        return;
      }
    }

    final firestore = FirebaseFirestore.instance;
    final accessCollection = firestore.collection(getBaseUrl(FirestoreCollections.accessEmployee));
    final employeesCollection = firestore.collection(getBaseUrl(FirestoreCollections.employeeInfo)); // Assuming this is the correct collection name

    int success = 0, updated = 0, failed = 0;

    for (var row in formData) {
      String employeeId = row[primaryKey]?.text.trim() ?? '';
      if (employeeId.isEmpty) {
        failed++;
        continue;
      }

      try {
        final now = DateTime.now().millisecondsSinceEpoch;

        // ✅ Step 1: Update/Create document in accessEmployee collection
        final accessDocRef = accessCollection.doc(employeeId);
        final accessDocSnapshot = await accessDocRef.get();

        if (accessDocSnapshot.exists) {
          // ✅ APPEND to existing arrays (not replace)
          Map<String, dynamic> updateData = {};

          // Add timestamp to timestamps array
          updateData['timestamps'] = FieldValue.arrayUnion([now]);

          row.forEach((key, controller) {
            String value = controller.text.trim();
            final firestoreField = columnToFirestoreField[key] ?? key;

            // Append to arrays (preserving existing data)
            updateData[firestoreField] = FieldValue.arrayUnion([value]);
          });

          await accessDocRef.update(updateData);
          updated++;
        } else {
          // ✅ CREATE new document with arrays
          Map<String, dynamic> data = {};

          data['timestamps'] = [now];

          row.forEach((key, controller) {
            String value = controller.text.trim();
            final firestoreField = columnToFirestoreField[key] ?? key;
            data[firestoreField] = [value];
          });

          await accessDocRef.set(data);
          success++;
        }

        // ✅ Step 2: Update Employee's Role in Employees_Info collection
        String desiredRole = row['Desired Role Type']?.text.trim() ?? '';

        if (desiredRole.isNotEmpty) {
          final employeeDocRef = employeesCollection.doc(employeeId);
          final employeeDocSnapshot = await employeeDocRef.get();

          if (employeeDocSnapshot.exists) {
            // Get existing employee data using NewEmployeeModelHistory
            final employeeData = NewEmployeeModelHistory.fromMap(employeeDocSnapshot.data());

            // Check if role already exists in the list
            bool roleExists = false;
            if (employeeData.role.isNotEmpty) {
              // Check the last role entry
              String lastRole = employeeData.role.last;
              roleExists = lastRole == desiredRole;
            }

            if (!roleExists) {
              // Add new role using the synchronized update method
              final updatedEmployee = employeeData.copyWithUpdateSynchronized(
                role: desiredRole,
                addTimestamp: now,
              );

              // Update Firestore
              await employeeDocRef.update(updatedEmployee.toMap());
            } else {
            }
          } else {
          }
        }

      } catch (e) {
        failed++;
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Upload complete: $success added, $updated updated, $failed failed.'),
      ),
    );
  }
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) return true;
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }
  void filterData(String query) {
    setState(() {
      searchQuery = query;
      filteredData = query.isEmpty ? List.from(formData) : formData.where((row) {
        return row.entries.any((entry) => entry.value.text.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }
  void saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> simpleData = formData.map((row) {
      return row.map((key, controller) => MapEntry(key, controller.text));
    }).toList();
    prefs.setString('saved_excel_data', jsonEncode(simpleData));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data saved locally.")));
  }
  void loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('saved_excel_data');
    if (data != null) {
      List decoded = jsonDecode(data);
      List<Map<String, TextEditingController>> loaded = decoded.map((row) {
        return Map<String, TextEditingController>.fromEntries(
          (row as Map).entries.map((e) => MapEntry(e.key, TextEditingController(text: e.value))),
        );
      }).toList();
      setState(() {
        formData = loaded;
        filteredData = List.from(formData);
      });
    }
  }
  void addEmptyRow() {
    Map<String, TextEditingController> newRow = {};
    for (var header in expectedHeaders) {
      newRow[header] = TextEditingController();
    }
    setState(() {
      formData.add(newRow);
      filteredData = List.from(formData);
    });
  }
  void deleteRow(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this row?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() {
        formData.removeAt(index);
        validationErrors.removeAt(index);
        filteredData = List.from(formData);
      });
    }
  }
  int getTotalErrorCount() {
    int totalErrors = 0;
    for (final row in validationErrors) {
      totalErrors += row.length;
    }
    return totalErrors;
  }
}
