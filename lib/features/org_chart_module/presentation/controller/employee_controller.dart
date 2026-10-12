import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employees_hierarchy_drawer.dart';
import 'package:knowticed_plus/core/custom/31-custom_multi_select_dropdown.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';

import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart' as newDepartmentModel;
import 'package:knowticed_plus/features/settings/main_controller/data/models/employee_directory_model.dart';
import 'package:knowticed_plus/features/org_chart_module/data/repository/employees_repository.dart';
import 'package:knowticed_plus/features/org_chart_module/domain/entities/organization_hierarchy_node.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:knowticed_plus/features/settings/se5_emergency_contact/presentation/controller/emergency_contact_controller.dart';
import 'package:intl/intl.dart';

/// Date: Jan/8/2024
/// By: MohamedFouad
/// Last Update: Migrated to NewEmployeeModelHistory model
/// Description: Controller for Employee management - handles CRUD operations,
///              hierarchy management, and employee data retrieval

class OrgChartEmployeeController extends GetxController with StateMixin {
  // Repository for employee data operations
  final EmployeesRepository employeesRepository = EmployeesRepository();

  // Organization hierarchy structures
  Map<String, OrganizationHierarchyNode> organizationHierarchyNodes = {};
  Map<String, OrganizationHierarchyNode> organizationHierarchyNodesRoots = {};

  // View state flags
  bool chartSelected = false;
  bool orgSelected = true;

  // ✅ NEW: Selected department for filtering (stores localized name)
  String? selectedDepartment;

  NewEmployeeModelHistory? employee;

  List<NewEmployeeModelHistory>? allnNewEmployees;
  List<newDepartmentModel.DepartmentModelPro> newDepartmentModels = [];
  int graphDepth = 0;

  @override
  onInit() {
    super.onInit();
    getAllEmployees();
    // NOTE: SettingsHealthInsuranceController is intentionally NOT registered
    // here. In skeleton_app it takes a SettingsController in its constructor,
    // and SettingsController itself does `OrgChartEmployeeController addEmployeeController
    // = Get.find()` — so building one from inside OrgChartEmployeeController.onInit()
    // would be circular. SettingsController.onInit() already creates the
    // instance (`healthInsuranceController = SettingsHealthInsuranceController(this)`),
    // so read it from there when you need it:
    //   Get.find<SettingsController>().healthInsuranceController
    Get.put(EmergencyContactController());
  }

  /// function name: activateAccount
  /// function purpose: activate a user account (first login)
  /// parameters:
  ///   - employee: NewEmployeeModelHistory - employee to activate
  ///   - isDemoActivation: bool - whether this is a demo activation
  /// ✅ UPDATED: Uses NewEmployeeModelHistory with copyWithUpdateSynchronized
  activateAccount(NewEmployeeModelHistory employee, bool isDemoActivation) {
    // Format the activation date and first login date
    String formattedDate = DateFormat(Constants.userAccessDateFormat, 'en')
        .format(DateTime.now());
    String firstLoginDate = DateTime.now().toString();

    // ✅ Update using copyWithUpdateSynchronized
    employee = employee.copyWithUpdateSynchronized(
      activationDate: formattedDate,
      firstLogin: firstLoginDate,
      addTimestamp: DateTime.now().millisecondsSinceEpoch,
    );

    // ✅ Get last email from array
    String userEmail = employee.email.isNotEmpty
        ? employee.email.last
        : '';

    createEmployee(employee, userEmail);
    activateAccountOverview(userEmail, isDemoActivation);
  }

  FirebaseFirestore db = FirebaseFirestore.instance;


  /// function name: fixSupervisorEmailDomains
  /// function purpose: Update all supervisor emails to match current company domain
  /// parameters:
  ///   - fromDomain: String - old domain (e.g., '@bayanatz.com')
  ///   - toDomain: String - new domain (e.g., '@spacex.com')
  Future<void> fixSupervisorEmailDomains({
    required String fromDomain,
    required String toDomain,
  }) async {

    if (allEmployees == null || allEmployees!.isEmpty) {
      return;
    }


    // Build the correct collection path
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      collectionPath = ApiConstants.employeeInfo;
    }

    final CollectionReference employeeCollection = db.collection(collectionPath);

    int updatedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    for (var employee in allEmployees!) {
      String empEmail = employee.email.isNotEmpty ? employee.email.last : '';
      String empName = "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}".trim();

      // Check if supervisor field needs updating
      if (employee.supervisor?.isNotEmpty == true) {
        String currentSupervisorEmail = employee.supervisor!.last?.trim() ?? '';

        if (currentSupervisorEmail.endsWith(fromDomain)) {
          // Replace the domain
          String newSupervisorEmail = currentSupervisorEmail.replaceAll(fromDomain, toDomain);


          try {
            // Create updated supervisor array
            List<String?> updatedSupervisorArray = List.from(employee.supervisor!);
            updatedSupervisorArray[updatedSupervisorArray.length - 1] = newSupervisorEmail;

            // Update in Firestore
            await employeeCollection.doc(employee.id).update({
              'Supervisor': updatedSupervisorArray,
            });

            updatedCount++;

          } catch (e) {
            errorCount++;
          }

        } else {
          skippedCount++;
        }
      } else {
        skippedCount++;
      }
    }


    // Reload employees after update
    await getAllEmployees();
  }

  // ✅ UPDATED: Use NewEmployeeModelHistory
  Rx<NewEmployeeModelHistory> employeeModel = NewEmployeeModelHistory().obs;
  Rx<EmployeeDirectoryModel> employeeemployeeDirectoryModelModel =
      EmployeeDirectoryModel().obs;

  List<NewEmployeeModelHistory>? allEmployees;
  List<NewEmployeeModelHistory>? employeesWithoutFilter;
  List<EmployeeDirectoryModel>? allEmployeesDirectory;

  NewEmployeeModelHistory employeePhone = NewEmployeeModelHistory();
  List<MultiSelectDropdownItem<dynamic>> selectedDaysOptions = [];

  void selecteItem(List<MultiSelectDropdownItem<dynamic>> item) {
    selectedDaysOptions.clear();
    selectedDaysOptions.addAll(item);
    update();
  }

  AddDepartmentController addDepartmentController =
  Get.put(AddDepartmentController());
  EmployeeDirectoryModel employeeDirectoryPhone = EmployeeDirectoryModel();

  /// function name: createEmployee
  /// function purpose: create or update employee in Firestore
  /// parameters:
  ///   - employeeModelNew: NewEmployeeModelHistory - employee data to save
  ///   - email: String - employee email
  /// ✅ UPDATED: Uses NewEmployeeModelHistory
  Future createEmployee(
      NewEmployeeModelHistory employeeModelNew, String email) async {
    update();

    // ✅ Build the correct collection path (same logic as getEmployee)
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      // Demo/Production mode: Demo/84763782/Employees_Info
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      // Fallback to direct path
      collectionPath = ApiConstants.employeeInfo;
    }


    final CollectionReference employeeCollection = db.collection(collectionPath);

    final dataToSave = employeeModelNew.toMap();

    await employeeCollection
        .doc(employeeModelNew.id)
        .set(dataToSave, SetOptions(merge: true));


    update();
    change(employeeModelNew, status: RxStatus.success());
  }

  /// function name: clearCollection
  /// function purpose: delete all documents in a collection
  /// parameters:
  ///   - collection: CollectionReference - collection to clear
  Future<void> clearCollection(CollectionReference collection) async {
    QuerySnapshot snapshot = await collection.get();
    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// function name: backupCollections
  /// function purpose: create backup of employee collections (2-level backup)
  /// UPDATED: Added comprehensive logging to track backup process
  Future<void> backupCollections() async {

    final FirebaseFirestore db = FirebaseFirestore.instance;


    // ✅ Build consistent paths for all collections
    String mainCollectionPath;
    String backupOneCollectionPath;
    String backupTwoCollectionPath;

    if (ApiConstants.baseUri.isNotEmpty) {
      // Demo/Production mode: Use base URI for ALL collections
      mainCollectionPath = '${ApiConstants.baseUri}/Employees_Info';
      backupOneCollectionPath = '${ApiConstants.baseUri}/Employees Backup One';
      backupTwoCollectionPath = '${ApiConstants.baseUri}/Employees Backup Two';
    } else {
      // Fallback to direct paths
      mainCollectionPath = ApiConstants.employeeInfo;
      backupOneCollectionPath = ApiConstants.employeesProfileBackUpOne;
      backupTwoCollectionPath = ApiConstants.employeesProfileBackUpTwo;
    }

    final CollectionReference employeeCollection = db.collection(mainCollectionPath);
    final CollectionReference backupCollectionOne = db.collection(backupOneCollectionPath);
    final CollectionReference backupCollectionTwo = db.collection(backupTwoCollectionPath);


    try {
      // ✅ Read FRESH data from main collection
      QuerySnapshot snapshot = await employeeCollection.get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs.take(3)) {
          var data = doc.data() as Map<String, dynamic>;
          var email = data['Email'] is List ? data['Email'].last : data['Email'];
        }
      } else {
      }

      QuerySnapshot snapshotBackupOne = await backupCollectionOne.get();

      // Move backup 1 to backup 2
      await clearCollection(backupCollectionTwo);

      int copiedToBackup2 = 0;
      for (var doc in snapshotBackupOne.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await backupCollectionTwo.doc(doc.id).set(data, SetOptions(merge: true));
        copiedToBackup2++;

        // Progress indicator for large datasets
        if (copiedToBackup2 % 10 == 0) {
        }
      }

      // Move main to backup 1
      await clearCollection(backupCollectionOne);

      int copiedToBackup1 = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await backupCollectionOne.doc(doc.id).set(data, SetOptions(merge: true));
        copiedToBackup1++;

        // Progress indicator for large datasets
        if (copiedToBackup1 % 10 == 0) {
        }
      }


    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// function name: restoreFromBackup
  /// function purpose: restore employee collection from backup
  /// parameters:
  ///   - backupVersion: String - 'first' or 'second' backup to restore from
  Future<void> restoreFromBackup(String backupVersion) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final CollectionReference mainCollection =
    db.collection(ApiConstants.employeeInfo);
    final CollectionReference backupCollectionOne =
    db.collection(ApiConstants.employeesProfileBackUpOne);
    final CollectionReference backupCollectionTwo =
    db.collection(ApiConstants.employeesProfileBackUpTwo);

    // Clear the main collection
    await clearCollection(mainCollection);

    if (backupVersion == 'first') {
      // Read all documents from backup collection 1
      QuerySnapshot snapshot = await backupCollectionOne.get();

      // Write all documents to the main collection
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await mainCollection.doc(doc.id).set(data, SetOptions(merge: true));
      }
    } else if (backupVersion == 'second') {
      // Read all documents from backup collection 2
      QuerySnapshot snapshot = await backupCollectionTwo.get();

      // Write all documents to the main collection
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await mainCollection.doc(doc.id).set(data, SetOptions(merge: true));
      }
    }
  }

  /// Method Name: getAllEmployees
  /// Purpose: function to get all employees and filter active employees
  /// ✅ UPDATED: Returns List<NewEmployeeModelHistory>
  getAllEmployees() async {
    Either<Failure, dynamic> result;
    result = await employeesRepository.getAllEmployees();

    if (result.isRight()) {
      // ✅ Cast properly
      var rawData = result.getOrElse(() => <NewEmployeeModelHistory>[]);
      employeesWithoutFilter = (rawData is List)
          ? rawData.cast<NewEmployeeModelHistory>()
          : <NewEmployeeModelHistory>[];
      allEmployees = employeesWithoutFilter;
    }

    update();

    try {
      await Get.find<MainCoreEmployeeController>().getAllNewEmployees();

      // ✅ ONLY access employee if it's initialized
      if (employee != null && employee!.email.isNotEmpty) {
        String userEmail = employee!.email.last;
        await Get.find<MainCoreEmployeeController>().getNewEmployee(userEmail);
      }
    } catch (e) {
    }

    return allEmployees;
  }

  /// function name: getEmployeeName
  /// function purpose: get employee full name based on current locale
  /// parameters:
  ///   - email: String - employee email
  /// return: String - employee full name
  /// ✅ UPDATED: Uses array-based fields
  String getEmployeeName(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return Get.locale.toString().contains('en')
        ? "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}"
        : "${employee.firstNameInArabic.isNotEmpty ? employee.firstNameInArabic.last : ''} ${employee.lastNameInArabic.isNotEmpty ? employee.lastNameInArabic.last : ''}";
  }

  /// function name: getEmployeeEmailFromId
  /// function purpose: get employee email from employee ID
  /// parameters:
  ///   - employeeId: String - employee ID
  /// return: String - employee email
  /// ✅ UPDATED: Uses array-based email field
  String getEmployeeEmailFromId(String employeeId) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => employeeId == element.id);
    return employee.email.isNotEmpty ? employee.email.last : '';
  }

  /// function name: getEmployeeNameEnglishArabic
  /// function purpose: get employee name in specific language
  /// parameters:
  ///   - email: String - employee email
  ///   - isEnglish: bool - true for English, false for Arabic
  /// return: String - employee full name
  /// ✅ UPDATED: Uses array-based fields
  String getEmployeeNameEnglishArabic(String email, bool isEnglish) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return isEnglish
        ? "${employee.firstName.isNotEmpty ? employee.firstName.last : ''} ${employee.lastName.isNotEmpty ? employee.lastName.last : ''}"
        : "${employee.firstNameInArabic.isNotEmpty ? employee.firstNameInArabic.last : ''} ${employee.lastNameInArabic.isNotEmpty ? employee.lastNameInArabic.last : ''}";
  }

  /// function name: getEmployeeJobTitle
  /// function purpose: get employee job title based on current locale
  /// parameters:
  ///   - email: String - employee email
  /// return: String - employee job title
  /// ✅ UPDATED: Uses array-based title fields
  String getEmployeeJobTitle(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    return Get.locale.toString().contains('en')
        ? (employee.title.isNotEmpty ? employee.title.last : '')
        : (employee.titleInArabic.isNotEmpty ? employee.titleInArabic.last : '');
  }

  /// function name: getEmployeePhoto
  /// function purpose: get employee photo URL or default avatar
  /// parameters:
  ///   - email: String - employee email
  /// return: String - photo URL or asset path
  /// ✅ UPDATED: Uses array-based photo and gender fields
  String getEmployeePhoto(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);

    bool hasPhoto = employee.photo.isNotEmpty && employee.photo.last.isNotEmpty;

    if (!hasPhoto) {
      bool isFemale = employee.gender.isNotEmpty &&
          employee.gender.last.toLowerCase() == 'female';
      return isFemale
          ? "assets/icons_assets/main_icons_assets/images_female.svg"
          : "assets/icons_assets/main_icons_assets/assets_male.svg";
    }

    return employee.photo.last;
  }

  /// function name: getDepartment
  /// function purpose: get department name based on current locale
  /// parameters:
  ///   - department: String - department ID
  /// return: String - department name
  String getDepartment(String department) {
    return Get.locale.toString().contains('en')
        ? (addDepartmentController.getEnglishDepartmentNameFromDepartmentId(
        departmentId: department) ??
        "")
        .toLowerCase()
        : (addDepartmentController.getArabicDepartmentNameFromDepartmentId(
        departmentId: department) ??
        "");
  }

  /// function name: getLocaleEmployee
  /// function purpose: get employee object by email
  /// parameters:
  ///   - email: String - employee email
  /// return: NewEmployeeModelHistory - employee data
  /// ✅ UPDATED: Returns NewEmployeeModelHistory
  NewEmployeeModelHistory getLocaleEmployee(String email) {
    NewEmployeeModelHistory employee = employeesWithoutFilter!
        .firstWhere((element) => email == element.email.last);
    return employee;
  }

  /// function name: getEmployee
  /// function purpose: get employee from Firestore by email
  /// parameters:
  ///   - email: String - employee email
  /// return: Future<NewEmployeeModelHistory?> - employee data or null
  /// ✅ UPDATED: Returns NewEmployeeModelHistory and uses arrayContains
  Future<NewEmployeeModelHistory?> getEmployee(String email) async {

    // ✅ Build the correct collection path
    String collectionPath;
    if (ApiConstants.baseUri.isNotEmpty) {
      // Demo/Production mode: Demo/84763782/Employees_Info
      collectionPath = '${ApiConstants.baseUri}/Employees_Info';
    } else {
      // Fallback to direct path
      collectionPath = ApiConstants.employeeInfo;
    }


    final CollectionReference employeeCollection = db.collection(collectionPath);

    try {
      QuerySnapshot employeeSnapshot = await employeeCollection
          .where('Email', arrayContains: email)
          .limit(1)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        employee = NewEmployeeModelHistory.fromMap(
            employeeSnapshot.docs[0].data() as Map);
        update();
        return employee;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      return null;
    }
  }

  /// function name: getEmployeeDirectory
  /// function purpose: get employee directory entry by email
  /// parameters:
  ///   - email: String - employee email
  /// return: Future<EmployeeDirectoryModel?> - directory data or null
  Future<EmployeeDirectoryModel?> getEmployeeDirectory(String email) async {
    final CollectionReference employeeDirectoryCollection =
    db.collection(ApiConstants.employeesDirectory);
    DocumentSnapshot employeeDirectorySnapshot =
    await employeeDirectoryCollection.doc(email).get();

    if (employeeDirectorySnapshot.exists) {
      EmployeeDirectoryModel employee = EmployeeDirectoryModel.fromMap(
          employeeDirectorySnapshot.data() as Map);
      return employee;
    } else {
      return null;
    }
  }
  /// function name: removeKnowticedCompanyAccountsDirect
  /// function purpose: Remove all accounts with @knowticedcompany domain from Demo_Users_Accounts
  /// Uses direct path: Demo_Users_Accounts
  Future<void> removeKnowticedCompanyAccountsDirect() async {

    try {
      // ✅ Direct path to Demo_Users_Accounts
      const String collectionPath = 'Demo_Users_Accounts';


      final CollectionReference accountsCollection = db.collection(collectionPath);

      // Get all documents
      QuerySnapshot snapshot = await accountsCollection.get();


      int deletedCount = 0;
      int skippedCount = 0;
      List<String> deletedEmails = [];

      for (var doc in snapshot.docs) {
        try {
          String docId = doc.id;

          // Document ID is the email itself (based on your screenshot)
          if (docId.contains('@knowticedcompany')) {
            await doc.reference.delete();
            deletedCount++;
            deletedEmails.add(docId);
          } else {
            skippedCount++;
            if (skippedCount <= 3) { // Show first 3 skipped
            }
          }
        } catch (e) {
        }
      }


      if (deletedEmails.isNotEmpty) {
        for (var email in deletedEmails.take(10)) { // Show first 10
        }
        if (deletedEmails.length > 10) {
        }
      }


    } catch (e, stackTrace) {
      rethrow;
    }
  }
  /// function name: filterEmployeesByDepartmentId
  /// function purpose: filter employees by department and build org chart
  /// parameters:
  ///   - value: String? - department ID or 'All'
  /// ✅ UPDATED: Tracks selected department for filter chips and handles null values
  filterEmployeesByDepartmentId(String? value) async {
    List<NewEmployeeModelHistory> graphEmployees = [];

    bool isArabic = Get.locale?.languageCode == 'ar';
    String allLabel = isArabic ? 'الكل' : 'All';

    if (value == null || value == 'All') {
      selectedDepartment = allLabel;
      graphEmployees = List.from(allEmployees ?? []);
    } else {
      selectedDepartment = getDepartment(value);
      if (selectedDepartment?.isEmpty ?? true) selectedDepartment = allLabel;

      // Get the filtered department employees
      List<NewEmployeeModelHistory> deptEmployees = allEmployees!
          .where((employee) =>
      employee.departmentId.isNotEmpty &&
          employee.departmentId.last == value)
          .toList();

      // ✅ Walk up the supervisor chain for each employee and include their full chain
      Set<String> emailsToInclude = {};
      Map<String, NewEmployeeModelHistory> emailMap = {
        for (var e in allEmployees!)
          if (e.email.isNotEmpty) e.email.last.trim(): e
      };

      for (var emp in deptEmployees) {
        String? current = emp.email.isNotEmpty ? emp.email.last.trim() : null;
        while (current != null && !emailsToInclude.contains(current)) {
          emailsToInclude.add(current);
          NewEmployeeModelHistory? empObj = emailMap[current];
          current = (empObj?.supervisor?.isNotEmpty == true)
              ? empObj!.supervisor!.last?.trim()
              : null;
        }
      }

      graphEmployees = allEmployees!
          .where((e) =>
      e.email.isNotEmpty && emailsToInclude.contains(e.email.last.trim()))
          .toList();
    }


    buildOrganizationHierarchyGraph(graphEmployees);
    update();
  }

  Map<String, int> topCountries = {};

  /// function name: countCountries
  /// function purpose: count employees by nationality and get top 3
  /// return: Map<String, int> - country counts (top 3)
  /// ✅ UPDATED: Uses array-based nationality field
  Map<String, int> countCountries() {
    Map<String, int> countryCount = {};

    for (var employee in allEmployees!) {
      String nationality = employee.nationality.isNotEmpty
          ? employee.nationality.last
          : 'Unknown';

      if (nationality.isNotEmpty && nationality != 'Unknown') {
        countryCount[nationality] = (countryCount[nationality] ?? 0) + 1;
      }
    }

    var sortedEntries = countryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topCountries = Map<String, int>.fromEntries(sortedEntries.take(3));
    return topCountries;
  }

  /// function name: activateAccountOverview
  /// function purpose: activate account overview in demo system
  /// parameters:
  ///   - email: String - employee email
  ///   - isDemoActivation: bool - whether this is demo activation
  void activateAccountOverview(String email, bool isDemoActivation) {
    employeesRepository.activateAccountOverview(email, isDemoActivation);
  }


  /// function name: diagnoseHierarchyIssues
  /// function purpose: Diagnose why hierarchy is not building correctly
  /// return: Map with diagnostic results
  Map<String, dynamic> diagnoseHierarchyIssues() {

    Map<String, dynamic> diagnostics = {
      'totalEmployees': allEmployees?.length ?? 0,
      'employeesWithSupervisor': 0,
      'employeesWithoutSupervisor': 0,
      'orphanedEmployees': [],
      'invalidSupervisorEmails': [],
      'ceoCount': 0,
      'supervisorEmailNotFound': [],
      'circularReferences': [],
      'employeeDetails': [],
    };

    if (allEmployees == null || allEmployees!.isEmpty) {
      return diagnostics;
    }

    // Create email lookup map
    Map<String, bool> validEmails = {};
    for (var emp in allEmployees!) {
      String email = emp.email.isNotEmpty ? emp.email.last : '';
      if (email.isNotEmpty) {
        validEmails[email.trim()] = true;
      }
    }


    // Analyze each employee
    for (var employee in allEmployees!) {
      String empEmail = employee.email.isNotEmpty ? employee.email.last : '';
      String empName = employee.firstName.isNotEmpty && employee.lastName.isNotEmpty
          ? "${employee.firstName.last} ${employee.lastName.last}"
          : empEmail;
      String supervisorEmail = employee.supervisor?.isNotEmpty == true
          ? employee.supervisor!.last?.trim() ?? ''
          : '';
      String title = employee.title.isNotEmpty ? employee.title.last : 'No Title';

      Map<String, dynamic> empDetails = {
        'name': empName,
        'email': empEmail,
        'title': title,
        'supervisorEmail': supervisorEmail,
        'hasSupervisor': supervisorEmail.isNotEmpty,
        'supervisorExists': false,
        'issues': [],
      };

      // Check if has supervisor
      if (supervisorEmail.isEmpty) {
        diagnostics['employeesWithoutSupervisor']++;

        // Check if this should be CEO
        bool isCEO = title.toLowerCase().contains('ceo') ||
            title.toLowerCase().contains('chief executive') ||
            title.contains('رئيس تنفيذي');

        if (isCEO) {
          diagnostics['ceoCount']++;
          empDetails['issues'].add('✓ Valid CEO (no supervisor needed)');
        } else {
          empDetails['issues'].add('⚠️ No supervisor assigned (not CEO)');
          diagnostics['orphanedEmployees'].add(empName);
        }
      } else {
        diagnostics['employeesWithSupervisor']++;

        // Check if supervisor email exists in system
        if (!validEmails.containsKey(supervisorEmail)) {
          empDetails['issues'].add('❌ Supervisor email NOT FOUND in system: $supervisorEmail');
          diagnostics['supervisorEmailNotFound'].add({
            'employee': empName,
            'invalidSupervisor': supervisorEmail,
          });
        } else {
          empDetails['supervisorExists'] = true;
          empDetails['issues'].add('✓ Valid supervisor reference');
        }

        // Check for self-reference
        if (supervisorEmail == empEmail) {
          empDetails['issues'].add('❌ CIRCULAR: Employee is their own supervisor!');
          diagnostics['circularReferences'].add(empName);
        }
      }

      diagnostics['employeeDetails'].add(empDetails);
    }

    // Print detailed report

    // Show CEOs
    if (diagnostics['ceoCount'] > 0) {
      for (var emp in diagnostics['employeeDetails']) {
        if (emp['issues'].toString().contains('Valid CEO')) {
        }
      }
    }

    // Show broken supervisor links
    if (diagnostics['supervisorEmailNotFound'].length > 0) {
      for (var issue in diagnostics['supervisorEmailNotFound']) {
      }
    }

    // Show orphaned employees (non-CEO without supervisor)
    if (diagnostics['orphanedEmployees'].length > 0) {
      for (var emp in diagnostics['employeeDetails']) {
        if (emp['issues'].toString().contains('No supervisor assigned')) {
        }
      }
    }

    // Show circular references
    if (diagnostics['circularReferences'].length > 0) {
      for (var name in diagnostics['circularReferences']) {
      }
    }

    // Detailed employee list
    for (var emp in diagnostics['employeeDetails']) {
      for (var issue in emp['issues']) {
      }
    }


    return diagnostics;
  }

}