/// Module: time_tracker / data / services / demo
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_demo_service.dart
/// Purpose: Declares `TimeTrackerDemoService` — the DEBUG-ONLY "Load demo
///          data" / "Remove demo data" writer behind the 🧪 button of the
///          Time Tracker header (like To-Do's demo tools).
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI quality pass — owner: every tab, chart, counter
///            and widget must show real content for the review)
///
/// LOAD: reads the company's employees (Employees_Info, through the module's
/// directory), their direct managers (org chart), the HR approvers and the
/// work set-up source, builds the plan (`TimeTrackerDemoBuilder`), renders
/// and uploads the PDF attachments through the module's OWN upload
/// repository (same Firebase Storage folder as a real attachment), then
/// writes every document through the module's data source + history codec +
/// model encoders — the exact indexed-history shape the app writes — plus
/// one extra history field `Is_Demo: [true]`.
/// - Nothing that exists is touched: every write is create-only
///   (`createIfAbsent`), so a real check-in, assignment or balance with the
///   same id is kept as it is.
/// - Already loaded (the demo Annual Vacation type exists) → nothing is
///   written.
/// - Free texts are written in the app language.
///
/// REMOVE: deletes ONLY documents tagged `Is_Demo` (a query on that field in
/// each collection), and returns the URLs of the PDFs those requests carry so
/// the caller can delete the files ([deleteFile]). Demo documents are hard
/// deleted — it is the developer's own test data in a debug build; every app
/// feature keeps its soft delete / status history.
///
/// Updated: 9/10/2026 - data model (owner, 9 Oct): balances are written to
/// `Vacation_Balances/{email}_{year}`; request comments to
/// `Requests/{id}/Comments/{commentId}` (one document each, `Is_Demo` too),
/// and REMOVE deletes each demo request's comments with it.
///
/// Throws on failure (the cubit turns it into a message).


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/data_source/remote_data_source/time_tracker_storage_remote_data_source.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/attendance_day_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/employee_group_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/location_assignment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_comment_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/request_type_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_document.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_field_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_history_codec.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/time_tracker_request_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/vacation_balance_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/models/work_location_model.dart';
import 'package:knowticed_plus/features/time_tracker/data/repository/work_setup_source_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_builder.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_documents.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/demo/time_tracker_demo_plan.dart';
import 'package:knowticed_plus/features/time_tracker/data/services/time_tracker_access.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/approver_directory.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/attachment_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/employee_directory_base_repository.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/manager_resolver.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/constants/time_tracker_firestore_paths.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/employee_assignment.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_parts.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/request_type.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_employee.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/vacation_balance.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';
import 'package:knowticed_plus/features/time_tracker/domain/enums/setup_status.dart';

/// The outcome of a load / remove.
class TtDemoResult {
  const TtDemoResult({required this.documents, this.files = 0, this.alreadyLoaded = false, this.fileUrls = const <String>[]});

  /// Documents written / deleted.
  final int documents;

  /// PDF files uploaded.
  final int files;

  /// Load found the demo already there (nothing written).
  final bool alreadyLoaded;

  /// Remove: the demo PDFs to delete from Storage.
  final List<String> fileUrls;
}

class TimeTrackerDemoService {
  TimeTrackerDemoService({
    required TimeTrackerRemoteDataSource remote,
    required EmployeeDirectoryBaseRepository directory,
    required ManagerResolver managers,
    required ApproverDirectory approvers,
    required WorkSetupSourceResolver resolver,
    required AttachmentBaseRepository attachments,
    required TimeTrackerAccess access,
    TimeTrackerStorageRemoteDataSource? storage,
    Future<ByteData> Function(String asset)? loadAsset,
    DateTime Function()? clock,
  })  : _remote = remote,
        _directory = directory,
        _managers = managers,
        _approvers = approvers,
        _resolver = resolver,
        _attachments = attachments,
        _access = access,
        _storage = storage,
        _loadAsset = loadAsset ?? rootBundle.load,
        _clock = clock ?? DateTime.now;

  final TimeTrackerRemoteDataSource _remote;
  final EmployeeDirectoryBaseRepository _directory;
  final ManagerResolver _managers;
  final ApproverDirectory _approvers;
  final WorkSetupSourceResolver _resolver;
  final AttachmentBaseRepository _attachments;
  final TimeTrackerAccess _access;
  final TimeTrackerStorageRemoteDataSource? _storage;
  final Future<ByteData> Function(String asset) _loadAsset;
  final DateTime Function() _clock;

  /// Every collection the demo writes to.
  static const List<String> collections = <String>[
    TimeTrackerFirestorePaths.requests,
    TimeTrackerFirestorePaths.attendance,
    TimeTrackerFirestorePaths.vacationBalances,
    TimeTrackerFirestorePaths.locationAssignments,
    TimeTrackerFirestorePaths.groups,
    TimeTrackerFirestorePaths.requestTypes,
    TimeTrackerFirestorePaths.locations,
  ];

  static const int _parallel = 8;
  static const String _cairo = 'assets/fonts/fonts_english/Cairo';

  /// Function Name: [load]
  ///
  /// Purpose: Build and write the demo data (see the file header).
  ///
  /// Return type: [Future<TtDemoResult>]
  Future<TtDemoResult> load({required bool isArabic}) async {
    if (await _remote.fetchDocument(TimeTrackerFirestorePaths.requestTypes, TtDemoIds.annual) != null) {
      return const TtDemoResult(documents: 0, alreadyLoaded: true);
    }
    final TtDemoInput input = await _input(isArabic: isArabic);
    final TtDemoPlan plan = TimeTrackerDemoBuilder.build(input, isArabic: isArabic);
    final String actor = _access.currentUserEmail.trim().toLowerCase();
    final DateTime setupAt = plan.typesCreatedAt ?? input.now;
    int written = 0;
    Future<void> run(List<Future<bool> Function()> jobs) async {
      for (int i = 0; i < jobs.length; i += _parallel) {
        final List<bool> done = await Future.wait(<Future<bool>>[
          for (final Future<bool> Function() job in jobs.skip(i).take(_parallel)) job(),
        ]);
        written += done.where((bool d) => d).length;
      }
    }

    TimeTrackerAudit audit(String by, DateTime at) =>
        TimeTrackerAudit(createdBy: by, createdAt: Timestamp.fromDate(at), modifiedBy: actor);
    await run(<Future<bool> Function()>[
      for (final WorkLocation l in plan.locations)
        () => _create(TimeTrackerFirestorePaths.locations, l.id,
            (String id) => WorkLocationModel.row(l, id: id, audit: audit(actor, setupAt))),
      for (final RequestType t in plan.requestTypes)
        () => _create(TimeTrackerFirestorePaths.requestTypes, t.id,
            (String id) => RequestTypeModel.row(t, id: id, audit: audit(actor, setupAt))),
      for (final EmployeeGroup g in plan.groups)
        () => _create(TimeTrackerFirestorePaths.groups, g.id,
            (String id) => EmployeeGroupModel.row(g, id: id, audit: audit(actor, setupAt))),
      for (final LocationAssignment a in plan.assignments)
        () => _create(TimeTrackerFirestorePaths.locationAssignments, a.employeeEmail,
            (String id) => LocationAssignmentModel.row(a, id: id, audit: audit(actor, setupAt))),
      for (final VacationBalance b in plan.balances)
        () => _create(TimeTrackerFirestorePaths.vacationBalances, VacationBalanceModel.docIdOf(b),
            (String id) => VacationBalanceModel.row(b, id: id, audit: audit(actor, DateTime(b.year)))),
    ]);
    await run(<Future<bool> Function()>[
      for (final TtDemoDay d in plan.days) () => _writeDay(d, audit(d.day.employeeEmail, d.day.date)),
    ]);
    final _Fonts fonts = await _fonts();
    int files = 0;
    final List<Future<bool> Function()> requestJobs = <Future<bool> Function()>[];
    for (final TtDemoRequest r in plan.requests) {
      requestJobs.add(() async {
        final List<RequestAttachment> uploaded = <RequestAttachment>[];
        for (final TtDemoDocument doc in r.documents) {
          final Uint8List bytes = await TtDemoDocuments.render(doc,
              regularFont: fonts.regular, boldFont: fonts.bold, details: isArabic ? '' : r.request.description);
          uploaded.add(await _attachments.uploadRequestAttachment(
            employeeEmail: r.request.requesterEmail,
            fileName: doc.fileName,
            bytes: bytes,
          ));
          files++;
        }
        final TimeTrackerRequest request =
            uploaded.isEmpty ? r.request : r.request.copyWith(attachments: uploaded);
        final bool created = await _create(TimeTrackerFirestorePaths.requests, r.request.id,
            (String id) => TimeTrackerRequestModel.row(request, id: id,
                audit: audit(r.request.requesterEmail, r.submittedAt)));
        // 9/10/2026 (data model): one document per comment.
        for (final RequestComment c in r.comments) {
          await _create(TimeTrackerFirestorePaths.requestComments(r.request.id), c.id,
              (String id) => RequestCommentModel.row(c, id: id,
                  audit: audit(c.authorEmail, c.createdAt ?? r.submittedAt)));
        }
        return created;
      });
    }
    await run(requestJobs);
    return TtDemoResult(documents: written, files: files);
  }

  /// Function Name: [remove]
  ///
  /// Purpose: Delete every `Is_Demo` document; answer the PDF URLs those
  /// requests carried (delete them with [deleteFile]).
  ///
  /// Return type: [Future<TtDemoResult>]
  Future<TtDemoResult> remove() async {
    int deleted = 0;
    final List<String> urls = <String>[];
    for (final String path in collections) {
      final List<TimeTrackerDocument> docs = await _remote.fetchArrayContains(path, TtDemoIds.field, true);
      if (path == TimeTrackerFirestorePaths.requests) {
        for (final TimeTrackerDocument d in docs) {
          for (final RequestAttachment a in TimeTrackerRequestModel.fromMap(d.id, d.data).attachments) {
            if (a.url.startsWith('http')) urls.add(a.url);
          }
          // 9/10/2026 (data model): the request's Comments sub-collection
          // (Firestore never deletes it with its parent).
          final String comments = TimeTrackerFirestorePaths.requestComments(d.id);
          for (final TimeTrackerDocument c in await _remote.fetchArrayContains(comments, TtDemoIds.field, true)) {
            await _remote.deleteDocument(comments, c.id);
            deleted++;
          }
        }
      }
      for (int i = 0; i < docs.length; i += _parallel) {
        await Future.wait(<Future<void>>[
          for (final TimeTrackerDocument d in docs.skip(i).take(_parallel)) _remote.deleteDocument(path, d.id),
        ]);
      }
      deleted += docs.length;
    }
    return TtDemoResult(documents: deleted, fileUrls: urls);
  }

  /// Function Name: [deleteFile]
  ///
  /// Purpose: Delete one demo PDF from Storage (throws on failure; the cubit
  /// ignores a file that is already gone).
  ///
  /// Return type: [Future<void>]
  Future<void> deleteFile(String url) async {
    final TimeTrackerStorageRemoteDataSource? storage = _storage;
    if (storage == null) return;
    await storage.deleteByUrl(url);
  }

  // ── Inputs ────────────────────────────────────────────────────────────────

  Future<TtDemoInput> _input({required bool isArabic}) async {
    final String myEmail = _access.currentUserEmail.trim().toLowerCase();
    final List<TimeTrackerEmployee> people = await _directory.fetchEmployees(isArabic: isArabic);
    final TimeTrackerIdentity me = _access.identity;
    final TimeTrackerEmployee self = people.firstWhere(
      (TimeTrackerEmployee e) => e.email == myEmail,
      orElse: () => TimeTrackerEmployee(
        email: myEmail,
        nameEn: me.nameEn,
        nameAr: me.nameAr,
        jobTitleEn: me.jobTitleEn,
        jobTitleAr: me.jobTitleAr,
        departmentId: me.departmentId,
        departmentName: me.departmentName,
      ),
    );
    final List<TimeTrackerEmployee> others = <TimeTrackerEmployee>[
      for (final TimeTrackerEmployee e in people)
        if (e.email.isNotEmpty && e.email != myEmail) e,
    ]..sort((TimeTrackerEmployee a, TimeTrackerEmployee b) => a.email.compareTo(b.email));
    final List<TimeTrackerEmployee> used = others.take(12).toList();
    final Map<String, String> managers = <String, String>{
      for (final TimeTrackerEmployee e in <TimeTrackerEmployee>[self, ...used])
        e.email: await _managers.managerEmailOf(employeeEmail: e.email, employeeId: e.employeeId),
    };
    final List<String> hr = <String>[
      for (final TimeTrackerApprover a in await _approvers.fetchHrApprovers()) a.email,
    ];
    final bool hasHr = await _resolver.hasHrModule();
    final WorkSetupSource source = await _resolver.resolve();
    final List<WorkLocation> locations = <WorkLocation>[
      for (final WorkLocation l in await source.loadLocations())
        if (l.status == LocationStatus.active) l,
    ];
    return TtDemoInput(
      me: self,
      others: used,
      now: _clock(),
      managerOf: managers,
      hrApprovers: hr,
      existingLocations: locations,
      companyHasHr: hasHr,
    );
  }

  Future<_Fonts> _fonts() async {
    final ByteData regular = await _loadAsset('$_cairo/Cairo-Regular.ttf');
    final ByteData bold = await _loadAsset('$_cairo/Cairo-Bold.ttf');
    return _Fonts(
      Uint8List.sublistView(regular),
      Uint8List.sublistView(bold),
    );
  }

  // ── Writes ────────────────────────────────────────────────────────────────

  /// Create [id] with its first row + the `Is_Demo` tag; false when it
  /// already exists (left untouched).
  Future<bool> _create(String path, String id, Map<String, Object?> Function(String id) row) =>
      _remote.createIfAbsent(
        relativePath: path,
        id: id,
        row: (String docId, Map<String, dynamic>? _) => <String, Object?>{...row(docId), TtDemoIds.field: true},
      );

  /// One attendance day: alerts / automatic check-out in the approved
  /// schema shape; a corrected day gets its uncorrected first row too.
  Future<bool> _writeDay(TtDemoDay d, TimeTrackerAudit audit) async {
    Map<String, Object?> row(AttendanceDay day, String id, {bool final_ = true}) {
      final Map<String, Object?> values = AttendanceDayModel.row(day, id: id, audit: audit);
      if (final_ && d.isAutoCheckOut) {
        final List<Map<String, dynamic>> sessions = TimeTrackerFieldCodec.maps(values[AttendanceDayModel.fSessions]);
        if (sessions.isNotEmpty) {
          sessions.last['Is_Auto_Check_Out'] = true;
          values[AttendanceDayModel.fSessions] = TimeTrackerFieldCodec.wrap(sessions);
        }
      }
      values['Alerts'] = TimeTrackerFieldCodec.wrap(<Object?>[
        for (final TtDemoAlert a in d.alerts)
          <String, Object?>{'Alert_Type': a.type, 'At': Timestamp.fromDate(a.at), 'Minutes_Over': a.minutesOver},
      ]);
      return values;
    }

    final AttendanceDay? before = d.before;
    final String id = d.day.id;
    if (before == null) {
      return _create(TimeTrackerFirestorePaths.attendance, id, (String docId) => row(d.day, docId));
    }
    final bool created = await _create(
      TimeTrackerFirestorePaths.attendance,
      id,
      (String docId) => row(before, docId, final_: false)..['Alerts'] = TimeTrackerFieldCodec.wrap(const <Object?>[]),
    );
    if (!created) return false;
    await _remote.appendRow(
      relativePath: TimeTrackerFirestorePaths.attendance,
      id: id,
      mustExist: true,
      row: (String docId, Map<String, dynamic>? stored) => <String, Object?>{
        ...row(d.day, docId),
        TtDemoIds.field: true,
        // The correction keeps the original creation date.
        if (stored != null) TimeTrackerAudit.fCreationDate: TimeTrackerHistoryCodec.lastOf(stored, TimeTrackerAudit.fCreationDate),
      },
    );
    return true;
  }
}

class _Fonts {
  const _Fonts(this.regular, this.bold);

  final Uint8List regular;
  final Uint8List bold;
}
