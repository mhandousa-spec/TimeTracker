// ignore_for_file: avoid_print

/// Module: roles / r4_active_directory / presentation / controller
///
///*************************** FILE INFO ****************************///
/// File Name: wrong_employee_cubit.dart
/// Purpose: Declares `AddWrongEmployeeController`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/network/api_constants.dart' hide FirebaseCollections;
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/invalid_import_row_model.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';

part './wrong_employee_state.dart';

/// Cubit for wrong-employee records.
///
/// Converted from AddWrongEmployeeController (GetxController + StateMixin) and
/// moved here from onboarding/o3_authentication, since every consumer of the
/// wrong-data flow lives in active_directory.
///
/// Dependency lookup still goes through GetX (`Get.put` in login_controller,
/// `Get.find` in ActiveDirectoryController) — only the state mechanism changed.
class AddWrongEmployeeController extends Cubit<WrongEmployeeState> {
  AddWrongEmployeeController() : super(WrongEmployeeInitial());

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
  void emitSafely(WrongEmployeeState state) {
    if (isClosed) return;
    emit(state);
  }

  FirebaseFirestore db = FirebaseFirestore.instance;

  /// Last record written (was an Rx field under GetX).
  WrongEmployeeModel wrongEmployeeModel = WrongEmployeeModel();

  List<WrongEmployeeModel>? allWrongEmployees;
  List<WrongEmployeeModel>? employeesWithoutFilter;

  Future<void> createWrongEmployee(
      WrongEmployeeModel wrongEmployeeModel, String email) async {
    emitSafely(WrongEmployeeLoading());

    final CollectionReference employeeCollection =
        db.collection(FirebaseCollections.wrongEmployeesProfile);

    await employeeCollection
        .doc(email)
        .set((wrongEmployeeModel).toMap(), SetOptions(merge: true));

    this.wrongEmployeeModel = wrongEmployeeModel;
    emitSafely(WrongEmployeeUpdated());
  }

  Future<List<WrongEmployeeModel>?> getAllEmployees() async {
    final CollectionReference employeeCollection =
        db.collection(ApiConstants.wrongEmployees);

    try {
      QuerySnapshot querySnapshot = await employeeCollection.get();

      allWrongEmployees = querySnapshot.docs
          .map((DocumentSnapshot document) => WrongEmployeeModel.fromMap(
              document.data() as Map<String, dynamic>))
          .toList();

      emitSafely(WrongEmployeeUpdated());
      return allWrongEmployees;
    } catch (e) {
      emitSafely(WrongEmployeeError(e.toString()));
      return [];
    }
  }
}
