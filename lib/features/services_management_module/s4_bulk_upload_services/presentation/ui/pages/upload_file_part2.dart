part of 'upload_file.dart';

// Split from upload_file.dart to keep files <700 LOC.

class _UploadFileTabletState extends State<UploadFileTablet> {
  // Add drag and drop state variables
  bool _isDragging = false;
  bool _isHovering = false;
  final MainCoreEmployeeController employeeController = Get.find();
  final MediaPickerService _mediaPicker = MediaPickerService();

  bool isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

  bool isArabic(String text) => RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text);

  bool isEnglish(String text) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);

  bool hasSpecialChars(String text) =>
      RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9]').hasMatch(text);

  bool hasNumbers(String text) => RegExp(r'\d').hasMatch(text);

  bool hasNoSpaceBetweenWords(String text) => !text.trim().contains(' ');

  bool containsArabic(String text) => RegExp(r'[\u0600-\u06FF]').hasMatch(text);

  bool containsEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

  List<Map<String, TextEditingController>> formData = [];
  List<Map<String, TextEditingController>> filteredData = [];
  List<Map<String, String>> validationErrors = [];
  int currentPage = 0;

  // ✅ UPDATED: Removed 'Service Availability' from expected headers
  final List<String> expectedHeaders = [
    'Service Name',
    'اسم الخدمة',
    'Service Description',
    'وصف الخدمة',
    'Duration of Service',
    'Time Unit',
    'Service Provider',
    'Limit Service Availability',
    'Departments',
    'Requires Approvals',
    'Approvers',
  ];

  String? selectedFileName;

  bool validateHeaders(List<String> headers) {
    if (headers.length != expectedHeaders.length) return false;
    for (int i = 0; i < headers.length; i++) {
      if (headers[i].trim() != expectedHeaders[i].trim()) return false;
    }
    return true;
  }

  String? validateCell(
      BuildContext context,
      String key,
      String? value, {
        Map<String, TextEditingController>? rowData,
      })
  {
    if (key == 'Approvers') {
      final requireApprovalCtrl = rowData?['Requires Approvals'];
      final requireApproval =
          requireApprovalCtrl?.text.trim().toLowerCase() ?? '';
      if (requireApproval == 'no') return null;
    }

    if (key == 'Departments') {
      final limitCtrl = rowData?['Limit Service Availability'];
      final limit = limitCtrl?.text.trim().toLowerCase() ?? '';
      if (limit == 'no') return null;
    }

    if (value == null || value.trim().isEmpty) {
      return S.of(context).required;
    }

    value = value.trim();

    if (value.toLowerCase() == 'null') {
      return S.of(context).cannotBeNull;
    }

    bool hasExtraSpaces(String val) => RegExp(r'\s{2,}').hasMatch(val);
    bool isArabic(String text) =>
        RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text);
    bool isEnglish(String text) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(text);
    bool hasSpecialChars(String text) =>
        RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$0-9]').hasMatch(text);
    bool hasNumbers(String text) => RegExp(r'\d').hasMatch(text);
    bool containsArabic(String text) =>
        RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    bool containsEnglish(String text) => RegExp(r'[a-zA-Z]').hasMatch(text);

    bool hasForbiddenCharsInDescription(String text) =>
        RegExp(r'[!<>?":_~;\[\]\\|=+)(*&^%]').hasMatch(text);

    if (['Service Name', 'اسم الخدمة', 'Service Description', 'وصف الخدمة']
        .contains(key)) {
      final currentValue = value.toLowerCase();
      int count = 0;

      for (var row in formData) {
        final otherValue = row[key]?.text.toLowerCase().trim();
        if (otherValue == currentValue) count++;
      }

      if (count > 1) {
        return S.of(context).duplicateValue;
      }
    }

    switch (key.trim()) {
      case 'Service Name':
        if (!isEnglish(value)) return S.of(context).englishOnly;
        if (containsArabic(value)) return S.of(context).arabicNotAllowed;
        if (hasSpecialChars(value))
          return S.of(context).specialCharsNotAllowed;
        if (hasExtraSpaces(value))
          return S.of(context).extraSpaces;
        break;

      case 'اسم الخدمة':
        if (!isArabic(value)) return S.of(context).arabicOnly;
        if (containsEnglish(value)) return S.of(context).englishNotAllowed;
        if (hasSpecialChars(value))
          return S.of(context).specialCharsNotAllowed;
        if (hasExtraSpaces(value))
          return S.of(context).extraSpaces;
        break;

      case 'Service Description':
        if (containsArabic(value)) return S.of(context).arabicNotAllowed;
        if (hasForbiddenCharsInDescription(value)) {
          return S.of(context).descriptionSpecialChars;
        }
        if (hasExtraSpaces(value))
          return S.of(context).extraSpaces;
        break;

      case 'وصف الخدمة':
        if (containsEnglish(value)) return S.of(context).englishNotAllowed;
        if (hasForbiddenCharsInDescription(value)) {
          return S.of(context).descriptionSpecialChars;
        }
        if (hasExtraSpaces(value))
          return S.of(context).extraSpaces;
        break;

      case 'Duration of Service':
        final parsed = int.tryParse(value);
        if (parsed == null) return S.of(context).mustBeNumber;
        if (parsed <= 0) return S.of(context).mustBeGreaterThanZero;
        if (parsed > 1000) return S.of(context).mustBeLessThanOrEqual;
        break;

      case 'Time Unit':
        if (hasNumbers(value)) return S.of(context).numbersNotAllowed;
        if (containsArabic(value)) return S.of(context).arabicNotAllowed;
        const allowed = ['Hours', 'Days', 'Seconds', 'Minutes'];
        if (!allowed.map((e) => e.toLowerCase()).contains(value.toLowerCase())) {
          return S.of(context).invalidTimeUnit;
        }
        break;

      case 'Service Provider':
        if (value.contains(':') ||
            value.contains(';') ||
            value.contains("'") ||
            value.contains('"') ||
            value.contains(' ')) {
          return S.of(context).emailsCommaSeparated;
        }
        if (value.startsWith(',') || value.endsWith(','))
          return S.of(context).commaAtStartOrEnd;
        if (value.contains(',,')) return S.of(context).doubleCommas;

        final emails = value.split(',').map((e) => e.trim()).toList();
        if (emails.toSet().length != emails.length) {
          return S.of(context).duplicateEmails;
        }

        for (final email in emails) {
          if (email.isEmpty) return S.of(context).emptyEmail;
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
            return S.of(context).invalidEmailFormat;
          }
          if (!employeeController.mapOfEmployeesWithEmailKey
              .containsKey(email)) {
            return S.of(context).emailDoesNotExist;
          }
        }
        break;

      case 'Approvers':
      // Check if approval is required first
        final requireApprovalCtrl = rowData?['Requires Approvals'];
        final requireApproval =
            requireApprovalCtrl?.text.trim().toLowerCase() ?? '';

        // If approval not required, skip validation
        if (requireApproval == 'no') return null;

        // Check for invalid characters (same as Service Provider)
        if (value.contains(':') ||
            value.contains(';') ||
            value.contains("'") ||
            value.contains('"') ||
            value.contains(' ')) {
          return S.of(context).emailsCommaSeparated;
        }

        // Check for comma at start or end
        if (value.startsWith(',') || value.endsWith(','))
          return S.of(context).commaAtStartOrEnd;

        // Check for double commas
        if (value.contains(',,')) return S.of(context).doubleCommas;

        // Split and validate emails
        final emails = value.split(',').map((e) => e.trim()).toList();

        // Check for duplicate emails in the same field
        if (emails.toSet().length != emails.length) {
          return S.of(context).duplicateEmails;
        }

        // Validate each email
        for (final email in emails) {
          if (email.isEmpty) return S.of(context).emptyEmail;

          // Check email format
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
            return S.of(context).invalidEmailFormat;
          }

          // Check if email exists in company (same validation as Service Provider)
          if (!employeeController.mapOfEmployeesWithEmailKey.containsKey(email)) {
            return S.of(context).emailDoesNotExist;
          }
        }
        break;

      case 'Limit Service Availability':
      case 'Requires Approvals':
        if (!['yes', 'no'].contains(value.toLowerCase())) {
          return S.of(context).invalidYesNo;
        }
        break;

      case 'Departments':
        final limitCtrl = rowData?['Limit Service Availability'];
        final limit = limitCtrl?.text.trim().toLowerCase() ?? '';

        if (limit == 'yes') {
          if (value.isEmpty) return S.of(context).departmentRequired;
          if (value.startsWith(',') || value.endsWith(','))
            return S.of(context).commaAtStartOrEnd;
          if (value.contains(',,')) return S.of(context).doubleCommas;
          if (RegExp(r'[!@#<>?":_~;\[\]\\|=+)(*&^%$]').hasMatch(value)) {
            return S.of(context).invalidDepartmentChars;
          }

          final departments = value.split(',').map((e) => e.trim()).toList();
          final controller = context.read<MainCoreDepartmentCubit>();

          for (final dept in departments) {
            if (dept.isEmpty) return S.of(context).emptyDepartment;
            if (dept.length < 2)
              return S.of(context).departmentMinLength;
            if (controller.getDepartmentIdFromDepartmentName(
                departmentName: dept) ==
                null) {
              return S.of(context).departmentDoesNotExist;
            }
          }
        }
        break;
    }

    return null;
  }

  Future<void> processFile(List<int> bytes, String fileName) async {
    // ✅ Set the filename immediately
    setState(() {
      selectedFileName = fileName;
    });

    Excel? excel;

    try {
      // ✅ FIXED: Wrap Excel decoding in try-catch
      try {
        excel = Excel.decodeBytes(bytes);
      } catch (parseError, parseStack) {
        _hideLoadingDialog();
        _showErrorDialog(_localized(
          en: 'The file may be corrupted or contain invalid data.\n\n'
              'Please ensure:\n'
              '• The file is a valid Excel format (.xlsx or .xls)\n'
              '• All cells contain valid data\n'
              '• There are no merged cells in the header row',
          ar: 'قد يكون الملف تالفًا أو يحتوي على بيانات غير صالحة.\n\n'
              'يرجى التأكد من:\n'
              '• أن الملف بصيغة إكسل صالحة (.xlsx أو .xls)\n'
              '• أن جميع الخلايا تحتوي على بيانات صالحة\n'
              '• عدم وجود خلايا مدمجة في صف العناوين',
        ));
        return;
      }

      if (excel == null || excel.tables.isEmpty) {
        _hideLoadingDialog();
        _showErrorDialog(_localized(
          en: 'No worksheets found in the Excel file.',
          ar: 'لم يتم العثور على أي أوراق عمل في ملف الإكسل.',
        ));
        return;
      }

      List<Map<String, TextEditingController>> parsedFormData = [];
      List<Map<String, String>> parsedValidationErrors = [];

      bool fileProcessed = false;

      /// Optional columns the sheet did not carry. Reported after the parse —
      /// see the deferral note at the assignment below.
      List<String> deferredMissingHeaders = [];

      for (var tableName in excel.tables.keys) {
        var sheet = excel.tables[tableName];
        if (sheet == null || sheet.rows.isEmpty) continue;

        var rows = sheet.rows;
        if (rows.length < 2) {
          continue;
        }

        // ✅ FIXED: Safe header extraction with additional null checks
        List<String> actualHeaders = [];
        try {
          if (rows.isNotEmpty && rows[0] != null) {
            // ✅ FIX (bug report p36): do NOT drop empty header cells here.
            //
            // The list was compacted with `.where(isNotEmpty)`, but below it is
            // used positionally — `actualHeaders.indexOf(header)` indexes
            // straight into the raw `rows[i]`. A single blank header cell (a
            // spacer column, or trailing blanks Excel leaves behind) therefore
            // shifted every following column by one, so cells were read from
            // the wrong column and the file came back as "corrupted or invalid
            // data". Keeping the blanks preserves index alignment.
            actualHeaders = rows[0]
                .map((cell) {
              try {
                if (cell == null || cell.value == null) return '';
                return cell.value.toString().trim();
              } catch (e) {
                return '';
              }
            })
                .toList();
          }
        } catch (e) {
          continue;
        }

        if (actualHeaders.every((header) => header.isEmpty)) {
          continue;
        }

        List<String> missingHeaders = expectedHeaders
            .where((h) => !actualHeaders.contains(h))
            .toList();
        // Blank padding cells are not "unknown columns" — only report real ones.
        List<String> unknownHeaders = actualHeaders
            .where((h) => h.isNotEmpty && !expectedHeaders.contains(h))
            .toList();

        if (missingHeaders.length >= 3) {
          _hideLoadingDialog();
          _showHeaderErrorDialog(missingHeaders);
          return;
        }

        // ✅ FIX: do NOT show the warning here. It is now a dialog rather than
        // a SnackBar, and this point is still inside the parse — a dialog
        // pushed here would be the topmost route when _hideLoadingDialog()
        // runs below, so that call would dismiss the warning and leave the
        // loading dialog behind it. Defer it to after the parse instead, where
        // it is awaited before navigating away.
        if (missingHeaders.isNotEmpty && missingHeaders.length < 3) {
          deferredMissingHeaders = missingHeaders;
        }

        // ✅ FIXED: Safe data row processing with try-catch per row
        for (int i = 1; i < rows.length; i++) {
          try {
            if (rows[i] == null || rows[i].isEmpty) continue;

            Map<String, TextEditingController> rowControllers = {};
            Map<String, String> rowErrors = {};

            for (final header in expectedHeaders) {
              String cellValue = '';

              if (actualHeaders.contains(header)) {
                int colIndex = actualHeaders.indexOf(header);

                // ✅ FIXED: Safe cell value extraction with try-catch
                try {
                  if (colIndex < rows[i].length) {
                    var cell = rows[i][colIndex];
                    if (cell != null && cell.value != null) {
                      cellValue = cell.value.toString().trim();
                    }
                  }
                } catch (cellError) {
                  cellValue = '';
                }
              }

              rowControllers[header] = TextEditingController(text: cellValue);

              String? error = validateCell(
                  context,
                  header,
                  cellValue.isEmpty ? null : cellValue,
                  rowData: rowControllers
              );

              if (error != null) {
                rowErrors[header] = error;
              }

              if (!actualHeaders.contains(header)) {
                rowErrors[header] = S.of(context).missingColumns;
              }
            }

            parsedFormData.add(rowControllers);
            parsedValidationErrors.add(rowErrors);

          } catch (rowError) {
            // Skip this row and continue with next
            continue;
          }
        }

        fileProcessed = true;
        break;
      }

      _hideLoadingDialog();

      if (!fileProcessed) {
        _showErrorDialog(_localized(
          en: 'No valid data found in the Excel file.',
          ar: 'لم يتم العثور على بيانات صالحة في ملف الإكسل.',
        ));
        return;
      }

      if (parsedFormData.isEmpty) {
        _showErrorDialog(S.of(context).noDataRowsFoundInTheExcelFile);
        return;
      }

      // Set formData for future reference
      setState(() {
        formData = parsedFormData;
        validationErrors = parsedValidationErrors;
      });

      // Optional columns were absent — tell the user before moving on. Awaited
      // so the dialog is not immediately buried by the details page; it closes
      // itself after _dialogAutoDismiss.
      if (deferredMissingHeaders.isNotEmpty) {
        await _showMissingHeadersWarning(deferredMissingHeaders);
      }

      if (!mounted) return;

      // ✅ Navigate with filename
      navigateTo(
        context,
        ToggleUploadFileDetails(
          formData: parsedFormData,
          validationErrors: parsedValidationErrors,
          selectedFileName: fileName,
        ),
      );

    } catch (e, stackTrace) {
      _hideLoadingDialog();
      _showErrorDialog('${S.of(context).excelNotAccepted}\n${e.toString()}');
    }
  }

  // File picker method
  // S4-003/007/008: no try/catch, no FilePicker/PlatformFile in the page — the
  // MediaPickerService owns picking and IO.
  Future<void> pickAndParseExcel() async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      _showErrorDialog(_localized(
        en: 'Storage permission denied. Please grant permission to access files.',
        ar: 'تم رفض إذن الوصول إلى التخزين. يرجى منح الإذن للوصول إلى الملفات.',
      ));
      return;
    }

    final picked = await _mediaPicker.pickExcelFile();
    if (picked == null) return;

    await processFile(picked.bytes, picked.name);
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

  void _onDragUpdate(DropEventDetails details) {
    setState(() {
      _isHovering = true;
    });
  }

  Future<void> _onDragDone(DropDoneDetails details) async {
    setState(() {
      _isDragging = false;
      _isHovering = false;
    });

    if (details.files.isEmpty) {
      _showErrorDialog(_localized(
        en: 'No files were dropped.',
        ar: 'لم يتم إفلات أي ملفات.',
      ));
      return;
    }

    final file = details.files.first;
    final fileName = file.name.toLowerCase();

    // Check file extension
    if (!fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
      _showErrorDialog(S.of(context).pleaseDropAnExcelFileXlsxOrXls);
      return;
    }

    try {
      final bytes = await file.readAsBytes();
      await processFile(bytes, file.name);
    } catch (e) {
      _showErrorDialog(
          '${S.of(context).unableToReadTheSelectedFile}\n${e.toString()}');
    }
  }

  // ───────────────────────── Dialog helpers ─────────────────────────
  //
  // ✅ CHANGED: every dialog on this screen now
  //   • is bilingual (AR/EN) — the strings below came from hardcoded English
  //     literals, which showed English text to Arabic users,
  //   • uses AppColors.card as its background, and
  //   • closes itself after [_dialogAutoDismiss]; there are no OK buttons and
  //     nothing to tap. The SnackBar that reported non-fatal missing columns is
  //     gone too, so all feedback on this page arrives the same way.

  /// How long a message dialog stays on screen before closing itself.
  static const Duration _dialogAutoDismiss = Duration(seconds: 3);

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  /// Picks the Arabic or English variant for the few messages on this screen
  /// that have no key in intl_en.arb / intl_ar.arb yet.
  ///
  /// Everything that DOES have a key goes through `S.of(context)` below. Move
  /// these five into the .arb files in the next localisation pass and this
  /// helper disappears.
  String _localized({required String en, required String ar}) =>
      _isArabic ? ar : en;

  /// Shows a message dialog that dismisses itself after [_dialogAutoDismiss].
  ///
  /// The close is driven off the dialog's OWN context, and is a no-op once the
  /// route is gone — the user can still tap the barrier, and the page may be
  /// popped, before the timer fires. Popping the enclosing navigator by the
  /// page's context instead would tear down whatever route happened to be on
  /// top by then, or throw "Looking up a deactivated widget's ancestor".
  Future<void> _showAutoDismissDialog({
    required String lottieAsset,
    required String title,
    required String message,
  }) async {
    BuildContext? dialogContext;
    var isClosed = false;

    void closeDialog() {
      if (isClosed) return;
      isClosed = true;
      final ctx = dialogContext;
      if (ctx != null && ctx.mounted) {
        Navigator.of(ctx, rootNavigator: true).maybePop();
      }
    }

    Future.delayed(_dialogAutoDismiss, closeDialog);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        dialogContext = ctx;
        final lightMode = Theme.of(ctx).brightness == Brightness.light;

        return AlertDialog(
          backgroundColor: AppColors.card,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                lottieAsset,
                width: 90.sp,
                height: 90.sp,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16.sp),
              Text(
                title,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: lightMode ? AppColors.blackButton : AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              Text(
                message,
                style: StyleText.fontSize12Weight500.copyWith(
                  color: lightMode ? AppColors.secondaryText : AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );

    // The dialog is already gone (barrier tap, or the timer above) — make sure
    // the pending timer can never pop the route that replaced it.
    isClosed = true;
  }

  /// True only while the progress dialog below is actually on screen.
  /// [_hideLoadingDialog] reads it — see the fix note there.
  bool _isLoadingDialogVisible = false;

  void _showLoadingDialog() {
    _isLoadingDialogVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      // Not auto-dismissed: this one is closed by _hideLoadingDialog when the
      // parse finishes.
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text(S.of(context).processingFile),
          ],
        ),
      ),
    ).whenComplete(() => _isLoadingDialogVisible = false);
  }

  void _hideLoadingDialog() {
    // ✅ FIX: guard on the flag. This used to pop unconditionally whenever the
    // navigator could pop — but _showLoadingDialog has no call site on this
    // screen, so no progress dialog is ever open, and every error path here
    // calls this first. The pop therefore removed THIS PAGE from the stack,
    // bouncing the user off the upload screen on any parse failure and leaving
    // the message dialog floating over whatever was underneath.
    if (!_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = false;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showErrorDialog(String message) {
    _showAutoDismissDialog(
      lottieAsset: 'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
      title: S.of(context).error,
      message: message,
    );
  }

  void _showHeaderErrorDialog(List<String> missingHeaders) {
    _showAutoDismissDialog(
      lottieAsset: 'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
      title: S.of(context).headerMismatch,
      message:
          '${S.of(context).missingRequiredColumns}: ${missingHeaders.join(', ')}',
    );
  }

  /// Non-fatal: the file is still parsed, a few optional columns were absent.
  ///
  /// ✅ CHANGED: was a SnackBar. It reads as a warning, not an error, so it
  /// keeps the warning lottie — but it now uses the same auto-dismissing
  /// dialog as everything else here.
  Future<void> _showMissingHeadersWarning(List<String> missingHeaders) {
    return _showAutoDismissDialog(
      lottieAsset: 'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
      title: S.of(context).warning,
      message: '${S.of(context).missingColumns}: ${missingHeaders.join(', ')}',
    );
  }

  Future<bool> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          status = await Permission.storage.request();
          if (status.isGranted) {
            return true;
          }
        }

        if (status.isPermanentlyDenied) {
          var manageStatus = await Permission.manageExternalStorage.status;
          if (manageStatus.isDenied) {
            manageStatus = await Permission.manageExternalStorage.request();
          }
          return manageStatus.isGranted;
        }

        return status.isGranted;
      } else if (Platform.isIOS) {
        return true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return SlideInContent(from: SlideFrom.bottom, child: SideFrameMasterServices(
      titleText: S.of(context).service,
      onFirstTap: (){
        navigateTo(context, LayoutScreenServices());
      },
      secondTitle: S.of(context).bulkUpload,
      child: Padding(
        padding: EdgeInsets.only(right: 7.sp),
        child: Column(
          children: [
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Enhanced Upload box with drag and drop
                  DropTarget(
                    onDragEntered: (_) => _onDragEntered(),
                    onDragExited: (_) => _onDragExited(),
                    onDragUpdated: _onDragUpdate,
                    onDragDone: _onDragDone,
                    child: GestureDetector(
                      onTap: pickAndParseExcel,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isDragging
                              ? (lightMode
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.2))
                              : (lightMode
                              ? AppColors.white
                              : AppColors.chatBackground),
                          borderRadius: BorderRadius.circular(8.r),

                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 60.sp),

                            // Animated icon based on drag state
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              child: _isDragging
                                  ? Icon(
                                Icons.cloud_upload_outlined,
                                key: ValueKey('dragging'),
                                size: 100.sp,
                                color: AppColors.primary,
                              )
                                  : SvgPicture.asset(
                                "assets/icons_assets/form_builder_assets/cloud_download.svg",
                                key: ValueKey('normal'),
                                width: 150.sp,
                                height: 150.sp,
                                color: AppColors.secondaryText,
                                semanticsLabel: 'Upload Icon',
                              ),
                            ),

                            SizedBox(height: 27.sp),

                            // Dynamic text based on drag state
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: Text(
                                _isDragging
                                    ? _localized(
                                        en: 'Drop your Excel file here',
                                        ar: 'أفلت ملف الإكسل هنا',
                                      )
                                    : S.of(context).dragDropFilesHere,
                                key: ValueKey(_isDragging ? 'drop' : 'drag'),
                                style: StyleText.fontSize20Weight500.copyWith(
                                  color: _isDragging
                                      ? AppColors.primary
                                      : (lightMode
                                      ? AppColors.blackButton
                                      : AppColors.white),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: 25.sp),

                            SizedBox(height: 60.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 26.sp),

            // Discard And Browse buttons
            Row(
              children: [
                customButton(
                  title: S.of(context).discard,
                  function: () {
                    setState(() {
                      selectedFileName = null;
                      formData.clear();
                      validationErrors.clear();
                    });
                  },
                  textStyle: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.onSecondaryAction,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.secondaryAction,
                ),

                Spacer(),

                customButton(
                  title: S.of(context).browseFiles,
                  function: pickAndParseExcel,
                  textStyle: StyleText.fontSize16Weight600.copyWith(
                    color: AppColors.textButton,
                  ),
                  width: 150.sp,
                  height: 38.sp,
                  radius: 8.r,
                  color: AppColors.primary,
                ),
              ],
            ),

            // Show selected file name if any
            if (selectedFileName != null) ...[
              SizedBox(height: 16.sp),
              Container(
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.sp),
                    Expanded(
                      child: Text(
                        selectedFileName!,
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedFileName = null;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }
}
