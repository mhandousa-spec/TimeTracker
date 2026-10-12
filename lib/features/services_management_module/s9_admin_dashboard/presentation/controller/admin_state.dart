// ******************* FILE INFO *******************
// File Name: admin_state.dart
// Description: State model for Admin Dashboard Cubit
// Module: services_management_module / presentation / s9_admin_dashboard / controller
// Created by: Amr Mesbah

class DashboardAdminState {
  // Bootstrap
  final bool bootstrapping;
  final bool bootstrapped;
  final bool tableDataLoaded;

  // Filter
  final String selectStatus;
  final bool showRequests;
  final bool showAll;

  // Loading flags
  final bool isLoading;
  final bool isLoadingFirst;
  final bool isLoadingRequests;
  final bool isLoadingServicesName;
  final bool isLoadingDepartments;
  final bool isServiceListLoading;

  // Status counts
  final Map<String, int> statusCounts;

  // Monthly data
  final Map<int, double> monthCounts;
  final Map<int, num> monthHours;
  final Map<int, double> monthCountss;

  // Service display toggle
  final bool showServiceCount;

  // Service names
  final List<String> serviceNames;
  final List<String> serviceNamesArabic;

  // Department breakdown counts
  final int totalServices;
  final int executiveCount;
  final int customerSupportCount;
  final int operationsCount;
  final int financeCount;
  final int informationTechnologyCount;
  final int humanResourcesCount;
  final int marketingCount;
  final int salesCount;
  final int dataManagementCount;
  final int complianceLegalCount;
  final int softwareCount;
  final Map<String, int> departmentCounts;

  // Table data
  final List<Map<String, dynamic>> displayedItems;

  // Service list (grid cards)
  final List<Map<String, dynamic>> allServices;

  const DashboardAdminState({
    required this.bootstrapping,
    required this.bootstrapped,
    required this.tableDataLoaded,
    required this.selectStatus,
    required this.showRequests,
    required this.showAll,
    required this.isLoading,
    required this.isLoadingFirst,
    required this.isLoadingRequests,
    required this.isLoadingServicesName,
    required this.isLoadingDepartments,
    required this.isServiceListLoading,
    required this.statusCounts,
    required this.monthCounts,
    required this.monthHours,
    required this.monthCountss,
    required this.showServiceCount,
    required this.serviceNames,
    required this.serviceNamesArabic,
    required this.totalServices,
    required this.executiveCount,
    required this.customerSupportCount,
    required this.operationsCount,
    required this.financeCount,
    required this.informationTechnologyCount,
    required this.humanResourcesCount,
    required this.marketingCount,
    required this.salesCount,
    required this.dataManagementCount,
    required this.complianceLegalCount,
    required this.softwareCount,
    required this.departmentCounts,
    required this.displayedItems,
    required this.allServices,
  });

  factory DashboardAdminState.initial() => DashboardAdminState(
    bootstrapping: false,
    bootstrapped: false,
    tableDataLoaded: false,
    selectStatus: 'All',
    showRequests: true,
    showAll: false,
    isLoading: true,
    isLoadingFirst: true,
    isLoadingRequests: true,
    isLoadingServicesName: true,
    isLoadingDepartments: true,
    isServiceListLoading: true,
    statusCounts: const {},
    monthCounts: const {},
    monthHours: const {},
    monthCountss: const {},
    showServiceCount: true,
    serviceNames: const [],
    serviceNamesArabic: const [],
    totalServices: 0,
    executiveCount: 0,
    customerSupportCount: 0,
    operationsCount: 0,
    financeCount: 0,
    informationTechnologyCount: 0,
    humanResourcesCount: 0,
    marketingCount: 0,
    salesCount: 0,
    dataManagementCount: 0,
    complianceLegalCount: 0,
    softwareCount: 0,
    departmentCounts: const {},
    displayedItems: const [],
    allServices: const [],
  );

  DashboardAdminState copyWith({
    bool? bootstrapping,
    bool? bootstrapped,
    bool? tableDataLoaded,
    String? selectStatus,
    bool? showRequests,
    bool? showAll,
    bool? isLoading,
    bool? isLoadingFirst,
    bool? isLoadingRequests,
    bool? isLoadingServicesName,
    bool? isLoadingDepartments,
    bool? isServiceListLoading,
    Map<String, int>? statusCounts,
    Map<int, double>? monthCounts,
    Map<int, num>? monthHours,
    Map<int, double>? monthCountss,
    bool? showServiceCount,
    List<String>? serviceNames,
    List<String>? serviceNamesArabic,
    int? totalServices,
    int? executiveCount,
    int? customerSupportCount,
    int? operationsCount,
    int? financeCount,
    int? informationTechnologyCount,
    int? humanResourcesCount,
    int? marketingCount,
    int? salesCount,
    int? dataManagementCount,
    int? complianceLegalCount,
    int? softwareCount,
    Map<String, int>? departmentCounts,
    List<Map<String, dynamic>>? displayedItems,
    List<Map<String, dynamic>>? allServices,
  }) {
    return DashboardAdminState(
      bootstrapping: bootstrapping ?? this.bootstrapping,
      bootstrapped: bootstrapped ?? this.bootstrapped,
      tableDataLoaded: tableDataLoaded ?? this.tableDataLoaded,
      selectStatus: selectStatus ?? this.selectStatus,
      showRequests: showRequests ?? this.showRequests,
      showAll: showAll ?? this.showAll,
      isLoading: isLoading ?? this.isLoading,
      isLoadingFirst: isLoadingFirst ?? this.isLoadingFirst,
      isLoadingRequests: isLoadingRequests ?? this.isLoadingRequests,
      isLoadingServicesName: isLoadingServicesName ?? this.isLoadingServicesName,
      isLoadingDepartments: isLoadingDepartments ?? this.isLoadingDepartments,
      isServiceListLoading: isServiceListLoading ?? this.isServiceListLoading,
      statusCounts: statusCounts ?? this.statusCounts,
      monthCounts: monthCounts ?? this.monthCounts,
      monthHours: monthHours ?? this.monthHours,
      monthCountss: monthCountss ?? this.monthCountss,
      showServiceCount: showServiceCount ?? this.showServiceCount,
      serviceNames: serviceNames ?? this.serviceNames,
      serviceNamesArabic: serviceNamesArabic ?? this.serviceNamesArabic,
      totalServices: totalServices ?? this.totalServices,
      executiveCount: executiveCount ?? this.executiveCount,
      customerSupportCount: customerSupportCount ?? this.customerSupportCount,
      operationsCount: operationsCount ?? this.operationsCount,
      financeCount: financeCount ?? this.financeCount,
      informationTechnologyCount: informationTechnologyCount ?? this.informationTechnologyCount,
      humanResourcesCount: humanResourcesCount ?? this.humanResourcesCount,
      marketingCount: marketingCount ?? this.marketingCount,
      salesCount: salesCount ?? this.salesCount,
      dataManagementCount: dataManagementCount ?? this.dataManagementCount,
      complianceLegalCount: complianceLegalCount ?? this.complianceLegalCount,
      softwareCount: softwareCount ?? this.softwareCount,
      departmentCounts: departmentCounts ?? this.departmentCounts,
      displayedItems: displayedItems ?? this.displayedItems,
      allServices: allServices ?? this.allServices,
    );
  }
}