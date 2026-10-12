/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: app_feedback.dart
/// Purpose: One feedback submission from the comments-and-feedback screen,
///          plus the read model the "Request Details" list renders.
/// Author: Knowticed Plus team
/// Created at: 13/8/2026
/// Updated: 1/9/2026 - Figma "Comments and Feedbacks" (MESBAH, nodes
///          7628:7681 and 7628:8180). Three additions:
///            • MANY attachments per box, not one. The screen now shows the
///              uploaded files in a grid with an "Attach Document" button at
///              the end, so `bugAttachment` and its two siblings became
///              `List<FeedbackAttachment>` keyed by kind.
///            • A [FeedbackPriority] per box — the Priority dropdown the
///              design puts under each text area.
///            • [FeedbackRequest], the READ model. This feature was
///              write-only apart from `countsByStatus`; the request list needs
///              whole documents, not just three integers.
///
/// Added while fixing the dead submit button. The screen offers three
/// independent boxes — report a bug, improvements to an existing feature,
/// request a feature — and the user may fill any combination of them, so one
/// submission carries up to three bodies rather than a single message plus a
/// type.
///
/// Updated: 2/9/2026 - Figma's "More Options" panel. Each box now also carries
/// a [FeedbackDetails] — module, screen, design/logic issue, device, software,
/// frequency and steps to reproduce. Kept in `feedback_details.dart` rather
/// than here: those seven enums describe a report's CONTENT, the three in this
/// file describe its LIFECYCLE, and folding them together would double the
/// length of this one.

import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/feedback_details.dart';

/// Re-exported deliberately. [AppFeedback] now has a [FeedbackDetails] on it,
/// so every file that already imports this one — the screen, the cubit, the
/// data source, the request card — would otherwise need a second import added
/// on the same line of work. One import keeps naming the whole feedback model.
export 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/feedback_details.dart';

/// Where a submission stands after triage.
///
/// ADDED 25/8/2026 for the "Comments and Feedbacks" home widget, which shows
/// Open / Fixed / Closed counts.
///
/// The field itself is not new — `FeedbackRemoteDataSource.submit` has always
/// written `'status': 'new'` on every document. It was a write-time constant
/// that nothing modelled and nothing read. This enum names the values that
/// field was meant to hold, and [fromWire] folds the literal `'new'` into
/// [open] so every submission already in Firestore counts correctly without a
/// migration.
///
/// ⚠️ Nothing sets [fixed] or [closed] yet — there is no triage screen. Those
/// two counts read 0 until one exists, which is accurate rather than
/// decorative: no feedback has been fixed or closed if nothing can close it.
enum FeedbackStatus {
  open('open'),
  fixed('fixed'),
  closed('closed');

  const FeedbackStatus(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  /// The value `submit` writes on a brand-new document.
  static const String newWireValue = 'new';

  /// Function Name: [fromWire]
  ///
  /// Purpose: Read a stored status, defaulting to [open].
  ///
  /// Mirrors `RequestStatus.fromWire`: anything unrecognised — including the
  /// legacy `'new'` and a missing field — is the un-actioned state, because a
  /// submission nobody has triaged is by definition still open.
  static FeedbackStatus fromWire(String? value) {
    final String normalized = (value ?? '').toLowerCase().trim();
    for (final FeedbackStatus status in FeedbackStatus.values) {
      if (status.wireValue == normalized) return status;
    }
    return FeedbackStatus.open;
  }
}

/// How urgent the submitter says their item is (1/9/2026).
///
/// The Figma form puts a "Select Priority" dropdown under each box. Nothing
/// downstream acts on it yet — like [FeedbackStatus.fixed], it is written now
/// so a triage screen has something to sort by later.
///
/// [fromWire] returns null rather than a default: "no priority given" is a
/// real state here (the dropdown starts empty and is optional), and collapsing
/// it into [low] would invent an answer the user never gave.
enum FeedbackPriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const FeedbackPriority(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  static FeedbackPriority? fromWire(String? value) {
    final String normalized = (value ?? '').toLowerCase().trim();
    if (normalized.isEmpty) return null;
    for (final FeedbackPriority priority in FeedbackPriority.values) {
      if (priority.wireValue == normalized) return priority;
    }
    return null;
  }
}

/// Which of the three boxes a body came from.
///
/// NOTE on [comment]: the label above this box reads "Improvements To Existing
/// Feature" as of 1/9/2026 (it was "Comments And Feedback"), but the wire value
/// stays `'comment'`. Renaming it would orphan every document already written
/// and break [FeedbackStatus] counting for existing employees. The label is a
/// presentation concern; this is the storage key.
enum FeedbackKind {
  bug('bug'),
  comment('comment'),
  featureRequest('feature_request');

  const FeedbackKind(this.wireValue);

  /// Exactly the string stored in Firestore.
  final String wireValue;

  /// Function Name: [fromWire]
  ///
  /// Purpose: Read a stored kind, defaulting to [comment].
  ///
  /// ADDED 1/9/2026 — the read path needs it. [comment] is the fallback
  /// because it is the least specific of the three: mislabelling an unknown
  /// document as a bug report or a feature request asserts something the
  /// document does not say.
  static FeedbackKind fromWire(String? value) {
    final String normalized = (value ?? '').toLowerCase().trim();
    for (final FeedbackKind kind in FeedbackKind.values) {
      if (kind.wireValue == normalized) return kind;
    }
    return FeedbackKind.comment;
  }
}

/// A file uploaded alongside one of the three bodies (24/8/2026).
///
/// The bytes live in Firebase Storage; only this descriptor is written to
/// Firestore. [name] and [sizeInBytes] are kept so a triager can see what was
/// attached without following [url].
class FeedbackAttachment {
  const FeedbackAttachment({
    required this.url,
    required this.name,
    required this.sizeInBytes,
    this.contentType,
    this.storagePath,
  });

  final String url;
  final String name;
  final int sizeInBytes;
  final String? contentType;

  /// Full path inside the bucket. Stored so the file can be deleted later
  /// without parsing it back out of the download URL.
  final String? storagePath;

  /// The part of [name] after the last dot, lower-cased and without the dot.
  ///
  /// Used to pick the file-type icon in the attachments grid. Empty when the
  /// name carries no extension — the icon helper falls back on its default.
  String get extension {
    final int dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'url': url,
        'name': name,
        'sizeInBytes': sizeInBytes,
        'contentType': contentType,
        'storagePath': storagePath,
      };

  /// Function Name: [fromMap]
  ///
  /// Purpose: Rebuild a descriptor written by [toMap].
  ///
  /// ADDED 1/9/2026 for the read path. Every field is defended: these
  /// documents are written by an older build too, and a null `sizeInBytes`
  /// must not take the whole list down.
  static FeedbackAttachment fromMap(Map<String, dynamic> map) {
    return FeedbackAttachment(
      url: map['url']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      sizeInBytes: (map['sizeInBytes'] as num?)?.toInt() ?? 0,
      contentType: map['contentType']?.toString(),
      storagePath: map['storagePath']?.toString(),
    );
  }
}

class AppFeedback {
  const AppFeedback({
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    this.bug = '',
    this.comment = '',
    this.featureRequest = '',
    this.attachments = const <FeedbackKind, List<FeedbackAttachment>>{},
    this.priorities = const <FeedbackKind, FeedbackPriority>{},
    this.details = const <FeedbackKind, FeedbackDetails>{},
  });

  final String employeeId;
  final String employeeName;
  final String employeeEmail;

  /// Body of the "Report Bugs" box; empty when the box was not used.
  final String bug;

  /// Body of the "Improvements To Existing Feature" box.
  final String comment;

  /// Body of the "Request New Feature" box.
  final String featureRequest;

  /// Files picked for each box, in the order the user added them.
  ///
  /// CHANGED 1/9/2026 — was one nullable [FeedbackAttachment] per box, because
  /// picking again REPLACED the previous file. The Figma form shows the
  /// uploads as a grid that grows, so a box now holds a list and picking again
  /// appends.
  final Map<FeedbackKind, List<FeedbackAttachment>> attachments;

  /// The priority chosen for each box. A box the user left on "Select
  /// Priority" is simply absent from the map.
  final Map<FeedbackKind, FeedbackPriority> priorities;

  /// The "More Options" answers for each box (2/9/2026).
  ///
  /// Per-kind, not per-submission: the form lets someone report a bug against
  /// the Requests module and ask for a feature on the Calendar in one go, and
  /// a single set of answers could not describe both.
  ///
  /// A box whose panel was never opened is absent from the map, which is not
  /// the same as being present with an empty [FeedbackDetails] — though
  /// [detailsByKind] flattens the two, since neither is worth writing.
  final Map<FeedbackKind, FeedbackDetails> details;

  /// The attachments, filtered down to boxes that are actually being sent.
  ///
  /// Deliberately keyed off [bodies], not off [attachments]: a file attached to
  /// a box the user then emptied or unticked is not sent, because that box has
  /// no document to hang it on.
  Map<FeedbackKind, List<FeedbackAttachment>> get attachmentsByKind {
    final Map<FeedbackKind, String> filled = bodies;
    final Map<FeedbackKind, List<FeedbackAttachment>> result =
        <FeedbackKind, List<FeedbackAttachment>>{};

    attachments.forEach((FeedbackKind kind, List<FeedbackAttachment> files) {
      if (filled.containsKey(kind) && files.isNotEmpty) {
        result[kind] = List<FeedbackAttachment>.unmodifiable(files);
      }
    });

    return result;
  }

  /// Same rule as [attachmentsByKind], for the priority values.
  Map<FeedbackKind, FeedbackPriority> get prioritiesByKind {
    final Map<FeedbackKind, String> filled = bodies;
    return <FeedbackKind, FeedbackPriority>{
      for (final MapEntry<FeedbackKind, FeedbackPriority> entry
          in priorities.entries)
        if (filled.containsKey(entry.key)) entry.key: entry.value,
    };
  }

  /// Same rule as [attachmentsByKind], for the "More Options" answers.
  ///
  /// Boxes whose panel came back empty are dropped as well as boxes with no
  /// body: an all-null [FeedbackDetails] is not worth a nested object on the
  /// document, and [FeedbackDetails.isEmpty] is the same test the data source
  /// would otherwise repeat.
  Map<FeedbackKind, FeedbackDetails> get detailsByKind {
    final Map<FeedbackKind, String> filled = bodies;
    return <FeedbackKind, FeedbackDetails>{
      for (final MapEntry<FeedbackKind, FeedbackDetails> entry
          in details.entries)
        if (filled.containsKey(entry.key) && entry.value.isNotEmpty)
          entry.key: entry.value,
    };
  }

  /// The bodies the user actually filled in, keyed by kind. Whitespace-only
  /// entries are dropped — the submit button treats them as empty too.
  Map<FeedbackKind, String> get bodies => <FeedbackKind, String>{
        if (bug.trim().isNotEmpty) FeedbackKind.bug: bug.trim(),
        if (comment.trim().isNotEmpty) FeedbackKind.comment: comment.trim(),
        if (featureRequest.trim().isNotEmpty)
          FeedbackKind.featureRequest: featureRequest.trim(),
      };

  /// Whether there is anything worth sending.
  bool get isEmpty => bodies.isEmpty;
}

/// One submitted document, as the "Request Details" list reads it back.
///
/// ADDED 1/9/2026. [AppFeedback] is the WRITE model — it carries up to three
/// bodies because the form does. Firestore stores one document per body, so
/// the read model is one body, and this is it. Keeping them separate is what
/// stops the list having to reason about two bodies that were never on the
/// same document.
class FeedbackRequest {
  const FeedbackRequest({
    required this.id,
    required this.kind,
    required this.body,
    required this.status,
    required this.createdAt,
    this.priority,
    this.attachments = const <FeedbackAttachment>[],
    this.details = const FeedbackDetails(),
  });

  /// Firestore document id.
  final String id;

  final FeedbackKind kind;
  final String body;
  final FeedbackStatus status;
  final FeedbackPriority? priority;

  /// Null while the server timestamp is still resolving — a document written
  /// moments ago reads back with `createdAt == null` until the write lands.
  /// The card shows a dash for it rather than inventing "now".
  final DateTime? createdAt;

  final List<FeedbackAttachment> attachments;

  /// The "More Options" answers this document was submitted with.
  ///
  /// Never null — [FeedbackDetails.fromMap] returns an empty instance for the
  /// documents written before 2/9/2026, which have no `details` field at all.
  /// A card can therefore read `request.details.device` without a null check
  /// and simply get null back.
  final FeedbackDetails details;

  /// Function Name: [fromMap]
  ///
  /// Purpose: Build one row from a Firestore document.
  ///
  /// Parameters:
  /// - [id]: the document id.
  /// - [map]: its data.
  /// - [createdAt]: already converted from `Timestamp` by the data source, so
  ///   this entity stays free of the cloud_firestore import.
  ///
  /// Reads BOTH attachment shapes: `attachments` (the list, written since
  /// 1/9/2026) and the older singular `attachment` map. Documents from before
  /// today have only the second, and dropping their file would look like data
  /// loss to the person who uploaded it.
  static FeedbackRequest fromMap({
    required String id,
    required Map<String, dynamic> map,
    DateTime? createdAt,
  }) {
    final List<FeedbackAttachment> files = <FeedbackAttachment>[];

    final Object? rawList = map['attachments'];
    if (rawList is List) {
      for (final Object? entry in rawList) {
        if (entry is Map) {
          files.add(FeedbackAttachment.fromMap(
            Map<String, dynamic>.from(entry),
          ));
        }
      }
    }

    if (files.isEmpty) {
      final Object? legacy = map['attachment'];
      if (legacy is Map) {
        files.add(FeedbackAttachment.fromMap(
          Map<String, dynamic>.from(legacy),
        ));
      }
    }

    return FeedbackRequest(
      id: id,
      kind: FeedbackKind.fromWire(map['type']?.toString()),
      body: map['body']?.toString() ?? '',
      status: FeedbackStatus.fromWire(map['status']?.toString()),
      priority: FeedbackPriority.fromWire(map['priority']?.toString()),
      createdAt: createdAt,
      attachments: List<FeedbackAttachment>.unmodifiable(files),
      // `is Map` rather than a cast: a document written by a build that stored
      // something else under this key must not take the whole list down.
      details: FeedbackDetails.fromMap(
        map['details'] is Map
            ? Map<String, dynamic>.from(map['details'] as Map)
            : null,
      ),
    );
  }
}
