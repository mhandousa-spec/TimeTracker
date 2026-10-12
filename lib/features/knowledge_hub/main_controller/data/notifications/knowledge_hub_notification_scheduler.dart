/// Module: knowledge_hub_module / notifications/knowledge_hub_notification_scheduler.dart
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_notification_scheduler.dart
/// Purpose:   The three Knowledge Hub notifications in §1.1 that no button can
///            raise, because nothing happens at the moment they are due:
///
///              • Document Expiring in 14 Days   (a date approaches)
///              • Document Archived              (a date passes)
///              • Review Reminder Issued         (nothing happens for 14 days)
///
/// Author: Knowticed Plus team
/// Created at: 1/9/2026
///
/// ─── WHY THIS EXISTS ─────────────────────────────────────────────────────
///
/// The other eight events in §1.1 are consequences of a user action, so they
/// are sent from the flow that performs it. These three are consequences of
/// TIME, and the app has no server-side scheduler: without something that
/// sweeps the collection, `document_expiring_in_14_days`,
/// `document_archived` and `review_reminder_issued` would exist as templates
/// in Notification Control and never be sent by anything — which is exactly
/// the state the module was in.
///
/// The sweep runs when the Knowledge Hub module is opened (see
/// `knowledge_hub_responsive_page.dart`). That is a client-side approximation
/// of a cron job, with the properties you would expect: a notification is
/// raised the first time SOMEBODY opens the module on or after its due date,
/// not at midnight on the dot. It is deliberately idempotent so that being
/// approximate never means being noisy.
///
/// ─── HOW IT AVOIDS SENDING TWICE ─────────────────────────────────────────
///
/// Every raised notification writes a marker document to
/// `Modules/knowledge_hub/Notification_Log`, keyed
/// `<knowledgeId>__<eventKey>__<dueMillis>`, and the sweep skips anything
/// already marked. This matters more than usual here: the sweep runs on every
/// module open, on every device, for every user — without the log, ten people
/// opening the module would send the same expiry warning ten times.
///
/// The due date is part of the key on purpose. Extending a document's End Date
/// produces a different key, so the owner is warned again about the NEW date —
/// while re-opening the module a hundred times against an unchanged date
/// produces the same key and stays silent.
///
/// ─── ARCHIVING ───────────────────────────────────────────────────────────
///
/// §1.1 says an expired document "will be automatically archived on
/// {EndDate}". Nothing in the app did that, so documents sat at `published`
/// forever and the Archive filter was permanently empty. The sweep appends
/// `archived` to the status array when it raises the archival notification.
/// That write is guarded by [archiveExpiredDocuments] so the notification can
/// be shipped without the status change if that is ever wanted.

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/notifications/knowledge_hub_notification_service.dart';

/// What one sweep did — returned rather than logged only, so a caller (or a
/// test) can assert on it.
class KnowledgeHubSweepReport {
  const KnowledgeHubSweepReport({
    this.scanned = 0,
    this.expiryWarnings = 0,
    this.archivals = 0,
    this.reviewReminders = 0,
    this.skipped = 0,
    this.failed = false,
  });

  final int scanned;
  final int expiryWarnings;
  final int archivals;
  final int reviewReminders;

  /// Due, but already marked in the log by an earlier sweep.
  final int skipped;

  /// The sweep could not complete (no network, permissions, timeout). Not an
  /// error the user sees — the next module open tries again.
  final bool failed;

  int get sent => expiryWarnings + archivals + reviewReminders;

  @override
  String toString() => 'KnowledgeHubSweepReport(scanned: $scanned, '
      'expiry: $expiryWarnings, archived: $archivals, '
      'reminders: $reviewReminders, skipped: $skipped, failed: $failed)';
}

class KnowledgeHubNotificationScheduler {
  KnowledgeHubNotificationScheduler._();

  /// §1.1: "Document Expiring in 14 Days".
  static const int expiryWarningDays = 14;

  /// How long a document may sit at `pending_approval` before the reminder in
  /// §1.1 ("Review Reminder Issued") is raised. The spec table gives no
  /// interval for Knowledge Hub; 14 days matches the overdue threshold the
  /// same document uses for Qiyas and To-Do.
  static const int reviewReminderAfterDays = 14;

  /// One sweep per app session is plenty — the module page is rebuilt on every
  /// tab change and we do not want a collection read each time.
  static bool _sweptThisSession = false;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run the sweep.
  ///
  /// [actingUserEmail] is stored as the notification's sender. These are
  /// system-raised, so it is only ever "who was in the app when the clock was
  /// checked" — never the cause.
  ///
  /// Set [force] to re-run inside the same session (pull-to-refresh, tests).
  static Future<KnowledgeHubSweepReport> sweep({
    required String actingUserEmail,
    required bool isArabic,
    bool archiveExpiredDocuments = true,
    bool force = false,
  }) async {
    if (_sweptThisSession && !force) {
      return const KnowledgeHubSweepReport();
    }
    _sweptThisSession = true;

    int scanned = 0;
    int expiryWarnings = 0;
    int archivals = 0;
    int reviewReminders = 0;
    int skipped = 0;

    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(getBaseUrl(FirebaseCollections.createKnowledge))
          .get()
          .timeout(const Duration(seconds: 20));

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        scanned++;
        try {
          final Map<String, dynamic> data = doc.data();

          final String knowledgeId = _firstString(data, 'knowledgeId', doc.id);
          final String nameEn = _lastString(data, 'nameEnglish', 'Document');
          final String nameAr = _lastString(data, 'nameArabic', nameEn);

          // The FIRST entry is the author. Later entries are whoever acted on
          // the document (approver, remover), which is why `.last` — used
          // elsewhere in the module — is wrong for "who owns this".
          final String ownerEmail = _firstString(data, 'createdByEmail', '');
          if (ownerEmail.isEmpty) continue;

          final String status =
              _lastString(data, 'status', '').toLowerCase().trim();

          // ── Review reminder ──────────────────────────────────────────────
          if (status == 'pending_approval' || status == 'pending') {
            final DateTime? submittedAt = _lastDate(data, 'timestamps');
            if (submittedAt != null &&
                today.difference(_dayOf(submittedAt)).inDays >=
                    reviewReminderAfterDays) {
              final bool fresh = await _claim(
                knowledgeId: knowledgeId,
                eventKey: 'review_reminder_issued',
                dueMillis: submittedAt.millisecondsSinceEpoch,
              );
              if (fresh) {
                // Addressed to the AUTHOR, which is what the spec's body
                // text is written for. The approver is not notified here
                // because nothing on the document records who the review was
                // assigned to — it is resolved live from the author's
                // supervisor at submission time — and guessing it from a
                // background sweep would chase the wrong person.
                final bool ok = await KnowledgeHubNotificationService
                    .remindOfPendingReview(
                  senderEmail: actingUserEmail,
                  receiverEmail: ownerEmail,
                  documentNameEn: nameEn,
                  documentNameAr: nameAr,
                  isArabic: isArabic,
                );
                if (ok) reviewReminders++;
              } else {
                skipped++;
              }
            }
            // A pending document has no publication window to police yet.
            continue;
          }

          // ── Expiry & archival ────────────────────────────────────────────
          final DateTime? endDate = _lastDate(data, 'endDateTime');
          if (endDate == null) continue;

          final DateTime endDay = _dayOf(endDate);
          final int daysUntilEnd = endDay.difference(today).inDays;

          final bool isLive = status == 'published' || status == 'approved';
          final bool alreadyClosed = status == 'archived' ||
              status == 'removed' ||
              status == 'rejected';

          if (daysUntilEnd > 0 &&
              daysUntilEnd <= expiryWarningDays &&
              isLive) {
            final bool fresh = await _claim(
              knowledgeId: knowledgeId,
              eventKey: 'document_expiring_in_14_days',
              dueMillis: endDay.millisecondsSinceEpoch,
            );
            if (fresh) {
              final bool ok = await KnowledgeHubNotificationService
                  .notifyOwnerOfUpcomingExpiry(
                senderEmail: actingUserEmail,
                ownerEmail: ownerEmail,
                documentNameEn: nameEn,
                documentNameAr: nameAr,
                endDateEn: _formatDate(endDate, arabic: false),
                endDateAr: _formatDate(endDate, arabic: true),
                isArabic: isArabic,
              );
              if (ok) expiryWarnings++;
            } else {
              skipped++;
            }
          } else if (daysUntilEnd <= 0 && !alreadyClosed) {
            final bool fresh = await _claim(
              knowledgeId: knowledgeId,
              eventKey: 'document_archived',
              dueMillis: endDay.millisecondsSinceEpoch,
            );
            if (fresh) {
              if (archiveExpiredDocuments) {
                await _appendStatus(doc.reference, data, 'archived');
              }
              final bool ok = await KnowledgeHubNotificationService
                  .notifyOwnerOfArchival(
                senderEmail: actingUserEmail,
                ownerEmail: ownerEmail,
                documentNameEn: nameEn,
                documentNameAr: nameAr,
                isArabic: isArabic,
              );
              if (ok) archivals++;
            } else {
              skipped++;
            }
          }
        } catch (e) {
          // One malformed document must not abort the sweep.
          log('[kh-sweep] skipped ${doc.id}: $e');
        }
      }

      final KnowledgeHubSweepReport report = KnowledgeHubSweepReport(
        scanned: scanned,
        expiryWarnings: expiryWarnings,
        archivals: archivals,
        reviewReminders: reviewReminders,
        skipped: skipped,
      );
      log('[kh-sweep] $report');
      return report;
    } catch (e, stackTrace) {
      // Allow a retry on the next module open rather than staying silent for
      // the rest of the session because the network blipped once.
      _sweptThisSession = false;
      log('[kh-sweep] FAILED — $e\n$stackTrace');
      return const KnowledgeHubSweepReport(failed: true);
    }
  }

  /// Visible for tests / a manual "run it again" affordance.
  static void resetSessionGuard() => _sweptThisSession = false;

  // ── Dedup log ────────────────────────────────────────────────────────────

  /// Reserve `<knowledgeId>__<eventKey>__<dueMillis>`.
  ///
  /// Returns true when THIS sweep created the marker (so the notification is
  /// ours to send), false when it already existed.
  ///
  /// A read-then-write is not atomic, so two devices sweeping in the same
  /// second could both claim. That is the honest limit of a client-side
  /// scheduler; the window is small and the failure mode is one duplicate
  /// notification, not a missed one. A Cloud Function doing this server-side
  /// is the real fix and would replace this whole file.
  static Future<bool> _claim({
    required String knowledgeId,
    required String eventKey,
    required int dueMillis,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> ref = _firestore
          .collection(getBaseUrl(FirebaseCollections.knowledgeNotificationLog))
          .doc('${knowledgeId}__${eventKey}__$dueMillis');

      final DocumentSnapshot<Map<String, dynamic>> existing = await ref.get();
      if (existing.exists) return false;

      await ref.set(<String, dynamic>{
        'knowledgeId': knowledgeId,
        'eventKey': eventKey,
        'dueMillis': dueMillis,
        'raisedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      // If the log is unreachable, do NOT send: a sweep that cannot remember
      // what it sent would re-send everything on every module open.
      log('[kh-sweep] claim failed for $knowledgeId/$eventKey: $e');
      return false;
    }
  }

  // ── Firestore shapes ─────────────────────────────────────────────────────

  /// Append to the parallel-array status history the module stores, rather
  /// than replacing it — every other writer in Knowledge Hub does the same,
  /// and the S7 details screen reads the history by index.
  static Future<void> _appendStatus(
    DocumentReference<Map<String, dynamic>> ref,
    Map<String, dynamic> data,
    String newStatus,
  ) async {
    try {
      final List<dynamic> statuses = List<dynamic>.from(data['status'] ?? []);
      final List<dynamic> timestamps =
          List<dynamic>.from(data['timestamps'] ?? []);
      final List<dynamic> timeStamp =
          List<dynamic>.from(data['timeStamp'] ?? []);

      statuses.add(newStatus);
      timestamps.add(DateTime.now().millisecondsSinceEpoch);
      timeStamp.add(DateTime.now().toIso8601String());

      await ref.update(<String, dynamic>{
        'status': statuses,
        'timestamps': timestamps,
        'timeStamp': timeStamp,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('[kh-sweep] could not archive ${ref.id}: $e');
    }
  }

  static String _firstString(
    Map<String, dynamic> data,
    String field,
    String fallback,
  ) {
    final dynamic value = data[field];
    if (value is List && value.isNotEmpty) {
      final String s = value.first?.toString().trim() ?? '';
      if (s.isNotEmpty) return s;
    } else if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  static String _lastString(
    Map<String, dynamic> data,
    String field,
    String fallback,
  ) {
    final dynamic value = data[field];
    if (value is List && value.isNotEmpty) {
      final String s = value.last?.toString().trim() ?? '';
      if (s.isNotEmpty) return s;
    } else if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }

  /// Dates in this collection are written inconsistently — `Timestamp` by the
  /// model's `toJson`, raw epoch millis by some older writers, and ISO strings
  /// by others. The calendar builder already handles the int case; all three
  /// are handled here so a document does not silently fall out of the sweep
  /// because of who wrote it.
  static DateTime? _lastDate(Map<String, dynamic> data, String field) {
    final dynamic value = data[field];
    final dynamic raw = value is List
        ? (value.isEmpty ? null : value.last)
        : value;
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    final String s = raw.toString();
    final int? millis = int.tryParse(s);
    if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
    return DateTime.tryParse(s);
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _formatDate(DateTime date, {required bool arabic}) {
    try {
      return DateFormat('dd/MM/yyyy', arabic ? 'ar' : 'en').format(date);
    } catch (_) {
      // The locale's date symbols may not be initialised on every entry point.
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
