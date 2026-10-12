part of './creating_knowledge_hub.dart';
/// Module: knowledge_hub / presentation / s1_create_new_knowledge/master_page/creating_knowledge_hub.data.dart

/// Fields + data/department initialisation for [CreatingKnowledgeHub],
/// split out of the page to keep each file under 800 LOC (§7).
mixin _CreatingKnowledgeHubData on State<CreatingKnowledgeHub> {
  // Controllers
  final _englishController = TextEditingController();
  final _arabicController = TextEditingController();
  final _englishDescController = TextEditingController();
  final _arabicDescController = TextEditingController();

  // Form Keys
  final _documentNameFormKey = GlobalKey<FormState>();
  final _documentDescriptionKey = GlobalKey<FormState>();
  int selectedIndex = 0;
  int innerIndex = 0;
  bool _isEditMode = false;
  // Services
  final _knowledgeService = KnowledgeHubFirebaseServices();

  // Department Controller
  final MainCoreDepartmentCubit _departmentController =
  Get.find<MainCoreDepartmentCubit>();

  String _dropDownMenuText = 'Choose Type';
  bool _limitDepartmentAvailability = false;
  bool _schedulePublishing = false;
  bool _isUploading = false;

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  File? _selectedImage;
  File? _selectedDocument;
  String? _documentFileName;
  String? _documentExtension;
  String? _documentIcon;
  int _documentSize = 0;
  DateTime? _documentUploadedDate;

  CreateKnowledgeModel? submittedDocument;

  // Department Data
  String? _employeeDepartmentId;
  String? _employeeDepartmentEn;
  String? _employeeDepartmentAr;
  String? _employeeEmail;
  String? _employeeName;
  String? _selectedOwningDepartmentId;  // ✅ NEW: For dropdown selection

  // Dynamic departments list
  List<DepartmentModelPro> _availableDepartments = [];
  Map<String, bool> _departmentSelections = {};
  List<String> departments = [];

  bool _hasInitializedSchedule = false;
  bool _hasInitializedDepartments = false;
  bool _isDepartmentDataLoaded = false;

  List<String> get _selectedDepartments => _departmentSelections.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  // Media picker service — keeps FilePicker/ImagePicker out of the UI (§16).
  final MediaPickerService _mediaPicker = MediaPickerService();

  bool _isFormComplete() {
    // Mirrors the submit-time validation (see _handleSubmitForApproval in
    // creating_knowledge_hub.actions.dart) so the Submit/Save button only turns
    // enabled (primary color) once EVERY required field is filled — until then
    // it stays disabled with the grey disabled color and does nothing on tap.

    // 1. All four text fields have content.
    final hasEnglishName = _englishController.text.trim().isNotEmpty;
    final hasArabicName = _arabicController.text.trim().isNotEmpty;
    final hasEnglishDesc = _englishDescController.text.trim().isNotEmpty;
    final hasArabicDesc = _arabicDescController.text.trim().isNotEmpty;

    // 2. A document type is chosen.
    final hasDocType = _dropDownMenuText != 'Choose Type';

    // 3. A document is attached — a newly picked file, or the existing one when
    //    editing.
    final hasDocument = _selectedDocument != null ||
        submittedDocument?.currentDocumentFileName != null;

    // 4. If availability is limited to specific departments, at least one must
    //    be selected.
    final departmentsOk =
        !_limitDepartmentAvailability || _selectedDepartments.isNotEmpty;

    // 5. If scheduling is enabled, a start date must be set.
    final scheduleOk = !_schedulePublishing || _startDate != null;

    return hasEnglishName &&
        hasArabicName &&
        hasEnglishDesc &&
        hasArabicDesc &&
        hasDocType &&
        hasDocument &&
        departmentsOk &&
        scheduleOk;
  }

  void _debugDepartmentController() {
    debugPrint("🔍 DEBUG DEPARTMENT CONTROLLER:");
    debugPrint("Models count: ${_departmentController.departmentModels.length}");
    debugPrint("English names count: ${_departmentController.departmentsEnglishName.length}");
    debugPrint("Arabic names count: ${_departmentController.departmentsArabicName.length}");
    debugPrint("Department IDs count: ${_departmentController.departmentIds.length}");
  }

  Future<void> _initializeData() async {
    debugPrint("🔄 Initializing data...");

    // Wait for departments to load first
    await _loadDepartments();

    // Then initialize employee data
    _initializeEmployeeData();

    debugPrint("✅ Data initialization complete");
  }

  Future<void> _loadDepartments() async {
    debugPrint("📂 Loading departments directly from cubit...");

    try {
      final cubit = context.read<CreateKnowledgeCubit>();
      await cubit.fetchAllDepartments();

      // Wait for the data
      await Future.delayed(Duration(milliseconds: 1500));

      // Force a rebuild to catch the state change
      if (mounted) setState(() {});

    } catch (e) {
      debugPrint("❌ Error loading departments: $e");
    }
  }

  void _initializeEmployeeData() {
    final employeeController = Get.find<MainCoreEmployeeController>();
    final employee = employeeController.employeeEntity;

    if (employee != null) {
      _employeeEmail = employee.email;
      _employeeName = '${employee.firstName} ${employee.lastName}';
      _employeeDepartmentId = employee.departmentId;

      // ✅ Initialize selected owning department with employee's department
      _selectedOwningDepartmentId = _employeeDepartmentId;

      // Get department names in both languages
      if (_employeeDepartmentId != null && _isDepartmentDataLoaded) {
        _updateDepartmentNames();
      }

      _logEmployeeAndDepartmentInfo();
    }
  }

  void _updateDepartmentNames() {
    if (_employeeDepartmentId == null) return;

    debugPrint("🔍 Finding department ID: $_employeeDepartmentId in ${_availableDepartments.length} departments");

    // Only use the departments we got from cubit
    for (var dept in _availableDepartments) {
      if (dept.departmentID == _employeeDepartmentId) {
        _employeeDepartmentEn = dept.departmentName ?? "Department $_employeeDepartmentId";
        _employeeDepartmentAr = dept.departmentNameInArabic ?? "القسم $_employeeDepartmentId";
        debugPrint("🎯 Found department:");
        debugPrint("   🇺🇸 EN: $_employeeDepartmentEn");
        debugPrint("   🇸🇦 AR: $_employeeDepartmentAr");
        return;
      }
    }

    // If not found, use fallback
    _employeeDepartmentEn = "Department $_employeeDepartmentId";
    _employeeDepartmentAr = "القسم $_employeeDepartmentId";
    debugPrint("⚠️ Department ID $_employeeDepartmentId not found in available departments");
  }

  // ✅ NEW: Get selected owning department name
  String _getSelectedOwningDepartmentName(BuildContext context) {
    if (_selectedOwningDepartmentId == null) {
      return _employeeDepartmentEn ?? "Loading Department...";
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    for (var dept in _availableDepartments) {
      if (dept.departmentID == _selectedOwningDepartmentId) {
        return isArabic
            ? (dept.departmentNameInArabic ?? dept.departmentName ?? "Unknown")
            : (dept.departmentName ?? "Unknown");
      }
    }

    return _employeeDepartmentEn ?? "Unknown Department";
  }

  void _findDepartmentInModels() {
    if (_departmentController.departmentModels.isNotEmpty) {
      final department = _departmentController.departmentModels.firstWhere(
            (dept) => dept.departmentID == _employeeDepartmentId,
        orElse: () => DepartmentModelPro(),
      );

      if (department.departmentID != null) {
        _employeeDepartmentEn = department.departmentName;
        _employeeDepartmentAr = department.departmentNameInArabic;
        debugPrint("🎯 Found department in models:");
        debugPrint("   🇺🇸 EN: $_employeeDepartmentEn");
        debugPrint("   🇸🇦 AR: $_employeeDepartmentAr");
      } else {
        debugPrint("❌ Department not found in models list for ID: $_employeeDepartmentId");
      }
    } else {
      debugPrint("❌ Department models list is empty");
    }
  }

  void _logEmployeeAndDepartmentInfo() {
    debugPrint("👤 EMPLOYEE & DEPARTMENT INFORMATION:");
    debugPrint("═══════════════════════════════════════");
    debugPrint("📧 Employee Email: $_employeeEmail");
    debugPrint("👤 Employee Name: $_employeeName");
    debugPrint("🆔 Department ID: $_employeeDepartmentId");
    debugPrint("🇺🇸 Department (EN): $_employeeDepartmentEn");
    debugPrint("🇸🇦 Department (AR): $_employeeDepartmentAr");
    debugPrint("📊 Department Data Loaded: $_isDepartmentDataLoaded");
    debugPrint("═══════════════════════════════════════");
  }

  void _logAllAvailableDepartments() {
    final allDepartments = _departmentController.departmentModels;

    debugPrint("📊 ALL AVAILABLE DEPARTMENTS:");
    debugPrint("═══════════════════════════════════════");
    debugPrint("Total departments: ${allDepartments.length}");

    for (var dept in allDepartments) {
      final id = dept.departmentID ?? 'No ID';
      final en = dept.departmentName ?? 'No EN Name';
      final ar = dept.departmentNameInArabic ?? 'No AR Name';

      debugPrint("🏢 $en");
      debugPrint("   🆔 ID: $id");
      debugPrint("   🇺🇸 English: $en");
      debugPrint("   🇸🇦 Arabic: $ar");
      debugPrint("   ─────────────────────");
    }
    debugPrint("═══════════════════════════════════════");
  }
}
