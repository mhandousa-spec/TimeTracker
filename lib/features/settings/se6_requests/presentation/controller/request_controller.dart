/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_controller.dart
/// Purpose: Read-only request lookups still used by the login bootstrap.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N09/N14: the four write methods are
///          deleted. All four were unreachable and all four were broken:
///
///          * `createRequest` reported `RxStatus.success()` unconditionally, so
///            a failed write still looked like a success.
///          * `updateRequest` chained `.then(...)` with no `catchError`, so a
///            failure silently skipped the employee-profile update.
///          * `acceptAll` built a `WriteBatch`, never added anything to it,
///            awaited each `set()` individually in the loop, then committed the
///            empty batch — which always succeeds. The atomicity was decorative.
///          * `updateEmployeeProfile` had its entire body commented out, so a
///            request could be marked approved with nothing written to the
///            employee record.
///
///          The working replacements live in `RequestsRepository` /
///          `RequestsCubit`, which is what the pages now use.
///
/// REMAINING GetX (CR-SKEL-SE6-N04): the two read methods below are still
/// GetX-shaped because `login_controller.dart:954` calls `getAllRequests` during
/// the login bootstrap. Converting them means touching onboarding, which is
/// outside this feature's scope — the migration is staged, not finished.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/features/settings/se6_requests/data/models/request_model.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';

class RequestController extends GetxController with StateMixin {
  // FirebaseFirestore instance for interacting with Firestore.
  FirebaseFirestore db = FirebaseFirestore.instance;
  Rx<RequestsModel> requestsModel = RequestsModel().obs;
  List<RequestsModel> requestsList = [];
  Map<String, List<RequestsModel>> allRequestsPending = {};
  Map<String, List<RequestsModel>> allRequestReview = {};
  bool isLoading = false;
  //Map<String, List<RequestsModel>> userRequests = {};
  Future<List<RequestsModel>> getuserRequests(
      String userEmail, String section, bool isPending) async {
    // Update the controller state.

    final CollectionReference requestsCollection = db.collection(FirebaseCollections.requests);

    // Fetch all documents from the 'User_Requests' sub-collection for the specified user.
    QuerySnapshot querySnapshot = isPending
        ? await requestsCollection
            .doc('${userEmail}_$section')
            .collection(FirebaseCollections.userRequests)
            .where('Status', isEqualTo: 'pending')
            .get()
        : await requestsCollection
            .doc('${userEmail}_$section')
            .collection(FirebaseCollections.userRequests)
            .where('Status', isNotEqualTo: 'pending')
            .get();

    // Convert the documents into a list of RequestsModel objects.
    List<RequestsModel> requestsList = querySnapshot.docs
        .map((doc) => RequestsModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    // Update the controller state.
    update();

    // Set the controller status to success.
    change(requestsList, status: RxStatus.success());

    return requestsList;
  }

  EmployeeController addEmployeeController = Get.find();
  List<String> sections = [
    'personal_info',
    'additional_info',
    'health_insurance'
  ];
  Map<String, List<RequestsModel>> pendingRequests = {};
  Map<String, List<RequestsModel>> reviewRequests = {};
  Future<Map<String, List<RequestsModel>>> getAllRequests(
      bool isPending) async {
    //  userRequests = {};
    isPending ? pendingRequests = {} : reviewRequests = {};
    isLoading = true;
    // Was `allEmployees!` — the login bootstrap calls this before the employee
    // list has necessarily loaded, and the force-unwrap threw there.
    for (final employee in addEmployeeController.allEmployees ?? []) {
      for (int i = 0; i < sections.length; i++) {
        List<RequestsModel> requests = await getuserRequests(
            employee.email.last!, sections[i], isPending);
        if (requests.isNotEmpty) {
          isPending
              ? pendingRequests[
                  '${employee.email.last!}_${sections[i]}'] = requests
              : reviewRequests[
                  '${employee.email.last!}_${sections[i]}'] = requests;
        }
      }

      update();
    }
    isLoading = false;

    return isPending ? pendingRequests : reviewRequests;
  }
}
