/// Module: services_management_module
/// Description: `calculateServiceStates` / `countServicesPerMonth` — request
///              state aggregation for dashboard charts (part of csv_helper.dart).
/// Author: Amr Mesbah
/// Date: 30/8/2025
/// Dependencies: cloud_firestore, core/network/get_base_url.dart (via csv_helper.dart)
/// Revision History: Initial version — auto-split from csv_helper.dart to keep
///                    each physical file ≤800 LOC (audit fix #1).
// Auto-split from csv_helper.dart — part of the same library.
part of 'csv_helper.dart';

Future<Map<String, int>> calculateServiceStates({
  String? filterServiceName,
}) async {
  // print("🔍 calculateServiceStates - Starting...");
  // print("📌 Filter Service Name: '${filterServiceName ?? 'None'}'");

  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .where("Email_Requester", arrayContains: employeeFunctionHelper.email)
      .get();

  int done = 0;
  int inProgress = 0;
  int approved = 0;
  int rejected = 0;
  int pending = 0;
  int cancel = 0;
  int branchSla = 0;

  int totalProcessed = 0;
  int matchedCount = 0;

  for (var doc in snapshot.docs) {
    totalProcessed++;

    try {
      final service = ServicesHistoryModel.fromJson(doc.data(), doc.id);

      // ✅ Filter by service name if provided
      if (filterServiceName != null &&
          service.currentServiceNameEnglish != filterServiceName) {
        continue;
      }

      matchedCount++;

      final stateField = service.currentState.toLowerCase();
      String finalState = '';

      // ✅ Check direct states first (except 'active' and 'pending')
      if (['done', 'inprogress', 'cancel', 'branchsla', 'breached sla', 'approved', 'rejected']
          .contains(stateField)) {
        finalState = stateField;
      }

      // ✅ If state is 'active' or 'pending' OR not set, check approval cycle
      if (finalState.isEmpty || stateField == 'active' || stateField == 'pending') {
        final approvers = service.currentApprovalCycle;
        final states = approvers.map((e) => e.state?.toLowerCase() ?? '').toList();

        if (states.isEmpty) {
          // If no approval cycle, treat 'pending' as pending, 'active' as inprogress
          if (stateField == 'pending') {
            finalState = 'pending';
          } else if (stateField == 'active') {
            finalState = 'inprogress';
          }
        } else {
          // Check approval cycle states
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

      // print('📊 Doc ${doc.id}: state = "$finalState"');

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
    } catch (e) {
      // print("❌ Error calculating states for doc ${doc.id}: $e");
    }
  }

  final result = {
    'done': done,
    'inprogress': inProgress,
    'approved': approved,
    'pending': pending,
    'rejected': rejected,
    'cancel': cancel,
    'branchsla': branchSla,
  };

  // print('✅ calculateServiceStates complete:');
  // print('   - Total docs processed: $totalProcessed');
  // print('   - Matched service name: $matchedCount');
  // print('   - Status counts: $result');

  return result;
}







////////////////////////////// function to calc number of services in every month /////////////////


Future<Map<String, int>> countServicesPerMonth(int year) async {
  final firestore = FirebaseFirestore.instance;

  final querySnapshot = await firestore
      .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
      .where("Email_Requester", arrayContains: employeeFunctionHelper.email)
      .get();

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

    // Parse using ServicesHistoryModel
    final model = ServicesHistoryModel.fromJson(data, doc.id);
    final timestamp = model.currentDurationOfServicesTimestamp;

    final date = timestamp.toDate();
    if (date.year == year) {
      final monthIndex = date.month; // 1 = January, 12 = December
      final monthName = monthCount.keys.elementAt(monthIndex - 1);
      monthCount[monthName] = (monthCount[monthName] ?? 0) + 1;
    }
  }

  return monthCount;
}
