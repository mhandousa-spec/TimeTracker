part of 'services_manager_cubit.dart';

// Methods extracted from services_manager_cubit.dart to keep it <700 LOC.
extension ServicesManagerCubitPart on ServicesManagerCubit {
  Future<void> loadSlaData() async {
    emit(ServicesLoading());
    try {
      final data = await repository.loadFromSharedPrefs();

      slaOne = data.slaOne;
      slaTwo = data.slaTwo;

      notifyRequesterChecked = data.notifyRequesterChecked;
      notifyProviderChecked = data.notifyProviderChecked;
      notifyManagerChecked = data.notifyManagerChecked;

      notifyRequesterSwitch0 = data.notifyRequesterSwitch0;
      notifyManagerSwitch1 = data.notifyManagerSwitch1;

      extraSlaOneList = data.extraSlaValues;
      extraSlaTwoList = data.extraSlaTwoValues;
      notificationSwitches = data.notificationSwitches;

      emit(SlaDataLoaded());
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> saveSlaDraft(ServicesHistoryModel model, {ServicesHistoryModel? oldModel}) async {
    emit(ServicesLoading());
    try {
      if (oldModel != null) {
        await repository.updateDraft(oldModel, model);
      } else {
        await repository.saveDraft(model);
      }
      emit(SlaDraftSaved());
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> submitSlaService(String docId, ServicesHistoryModel model, {required bool isUpdate}) async {
    emit(ServicesLoading());
    try {
      if (isUpdate) {
        await repository.updateService(docId, model);
      } else {
        await repository.saveService(docId, model);
      }

      emit(SlaServiceSubmitted());
    } catch (e) {
      emit(ServicesError(e.toString()));
    }
  }

  Future<void> submitSlaData({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required List<String> extraSlaList,
    required List<String> extraSlaTwoList,
    required Map<String, Map<int, bool>> notificationSwitches,
  }) async {
    emit(SlaSaving());
    try {
      await repository.saveSlaToPrefs(
        slaOne: slaOne,
        slaTwo: slaTwo,
        notifyRequesterChecked: notifyRequesterChecked,
        notifyProviderChecked: notifyProviderChecked,
        notifyManagerChecked: notifyManagerChecked,
        notifyRequesterSwitch0: notifyRequesterSwitch0,
        notifyManagerSwitch1: notifyManagerSwitch1,
        extraSlaList: extraSlaList,
        extraSlaTwoList: extraSlaTwoList,
        notificationSwitches: notificationSwitches,
      );
      emit(SlaSaved());
    } catch (e) {
      emit(SlaError(e.toString()));
    }
  }

  Future<void> loadRequestServices(BuildContext context) async {
    emit(RequestServicesLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      userEmail = prefs.getString("emailRequester") ?? '';
      userDepartment = MainCoreEmployeeController().getEmployeeDepartmentName(userEmail);

      allServices = await repository.getFilteredServices(services, userEmail, userDepartment);
      final deptCounts = await repository.getDepartmentCounts(services, userDepartment);

      emit(RequestServicesLoaded(services: allServices, departmentCounts: deptCounts));
    } catch (e) {
      emit(RequestServicesError(e.toString()));
    }
  }

  searchServices(String query) {
    final lowerQuery = query.toLowerCase().trim();
    return allServices.where((service) {
      // ✅ UPDATED: Access current values
      final en = service.currentServiceNameEnglish.toLowerCase();
      final ar = service.currentServiceNameArabic.toLowerCase();
      return en.contains(lowerQuery) || ar.contains(lowerQuery);
    }).toList();
  }

  filterByDepartment(String department) {
    return department == "All"
        ? allServices
        : allServices.where((s) =>
    s.currentDepartmentRequester.toLowerCase() == department.toLowerCase()
    ).toList();
  }

  /// Builds the filtered request list + stats for a parent service
  /// (heavy lifting in ServicesFilterLoader).
  Future<Map<String, dynamic>> loadFilteredItems({
    required String? parentServiceId,
    required BuildContext context,
    required ServicesHistoryModel parentService,
  }) {
    return _filterLoader.loadFilteredItems(
      parentServiceId: parentServiceId,
      context: context,
      parentService: parentService,
    );
  }
}
