/// Module: roles / r4_active_directory / presentation / controller
///
/// ***************************** FILE INFO ***************************** ///
/// File Name: main_core_department_cubit.dart
/// Purpose: Manages the department data within the application.
/// Author: Mohamed Fouad
/// Created At: Jan/10/2024
/// Description: Converted from MainCoreDepartmentController (GetxController).
///              The old onInit() auto-load now runs from the constructor, so
///              creating the cubit still kicks off the department fetch.
/// ********************************************************************* ///

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
// Full import: `Get.locale` is an extension member on GetInterface, so a
// `show Get` clause does not bring it into scope.

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/repository/department_repository.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part './main_core_department_state.dart';

class MainCoreDepartmentCubit extends Cubit<MainCoreDepartmentState> {
  /// Kicks off [getAllDepartments] immediately, mirroring the GetxController
  /// `onInit` behaviour the rest of the app relies on.
  MainCoreDepartmentCubit({bool autoLoad = true})
      : super(const MainCoreDepartmentInitial()) {
    if (autoLoad) {
      getAllDepartments();
    }
  }

  /// Function Name: [emitSafely]
  ///
  /// Purpose: Publish [state] only while this cubit is still open.
  ///
  /// Every load path here awaits Firestore before emitting; navigating away
  /// mid-fetch closed the cubit and the completion then threw
  /// "Cannot emit after close" (§16). Routing every emit through here makes the
  /// guard impossible to forget at a new call site.
  ///
  /// Parameters:
  /// - [state]: The state to publish.
  ///
  /// Returns: [void]
  void emitSafely(MainCoreDepartmentState state) {
    if (isClosed) return;
    emit(state);
  }

  DepartmentRepository departmentRepository = DepartmentRepository();
  FirebaseFirestore db = FirebaseFirestore.instance;

  List<DepartmentModelPro> departmentModels = [];

  Map<String, String> _departmentsArabicNameFromDepartmentId = {};
  Map<String, String> _departmentsEnglishNameFromDepartmentId = {};
  Map<String, String> _getDepartmentIdFromDepartmentName = {};
  List<String> _departmentsEnglishName = [];
  List<String> _departmentsArabicName = [];
  List<String> _departmentIds = [];

  List<String> get departmentsEnglishName => _departmentsEnglishName;
  List<String> get departmentsArabicName => _departmentsArabicName;
  List<String> get departmentIds => _departmentIds;

  /// Arabic label for the catch-all "Other" department bucket.
  static const String otherAr = 'أخرى';

  /// Dynamic English -> Arabic department-name map, built from the departments
  /// loaded via [getAllDepartments].
  Map<String, String> get enToAr {
    final Map<String, String> map = {};
    final int length =
        _departmentsEnglishName.length < _departmentsArabicName.length
            ? _departmentsEnglishName.length
            : _departmentsArabicName.length;
    for (int i = 0; i < length; i++) {
      map[_departmentsEnglishName[i]] = _departmentsArabicName[i];
    }
    return map;
  }

  /// Method Name: [getAllDepartments]
  ///
  /// Purpose: get all company departments
  Future<List<DepartmentModelPro>> getAllDepartments() async {
    emitSafely(const MainCoreDepartmentLoading());
    try {
      Either<Failure, dynamic> result =
          await departmentRepository.getDepartments();
      if (result.isRight()) departmentModels = result.getOrElse(() => []);
      _getDepartmentMapsFromDepartmentsList(departmentModels);
      _setDepartmentNamesLists(departmentModels);
      _publish();
      return departmentModels;
    } catch (e) {
      emitSafely(MainCoreDepartmentError(e.toString()));
      return departmentModels;
    }
  }

  void _publish() {
    emitSafely(MainCoreDepartmentLoaded(
      departments: List.unmodifiable(departmentModels),
      englishNames: List.unmodifiable(_departmentsEnglishName),
      arabicNames: List.unmodifiable(_departmentsArabicName),
      departmentIds: List.unmodifiable(_departmentIds),
    ));
  }

  /// Fetches the department name based on the department ID.
  ///
  /// [isEnglish] used to be nullable, with `null` falling back to `Get.locale`.
  /// A cubit has no BuildContext and GetX is banned, so the caller — which does
  /// have a context — decides. `null` now means English, matching the previous
  /// behaviour for every existing call site (all pass an explicit value).
  String getDepartmentName(String departmentId, bool? isEnglish) {
    final bool useEnglish = isEnglish ?? true;
    // `?? ''` not `!` (7/10/2026): an employee with an empty / unknown
    // department id (e.g. a freshly activated company admin) crashed every
    // screen that shows a department — first seen on the Notifications inbox.
    return (useEnglish
            ? getEnglishDepartmentNameFromDepartmentId(
                departmentId: departmentId)
            : getArabicDepartmentNameFromDepartmentId(
                departmentId: departmentId)) ??
        '';
  }

  /// Fetches the department ID based on the department name or its Arabic
  /// counterpart. Returns the department ID if found, otherwise "none".
  String getDepartmentId(String departmentName) {
    List<DepartmentModelPro> departmentModel = departmentModels
        .where((element) =>
            element.departmentName == departmentName ||
            element.departmentNameInArabic == departmentName)
        .toList();

    if (departmentModel.isEmpty) {
      return "none";
    } else {
      return departmentModel.first.departmentID!;
    }
  }

  /// Returns the abbreviation capitalised.
  String containAbbreviation(String abbreviation) {
    return FormatHelper.capitalize(abbreviation);
  }

  void _getDepartmentMapsFromDepartmentsList(
      List<DepartmentModelPro> departments) {
    _departmentsArabicNameFromDepartmentId = {};
    _departmentsEnglishNameFromDepartmentId = {};
    _getDepartmentIdFromDepartmentName = {};
    for (DepartmentModelPro department in departments) {
      _departmentsArabicNameFromDepartmentId[department.departmentID!] =
          department.departmentNameInArabic!;
      _departmentsEnglishNameFromDepartmentId[department.departmentID!] =
          containAbbreviation(department.departmentName!);
      _getDepartmentIdFromDepartmentName[
          department.departmentName!.toLowerCase()] = department.departmentID!;
      _getDepartmentIdFromDepartmentName[department.departmentNameInArabic!] =
          department.departmentID!;
    }
  }

  void _setDepartmentNamesLists(List<DepartmentModelPro> departments) {
    _departmentsArabicName = [];
    _departmentsEnglishName = [];
    _departmentIds = [];
    for (DepartmentModelPro department in departments) {
      _departmentIds.add(department.departmentID!);
      _departmentsArabicName.add(department.departmentNameInArabic!);
      _departmentsEnglishName
          .add(containAbbreviation(department.departmentName!));
    }
  }

  /// Department id for a department NAME, in either language.
  ///
  /// ✅ FIX 31/8/2026 (bug report p13, "why it doesn't accept the
  /// capitalization?"): this lookup was case-SENSITIVE while the map it reads
  /// is not built that way. `_getDepartmentMapsFromDepartmentsList` stores the
  /// English key as `departmentName.toLowerCase()`, so a caller passing
  /// "Information Technology" — the department's real, capitalised name, and
  /// what a user naturally types in the bulk-upload sheet — matched nothing and
  /// got null back. The bulk-upload validator reports that null as "department
  /// does not exist", so a correctly spelled sheet was flagged row by row and
  /// could not be uploaded at all; only an all-lowercase "information
  /// technology" was accepted.
  ///
  /// The exact key is tried first, then the lower-cased one:
  ///   * the exact match keeps the ARABIC entries working — those are stored
  ///     verbatim rather than lower-cased (Arabic has no case, so lowering is
  ///     a no-op there either way);
  ///   * the fallback is what accepts any capitalisation of an English name.
  ///
  /// Trimmed as well: a name arriving from a spreadsheet cell routinely carries
  /// a trailing space.
  ///
  /// Note that [getDepartmentArabicNameFromEnglishName] below already
  /// lower-cases at its own call site — evidence this normalisation belonged
  /// in here all along, where every caller gets it, rather than in each caller
  /// that happens to remember.
  String? getDepartmentIdFromDepartmentName({required String departmentName}) {
    final String key = departmentName.trim();
    if (key.isEmpty) return null;

    return _getDepartmentIdFromDepartmentName[key] ??
        _getDepartmentIdFromDepartmentName[key.toLowerCase()];
  }

  String? getEnglishDepartmentNameFromDepartmentId(
      {required String departmentId}) {
    return _departmentsEnglishNameFromDepartmentId[departmentId];
  }

  String? getArabicDepartmentNameFromDepartmentId(
      {required String departmentId}) {
    return _departmentsArabicNameFromDepartmentId[departmentId];
  }

  dynamic getDepartmentEnglishNameFromArabicName(
      {required String arabicName}) {
    String departmentId =
        getDepartmentIdFromDepartmentName(departmentName: arabicName)!;
    return getEnglishDepartmentNameFromDepartmentId(departmentId: departmentId);
  }

  dynamic getDepartmentArabicNameFromEnglishName(
      {required String englishName}) {
    String departmentId = getDepartmentIdFromDepartmentName(
        departmentName: englishName.toLowerCase())!;
    return getArabicDepartmentNameFromDepartmentId(departmentId: departmentId);
  }
}
