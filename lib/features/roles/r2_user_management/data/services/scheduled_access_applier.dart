/// Module: roles / r2_user_management / data / services
///
///*************************** FILE INFO ****************************///
/// File Name: scheduled_access_applier.dart
/// Purpose: Detects pre-dated access changes whose start date has arrived and
///          raises the two "Scheduled Access Applied" notifications for them.
/// Author: Knowticed Plus team
/// Created at: 26/8/2026
///
/// ─── WHY IT EXISTS ───────────────────────────────────────────────────
/// Spec §1.5 defines eight notifications. Seven of them fire from
/// `UserManagementAccessRepository`. The eighth is a PAIR —
/// `scheduledAccessAppliedUser` and `scheduledAccessAppliedAdmin`, both sent
/// by one call to
/// `UserManagementNotificationService.sendScheduledAccessAppliedNotification`
/// — and it was the only §1.5 row with no trigger, because its trigger is
/// "the job that executes pre-dated access changes" and no such job existed.
/// That is why the module sat at 6 of 8 rather than 7 of 8: one uncalled
/// method costs two spec rows.
///
/// ─── WHY THIS IS A DETECTOR AND NOT A MUTATOR ────────────────────────
/// "Executes the change" is misleading about how this app stores permissions.
/// `updateUserPermission` writes the role to `Employees_Info.Role` and the
/// window to `User_Management.From_Date` in the SAME transaction — the role is
/// already on the account the moment an admin saves it. `From_Date` is not a
/// deferred write waiting to be flushed; it is the date from which
/// `getUserAccessStatus` stops reporting `scheduled` and starts reporting
/// `active`.
///
/// So there is nothing to apply. What there is, is a moment that passes
/// unobserved: the clock crosses `From_Date` and the user's access silently
/// becomes live. This service is what observes it. Writing a mutator instead
/// would mean re-applying a role the document already holds, which is a no-op
/// dressed up as a job.
///
/// ─── RUNNING ONCE ────────────────────────────────────────────────────
/// Announcing the same date twice is worse than not announcing it, so every
/// send is sealed by writing the announced date back to the permission
/// document as [_appliedForField]. The seal is the DATE STRING, not a boolean:
/// if an admin later re-schedules the same user to a new future date, the seal
/// no longer matches and that new date earns its own announcement.
///
/// The write is a merge (`RoleRemoteDataSource.updateRoleWithinTransaction`
/// and every other writer to this collection use `SetOptions(merge: true)`),
/// so the field survives later permission saves and costs nothing to carry.
///
/// ─── NOT ANNOUNCING HISTORY ──────────────────────────────────────────
/// The seal did not exist before today, so on the first run every pre-dated
/// change ever made looks unannounced. Sending all of them would put years of
/// "your access change has been applied" in every inbox at once. Anything
/// older than [_announceWindowDays] is therefore sealed SILENTLY — recorded as
/// handled, never sent. Only changes that landed inside the window are real
/// news.
///
/// ─── WHERE IT RUNS ───────────────────────────────────────────────────
/// [applyDue] is called from `UserManagementAccessRepository
/// .getUsersPermissionsData()`, i.e. whenever the User Management screen
/// loads. That is the right place for a client-side detector: it is the one
/// moment an administrator is present, it scans every user rather than only
/// the signed-in one, and the collection read it needs is small.
///
/// ⚠️ The consequence, stated plainly: an affected user hears about their own
/// applied change only once SOMEBODY opens User Management. In a tenant with
/// active administrators that is daily; in one without, it may not happen. The
/// fix is a scheduled backend job, and this class is shaped for it — it takes
/// both its Firestore handle and its clock as parameters and holds no widget,
/// cubit or locator reference, so only [applyDue]'s caller would change.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/features/notification/data/repository/user_management_notification_service.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/entities/new_permission_entity.dart';

/// One user's pending announcement, resolved from their permission document.
class _DueChange {
  const _DueChange({
    required this.employeeId,
    required this.fromDate,
    required this.isWithinWindow,
  });

  final String employeeId;

  /// The stored `From_Date` string, verbatim — this is what gets sealed, so it
  /// must be the exact value that was read, not a reformatted copy.
  final String fromDate;

  /// False when the date passed longer ago than [_announceWindowDays]. Such a
  /// change is sealed without a notification.
  final bool isWithinWindow;
}

class ScheduledAccessApplier {
  ScheduledAccessApplier({
    FirebaseFirestore? firestore,
    DateTime Function()? now,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;

  /// Injected so a test can move the clock without waiting for one.
  final DateTime Function() _now;

  /// The permission document field that records which `From_Date` has already
  /// been announced. Added 26/8/2026; absent on every document written before
  /// then, which [_dueChangeFor] treats as "nothing announced yet".
  static const String _appliedForField = 'Scheduled_Applied_For';

  /// How far back a start date may be and still be worth announcing.
  ///
  /// Thirty days is long enough that a user who was away for a few weeks still
  /// hears about the change waiting for them, and short enough that the first
  /// run after this service ships does not resurrect old history.
  static const int _announceWindowDays = 30;

  /// The email put on the notification as sender. No human triggered this —
  /// the clock did — which is exactly the case
  /// `UserManagementNotificationService._systemSender` exists for, so the
  /// parameter is left at its default and this constant is only used for the
  /// audit trail in [_seal].
  static const String _systemActor = 'system@company.com';

  /// Function Name: [applyDue]
  ///
  /// Purpose: Announce every pre-dated access change whose start date has now
  /// arrived, and seal it so it is never announced again.
  ///
  /// Returns: [Future<int>] how many notifications actually went out. Sealed-
  /// but-silent documents are not counted, so a return of 0 on the first run
  /// means "nothing recent was waiting", not "nothing happened".
  ///
  /// Never throws. This runs off the back of a screen load; a detector that
  /// cannot read the collection must not take the User Management screen down
  /// with it.
  Future<int> applyDue() async {
    int sent = 0;

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(getBaseUrl('User_Management'))
          .get()
          .timeout(const Duration(seconds: 20));

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final _DueChange? due = _dueChangeFor(doc);
        if (due == null) continue;

        if (due.isWithinWindow) {
          final bool announced = await _announce(due);
          if (announced) sent++;
        }

        // Sealed either way: an announcement that went out must not repeat,
        // and one deliberately skipped as history must not come back.
        await _seal(due);
      }
    } catch (e, stackTrace) {
      // Deliberately swallowed, and deliberately logged. Consistent with every
      // other background pass in this feature.
      debugPrint('ScheduledAccessApplier: pass failed — $e\n$stackTrace');
    }

    return sent;
  }

  // ═══════════════════════════════════════════════════════════
  // Detection
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [_dueChangeFor]
  ///
  /// Purpose: Decide whether one permission document has an announcement owing.
  ///
  /// Returns: [_DueChange?] — null when there is nothing to announce, for any
  /// of the reasons spelled out inline. Each `return null` below is a rule from
  /// §1.5, not a defensive guard, so they are kept separate rather than folded
  /// into one condition.
  _DueChange? _dueChangeFor(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic>? raw = doc.data();
    if (raw == null) return null;

    final UserPermissionHistoryModel model =
        UserPermissionHistoryModel.fromMap(raw);

    // A revoked or never-granted role has no access to start.
    final String role = model.currentRole;
    if (role.isEmpty || role == Constants.removedEmployeePermission) return null;

    final String fromDate = model.currentFromDate;
    if (fromDate.trim().isEmpty) return null;

    // Already announced for exactly this date.
    final Object? sealed = raw[_appliedForField];
    if (sealed is String && sealed == fromDate) return null;

    final DateTime? start = _parseAccessDate(fromDate);
    if (start == null) return null;

    final DateTime now = _now();

    // Still in the future: this is a scheduled change, and
    // `sendAccessChangeScheduledNotification` has already announced it as such.
    if (start.isAfter(now)) return null;

    // ── Was it ever actually scheduled? ──────────────────────────────
    // A start date in the past is not by itself news: most access is granted
    // with a start date of today, which is "past" by the time anyone looks.
    // The row's own timestamp says when it was written, so a change counts as
    // pre-dated only when its start date was in the future AT THE MOMENT IT
    // WAS SAVED. This is the one piece of evidence that separates a genuine
    // scheduled change from an ordinary grant, and it needs no new field —
    // `Timestamps` has been written alongside `From_Date` since the model was
    // created.
    final int index = model.fromDate.length - 1;
    final int? savedAtMs = model.getTimestampAt(index);
    if (savedAtMs == null) return null;

    final DateTime savedAt = DateTime.fromMillisecondsSinceEpoch(savedAtMs);
    if (!start.isAfter(savedAt)) return null;

    final int daysSinceStart = now.difference(start).inDays;

    return _DueChange(
      employeeId: doc.id,
      fromDate: fromDate,
      isWithinWindow: daysSinceStart <= _announceWindowDays,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Announcing and sealing
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [_announce]
  ///
  /// Purpose: Send the §1.5 pair for one due change.
  ///
  /// The user is addressed by email and the admin fan-out prints their name, so
  /// both come from `Employees_Info`; a document with no readable email cannot
  /// be announced to anyone and is reported as not sent (but still sealed by
  /// the caller, because it will never become announceable).
  ///
  /// Returns: [Future<bool>] whether the notification pair went out.
  Future<bool> _announce(_DueChange due) async {
    final Map<String, String>? identity = await _identityFor(due.employeeId);
    if (identity == null) return false;

    await UserManagementNotificationService
        .sendScheduledAccessAppliedNotification(
      userEmail: identity['email']!,
      userName: identity['name']!,
    );
    return true;
  }

  /// Function Name: [_seal]
  ///
  /// Purpose: Record that [due]'s start date has been dealt with.
  ///
  /// A merge write of two fields: the date itself, which is what [_dueChangeFor]
  /// compares against, and the moment it was sealed, which is only there so the
  /// document can be read by a human wondering why no notification arrived.
  Future<void> _seal(_DueChange due) async {
    try {
      await _firestore
          .collection(getBaseUrl('User_Management'))
          .doc(due.employeeId)
          .set(
        <String, dynamic>{
          _appliedForField: due.fromDate,
          'Scheduled_Applied_At': _now().millisecondsSinceEpoch,
          'Scheduled_Applied_By': _systemActor,
        },
        SetOptions(merge: true),
      );
    } catch (e, stackTrace) {
      // A failed seal means this change is announced again on the next pass.
      // That is the safe direction to fail in — a duplicate notice beats a
      // silent one — but it is worth seeing in the log.
      debugPrint('ScheduledAccessApplier: could not seal ${due.employeeId} '
          '— $e\n$stackTrace');
    }
  }

  /// Function Name: [_identityFor]
  ///
  /// Purpose: The email and display name for a permission document's owner.
  ///
  /// `User_Management` is keyed by employee id and carries neither, so the
  /// directory record is read. Both `Email` and the name fields are history
  /// lists whose CURRENT value is the last entry — the same convention
  /// `AccountStatusNotificationService._masterAdminEmails` follows.
  ///
  /// Returns: [Future<Map<String, String>?>] with `email` and `name`, or null
  /// when the employee has no readable address.
  Future<Map<String, String>?> _identityFor(String employeeId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(getBaseUrl('Employees_Info'))
          .doc(employeeId)
          .get()
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic>? data = doc.data();
      if (data == null) return null;

      final String email = _currentOf(data['Email']);
      if (email.isEmpty) return null;

      final String first = _currentOf(data['First_Name']);
      final String last = _currentOf(data['Last_Name']);
      final String name = '$first $last'.trim();

      return <String, String>{
        'email': email,
        // Falls back to the address rather than leaving the admin notice
        // reading "The scheduled access modification for  has been executed".
        'name': name.isEmpty ? email : name,
      };
    } catch (e, stackTrace) {
      debugPrint('ScheduledAccessApplier: identity for $employeeId failed '
          '— $e\n$stackTrace');
      return null;
    }
  }

  /// The last entry of an `Employees_Info` history list, as a plain string.
  static String _currentOf(dynamic value) {
    if (value == null) return '';
    if (value is List) {
      return value.isEmpty ? '' : (value.last?.toString().trim() ?? '');
    }
    return value.toString().trim();
  }

  /// Function Name: [_parseAccessDate]
  ///
  /// Purpose: Read a stored access date.
  ///
  /// `Constants.userAccessDateFormat` ("MMM dd, yyyy") is what the User
  /// Management screens write, but this collection also holds ISO rows from
  /// earlier imports and `dd/MM/yyyy` rows typed by hand, so all three are
  /// accepted. Deliberately narrower than
  /// `UserManagementAccessRepository.parseAccessDate`, which also handles
  /// Arabic month names: a date that only that parser can read still parses
  /// there, and the cost of missing it here is one un-announced change rather
  /// than a wrong one.
  ///
  /// Returns: [DateTime?] null when no known format matches.
  static DateTime? _parseAccessDate(String raw) {
    final String text = raw.trim();
    if (text.isEmpty || text == 'null' || text == '-' || text == '[]') {
      return null;
    }

    for (final String pattern in const <String>[
      'MMM dd, yyyy',
      'MMM d, yyyy',
      'MMMM dd, yyyy',
      'yyyy-MM-dd',
    ]) {
      try {
        return DateFormat(pattern, 'en').parseStrict(text);
      } catch (_) {
        // Next pattern.
      }
    }

    if (text.contains('/')) {
      final List<String> parts = text.split('/');
      if (parts.length == 3) {
        final int? day = int.tryParse(parts[0]);
        final int? month = int.tryParse(parts[1]);
        final int? year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    }

    return DateTime.tryParse(text);
  }
}
