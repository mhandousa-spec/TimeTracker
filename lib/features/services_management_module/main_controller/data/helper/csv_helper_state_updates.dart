// Module: services_management_module / data / helper (part of csv_helper.dart)
// Auto-split from csv_helper.dart — part of the same library.
part of 'csv_helper.dart';

Future<void> updateGlobalStateIfFullyApproved({
  required String docId,
  required String serviceName,
  required List<EmployeeEntityModell> approvalCycle,
}) async {
  final firestore = FirebaseFirestore.instance;

  final isAllApproved = approvalCycle.every(
        (e) => e.state?.toLowerCase() == 'approved',
  );

  final isRejected = approvalCycle.any(
        (e) => e.state?.toLowerCase() == 'rejected' || e.state?.toLowerCase() == 'cancel',
  );

  if (isRejected) {
    await updateRequestState(docId, 'rejected');
  } else if (isAllApproved) {
    // ✅ Stop at "approved", wait for manual start to become "inprogress"
    await updateRequestState(docId, 'approved');
    // print("✅ All approvers approved — state updated to 'approved'");
  }
}

//////////////////////////////////////////////////////////////////////////////////


EmployeeEntityPro get employeeEntityFunction {
  final controller = AppControllers.employee;
  if (controller.employeeEntity == null) {
    throw Exception('EmployeeEntity is not initialized yet');
  }
  return controller.employeeEntity!;
}


EmployeeEntityPro get employeeFunctionHelper {
  final controller = AppControllers.employee;
  if (controller.employeeEntity == null) {
    throw Exception('EmployeeEntity is not initialized yet');
  }
  return controller.employeeEntity!;
}


Future<void> updateRequestState(String docId, String newState) async {
  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .where("Email_Requester", arrayContains: employeeFunctionHelper.email)
      .get();

  final doc = querySnapshot.docs.firstWhere(
        (doc) => doc.id == docId,
    orElse: () => throw Exception("Document not found"),
  );

  await doc.reference.update({
    "state": [newState],
  });

  // print("✅ RequestServices state updated to $newState");
}

Future<void> updateApprovalState(String docId, String newState) async {
  final firestore = FirebaseFirestore.instance;

  // Query to find documents where emailRequester matches
  final querySnapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .where("Email_Requester", arrayContains: employeeFunctionHelper.email)
      .get();

  // Find and update the matching document by ID
  for (var doc in querySnapshot.docs) {
    if (doc.id == docId) {
      await doc.reference.update({
        "state": [newState],
      });
      if (kDebugMode) print("✅ RequestServices state updated to $newState");
      return;
    }
  }

  if (kDebugMode) print("❌ No matching document found");
}



/////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////




Future<void> updateServiceState({
  required String docId,
  required String serviceName,
  required String newState, // "inprogress" or "done"
  required Map<String, dynamic> duration, // { "value": 10, "unit": "hours" }
}) async {
  try {
    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("Email_Requester", arrayContains: employeeFunctionHelper.email)
        .get();

    final doc = querySnapshot.docs.firstWhere(
          (doc) => doc.id == docId,
      orElse: () => throw Exception("Document not found"),
    );

    Map<String, dynamic> updateData = {
      "state": [newState],
    };

    if (newState.toLowerCase() == "inprogress") {
      final DateTime startTime = DateTime.now();
      final dynamic rawValue = duration["value"];
      final double value = rawValue is String ? double.tryParse(rawValue) ?? 0 : (rawValue as num).toDouble();
      final String unit = (duration["unit"] ?? "minutes").toString().toLowerCase();

      Duration calculatedDuration = switch (unit) {
        "hours" => Duration(minutes: (value * 60).toInt()),
        "days" => Duration(minutes: (value * 1440).toInt()),
        "weeks" => Duration(minutes: (value * 10080).toInt()),
        _ => Duration(minutes: value.toInt()),
      };

      final DateTime endTime = startTime.add(calculatedDuration);

      updateData.addAll({
        "startTime": [startTime.toIso8601String()],
        "endTime": [endTime.toIso8601String()],
        "duration": [duration],
      });
    }

    await doc.reference.update(updateData);

    // print("✅ Main RequestServices state updated to '$newState'");
  } catch (e) {
    // print("❌ Error updating service state: $e");
  }
}






/////////////////////////////////////////////////////////////////////////////////////////////////////







/////////////////////////// change from Arroved to Inprogress /////////////////////////////

// await changeStateToInProgress(widget.myRequestDetailsModel.id!);
// this is for call this function

Future<void> changeStateToInProgress(String docId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final querySnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .where("Email_Requester", arrayContains: employeeFunctionHelper.email)
        .get();

    final docSnapshot = querySnapshot.docs.firstWhere(
          (doc) => doc.id == docId,
      orElse: () => throw Exception("Document not found"),
    );

    final data = docSnapshot.data();

    // Parse using ServicesHistoryModel
    final model = ServicesHistoryModel.fromJson(data, docId);

    final durationValueStr = model.currentDurationOfServices;
    final durationUnit = model.currentSelectedDurationUnit.toLowerCase();

    if (durationValueStr.isEmpty || durationUnit.isEmpty) {
      // print("❌ Duration fields are missing");
      return;
    }

    final durationValue = double.tryParse(durationValueStr);
    if (durationValue == null) {
      // print("❌ Invalid duration value");
      return;
    }

    Duration calculatedDuration;
    switch (durationUnit) {
      case "hours":
      case "hour":
      case "hr":
        calculatedDuration = Duration(minutes: (durationValue * 60).toInt());
        break;
      case "days":
      case "day":
        calculatedDuration = Duration(minutes: (durationValue * 1440).toInt());
        break;
      case "weeks":
      case "week":
        calculatedDuration = Duration(minutes: (durationValue * 10080).toInt());
        break;
      default:
        calculatedDuration = Duration(minutes: durationValue.toInt());
    }

    final now = DateTime.now();
    final endTime = now.add(calculatedDuration);

    await docSnapshot.reference.update({
      "state": ["inprogress"],
      "startTime": [now.toIso8601String()],
      "endTime": [endTime.toIso8601String()],
      "duration": [{
        "value": durationValue,
        "unit": durationUnit,
      }],
    });

    // print("✅ State updated to inprogress");

  } catch (e) {
    // print("❌ Error: $e");
  }
}

////////////////////////// cancel button /////////////////////////////////

////////////////////////// cancel button /////////////////////////////////

Future<void> cancelAllApprovalCycleStates({
  required String docId,
}) async {
  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .where("Email_Requester", arrayContains: employeeFunctionHelper.email)
      .get();

  final snapshot = querySnapshot.docs.firstWhere(
        (doc) => doc.id == docId,
    orElse: () => throw Exception("Document not found"),
  );

  final data = snapshot.data();

  // Parse using ServicesHistoryModel
  final model = ServicesHistoryModel.fromJson(data, docId);

  // Get current approval cycle and set all states to 'cancel'
  List<EmployeeEntityModell> updatedApprovalCycle = model.currentApprovalCycle.map((e) {
    return EmployeeEntityModell(
      email: e.email,
      firstName: e.firstName,
      lastName: e.lastName,
      firstNameInArabic: e.firstNameInArabic,
      lastNameInArabic: e.lastNameInArabic,
      middleName: e.middleName,
      middleNameInArabic: e.middleNameInArabic,
      title: e.title,
      titleInArabic: e.titleInArabic,
      gender: e.gender,
      photo: e.photo,
      departmentId: e.departmentId,
      workLocation: e.workLocation,
      role: e.role,
      status: e.status,
      supervisor: e.supervisor,
      mobilePhone: e.mobilePhone,
      id: e.id,
      officePhone: e.officePhone,
      homePhone: e.homePhone,
      extension: e.extension,
      nationality: e.nationality,
      language: e.language,
      skills: e.skills,
      bio: e.bio,
      hobbies: e.hobbies,
      academicHistory: e.academicHistory,
      maritalStatus: e.maritalStatus,
      birthDay: e.birthDay,
      nationalId: e.nationalId,
      passport: e.passport,
      drivingLicenseId: e.drivingLicenseId,
      imageUrl: e.imageUrl,
      country: e.country,
      state: 'cancel', // ✅ Set state to cancel
      city: e.city,
      province: e.province,
      street: e.street,
      postalCode: e.postalCode,
      carPlates: e.carPlates,
      activationDate: e.activationDate,
      deactivationDate: e.deactivationDate,
      firstLogin: e.firstLogin,
      lastLogin: e.lastLogin,
      nationalIdExpirationDate: e.nationalIdExpirationDate,
      passportExpirationDate: e.passportExpirationDate,
    );
  }).toList();

  // Convert to JSON string for storage
  final updatedApprovalCycleJson = jsonEncode(updatedApprovalCycle.map((e) => e.toJson()).toList());

  await snapshot.reference.update({
    'approvalCycle': [updatedApprovalCycleJson],
    'state': ['cancel'], // Optional: sync state field too
  });

  // print("✅ All approvalCycle states set to 'cancel'");
}

//////////////////////////////////// get number of all services as flow Chart ////////////////////////////////////


