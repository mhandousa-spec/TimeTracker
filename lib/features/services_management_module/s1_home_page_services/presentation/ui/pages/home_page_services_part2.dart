part of 'home_page_services.dart';

// Split from home_page_services.dart to keep files <700 LOC.

class _ServicesScreenTabletState extends State<ServicesScreenTablet> with TickerProviderStateMixin {
  late final HomePageServicesCubit _cubit;

  late AnimationController _gridAnimationController;
  final List<Animation<Offset>> _slideAnimations = [];

  bool _isInitializing = true;
  bool _dataFullyLoaded = false;
  bool _hasInitialized = false; // Track if we've already initialized

  /// True once _applyFilters() has completed at least once.
  ///
  /// ✅ FIX (bug report p27): _dataFullyLoaded was set unconditionally at the
  /// end of init, but _applyFilters() only ran when userDepartment happened to
  /// be non-empty. When it wasn't, filteredServices was still empty while the
  /// loading view was already dismissed — so the empty-state illustration
  /// flashed up and the services then popped in behind it.
  ///
  /// This is a one-shot flag rather than reusing isServiceListLoading, which
  /// gets set back to true on status-chip changes that deliberately do not
  /// re-run _applyFilters (see onStatusSelected).
  bool _initialFilterApplied = false;
  bool _isProcessingUpdate = false; // Track if we're currently processing an update
  int _lastServicesCount = 0; // Track the last service count to detect actual changes
  bool isGridViewChoose = true;
  int selectedStatusIndex = 0;

  EmployeeEntityPro? _employeeEntity;

  EmployeeEntityPro get employeeEntity {
    if (_employeeEntity == null) {
      final controller = AppControllers.employee;
      if (controller.employeeEntity != null) {
        _employeeEntity = controller.employeeEntity;
      } else {
        throw Exception('EmployeeEntity is not initialized yet');
      }
    }
    return _employeeEntity!;
  }

  final TextEditingController _searchController = TextEditingController();
  Map<String, Map<String, dynamic>> selectedProviders = {};
  Map<String, int> doneServicesCount = {};

  void _initializeGridAnimations(int itemCount) {
    _slideAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      final Animation<Offset> slideAnimation = Tween<Offset>(
        begin: const Offset(-1.0, 0.0), // Slide from left (horizontal)
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            (i * 0.15).clamp(0.0, 1.0),
            ((i * 0.15) + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
      _slideAnimations.add(slideAnimation);
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _gridAnimationController.forward();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _cubit = HomePageServicesCubit(
      departmentCubit: context.read<MainCoreDepartmentCubit>(),
      servicesManagerCubit: ServicesManagerCubit.get(context),
    );

    _gridAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    formatDate = DateFormat("MMMdd_yyyy").format(DateTime.now());
    searchController.addListener(() => _applyFilters());

    // Filter starts at "All" (index 0)
    selectedStatusIndex = 0;

    if (!_hasInitialized) {
      _initializeAllData();
    }
  }

  /// Master initialization: loads the employee, department, services, then
  /// applies filters. Guarded against duplicate concurrent runs.
  Future<void> _initializeAllData() async {
    if (_hasInitialized) return;

    setState(() {
      _isInitializing = true;
      _dataFullyLoaded = false;
    });

    await _initializeEmployeeAndData();
    await loadUserDepartmentSafely();

    if (mounted) {
      await ServicesManagerCubit.get(context).getAllRequestServices();
    }

    // ✅ FIX (bug report p27): always run the filter pass before declaring the
    // data loaded. It was gated on userDepartment being non-empty, which left
    // filteredServices empty while the loading view was dismissed.
    if (mounted) {
      _applyFilters();
    }

    // P08: removed the 500ms race-condition delay. The data-loading steps
    // above are already awaited, so the cushion was unnecessary.

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _dataFullyLoaded = true;
        _hasInitialized = true;
      });
    }
  }

  /////////////////////////////////// Admin /////////////////////////////

  List<ServicesHistoryModel> filteredServices = [];
  TextEditingController searchController = TextEditingController();
  String userEmail = '';
  String userDepartment = '';

  List<String> allowedDepartmentsCache = [];
  String? selectedDurationUnit;

  String? formatDate;

  List<String> _processAllowedDepartments(ServicesHistoryModel service) =>
      HomeServicesVisibilityFilter.processAllowedDepartments(service);

  void _onSearchChangedRequest() {
    var model = ServicesManagerCubit
        .get(context)
        .servicesRequest;
    String query = searchController.text.toLowerCase().trim();

    setState(() {
      filteredServices = _filterServicesBySearchAndDepartment(model, query);
    });
  }

  List<ServicesHistoryModel> _filterServicesBySearchAndDepartment(
      List<ServicesHistoryModel> services, String query) {
    List<ServicesHistoryModel> filteredList = [];

    for (var service in services) {
      final nameEn = service.currentServiceNameEnglish.toLowerCase();
      final nameAr = service.currentServiceNameArabic.toLowerCase();

      final nameMatch = nameEn.contains(query) || nameAr.contains(query);

      final isLimited = service.currentLimitAvailability;
      final sameDepartment =
          service.currentDepartmentRequester.toLowerCase().trim() ==
              userDepartment.toLowerCase().trim();

      final departmentCheck = isLimited ? sameDepartment : true;

      if (nameMatch && departmentCheck) {
        filteredList.add(service);
      }
    }

    return filteredList;
  }

  /// Loads the current user's department, using the cubit's fallback-aware
  /// resolver. Never throws — an unresolved department just stays empty.
  Future<void> loadUserDepartmentSafely() async {
    if (_employeeEntity == null) {
      await _initializeEmployeeAndData();
    }

    userEmail = _employeeEntity?.email ?? '';
    if (userEmail.isEmpty) return;

    userDepartment = _cubit.resolveUserDepartment(_employeeEntity, userEmail);
  }

  int totalServices = 0;
  int executiveCount = 0;
  int customerSupportCount = 0;
  int operationsCount = 0;
  int financeCount = 0;
  int informationTechnologyCount = 0;
  int humanResourcesCount = 0;
  int marketingCount = 0;
  int salesCount = 0;
  int dataManagementCount = 0;
  int complianceLegalCount = 0;
  int softwareCount = 0;
  String selectStatus = "All";
  List<Map<String, dynamic>> allServices = [];
  bool isServiceListLoading = true;

  Map<String, String> get departmentTranslations =>
      HomeServicesDepartmentUtils.departmentTranslations;

  String getLocalizedDepartment(String key, bool isArabic) =>
      HomeServicesDepartmentUtils.getLocalizedDepartment(key, isArabic);

  String _normDept(String? raw) => HomeServicesDepartmentUtils.normalize(raw);

  void _applyFilters() {
    final model = ServicesManagerCubit.get(context).servicesRequest;

    // Get localized strings properly
    final l = S.of(context);
    final selectedKey = _getSelectedKeyByIndex(selectedStatusIndex, l);

    if (userDepartment.isEmpty) {
      // W-item1: single, well-scoped fallback reload — kept here (not moved
      // to the cubit) because it's tightly coupled to the setState-driven
      // filter flow immediately below it. Never throws past this boundary.
      userEmail = _employeeEntity?.email ?? '';
      if (userEmail.isNotEmpty) {
        userDepartment = _cubit.resolveUserDepartment(_employeeEntity, userEmail);
      }
    }

    final query = searchController.text.toLowerCase().trim();

    // Use l.all instead of "All"
    final selectedKeyCanonical = l.all;

    final list = HomeServicesVisibilityFilter.applyAllFilters(
      services: model,
      query: query,
      selectedKeyCanonical: selectedKeyCanonical,
      employeeEntity: _employeeEntity,
      userDepartment: userDepartment,
    );

    // Calculate department counts
    final keys = [
      "Executive",
      "Customer Support",
      "Operations",
      "Finance",
      "Information Technology",
      "Human Resources",
      "Marketing",
      "Sales",
      "Data Management",
      "Compliance & Legal",
      "Software",
    ];

    final Map<String, int> counts = { for (final k in keys) k: 0};
    var total = 0;

    int draftCount = 0;

    for (int i = 0; i < list.length; i++) {
      final service = list[i];

      final state = service.currentState?.toLowerCase().trim() ?? '';
      final isDraft = state == 'draft';

      if (isDraft) {
        draftCount++;
        continue;
      }

      final rawDept = service.currentDepartmentRequester;
      final sDept = _normDept(rawDept);

      if (sDept.isEmpty) {
        continue;
      }

      if (counts.containsKey(sDept)) {
        counts[sDept] = (counts[sDept] ?? 0) + 1;
        total++;
      }
    }

    if (mounted) {
      setState(() {
        filteredServices = list;

        executiveCount = counts["Executive"] ?? 0;
        customerSupportCount = counts["Customer Support"] ?? 0;
        operationsCount = counts["Operations"] ?? 0;
        financeCount = counts["Finance"] ?? 0;
        informationTechnologyCount = counts["Information Technology"] ?? 0;
        humanResourcesCount = counts["Human Resources"] ?? 0;
        marketingCount = counts["Marketing"] ?? 0;
        salesCount = counts["Sales"] ?? 0;
        dataManagementCount = counts["Data Management"] ?? 0;
        complianceLegalCount = counts["Compliance & Legal"] ?? 0;
        softwareCount = counts["Software"] ?? 0;
        totalServices = total;

        isServiceListLoading = false;
        _initialFilterApplied = true;
      });
    }
  }

  bool canUserSeeService(ServicesHistoryModel service, [int? index]) =>
      HomeServicesVisibilityFilter.canUserSeeService(
        employeeEntity: _employeeEntity,
        service: service,
        userDepartment: userDepartment,
      );

  Map<String, int> _createSortedDepartmentMap() {
    return HomeServicesVisibilityFilter.createSortedDepartmentMap({
      "Marketing": marketingCount,
      "Software": softwareCount,
      "Finance": financeCount,
      "Human Resources": humanResourcesCount,
      "Operations": operationsCount,
      "Executive": executiveCount,
      "Customer Support": customerSupportCount,
      "Information Technology": informationTechnologyCount,
      "Sales": salesCount,
      "Data Management": dataManagementCount,
      "Compliance & Legal": complianceLegalCount,
    });
  }

  /////////////////////////////////// Admin /////////////////////////////

  /// Waits for the employee to load, then runs the one-time bootstrap.
  /// I/O + error handling now live in HomePageServicesCubit.
  Future<void> _initializeEmployeeAndData() async {
    final entity = await _cubit.waitForEmployee();
    if (entity == null) return;

    _employeeEntity = entity;

    await _cubit.bootstrapAfterEmployeeLoaded();

    _searchController.addListener(_onSearchChanged);
    loadSelectedProviders();

    await startApp();
  }

  Future<void> startApp() async {
    await _cubit.persistRequesterProfile(employeeEntity);
  }

  String formatStartDate(dynamic timestampOrDateTime) =>
      HomeServicesDurationUtils.formatStartDate(timestampOrDateTime);

  Future<List<ServicesHistoryModel>> _getAllServicesIncludingDrafts() async {
    final servicesCubit = ServicesManagerCubit.get(context);

    // Use servicesRequest which now has repaired drafts
    final firestoreServices = servicesCubit.servicesRequest;

    final regularServices = firestoreServices.where((s) {
      final state = s.currentState?.toLowerCase().trim() ?? '';
      return state != 'draft';
    }).toList();

    final draftsInFirestore = firestoreServices.where((s) {
      final state = s.currentState?.toLowerCase().trim() ?? '';
      return state == 'draft';
    }).toList();

    // Additional Firebase drafts — I/O + error handling live in the cubit.
    final additionalDrafts = await _cubit.fetchAdditionalFirebaseDrafts();

    final combinedServices = <ServicesHistoryModel>[];
    final Set<String> addedIds = {};

    for (final service in [...regularServices, ...draftsInFirestore, ...additionalDrafts]) {
      if (!addedIds.contains(service.currentId)) {
        combinedServices.add(service);
        addedIds.add(service.currentId);
      }
    }

    return combinedServices;
  }

  void loadSelectedProviders() async {
    for (var service in ServicesManagerCubit.get(context).services) {
      final serviceId = service.currentId;
      if (serviceId.isNotEmpty) {
        final selected = await selectServiceProvider(serviceId);
        if (selected != null) {
          if (mounted) {
            setState(() {
              selectedProviders[serviceId] = selected;
            });
          }
        }
      }
    }
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    searchController.removeListener(_onSearchChangedRequest);
    searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  String getLocalizedDurationUnit(
    BuildContext context,
    String? rawUnit, {
    num? quantity,
  }) {
    return HomeServicesDurationUtils.getLocalizedDurationUnit(S.of(context), rawUnit);
  }

  String _getSelectedKeyByIndex(int index, S l) {
    switch (index) {
      case 0:
        return "All";
      case 1:
        return "Active";
      case 2:
        return "Inactive";
      case 3:
        return "Draft";
      default:
        return "All";
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = ServicesManagerCubit.get(context);
    // Only show loading on FIRST load, not on navigation back
    if (!_hasInitialized && (_isInitializing || !_dataFullyLoaded)) {
      return HomeServicesLoadingView(
        subtitle: Localizations.localeOf(context).languageCode == 'ar'
            ? "يرجى الانتظار ريثما يتم تحميل خدماتك..."
            : "Please wait while we load your services...",
      );
    }

    // MAIN CONTENT — show immediately on subsequent visits
    return BlocConsumer<ServicesManagerCubit, ServicesManagerState>(
      listener: (context, state) {
        if (state is GetServiceLoaded) {
          // Only process if fully initialized AND not already processing
          if (mounted && _hasInitialized && !_isProcessingUpdate) {
            final newServicesCount = ServicesManagerCubit
                .get(context)
                .servicesRequest
                .length;

            // Only apply filters if service count changed
            if (newServicesCount != _lastServicesCount) {
              setState(() {
                _isProcessingUpdate = true;
              });

              if (userDepartment.isEmpty && _employeeEntity != null) {
                userEmail = _employeeEntity?.email ?? '';
                if (userEmail.isNotEmpty) {
                  userDepartment =
                      _cubit.resolveUserDepartment(_employeeEntity, userEmail);
                }
              }

              _applyFilters();

              setState(() {
                _lastServicesCount = newServicesCount;
                _isProcessingUpdate = false;
              });
            }
          }
        } else if (state is GetServiceError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(S.of(context).errorLoadingServices),
                backgroundColor: AppColors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final servicesCubit = ServicesManagerCubit.get(context);

        // Show loading only for initial load (not for navigation back)
        if (state is GetServiceLoading && !_hasInitialized) {
          return const HomeServicesLoadingView();
        }

        // Show error state
        if (state is GetServiceError && !_hasInitialized) {
          return HomeServicesErrorView(
            title: 'Error loading services',
            message: 'Please try again later',
            onRetry: () async {
              setState(() {
                _isInitializing = true;
                _dataFullyLoaded = false;
                _hasInitialized = false;
              });
              await _initializeAllData();
            },
          );
        }

        // MAIN CONTENT with FutureBuilder
        return FutureBuilder<List<ServicesHistoryModel>>(
          future: _getAllServicesIncludingDrafts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !_hasInitialized) {
              return const HomeServicesLoadingView(
                subtitle: 'Loading draft services...',
              );
            }

            final allServices = snapshot.data ?? servicesCubit.services;
            final filteredModel = _getFilteredServices(allServices);

            // Process provider data
            final providerSelector = servicesCubit.providerSelector;
            List<ProviderData> providerList = [];

            if (providerSelector != null) {
              providerSelector.forEach((id, data) {
                final firstName = data['firstName'] ?? 'Unknown';
                final lastName = data['lastName'] ?? 'Unknown';
                final email = data['email'] ?? 'Unknown';
                final gender = data['gender'] ?? 'Unknown';
                final role = data['role'] ?? 'Unknown';
                final state = data['state'] ?? 'Unknown';
                final lastNameInArabic = data['lastNameInArabic'] ?? 'Unknown';
                final firstNameInArabic = data['firstNameInArabic'] ??
                    'Unknown';
                final title = data['title'] ?? 'Unknown';
                final phone = data['mobilePhone']?["phone"] ?? 'Unknown';

                providerList.add(
                  ProviderData(
                    id: id,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phone: phone,
                    gender: gender,
                    title: title,
                    role: role,
                    state: state,
                    firstNameInArabic: firstNameInArabic,
                    lastNameInArabic: lastNameInArabic,
                  ),
                );
              });
            }

            // FINAL UI — render immediately on subsequent visits
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: SideFrameMasterServices(
                  // ✅ FIX (bug report p20): this is the services *list* page,
                  // so the heading is plural. It read "Service".
                  titleText: S
                      .of(context)
                      .services,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: ClampingScrollPhysics(),
                    child: SlideInContent(
                      from: SlideFrom.bottom,
                      child: Column(
                        children: [
                          _buildServiceWidget(allServices, filteredModel),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildServiceWidget(List<ServicesHistoryModel> allServices, dynamic filteredModel) {
    return managementWidget(
      allServices: allServices,
      filteredModel: filteredModel,
    );
  }

  Widget managementWidget({
    required List<ServicesHistoryModel> allServices,
    required List<ServicesHistoryModel> filteredModel,
  }) {
    // Initialize animations when filtered model changes
    if (_slideAnimations.isEmpty || _slideAnimations.length != filteredModel.length) {
      _initializeGridAnimations(filteredModel.length);
    }

    return ManagementWidget(
      allServices: allServices,
      filteredModel: filteredModel,
      selectedProviders: selectedProviders,
      doneServicesCount: doneServicesCount,
      searchController: _searchController,
      isGridViewChoose: isGridViewChoose,
      isMobile: ContextExtension(context).isPhone,
      isArabic: Localizations.localeOf(context).languageCode == 'ar',
      lightMode: Theme.of(context).brightness == Brightness.light,
      employeeEntity: _employeeEntity,
      formatStartDate: formatStartDate,
      getLocalizedDurationUnit: getLocalizedDurationUnit,
      filterWidget: filterWidget,
      approvalAndServicesRequest: approvalAndServicesRequest,
      onToggleGridView: () => setState(() => isGridViewChoose = true),
      onToggleTableView: () => setState(() => isGridViewChoose = false),
    );
  }

  Widget requestServicesWidget() {
    // Show loading if data is not ready yet.
    // ✅ FIX (bug report p27): also wait for the first filter pass, otherwise
    // the empty-state illustration renders for a frame before the services do.
    if (!_hasInitialized || !_dataFullyLoaded || !_initialFilterApplied) {
      return HomeServicesLoadingView(
        subtitle: 'Please wait while we load your services...',
      );
    }

    // Filter by selected department BEFORE passing to widget
    List<ServicesHistoryModel> departmentFilteredServices = filteredServices;

    if (selectStatus != "All") {
      final selectedDeptNormalized = _normDept(selectStatus);

      departmentFilteredServices = filteredServices.where((service) {
        final serviceDept = _normDept(service.currentDepartmentRequester);
        return serviceDept == selectedDeptNormalized;
      }).toList();
    }

    final sortedMap = _createSortedDepartmentMap();

    return RequestServicesWidget(
      filteredServices: departmentFilteredServices,
      selectStatus: selectStatus,
      onStatusSelected: (key) {
        setState(() {
          selectStatus = key;
          isServiceListLoading = true;
        });
        // Don't call _applyFilters here - it will trigger rebuild automatically
      },
      totalServices: filteredServices.length,
      sortedMap: sortedMap,
      userDepartment: userDepartment,
      isArabic: Localizations
          .localeOf(context)
          .languageCode == 'ar',
      searchController: searchController,
      getLocalizedDurationUnit: getLocalizedDurationUnit,
      selectServiceProvider: selectServiceProvider,
    );
  }

  Widget filterWidget(List<ServicesHistoryModel> allServices) {
    return HomeServicesStatusFilter(
      allServices: allServices,
      currentUserEmail: _employeeEntity?.email ?? '',
      selectedStatusIndex: selectedStatusIndex,
      onIndexSelected: (index) => setState(() => selectedStatusIndex = index),
    );
  }

  List<ServicesHistoryModel> _getFilteredServices(List<ServicesHistoryModel> allServices) {
    return HomeServicesVisibilityFilter.getFilteredServices(
      allServices: allServices,
      searchQuery: _searchController.text,
      currentUserEmail: _employeeEntity?.email ?? '',
      selectedStatusIndex: selectedStatusIndex,
    );
  }

  // W03: presentation never calls Firestore — delegate to the cubit, which
  // delegates to the repository.
  Future<Map<String, dynamic>?> selectServiceProvider(String serviceId) {
    return _cubit.selectServiceProvider(serviceId);
  }
}
