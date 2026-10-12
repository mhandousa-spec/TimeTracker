/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: feedback_remote_data_source.dart
/// Purpose: The Firestore reads and writes behind the comments-and-feedback
///          screen.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
/// Updated: 2/9/2026 - `submit` also writes the `details` object behind the
///          "More Options" panel (module, screen, design/logic issue, device,
///          software, frequency, steps to reproduce).
/// Updated: 1/9/2026 - `submit` now writes a LIST of attachments and the
///          submitter's priority, and [listForEmployee] gives the "Request
///          Details" list whole documents instead of the three integers
///          [countsByStatus] returns.
///
/// Added while fixing the dead submit button — there was no data layer for
/// this feature at all, in any module. The screen collected three text bodies
/// and then dropped them on the floor.

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/features/messaging/m5_support/data/support_chat_repository.dart';

import 'package:knowticed_plus/features/settings/se7_app_info/data/utils/feedback_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';

class FeedbackRemoteDataSource {
  FeedbackRemoteDataSource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _feedback => _db
      .doc(FeedbackCollectionPaths.settingsDoc)
      .collection(FeedbackCollectionPaths.feedbackCollection);

  /// Function Name: [submit]
  ///
  /// Purpose: Write one document per filled-in box, so a bug report and a
  ///          feature request submitted together stay separately triageable.
  ///
  /// All of them go in a single batch: either every body lands or none does,
  /// which keeps the success dialog honest.
  Future<void> submit(AppFeedback feedback) async {
    final Map<FeedbackKind, String> bodies = feedback.bodies;
    if (bodies.isEmpty) return;

    final WriteBatch batch = _db.batch();
    final Map<FeedbackKind, List<FeedbackAttachment>> attachments =
        feedback.attachmentsByKind;
    final Map<FeedbackKind, FeedbackPriority> priorities =
        feedback.prioritiesByKind;
    final Map<FeedbackKind, FeedbackDetails> details = feedback.detailsByKind;

    bodies.forEach((FeedbackKind kind, String body) {
      final List<FeedbackAttachment> files =
          attachments[kind] ?? const <FeedbackAttachment>[];
      final FeedbackDetails? panel = details[kind];

      batch.set(_feedback.doc(), <String, dynamic>{
        'type': kind.wireValue,
        'body': body,
        'employeeId': feedback.employeeId,
        'employeeName': feedback.employeeName,
        'employeeEmail': feedback.employeeEmail,
        // Was the bare literal `'new'`. Identical on the wire — see
        // [FeedbackStatus.newWireValue] — but named, so the field this writes
        // and the field [countsByStatus] reads cannot drift apart.
        'status': FeedbackStatus.newWireValue,
        // ADDED 1/9/2026. Null when the user left the dropdown on "Select
        // Priority", so a triager can test the field rather than guess whether
        // 'low' was chosen or defaulted.
        'priority': priorities[kind]?.wireValue,
        'createdAt': FieldValue.serverTimestamp(),
        // ADDED 24/8/2026, widened to a list 1/9/2026. Empty when that box had
        // no files.
        'attachments': files
            .map((FeedbackAttachment file) => file.toMap())
            .toList(growable: false),
        // Kept alongside the list for anything still reading the singular
        // field — the admin dashboard among them. It carries the FIRST file;
        // a reader that only knows this shape could never have shown more than
        // one anyway.
        'attachment': files.isEmpty ? null : files.first.toMap(),
        // ADDED 2/9/2026 — the "More Options" panel. Null, not an object of
        // nulls, when the user never opened it: `detailsByKind` has already
        // dropped the boxes whose panel came back empty, so the presence of
        // this field means the submitter actually answered something.
        'details': panel?.toMap(),
      });
    });

    // ADDED 23/9/2026 — the submission also opens / continues the user's
    // conversation with Knowticed Support (Messages), where the admin team
    // replies. The submission itself is not copied: both apps show it from
    // App_Feedback.
    SupportChatRepository.touchOnFeedback(
      batch,
      _db,
      email: feedback.employeeEmail,
      employeeId: feedback.employeeId,
      name: feedback.employeeName,
      lastText: bodies.values.last,
      count: bodies.length,
    );

    await batch.commit();
  }

  /// Function Name: [countsByStatus]
  ///
  /// Purpose: How many of one employee's submissions sit in each status.
  ///
  /// ADDED 25/8/2026. This feature had no read path at all — the screen
  /// submitted and nothing ever looked at the result — so the home widget had
  /// nothing to count. This is that read, and it is deliberately the smallest
  /// one that answers the question: three integers, not a list of bodies the
  /// caller would then have to fold itself.
  ///
  /// Filtered on `employeeId` rather than the email: `submit` writes both, but
  /// the email is stored in whatever case the employee record carries and
  /// Firestore equality is case-sensitive, while the id is exact.
  ///
  /// Parameters:
  /// - [employeeId]: whose submissions to count.
  ///
  /// Returns: [Future] of every [FeedbackStatus] mapped to its count — always
  ///          all three keys, so the caller renders a 0 rather than a blank.
  Future<Map<FeedbackStatus, int>> countsByStatus(String employeeId) async {
    final Map<FeedbackStatus, int> counts = <FeedbackStatus, int>{
      for (final FeedbackStatus status in FeedbackStatus.values) status: 0,
    };
    if (employeeId.isEmpty) return counts;

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _feedback.where('employeeId', isEqualTo: employeeId).get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      final FeedbackStatus status =
          FeedbackStatus.fromWire(doc.data()['status']?.toString());
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  /// Function Name: [listForEmployee]
  ///
  /// Purpose: Every submission one employee has made, newest first — the rows
  ///          behind the "Request Details" list.
  ///
  /// ADDED 1/9/2026 for the Figma request list (MESBAH, node 7628:8180).
  ///
  /// Sorted in DART, not with `orderBy('createdAt')`. Two reasons, and the
  /// second is the load-bearing one:
  ///
  ///  1. `where` + `orderBy` on different fields needs a composite index. This
  ///     query would start failing in production the moment it shipped, on a
  ///     screen whose whole job is to show the user their own submissions.
  ///  2. `createdAt` is a SERVER timestamp. A document written seconds ago
  ///     reads back null until the server resolves it, and Firestore sorts
  ///     those documents last — so the submission the user just made would
  ///     appear at the BOTTOM of a list that claims to be newest-first. Sorting
  ///     here lets [_compareNewestFirst] put the un-resolved ones on top, which
  ///     is where the person who just pressed Submit expects to find them.
  ///
  /// The result set is one employee's own feedback, so it is small enough that
  /// client-side ordering costs nothing.
  ///
  /// Parameters:
  /// - [employeeId]: whose submissions to read.
  ///
  /// Returns: [Future<List<FeedbackRequest>>]; empty when [employeeId] is
  ///          empty, rather than reading the whole company's feedback.
  Future<List<FeedbackRequest>> listForEmployee(String employeeId) async {
    if (employeeId.isEmpty) return const <FeedbackRequest>[];

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _feedback.where('employeeId', isEqualTo: employeeId).get();

    final List<FeedbackRequest> requests = snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      final Object? raw = data['createdAt'];

      return FeedbackRequest.fromMap(
        id: doc.id,
        map: data,
        // Converted here so the entity never imports cloud_firestore.
        createdAt: raw is Timestamp ? raw.toDate() : null,
      );
    }).toList();

    requests.sort(_compareNewestFirst);
    return requests;
  }

  /// Newest first, with un-resolved server timestamps at the very top.
  ///
  /// See the note in [listForEmployee] — a null `createdAt` means "written so
  /// recently the server has not stamped it yet", which is the newest thing
  /// there is, not the oldest.
  static int _compareNewestFirst(FeedbackRequest a, FeedbackRequest b) {
    final DateTime? left = a.createdAt;
    final DateTime? right = b.createdAt;

    if (left == null && right == null) return 0;
    if (left == null) return -1;
    if (right == null) return 1;
    return right.compareTo(left);
  }
}
