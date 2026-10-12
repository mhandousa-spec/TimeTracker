/// Module: database / db1_create_database / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: database_notification_dispatcher.dart
/// Purpose: Turns a completed database write into the notifications it owes.
/// Author: Knowticed Plus team
/// Created at: 17/8/2026
///
/// The database side of the notification wiring. `DatabaseNotificationService`
/// (in the notification feature) knows how to SEND each of the thirteen §1.7
/// events and takes nothing but plain strings; this class knows WHO to send
/// them to and WHICH ones a given save earned, and it is the only thing that
/// speaks both languages.
///
/// ─── WHY IT IS HERE AND NOT IN THE NOTIFICATION FEATURE ──────────────
/// It reads `DatabaseAccessGrant`, `DatabaseMember` and db1's repository. A
/// feature raises its OWN notifications, so the dependency runs
/// database → notification and never back; putting this logic beside the
/// sender would make the notification feature import three database entities
/// and a repository, and every future database entity after them.
///
/// ─── WHY IT IS IN db1 ────────────────────────────────────────────────
/// db2 and db3 already import db1's entities, constants and repository; db1
/// imports neither of them. Recipients always come from a DATABASE's grants —
/// including for table events — so this needs db1's `fetchGrants` and nothing
/// of db2's or db3's. Table names arrive as strings for the same reason: taking
/// a `DatabaseTableEntity` would point db1 at db3.
///
/// ─── NAMES ARRIVE IN BOTH LANGUAGES ──────────────────────────────────
/// Every name parameter is a `…En` / `…Ar` pair, resolved here against the
/// actor's locale with the same "fall back to the other side" rule
/// `DatabaseEntity.localizedTitle` uses. Passing one pre-localized string would
/// send an Arabic body naming an English table, which is what happens when the
/// caller localizes with `context` and the notification does not.
///
/// ─── EVERY METHOD SWALLOWS ITS ERRORS ────────────────────────────────
/// A notification is a side effect of a write that has ALREADY succeeded. If
/// FCM is unreachable or a template read times out, the user's database still
/// exists and the screen must still say so. Nothing here rethrows, and callers
/// are expected to `await` these only to keep the call ordered — never to learn
/// whether the write worked.
///
/// ─── FIRE-AND-FORGET IS THE CALLER'S CHOICE ──────────────────────────
/// These are `Future<void>`. A cubit that awaits one holds its success state
/// back until the sends finish, which on a nine-person grant is nine template
/// reads plus nine pushes. Cubits therefore call these WITHOUT awaiting, after
/// emitting success — see `CreateDatabaseCubit._write`.

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/database/db1_create_database/data/repository/create_database_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/base_repository/create_database_base_repository.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_access_grant.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_permission_level.dart';
import 'package:knowticed_plus/features/notification/data/repository/database_notification_service.dart';

/// Who is doing the thing, in the language it will be announced in.
///
/// Resolved once per dispatch rather than per recipient: a save that notifies
/// nine people has one actor, and `getEmployeeNameEnglishArabic` walks the
/// directory map on every call.
class DatabaseNotificationActor {
  const DatabaseNotificationActor({
    required this.email,
    required this.name,
    required this.isArabic,
  });

  final String email;
  final String name;
  final bool isArabic;
}

abstract final class DatabaseNotificationDispatcher {
  const DatabaseNotificationDispatcher._();

  /// Reading a database's grants to find recipients costs one Firestore read
  /// per dispatch; the repository is built once.
  static final CreateDatabaseBaseRepository _repository =
      CreateDatabaseRepository();

  /// How many `columnAdded` notifications one save may send.
  ///
  /// The spec's body names the column ("A new column, {{columnName}}, has
  /// been..."), so there is no plural form to fall back on — a save that added
  /// twenty columns would be twenty notifications per recipient. Past this
  /// count the individual ones are dropped and `tableStructureUpdated` carries
  /// the news instead, which is what it is for.
  static const int maxColumnNotifications = 5;

  /// More than one person affected by one access save makes it a BULK update in
  /// the spec's sense (§1.7 row 10) — the actor gets the summary receipt on top
  /// of the individual notifications the affected people get.
  static const int bulkThreshold = 2;

  // ═══════════════════════════════════════════════════════════
  // Actor / recipients
  // ═══════════════════════════════════════════════════════════

  /// The signed-in user, or the system sentinel when nobody is.
  ///
  /// GetX in a data-layer file is the same escape hatch `calendar_data_service`
  /// documents: `Constant.emailUser` and the employee directory are only
  /// reachable through the controller today. Every public method below takes an
  /// `actor` override, so nothing here is untestable — pass one and this is
  /// never called.
  static DatabaseNotificationActor resolveActor() {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    final String email = (Constant.emailUser ?? '').trim();
    if (email.isEmpty) {
      return DatabaseNotificationActor(
        email: DatabaseNotificationService.systemSender,
        name: '',
        isArabic: isArabic,
      );
    }

    String name = '';
    try {
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        name = Get
            .find<MainCoreEmployeeController>()
            .getEmployeeNameEnglishArabic(email, !isArabic)
            .trim();
      }
    } catch (_) {
      // A missing controller must not stop the notification — the body then
      // names the actor by email, which is still an identification.
    }

    return DatabaseNotificationActor(
      email: email,
      name: name.isEmpty ? email : name,
      isArabic: isArabic,
    );
  }

  /// Emails on [grants], deduped, minus [exclude].
  ///
  /// A member with no stored email is skipped rather than sent to: the grant
  /// carries the email as a snapshot and older rows may not have one.
  /// `AppNotificationSender` refuses an empty receiver anyway, so this only
  /// keeps the counts honest.
  static Set<String> recipientsOf(
    Iterable<DatabaseAccessGrant> grants, {
    String? exclude,
  }) {
    final String? excluded = exclude?.trim().toLowerCase();
    final Set<String> emails = <String>{};

    for (final DatabaseAccessGrant grant in grants) {
      for (final DatabaseMember member in grant.members) {
        final String email = (member.email ?? '').trim();
        if (email.isEmpty) continue;
        if (email.toLowerCase() == excluded) continue;
        emails.add(email);
      }
    }
    return emails;
  }

  /// Everyone holding a grant on [databaseId] right now, minus the actor.
  ///
  /// Used by the TABLE events, which have no grant list of their own to read: a
  /// table's structural news is relevant to whoever can see the database it
  /// sits in. A failed read yields nobody rather than throwing — see the
  /// header.
  static Future<Set<String>> databaseRecipients(
    String databaseId, {
    required String actorEmail,
  }) async {
    if (databaseId.isEmpty) return <String>{};
    try {
      final Either<Failure, List<DatabaseAccessGrant>> result =
          await _repository.fetchGrants(databaseId);
      return result.fold(
        (Failure _) => <String>{},
        (List<DatabaseAccessGrant> grants) =>
            recipientsOf(grants, exclude: actorEmail),
      );
    } catch (_) {
      return <String>{};
    }
  }

  // ═══════════════════════════════════════════════════════════
  // db1 — the create wizard
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [databaseCreated]
  ///
  /// Purpose: Announce a finished database and each window it opened.
  ///
  /// TWO KINDS OF NOTIFICATION, DELIBERATELY. `databaseCreated` is the news
  /// ("X created HR Database"), broadcast to everyone on it; `accessGranted` is
  /// each person's own window ("you have Edit until 30 Sep"), which cannot be
  /// broadcast because every value in it differs per grant.
  ///
  /// Call this ONLY for a finished write. A record parked by "Save For Later"
  /// has granted nobody anything yet — notifying its members would announce a
  /// database that appears in no list but Drafts.
  static Future<void> databaseCreated({
    required String databaseNameEn,
    required String databaseNameAr,
    required List<DatabaseAccessGrant> grants,
    DatabaseNotificationActor? actor,
  }) async {
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String> recipients = recipientsOf(grants, exclude: who.email);
    if (recipients.isEmpty) return;

    final String databaseName =
        _localized(databaseNameEn, databaseNameAr, who.isArabic);
    final String scope =
        DatabaseNotificationService.allTablesLabel(isArabic: who.isArabic);

    await DatabaseNotificationService.databaseCreated(
      actorEmail: who.email,
      actorName: who.name,
      databaseName: databaseName,
      recipients: recipients,
      isArabic: who.isArabic,
    );

    await _announceGrants(
      grants: grants,
      databaseName: databaseName,
      tableName: scope,
      who: who,
    );

    if (recipients.length >= bulkThreshold) {
      await DatabaseNotificationService.bulkAccessUpdate(
        actorEmail: who.email,
        actorName: who.name,
        databaseName: databaseName,
        tableName: scope,
        isArabic: who.isArabic,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // db2 / db3 — access edits
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [accessSaved]
  ///
  /// Purpose: Work out what changed for whom, and tell each of them.
  ///
  /// [before] is the grants as they were LOADED, [after] the grants just
  /// written. The diff is by `employeeId` (`DatabaseMember`'s identity), so a
  /// person moved between two grants in one save is an UPDATE, not a revoke
  /// followed by a grant — which is what a naive per-grant comparison would
  /// report, and would tell them twice.
  ///
  /// Three outcomes per person:
  ///   • in [after] only            → accessGranted
  ///   • in both, rule differs      → accessUpdated
  ///   • in [before] only           → accessRevoked
  ///
  /// A person in both whose rule is IDENTICAL gets nothing. Every access save
  /// rewrites the whole subcollection, so without that check re-saving one
  /// person's dates would notify all nine.
  ///
  /// [tableNameEn] / [tableNameAr] are null for a database-level save and the
  /// table's names for a table-level one; they decide both what the bodies say
  /// and whether [viewableFieldsChanged] can mean anything.
  static Future<void> accessSaved({
    required String databaseNameEn,
    required String databaseNameAr,
    String? tableNameEn,
    String? tableNameAr,
    required List<DatabaseAccessGrant> before,
    required List<DatabaseAccessGrant> after,
    bool viewableFieldsChanged = false,
    DatabaseNotificationActor? actor,
  }) async {
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final String databaseName =
        _localized(databaseNameEn, databaseNameAr, who.isArabic);

    final bool isTableLevel =
        (tableNameEn?.isNotEmpty ?? false) || (tableNameAr?.isNotEmpty ?? false);
    final String? tableName = isTableLevel
        ? _localized(tableNameEn ?? '', tableNameAr ?? '', who.isArabic)
        : null;
    final String scope = tableName ??
        DatabaseNotificationService.allTablesLabel(isArabic: who.isArabic);

    final Map<String, _MemberGrant> was = _byEmployee(before);
    final Map<String, _MemberGrant> now = _byEmployee(after);

    int affected = 0;

    for (final MapEntry<String, _MemberGrant> entry in now.entries) {
      final _MemberGrant current = entry.value;
      final String email = (current.member.email ?? '').trim();
      if (email.isEmpty) continue;
      if (email.toLowerCase() == who.email.toLowerCase()) continue;

      final _MemberGrant? previous = was[entry.key];

      if (previous == null) {
        affected++;
        await DatabaseNotificationService.accessGranted(
          actorEmail: who.email,
          recipientEmail: email,
          databaseName: databaseName,
          tableName: scope,
          permissionLabel:
              _permissionLabel(current.grant, isArabic: who.isArabic),
          startDate: current.grant.startDate,
          endDate: current.grant.endDate,
          isArabic: who.isArabic,
        );
        continue;
      }

      if (_ruleChanged(previous.grant, current.grant)) {
        affected++;
        await DatabaseNotificationService.accessUpdated(
          actorEmail: who.email,
          recipientEmail: email,
          databaseName: databaseName,
          tableName: scope,
          isArabic: who.isArabic,
        );
      }
    }

    for (final MapEntry<String, _MemberGrant> entry in was.entries) {
      if (now.containsKey(entry.key)) continue;

      final String email = (entry.value.member.email ?? '').trim();
      if (email.isEmpty) continue;
      if (email.toLowerCase() == who.email.toLowerCase()) continue;

      affected++;
      await DatabaseNotificationService.accessRevoked(
        actorEmail: who.email,
        actorName: who.name,
        recipientEmail: email,
        databaseName: databaseName,
        tableName: scope,
        isArabic: who.isArabic,
      );
    }

    // Field visibility is a TABLE-level notion: `viewableFields` holds column
    // ids, and a database grant has no columns to name. A database-level save
    // that somehow flagged this is ignored rather than sent with a scope its
    // own body cannot describe.
    if (viewableFieldsChanged && tableName != null) {
      final Set<String> remaining = recipientsOf(after, exclude: who.email);
      if (remaining.isNotEmpty) {
        await DatabaseNotificationService.viewableFieldsUpdated(
          actorEmail: who.email,
          tableName: tableName,
          recipients: remaining,
          isArabic: who.isArabic,
        );
      }
    }

    if (affected >= bulkThreshold) {
      await DatabaseNotificationService.bulkAccessUpdate(
        actorEmail: who.email,
        actorName: who.name,
        databaseName: databaseName,
        tableName: scope,
        isArabic: who.isArabic,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // db3 — tables
  // ═══════════════════════════════════════════════════════════

  /// Function Name: [tableCreated]
  ///
  /// Purpose: Tell the database's members a table was added.
  static Future<void> tableCreated({
    required String databaseId,
    required String databaseNameEn,
    required String databaseNameAr,
    required String tableNameEn,
    required String tableNameAr,
    DatabaseNotificationActor? actor,
  }) async {
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String> recipients =
        await databaseRecipients(databaseId, actorEmail: who.email);
    if (recipients.isEmpty) return;

    await DatabaseNotificationService.tableCreated(
      actorEmail: who.email,
      actorName: who.name,
      databaseName: _localized(databaseNameEn, databaseNameAr, who.isArabic),
      tableName: _localized(tableNameEn, tableNameAr, who.isArabic),
      recipients: recipients,
      isArabic: who.isArabic,
    );
  }

  /// Function Name: [tableSaved]
  ///
  /// Purpose: The edit-card counterpart — up to three different pieces of news
  /// out of one save.
  ///
  /// The three are independent and any combination can fire:
  ///   [detailsChanged]   the name, description or comments-access moved
  ///                                                      → tableUpdated
  ///   [addedColumnNames] new columns, named               → columnAdded ×N
  ///   [structureChanged] columns removed, reordered or
  ///                      retyped, or more than
  ///                      [maxColumnNotifications] added   → tableStructureUpdated
  ///
  /// A save that changed only the comments-access dropdown counts as
  /// [detailsChanged]: that event's body says "the table name, description, or
  /// associated metadata", which is what the setting is.
  static Future<void> tableSaved({
    required String databaseId,
    required String databaseNameEn,
    required String databaseNameAr,
    required String tableNameEn,
    required String tableNameAr,
    bool detailsChanged = false,
    bool structureChanged = false,
    List<String> addedColumnNames = const <String>[],
    DatabaseNotificationActor? actor,
  }) async {
    if (!detailsChanged && !structureChanged && addedColumnNames.isEmpty) {
      return;
    }

    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String> recipients =
        await databaseRecipients(databaseId, actorEmail: who.email);
    if (recipients.isEmpty) return;

    final String tableName =
        _localized(tableNameEn, tableNameAr, who.isArabic);

    if (detailsChanged) {
      await DatabaseNotificationService.tableUpdated(
        actorEmail: who.email,
        actorName: who.name,
        tableName: tableName,
        recipients: recipients,
        isArabic: who.isArabic,
      );
    }

    final bool tooManyColumns =
        addedColumnNames.length > maxColumnNotifications;

    if (!tooManyColumns) {
      for (final String column in addedColumnNames) {
        final String name = column.trim();
        if (name.isEmpty) continue;
        await DatabaseNotificationService.columnAdded(
          actorEmail: who.email,
          columnName: name,
          tableName: tableName,
          recipients: recipients,
          isArabic: who.isArabic,
        );
      }
    }

    if (structureChanged || tooManyColumns) {
      await DatabaseNotificationService.tableStructureUpdated(
        actorEmail: who.email,
        tableName: tableName,
        recipients: recipients,
        isArabic: who.isArabic,
      );
    }
  }

  /// Function Name: [tableDeleted]
  ///
  /// Purpose: Announce a permanent removal.
  ///
  /// ⚠️ RESOLVE THE RECIPIENTS BEFORE THE DELETE, NOT AFTER, and hand them in
  /// via [recipients]. The database's grants survive a table delete so the
  /// fallback read still returns somebody, but people holding access to the
  /// TABLE and not to the database would otherwise never hear that it went.
  ///
  /// NO CALL SITE YET: `CreateTableRepository.deleteTable` exists and no screen
  /// invokes it — the table card has no Delete row in the Figma section that has
  /// been built. Wire this in beside that call when it lands.
  static Future<void> tableDeleted({
    required String databaseId,
    required String databaseNameEn,
    required String databaseNameAr,
    required String tableNameEn,
    required String tableNameAr,
    Set<String>? recipients,
    DatabaseNotificationActor? actor,
  }) async {
    final DatabaseNotificationActor who = actor ?? resolveActor();

    final Set<String> targets = recipients ??
        await databaseRecipients(databaseId, actorEmail: who.email);
    if (targets.isEmpty) return;

    await DatabaseNotificationService.tableDeleted(
      actorEmail: who.email,
      databaseName: _localized(databaseNameEn, databaseNameAr, who.isArabic),
      tableName: _localized(tableNameEn, tableNameAr, who.isArabic),
      recipients: targets,
      isArabic: who.isArabic,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Internals
  // ═══════════════════════════════════════════════════════════

  /// One `accessGranted` per member per grant.
  static Future<void> _announceGrants({
    required List<DatabaseAccessGrant> grants,
    required String databaseName,
    required String tableName,
    required DatabaseNotificationActor who,
  }) async {
    for (final DatabaseAccessGrant grant in grants) {
      for (final DatabaseMember member in grant.members) {
        final String email = (member.email ?? '').trim();
        if (email.isEmpty) continue;
        if (email.toLowerCase() == who.email.toLowerCase()) continue;

        await DatabaseNotificationService.accessGranted(
          actorEmail: who.email,
          recipientEmail: email,
          databaseName: databaseName,
          tableName: tableName,
          permissionLabel: _permissionLabel(grant, isArabic: who.isArabic),
          startDate: grant.startDate,
          endDate: grant.endDate,
          isArabic: who.isArabic,
        );
      }
    }
  }

  /// Flattens grants into one entry per person.
  ///
  /// LAST GRANT WINS for someone who appears on two. That is not a state the
  /// screens can produce — db2 dedupes a department's members against the
  /// individually-picked ones — but a document written by an older build could
  /// hold it, and picking one is the only way to send that person one
  /// notification instead of two that contradict each other.
  static Map<String, _MemberGrant> _byEmployee(
    Iterable<DatabaseAccessGrant> grants,
  ) {
    final Map<String, _MemberGrant> byId = <String, _MemberGrant>{};
    for (final DatabaseAccessGrant grant in grants) {
      for (final DatabaseMember member in grant.members) {
        if (member.employeeId.isEmpty) continue;
        byId[member.employeeId] = _MemberGrant(member: member, grant: grant);
      }
    }
    return byId;
  }

  /// True when anything the person would care about differs.
  ///
  /// Dates are compared by DAY: a grant read back from Firestore carries the
  /// time it was stored with while the picker returns midnight, so a timestamp
  /// comparison would report a change on every save.
  /// `DatabaseAccessGrant.dateOnly` is the same notion of "a day" the entity's
  /// own validation uses.
  ///
  /// `viewableFields` is compared as a SET — reordering the columns a person may
  /// see is not a change to what they may see.
  static bool _ruleChanged(
    DatabaseAccessGrant before,
    DatabaseAccessGrant after,
  ) {
    if (before.permission != after.permission) return true;
    if (!_sameDay(before.startDate, after.startDate)) return true;
    if (!_sameDay(before.endDate, after.endDate)) return true;

    final Set<String> wasFields = before.viewableFields.toSet();
    final Set<String> nowFields = after.viewableFields.toSet();
    if (wasFields.length != nowFields.length) return true;
    return !wasFields.containsAll(nowFields);
  }

  static bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == null && b == null;
    return DatabaseAccessGrant.dateOnly(a) == DatabaseAccessGrant.dateOnly(b);
  }

  /// The permission level as the recipient's language spells it.
  ///
  /// An unset level renders as an em dash rather than "null": a complete grant
  /// always has one (`DatabaseAccessGrant.isComplete` gates every save), so this
  /// only surfaces on a legacy document.
  static String _permissionLabel(
    DatabaseAccessGrant grant, {
    required bool isArabic,
  }) {
    final DatabasePermissionLevel? level = grant.permission;
    if (level == null) return '—';
    return isArabic ? level.labelAr : level.labelEn;
  }

  /// The side of a bilingual name the actor's locale asks for, falling back to
  /// the other when it is empty — the rule `DatabaseEntity.localizedTitle` and
  /// `DatabaseTableEntity.localizedName` already apply on screen.
  static String _localized(String en, String ar, bool isArabic) {
    if (isArabic) return ar.isNotEmpty ? ar : en;
    return en.isNotEmpty ? en : ar;
  }
}

/// A person paired with the grant they are on, so the diff can report both who
/// changed and what their new rule is without walking the grants twice.
class _MemberGrant {
  const _MemberGrant({required this.member, required this.grant});

  final DatabaseMember member;
  final DatabaseAccessGrant grant;
}
