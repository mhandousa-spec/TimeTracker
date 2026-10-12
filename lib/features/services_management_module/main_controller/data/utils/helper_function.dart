/// Module: services_management_module
/// Description: Core-safe CSV export helper + provider-selection/request-state
///              Firestore functions, kept independent of the services module's
///              EmployeeEntityModell so core can compile without the module.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: csv, path_provider, cloud_firestore, flutter/foundation.dart,
///               core/network/get_base_url.dart, core/network/api_constants.dart
/// Revision History: Initial version

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';

class CSVHelper {
  String createCsv(List<List<dynamic>> rows) {
    return Csv(autoDetect: false).encode(rows);
  }

  Future<File> saveCsvToFile(String csvData, String fileName) async {
    Directory? directory;

    if (Platform.isAndroid) {
      // ✅ Save to public Downloads folder
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    } else {
      // ✅ For iOS/macOS fallback
      directory = await getApplicationDocumentsDirectory();
    }

    final path = '${directory.path}/$fileName.csv';
    final file = File(path);

    List<int> csvBytes = utf8.encode(csvData);
    List<int> bom = [0xEF, 0xBB, 0xBF]; // Excel compatibility BOM

    return await file.writeAsBytes(bom + csvBytes);
  }

  Future<File> exportToCSV(List<List<dynamic>> rows, String fileName) async {
    final csv = createCsv(rows);
    return await saveCsvToFile(csv, fileName);
  }
}

Future<Map<String, dynamic>?> selectServiceProvider(
    String currentServiceDocId) async {
  final firestore = FirebaseFirestore.instance;

  final servicesSnapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.createServicesRoot))

      .get();
//CreateServices
  final Map<String, double> emailTotalDuration = {};
  final Map<String, int> emailFrequency = {};

  for (var serviceDoc in servicesSnapshot.docs) {
    final data = serviceDoc.data();
    final providerServices = data['providerServices'];
    final durationValueStr = data['durationOfServices']?['value']?.toString();
    final durationUnit =
    data['selectedDurationUnit']?['value']?.toString().toLowerCase();

    double durationValue = double.tryParse(durationValueStr ?? '0') ?? 0;
    double durationInMin = switch (durationUnit) {
      "minutes" => durationValue,
      "hours" => durationValue * 60,
      "days" => durationValue * 1440,
      "weeks" => durationValue * 10080,
      _ => durationValue
    };

    if (providerServices != null && providerServices['value'] is List) {
      List<dynamic> providers = providerServices['value'];
      for (var provider in providers) {
        final email = provider['email'];
        if (email != null) {
          emailTotalDuration[email] =
              (emailTotalDuration[email] ?? 0) + durationInMin;
          emailFrequency[email] = (emailFrequency[email] ?? 0) + 1;
        }
      }
    }
  }

  final currentServiceDoc = await firestore
      .collection(getBaseUrl(FirestoreCollections.createServicesRoot))
      .doc(currentServiceDocId)
      .get();

  final currentProviderServices = currentServiceDoc.data()?['providerServices'];
  if (currentProviderServices == null ||
      currentProviderServices['value'] == null ||
      currentProviderServices['value'] is! List) {
    return null;
  }

  List<dynamic> currentProviders = currentProviderServices['value'];

  if (currentProviders.length == 1) {
    return currentProviders[0];
  } else {
    currentProviders.sort((a, b) {
      final emailA = a['email'];
      final emailB = b['email'];

      final durationA = emailTotalDuration[emailA] ?? 0;
      final durationB = emailTotalDuration[emailB] ?? 0;

      if (durationA != durationB) {
        return durationA.compareTo(durationB);
      } else {
        final freqA = emailFrequency[emailA] ?? 0;
        final freqB = emailFrequency[emailB] ?? 0;
        return freqA.compareTo(freqB);
      }
    });

    return currentProviders.first;
  }
}

Future<Map<String, dynamic>?> selectServiceProviderRequest(
    String currentServiceDocId) async {
  final firestore = FirebaseFirestore.instance;

  final servicesSnapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))

      .get();
//RequestServices
  final Map<String, double> emailTotalDuration = {};
  final Map<String, int> emailFrequency = {};

  for (var serviceDoc in servicesSnapshot.docs) {
    final data = serviceDoc.data();
    final providerServices = data['providerServices'];
    final durationValueStr = data['durationOfServices']?['value']?.toString();
    final durationUnit =
    data['selectedDurationUnit']?['value']?.toString().toLowerCase();

    double durationValue = double.tryParse(durationValueStr ?? '0') ?? 0;
    double durationInMin = switch (durationUnit) {
      "minutes" => durationValue,
      "hours" => durationValue * 60,
      "days" => durationValue * 1440,
      "weeks" => durationValue * 10080,
      _ => durationValue
    };

    if (providerServices != null && providerServices['value'] is List) {
      List<dynamic> providers = providerServices['value'];
      for (var provider in providers) {
        final email = provider['email'];
        if (email != null) {
          emailTotalDuration[email] =
              (emailTotalDuration[email] ?? 0) + durationInMin;
          emailFrequency[email] = (emailFrequency[email] ?? 0) + 1;
        }
      }
    }
  }

  final currentServiceDoc = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))

      .doc(currentServiceDocId)
      .get();


  final currentProviderServices = currentServiceDoc.data()?['providerServices'];
  if (currentProviderServices == null ||
      currentProviderServices['value'] == null ||
      currentProviderServices['value'] is! List) {
    return null;
  }

  List<dynamic> currentProviders = currentProviderServices['value'];

  if (currentProviders.length == 1) {
    return currentProviders[0];
  } else {
    currentProviders.sort((a, b) {
      final emailA = a['email'];
      final emailB = b['email'];

      final durationA = emailTotalDuration[emailA] ?? 0;
      final durationB = emailTotalDuration[emailB] ?? 0;

      if (durationA != durationB) {
        return durationA.compareTo(durationB);
      } else {
        final freqA = emailFrequency[emailA] ?? 0;
        final freqB = emailFrequency[emailB] ?? 0;
        return freqA.compareTo(freqB);
      }
    });

    return currentProviders.first;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

// NOTE: updateGlobalStateIfFullyApproved moved to the services module
// (data/helper/csv_helper_state_updates.dart, part of data/helper/csv_helper.dart)
// because it depends on the module's EmployeeEntityModell. Keeping it out of
// core lets core compile even when the services module is deleted.

//////////////////////////////////////////////////////////////////////////////////

Future<void> updateRequestState(String docId, String newState) async {
  final firestore = FirebaseFirestore.instance;

  final docRef = firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .doc(docId);

  //RequestServices

  await docRef.update({
    "state": newState,
  });

  debugPrint("✅ RequestServices state updated to $newState");
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

    final docRef = firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId);
//RequestServices
    Map<String, dynamic> updateData = {
      "state": newState,
    };

    if (newState.toLowerCase() == "inprogress") {
      final DateTime startTime = DateTime.now();
      final dynamic rawValue = duration["value"];
      final double value = rawValue is String
          ? double.tryParse(rawValue) ?? 0
          : (rawValue as num).toDouble();
      final String unit =
      (duration["unit"] ?? "minutes").toString().toLowerCase();

      Duration calculatedDuration = switch (unit) {
        "hours" => Duration(minutes: (value * 60).toInt()),
        "days" => Duration(minutes: (value * 1440).toInt()),
        "weeks" => Duration(minutes: (value * 10080).toInt()),
        _ => Duration(minutes: value.toInt()),
      };

      final DateTime endTime = startTime.add(calculatedDuration);

      updateData.addAll({
        "startTime": startTime.toIso8601String(),
        "endTime": endTime.toIso8601String(),
        "duration": duration,
      });
    }

    await docRef.update(updateData);

    debugPrint("✅ Main RequestServices state updated to '$newState'");
  } catch (e) {
    debugPrint("❌ Error updating service state: $e");
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////// change from Arroved to Inprogress /////////////////////////////

// await changeStateToInProgress(widget.myRequestDetailsModel.id!);
// this is for call this function

Future<void> changeStateToInProgress(String docId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final docSnapshot = await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .get();
    final durationValueStr =
    docSnapshot.data()?['durationOfServices']?['value']?.toString();
    final durationUnit = docSnapshot
        .data()?['selectedDurationUnit']?['value']
        ?.toString()
        .toLowerCase();

    if (durationValueStr == null || durationUnit == null) {
      debugPrint("❌ Duration fields are missing");
      return;
    }

    final durationValue = double.tryParse(durationValueStr);
    if (durationValue == null) {
      debugPrint("❌ Invalid duration value");
      return;
    }

    Duration calculatedDuration;
    switch (durationUnit) {
      case "hours":
        calculatedDuration = Duration(minutes: (durationValue * 60).toInt());
        break;
      case "days":
        calculatedDuration = Duration(minutes: (durationValue * 1440).toInt());
        break;
      case "weeks":
        calculatedDuration = Duration(minutes: (durationValue * 10080).toInt());
        break;
      default:
        calculatedDuration = Duration(minutes: durationValue.toInt());
    }

    final now = DateTime.now();
    final endTime = now.add(calculatedDuration);

    await firestore
        .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
        .doc(docId)
        .update({
      "state": "inprogress",
      "startTime": now.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "duration": {
        "value": durationValue,
        "unit": durationUnit,
      },
    });

    debugPrint("✅ State updated to inprogress");
  } catch (e) {
    debugPrint("❌ Error: $e");
  }
}

////////////////////////// cancel button /////////////////////////////////

Future<void> cancelAllApprovalCycleStates({
  required String docId,
}) async {
  final firestore = FirebaseFirestore.instance;

  final docRef = firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .doc(docId);
  final snapshot = await docRef.get();

  if (!snapshot.exists) {
    debugPrint("❌ Document not found.");
    return;
  }

  final data = snapshot.data();
  if (data == null || data['approvalCycle'] == null) {
    debugPrint("❌ No approvalCycle found.");
    return;
  }

  final approvalData = data['approvalCycle'];
  if (approvalData is Map<String, dynamic> && approvalData['value'] is List) {
    List<dynamic> updatedList = (approvalData['value'] as List).map((e) {
      if (e is Map<String, dynamic>) {
        e['state'] = 'cancel';
      }
      return e;
    }).toList();

    await docRef.update({
      'approvalCycle.value': updatedList,
      'state': 'cancel', // Optional: sync state field too
    });

    debugPrint("✅ All approvalCycle states set to 'cancel'");
  } else {
    debugPrint("❌ Invalid approvalCycle structure.");
  }
}
//////////////////////////////////// get number of all services as flow Chart ////////////////////////////////////

Future<Map<String, int>> calculateServiceStates() async {
  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .get();

  int done = 0;
  int inProgress = 0;
  int approved = 0;
  int rejected = 0;
  int pending = 0;
  int cancel = 0;
  int branchSla = 0;

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final stateField = (data['state']?.toString().toLowerCase()) ?? '';

    String finalState = '';

    if ([
      'done',
      'inprogress',
      'cancel',
      'branchsla',
      'breached sla',
      'approved'
    ].contains(stateField)) {
      finalState = stateField;
    }

    if (finalState.isEmpty && data['approvalCycle'] is Map<String, dynamic>) {
      final approvalMap = data['approvalCycle'] as Map<String, dynamic>;
      final valueList = approvalMap['value'];

      if (valueList is List) {
        final states = valueList.map((item) {
          if (item is Map && item['state'] != null) {
            return item['state'].toString().toLowerCase();
          }
          return '';
        }).toList();

        if (states.contains('cancel')) {
          finalState = 'cancel';
        } else if (states.contains('rejected')) {
          finalState = 'rejected';
        } else if (states.every((s) => s == 'approved')) {
          finalState = 'approved';
        } else if (states.contains('pending')) {
          finalState = 'pending';
        }
      }
    }

    switch (finalState) {
      case 'done':
        done++;
        break;
      case 'inprogress':
        inProgress++;
        break;
      case 'approved':
        approved++;
        break;
      case 'rejected':
        rejected++;
        break;
      case 'pending':
        pending++;
        break;
      case 'cancel':
        cancel++;
        break;
      case 'branchsla':
      case 'breached sla':
        branchSla++;
        break;
    }
  }

  return {
    'done': done,
    'inprogress': inProgress,
    'approved': approved,
    'pending': pending,
    'rejected': rejected,
    'cancel': cancel,
    'branchsla': branchSla,
  };
}

////////////////////////////// function to calc number of services in every month /////////////////

Future<Map<String, int>> countServicesPerMonth(int year) async {
  final firestore = FirebaseFirestore.instance;
  final collection = firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot));

//RequestServices
  final querySnapshot = await collection.get();

  final Map<String, int> monthCount = {
    'January': 0,
    'February': 0,
    'March': 0,
    'April': 0,
    'May': 0,
    'June': 0,
    'July': 0,
    'August': 0,
    'September': 0,
    'October': 0,
    'November': 0,
    'December': 0,
  };

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final timestamp = data['serviceNameEnglish']?['timestamp'];

    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      if (date.year == year) {
        final monthIndex = date.month; // 1 = January, 12 = December
        final monthName = monthCount.keys.elementAt(monthIndex - 1);
        monthCount[monthName] = (monthCount[monthName] ?? 0) + 1;
      }
    }
  }

  return monthCount;
}
