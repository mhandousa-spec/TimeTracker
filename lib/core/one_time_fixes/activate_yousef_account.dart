import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

/// ONE-TIME FIX (28/9/2026) — activates yousef_jamal_2508@bayanatz.com.
///
/// The login looks the account up by DOCUMENT ID in `Demo_Users_Accounts`
/// (see DemoLoginRepository._checkIfAccountExists). The account was added by
/// editing the `Email` field of the `faisal_mohammed_3012@knowticedplus.com`
/// document, so no document with Yousef's email as its ID existed and the
/// login answered "Email Not Found".
///
/// This function:
///  1. creates `Demo_Users_Accounts/yousef_jamal_2508@bayanatz.com`,
///     already activated (`Is_Activated: true`);
///  2. puts Faisal's own email back on the Faisal document, so Faisal's login
///     does not resolve to Yousef's employee record;
///  3. on the employee in `Demo/75440689/Employees_Info` whose `Email` array
///     contains Yousef's email: sets `Password` to 12345@Employee and makes
///     the last `Status` entry `active`, which is what the active-login path
///     checks.
///
/// Runs once per device: a GetStorage flag is written only after every step
/// succeeds, so a failed run is retried on the next launch. Every step is also
/// safe to repeat. Delete this file and its call in main.dart once the account
/// logs in.
Future<void> activateYousefAccountOnce() async {
  const String doneKey = 'one_time_fix_activate_yousef_account_v1';
  const String email = 'yousef_jamal_2508@bayanatz.com';
  const String oldDocId = 'faisal_mohammed_3012@knowticedplus.com';
  const String companyId = '75440689';
  const String password = '12345@Employee';

  final GetStorage storage = GetStorage();
  if (storage.read(doneKey) == true) return;

  try {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final CollectionReference<Map<String, dynamic>> accounts =
        db.collection('Demo_Users_Accounts');

    // ── 1 + 2. Demo_Users_Accounts ─────────────────────────────────────────
    final DocumentSnapshot<Map<String, dynamic>> oldDoc =
        await accounts.doc(oldDocId).get();
    final Map<String, dynamic> oldData = oldDoc.data() ?? <String, dynamic>{};

    await accounts.doc(email).set(<String, dynamic>{
      'Company_Id': oldData['Company_Id'] ?? companyId,
      'Email': email,
      'Is_Activated': true,
      'Demo_Activated': Timestamp.now(),
      'Demo_Granted': oldData['Demo_Granted'],
    }, SetOptions(merge: true));

    if (oldDoc.exists &&
        (oldData['Email'] as String?)?.toLowerCase() == email) {
      await accounts.doc(oldDocId).update(<String, dynamic>{'Email': oldDocId});
    }

    // ── 3. Employees_Info ─────────────────────────────────────────────────
    final QuerySnapshot<Map<String, dynamic>> employees = await db
        .collection('Demo/$companyId/Employees_Info')
        .where('Email', arrayContains: email)
        .get();

    if (employees.docs.isEmpty) {
      debugPrint('[one-time fix] No employee in Demo/$companyId/Employees_Info '
          'has "$email" in its Email list — add it there, the fix will retry '
          'on next launch.');
      return; // flag not written -> retried next launch
    }

    final DocumentSnapshot<Map<String, dynamic>> employee = employees.docs.first;
    final List<dynamic> status =
        List<dynamic>.from(employee.data()?['Status'] as List? ?? <dynamic>[]);
    final String nowLabel =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final Map<String, dynamic> update = <String, dynamic>{
      'Password': password,
      'First_Login': employee.data()?['First_Login'] ?? nowLabel,
      'Activation_Date': employee.data()?['Activation_Date'] ?? nowLabel,
    };
    if (status.isEmpty || status.last.toString().trim().toLowerCase() != 'active') {
      update['Status'] = <dynamic>[...status, 'active'];
    }
    await employee.reference.update(update);

    await storage.write(doneKey, true);
    debugPrint('[one-time fix] $email is active (employee ${employee.id}).');
  } catch (e, s) {
    debugPrint('[one-time fix] activateYousefAccountOnce failed: $e\n$s');
  }
}
