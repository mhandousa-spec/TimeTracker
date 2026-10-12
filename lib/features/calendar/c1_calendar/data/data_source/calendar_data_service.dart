/// Module: calendar/c1_calendar
///
///*************************** FILE INFO ****************************///
/// File Name: calendar_data_service.dart
/// Purpose: Fetches calendar events from every module that publishes them.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-CAL-N02-DATA/N04-DATA/N05-DATA: `package:flutter/material.dart` no
///          longer reaches the data layer; the 26 inline colour literals are
///          named tokens on AppColors; `Get.locale` and
///          `Get.find<MainCoreEmployeeController>()` are injected callbacks; the
///          dead `_capitalizeFirstLetter` is deleted.
/// Updated: 9/10/2026 - Time Tracker phase 6: `getTimeTrackerCalendarEvents`
///          + `timeTrackerCalendarEntries` (delegate to
///          `time_tracker_calendar_source.dart`); seeded Time Tracker cards
///          carry no request id.
///
/// REMAINING (CR-SKEL-CAL-N01-DATA): still ~2,900 LOC, over the 1,500 gate. The
/// seven public `get*CalendarEvents` methods are the natural split points, but
/// several private helpers (`_getArrayValue`, `_isMyTurnToApprove`) are shared
/// across them, so the split needs a shared base rather than a straight cut.

import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_event_type.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/grc_module/grc_module_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/grc_module/grc_policy_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/grc_module/grc_control_calendar_events.dart';
import 'package:knowticed_plus/features/grc/assignment_control/data/models/assignment_control_model.dart';
import 'package:knowticed_plus/features/grc/control/data/models/control_model.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control_champion/data/models/champion_model.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_entity.dart';
import 'package:knowticed_plus/features/grc/control_champion/domain/entities/champion_status.dart';
import 'package:knowticed_plus/features/grc/control_owner/data/models/owner_model.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_status.dart';
import 'package:knowticed_plus/features/grc/grc_request/data/models/grc_request_model.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_entity.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/approval_status.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/grc/policy/data/models/policy_model.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/module/data/models/grc_module_model.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/services_management_module.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/services_module/services_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/role_module/role_management_module/role_management_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/role_module/user_access_module/user_access_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/knowledge_hub_module/knowledge_hub_calendar_events.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/todo_module/todo_calendar_events.dart';
import 'package:knowticed_plus/features/todo/data/models/todo_model.dart';
import 'package:knowticed_plus/features/todo/domain/constants/todo_firestore_paths.dart';
import 'package:knowticed_plus/features/todo/domain/entities/todo_entity.dart';
// ADDED 9/10/2026 — Time Tracker phase 6 calendar source.
import 'package:knowticed_plus/features/calendar/c1_calendar/data/data_source/time_tracker_calendar_source.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/time_tracker_module/time_tracker_calendar_events.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/attendance_day.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/time_tracker_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/settings_module/settings_calendar_events.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/roles_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_management_permission.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
// api_constants.dart is imported for FirestoreCollections (the request path
// constant). `FirebaseCollections` is hidden because a second class of that
// name lives in core/constants/firebase_collections.dart.
import 'package:knowticed_plus/core/network/api_constants.dart' hide FirebaseCollections;
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/data/models/calendar_event_model.dart';
import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/features/grc/shared/constants/grc_firebase_paths.dart';
import 'package:knowticed_plus/features/calendar/c1_calendar/domain/enums/calendar_catalog.dart';
import 'package:knowticed_plus/core/enums/template_variable_samples.dart';

class CalendarDataService {
  /// Department lookups are injected; this service has no service locator.
  final MainCoreDepartmentCubit departmentCubit;

  /// The active language code. Was `Get.locale?.languageCode ?? 'en'` read at
  /// six points inside this file — a banned service locator, in the data layer
  /// (CR-SKEL-CAL-N04-DATA). A callback, not a value, so a locale change while
  /// the app is running is picked up.
  final String Function() languageCode;

  /// The signed-in employee. Was `Get.find<MainCoreEmployeeController>()` at
  /// three points here.
  final MainCoreEmployeeController Function() currentEmployee;

  CalendarDataService({
    required this.departmentCubit,
    String Function()? languageCode,
    MainCoreEmployeeController Function()? currentEmployee,
  })  : languageCode = languageCode ?? _defaultLanguageCode,
        currentEmployee = currentEmployee ?? _defaultCurrentEmployee;

  /// Fallbacks so existing call sites keep working while the injection is
  /// threaded through. They are the only GetX left in this file and are the
  /// next thing to remove.
  static String _defaultLanguageCode() => Get.locale?.languageCode ?? 'en';
  static MainCoreEmployeeController _defaultCurrentEmployee() =>
      Get.find<MainCoreEmployeeController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ───────────────────────── seeded demo events ─────────────────────────
  // ADDED 27/9/2026 — the "Apply all modules" button on Home.

  /// Collection (under `getBaseUrl`) that `DemoAccountsSeeder` writes one
  /// document per (account, calendar event type) into.
  static const String seededEventsPath = 'Modules/calendar/Seeded_Events';

  /// Function Name: [getSeededCalendarEvents]
  ///
  /// Purpose: the calendar entries written by the Home "Apply all modules"
  /// button for [currentUserEmail]. Each document only stores the event type
  /// id and a source date; title, colour, status and description are rebuilt
  /// from the enum through `CalendarEventModel.fromType`, exactly like the
  /// real builders, so a seeded card looks identical to a real one.
  Future<List<CalendarEventModel>> getSeededCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];
    final String email = currentUserEmail.trim().toLowerCase();
    if (email.isEmpty) return events;

    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(getBaseUrl(seededEventsPath))
        .where('receiverEmail', isEqualTo: email)
        .get();

    final bool isArabic = languageCode() == 'ar';
    final DateTime now = DateTime.now();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in snapshot.docs) {
      final Map<String, dynamic> data = doc.data();
      final CalendarEventType? type =
          CalendarCatalog.findById((data['typeId'] ?? '').toString());
      final dynamic rawDate = data['sourceDate'];
      if (type == null || rawDate is! Timestamp) continue;

      final DateTime sourceDate = rawDate.toDate();
      events.add(CalendarEventModel.fromType(
        type,
        sourceDate: sourceDate,
        isArabic: isArabic,
        variables: type.variables.toSampleValues(now: now),
        time: DateFormat('hh:mm a', 'en').format(sourceDate),
        // A seeded To-Do card has no real to-do behind it: a null id makes
        // the card open the To-Do list instead of a "not found" details page.
        // 9/10/2026 — same for a seeded Time Tracker card (opens the module).
        requestId: (type is TodoCalendarEvent || type is TimeTrackerCalendarEvent)
            ? null
            : doc.id,
        userEmail: email,
      ));
    }
    return events;
  }


  Future<List<CalendarEventModel>> getApprovalCalendarEvents({
    required String currentUserEmail,
  }) async
  {
    List<CalendarEventModel> events = [];

    try {
      // The hand-rolled companyId extraction that stood here
      // (`getBaseUrl('').split('/')[1]`) is gone with the path fix below —
      // `getBaseUrl` already prefixes the tenant, so nothing needs to take it
      // apart.

      // ✅ Get current locale to determine language
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';


      try {
        // ⚠️ FIXED 30/8/2026 — THE COLLECTION PATH WAS WRONG, and this alone
        // is why the Services module never put a single card on the calendar.
        //
        // This built `Demo/<companyId>/RequestServices`. Service requests are
        // not stored there. Every writer and reader in the Services module
        // itself goes through
        // `getBaseUrl(FirestoreCollections.requestServicesRoot)`, which is
        // `Modules/services/RequestServices` — so the real collection is
        // `Demo/<companyId>/Modules/services/RequestServices`, confirmed
        // against the module's own log line:
        //
        //     getMyRequestServices → path=Demo/75440689/Modules/services/
        //     RequestServices → 10 docs
        //
        // The path this used resolves to an empty collection: no error, no
        // exception, `docs` simply empty, and the `isEmpty` guard below
        // returned an empty list. Nothing anywhere reported a problem.
        //
        // Built from the shared constant rather than reassembled here, so the
        // calendar cannot drift from the module again.
        final exactPath = _firestore
            .collection(getBaseUrl(FirestoreCollections.requestServicesRoot));

        final requestsSnapshot = await exactPath.get().timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Approval query timeout after 15 seconds');
          },
        );


        if (requestsSnapshot.docs.isEmpty) {
          return events;
        }

        int requestIndex = 0;

        for (var requestDoc in requestsSnapshot.docs) {
          requestIndex++;
          try {
            final data = requestDoc.data();
            final requestId = requestDoc.id;


            // ✅ Get service name
            String? serviceNameEnglish = _getArrayValue(data['serviceNameEnglish']);
            String? serviceNameArabic = _getArrayValue(data['serviceNameArabic']);

            // Fallback to alternative fields
            if (serviceNameEnglish == null || serviceNameEnglish.isEmpty || serviceNameEnglish.toLowerCase() == 'approval') {
              serviceNameEnglish = _getArrayValue(data['currentServiceNameEnglish']) ?? 'Service Request';
            }

            if (serviceNameArabic == null || serviceNameArabic.isEmpty || serviceNameArabic == 'موافقة') {
              serviceNameArabic = _getArrayValue(data['currentServiceNameArabic']) ?? 'طلب خدمة';
            }

            final taskName = isArabic ? serviceNameArabic : serviceNameEnglish;


            // Parse approval cycle.
            //
            // FIXED: read the canonical `Approval_Cycle` key.
            // Request documents store the cycle under `Approval_Cycle`
            // (ServicesHistoryModel.kApprovalCycle = 'Approval_Cycle'); this
            // read the lowercase `approvalCycle`, which never exists, so
            // `approvalCycleRaw` was always null, the parsed cycle stayed
            // empty, and every request was skipped by the `isEmpty` guard
            // below — no approver ever saw a "Pending Approval" (or approved /
            // rejected) entry on their calendar. Falls back to the lowercase
            // key for any legacy document that used it.
            // ⚠️ FIXED 30/8/2026 — this is why approving or rejecting a
            // request never changed anything on the calendar.
            //
            // `Approval_Cycle` is a REVISION HISTORY, not a cycle.
            // `ServicesHistoryModel.updateApprovalCycle` appends a whole new
            // JSON-encoded cycle every time a decision is taken, and
            // `ServicesHistoryModel.currentApprovalCycle` reads `.last`. The
            // loop that stood here decoded EVERY revision and flattened them
            // into one list, so after a single approval the list held the same
            // approvers twice — the original revision (everyone `pending`)
            // first, the decided revision second. `indexWhere` returns the
            // FIRST match, so `myState` was read out of the OLDEST revision
            // and stayed 'pending' forever: CASE 2 (approved) and CASE 3
            // (rejected) below could never fire, no matter how many times the
            // request was decided. The `timestampsArray[myIndex]` lookups were
            // wrong for the same reason — a cross-revision position indexed
            // into an unrelated array.
            //
            // Only the last revision is the live cycle, so only the last
            // revision is decoded.
            final approvalCycleRaw =
                data['Approval_Cycle'] ?? data['approvalCycle'];
            final List<Map<String, String>> approvalCycle =
                _decodeCurrentApprovalCycle(approvalCycleRaw);

            if (approvalCycle.isEmpty) {
              continue;
            }

            // Get timestamps
            final timestampsArray = data['timestamps'] as List?;
            if (timestampsArray == null || timestampsArray.isEmpty) {
              continue;
            }

            // ── Dates ────────────────────────────────────────────────────
            //
            // `timestamps` is appended to by EVERY mutation of the document
            // (status, provider list, department, approval cycle), so no index
            // into it maps to "my step in the cycle". The two ENDS are
            // meaningful and the middle is not: the first entry is when the
            // request was raised, the last is when it was most recently acted
            // on — which, for a request whose cycle has just been decided, is
            // that decision.
            final DateTime submittedAt = _epochMs(timestampsArray.first);
            final DateTime lastActionAt = _epochMs(timestampsArray.last);

            final List<String> requesterEmails =
                _historyList(data['Email_Requester'])
                    .where((String e) => e.trim().isNotEmpty)
                    .toList();
            final String requesterEmail = requesterEmails.isEmpty
                ? ''
                : requesterEmails.last.trim().toLowerCase();
            final bool isRequester =
                requesterEmail.isNotEmpty &&
                    requesterEmail == currentUserEmail.trim().toLowerCase();

            // Check if user is in approval cycle
            final myIndex = approvalCycle.indexWhere(
                  (e) => e['email'] == currentUserEmail.trim().toLowerCase(),
            );

            if (myIndex == -1 && !isRequester) {
              continue;
            }

            final String myState =
                myIndex == -1 ? '' : (approvalCycle[myIndex]['state'] ?? '');

            // ── APPROVER'S OWN STEP ──────────────────────────────────────
            if (myIndex != -1) {
              // ✅ CASE 1: Pending Approval (show if currently pending)
              if (<String>['pending', 'normal', ''].contains(myState)) {
                final isMyTurn = _isMyTurnToApprove(
                  approvalCycle: approvalCycle,
                  currentUserEmail: currentUserEmail,
                  myIndex: myIndex,
                );

                if (isMyTurn) {
                  events.add(CalendarEventModel.fromType(
                    ServicesCalendarEvent.pendingApproval,
                    sourceDate: submittedAt,
                    isArabic: isArabic,
                    taskName: taskName,
                    time: DateFormat('hh:mm a').format(submittedAt),
                    requestId: requestId,
                    userEmail: currentUserEmail,
                  ));
                }
              }

              // ✅ CASE 2: Approved (always show, even after approval)
              if (myState == 'approved') {
                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.approvalApproved,
                  sourceDate: lastActionAt,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(lastActionAt),
                  requestId: requestId,
                  userEmail: currentUserEmail,
                ));
              }

              // ✅ CASE 3: Rejected (always show)
              if (myState == 'rejected') {
                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.approvalRejected,
                  sourceDate: lastActionAt,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(lastActionAt),
                  requestId: requestId,
                  userEmail: currentUserEmail,
                ));
              }
            }

            // ── THE REQUESTER'S OWN REQUEST ──────────────────────────────
            //
            // ADDED 30/8/2026. Every branch above is keyed on the signed-in
            // user being IN the approval cycle, and the loop `continue`d when
            // they were not — so the person who RAISED the request saw
            // nothing on their calendar at any point: not while it waited, not
            // when it was approved, not when it was rejected. The Services
            // builder does not cover the gap either; it starts at
            // `assignedToProvider` (provider only) and its requester cards
            // need a duration and an InProgress status, so a request that is
            // still in, or was refused by, the approval cycle produces no
            // calendar entry for its own author.
            //
            // The outcome is read from the live cycle as a whole, the same
            // rule `_getFinalStateFromModel` applies: any rejection decides
            // the request, otherwise it is approved only once every step has
            // approved.
            if (isRequester) {
              final List<String> states = approvalCycle
                  .map((Map<String, String> e) => e['state'] ?? '')
                  .toList();

              final bool anyRejected = states.contains('rejected');
              final bool allApproved = states.isNotEmpty &&
                  states.every((String state) => state == 'approved');

              if (anyRejected) {
                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.approvalRejected,
                  sourceDate: lastActionAt,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(lastActionAt),
                  requestId: requestId,
                  userEmail: currentUserEmail,
                ));
              } else if (allApproved) {
                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.approvalApproved,
                  sourceDate: lastActionAt,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(lastActionAt),
                  requestId: requestId,
                  userEmail: currentUserEmail,
                ));
              } else {
                // Still moving through the cycle: the requester gets the
                // submission itself, dated when they raised it, so an
                // outstanding request is visible to the person waiting on it.
                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.pendingApproval,
                  sourceDate: submittedAt,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(submittedAt),
                  requestId: requestId,
                  userEmail: currentUserEmail,
                ));
              }
            }

          } catch (e) {
          }
        }

      } catch (timeoutError) {
        return events;
      }


    } catch (e, stackTrace) {
    }

    return events;
  }
















  // ══════════════════════════════════════════════════════════════════
  //  ROLE MANAGEMENT
  //
  //  Source: `User_Management/{employeeId}` - a UserPermissionHistoryModel.
  //  Role / From_Date / To_Date are HISTORY LISTS: the current value is the
  //  last entry, and a list longer than one entry means the date was moved,
  //  which is what the "... Date Updated" spec entries describe.
  //  Dates are stored as `MMM dd, yyyy` (Constants.userAccessDateFormat).
  // ══════════════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════════════════
  //  GRC MODULE  —  activation-date entries
  // ══════════════════════════════════════════════════════════════════════

  /// The three GRC Module rows of the calendar spec, all driven by a module's
  /// activation date:
  ///
  ///   * [GrcModuleCalendarEvent.activationDateDefined]  on the date itself
  ///   * [GrcModuleCalendarEvent.activationIn14Days]     14 days before
  ///   * [GrcModuleCalendarEvent.activationDateUpdated]  when the date moved
  ///
  /// DERIVED, NEVER STORED — like every other source in this file. The spec
  /// says the calendar entry is "created immediately after saving the
  /// Activation Date" and that an existing entry "is updated automatically";
  /// deriving on read gives both for free, because the cards are recomputed
  /// from the module document each time the calendar opens. Nothing has to be
  /// written, found, or rescheduled.
  ///
  /// AUDIENCE: the module's current owners. A module nobody owns puts nothing
  /// on anybody's calendar, which is why an empty result is not necessarily a
  /// fault — see the logging below.
  Future<List<CalendarEventModel>> getGrcCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];

    if (currentUserEmail.isEmpty) {
      debugPrint('[grc-cal] no signed-in email — nothing to build.');
      return events;
    }

    try {
      final bool isArabic = languageCode() == 'ar';
      final DateFormat fmt = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');
      final DateTime today = DateTime.now();
      final DateTime startOfToday = DateTime(today.year, today.month, today.day);

      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection(GrcFirebasePaths.modulesCollection).get();

      int owned = 0;
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in snapshot.docs) {
        final GRCModuleModel model;
        try {
          model = GRCModuleModel.fromJson(doc.data());
        } catch (e) {
          debugPrint('[grc-cal] skipped ${doc.id} — unreadable document: $e');
          continue;
        }

        final GRCModuleEntity entity = model.toEntity();

        // Only the people responsible for the module get its dates.
        if (!entity.moduleOwners.contains(currentUserEmail)) continue;

        // A removed module keeps its activation date, but it is not going to
        // activate — its cards would be noise.
        if (entity.isRemoved) continue;
        owned++;

        final String name =
            isArabic ? entity.moduleNameAr : entity.moduleNameEn;
        final DateTime activation = entity.moduleActivationDate;
        final String activationText = fmt.format(activation);

        // ── On the activation date ────────────────────────────────────────
        events.add(
          CalendarEventModel.fromType(
            GrcModuleCalendarEvent.activationDateDefined,
            sourceDate: activation,
            isArabic: isArabic,
            // The card's title is the module this event is about.
            taskName: name,
            // `time` was omitted here, so it defaulted to ''. DayTimelineView
            // buckets cards by parsing this string, and an unparseable one was
            // dropped — the day view showed "1 events" in its header (which
            // counts the list) with an empty hour grid, while the month view,
            // which only reads `date`, was fine. Every other builder in this
            // file passes hh:mm a; an activation date is date-only, so this
            // resolves to 12:00 AM exactly like the role-management cards.
            time: DateFormat('hh:mm a').format(activation),
            requestId: entity.moduleId,
            userEmail: currentUserEmail,
            variables: <TemplateVariable, String>{
              TemplateVariable.moduleName: name,
              TemplateVariable.activationDate: activationText,
            },
          ),
        );

        // ── 14 days before ────────────────────────────────────────────────
        //
        // Skipped once that day has passed: a module created inside its own
        // 14-day window would otherwise get a reminder dated in the past,
        // which reads as a missed deadline rather than advance notice.
        final DateTime reminderDay =
            GrcModuleCalendarEvent.activationIn14Days.dateFor(activation);
        if (!reminderDay.isBefore(startOfToday)) {
          events.add(
            CalendarEventModel.fromType(
              GrcModuleCalendarEvent.activationIn14Days,
              sourceDate: activation,
              isArabic: isArabic,
              taskName: name,
              time: DateFormat('hh:mm a').format(reminderDay),
              requestId: entity.moduleId,
              userEmail: currentUserEmail,
              variables: <TemplateVariable, String>{
                TemplateVariable.moduleName: name,
                TemplateVariable.activationDate: activationText,
              },
            ),
          );
        }

        // ── Date moved ────────────────────────────────────────────────────
        //
        // Module_Activation_Date is a history list, so a change is the last
        // two entries differing — the same comparison
        // getRoleManagementCalendarEvents makes on From_Date / To_Date.
        final List<DateTime> history = model.moduleActivationDate;
        if (history.length >= 2) {
          final DateTime previous = history[history.length - 2];
          if (!_isSameDay(previous, activation)) {
            events.add(
              CalendarEventModel.fromType(
                GrcModuleCalendarEvent.activationDateUpdated,
                sourceDate: activation,
                isArabic: isArabic,
                taskName: name,
                time: DateFormat('hh:mm a').format(activation),
                requestId: entity.moduleId,
                userEmail: currentUserEmail,
                variables: <TemplateVariable, String>{
                  TemplateVariable.moduleName: name,
                  TemplateVariable.oldActivationDate: fmt.format(previous),
                  TemplateVariable.newActivationDate: activationText,
                },
              ),
            );
          }
        }
      }

      // Same reasoning as the role builder: an empty list has several
      // innocent causes, and from the calendar they all look like a broken
      // module. Name which one it was.
      debugPrint(
        '[grc-cal] ${snapshot.docs.length} module(s) scanned, '
        '$owned owned by "$currentUserEmail", '
        '${events.length} card(s) built.',
      );
    } catch (e, stackTrace) {
      debugPrint('[grc-cal] build FAILED — $e\n$stackTrace');
    }

    return events;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  GRC POLICY  —  start / end date entries
  // ══════════════════════════════════════════════════════════════════════

  /// The six GRC Policy rows of the calendar spec, all driven by a policy's
  /// Start Date and End Date:
  ///
  ///   * [GrcPolicyCalendarEvent.startDateReached]   on the start date
  ///   * [GrcPolicyCalendarEvent.startDateUpdated]   when that date moved
  ///   * [GrcPolicyCalendarEvent.endDateDefined]     on the end date
  ///   * [GrcPolicyCalendarEvent.expiresIn14Days]    14 days before it
  ///   * [GrcPolicyCalendarEvent.expiresToday]       on the end date
  ///   * [GrcPolicyCalendarEvent.endDateUpdated]     when THAT date moved
  ///
  /// DERIVED, NEVER STORED — same as [getGrcCalendarEvents]. The spec's
  /// "entry is created immediately" and "existing entry is updated
  /// automatically" both come free: the cards are recomputed from the policy
  /// document every time the calendar opens, so a moved date simply stops
  /// producing its old cards.
  ///
  /// AUDIENCE: the owners of the policy's MODULE. A policy has no owners of
  /// its own, and the module owners are exactly who [getGrcCalendarEvents]
  /// already shows module dates to — so GRC stays one audience.
  ///
  /// SHAPE: policies live in a subcollection under each module, so this walks
  /// the modules the user owns and reads each one's policies. That is one
  /// read per owned module rather than a collection-group query, which keeps
  /// the owner filter on the module document where it already works.
  Future<List<CalendarEventModel>> getGrcPolicyCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];

    if (currentUserEmail.isEmpty) {
      debugPrint('[grc-policy-cal] no signed-in email — nothing to build.');
      return events;
    }

    try {
      final bool isArabic = languageCode() == 'ar';
      final DateFormat fmt = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');
      final DateFormat clock = DateFormat('hh:mm a');
      final DateTime today = DateTime.now();
      final DateTime startOfToday = DateTime(today.year, today.month, today.day);

      final QuerySnapshot<Map<String, dynamic>> modules =
          await FirebaseFirestore.instance.collection(GrcFirebasePaths.modulesCollection).get();

      int ownedModules = 0;
      int policiesScanned = 0;

      for (final QueryDocumentSnapshot<Map<String, dynamic>> moduleDoc
          in modules.docs) {
        final GRCModuleModel moduleModel;
        try {
          moduleModel = GRCModuleModel.fromJson(moduleDoc.data());
        } catch (e) {
          debugPrint(
              '[grc-policy-cal] skipped module ${moduleDoc.id} — unreadable: $e');
          continue;
        }

        final GRCModuleEntity module = moduleModel.toEntity();
        if (!module.moduleOwners.contains(currentUserEmail)) continue;
        if (module.isRemoved) continue;
        ownedModules++;

        // 'Policies' — the same subcollection name PolicyFirebaseDataSource
        // writes to.
        final QuerySnapshot<Map<String, dynamic>> policies =
            await moduleDoc.reference.collection('Policies').get();

        for (final QueryDocumentSnapshot<Map<String, dynamic>> policyDoc
            in policies.docs) {
          final PolicyModel policyModel;
          try {
            policyModel = PolicyModel.fromJson(policyDoc.data());
          } catch (e) {
            debugPrint(
                '[grc-policy-cal] skipped policy ${policyDoc.id} — unreadable: $e');
            continue;
          }

          final PolicyEntity policy = policyModel.toEntity();

          // A removed policy keeps its dates but is not going to activate or
          // expire; its cards would be noise. A draft has not been published
          // yet, so its dates are not commitments either.
          if (policy.status == PolicyStatus.removed ||
              policy.status == PolicyStatus.draft) {
            continue;
          }
          policiesScanned++;

          final String name =
              isArabic ? policy.policyNameAr : policy.policyNameEn;
          final DateTime start = policy.startDate;
          final DateTime end = policy.endDate;
          final String startText = fmt.format(start);
          final String endText = fmt.format(end);

          // ── Start date ────────────────────────────────────────────────
          events.add(
            CalendarEventModel.fromType(
              GrcPolicyCalendarEvent.startDateReached,
              sourceDate: start,
              isArabic: isArabic,
              taskName: name,
              // Date-only, so this resolves to 12:00 AM. DayTimelineView
              // buckets by parsing this string and drops an unparseable one —
              // see the note in getGrcCalendarEvents.
              time: clock.format(start),
              requestId: policy.id,
              userEmail: currentUserEmail,
              variables: <TemplateVariable, String>{
                TemplateVariable.policyName: name,
                TemplateVariable.startDate: startText,
              },
            ),
          );

          // ── Start date moved ──────────────────────────────────────────
          //
          // startDate is a history list, so a change is the last two entries
          // differing — the same comparison getGrcCalendarEvents makes on
          // Module_Activation_Date.
          final List<DateTime> startHistory = policyModel.startDate;
          if (startHistory.length >= 2) {
            final DateTime previousStart = startHistory[startHistory.length - 2];
            if (!_isSameDay(previousStart, start)) {
              events.add(
                CalendarEventModel.fromType(
                  GrcPolicyCalendarEvent.startDateUpdated,
                  sourceDate: start,
                  isArabic: isArabic,
                  taskName: name,
                  time: clock.format(start),
                  requestId: policy.id,
                  userEmail: currentUserEmail,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.policyName: name,
                    TemplateVariable.oldStartDate: fmt.format(previousStart),
                    TemplateVariable.newStartDate: startText,
                  },
                ),
              );
            }
          }

          // ── End date defined ──────────────────────────────────────────
          events.add(
            CalendarEventModel.fromType(
              GrcPolicyCalendarEvent.endDateDefined,
              sourceDate: end,
              isArabic: isArabic,
              taskName: name,
              time: clock.format(end),
              requestId: policy.id,
              userEmail: currentUserEmail,
              variables: <TemplateVariable, String>{
                TemplateVariable.policyName: name,
                TemplateVariable.endDate: endText,
              },
            ),
          );

          // ── Expires today ─────────────────────────────────────────────
          //
          // Only on the day itself. Without this guard it would be a second
          // permanent card on the same square as endDateDefined, for every
          // policy, forever — the spec wants "it is today", not "it will be".
          if (_isSameDay(end, startOfToday)) {
            events.add(
              CalendarEventModel.fromType(
                GrcPolicyCalendarEvent.expiresToday,
                sourceDate: end,
                isArabic: isArabic,
                taskName: name,
                time: clock.format(end),
                requestId: policy.id,
                userEmail: currentUserEmail,
                variables: <TemplateVariable, String>{
                  TemplateVariable.policyName: name,
                  TemplateVariable.endDate: endText,
                },
              ),
            );
          }

          // ── 14 days before expiry ─────────────────────────────────────
          //
          // Skipped once that day has passed: a policy created inside its own
          // 14-day window would otherwise get a reminder dated in the past,
          // which reads as a missed deadline rather than advance notice.
          final DateTime expiryReminderDay =
              GrcPolicyCalendarEvent.expiresIn14Days.dateFor(end);
          if (!expiryReminderDay.isBefore(startOfToday)) {
            events.add(
              CalendarEventModel.fromType(
                GrcPolicyCalendarEvent.expiresIn14Days,
                sourceDate: end,
                isArabic: isArabic,
                taskName: name,
                time: clock.format(expiryReminderDay),
                requestId: policy.id,
                userEmail: currentUserEmail,
                variables: <TemplateVariable, String>{
                  TemplateVariable.policyName: name,
                  TemplateVariable.endDate: endText,
                },
              ),
            );
          }

          // ── End date moved ────────────────────────────────────────────
          final List<DateTime> endHistory = policyModel.endDate;
          if (endHistory.length >= 2) {
            final DateTime previousEnd = endHistory[endHistory.length - 2];
            if (!_isSameDay(previousEnd, end)) {
              events.add(
                CalendarEventModel.fromType(
                  GrcPolicyCalendarEvent.endDateUpdated,
                  sourceDate: end,
                  isArabic: isArabic,
                  taskName: name,
                  time: clock.format(end),
                  requestId: policy.id,
                  userEmail: currentUserEmail,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.policyName: name,
                    TemplateVariable.oldEndDate: fmt.format(previousEnd),
                    TemplateVariable.newEndDate: endText,
                  },
                ),
              );
            }
          }
        }
      }

      // Same reasoning as the module builder: an empty list has several
      // innocent causes (no owned module, no policies, every policy draft or
      // removed) and from the calendar they all look identical. Name which.
      debugPrint(
        '[grc-policy-cal] ${modules.docs.length} module(s) scanned, '
        '$ownedModules owned by "$currentUserEmail", '
        '$policiesScanned policy(ies) eligible, '
        '${events.length} card(s) built.',
      );
    } catch (e, stackTrace) {
      debugPrint('[grc-policy-cal] build FAILED — $e\n$stackTrace');
    }

    return events;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  GRC CONTROL  —  control, champion, owner and reassignment entries
  // ══════════════════════════════════════════════════════════════════════

  /// Every [GrcControlCalendarEvent] row of the calendar spec, derived on read
  /// (never stored) like the module and policy builders above:
  ///
  ///   MODULE OWNERS
  ///   * controlStartDateReached         a control's start date, that day
  ///   * champion/ownerReassignmentPending  a pending request's start date
  ///
  ///   ASSIGNED CHAMPION (Control Champions/{email})
  ///   * championStartDateDefined / championAssignmentStartDateReached
  ///   * championStartDateUpdated
  ///   * submissionDueDateDefined / DueIn14Days / DueToday / Overdue
  ///   * submissionDueDateUpdated
  ///
  ///   ASSIGNED OWNER (Control Owners/{email})
  ///   * ownerStartDateDefined / ownerAssignmentStartDateReached
  ///   * ownerStartDateUpdated
  ///
  ///   NEW ASSIGNEE OF AN APPROVED REASSIGNMENT REQUEST
  ///   * champion/ownerReassignmentApproved, …StartDateReached,
  ///     …AssignmentEndsToday
  ///
  /// SOURCE DATES: assignment start = control Start Date; submission due =
  /// control End Date (the rule computeAssignmentControlTab already uses);
  /// reassignments use the request's own Start / End Date.
  ///
  /// COST: per module — the user's champion doc, owner doc, the Requests
  /// collection and one Assignment Controls query; then one Controls read per
  /// policy the user owns or is assigned to.
  Future<List<CalendarEventModel>> getGrcControlCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];

    if (currentUserEmail.isEmpty) {
      debugPrint('[grc-control-cal] no signed-in email — nothing to build.');
      return events;
    }

    try {
      final bool isArabic = languageCode() == 'ar';
      final DateFormat fmt = DateFormat('d MMM yyyy', isArabic ? 'ar' : 'en');
      final DateFormat clock = DateFormat('hh:mm a');
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

      CalendarEventModel card(
        GrcControlCalendarEvent type, {
        required DateTime sourceDate,
        required String name,
        required String id,
        required Map<TemplateVariable, String> variables,
      }) =>
          CalendarEventModel.fromType(
            type,
            sourceDate: sourceDate,
            isArabic: isArabic,
            taskName: name,
            // Date-only → 12:00 AM. DayTimelineView drops an unparseable
            // time; see the note in getGrcCalendarEvents.
            time: clock.format(type.dateFor(sourceDate)),
            requestId: id,
            userEmail: currentUserEmail,
            variables: variables,
          );

      final QuerySnapshot<Map<String, dynamic>> modules =
          await FirebaseFirestore.instance.collection(GrcFirebasePaths.modulesCollection).get();

      int modulesUsed = 0;

      for (final QueryDocumentSnapshot<Map<String, dynamic>> moduleDoc
          in modules.docs) {
        final GRCModuleEntity module;
        try {
          module = GRCModuleModel.fromJson(moduleDoc.data()).toEntity();
        } catch (e) {
          debugPrint(
              '[grc-control-cal] skipped module ${moduleDoc.id} — unreadable: $e');
          continue;
        }
        if (module.isRemoved) continue;

        final bool isModuleOwner =
            module.moduleOwners.contains(currentUserEmail);
        final DocumentReference<Map<String, dynamic>> moduleRef =
            moduleDoc.reference;

        // ── Who is the user in this module? ───────────────────────────────
        List<AssigningControlEntity> championPairs =
            const <AssigningControlEntity>[];
        List<AssigningControlEntity> ownerPairs =
            const <AssigningControlEntity>[];
        try {
          final championDoc = await moduleRef
              .collection('Control Champions')
              .doc(currentUserEmail)
              .get();
          final Map<String, dynamic>? data = championDoc.data();
          if (data != null) {
            final ChampionEntity champion =
                ChampionModel.fromJson(data).toEntity();
            if (champion.status != ChampionStatus.removed) {
              championPairs = champion.assigningControls;
            }
          }
          final ownerDoc = await moduleRef
              .collection('Control Owners')
              .doc(currentUserEmail)
              .get();
          final Map<String, dynamic>? ownerData = ownerDoc.data();
          if (ownerData != null) {
            final OwnerEntity owner = OwnerModel.fromJson(ownerData).toEntity();
            if (owner.status != OwnerStatus.removed) {
              ownerPairs = owner.assigningControls;
            }
          }
        } catch (e) {
          debugPrint('[grc-control-cal] assignee read failed '
              '(${module.moduleId}): $e');
        }

        // ── Reassignment requests ─────────────────────────────────────────
        final List<GrcRequestEntity> requests = <GrcRequestEntity>[];
        try {
          final snapshot = await moduleRef.collection('Requests').get();
          for (final doc in snapshot.docs) {
            try {
              final GrcRequestEntity request =
                  GrcRequestModel.fromJson(doc.data()).toEntity();
              if (request.type.isReassignment) requests.add(request);
            } catch (_) {}
          }
        } catch (e) {
          debugPrint('[grc-control-cal] requests read failed '
              '(${module.moduleId}): $e');
        }

        final bool hasRequestForMe = requests.any((GrcRequestEntity r) =>
            r.status == ApprovalStatus.approved &&
            (r.newChampionEmail == currentUserEmail ||
                r.newOwnerEmail == currentUserEmail));
        final bool hasPendingForApproval = isModuleOwner &&
            requests.any((GrcRequestEntity r) =>
                r.status == ApprovalStatus.pending &&
                r.requestedBy != currentUserEmail);

        if (!isModuleOwner &&
            championPairs.isEmpty &&
            ownerPairs.isEmpty &&
            !hasRequestForMe &&
            !hasPendingForApproval) {
          continue;
        }
        modulesUsed++;

        // ── Controls the user needs, keyed "<policy>/<control>" ───────────
        final Set<String> neededPolicies = <String>{
          ...championPairs.map((AssigningControlEntity a) => a.policyId),
          ...ownerPairs.map((AssigningControlEntity a) => a.policyId),
          for (final GrcRequestEntity r in requests)
            ...?r.controls?.map((AssigningControlEntity a) => a.policyId),
        };
        final Map<String, ControlModel> controlModels =
            <String, ControlModel>{};
        try {
          final policies = await moduleRef.collection('Policies').get();
          for (final policyDoc in policies.docs) {
            if (!isModuleOwner && !neededPolicies.contains(policyDoc.id)) {
              continue;
            }
            final PolicyEntity policy;
            try {
              policy = PolicyModel.fromJson(policyDoc.data()).toEntity();
            } catch (_) {
              continue;
            }
            if (policy.status == PolicyStatus.removed ||
                policy.status == PolicyStatus.draft) {
              continue;
            }
            final controls =
                await policyDoc.reference.collection('Controls').get();
            for (final controlDoc in controls.docs) {
              try {
                controlModels['${policyDoc.id}/${controlDoc.id}'] =
                    ControlModel.fromJson(controlDoc.data());
              } catch (_) {}
            }
          }
        } catch (e) {
          debugPrint('[grc-control-cal] controls read failed '
              '(${module.moduleId}): $e');
        }

        String nameOf(ControlEntity c) =>
            isArabic && c.controlsNameAr.isNotEmpty
                ? c.controlsNameAr
                : c.controlsNameEn;
        bool isLive(ControlEntity c) =>
            c.status != ControlStatus.draft &&
            c.status != ControlStatus.inactive;

        // ── Module owners: control start date ─────────────────────────────
        if (isModuleOwner) {
          for (final MapEntry<String, ControlModel> entry
              in controlModels.entries) {
            final ControlEntity control = entry.value.toEntity();
            if (!isLive(control)) continue;
            if (dayOf(control.startDate) != today) continue;
            events.add(card(
              GrcControlCalendarEvent.controlStartDateReached,
              sourceDate: control.startDate,
              name: nameOf(control),
              id: control.id,
              variables: <TemplateVariable, String>{
                TemplateVariable.controlName: nameOf(control),
              },
            ));
          }
        }

        // ── Submission status for the champion's controls ─────────────────
        final Set<String> submittedControls = <String>{};
        if (championPairs.isNotEmpty) {
          try {
            final snapshot = await moduleRef
                .collection('Assignment Controls')
                .where('Control_Champion_Email', isEqualTo: currentUserEmail)
                .get();
            for (final doc in snapshot.docs) {
              try {
                // Compared on the stored value rather than
                // AssignmentControlStatus, whose file pulls Material into
                // this data layer (CR-SKEL-CAL-N02-DATA).
                final AssignmentControlModel a =
                    AssignmentControlModel.fromJson(doc.data());
                final String status =
                    a.status.isEmpty ? '' : a.status.last.toLowerCase();
                if (status == 'submitted' ||
                    status == 'in review' ||
                    status == 'approved') {
                  submittedControls.add(a.controlId);
                }
              } catch (_) {}
            }
          } catch (e) {
            debugPrint('[grc-control-cal] submissions read failed '
                '(${module.moduleId}): $e');
          }
        }

        // ── Assigned champion / owner ─────────────────────────────────────
        void assignee(
          List<AssigningControlEntity> pairs, {
          required bool champion,
        }) {
          for (final AssigningControlEntity pair in pairs) {
            final ControlModel? model =
                controlModels['${pair.policyId}/${pair.controlId}'];
            if (model == null) continue;
            final ControlEntity control = model.toEntity();
            if (!isLive(control)) continue;
            final String name = nameOf(control);
            final DateTime start = control.startDate;
            final Map<TemplateVariable, String> nameOnly =
                <TemplateVariable, String>{TemplateVariable.controlName: name};

            // Start date defined — while the start is today or ahead.
            if (!dayOf(start).isBefore(today)) {
              events.add(card(
                champion
                    ? GrcControlCalendarEvent.championStartDateDefined
                    : GrcControlCalendarEvent.ownerStartDateDefined,
                sourceDate: start,
                name: name,
                id: control.id,
                variables: <TemplateVariable, String>{
                  TemplateVariable.controlName: name,
                  TemplateVariable.startDate: fmt.format(start),
                },
              ));
            }
            // Start date reached — on that day only.
            if (dayOf(start) == today) {
              events.add(card(
                champion
                    ? GrcControlCalendarEvent.championAssignmentStartDateReached
                    : GrcControlCalendarEvent.ownerAssignmentStartDateReached,
                sourceDate: start,
                name: name,
                id: control.id,
                variables: nameOnly,
              ));
            }
            // Start date moved — startDate is a history list.
            if (model.startDate.length >= 2) {
              final DateTime previous =
                  model.startDate[model.startDate.length - 2];
              if (!_isSameDay(previous, start)) {
                events.add(card(
                  champion
                      ? GrcControlCalendarEvent.championStartDateUpdated
                      : GrcControlCalendarEvent.ownerStartDateUpdated,
                  sourceDate: start,
                  name: name,
                  id: control.id,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.controlName: name,
                    TemplateVariable.oldStartDate: fmt.format(previous),
                    TemplateVariable.newStartDate: fmt.format(start),
                  },
                ));
              }
            }

            if (!champion) continue;

            // ── Submission due date (champions only) ────────────────────
            final DateTime due = control.endDate;
            final Map<TemplateVariable, String> dueVars =
                <TemplateVariable, String>{
              TemplateVariable.controlName: name,
              TemplateVariable.dueDate: fmt.format(due),
            };
            final bool submitted = submittedControls.contains(control.id);

            if (model.endDate.length >= 2) {
              final DateTime previousDue =
                  model.endDate[model.endDate.length - 2];
              if (!_isSameDay(previousDue, due)) {
                events.add(card(
                  GrcControlCalendarEvent.submissionDueDateUpdated,
                  sourceDate: due,
                  name: name,
                  id: control.id,
                  variables: <TemplateVariable, String>{
                    TemplateVariable.controlName: name,
                    TemplateVariable.oldEndDate: fmt.format(previousDue),
                    TemplateVariable.newEndDate: fmt.format(due),
                  },
                ));
              }
            }
            if (submitted) continue;

            events.add(card(
              GrcControlCalendarEvent.submissionDueDateDefined,
              sourceDate: due,
              name: name,
              id: control.id,
              variables: dueVars,
            ));
            final DateTime reminderDay = dayOf(
                GrcControlCalendarEvent.submissionDueIn14Days.dateFor(due));
            if (!reminderDay.isBefore(today)) {
              events.add(card(
                GrcControlCalendarEvent.submissionDueIn14Days,
                sourceDate: due,
                name: name,
                id: control.id,
                variables: dueVars,
              ));
            }
            if (dayOf(due) == today) {
              events.add(card(
                GrcControlCalendarEvent.submissionDueToday,
                sourceDate: due,
                name: name,
                id: control.id,
                variables: dueVars,
              ));
            }
            if (dayOf(due).isBefore(today)) {
              events.add(card(
                GrcControlCalendarEvent.submissionOverdue,
                sourceDate: due,
                name: name,
                id: control.id,
                variables: dueVars,
              ));
            }
          }
        }

        assignee(championPairs, champion: true);
        assignee(ownerPairs, champion: false);

        // ── Reassignment requests ─────────────────────────────────────────
        for (final GrcRequestEntity request in requests) {
          final DateTime? start = request.startDate;
          if (start == null) continue;
          final bool isChampionRequest =
              request.type == GrcRequestType.reassignChampion;
          final List<AssigningControlEntity> pairs =
              request.controls ?? const <AssigningControlEntity>[];

          for (final AssigningControlEntity pair in pairs) {
            final ControlModel? model =
                controlModels['${pair.policyId}/${pair.controlId}'];
            if (model == null) continue;
            final ControlEntity control = model.toEntity();
            final String name = nameOf(control);

            // Approvers — while pending.
            if (request.status == ApprovalStatus.pending &&
                isModuleOwner &&
                request.requestedBy != currentUserEmail) {
              events.add(card(
                isChampionRequest
                    ? GrcControlCalendarEvent.championReassignmentPending
                    : GrcControlCalendarEvent.ownerReassignmentPending,
                sourceDate: start,
                name: name,
                id: request.id,
                variables: <TemplateVariable, String>{
                  TemplateVariable.requesterName:
                      FormatHelper.formatEmailToName(request.requestedBy),
                  TemplateVariable.controlName: name,
                  TemplateVariable.startDate: fmt.format(start),
                },
              ));
            }

            // The incoming assignee — once approved.
            final String? incoming = isChampionRequest
                ? request.newChampionEmail
                : request.newOwnerEmail;
            if (request.status != ApprovalStatus.approved ||
                incoming != currentUserEmail) {
              continue;
            }
            if (!dayOf(start).isBefore(today)) {
              events.add(card(
                isChampionRequest
                    ? GrcControlCalendarEvent.championReassignmentApproved
                    : GrcControlCalendarEvent.ownerReassignmentApproved,
                sourceDate: start,
                name: name,
                id: request.id,
                variables: <TemplateVariable, String>{
                  TemplateVariable.controlName: name,
                  TemplateVariable.startDate: fmt.format(start),
                },
              ));
            }
            if (dayOf(start) == today) {
              events.add(card(
                isChampionRequest
                    ? GrcControlCalendarEvent.championStartDateReached
                    : GrcControlCalendarEvent.ownerStartDateReached,
                sourceDate: start,
                name: name,
                id: request.id,
                variables: <TemplateVariable, String>{
                  TemplateVariable.controlName: name,
                },
              ));
            }
            final DateTime? end = request.endDate;
            if (end != null && dayOf(end) == today) {
              events.add(card(
                isChampionRequest
                    ? GrcControlCalendarEvent.championAssignmentEndsToday
                    : GrcControlCalendarEvent.ownerAssignmentEndsToday,
                sourceDate: end,
                name: name,
                id: request.id,
                variables: <TemplateVariable, String>{
                  TemplateVariable.controlName: name,
                },
              ));
            }
          }
        }
      }

      debugPrint(
        '[grc-control-cal] ${modules.docs.length} module(s) scanned, '
        '$modulesUsed relevant to "$currentUserEmail", '
        '${events.length} card(s) built.',
      );
    } catch (e, stackTrace) {
      debugPrint('[grc-control-cal] build FAILED — $e\n$stackTrace');
    }

    return events;
  }

  Future<List<CalendarEventModel>> getRoleManagementCalendarEvents({
    required String currentUserEmail,
  }) async {
    final events = <CalendarEventModel>[];

    // ── WHY THIS BUILDER LOGS AT ALL ─────────────────────────────────────
    //
    // ADDED 1/9/2026, answering "the role calendar doesn't work".
    //
    // Every branch below ends in a bare `return events`, and there are SIX of
    // them: no signed-in email, no directory record, no permission document,
    // null data, no role, and — the quiet one — a role whose From_Date and
    // To_Date are both unparseable. All six produce an identical, correct,
    // completely silent empty list. From the calendar all six look the same as
    // "this module is broken", and none of them could be told apart from the
    // outside.
    //
    // Nothing about the logic changed here; each exit just says which gate it
    // was. One run with the debug console open now names the cause instead of
    // leaving it to be guessed at.
    //
    // Worth knowing before reading a log: all seven §2 Role Management rows
    // hang off {AccessGrantedDate} or {AccessRevokedDate}. A role held with no
    // dates set produces no cards AND no error — that is the spec working as
    // written, not a fault. Equally, a role granted last year puts its single
    // `accessGrantedImmediate` card on last year's date, so an empty CURRENT
    // month is not the same thing as an empty source. The summary line at the
    // end prints the dates the cards were placed on for exactly that reason.
    if (currentUserEmail.isEmpty) {
      debugPrint('[role-cal] no signed-in email — nothing to build.');
      return events;
    }

    try {
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';

      // The permission document is keyed by employee id, so resolve the id
      // for the signed-in email first. See [_employeeDocForEmail] for why this
      // is a query and not a scan.
      final employeeDoc = await _employeeDocForEmail(currentUserEmail);
      if (employeeDoc == null) {
        debugPrint(
          '[role-cal] no Employees_Info record matched "$currentUserEmail" — '
          'the calendar cannot resolve an employee id, so it cannot find the '
          'permission document. Check the Email field on that record.',
        );
        return events;
      }
      final String employeeId = employeeDoc.id;

      final permissionDoc = await FirebaseFirestore.instance
          .collection(getBaseUrl('User_Management'))
          .doc(employeeId)
          .get()
          .timeout(_employeeLookupTimeout);

      if (!permissionDoc.exists) {
        debugPrint(
          '[role-cal] no User_Management document for employee "$employeeId" '
          '($currentUserEmail). This user has never been given a role through '
          'User Management, so there is nothing to put on the calendar.',
        );
        return events;
      }
      final data = permissionDoc.data();
      if (data == null) {
        debugPrint('[role-cal] User_Management/$employeeId exists but is empty.');
        return events;
      }

      final roles = _historyList(data['Role']);
      final fromDates = _historyList(data['From_Date']);
      final toDates = _historyList(data['To_Date']);
      if (roles.isEmpty) {
        debugPrint(
          '[role-cal] User_Management/$employeeId has no Role history.',
        );
        return events;
      }

      final roleName = roles.last;
      final from = _parseAccessDate(fromDates.isNotEmpty ? fromDates.last : '');
      final to = _parseAccessDate(toDates.isNotEmpty ? toDates.last : '');

      if (from == null && to == null) {
        // The quiet one. Both dates missing is normal (a role granted with no
        // window); both dates PRESENT but unparseable is a data problem, and
        // the two are indistinguishable without seeing the raw strings — so
        // the raw strings are what gets printed.
        final String rawFrom =
            fromDates.isEmpty ? '(none)' : '"${fromDates.last}"';
        final String rawTo = toDates.isEmpty ? '(none)' : '"${toDates.last}"';
        debugPrint(
          '[role-cal] role "$roleName" on $employeeId has no usable dates — '
          'From_Date=$rawFrom, To_Date=$rawTo. Every §2 Role Management entry '
          'is dated off one of these two, so no card can be placed. Expected '
          'format: "MMM dd, yyyy" (Constants.userAccessDateFormat).',
        );
        return events;
      }

      void add(RoleManagementCalendarEvent type, DateTime source) {
        events.add(CalendarEventModel.fromType(
          type,
          sourceDate: source,
          isArabic: isArabic,
          taskName: roleName,
          time: DateFormat('hh:mm a').format(source),
          userEmail: currentUserEmail,
          variables: {
            TemplateVariable.accessGrantedDate:
                DateTimeHelper.formatDateTimeMMMDDYYYY(from),
            TemplateVariable.accessRevokedDate:
                DateTimeHelper.formatDateTimeMMMDDYYYY(to),
          },
        ));
      }

      final DateTime now = DateTime.now();

      if (from != null) {
        // ── The access window opens ──────────────────────────────────────
        //
        // FIXED 30/8/2026. `accessGrantedImmediate` and `accessStartsToday`
        // were BOTH added unconditionally, on the same `from` date — so every
        // user with a role saw two cards saying the same thing on the same
        // day. The spec separates them by how the access was granted:
        //
        //   "Access Granted (Immediate)"  — access is live now; the entry is
        //                                   created the moment it is granted.
        //   "Access Starts Today"         — a SCHEDULED start date has been
        //                                   reached and the access becomes
        //                                   active today.
        //
        // so they are mutually exclusive, and only one can be true of a given
        // start date. A future start date is neither yet: it is the scheduled
        // reminder, and nothing else.
        final bool startsInFuture = from.isAfter(now);
        final bool startsToday = _isSameDay(from, now);

        if (startsInFuture) {
          // Only the advance reminder. The enum applies the -14 day offset
          // itself (`CalendarEventTypeX.dateFor`), so the source date passed
          // here is the start date, not the reminder date.
          add(RoleManagementCalendarEvent.accessScheduled14DaysBeforeStart,
              from);
        } else if (startsToday) {
          add(RoleManagementCalendarEvent.accessStartsToday, from);
        } else {
          add(RoleManagementCalendarEvent.accessGrantedImmediate, from);
        }

        // More than one entry means the start date was moved.
        if (fromDates.length > 1 && fromDates.last != fromDates[fromDates.length - 2]) {
          add(RoleManagementCalendarEvent.accessGrantedDateUpdated, from);
        }
      }

      if (to != null) {
        // The expiry reminder is an ADVANCE warning — it says "expiring
        // soon", so it is meaningless once the date has passed. The expiry
        // itself always lands.
        if (to.isAfter(now)) {
          add(RoleManagementCalendarEvent.accessExpiringIn14Days, to);
        }
        add(RoleManagementCalendarEvent.accessRevokedExpiryDateReached, to);
        if (toDates.length > 1 && toDates.last != toDates[toDates.length - 2]) {
          add(RoleManagementCalendarEvent.accessRevokedDateUpdated, to);
        }
      }

      // What actually got built, and WHERE. The dates matter as much as the
      // count: these entries are placed on the access dates themselves, so a
      // role granted a year ago puts its card a year back and the current
      // month is legitimately empty. A non-zero count here with nothing on
      // screen means the cards are outside the month being viewed — a
      // different problem from this source returning nothing.
      final List<String> placed = <String>[];
      for (final CalendarEventModel event in events) {
        final String key = event.type?.key ?? event.status;
        placed.add('$key@${DateFormat('yyyy-MM-dd').format(event.date)}');
      }
      debugPrint(
        '[role-cal] role "$roleName" → ${events.length} card(s): '
        '${placed.join(', ')}',
      );

    } catch (e, stackTrace) {
      // WAS `catch (e) {}`. An empty catch here is why this builder could
      // return an empty list for months without anyone being able to tell an
      // employee with no role apart from a query that threw.
      debugPrint(
        'CalendarDataService.getRoleManagementCalendarEvents failed for '
        '$currentUserEmail — $e\n$stackTrace',
      );
    }
    return events;
  }

  /// Function Name: [_isSameDay]
  ///
  /// Purpose: Calendar-day equality, ignoring the time of day.
  ///
  /// Access dates are parsed from `MMM dd, yyyy` and so land at midnight,
  /// while `DateTime.now()` does not — `isAfter`/`isBefore` alone would call
  /// a start date "in the past" from 00:01 on the day it starts.
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ══════════════════════════════════════════════════════════════════
  //  USER ACCESS
  //
  //  Source: `Employees_Info/{id}` - `Activation_Date` and
  //  `Deactivation_Date`, both plain strings (NOT history lists).
  //
  //  ✅ COMPLETED 1/9/2026 — all eight spec entries are emitted.
  //
  //  The four that were missing were both documented here as impossible, and
  //  both notes were out of date:
  //
  //    • accountLocked / accountUnlocked — this said `Status` "records the
  //      state but no timestamp, so there is no date to place a card on".
  //      `Status` is a history LIST, and
  //      `NewEmployeeModelHistory.copyWithUpdateSynchronized` appends to it
  //      and to the shared `timestamps` list in the same call. `Status[i]` has
  //      always been dated by `timestamps[i]` — the same parallel-array
  //      pairing the Knowledge Hub and Services builders already rely on.
  //
  //    • scheduledActivationDateUpdated / scheduledDeactivationDateUpdated —
  //      this said the wiring was "not done here yet only because the catalog
  //      entries' `variables` sets have to be matched at the call site". That
  //      was the whole job: the builder now has an `addWith` that passes
  //      variables, and the two entries declare the old/new date pair they
  //      interpolate. `UserAccessRepository._recordScheduleChange` has been
  //      stamping `<field>_Changed_At` and `<field>_Previous` since 26/8/2026
  //      expressly so these cards could exist.
  // ══════════════════════════════════════════════════════════════════
  Future<List<CalendarEventModel>> getUserAccessCalendarEvents({
    required String currentUserEmail,
  }) async {
    final events = <CalendarEventModel>[];
    if (currentUserEmail.isEmpty) return events;

    try {
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';

      // CHANGED 30/8/2026: was a full read of `Employees_Info` followed by a
      // Dart-side loop with a `break` on the first match — a whole-collection
      // download to reach one document, inside a source the cubit only allows
      // 12 seconds. See [_employeeDocForEmail].
      final doc = await _employeeDocForEmail(currentUserEmail);
      if (doc == null) return events;

      final data = doc.data();
      if (data == null) return events;

      final emails = _historyList(data['Email']);
      final names = _historyList(data['First_Name']);
      final displayName = names.isNotEmpty
          ? names.last
          : (emails.isNotEmpty ? emails.last : currentUserEmail);

      void addWith(
        UserAccessCalendarEvent type,
        DateTime source, {
        Map<TemplateVariable, String> variables = const {},
      }) {
        events.add(CalendarEventModel.fromType(
          type,
          sourceDate: source,
          isArabic: isArabic,
          taskName: displayName,
          time: DateFormat('hh:mm a').format(source),
          userEmail: currentUserEmail,
          // The one builder whose taskName IS a person: `displayName` here is
          // the employee's first name, which the card upgrades to the full
          // name. See CalendarEventModel.titleIsPersonName.
          titleIsPersonName: true,
          variables: variables,
        ));
      }

      void add(UserAccessCalendarEvent type, DateTime source) =>
          addWith(type, source);

      final now = DateTime.now();

      final activation = _parseAccessDate(data['Activation_Date']?.toString());
      if (activation != null) {
        add(UserAccessCalendarEvent.accountActivationToday, activation);
        if (activation.isAfter(now)) {
          add(UserAccessCalendarEvent.accountActivationIn14Days, activation);
        }
      }

      final deactivation =
          _parseAccessDate(data['Deactivation_Date']?.toString());
      if (deactivation != null) {
        add(UserAccessCalendarEvent.accountDeactivationToday, deactivation);
        if (deactivation.isAfter(now)) {
          add(UserAccessCalendarEvent.accountDeactivationIn14Days, deactivation);
        }
      }

      // ── Locked / unlocked ────────────────────────────────────────────
      //
      // ADDED 1/9/2026 — §2 "Account Locked" and "Account Unlocked".
      //
      // The comment that used to head this method said `Status` "records the
      // state but no timestamp, so there is no date to place a card on", and
      // on that basis two spec rows were left unbuilt. It was wrong.
      // `Status` is a history LIST, and
      // `NewEmployeeModelHistory.copyWithUpdateSynchronized` appends to it and
      // to the shared `timestamps` list in one call — that is what
      // "synchronized" means in its name. `Status[i]` is dated by
      // `timestamps[i]`, exactly as the Knowledge Hub and Services builders
      // already read their own parallel arrays.
      final List<String> statuses = _historyList(data['Status'])
          .map((String s) => s.toLowerCase().trim())
          .toList();
      final List<dynamic> statusTimestamps =
          (data['timestamps'] as List?) ?? const <dynamic>[];

      DateTime? statusDateAt(int index) {
        if (index < 0 || index >= statusTimestamps.length) return null;
        final dynamic raw = statusTimestamps[index];
        final int? ms = raw is int ? raw : int.tryParse(raw.toString());
        return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
      }

      // Both spellings, for the reason `UserAccessRepository` documents: the
      // camel-case enum name is not what earlier builds wrote.
      bool isLocked(String status) =>
          status == 'locked' ||
          status == 'lockedwithrequest' ||
          status == 'locked with send request';

      // Only the most recent of each. `Status` holds every status change for
      // the life of the account; one card per historical lock would bury the
      // current state under years of churn. System Logs keeps the full run.
      int lastLock = -1;
      int lastUnlock = -1;
      for (int i = 0; i < statuses.length; i++) {
        if (isLocked(statuses[i])) {
          lastLock = i;
        } else if (statuses[i] == 'active' && i > 0 && isLocked(statuses[i - 1])) {
          // An unlock is a TRANSITION, not a status of its own: `active`
          // preceded by a locked state. Plain `active` with no lock behind it
          // is an ordinary activation and belongs to
          // [accountActivationToday], not here.
          lastUnlock = i;
        }
      }

      final DateTime? lockedAt = lastLock == -1 ? null : statusDateAt(lastLock);
      if (lockedAt != null) {
        add(UserAccessCalendarEvent.accountLocked, lockedAt);
      }

      final DateTime? unlockedAt =
          lastUnlock == -1 ? null : statusDateAt(lastUnlock);
      if (unlockedAt != null) {
        add(UserAccessCalendarEvent.accountUnlocked, unlockedAt);
      }

      // ── Rescheduled activation / deactivation ────────────────────────
      //
      // ADDED 1/9/2026 — §2 "Scheduled Activation Date Updated" and
      // "Scheduled Deactivation Date Updated".
      //
      // The old note said a change to these fields "cannot be detected"
      // because they are plain strings with no history. That stopped being
      // true on 26/8/2026, when `UserAccessRepository._recordScheduleChange`
      // started stamping `<field>_Changed_At` and `<field>_Previous` on the
      // edit branch of each scheduler — a method whose own doc comment says it
      // exists "so the calendar has a date to hang its '… Date Updated' card
      // on". The stamp shipped; the card never did. This is it.
      void addRescheduled({
        required String changedAtField,
        required String previousField,
        required String currentField,
        required UserAccessCalendarEvent type,
        required TemplateVariable oldVariable,
        required TemplateVariable newVariable,
      }) {
        final dynamic rawChangedAt = data[changedAtField];
        if (rawChangedAt == null) return;
        final int? changedMs = rawChangedAt is int
            ? rawChangedAt
            : int.tryParse(rawChangedAt.toString());
        if (changedMs == null) return;

        // The stored strings are already in the display format the schedulers
        // write ("MMM dd, yyyy"), so they are shown verbatim. An em dash
        // rather than an empty string when a side is missing: "changed from
        //  to Sep 20, 2026" reads like a rendering fault.
        final String previous =
            (data[previousField]?.toString().trim() ?? '');
        final String current = (data[currentField]?.toString().trim() ?? '');

        addWith(
          type,
          DateTime.fromMillisecondsSinceEpoch(changedMs),
          variables: <TemplateVariable, String>{
            oldVariable: previous.isEmpty ? '—' : previous,
            newVariable: current.isEmpty ? '—' : current,
          },
        );
      }

      addRescheduled(
        changedAtField: 'Activation_Date_Changed_At',
        previousField: 'Activation_Date_Previous',
        currentField: 'Activation_Date',
        type: UserAccessCalendarEvent.scheduledActivationDateUpdated,
        oldVariable: TemplateVariable.oldActivationDate,
        newVariable: TemplateVariable.newActivationDate,
      );

      addRescheduled(
        changedAtField: 'Deactivation_Date_Changed_At',
        previousField: 'Deactivation_Date_Previous',
        currentField: 'Deactivation_Date',
        type: UserAccessCalendarEvent.scheduledDeactivationDateUpdated,
        oldVariable: TemplateVariable.oldDeactivationDate,
        newVariable: TemplateVariable.newDeactivationDate,
      );

    } catch (e, stackTrace) {
      // WAS `catch (e) {}` — see the note on the role-management builder.
      debugPrint(
        'CalendarDataService.getUserAccessCalendarEvents failed for '
        '$currentUserEmail — $e\n$stackTrace',
      );
    }
    return events;
  }

  // ── shared helpers for the two builders above ────────────────────────

  /// ══════════════════════════════════════════════════════════════════
  ///  EMPLOYEE LOOKUP BY EMAIL                       ADDED 30/8/2026
  ///
  ///  Both role-area builders used to resolve the signed-in user by pulling
  ///  the WHOLE `Employees_Info` collection and looping it in Dart, each with
  ///  its own `.timeout(const Duration(seconds: 15))`. Two problems, and
  ///  together they are why these two sources produced nothing on any tenant
  ///  with a real headcount:
  ///
  ///   1. `CalendarCubit._perSourceTimeout` is **12 seconds**. Role
  ///      Management then spent up to 15s on the scan and up to another 15s
  ///      on the permission document — 30s of budget inside a 12s window — so
  ///      the cubit abandoned the source, logged it under `failures`, and the
  ///      calendar rendered without a single role card. The inner timeouts
  ///      were never reachable; the outer one always won first.
  ///   2. A full-collection read to find one document is the wrong query. It
  ///      also grows with the tenant, so this got slower exactly as it got
  ///      more likely to matter.
  ///
  ///  `Email` is a history list, so `arrayContains` matches an employee whose
  ///  address is (or ever was) this one. Both the address as given and its
  ///  lowercased form are tried, because the collection is not consistently
  ///  cased; the old full scan stays as the last resort for a record whose
  ///  address is stored in some third casing, now time-boxed to fit the
  ///  budget.
  /// ══════════════════════════════════════════════════════════════════

  /// Everything the two builders need from the employee record.
  ///
  /// [Duration] is deliberately short: two of these can run inside one 12s
  /// source, and a slow answer is worth less than a partial calendar.
  static const Duration _employeeLookupTimeout = Duration(seconds: 5);

  /// Function Name: [_employeeDocForEmail]
  ///
  /// Purpose: The `Employees_Info` document for an address, or null.
  ///
  /// Parameters:
  /// - [email]: the signed-in user's address.
  ///
  /// Returns: [Future] of the snapshot, or null when no record matches.
  static Future<DocumentSnapshot<Map<String, dynamic>>?> _employeeDocForEmail(
    String email,
  ) async {
    final String trimmed = email.trim();
    if (trimmed.isEmpty) return null;

    final CollectionReference<Map<String, dynamic>> collection =
        FirebaseFirestore.instance.collection(getBaseUrl('Employees_Info'));

    for (final String candidate in <String>{trimmed, trimmed.toLowerCase()}) {
      final QuerySnapshot<Map<String, dynamic>> hit = await collection
          .where('Email', arrayContains: candidate)
          .limit(1)
          .get()
          .timeout(_employeeLookupTimeout);
      if (hit.docs.isNotEmpty) return hit.docs.first;
    }

    // Last resort: the old scan, for a record stored in some other casing.
    final QuerySnapshot<Map<String, dynamic>> all =
        await collection.get().timeout(_employeeLookupTimeout);
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in all.docs) {
      final List<String> emails = _historyList(doc.data()['Email']);
      if (emails.isEmpty) continue;
      if (emails.last.trim().toLowerCase() == trimmed.toLowerCase()) return doc;
    }
    return null;
  }

  /// Firestore stores most employee fields as a history list where the
  /// CURRENT value is the last entry. Normalises the several shapes seen in
  /// this database into a plain list of strings.
  static List<String> _historyList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    if (value is Map && value['values'] is List) {
      return (value['values'] as List).map((e) => e?.toString() ?? '').toList();
    }
    return [value.toString()];
  }

  /// Access dates are written with Constants.userAccessDateFormat
  /// ("MMM dd, yyyy"). A few older rows use ISO, so both are accepted.
  static DateTime? _parseAccessDate(String? raw) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty || text == 'null' || text == '[]') return null;
    for (final pattern in const ['MMM dd, yyyy', 'MMM d, yyyy', 'yyyy-MM-dd']) {
      try {
        return DateFormat(pattern, 'en').parseStrict(text);
      } catch (_) {}
    }
    return DateTime.tryParse(text);
  }

  // ══════════════════════════════════════════════════════════════════
  // SETTINGS — profile / health insurance / emergency contact change
  // requests.
  //
  // ADDED 25/8/2026. The settings change-request flow raised notifications but
  // never a calendar entry, so a request waiting on a reviewer lived only in
  // the inbox and the Requests queue — neither of which answers "what needs me
  // this week".
  //
  // Two audiences off one collection, decided per document:
  //   • a signed-in user holding `Users_Requests` gets a pending-review card
  //     for every request still awaiting a decision;
  //   • the employee who raised a request gets its own lifecycle — submitted
  //     while pending, then approved or rejected on the decision date.
  // CHANGED 9/10/2026 (owner decision): a reviewer no longer gets the
  // pending-review card for their OWN request — they cannot approve or reject
  // it any more (SelfApprovalRule), so "someone has to answer" is not them.
  // They still get their own submitted / decided lifecycle cards.
  // ══════════════════════════════════════════════════════════════════

  /// How many requests one calendar load will read.
  ///
  /// The collection is unbounded and grows for the life of the tenant, while
  /// the calendar only ever renders a window of it. Newest-first with a cap
  /// keeps the read predictable; the cap is generous enough that reaching it
  /// means more history than any calendar view can show, and
  /// [getSettingsCalendarEvents] says so in the log rather than truncating
  /// silently.
  static const int _settingsRequestScanLimit = 300;

  Future<List<CalendarEventModel>> getSettingsCalendarEvents({
    required String currentUserEmail,
  }) async {
    final events = <CalendarEventModel>[];
    if (currentUserEmail.isEmpty) return events;

    try {
      final bool isArabic = languageCode() == 'ar';
      final String myEmail = currentUserEmail.toLowerCase().trim();

      // Whether the signed-in user reviews requests. This is the one permission
      // question the local check can answer — it is about the current user — so
      // it uses MainCoreEmployeeController rather than the directory-wide
      // lookup the notification fan-out needs.
      final bool isReviewer = currentEmployee().isHasPermission(
        module: Modules.roles,
        section: RolePermissionsSections.userManagement,
        permission: UserManagement.usersRequests,
      );

      final snapshot = await _firestore
          .doc(RequestCollectionPaths.rolesDoc)
          .collection(RequestCollectionPaths.requestsCollection)
          .orderBy(ChangeRequestMapper.keyRequestDate, descending: true)
          .limit(_settingsRequestScanLimit)
          .get()
          .timeout(const Duration(seconds: 15));

      if (snapshot.docs.length == _settingsRequestScanLimit) {
        debugPrint(
          'CalendarDataService: settings requests hit the '
          '$_settingsRequestScanLimit-document scan limit; older requests are '
          'not on the calendar.',
        );
      }

      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();

        // Parsed through the shared mapper rather than by hand: it already
        // tolerates the several shapes `requestDate` has been written in, and
        // it is the same reading the request screens use.
        final ChangeRequest request =
            ChangeRequestMapper.fromDocument(doc.id, data);

        final DateTime? requestDate = request.requestDate;
        if (requestDate == null) continue;

        final bool isMine =
            request.employeeEmail.toLowerCase().trim() == myEmail;

        // Nothing to draw for a request that is neither mine nor mine to
        // review — skip before doing any more work on it.
        // 9/10/2026: `isMine` requests are never review cards (see above).
        if (!isMine && !(isReviewer && request.status.isPending)) continue;

        final DateTime decidedOn =
            _settingsDecisionDate(data[ChangeRequestMapper.keyUpdatedAt]) ??
                requestDate;

        void add(
          SettingsCalendarEvent type,
          DateTime source, {
          Map<TemplateVariable, String> variables =
              const <TemplateVariable, String>{},
        }) {
          events.add(CalendarEventModel.fromType(
            type,
            sourceDate: source,
            isArabic: isArabic,
            // The section is the card's subject — `Personal Information`,
            // `Health Insurance`, `Emergency Contact`.
            taskName: request.section,
            time: DateFormat('hh:mm a').format(source),
            variables: variables,
            requestId: doc.id,
            userEmail: request.employeeEmail,
          ));
        }

        if (request.status.isPending) {
          // 9/10/2026 — `&& !isMine`: no review card for your own request.
          if (isReviewer && !isMine) {
            add(
              SettingsCalendarEvent.changeRequestPendingReview,
              requestDate,
              variables: <TemplateVariable, String>{
                // Falls back to the address on a document written before
                // `employeeName` existed, so the sentence never opens with a
                // blank.
                // Title-cased: names are stored lower-case ("demo company").
                TemplateVariable.employeeName: request.employeeName.isNotEmpty
                    ? request.employeeName
                        .split(' ')
                        .map((String w) => w.isEmpty
                            ? w
                            : '${w[0].toUpperCase()}${w.substring(1)}')
                        .join(' ')
                    : request.employeeEmail,
                // The section the request changes — "Personal Information",
                // "Health Insurance", "Emergency Contact".
                TemplateVariable.documentName: request.section,
              },
            );
          }
          if (isMine) {
            add(SettingsCalendarEvent.changeRequestSubmitted, requestDate);
          }
          continue;
        }

        // Past this point the request is decided. The outcome belongs to the
        // person who asked; a reviewer's calendar is a queue of work, and work
        // that is done is not on it.
        if (!isMine) continue;

        if (request.status == RequestStatus.approved) {
          add(SettingsCalendarEvent.changeRequestApproved, decidedOn);
        } else if (request.status == RequestStatus.rejected) {
          add(SettingsCalendarEvent.changeRequestRejected, decidedOn);
        }
        // Cancelled draws nothing: it is the employee's own doing and the
        // catalog has no entry for it, matching the notification side.
      }
    } catch (e, stackTrace) {
      // Consistent with every other builder here: one source failing must not
      // empty the calendar. CalendarCubit records the failure by name.
      debugPrint(
          'CalendarDataService: settings requests failed — $e\n$stackTrace');
    }
    return events;
  }

  /// Function Name: [_settingsDecisionDate]
  ///
  /// Purpose: When a request was decided.
  ///
  /// `updatedAt` is written as a server timestamp, but older documents predate
  /// the field and a few carry epoch milliseconds, so all three shapes are
  /// accepted. Anything else yields null and the caller falls back to the
  /// request date rather than dropping the card.
  static DateTime? _settingsDecisionDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  /// All Qiyas events use GREY color (0xFF9FADAF)
  Future<List<CalendarEventModel>> getQiyasCalendarEvents({
    required String currentUserEmail,
  }) async
  {
    List<CalendarEventModel> events = [];

    try {

      String companyIdPath = getBaseUrl('');
      String companyId = '';
      if (companyIdPath.contains('/')) {
        final parts = companyIdPath.split('/');
        if (parts.length >= 2) {
          companyId = parts[1];
        }
      }


      // ✅ Get current locale to determine language
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';


      // Get main core controller for employee details
      final mainCoreController = currentEmployee();

      // ========================================
      // PART 1: GET CHAMPION ASSIGNMENTS (Initial Assignment + Due/Overdue)
      // ========================================
      try {

        final championsSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.qiyasControlChampions)
            .where('Champion', isEqualTo: currentUserEmail)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Champions query timeout');
          },
        );


        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (var championDoc in championsSnapshot.docs) {
          try {
            final data = championDoc.data();
            final criteriaId = data['Criteria_Id']?.toString() ?? '';
            final documentNumber = data['Document']?.toString() ?? '';
            final championId = championDoc.id;
            final status = data['status']?.toString()?.toLowerCase() ?? '';


            // Check if status is active
            if (status != 'active') {
              continue;
            }

            // Get date from 'Deadline' field (array)
            DateTime? submissionDate;
            final deadlineArray = data['Deadline'] as List?;

            if (deadlineArray != null && deadlineArray.isNotEmpty) {
              final deadlineItem = deadlineArray.first;
              if (deadlineItem is Timestamp) {
                submissionDate = deadlineItem.toDate();
              }
            }

            if (submissionDate == null) {
              continue;
            }

            // Remove time component for date comparison
            final submissionDateOnly = DateTime(
                submissionDate.year,
                submissionDate.month,
                submissionDate.day
            );

            final daysUntilSubmission = submissionDateOnly.difference(today).inDays;


            // ✅ Get VISION/EVIDENCE NAME
            String? evidenceName;

            final notesArray = data['Notes'] as List?;
            if (notesArray != null && notesArray.isNotEmpty) {
              final notesValue = notesArray.first?.toString().trim();
              if (notesValue != null && notesValue.isNotEmpty) {
                evidenceName = notesValue;
              }
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              final evidenceNameField = data['Evidence_Name'];
              if (evidenceNameField != null) {
                if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                  evidenceName = evidenceNameField.first?.toString().trim();
                } else if (evidenceNameField is String) {
                  evidenceName = evidenceNameField.trim();
                }
              }
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              final descriptionField = data['Description'];
              if (descriptionField != null) {
                if (descriptionField is List && descriptionField.isNotEmpty) {
                  evidenceName = descriptionField.first?.toString().trim();
                } else if (descriptionField is String) {
                  evidenceName = descriptionField.trim();
                }
              }
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              final titleField = data['Title'];
              if (titleField != null) {
                if (titleField is List && titleField.isNotEmpty) {
                  evidenceName = titleField.first?.toString().trim();
                } else if (titleField is String) {
                  evidenceName = titleField.trim();
                }
              }
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              final nameField = data['Name'];
              if (nameField != null) {
                if (nameField is List && nameField.isNotEmpty) {
                  evidenceName = nameField.first?.toString().trim();
                } else if (nameField is String) {
                  evidenceName = nameField.trim();
                }
              }
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
            }


            // Check if champion has submitted evidence
            bool hasSubmitted = false;
            bool isApprovedBySupervisor = false;
            bool isApprovedByManager = false;
            bool isRejectedBySupervisor = false;
            bool isRejectedByManager = false;
            bool isSubmitted = false;
            DateTime? evidenceSubmissionDate;
            DateTime? supervisorApprovalDate;
            DateTime? managerApprovalDate;
            DateTime? supervisorRejectionDate;
            DateTime? managerRejectionDate;

            try {
              final evidenceSnapshot = await _firestore
                  .collection(FirebaseCollections.demo)
                  .doc(companyId)
                  .collection(FirebaseCollections.qiyasEvidenceSubmissions)
                  .where('Criteria_Number', isEqualTo: criteriaId)
                  .where('Evidence_Number', isEqualTo: documentNumber)
                  .where('Submitted_By', isEqualTo: currentUserEmail)
                  .orderBy('Submission_Date', descending: true)
                  .limit(1)
                  .get();

              if (evidenceSnapshot.docs.isNotEmpty) {
                hasSubmitted = true;
                final evidenceData = evidenceSnapshot.docs.first.data();
                final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';

                isSubmitted = evidenceStatus == 'submitted' || evidenceStatus == 'pending';
                isApprovedBySupervisor = evidenceStatus == 'approved_by_supervisor';
                isApprovedByManager = evidenceStatus == 'approved';
                isRejectedBySupervisor = evidenceStatus == 'rejected_by_supervisor';
                isRejectedByManager = evidenceStatus == 'rejected_by_manager' || evidenceStatus == 'rejected';

                // Get evidence submission date
                final submissionDateField = evidenceData['Submission_Date'];
                if (submissionDateField is Timestamp) {
                  evidenceSubmissionDate = submissionDateField.toDate();
                }

                // Get supervisor approval date
                final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
                if (supervisorApprovalDateField is Timestamp) {
                  supervisorApprovalDate = supervisorApprovalDateField.toDate();
                } else if (isApprovedBySupervisor) {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    supervisorApprovalDate = actionDateField.toDate();
                  } else {
                    supervisorApprovalDate = evidenceSubmissionDate;
                  }
                }

                // Get manager approval date
                final managerApprovalDateField = evidenceData['Manager_Approval_Date'];
                if (managerApprovalDateField is Timestamp) {
                  managerApprovalDate = managerApprovalDateField.toDate();
                } else if (isApprovedByManager) {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerApprovalDate = actionDateField.toDate();
                  } else {
                    managerApprovalDate = supervisorApprovalDate ?? evidenceSubmissionDate;
                  }
                }

                // Get supervisor rejection date
                if (isRejectedBySupervisor) {
                  final supervisorRejectionDateField = evidenceData['Supervisor_Rejection_Date'];
                  if (supervisorRejectionDateField is Timestamp) {
                    supervisorRejectionDate = supervisorRejectionDateField.toDate();
                  } else {
                    final actionDateField = evidenceData['Action_Date'];
                    if (actionDateField is Timestamp) {
                      supervisorRejectionDate = actionDateField.toDate();
                    } else {
                      supervisorRejectionDate = evidenceSubmissionDate ?? DateTime.now();
                    }
                  }
                }

                // Get manager rejection date
                if (isRejectedByManager) {
                  final managerRejectionDateField = evidenceData['Manager_Rejection_Date'];
                  if (managerRejectionDateField is Timestamp) {
                    managerRejectionDate = managerRejectionDateField.toDate();
                  } else {
                    final actionDateField = evidenceData['Action_Date'];
                    if (actionDateField is Timestamp) {
                      managerRejectionDate = actionDateField.toDate();
                    } else {
                      managerRejectionDate = supervisorApprovalDate ?? evidenceSubmissionDate ?? DateTime.now();
                    }
                  }
                }

              }
            } catch (e) {
            }


            // ✅ CARD 1: INITIAL ASSIGNMENT - Always show (PERMANENT)
            final dueDateStr = DateFormat('MMM dd, yyyy').format(submissionDate);

            final assignmentDescription = isArabic
                ? 'تم تعيين دليل لك والموعد النهائي هو $dueDateStr'
                : 'You have been assigned an evidence and due date is $dueDateStr';

            events.add(CalendarEventModel(
              date: submissionDate,
              color: AppColors.calendarEventQiyas,
              moduleName: 'Qiyas',
              taskName: evidenceName,
              time: DateFormat('hh:mm a').format(submissionDate),
              description: assignmentDescription,
              status: 'Due',
            ));


            // ✅ CARD 2: OVERDUE
            if (!hasSubmitted && daysUntilSubmission < 0 && !isApprovedByManager) {
              final overdueDescription = isArabic
                  ? 'يجب عليك تحميل الدليل الخاص بك على الفور'
                  : 'You must upload your evidence immediately';

              events.add(CalendarEventModel(
                date: submissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(submissionDate),
                description: overdueDescription,
                status: 'Overdue',
              ));

            }

            // ✅ CARD 3: SUBMITTED
            if (hasSubmitted && evidenceSubmissionDate != null) {
              final submittedDescription = isArabic
                  ? 'تم تقديم الدليل الخاص بك وفي انتظار موافقة المشرف'
                  : 'Your evidence has been submitted and is awaiting supervisor approval';

              events.add(CalendarEventModel(
                date: evidenceSubmissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(evidenceSubmissionDate),
                description: submittedDescription,
                status: 'Submitted',
              ));

            }

            // ✅ CARD 4: APPROVED BY SUPERVISOR
            if (isApprovedBySupervisor && supervisorApprovalDate != null) {
              final approvedBySupervisorDescription = isArabic
                  ? 'تمت الموافقة على الدليل الخاص بك من قبل المشرف، في انتظار موافقة المدير'
                  : 'Your evidence has been approved by supervisor, waiting for manager approval';

              events.add(CalendarEventModel(
                date: supervisorApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorApprovalDate),
                description: approvedBySupervisorDescription,
                status: 'Approved by Supervisor',
              ));

            }

            // ✅ CARD 5: APPROVED BY MANAGER (FINAL)
            if (isApprovedByManager && managerApprovalDate != null) {
              final approvedByManagerDescription = isArabic
                  ? 'تمت الموافقة على الدليل الخاص بك بشكل نهائي من قبل المدير'
                  : 'Your evidence has been fully approved by manager';

              events.add(CalendarEventModel(
                date: managerApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerApprovalDate),
                description: approvedByManagerDescription,
                status: 'Approved',
              ));

            }

            // ✅ CARD 6: REJECTED BY SUPERVISOR
            if (isRejectedBySupervisor && supervisorRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'تم رفض الدليل الخاص بك من قبل المشرف. يرجى إعادة التقديم'
                  : 'Your evidence has been rejected by supervisor. Please resubmit';

              events.add(CalendarEventModel(
                date: supervisorRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

            }

            // ✅ CARD 7: REJECTED BY MANAGER
            if (isRejectedByManager && managerRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'تم رفض الدليل الخاص بك من قبل المدير. يرجى إعادة التقديم'
                  : 'Your evidence has been rejected by manager. Please resubmit';

              events.add(CalendarEventModel(
                date: managerRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

            }

          } catch (e) {
          }
        }

      } catch (timeoutError) {
      } catch (e) {
      }

      // ========================================
      // PART 2: GET SUPERVISOR VIEW
      // ========================================
      try {

        final allChampionsSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.qiyasControlChampions)
            .where('status', isEqualTo: 'active')
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('All champions query timeout');
          },
        );


        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        for (var championDoc in allChampionsSnapshot.docs) {
          try {
            final data = championDoc.data();
            final criteriaId = data['Criteria_Id']?.toString() ?? '';
            final documentNumber = data['Document']?.toString() ?? '';
            final championEmail = data['Champion']?.toString() ?? '';

            // ✅ CRITICAL FIX: Skip if current user IS the champion themselves
            if (championEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
              continue;
            }

            final championEmployee = mainCoreController.getLocaleEmployee(championEmail);

            if (championEmployee == null) {
              continue;
            }

            final championSupervisorEmail = championEmployee.supervisor?.trim().toLowerCase();

            if (championSupervisorEmail != currentUserEmail.toLowerCase()) {
              continue;
            }


            DateTime? submissionDate;
            final deadlineArray = data['Deadline'] as List?;

            if (deadlineArray != null && deadlineArray.isNotEmpty) {
              final deadlineItem = deadlineArray.first;
              if (deadlineItem is Timestamp) {
                submissionDate = deadlineItem.toDate();
              }
            }

            if (submissionDate == null) {
              continue;
            }

            final submissionDateOnly = DateTime(
                submissionDate.year,
                submissionDate.month,
                submissionDate.day
            );

            final daysUntilSubmission = submissionDateOnly.difference(today).inDays;

            String? evidenceName;
            final notesArray = data['Notes'] as List?;
            if (notesArray != null && notesArray.isNotEmpty) {
              final notesValue = notesArray.first?.toString().trim();
              if (notesValue != null && notesValue.isNotEmpty) {
                evidenceName = notesValue;
              }
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              final evidenceNameField = data['Evidence_Name'];
              if (evidenceNameField != null) {
                if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                  evidenceName = evidenceNameField.first?.toString().trim();
                } else if (evidenceNameField is String) {
                  evidenceName = evidenceNameField.trim();
                }
              }
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
            }

            bool hasSubmitted = false;
            bool isApprovedBySupervisor = false;
            bool isApprovedByManager = false;
            bool isRejectedBySupervisor = false;
            bool isRejectedByManager = false;
            DateTime? supervisorApprovalDate;
            DateTime? managerApprovalDate;
            DateTime? supervisorRejectionDate;
            DateTime? managerRejectionDate;

            try {
              final evidenceSnapshot = await _firestore
                  .collection(FirebaseCollections.demo)
                  .doc(companyId)
                  .collection(FirebaseCollections.qiyasEvidenceSubmissions)
                  .where('Criteria_Number', isEqualTo: criteriaId)
                  .where('Evidence_Number', isEqualTo: documentNumber)
                  .where('Submitted_By', isEqualTo: championEmail)
                  .orderBy('Submission_Date', descending: true)
                  .limit(1)
                  .get();

              if (evidenceSnapshot.docs.isNotEmpty) {
                hasSubmitted = true;
                final evidenceData = evidenceSnapshot.docs.first.data();
                final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';

                isApprovedBySupervisor = evidenceStatus == 'approved_by_supervisor';
                isApprovedByManager = evidenceStatus == 'approved';
                isRejectedBySupervisor = evidenceStatus == 'rejected_by_supervisor';
                isRejectedByManager = evidenceStatus == 'rejected_by_manager' || evidenceStatus == 'rejected';

                final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
                if (supervisorApprovalDateField is Timestamp) {
                  supervisorApprovalDate = supervisorApprovalDateField.toDate();
                } else if (isApprovedBySupervisor) {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    supervisorApprovalDate = actionDateField.toDate();
                  } else {
                    supervisorApprovalDate = DateTime.now();
                  }
                }

                final managerApprovalDateField = evidenceData['Manager_Approval_Date'];
                if (managerApprovalDateField is Timestamp) {
                  managerApprovalDate = managerApprovalDateField.toDate();
                } else if (isApprovedByManager) {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerApprovalDate = actionDateField.toDate();
                  } else {
                    managerApprovalDate = DateTime.now();
                  }
                }

                if (isRejectedBySupervisor) {
                  final supervisorRejectionDateField = evidenceData['Supervisor_Rejection_Date'];
                  if (supervisorRejectionDateField is Timestamp) {
                    supervisorRejectionDate = supervisorRejectionDateField.toDate();
                  } else {
                    final actionDateField = evidenceData['Action_Date'];
                    if (actionDateField is Timestamp) {
                      supervisorRejectionDate = actionDateField.toDate();
                    } else {
                      supervisorRejectionDate = DateTime.now();
                    }
                  }
                }

                if (isRejectedByManager) {
                  final managerRejectionDateField = evidenceData['Manager_Rejection_Date'];
                  if (managerRejectionDateField is Timestamp) {
                    managerRejectionDate = managerRejectionDateField.toDate();
                  } else {
                    final actionDateField = evidenceData['Action_Date'];
                    if (actionDateField is Timestamp) {
                      managerRejectionDate = actionDateField.toDate();
                    } else {
                      managerRejectionDate = DateTime.now();
                    }
                  }
                }
              }
            } catch (e) {
            }

            final championName = '${championEmployee.firstName} ${championEmployee.lastName}';

            // SUPERVISOR CARD 1: DURATION
            final durationDescription = isArabic
                ? 'موظفك $championName تم تعيين له $evidenceName'
                : 'Your employee $championName has been assigned $evidenceName';

            events.add(CalendarEventModel(
              date: submissionDate,
              color: AppColors.calendarEventQiyas,
              moduleName: 'Qiyas',
              taskName: evidenceName,
              time: DateFormat('hh:mm a').format(submissionDate),
              description: durationDescription,
              status: 'Duration',
            ));


            // SUPERVISOR CARD 2: OVERDUE
            if (!hasSubmitted && daysUntilSubmission < 0 && !isApprovedByManager) {
              final overdueDescription = isArabic
                  ? 'موظفك $championName لم يقم بتحميل الدليل المطلوب منه'
                  : 'Your employee $championName did not upload the evidence which was requested from him';

              events.add(CalendarEventModel(
                date: submissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(submissionDate),
                description: overdueDescription,
                status: 'Overdue',
              ));

            }

            // SUPERVISOR CARD 3: APPROVED BY SUPERVISOR
            if (isApprovedBySupervisor && supervisorApprovalDate != null) {
              final approvedDescription = isArabic
                  ? 'لقد وافقت على دليل $championName، في انتظار موافقة المدير'
                  : 'You have approved $championName\'s evidence, waiting for manager approval';

              events.add(CalendarEventModel(
                date: supervisorApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorApprovalDate),
                description: approvedDescription,
                status: 'Approved by Supervisor',
              ));

            }

            // SUPERVISOR CARD 4: APPROVED BY MANAGER
            if (isApprovedByManager && managerApprovalDate != null) {
              final approvedDescription = isArabic
                  ? 'تمت الموافقة على دليل $championName بشكل نهائي من قبل المدير'
                  : 'Manager has approved $championName\'s evidence';

              events.add(CalendarEventModel(
                date: managerApprovalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerApprovalDate),
                description: approvedDescription,
                status: 'Approved',
              ));

            }

            // SUPERVISOR CARD 5: REJECTED BY SUPERVISOR
            if (isRejectedBySupervisor && supervisorRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'لقد رفضت دليل $championName'
                  : 'You have rejected $championName\'s evidence';

              events.add(CalendarEventModel(
                date: supervisorRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(supervisorRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

            }

            // SUPERVISOR CARD 6: REJECTED BY MANAGER
            if (isRejectedByManager && managerRejectionDate != null) {
              final rejectedDescription = isArabic
                  ? 'المدير رفض دليل $championName'
                  : 'Manager has rejected $championName\'s evidence';

              events.add(CalendarEventModel(
                date: managerRejectionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: DateFormat('hh:mm a').format(managerRejectionDate),
                description: rejectedDescription,
                status: 'Rejected',
              ));

            }

          } catch (e) {
          }
        }

      } catch (timeoutError) {
      } catch (e) {
      }

      // ========================================
      // PART 3: GET SUPERVISOR PENDING APPROVALS
      // ========================================
      try {

        final allEvidenceSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.qiyasEvidenceSubmissions)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Evidence query timeout');
          },
        );


        int pendingCount = 0;
        int approvedBySupervisorCount = 0;

        for (var evidenceDoc in allEvidenceSnapshot.docs) {
          try {
            final evidenceData = evidenceDoc.data();
            final criteriaId = evidenceData['Criteria_Number']?.toString() ?? '';
            final documentNumber = evidenceData['Evidence_Number']?.toString() ?? '';
            final championEmail = evidenceData['Submitted_By']?.toString() ?? '';
            final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';


            // ✅ CRITICAL FIX: Skip if current user IS the champion themselves
            if (championEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
              continue;
            }

            if (evidenceStatus != 'pending' &&
                evidenceStatus != 'submitted' &&
                evidenceStatus != 'approved_by_supervisor') {
              continue;
            }

            final championEmployee = mainCoreController.getLocaleEmployee(championEmail);

            if (championEmployee == null) {
              continue;
            }

            final championSupervisorEmail = championEmployee.supervisor?.trim().toLowerCase();

            if (championSupervisorEmail == null || championSupervisorEmail.isEmpty) {
              continue;
            }

            final currentUserEmailNormalized = currentUserEmail.trim().toLowerCase();

            bool isCurrentUserSupervisor = championSupervisorEmail == currentUserEmailNormalized;

            bool isSuperAdmin = mainCoreController.isSuperAdmin();
            bool hasQiyasAdminPermission = false;

            try {
              hasQiyasAdminPermission = mainCoreController.hasSpecificPermission(
                  Modules.qiyas,
                  'admin_access'
              ) || mainCoreController.hasSpecificPermission(
                  Modules.qiyas,
                  'approve_evidence'
              );
            } catch (e) {
            }

            bool shouldShowCard = isCurrentUserSupervisor || isSuperAdmin || hasQiyasAdminPermission;

            if (!shouldShowCard) {
              continue;
            }

            final submissionDateField = evidenceData['Submission_Date'];
            DateTime? submissionDate;

            if (submissionDateField is Timestamp) {
              submissionDate = submissionDateField.toDate();
            }

            if (submissionDate == null) {
              continue;
            }

            String? evidenceName;

            try {
              final championDoc = await _firestore
                  .collection(FirebaseCollections.demo)
                  .doc(companyId)
                  .collection(FirebaseCollections.qiyasControlChampions)
                  .where('Criteria_Id', isEqualTo: criteriaId)
                  .where('Document', isEqualTo: documentNumber)
                  .where('Champion', isEqualTo: championEmail)
                  .limit(1)
                  .get();

              if (championDoc.docs.isNotEmpty) {
                final championData = championDoc.docs.first.data();

                final notesArray = championData['Notes'] as List?;
                if (notesArray != null && notesArray.isNotEmpty) {
                  final notesValue = notesArray.first?.toString().trim();
                  if (notesValue != null && notesValue.isNotEmpty) {
                    evidenceName = notesValue;
                  }
                }

                if (evidenceName == null || evidenceName.isEmpty) {
                  final evidenceNameField = championData['Evidence_Name'];
                  if (evidenceNameField != null) {
                    if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                      evidenceName = evidenceNameField.first?.toString().trim();
                    } else if (evidenceNameField is String) {
                      evidenceName = evidenceNameField.trim();
                    }
                  }
                }
              }
            } catch (e) {
            }

            if (evidenceName == null || evidenceName.isEmpty) {
              evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
            }

            final championName = '${championEmployee.firstName} ${championEmployee.lastName}';

            final period = submissionDate.hour >= 12 ? 'PM' : 'AM';
            final displayHour = submissionDate.hour > 12
                ? submissionDate.hour - 12
                : (submissionDate.hour == 0 ? 12 : submissionDate.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${submissionDate.minute.toString().padLeft(2, '0')} $period';

            if (evidenceStatus == 'pending' || evidenceStatus == 'submitted') {

              final pendingDescription = isArabic
                  ? 'لديك طلب من $championName يحتاج إلى اتخاذ إجراء'
                  : 'You have a request from $championName that needs action';

              events.add(CalendarEventModel(
                date: submissionDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: displayTime,
                description: pendingDescription,
                status: 'Pending Approval',
              ));

              pendingCount++;

            } else if (evidenceStatus == 'approved_by_supervisor') {

              DateTime? approvalDate;
              final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
              if (supervisorApprovalDateField is Timestamp) {
                approvalDate = supervisorApprovalDateField.toDate();
              } else {
                final actionDateField = evidenceData['Action_Date'];
                if (actionDateField is Timestamp) {
                  approvalDate = actionDateField.toDate();
                } else {
                  approvalDate = submissionDate;
                }
              }

              final approvalPeriod = approvalDate.hour >= 12 ? 'PM' : 'AM';
              final approvalDisplayHour = approvalDate.hour > 12
                  ? approvalDate.hour - 12
                  : (approvalDate.hour == 0 ? 12 : approvalDate.hour);
              final approvalDisplayTime =
                  '${approvalDisplayHour.toString().padLeft(2, '0')}:${approvalDate.minute.toString().padLeft(2, '0')} $approvalPeriod';

              final approvedDescription = isArabic
                  ? 'لقد وافقت على دليل $championName، في انتظار موافقة المدير'
                  : 'You have approved $championName\'s evidence, waiting for manager approval';

              events.add(CalendarEventModel(
                date: approvalDate,
                color: AppColors.calendarEventQiyas,
                moduleName: 'Qiyas',
                taskName: evidenceName,
                time: approvalDisplayTime,
                description: approvedDescription,
                status: 'Approved by Supervisor',
              ));

              approvedBySupervisorCount++;
            }

          } catch (e) {
          }
        }


      } catch (timeoutError) {
      } catch (e) {
      }

      // ========================================
      // PART 4: GET MANAGER PENDING APPROVALS & ACTIONS
      // ========================================
      try {

        // The QiyasPermissionsSections enum was removed, so the
        // changeSubmissionStatus permission can no longer be granted to
        // anyone. isHasPermission returns false for a null section, so this
        // stays deny-by-default rather than silently opening the manager view.
        const bool hasManagerPermission = false;


        if (!hasManagerPermission) {
        } else {

          // Get all evidence submissions
          final allEvidenceSnapshot = await _firestore
              .collection(FirebaseCollections.demo)
              .doc(companyId)
              .collection(FirebaseCollections.qiyasEvidenceSubmissions)
              .get()
              .timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Manager evidence query timeout');
            },
          );


          int managerPendingCount = 0;
          int managerApprovedCount = 0;
          int managerRejectedCount = 0;

          for (var evidenceDoc in allEvidenceSnapshot.docs) {
            try {
              final evidenceData = evidenceDoc.data();
              final criteriaId = evidenceData['Criteria_Number']?.toString() ?? '';
              final documentNumber = evidenceData['Evidence_Number']?.toString() ?? '';
              final championEmail = evidenceData['Submitted_By']?.toString() ?? '';
              final evidenceStatus = evidenceData['Submission_Status']?.toString().toLowerCase() ?? '';


              // ✅ CRITICAL FIX: Skip if current user IS the champion themselves
              if (championEmail.toLowerCase() == currentUserEmail.toLowerCase()) {
                continue;
              }

              // ✅ Skip if not relevant to manager
              if (evidenceStatus != 'approved_by_supervisor' &&
                  evidenceStatus != 'approved' &&
                  evidenceStatus != 'rejected_by_manager' &&
                  evidenceStatus != 'rejected') {
                continue;
              }


              // Get champion employee
              final championEmployee = mainCoreController.getLocaleEmployee(championEmail);
              if (championEmployee == null) {
                continue;
              }

              final championName = '${championEmployee.firstName} ${championEmployee.lastName}';

              // Get supervisor name
              String supervisorName = 'Supervisor';
              final championSupervisorEmail = championEmployee.supervisor?.trim();
              if (championSupervisorEmail != null && championSupervisorEmail.isNotEmpty) {
                final supervisorEmployee = mainCoreController.getLocaleEmployee(championSupervisorEmail);
                if (supervisorEmployee != null) {
                  supervisorName = '${supervisorEmployee.firstName} ${supervisorEmployee.lastName}';
                }
              }


              // Get evidence name
              String? evidenceName;
              try {
                final championDoc = await _firestore
                    .collection(FirebaseCollections.demo)
                    .doc(companyId)
                    .collection(FirebaseCollections.qiyasControlChampions)
                    .where('Criteria_Id', isEqualTo: criteriaId)
                    .where('Document', isEqualTo: documentNumber)
                    .where('Champion', isEqualTo: championEmail)
                    .limit(1)
                    .get();

                if (championDoc.docs.isNotEmpty) {
                  final championData = championDoc.docs.first.data();
                  final notesArray = championData['Notes'] as List?;
                  if (notesArray != null && notesArray.isNotEmpty) {
                    evidenceName = notesArray.first?.toString().trim();
                  }

                  if (evidenceName == null || evidenceName.isEmpty) {
                    final evidenceNameField = championData['Evidence_Name'];
                    if (evidenceNameField is List && evidenceNameField.isNotEmpty) {
                      evidenceName = evidenceNameField.first?.toString().trim();
                    } else if (evidenceNameField is String) {
                      evidenceName = evidenceNameField.trim();
                    }
                  }
                }
              } catch (e) {
              }

              if (evidenceName == null || evidenceName.isEmpty) {
                evidenceName = 'Qiyas Document $criteriaId-$documentNumber';
              }


              // ✅ MANAGER CARD 1: PENDING APPROVAL (approved_by_supervisor)
              if (evidenceStatus == 'approved_by_supervisor') {

                DateTime? approvalDate;

                // Try to get supervisor approval date
                final supervisorApprovalDateField = evidenceData['Supervisor_Approval_Date'];
                if (supervisorApprovalDateField is Timestamp) {
                  approvalDate = supervisorApprovalDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    approvalDate = actionDateField.toDate();
                  } else {
                    final submissionDateField = evidenceData['Submission_Date'];
                    if (submissionDateField is Timestamp) {
                      approvalDate = submissionDateField.toDate();
                    } else {
                      approvalDate = DateTime.now();
                    }
                  }
                }

                final period = approvalDate.hour >= 12 ? 'PM' : 'AM';
                final displayHour = approvalDate.hour > 12
                    ? approvalDate.hour - 12
                    : (approvalDate.hour == 0 ? 12 : approvalDate.hour);
                final displayTime =
                    '${displayHour.toString().padLeft(2, '0')}:${approvalDate.minute.toString().padLeft(2, '0')} $period';

                final managerPendingDescription = isArabic
                    ? 'لديك طلب من $championName تمت الموافقة عليه من قبل $supervisorName ويحتاج إلى موافقتك'
                    : 'You have a request from $championName approved by $supervisorName that needs your approval';

                events.add(CalendarEventModel(
                  date: approvalDate,
                  color: AppColors.calendarEventQiyas,
                  moduleName: 'Qiyas',
                  taskName: evidenceName,
                  time: displayTime,
                  description: managerPendingDescription,
                  status: 'Pending Approval',
                ));

                managerPendingCount++;
              }

              // ✅ MANAGER CARD 2: APPROVED BY MANAGER
              if (evidenceStatus == 'approved') {

                DateTime? managerApprovalDate;
                final managerApprovalDateField = evidenceData['Manager_Approval_Date'];
                if (managerApprovalDateField is Timestamp) {
                  managerApprovalDate = managerApprovalDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerApprovalDate = actionDateField.toDate();
                  } else {
                    managerApprovalDate = DateTime.now();
                  }
                }

                final period = managerApprovalDate.hour >= 12 ? 'PM' : 'AM';
                final displayHour = managerApprovalDate.hour > 12
                    ? managerApprovalDate.hour - 12
                    : (managerApprovalDate.hour == 0 ? 12 : managerApprovalDate.hour);
                final displayTime =
                    '${displayHour.toString().padLeft(2, '0')}:${managerApprovalDate.minute.toString().padLeft(2, '0')} $period';

                final managerApprovedDescription = isArabic
                    ? 'لقد وافقت على دليل $championName'
                    : 'You have approved $championName\'s evidence';

                events.add(CalendarEventModel(
                  date: managerApprovalDate,
                  color: AppColors.calendarEventQiyas,
                  moduleName: 'Qiyas',
                  taskName: evidenceName,
                  time: displayTime,
                  description: managerApprovedDescription,
                  status: 'Approved',
                ));

                managerApprovedCount++;
              }

              // ✅ MANAGER CARD 3: REJECTED BY MANAGER
              if (evidenceStatus == 'rejected_by_manager' || evidenceStatus == 'rejected') {

                DateTime? managerRejectionDate;
                final managerRejectionDateField = evidenceData['Manager_Rejection_Date'];
                if (managerRejectionDateField is Timestamp) {
                  managerRejectionDate = managerRejectionDateField.toDate();
                } else {
                  final actionDateField = evidenceData['Action_Date'];
                  if (actionDateField is Timestamp) {
                    managerRejectionDate = actionDateField.toDate();
                  } else {
                    managerRejectionDate = DateTime.now();
                  }
                }

                final period = managerRejectionDate.hour >= 12 ? 'PM' : 'AM';
                final displayHour = managerRejectionDate.hour > 12
                    ? managerRejectionDate.hour - 12
                    : (managerRejectionDate.hour == 0 ? 12 : managerRejectionDate.hour);
                final displayTime =
                    '${displayHour.toString().padLeft(2, '0')}:${managerRejectionDate.minute.toString().padLeft(2, '0')} $period';

                final managerRejectedDescription = isArabic
                    ? 'لقد رفضت دليل $championName'
                    : 'You have rejected $championName\'s evidence';

                events.add(CalendarEventModel(
                  date: managerRejectionDate,
                  color: AppColors.calendarEventQiyas,
                  moduleName: 'Qiyas',
                  taskName: evidenceName,
                  time: displayTime,
                  description: managerRejectedDescription,
                  status: 'Rejected',
                ));

                managerRejectedCount++;
              }

            } catch (e) {
            }
          }

        }

      } catch (timeoutError) {
      } catch (e) {
      }


    } catch (e, stackTrace) {
      debugPrint(
        'CalendarDataService: a calendar source failed for $currentUserEmail '
        '— $e\n$stackTrace',
      );
    }

    return events;
  }




  /// Function Name: [getTimeTrackerCalendarEvents]
  ///
  /// Purpose: The signed-in user's Time Tracker calendar entries. ADDED
  /// 9/10/2026 (Time Tracker phase 6) — delegates to
  /// `TimeTrackerCalendarSource.load`, which reads the module's own
  /// repositories (approved leaves, pending requests, transactions, late /
  /// absent days, and for an approver the requests waiting for them). A
  /// failed read throws; `CalendarCubit._collect` records the source.
  ///
  /// Parameters:
  /// - [currentUserEmail]: the signed-in user.
  ///
  /// Returns: [Future<List<CalendarEventModel>>]
  Future<List<CalendarEventModel>> getTimeTrackerCalendarEvents({
    required String currentUserEmail,
  }) =>
      const TimeTrackerCalendarSource().load(
        currentUserEmail: currentUserEmail,
        isArabic: languageCode() == 'ar',
      );

  /// Function Name: [timeTrackerCalendarEntries]
  ///
  /// Purpose: The pure Time Tracker card builder (unit-tested in
  /// test/features/calendar/time_tracker/) — see
  /// `TimeTrackerCalendarSource.entries`. ADDED 9/10/2026.
  ///
  /// Returns: [List<CalendarEventModel>]
  static List<CalendarEventModel> timeTrackerCalendarEntries({
    required List<TimeTrackerRequest> requests,
    required List<AttendanceDay> days,
    required String userEmail,
    required DateTime now,
    required bool isArabic,
    bool showRequests = true,
    bool showAttendance = true,
    bool Function(TimeTrackerRequest request)? waitsForMe,
    String Function(TimeTrackerRequest request)? typeNameOf,
    String Function(String email)? personNameOf,
  }) =>
      TimeTrackerCalendarSource.entries(
        requests: requests,
        days: days,
        userEmail: userEmail,
        now: now,
        isArabic: isArabic,
        showRequests: showRequests,
        showAttendance: showAttendance,
        waitsForMe: waitsForMe,
        typeNameOf: typeNameOf,
        personNameOf: personNameOf,
      );

  /// Function Name: [getTodoCalendarEvents]
  ///
  /// Purpose: The signed-in user's To-Do calendar entries, built from the
  /// user's own To-Do folder `Modules/todo/{email}` (the
  /// module is personal; per-email layout owner-approved 7/10/2026). REWRITTEN 7/10/2026: this used to read the legacy
  /// `Creating_Task` collection, which the new module no longer writes, and
  /// built every card from literal EN/AR strings with the Knowledge Hub
  /// colour and module name 'Todo' (which no module chip matched).
  ///
  /// Every card comes from `TodoCalendarEvent` via
  /// `CalendarEventModel.fromType` — see [todoCalendarEntries] for the rules
  /// (Scheduled before the due date, Due / Overdue on it, Recurring on later
  /// occurrences). Each card's `requestId` is the to-do id, which the
  /// calendar cards use to open that to-do's details.
  ///
  /// A failed query is left to throw: `CalendarCubit._collect` records the
  /// source as failed without affecting the others.
  ///
  /// Parameters:
  /// - [currentUserEmail]: the owner whose to-dos are shown.
  ///
  /// Returns: [Future<List<CalendarEventModel>>]
  Future<List<CalendarEventModel>> getTodoCalendarEvents({
    required String currentUserEmail,
  }) async {
    final List<CalendarEventModel> events = <CalendarEventModel>[];
    final String email = currentUserEmail.trim().toLowerCase();
    // No company signed in: the base path would collapse to a top-level
    // collection, so there is nothing to read.
    if (email.isEmpty || ApiConstants.baseUri.trim().isEmpty) return events;

    // Every document in the user's own folder is theirs — no owner filter.
    final QuerySnapshot<Map<String, dynamic>> todoSnapshot = await _firestore
        .collection(getBaseUrl(TodoFirestorePaths.todosOf(email)))
        .get()
        .timeout(const Duration(seconds: 15));

    final bool isArabic = languageCode() == 'ar';
    final DateTime now = DateTime.now();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in todoSnapshot.docs) {
      final TodoEntity todo;
      try {
        todo = TodoModel.fromSnapshot(doc, ownerEmail: email);
      } on Object catch (_) {
        // One malformed document must not hide the rest of the calendar.
        continue;
      }
      events.addAll(todoCalendarEntries(
        todo,
        now: now,
        isArabic: isArabic,
        userEmail: email,
      ));
    }

    return events;
  }

  /// Function Name: [todoCalendarEntries]
  ///
  /// Purpose: The calendar cards ONE to-do raises — the pure half of
  /// [getTodoCalendarEvents], split out 7/10/2026 so it can be unit-tested
  /// without Firestore (test/features/calendar/todo/).
  ///
  /// REVISED 7/10/2026 (owner feedback): the DUE date (the to-do's end date)
  /// is "the day it must be done", so it carries its own entry.
  ///  • Task Scheduled — every day from the start date up to the day BEFORE
  ///    the due date, at the start time. Start and due on the same day → no
  ///    Scheduled card at all;
  ///  • Task Due — on the due date, at the end time, while it is not overdue
  ///    (a done to-do keeps it);
  ///  • Task Overdue — on the due date INSTEAD of Task Due, once the end time
  ///    has passed and the to-do is not done;
  ///  • Recurring Task Reminder — every later recurrence day (`occursOn`).
  ///    For a scheduled to-do the first occurrence is its own start → due
  ///    span above, so no recurring card lands on any day of that span.
  /// Deleted to-dos raise nothing; done to-dos keep their Scheduled / Due
  /// cards but raise no Overdue or recurrence cards. Days are limited to 60
  /// days back and 180 days ahead of [now]. Every card's `requestId` is the
  /// to-do id, so tapping it can open that to-do's details.
  ///
  /// Parameters:
  /// - [todo]: the to-do (current state of its history document).
  /// - [now]: the clock every rule is evaluated against.
  /// - [isArabic]: language of the catalog title / description.
  /// - [userEmail]: stored on each card (the owner).
  ///
  /// Returns: [List<CalendarEventModel>]
  static List<CalendarEventModel> todoCalendarEntries(
    TodoEntity todo, {
    required DateTime now,
    required bool isArabic,
    required String userEmail,
  }) {
    final List<CalendarEventModel> events = <CalendarEventModel>[];
    if (todo.isDeleted) return events;

    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime windowStart =
        DateTime(today.year, today.month, today.day - 60);
    final DateTime windowEnd =
        DateTime(today.year, today.month, today.day + 180);

    DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
    bool inWindow(DateTime d) =>
        !dayOf(d).isBefore(windowStart) && !dayOf(d).isAfter(windowEnd);
    String timeOf(DateTime d) => DateFormat('hh:mm a', 'en').format(d);

    final String? taskName = todo.name.trim().isEmpty ? null : todo.name;
    CalendarEventModel entry(
      TodoCalendarEvent type,
      DateTime sourceDate,
      String time,
    ) =>
        CalendarEventModel.fromType(
          type,
          sourceDate: sourceDate,
          isArabic: isArabic,
          taskName: taskName,
          time: time,
          requestId: todo.id,
          userEmail: userEmail,
        );

    // The scheduled span: start → due. A missing end falls back to the start
    // (that single day is then the due day), and a due day that sits before
    // the start day (bad data) is pulled up to the start day.
    final DateTime? start = todo.startAt ?? todo.endAt;
    final DateTime? due = todo.endAt ?? todo.startAt;
    final bool hasSpan = todo.isScheduled && start != null && due != null;
    final DateTime? spanFirstDay = hasSpan ? dayOf(start) : null;
    final DateTime? dueDay = hasSpan
        ? (dayOf(due).isBefore(dayOf(start)) ? dayOf(start) : dayOf(due))
        : null;

    // ── Task Scheduled: start → the day before the due date ──────────────
    if (hasSpan) {
      DateTime day =
          spanFirstDay!.isBefore(windowStart) ? windowStart : spanFirstDay;
      while (day.isBefore(dueDay!) && !day.isAfter(windowEnd)) {
        events.add(entry(
          TodoCalendarEvent.taskScheduled,
          DateTime(day.year, day.month, day.day, start.hour, start.minute),
          timeOf(start),
        ));
        day = DateTime(day.year, day.month, day.day + 1);
      }
    }

    // ── Task Overdue — Action Required: on the end date ──────────────────
    // Replaces Task Due once the end time has passed and it is not done.
    final DateTime? endAt = todo.endAt;
    final bool overdue = endAt != null && todo.isOverdue(now);
    if (overdue && inWindow(endAt)) {
      events.add(entry(TodoCalendarEvent.taskOverdue, endAt, timeOf(endAt)));
    }

    // ── Task Due — Action Required: on the due date ──────────────────────
    if (hasSpan && !overdue) {
      final DateTime dueAt = DateTime(
          dueDay!.year, dueDay.month, dueDay.day, due.hour, due.minute);
      if (inWindow(dueAt)) {
        events.add(entry(TodoCalendarEvent.taskDue, dueAt, timeOf(due)));
      }
    }

    // ── Recurring Task Reminder: each later occurrence in the window ─────
    final DateTime? anchor = todo.recurrenceAnchor;
    if (todo.hasFrequency && !todo.isDone && anchor != null) {
      final DateTime anchorDay = dayOf(anchor);
      bool inOwnSpan(DateTime day) =>
          spanFirstDay != null &&
          !day.isBefore(spanFirstDay) &&
          !day.isAfter(dueDay!);
      DateTime day = anchorDay.isBefore(windowStart) ? windowStart : anchorDay;
      while (!day.isAfter(windowEnd)) {
        if (!inOwnSpan(day) &&
            todo.frequency.occursOn(anchor: anchor, day: day)) {
          final DateTime at =
              DateTime(day.year, day.month, day.day, anchor.hour, anchor.minute);
          events.add(entry(
            TodoCalendarEvent.recurringTaskReminder,
            at,
            timeOf(at),
          ));
        }
        day = DateTime(day.year, day.month, day.day + 1);
      }
    }

    return events;
  }


  /// Helper method to check if it's user's turn to approve
  /// Function Name: [_decodeCurrentApprovalCycle]
  ///
  /// Purpose: The LIVE approval cycle out of the `Approval_Cycle` field.
  ///
  /// `Approval_Cycle` is a revision history: `ServicesHistoryModel
  /// .updateApprovalCycle` appends a whole new JSON-encoded cycle every time a
  /// decision is taken, and `currentApprovalCycle` reads `.last`. Only that
  /// last revision is decoded here, for the reason spelled out at the call
  /// site — flattening every revision put each approver in the list once per
  /// revision, and `indexWhere` then returned their state from the OLDEST one.
  ///
  /// Parameters:
  /// - [raw]: the field value, a list of JSON strings.
  ///
  /// Returns: one entry per approver with `email` and `state`, both
  /// lower-cased; empty when the field is absent, empty or unreadable.
  static List<Map<String, String>> _decodeCurrentApprovalCycle(dynamic raw) {
    if (raw is! List || raw.isEmpty) return const <Map<String, String>>[];

    // Skip trailing blanks: a cleared cycle is written as '' or '[]', and the
    // live revision is the last one that actually holds approvers.
    for (int i = raw.length - 1; i >= 0; i--) {
      final dynamic item = raw[i];
      if (item is! String) continue;
      final String text = item.trim();
      if (text.isEmpty || text == '[]' || text == '""') continue;

      try {
        final dynamic decoded = jsonDecode(text);
        if (decoded is! List) continue;

        final List<Map<String, String>> cycle = <Map<String, String>>[];
        for (final dynamic emp in decoded) {
          if (emp is! Map) continue;
          cycle.add(<String, String>{
            'email': (emp['email'] ?? '').toString().trim().toLowerCase(),
            'state': (emp['state'] ?? '').toString().trim().toLowerCase(),
          });
        }
        if (cycle.isNotEmpty) return cycle;
      } catch (_) {
        // Malformed revision — fall back to the one before it.
      }
    }
    return const <Map<String, String>>[];
  }

  /// Function Name: [_epochMs]
  ///
  /// Purpose: A `timestamps` entry as a [DateTime].
  ///
  /// The array holds epoch milliseconds, but written by several paths: as an
  /// `int`, as a `num` (a double epoch), or as a string. All three are
  /// accepted; anything else yields "now" rather than throwing, because one
  /// unreadable timestamp must not cost the whole calendar its service cards.
  static DateTime _epochMs(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    final int? parsed = int.tryParse(value.toString());
    return parsed == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(parsed);
  }

  bool _isMyTurnToApprove({
    required List<Map<String, String>> approvalCycle,
    required String currentUserEmail,
    required int myIndex,
  }) {

    // Check all previous approvers
    for (int i = 0; i < myIndex; i++) {
      final prevState = approvalCycle[i]['state'];

      // If previous approver rejected or canceled, not my turn
      if (['rejected', 'cancel'].contains(prevState)) {
        return false;
      }

      // If previous approver is still pending, not my turn
      if (['pending', 'normal', ''].contains(prevState)) {
        return false;
      }

      // Previous approver must be approved
      if (prevState != 'approved') {
        return false;
      }
    }

    // Check my state
    final myState = approvalCycle[myIndex]['state'];

    final isMyTurn = ['pending', 'normal', ''].contains(myState);

    return isMyTurn;
  }



  /// Get all calendar events from Knowledge Hub module
  /// All Knowledge Hub events use BRONZE color (0xFFCD7F32)
  Future<List<CalendarEventModel>> getKnowledgeHubCalendarEvents({
    required String currentUserEmail,
  }) async {
    List<CalendarEventModel> events = [];

    try {

      String companyIdPath = getBaseUrl('');
      String companyId = '';
      if (companyIdPath.contains('/')) {
        final parts = companyIdPath.split('/');
        if (parts.length >= 2) {
          companyId = parts[1];
        }
      }


      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Card text now comes from KnowledgeHubCalendarEvent, which is
      // bilingual, so the builder needs to know which language to render.
      // Previously every card glued the two languages together with ' / '
      // and showed both to everyone.
      final isArabic = languageCode() == 'ar';

      // ========================================
      // PART 1: GET SCHEDULED DOCUMENTS (startDateTime in future)
      // ========================================
      try {

        final scheduledSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Scheduled query timeout');
          },
        );


        for (var doc in scheduledSnapshot.docs) {
          try {
            final data = doc.data();
            final knowledgeId = doc.id;

            // Get startDateTime
            final startDateTimeArray = data['startDateTime'] as List?;
            if (startDateTimeArray == null || startDateTimeArray.isEmpty) {
              continue;
            }

            final startTimestamp = startDateTimeArray.first;
            final startDateTime = DateTime.fromMillisecondsSinceEpoch(
              startTimestamp is int ? startTimestamp : int.parse(startTimestamp.toString()),
            );

            final startDateOnly = DateTime(
              startDateTime.year,
              startDateTime.month,
              startDateTime.day,
            );


            // ✅ Check if startDateTime is in the FUTURE
            if (startDateOnly.isAfter(today)) {

              // ✅ Get document names in both languages
              final nameEnglishArray = data['nameEnglish'] as List?;
              final nameArabicArray = data['nameArabic'] as List?;

              final nameEnglish = (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                  ? nameEnglishArray.first.toString()
                  : 'Knowledge Document';

              final nameArabic = (nameArabicArray != null && nameArabicArray.isNotEmpty)
                  ? nameArabicArray.first.toString()
                  : 'وثيقة معرفية';

              // ✅ Create bilingual task name
              final taskName = '$nameEnglish / $nameArabic';

              // Format time
              final period = startDateTime.hour >= 12 ? 'PM' : 'AM';
              final displayHour = startDateTime.hour > 12
                  ? startDateTime.hour - 12
                  : (startDateTime.hour == 0 ? 12 : startDateTime.hour);
              final displayTime =
                  '${displayHour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')} $period';

              events.add(CalendarEventModel.fromType(
                KnowledgeHubCalendarEvent.documentScheduled,
                sourceDate: startDateTime,
                isArabic: isArabic,
                taskName: taskName,
                time: displayTime,
              ));

            } else {
            }

          } catch (e) {
          }
        }

      } catch (e) {
      }

      // ========================================
      // PART 2: GET EXPIRING SOON & REMINDERS (endDateTime)
      // ========================================
      try {

        final expiringSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Expiring query timeout');
          },
        );


        for (var doc in expiringSnapshot.docs) {
          try {
            final data = doc.data();
            final knowledgeId = doc.id;

            // Get endDateTime
            final endDateTimeArray = data['endDateTime'] as List?;
            if (endDateTimeArray == null || endDateTimeArray.isEmpty) {
              continue;
            }

            final endTimestamp = endDateTimeArray.first;
            final endDateTime = DateTime.fromMillisecondsSinceEpoch(
              endTimestamp is int ? endTimestamp : int.parse(endTimestamp.toString()),
            );

            final endDateOnly = DateTime(
              endDateTime.year,
              endDateTime.month,
              endDateTime.day,
            );

            final daysUntilEnd = endDateOnly.difference(today).inDays;


            // Skip if already expired (past dates)
            if (daysUntilEnd < 0) {
              continue;
            }

            // ✅ Get document names in both languages FIRST
            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish = (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                ? nameEnglishArray.first.toString()
                : 'Knowledge Document';

            final nameArabic = (nameArabicArray != null && nameArabicArray.isNotEmpty)
                ? nameArabicArray.first.toString()
                : 'وثيقة معرفية';

            // ✅ Create bilingual task name
            final taskName = '$nameEnglish / $nameArabic';

            // ✅ Determine which catalog entry applies, based on how far
            // away the end date is. Both sit ON the end date — the window
            // only decides which bucket (and therefore which filter chip)
            // the card belongs to. See the header of
            // knowledge_hub_calendar_events.dart for why the 14-day
            // reminder is not shifted two weeks earlier.
            final expiryEntry = daysUntilEnd > 14
                ? KnowledgeHubCalendarEvent.documentExpiringSoon
                : KnowledgeHubCalendarEvent.documentValidityExpiring;

            // Format time
            final period = endDateTime.hour >= 12 ? 'PM' : 'AM';
            final displayHour = endDateTime.hour > 12
                ? endDateTime.hour - 12
                : (endDateTime.hour == 0 ? 12 : endDateTime.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')} $period';

            events.add(CalendarEventModel.fromType(
              expiryEntry,
              sourceDate: endDateTime,
              isArabic: isArabic,
              taskName: taskName,
              time: displayTime,
            ));


          } catch (e) {
          }
        }

      } catch (e) {
      }

      // ========================================
      // PART 3: GET PENDING APPROVALS (Supervisor check)
      // ========================================
      try {

        // Get all pending approval documents
        final pendingSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Pending approvals query timeout');
          },
        );


        int pendingCount = 0;

        for (var doc in pendingSnapshot.docs) {
          try {
            final data = doc.data();
            final knowledgeId = doc.id;

            // Get status array and check LATEST status
            final statusArray = data['status'] as List?;
            if (statusArray == null || statusArray.isEmpty) {
              continue;
            }

            // ✅ Get LATEST status (last element)
            final latestStatus = statusArray.last.toString().toLowerCase();


            // Only process if status is pending_approval
            if (latestStatus != 'pending_approval') {
              continue;
            }

            // Get creator email
            final createdByEmailArray = data['createdByEmail'] as List?;
            if (createdByEmailArray == null || createdByEmailArray.isEmpty) {
              continue;
            }

            final creatorEmail = createdByEmailArray.first.toString();

            // Get creator's employee data to find their supervisor
            final mainCoreController = currentEmployee();
            final creatorEmployee = mainCoreController.getLocaleEmployee(creatorEmail);

            if (creatorEmployee == null) {
              continue;
            }


            // Get creator's supervisor email
            final creatorSupervisorEmail = creatorEmployee.supervisor?.trim().toLowerCase();

            if (creatorSupervisorEmail == null || creatorSupervisorEmail.isEmpty) {
              continue;
            }

            final currentUserEmailNormalized = currentUserEmail.trim().toLowerCase();


            // Check if current user is the supervisor
            bool isCurrentUserSupervisor = creatorSupervisorEmail == currentUserEmailNormalized;

            // Also check if user is super admin or has Knowledge Hub admin permission
            bool isSuperAdmin = mainCoreController.isSuperAdmin();
            bool hasKnowledgeHubAdminPermission = false;

            try {
              hasKnowledgeHubAdminPermission = mainCoreController.hasSpecificPermission(
                  Modules.knowledgeHub,
                  'admin_access'
              ) || mainCoreController.hasSpecificPermission(
                  Modules.knowledgeHub,
                  'approve_document'
              );
            } catch (e) {
            }

            bool shouldShowApproval = isCurrentUserSupervisor || isSuperAdmin || hasKnowledgeHubAdminPermission;

            if (!shouldShowApproval) {
              continue;
            }

            // Get submission date (use latest timestamp)
            final timestampsArray = data['timestamps'] as List?;
            DateTime? submissionDate;

            if (timestampsArray != null && timestampsArray.isNotEmpty) {
              final latestTimestamp = timestampsArray.last;
              submissionDate = DateTime.fromMillisecondsSinceEpoch(
                latestTimestamp is int ? latestTimestamp : int.parse(latestTimestamp.toString()),
              );
            }

            if (submissionDate == null) {
              continue;
            }

            String approvalType = 'Supervisor';
            if (isSuperAdmin) approvalType = 'Super Admin';
            if (hasKnowledgeHubAdminPermission) approvalType = 'Knowledge Hub Admin';


            // ✅ Get document names in both languages
            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish = (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                ? nameEnglishArray.first.toString()
                : 'Knowledge Document';

            final nameArabic = (nameArabicArray != null && nameArabicArray.isNotEmpty)
                ? nameArabicArray.first.toString()
                : 'وثيقة معرفية';

            // ✅ Create bilingual task name
            final taskName = '$nameEnglish / $nameArabic';

            // Format time
            final period = submissionDate.hour >= 12 ? 'PM' : 'AM';
            final displayHour = submissionDate.hour > 12
                ? submissionDate.hour - 12
                : (submissionDate.hour == 0 ? 12 : submissionDate.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${submissionDate.minute.toString().padLeft(2, '0')} $period';

            events.add(CalendarEventModel.fromType(
              KnowledgeHubCalendarEvent.approvalPending,
              sourceDate: submissionDate,
              isArabic: isArabic,
              taskName: taskName,
              time: displayTime,
              // Which hat the signed-in user is wearing for this approval —
              // Supervisor / Super Admin / Knowledge Hub Admin. Carried as
              // roleName because that is exactly what it is.
              variables: {TemplateVariable.roleName: approvalType},
            ));

            pendingCount++;

          } catch (e) {
          }
        }


      } catch (e) {
      }

      // ========================================
      // PART 4: GET PUBLISHED DOCUMENTS (immediate)
      // ========================================
      //
      // ADDED 1/9/2026 — the first row of the Knowledge Hub block in §2 of
      // "Knowticed Plus — Notification & Validation":
      //
      //   Document Published (immediate) → "Document Published and Effective"
      //   "Appears on calendar immediately upon publication. Expiry date is
      //    visible if an End Date is set."
      //
      // `KnowledgeHubCalendarEvent.documentPublished` has existed since the
      // module was migrated onto the calendar enums, and nothing built an
      // occurrence from it: PART 1 covers documents still WAITING to be
      // published, PART 2 their expiry and PART 3 the approval queue, so the
      // one moment the spec puts first — the document going live — was the
      // one moment missing from the calendar. A published policy simply never
      // appeared on the day it took effect.
      //
      // The card is placed on the publication date, which is the FIRST
      // `published` entry in the status history (`publishedAt` on the model
      // uses the same rule) rather than the document's `startDateTime`: an
      // unscheduled document has a start date of "whenever it was created",
      // and a document approved late went live after its planned start.
      try {

        final publishedSnapshot = await _firestore
            .collection(FirebaseCollections.demo)
            .doc(companyId)
            .collection(FirebaseCollections.createKnowledge)
            .get()
            .timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Published query timeout');
          },
        );

        for (var doc in publishedSnapshot.docs) {
          try {
            final data = doc.data();

            // Only documents that are live RIGHT NOW. A document that was
            // published and later removed or archived should not keep
            // advertising itself as effective.
            final statusArray = List<dynamic>.from(data['status'] ?? []);
            if (statusArray.isEmpty) continue;
            final currentStatus =
                statusArray.last.toString().toLowerCase().trim();
            if (currentStatus != 'published') continue;

            // The date it BECAME published — the first 'published' in the
            // history, paired with the timestamp recorded alongside it.
            final publishedIndex = statusArray.indexWhere(
              (s) => s.toString().toLowerCase().trim() == 'published',
            );
            if (publishedIndex == -1) continue;

            final timestampsArray = List<dynamic>.from(data['timestamps'] ?? []);
            if (publishedIndex >= timestampsArray.length) continue;

            final rawTimestamp = timestampsArray[publishedIndex];
            final publishedAt = DateTime.fromMillisecondsSinceEpoch(
              rawTimestamp is int
                  ? rawTimestamp
                  : int.parse(rawTimestamp.toString()),
            );

            final nameEnglishArray = data['nameEnglish'] as List?;
            final nameArabicArray = data['nameArabic'] as List?;

            final nameEnglish =
                (nameEnglishArray != null && nameEnglishArray.isNotEmpty)
                    ? nameEnglishArray.first.toString()
                    : 'Knowledge Document';

            final nameArabic =
                (nameArabicArray != null && nameArabicArray.isNotEmpty)
                    ? nameArabicArray.first.toString()
                    : 'وثيقة معرفية';

            final taskName = '$nameEnglish / $nameArabic';

            final period = publishedAt.hour >= 12 ? 'PM' : 'AM';
            final displayHour = publishedAt.hour > 12
                ? publishedAt.hour - 12
                : (publishedAt.hour == 0 ? 12 : publishedAt.hour);
            final displayTime =
                '${displayHour.toString().padLeft(2, '0')}:${publishedAt.minute.toString().padLeft(2, '0')} $period';

            events.add(CalendarEventModel.fromType(
              KnowledgeHubCalendarEvent.documentPublished,
              sourceDate: publishedAt,
              isArabic: isArabic,
              taskName: taskName,
              time: displayTime,
            ));

          } catch (e) {
          }
        }

      } catch (e) {
      }


    } catch (e, stackTrace) {
      debugPrint(
        'CalendarDataService: a calendar source failed for $currentUserEmail '
        '— $e\n$stackTrace',
      );
    }

    return events;
  }

  /// Function Name: [getServicesCalendarEvents]
  ///
  /// Purpose: Every calendar entry the Service Management module raises for
  /// one signed-in user — as provider, as requester, or as the middle manager
  /// over either.
  ///
  /// Colour, title and status all come from [ServicesCalendarEvent]; nothing
  /// here passes a literal for them.
  ///
  /// TIDIED 30/8/2026: the doc comment above this was five verbatim copies of
  /// the same two lines, and the body ended with two `for` loops that read
  /// `events[i]` into a variable and did nothing with it — the remains of
  /// removed debug printing.
  Future<List<CalendarEventModel>> getServicesCalendarEvents({
    required String currentUserEmail,
  }) async {

    if (currentUserEmail.isEmpty) {
      return [];
    }

    List<CalendarEventModel> events = [];

    try {
      // ⚠️ Same wrong path as [getApprovalCalendarEvents] had — see the note
      // there. `Demo/<companyId>/RequestServices` does not exist; the module
      // stores requests under `Modules/services/RequestServices`.
      final snapshot = await FirebaseFirestore.instance
          .collection(getBaseUrl(FirestoreCollections.requestServicesRoot))
          .get();


      final now = DateTime.now();

      // ✅ Get current locale to determine language
      final currentLocale = languageCode();
      final isArabic = currentLocale == 'ar';


      // ✅ Get main core controllers
      final mainCoreController = currentEmployee();
      final departmentController = departmentCubit;

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final model = ServicesHistoryModel.fromJson(data, doc.id);


          // ✅ Get service names in both languages
          final serviceNameEnglish = model.currentServiceNameEnglish.isNotEmpty
              ? model.currentServiceNameEnglish
              : 'Service';

          final serviceNameArabic = model.currentServiceNameArabic.isNotEmpty
              ? model.currentServiceNameArabic
              : 'خدمة';

          // ✅ Create bilingual task name
          final taskName = '$serviceNameEnglish / $serviceNameArabic';


          // Get final state
          final state = _getFinalStateFromModel(model);

          // Get user involvement
          final assignedEmail = model.currentAssignedProviderEmail.toLowerCase().trim();
          final requesterEmails = model.currentEmailRequester;
          final isAssignedToUser = assignedEmail == currentUserEmail.toLowerCase().trim();
          final isRequestedByUser = requesterEmails.contains(currentUserEmail.toLowerCase().trim());


          // ✅ Get provider and requester details for manager check
          final providerEmployee = mainCoreController.getLocaleEmployee(assignedEmail);
          final requesterEmail = requesterEmails.isNotEmpty ? requesterEmails.toLowerCase().trim() : '';
          final requesterEmployee = requesterEmail.isNotEmpty
              ? mainCoreController.getLocaleEmployee(requesterEmail)
              : null;

          // ✅ Check if current user is Middle Management in relevant departments
          bool isMiddleManagementForService = false;
          String managerDepartment = '';

          final currentEmployee = mainCoreController.getLocaleEmployee(currentUserEmail);
          if (currentEmployee != null && currentEmployee.role?.toLowerCase() == 'middle management') {
            if (providerEmployee != null &&
                currentEmployee.departmentId == providerEmployee.departmentId) {
              isMiddleManagementForService = true;
              managerDepartment = currentEmployee.departmentId ?? '';
            } else if (requesterEmployee != null &&
                currentEmployee.departmentId == requesterEmployee.departmentId) {
              isMiddleManagementForService = true;
              managerDepartment = currentEmployee.departmentId ?? '';
            }
          }

          // Skip if not relevant to current user
          if (!isAssignedToUser && !isRequestedByUser && !isMiddleManagementForService) {
            continue;
          }

          // ✅ Get timestamps array
          final timestampsArray = data['timestamps'] as List?;
          if (timestampsArray == null || timestampsArray.isEmpty) {
            continue;
          }

          // ✅ Get status history array to find when it moved to InProgress
          final statusHistoryArray = data['status'] as List?;


          // ✅ STAGE 1: APPROVED - Add "Assigned" card (for provider only)
          if (['approved', 'inprogress', 'done'].contains(state.toLowerCase())) {
            if (isAssignedToUser) {

              final approvedTimestamp = timestampsArray.first;
              final eventDate = DateTime.fromMillisecondsSinceEpoch(
                approvedTimestamp is int ? approvedTimestamp : int.parse(approvedTimestamp.toString()),
              );

              events.add(CalendarEventModel.fromType(
                ServicesCalendarEvent.assignedToProvider,
                sourceDate: eventDate,
                isArabic: isArabic,
                taskName: taskName,
                time: DateFormat('hh:mm a').format(eventDate),
              ));

            }
          }

          // ✅ STAGE 2: INPROGRESS — the start date and the SLA deadline
          //
          // Cards raised here: "Due" on the deadline (provider), and
          // "In Progress" on the actual start date for BOTH the requester and
          // — since 1/9/2026 — the provider, plus the SLA breach cards for
          // every party while the request is still open.
          if (['inprogress', 'done'].contains(state.toLowerCase())) {

            DateTime? dueDate;

            // The ACTUAL moment work started — the timestamp paired with the
            // first `InProgress` entry, falling back to the second timestamp
            // on documents written before the two arrays were kept in step.
            // CHANGED 1/9/2026 — this lookup was written out here and again in
            // STAGE 3, where the fallback was missing; both now call
            // [_inProgressStart].
            final DateTime? inProgressStartTime = _inProgressStart(
              statusHistory: statusHistoryArray,
              timestamps: timestampsArray,
            );

            if (inProgressStartTime != null) {
              // The SLA deadline runs from the moment work actually started.
              // CHANGED 1/9/2026 — this was thirty lines of inline duration
              // arithmetic, duplicated verbatim in STAGE 3 below. Both copies
              // are now one call to [_serviceDueDate], so the two stages can
              // no longer disagree about when a request was due.
              dueDate = _serviceDueDate(data: data, from: inProgressStartTime);

              // ✅ Add Due event for provider
              if (isAssignedToUser && dueDate != null) {

                final dueDateStr = DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.dueForProvider,
                  sourceDate: dueDate,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(dueDate),
                  variables: {TemplateVariable.dueDate: dueDateStr},
                ));

              }

              // ✅ Add "In Progress" event for REQUESTER
              if (isRequestedByUser && dueDate != null) {

                final completionDateStr = DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.inProgressForRequester,
                  sourceDate: inProgressStartTime,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(inProgressStartTime),
                  variables: {TemplateVariable.dueDate: completionDateStr},
                ));

              }

              // ✅ Add "In Progress" event for the PROVIDER
              //
              // ADDED 1/9/2026 — §2 "Service Status Changed to In Progress":
              // "The event records the actual start date."
              //
              // The provider is the person who MAKES that status change, and
              // they were the one party with no card on the day it happened.
              // The card immediately above gives the requester the start date;
              // the provider only had `dueForProvider`, which sits on the
              // DEADLINE. So the calendar could tell a provider when a job was
              // assigned and when it was due, but never when work on it began
              // — the one date the spec row is actually about.
              if (isAssignedToUser && dueDate != null) {

                final providerDueStr =
                    DateFormat('MMM dd, yyyy hh:mm a').format(dueDate);

                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.inProgressForProvider,
                  sourceDate: inProgressStartTime,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: DateFormat('hh:mm a').format(inProgressStartTime),
                  variables: {TemplateVariable.dueDate: providerDueStr},
                ));

              }

              // ✅ Check for SLA breach (only if InProgress)
              if (state.toLowerCase() == 'inprogress' && dueDate != null) {

                if (now.isAfter(dueDate)) {

                  final period = dueDate.hour >= 12 ? 'PM' : 'AM';
                  final displayHour = dueDate.hour > 12
                      ? dueDate.hour - 12
                      : (dueDate.hour == 0 ? 12 : dueDate.hour);
                  final displayTime =
                      '${displayHour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')} $period';

                  // Add SLA card for provider
                  if (isAssignedToUser) {
                    events.add(CalendarEventModel.fromType(
                      ServicesCalendarEvent.slaBreachedProvider,
                      sourceDate: dueDate,
                      isArabic: isArabic,
                      taskName: taskName,
                      time: displayTime,
                    ));
                  }

                  // Add SLA card for requester
                  if (isRequestedByUser) {
                    events.add(CalendarEventModel.fromType(
                      ServicesCalendarEvent.slaBreachedRequester,
                      sourceDate: dueDate,
                      isArabic: isArabic,
                      taskName: taskName,
                      time: displayTime,
                    ));
                  }

                  // Add SLA card for middle management
                  if (isMiddleManagementForService && !isAssignedToUser && !isRequestedByUser) {

                    String departmentName = departmentController.getDepartmentName(managerDepartment, true);
                    String departmentNameAr = departmentController.getDepartmentName(managerDepartment, false);

                    events.add(CalendarEventModel.fromType(
                      ServicesCalendarEvent.slaBreachedManagement,
                      sourceDate: dueDate,
                      isArabic: isArabic,
                      taskName: taskName,
                      time: displayTime,
                      variables: {
                        TemplateVariable.departmentName:
                            isArabic ? departmentNameAr : departmentName,
                      },
                    ));
                  }

                } else {
                }
              }
            }
          }

          // ✅ STAGE 3: DONE — completion cards for EVERY relevant party
          //
          // REWRITTEN 1/9/2026 — §2 of the revised spec, two rows:
          //
          //   "Service Completion Date Reached → Completion date reached; all
          //    relevant parties are notified simultaneously."
          //   "Service Status Changed to Done → Service Completed."
          //
          // This whole stage used to sit inside `if (isRequestedByUser)`, so
          // completion was a requester-only event. The provider who did the
          // work watched the request disappear from their calendar the moment
          // they closed it, and a middle manager saw completions not at all —
          // management appeared in this builder for exactly one thing, an SLA
          // breach, which made the calendar a list of that department's
          // failures with none of its deliveries.
          //
          // The SLA comparison is now computed once, above the audience
          // branches, instead of inside the requester branch. It also drove
          // thirty lines of duplicated duration arithmetic, which is now the
          // same [_serviceDueDate] helper STAGE 2 uses — the two stages could
          // previously disagree about when a request was due.
          if (state.toLowerCase() == 'done') {

            final doneTimestamp = timestampsArray.last;
            final eventDate = DateTime.fromMillisecondsSinceEpoch(
              doneTimestamp is int
                  ? doneTimestamp
                  : int.parse(doneTimestamp.toString()),
            );

            // Did it land after the SLA deadline? Needed by the requester's
            // wording, and by the retained breach record below.
            final DateTime? inProgressStart = _inProgressStart(
              statusHistory: statusHistoryArray,
              timestamps: timestampsArray,
            );
            final DateTime? slaDeadline = inProgressStart == null
                ? null
                : _serviceDueDate(data: data, from: inProgressStart);
            final bool exceededSLA =
                slaDeadline != null && eventDate.isAfter(slaDeadline);

            final String doneTime = DateFormat('hh:mm a').format(eventDate);

            // ── Requester ────────────────────────────────────────────────
            if (isRequestedByUser) {
              events.add(CalendarEventModel.fromType(
                exceededSLA
                    ? ServicesCalendarEvent.doneAfterSlaForRequester
                    : ServicesCalendarEvent.doneForRequester,
                sourceDate: eventDate,
                isArabic: isArabic,
                taskName: taskName,
                time: doneTime,
              ));
            }

            // ── Provider ─────────────────────────────────────────────────
            if (isAssignedToUser) {
              events.add(CalendarEventModel.fromType(
                ServicesCalendarEvent.doneForProvider,
                sourceDate: eventDate,
                isArabic: isArabic,
                taskName: taskName,
                time: doneTime,
              ));
            }

            // ── Middle management ────────────────────────────────────────
            //
            // Only when the manager is neither party, matching the guard the
            // SLA branch already uses — otherwise a manager who raised or
            // fulfilled the request themselves would get two cards for one
            // completion.
            if (isMiddleManagementForService &&
                !isAssignedToUser &&
                !isRequestedByUser) {
              final String departmentName =
                  departmentController.getDepartmentName(managerDepartment, true);
              final String departmentNameAr =
                  departmentController.getDepartmentName(managerDepartment, false);

              events.add(CalendarEventModel.fromType(
                ServicesCalendarEvent.doneForManagement,
                sourceDate: eventDate,
                isArabic: isArabic,
                taskName: taskName,
                time: doneTime,
                variables: {
                  TemplateVariable.departmentName:
                      isArabic ? departmentNameAr : departmentName,
                },
              ));
            }

            // ── The breach itself, retained ──────────────────────────────
            //
            // ADDED 1/9/2026. §2 row 1 says an SLA breach is "Visible to
            // Manager, Service Provider, and Requester. Escalation action
            // recommended." The breach cards in STAGE 2 are gated on
            // `state == 'inprogress'`, so the moment the provider marked a
            // late request Done, every trace of the breach left the calendar
            // — for the provider and the manager, the two people escalation
            // is aimed at, it vanished entirely. Closing a ticket late is
            // exactly the case a manager needs to still be able to see.
            //
            // The requester is deliberately excluded: their
            // [doneAfterSlaForRequester] card above already says the deadline
            // was missed, and a second card would say it twice.
            if (exceededSLA && slaDeadline != null) {
              final String breachTime =
                  DateFormat('hh:mm a').format(slaDeadline);

              if (isAssignedToUser) {
                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.slaBreachedProvider,
                  sourceDate: slaDeadline,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: breachTime,
                ));
              }

              if (isMiddleManagementForService &&
                  !isAssignedToUser &&
                  !isRequestedByUser) {
                final String departmentName = departmentController
                    .getDepartmentName(managerDepartment, true);
                final String departmentNameAr = departmentController
                    .getDepartmentName(managerDepartment, false);

                events.add(CalendarEventModel.fromType(
                  ServicesCalendarEvent.slaBreachedManagement,
                  sourceDate: slaDeadline,
                  isArabic: isArabic,
                  taskName: taskName,
                  time: breachTime,
                  variables: {
                    TemplateVariable.departmentName:
                        isArabic ? departmentNameAr : departmentName,
                  },
                ));
              }
            }
          }

        } catch (e) {
          continue;
        }
      }


    } catch (e, stackTrace) {
      debugPrint(
        'CalendarDataService: a calendar source failed for $currentUserEmail '
        '— $e\n$stackTrace',
      );
    }

    return events;
  }

  // Helper methods

  /// Function Name: [_inProgressStart]
  ///
  /// Purpose: When work on a service request ACTUALLY started — the timestamp
  /// paired with the first `InProgress` entry in the status history.
  ///
  /// ADDED 1/9/2026. This lookup existed twice, written out longhand in
  /// STAGE 2 and again in STAGE 3 of [getServicesCalendarEvents], and only one
  /// of the two copies had the fallback. §2 of the spec hangs the in-progress
  /// calendar entry off "the actual start date", so getting this wrong moves
  /// a card rather than dropping it, which is harder to notice.
  ///
  /// Parameters:
  /// - [statusHistory]: the document's `status` array, parallel to
  ///   [timestamps]. May be null on older documents.
  /// - [timestamps]: the document's `timestamps` array.
  ///
  /// Returns: [DateTime] of the transition, or null when neither the status
  /// history nor the two-entry fallback can place it.
  DateTime? _inProgressStart({
    required List<dynamic>? statusHistory,
    required List<dynamic> timestamps,
  }) {
    int? index;
    if (statusHistory != null) {
      for (int i = 0; i < statusHistory.length; i++) {
        if (statusHistory[i].toString().toLowerCase() == 'inprogress') {
          index = i;
          break;
        }
      }
    }

    // Fallback for documents written before the status history was kept in
    // step with the timestamps: the second entry is the first transition
    // after submission.
    final int? resolved = (index != null && timestamps.length > index)
        ? index
        : (timestamps.length >= 2 ? 1 : null);
    if (resolved == null) return null;

    final dynamic raw = timestamps[resolved];
    return DateTime.fromMillisecondsSinceEpoch(
      raw is int ? raw : int.parse(raw.toString()),
    );
  }

  /// Function Name: [_serviceDueDate]
  ///
  /// Purpose: The SLA deadline for a service request, measured from [from]
  /// using the request's own `durationOfServices` + `selectedDurationUnit`.
  ///
  /// ADDED 1/9/2026. This switch was written out twice inside
  /// [getServicesCalendarEvents] — once to place the provider's Due card and
  /// the breach cards, once to decide whether a completed request had
  /// overrun. Two copies of the same arithmetic deciding "was this late?" in
  /// two different places is a drift waiting to happen, and the completion
  /// branch is the one a manager relies on.
  ///
  /// Parameters:
  /// - [data]: the raw request document.
  /// - [from]: the point the clock starts — the in-progress timestamp.
  ///
  /// Returns: the deadline, or null when the request carries no usable
  /// duration (nothing recorded, unparseable, or zero) — callers treat that
  /// as "no SLA to breach" rather than as an immediate breach.
  DateTime? _serviceDueDate({
    required Map<String, dynamic> data,
    required DateTime from,
  }) {
    final List? durationArray = data['durationOfServices'] as List?;
    final List? durationUnitArray = data['selectedDurationUnit'] as List?;

    if (durationArray == null ||
        durationArray.isEmpty ||
        durationUnitArray == null ||
        durationUnitArray.isEmpty) {
      return null;
    }

    final int durationValue =
        int.tryParse(durationArray.first.toString()) ?? 0;
    if (durationValue <= 0) return null;

    switch (durationUnitArray.first.toString().toLowerCase()) {
      case 'minutes':
        return from.add(Duration(minutes: durationValue));
      case 'hours':
        return from.add(Duration(hours: durationValue));
      case 'days':
        return from.add(Duration(days: durationValue));
      case 'weeks':
        return from.add(Duration(days: durationValue * 7));
      case 'months':
        return DateTime(
          from.year,
          from.month + durationValue,
          from.day,
          from.hour,
          from.minute,
        );
      default:
        // Unrecognised unit — the original code fell back to hours rather
        // than dropping the deadline, and that is kept: a request with a
        // duration but a typo'd unit should still have an SLA.
        return from.add(Duration(hours: durationValue));
    }
  }

  String _getFinalStateFromModel(ServicesHistoryModel service) {
    final stateField = service.currentState.toLowerCase();

    if (['cancel', 'inprogress', 'done', 'branchsla', 'breached sla'].contains(stateField)) {
      return stateField;
    }

    final approvalCycle = service.currentApprovalCycle;
    final hasApprovalCycle = approvalCycle.isNotEmpty;

    if (!hasApprovalCycle) {
      if (stateField.isEmpty || stateField == 'pending') {
        return 'approved';
      }
      return stateField.isEmpty ? 'approved' : stateField;
    }

    final states = approvalCycle
        .where((e) => e.state != null && e.state!.isNotEmpty)
        .map((e) => e.state!.toLowerCase())
        .toList();

    if (states.contains('cancel')) return 'cancel';
    if (states.contains('rejected')) return 'rejected';
    if (states.every((s) => s == 'approved') && states.isNotEmpty) return 'approved';
    if (states.contains('pending')) return 'pending';

    if (stateField.isNotEmpty) {
      return stateField;
    }

    return 'approved';
  }

  String? _getArrayValue(dynamic field) {
    if (field == null) return null;
    if (field is List && field.isNotEmpty) {
      return field.first?.toString();
    }
    if (field is String) return field;
    return field.toString();
  }
}