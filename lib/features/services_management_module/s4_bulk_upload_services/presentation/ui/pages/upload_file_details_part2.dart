part of 'upload_file_details.dart';

// Split from upload_file_details.dart to keep files <700 LOC.

class _UploadFileDetailsTabletMasterState extends State<UploadFileDetailsTabletMaster> {
  List<Map<String, GlobalKey>> fieldKeys = [];
  final MainCoreEmployeeController employeeController = Get.find();
  final MediaPickerService _mediaPicker = MediaPickerService();

  final _formKey = GlobalKey<FormState>();
  List<Map<String, TextEditingController>> formData = [];
  List<Map<String, TextEditingController>> filteredData = [];
  List<Map<String, String>> validationErrors = [];
  Set<int> selectedRows = {};
  String primaryKey = 'Approvers';
  String searchQuery = '';
  String? selectedFileName;

  // 012: Excel column headers come from constants, not page-level literals.
  final List<String> expectedHeaders = MasterUploadHeaders.step1ExpectedHeaders;

  void ensureDisabledFieldsAreCleared() {
    for (int i = 0; i < formData.length; i++) {
      final requireApproval = formData[i]['Requires Approvals']?.text.trim().toLowerCase() ?? '';
      if (requireApproval == 'no') {
        formData[i]['Approvers']?.clear();
        validationErrors[i].remove('Approvers');
      }

      final limitAvailability = formData[i]['Limit Service Availability']?.text.trim().toLowerCase() ?? '';
      if (limitAvailability == 'no') {
        formData[i]['Departments']?.clear();
        validationErrors[i].remove('Departments');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ FIX: resolve context-dependent services now, while this State is
    // still mounted. See the _uploadCubit declaration for why.
    _uploadCubit = UploadFileDetailsCubit(
      repository: ServicesManagerCubit.get(context).repository,
      employeeController: employeeController,
      departmentController: context.read<MainCoreDepartmentCubit>(),
    );

    formData = widget.formData;
    validationErrors = widget.validationErrors;
    filteredData = List.from(widget.formData);
    selectedFileName = widget.selectedFileName;

    focusNodes = List.generate(formData.length, (i) {
      final map = <String, FocusNode>{};
      for (final key in formData[i].keys) {
        map[key] = FocusNode();
      }
      return map;
    });

    fieldKeys = List.generate(formData.length, (i) {
      final map = <String, GlobalKey>{};
      for (final key in formData[i].keys) {
        map[key] = GlobalKey();
      }
      return map;
    });

    ensureDisabledFieldsAreCleared();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateErrorLocations();
    });
  }

  int currentPage = 0;

  /// All per-cell validation rules live in UploadFileRowValidator (domain
  /// layer) \u2014 this page only wires it up (audit fix #1/#4a).
  late final UploadFileRowValidator _rowValidator = UploadFileRowValidator(
    employeeController: employeeController,
    departmentController: context.read<MainCoreDepartmentCubit>(),
  );

  bool validateHeaders(List<String> headers) =>
      _rowValidator.validateHeaders(headers, expectedHeaders);

  double getColumnWidth(int rowIndex, String header) {
    return validationErrors.length > rowIndex &&
        validationErrors[rowIndex].containsKey(header)
        ? 230
        : 250;
  }

  String? validateCell(
      BuildContext context,
      String key,
      String? value, {
        Map<String, TextEditingController>? rowData,
      }) {
    return _rowValidator.validateCell(
      context,
      key,
      value,
      formData: formData,
      rowData: rowData,
    );
  }

  bool isDepartmentDisabled(int rowIndex) {
    final limitCtrl = formData[rowIndex]['Limit Service Availability'];
    final limit = limitCtrl?.text.trim().toLowerCase() ?? '';
    return limit == 'no';
  }

  bool isApproversDisabled(int rowIndex) {
    final requireApprovalCtrl = formData[rowIndex]['Requires Approvals'];
    final requireApproval =
        requireApprovalCtrl?.text.trim().toLowerCase() ?? '';
    return requireApproval == 'no';
  }

  /// Normalizes one raw Excel cell into the text the table/validator sees.
  ///
  /// ✅ FIX: xlsx has no integer type — every number is stored as a double, so
  /// a "Duration of Service" cell the user typed as `3` reaches us as the
  /// string "3.0". `validateCell` runs `int.tryParse` on it, which returns
  /// null, so EVERY row was flagged "must be a number" and the Activate button
  /// stayed disabled — the file could not be uploaded at all. "3.0" was also
  /// what got persisted to Duration_Of_Services when a sheet did get through,
  /// making the details page read "3.0 Hours".
  ///
  /// Also strips U+00A0 (non-breaking space), which Excel and pasted web text
  /// leave behind: `String.trim()` does remove it, but only at the ends, and
  /// an inner one breaks the email regex in the provider/approver columns.
  static String _normalizeCellText(String raw) {
    final cleaned = raw.replaceAll('\u00A0', ' ').trim();
    final asNum = num.tryParse(cleaned);
    if (asNum != null && asNum == asNum.roundToDouble()) {
      return asNum.toInt().toString();
    }
    return cleaned;
  }

  Future<void> pickAndParseExcel() async {
    await requestStoragePermission();
    // S4-007: picking via the shared MediaPickerService (no FilePicker in page).
    final picked = await _mediaPicker.pickExcelFile();

    if (picked != null) {
      selectedFileName = picked.name;
      setState(() {});
      var bytes = picked.bytes;
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, TextEditingController>> parsedFormData = [];
      List<Map<String, String>> parsedValidationErrors = [];

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;
        if (rows.length < 2) continue;

        // ✅ FIX (bug report p3): same null-cell trap as the row loop below —
        // an empty header cell stringified to "null" and was then reported as
        // an unknown column. Index positions are preserved either way.
        List<String> actualHeaders = rows[0]
            .map((e) => (e?.value == null) ? '' : e!.value.toString().trim())
            .toList();
        List<String> missingHeaders =
        expectedHeaders.where((h) => !actualHeaders.contains(h)).toList();
        List<String> unknownHeaders =
        actualHeaders.where((h) => !expectedHeaders.contains(h)).toList();

        if (missingHeaders.length >= 5) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(S.of(context).headerMismatch),
              content: Text(
                "${S.of(context).excelNotAccepted}\n\n${S.of(context).missingColumns}: ${missingHeaders.join(', ')}\n${S.of(context).unknownColumns}: ${unknownHeaders.join(', ')}",
              ),
              actions: [
                customButton(
                  title: S.of(context).ok,
                  function: () => Navigator.pop(context),
                  width: 80.sp,
                  height: 36.sp,
                  color: AppColors.primary,
                  textColor: AppColors.textButton,
                ),
              ],
            ),
          );
          return;
        }

        for (int i = 1; i < rows.length; i++) {
          Map<String, TextEditingController> rowControllers = {};
          Map<String, String> rowErrors = {};

          for (final header in expectedHeaders) {
            if (actualHeaders.contains(header)) {
              int colIndex = actualHeaders.indexOf(header);
              // ✅ FIX (bug report p3): `rows[i][colIndex]?.value.toString()`
              // only guarded the cell, not its value — an empty cell inside
              // the used range is a non-null Data object holding a null value,
              // so this produced the literal string "null". validateCell then
              // rejected it with "cannot be null", which is why practically
              // every row came back flagged with a red "!" on a clean file.
              final cell = rows[i][colIndex];
              final String value = _normalizeCellText(
                  (cell?.value == null) ? '' : cell!.value.toString());
              rowControllers[header] = TextEditingController(text: value);
              String? error =
              validateCell(context, header, value, rowData: rowControllers);
              if (error != null) rowErrors[header] = error;
            } else {
              rowControllers[header] = TextEditingController(text: '');
              rowErrors[header] = S.of(context).missingColumns;
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
          selectedFileName: selectedFileName,
        ),
      );
    }
  }

  final ScrollController _scrollController = ScrollController();

  /// All Firestore writes for this screen go through this cubit (audit fix
  /// #1/#3) — the page only builds row data and calls uploadToFirebase().
  ///
  /// ✅ FIX: built eagerly in initState, NOT as a `late final` field initializer.
  ///
  /// A `late final` initializer is lazy — it runs on first *access*. In the
  /// master flow this screen never calls uploadToFirebase() itself; it hands
  /// the function to MasterUploadScreen via onActivated and is then popped.
  /// Step 2 invokes that closure later, which was the first touch of this
  /// field, so the initializer ran against a State that had already been
  /// disposed and threw:
  ///
  ///   "This widget has been unmounted, so the State no longer has a context
  ///    (and should be considered defunct)."
  ///
  /// surfacing as "Upload failed: ..." on the Bulk Upload Preview screen.
  /// Resolving the dependencies up front means the closure carries a fully
  /// built cubit and never reaches back for a dead context.
  late final UploadFileDetailsCubit _uploadCubit;

  /// Ensures employee data is loaded, then delegates the whole upload to
  /// [UploadFileDetailsCubit.uploadToFirebase]. Returns
  /// Map<String, String> (serviceName -> firestoreDocId) so Step 2 can set
  /// Parent_Service_Id and id to the real Firestore doc ID.
  Future<Map<String, String>> uploadToFirebase() async {
    if (employeeController.mapOfEmployeesWithEmailKey.isEmpty) {
      await employeeController.getAllNewEmployees();
    }

    return _uploadCubit.uploadToFirebase(
      formData: formData,
      requesterEmail: employeeController.employeeEntity!.email!,
    );
  }

  /// Runs the upload (master flow hands the function to the parent screen;
  /// standalone flow uploads directly then refreshes the module cubit's
  /// cached lists) — called by [UploadFileDetailsActivateRow.onUpload].
  Future<void> _performUpload() async {
    if (widget.onActivated != null) {
      // Master flow: parent (MasterUploadScreen) stores uploadToFirebase and
      // calls it together with Step 2 when the user confirms Step 2.
      await widget.onActivated!(uploadToFirebase);
      return;
    }

    // Standalone flow: upload directly, then best-effort refresh cached
    // lists (a refresh failure must not surface as an "upload failed" error
    // — the upload itself already succeeded by this point).
    await uploadToFirebase();
    if (!mounted) return;
    await _refreshServicesManagerCubit();
  }

  Future<void> _refreshServicesManagerCubit() async {
    if (!mounted) return;
    final cubit = ServicesManagerCubit.get(context);
    await cubit.getAllServices().catchError((_) {});
    await cubit.getAllRequestServices().catchError((_) {});
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
      filteredData = query.isEmpty
          ? List.from(formData)
          : formData.where((row) {
        return row.entries.any((entry) =>
            entry.value.text.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
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
        title: Text(S.of(context).confirmDeletion),
        content: Text(S.of(context).areYouSureDeleteRow),
        actions: [
          customButton(
            title: S.of(context).cancel,
            function: () => Navigator.pop(context, false),
            width: 90.sp,
            height: 36.sp,
            color: AppColors.card,
            textColor: AppColors.text,
          ),
          customButton(
            title: S.of(context).delete,
            function: () => Navigator.pop(context, true),
            width: 90.sp,
            height: 36.sp,
            color: AppColors.primary,
            textColor: AppColors.textButton,
          ),
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

  List<Map<String, FocusNode>> focusNodes = [];
  List<MapEntry<int, String>> errorLocations = [];
  int currentErrorIndex = -1;

  /// Per-cell validation callback passed into [UploadFileDetailsTable]. Keeps
  /// the "Requires Approvals"/"Limit Service Availability" cross-field
  /// clearing behavior identical to the original inline callback.
  void _onCellValidate(String key, int index) {
    if (key == 'Requires Approvals') {
      final value = formData[index][key]?.text ?? '';
      if (value.trim().toLowerCase() == 'no') {
        formData[index]['Approvers']?.clear();
        validationErrors[index].remove('Approvers');
      } else {
        final approverValue = formData[index]['Approvers']?.text ?? '';
        final approverError =
            validateCell(context, 'Approvers', approverValue, rowData: formData[index]);
        if (approverError != null) {
          validationErrors[index]['Approvers'] = approverError;
        } else {
          validationErrors[index].remove('Approvers');
        }
      }
      final error = validateCell(context, key, value, rowData: formData[index]);
      if (error != null) {
        validationErrors[index][key] = error;
      } else {
        validationErrors[index].remove(key);
      }
    } else if (key == 'Limit Service Availability') {
      final value = formData[index][key]?.text ?? '';
      if (value.trim().toLowerCase() == 'no') {
        formData[index]['Departments']?.clear();
        validationErrors[index].remove('Departments');
      } else {
        final deptValue = formData[index]['Departments']?.text ?? '';
        final deptError =
            validateCell(context, 'Departments', deptValue, rowData: formData[index]);
        if (deptError != null) {
          validationErrors[index]['Departments'] = deptError;
        } else {
          validationErrors[index].remove('Departments');
        }
      }
      final error = validateCell(context, key, value, rowData: formData[index]);
      if (error != null) {
        validationErrors[index][key] = error;
      } else {
        validationErrors[index].remove(key);
      }
    } else {
      final value = formData[index][key]?.text ?? '';
      final error = validateCell(context, key, value, rowData: formData[index]);
      if (error != null) {
        validationErrors[index][key] = error;
      } else {
        validationErrors[index].remove(key);
      }
    }

    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => updateErrorLocations());
    });
  }

  void updateErrorLocations() {
    errorLocations.clear();
    for (int row = 0; row < validationErrors.length; row++) {
      validationErrors[row].forEach((header, error) {
        errorLocations.add(MapEntry(row, header));
      });
    }

    if (errorLocations.isEmpty) {
      currentErrorIndex = -1;
    } else if (currentErrorIndex >= errorLocations.length ||
        currentErrorIndex < 0) {
      currentErrorIndex = 0;
    }
  }

  void focusErrorField(bool forward) {
    if (errorLocations.isEmpty) return;

    setState(() {
      if (forward) {
        currentErrorIndex = (currentErrorIndex + 1) % errorLocations.length;
      } else {
        currentErrorIndex = (currentErrorIndex - 1 + errorLocations.length) %
            errorLocations.length;
      }
    });

    final entry = errorLocations[currentErrorIndex];
    final rowIndex = entry.key;
    final header = entry.value;

    final controller = formData[rowIndex][header];
    final node = focusNodes[rowIndex][header];
    final key = fieldKeys[rowIndex][header];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final contextToScroll = key?.currentContext;
        if (contextToScroll != null) {
          Scrollable.ensureVisible(
            contextToScroll,
            duration: const Duration(milliseconds: 500),
            alignment: 0.3,
            curve: Curves.easeInOut,
          ).then((_) {
            if (controller != null && node != null) {
              controller.selection = TextSelection(
                  baseOffset: 0, extentOffset: controller.text.length);
              FocusScope.of(context).requestFocus(node);
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SlideInContent(from: SlideFrom.bottom, child: SideFrameMasterServices(
      titleText: S.of(context).service,
      onFirstTap: () {
        navigateTo(context, ToggleUploadFile());
      },
      secondTitle: S.of(context).bulkUpload,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    selectedFileName ?? S.of(context).noFileSelected,
                    style: StyleText.fontSize23Weight400
                        .copyWith(color: AppColors.text),
                  ),
                ],
              ),
              SizedBox(height: 23.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 30.sp,
                    width: 142.sp,
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(4.r)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (errorLocations.isEmpty) updateErrorLocations();
                            if (errorLocations.isNotEmpty) {
                              focusErrorField(false);
                              setState(() {});
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            child: SvgPicture.asset(
                              isArabic
                                  ? "assets/icons_assets/main_icons_assets/chevron_right.svg"
                                  : "assets/icons_assets/main_icons_assets/chevron_left.svg",
                              width: 15.sp,
                              height: 15.sp,
                              color: errorLocations.isEmpty
                                  ? AppColors.grey
                                  : (lightMode
                                  ? AppColors.blackButton
                                  : AppColors.whiteShadow),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 9.sp),
                        Text(
                          "${S.of(context).error}: ",
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: lightMode
                                ? AppColors.blackButton
                                : AppColors.white,
                          ),
                        ),
                        Text(
                          getTotalErrorCount() > 0
                              ? "${currentErrorIndex + 1}/${getTotalErrorCount()}"
                              : "${getTotalErrorCount()}",
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.red,
                          ),
                        ),
                        SizedBox(width: 9.sp),
                        GestureDetector(
                          onTap: () {
                            if (errorLocations.isEmpty) updateErrorLocations();
                            if (errorLocations.isNotEmpty) {
                              focusErrorField(true);
                              setState(() {});
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.sp),
                            child: SvgPicture.asset(
                              isArabic
                                  ? "assets/icons_assets/main_icons_assets/chevron_left.svg"
                                  : "assets/icons_assets/main_icons_assets/chevron_right.svg",
                              width: 15.sp,
                              height: 15.sp,
                              color: errorLocations.isEmpty
                                  ? AppColors.grey
                                  : (lightMode
                                  ? AppColors.blackButton
                                  : AppColors.whiteShadow),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  customButtonWithIcon(
                      title: S.of(context).removeSelection,
                      function: () {
                        if (selectedRows.isEmpty) return;
                        setState(() {
                          final sortedRows = selectedRows.toList()
                            ..sort((a, b) => b.compareTo(a));
                          for (final index in sortedRows) {
                            formData.removeAt(index);
                            validationErrors.removeAt(index);
                            focusNodes.removeAt(index);
                            fieldKeys.removeAt(index);
                          }
                          selectedRows.clear();
                          filteredData = List.from(formData);
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => updateErrorLocations());
                        });
                      },
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.white),
                      width: 166.sp,
                      height: 30.sp,
                      space: 8.sp,
                      radius: 4.r,
                      color: AppColors.card,
                    icon: Icons.remove,
                    iconColor: Colors.white,
                    iconSize: 20,
                  ),
                  SizedBox(width: 10.sp),
                  customButton(
                      title: S.of(context).duplication,
                      function: () {
                        if (selectedRows.length != 1) return;

                        final indexToDuplicate = selectedRows.first;
                        final original = formData[indexToDuplicate];

                        final newRow = <String, TextEditingController>{};
                        for (final entry in original.entries) {
                          newRow[entry.key] =
                              TextEditingController(text: entry.value.text);
                        }

                        final newFocusMap = <String, FocusNode>{};
                        final newKeyMap = <String, GlobalKey>{};
                        for (final key in expectedHeaders) {
                          newFocusMap[key] = FocusNode();
                          newKeyMap[key] = GlobalKey();
                        }

                        setState(() {
                          formData.add(newRow);
                          focusNodes.add(newFocusMap);
                          fieldKeys.add(newKeyMap);
                          validationErrors.add({});
                          filteredData = List.from(formData);

                          int newIndex = formData.length - 1;

                          final requireApproval = formData[newIndex]
                          ['Requires Approvals']
                              ?.text
                              .trim()
                              .toLowerCase() ??
                              '';
                          if (requireApproval == 'no') {
                            formData[newIndex]['Approvers']?.clear();
                          }

                          final limitAvailability = formData[newIndex]
                          ['Limit Service Availability']
                              ?.text
                              .trim()
                              .toLowerCase() ??
                              '';
                          if (limitAvailability == 'no') {
                            formData[newIndex]['Departments']?.clear();
                          }

                          final newRowData = formData[newIndex];
                          final newErrorMap = <String, String>{};
                          for (final header in expectedHeaders) {
                            final value = newRowData[header]?.text ?? '';
                            final error = validateCell(context, header, value,
                                rowData: newRowData);
                            if (error != null) newErrorMap[header] = error;
                          }
                          validationErrors[newIndex] = newErrorMap;

                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => updateErrorLocations());
                        });
                      },
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.white),
                      width: 103.sp,
                      height: 30.sp,
                      radius: 4.r,
                      color: AppColors.card
                  ),
                  SizedBox(width: 10.sp),
                  customButtonWithSvg(
                      title: S.of(context).row,
                      function: () {
                        Map<String, TextEditingController> newRow = {};
                        Map<String, FocusNode> newFocusMap = {};
                        Map<String, GlobalKey> newKeyMap = {};

                        for (var header in expectedHeaders) {
                          newRow[header] = TextEditingController();
                          newFocusMap[header] = FocusNode();
                          newKeyMap[header] = GlobalKey();
                        }

                        setState(() {
                          formData.add(newRow);
                          validationErrors.add({});
                          focusNodes.add(newFocusMap);
                          fieldKeys.add(newKeyMap);
                          filteredData = List.from(formData);
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => updateErrorLocations());
                        });
                      },
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.white),
                      width: 82.sp,
                      height: 30.sp,
                      space: 8.sp,
                      radius: 4.r,
                      color: AppColors.card,
                      image: "assets/icons_assets/database_builder_assets/plus_head.svg",
                      svgColor: Colors.white,
                      widthImage: 12.sp,
                      heightImage: 12.sp,
                      colorBorder: Colors.transparent),
                ],
              ),
              SizedBox(height: 10.sp),
              if (formData.isNotEmpty)
                UploadFileDetailsTable(
                  expectedHeaders: expectedHeaders,
                  formData: formData,
                  validationErrors: validationErrors,
                  selectedRows: selectedRows,
                  focusNodes: focusNodes,
                  fieldKeys: fieldKeys,
                  scrollController: _scrollController,
                  isDepartmentDisabled: isDepartmentDisabled,
                  isApproversDisabled: isApproversDisabled,
                  onToggleRowSelected: (rowIndex) {
                    setState(() {
                      if (selectedRows.contains(rowIndex)) {
                        selectedRows.remove(rowIndex);
                      } else {
                        selectedRows.add(rowIndex);
                      }
                    });
                  },
                  onCellValidate: _onCellValidate,
                ),
              SizedBox(height: 20.sp),
              UploadFileDetailsActivateRow(
                lightMode: lightMode,
                totalErrorCount: getTotalErrorCount(),
                isMasterFlow: widget.onActivated != null,
                // Discard = leave the review screen without activating. This
                // screen is always a pushed route (master flow and standalone
                // both reach it via navigateTo), so popping returns to the
                // step that opened it.
                onDiscard: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                onUpload: _performUpload,
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
