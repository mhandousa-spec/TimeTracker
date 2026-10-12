// ****************** FILE INFO ******************
// File Name: crm_templates_remote_data_source.dart
// Purpose: Remote Firestore data source for CRM template builder operations
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_history_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_layout_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_template_default_sync_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_template_defaults.dart';

class CrmTemplatesRemoteDataSource {
  final FirebaseFirestore _firestore;

  /// Session-scoped guard for [syncDefaultsForAllTemplates]: the sync is an
  /// idempotent seed operation, so it runs at most once per app process
  /// instead of on every page open.
  static bool _defaultsSyncedThisSession = false;

  CrmTemplatesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Either<Failure, CrmTemplateModel>> createTemplateDraft({
    required String clientTypeId,
    required String nameEn,
    required String nameAr,
    required String userEmail,
    String? templateId,
  }) async {
    try {
      final String id = templateId ??
          _firestore.collection(CrmFirestorePaths.templates).doc().id;
      final CrmTemplateModel template = CrmTemplateModel(
        id: id,
        clientTypeId: clientTypeId,
        nameEn: nameEn,
        nameAr: nameAr,
        status: 'active',
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      final Either<Failure, void> result = await _setDocument(
        collectionPath: CrmFirestorePaths.templates,
        documentId: template.id,
        data: template.toMap(),
      );
      if (result.isLeft()) return _draftFailure(result, template);

      await _trackTemplateChange(
        history: _createHistory(
          templateId: template.id,
          targetType: 'template',
          targetId: template.id,
          action: 'created',
          before: const {},
          after: template.toMap(),
          changedBy: userEmail,
        ),
      );

      final Either<Failure, void> defaults = await ensureTemplateDefaults(
        templateId: template.id,
        clientTypeId: clientTypeId,
        userEmail: userEmail,
      );
      if (defaults.isLeft()) return _draftFailure(defaults, template);

      return Right(template.copyWith(fieldCount: 13, sectionCount: 2));
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> ensureTemplateDefaults({
    required String templateId,
    required String clientTypeId,
    required String userEmail,
  }) async {
    try {
      final List<CrmTemplateSectionModel> sections =
          CrmTemplateDefaults.sections(
        templateId: templateId,
        clientTypeId: clientTypeId,
        userEmail: userEmail,
      );
      final List<CrmTemplateFieldModel> fields = CrmTemplateDefaults.fields(
        templateId: templateId,
        clientTypeId: clientTypeId,
        userEmail: userEmail,
      );

      final WriteBatch batch = _firestore.batch();
      final List<CrmTemplateHistoryModel> historyItems = [];

      // One parallel read batch fetches every candidate section/field document
      // instead of 15 sequential .get() calls per template.
      final List<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          await Future.wait(<Future<DocumentSnapshot<Map<String, dynamic>>>>[
        ...sections.map(
          (CrmTemplateSectionModel section) =>
              _docRef(CrmFirestorePaths.templateSections, section.id).get(),
        ),
        ...fields.map(
          (CrmTemplateFieldModel field) =>
              _docRef(CrmFirestorePaths.templateFields, field.id).get(),
        ),
      ]);
      final Map<String, DocumentSnapshot<Map<String, dynamic>>> docsById =
          <String, DocumentSnapshot<Map<String, dynamic>>>{
        for (final DocumentSnapshot<Map<String, dynamic>> snapshot in snapshots)
          snapshot.id: snapshot,
      };

      for (final CrmTemplateSectionModel section in sections) {
        final DocumentSnapshot<Map<String, dynamic>>? doc =
            docsById[section.id];
        if (doc?.exists ?? false) continue;
        batch.set(
          _docRef(CrmFirestorePaths.templateSections, section.id),
          section.toMap(),
        );
        historyItems.add(
          _createHistory(
            templateId: templateId,
            targetType: 'section',
            targetId: section.id,
            action: 'created',
            before: const {},
            after: section.toMap(),
            changedBy: userEmail,
          ),
        );
      }

      for (final CrmTemplateFieldModel field in fields) {
        final DocumentSnapshot<Map<String, dynamic>>? doc = docsById[field.id];
        if (doc?.exists != true) {
          batch.set(
            _docRef(CrmFirestorePaths.templateFields, field.id),
            field.toMap(),
          );
          historyItems.add(
            _createHistory(
              templateId: templateId,
              targetType: 'field',
              targetId: field.id,
              action: 'created',
              before: const {},
              after: field.toMap(),
              changedBy: userEmail,
            ),
          );
          continue;
        }

        final Map<String, dynamic> fieldData =
            doc!.data() ?? <String, dynamic>{};
        final CrmTemplateFieldModel existing =
            CrmTemplateFieldModel.fromMap(fieldData);
        final CrmTemplateFieldModel merged =
            CrmTemplateDefaultSyncHelper.mergeFieldWithDefault(
          existing: existing,
          defaultField: field,
        );
        if (!CrmTemplateDefaultSyncHelper.needsSync(
          existing: existing,
          merged: merged,
        )) {
          continue;
        }

        final CrmTemplateFieldModel updated = merged.copyWith(
          audit: _updatedAudit(
            before: fieldData,
            changedBy: userEmail,
          ),
        );
        batch.set(
          _docRef(CrmFirestorePaths.templateFields, field.id),
          updated.toMap(),
        );
        historyItems.add(
          _createHistory(
            templateId: templateId,
            targetType: 'field',
            targetId: field.id,
            action: 'defaults_synced',
            before: fieldData,
            after: updated.toMap(),
            changedBy: userEmail,
          ),
        );
      }

      for (final CrmTemplateHistoryModel history in historyItems) {
        batch.set(
          _docRef(CrmFirestorePaths.templateHistory, history.id),
          history.toMap(),
        );
      }

      batch.set(
        _docRef(CrmFirestorePaths.templates, templateId),
        {
          CrmFirestoreKeys.SECTION_COUNT_KEY: sections.length,
          CrmFirestoreKeys.FIELD_COUNT_KEY: fields.length,
          CrmFirestoreKeys.DEFAULTS_VERSION_KEY:
              CrmTemplateDefaults.defaultsVersion,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
              Timestamp.now(),
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
              _normalizeUser(userEmail),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, List<CrmTemplateModel>>> watchTemplates() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
          _firestore.collection(CrmFirestorePaths.templates).snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmTemplateModel> items = snapshot.docs
            .map((doc) => CrmTemplateModel.fromMap(doc.data()))
            .where((template) => template.status != 'deleted')
            .toList();
        items.sort((a, b) => b.audit.createdAt.compareTo(a.audit.createdAt));
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> syncDefaultsForAllTemplates({
    required String userEmail,
  }) async {
    if (_defaultsSyncedThisSession) return const Right(null);
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.templates).get();
      final List<CrmTemplateModel> templates =
          snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return CrmTemplateModel.fromMap(doc.data());
      }).where((CrmTemplateModel template) {
        return template.status.toLowerCase() != 'deleted';
      }).toList();

      for (final CrmTemplateModel template in templates) {
        // Templates already stamped with the current defaults version and that
        // still carry the expected number of sections/fields are in sync — skip
        // them so we avoid per-template Firestore round trips. Missing defaults
        // (e.g. a deleted default field) still get healed because the count
        // check then fails.
        final bool matchesVersion =
            template.defaultsVersion == CrmTemplateDefaults.defaultsVersion;
        final bool hasExpectedCounts = matchesVersion &&
            template.sectionCount >=
                CrmTemplateDefaults.sections(
                  templateId: template.id,
                  clientTypeId: template.clientTypeId,
                  userEmail: userEmail,
                ).length &&
            template.fieldCount >=
                CrmTemplateDefaults.fields(
                  templateId: template.id,
                  clientTypeId: template.clientTypeId,
                  userEmail: userEmail,
                ).length;
        if (hasExpectedCounts) continue;
        final Either<Failure, void> result = await ensureTemplateDefaults(
          templateId: template.id,
          clientTypeId: template.clientTypeId,
          userEmail: userEmail,
        );
        if (result.isLeft()) return result;
      }
      _defaultsSyncedThisSession = true;
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, CrmTemplateModel?>> watchTemplate({
    required String templateId,
  }) async* {
    try {
      final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          _firestore
              .collection(CrmFirestorePaths.templates)
              .doc(templateId)
              .snapshots();

      await for (final DocumentSnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final Map<String, dynamic>? data = snapshot.data();
        yield Right(data == null ? null : CrmTemplateModel.fromMap(data));
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, List<CrmTemplateSectionModel>>> watchTemplateSections({
    required String templateId,
  }) async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
          _firestore.collection(CrmFirestorePaths.templateSections).snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmTemplateSectionModel> items = snapshot.docs
            .map((doc) => CrmTemplateSectionModel.fromMap(doc.data()))
            .where((section) => section.templateId == templateId)
            .where(
                (section) => !section.isDeleted && section.status != 'deleted')
            .toList();
        items.sort((a, b) => a.order.compareTo(b.order));
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, List<CrmTemplateFieldModel>>> watchTemplateFields({
    required String templateId,
  }) async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
          _firestore.collection(CrmFirestorePaths.templateFields).snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmTemplateFieldModel> items = snapshot.docs
            .map((doc) => CrmTemplateFieldModel.fromMap(doc.data()))
            .where((field) => field.templateId == templateId)
            .where((field) => !field.isDeleted && field.status != 'deleted')
            .toList();
        items.sort((a, b) => a.order.compareTo(b.order));
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, CrmTemplateLayoutModel?>> watchTemplateLayout({
    required String templateId,
  }) async* {
    try {
      final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          _firestore
              .collection(CrmFirestorePaths.templateLayouts)
              .doc(templateId)
              .snapshots();

      await for (final DocumentSnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final Map<String, dynamic>? data = snapshot.data();
        yield Right(data == null ? null : CrmTemplateLayoutModel.fromMap(data));
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> addTemplateField({
    required CrmTemplateFieldModel field,
    required String changedBy,
  }) async {
    final Either<Failure, void> result = await _setDocument(
      collectionPath: CrmFirestorePaths.templateFields,
      documentId: field.id,
      data: field.toMap(),
    );
    if (result.isLeft()) return result;
    await _updateTemplateCounts(
        templateId: field.templateId, changedBy: changedBy);
    return _trackTemplateChange(
      history: _createHistory(
        templateId: field.templateId,
        targetType: 'field',
        targetId: field.id,
        action: 'created',
        before: const {},
        after: field.toMap(),
        changedBy: changedBy,
      ),
    );
  }

  Either<Failure, CrmTemplateModel> _draftFailure(
    Either<Failure, void> result,
    CrmTemplateModel template,
  ) =>
      result.fold((failure) => Left(failure), (_) => Right(template));

  Future<Either<Failure, void>> updateTemplateField({
    required CrmTemplateFieldModel field,
    required String changedBy,
  }) async {
    final Map<String, dynamic> before = await _getDocumentMap(
      collectionPath: CrmFirestorePaths.templateFields,
      documentId: field.id,
    );
    if (before.isEmpty) {
      return Left(FeatureFailure('Template field not found: ${field.id}'));
    }
    final CrmTemplateFieldModel audited = field.copyWith(
      audit: _updatedAudit(before: before, changedBy: changedBy),
    );
    final Either<Failure, void> result = await _setDocument(
      collectionPath: CrmFirestorePaths.templateFields,
      documentId: field.id,
      data: audited.toMap(),
    );
    if (result.isLeft()) return result;
    await _updateTemplateAudit(
        templateId: field.templateId, changedBy: changedBy);
    return _trackTemplateChange(
      history: _createHistory(
        templateId: field.templateId,
        targetType: 'field',
        targetId: field.id,
        action: 'updated',
        before: before,
        after: audited.toMap(),
        changedBy: changedBy,
      ),
    );
  }

  Future<Either<Failure, void>> removeTemplateField({
    required String templateId,
    required String fieldId,
    required String changedBy,
  }) async {
    return _softDeleteTemplateItem(
      collectionPath: CrmFirestorePaths.templateFields,
      templateId: templateId,
      itemId: fieldId,
      targetType: 'field',
      changedBy: changedBy,
    );
  }

  Future<Either<Failure, void>> addTemplateSection({
    required CrmTemplateSectionModel section,
    required String changedBy,
  }) async {
    final Either<Failure, void> result = await _setDocument(
      collectionPath: CrmFirestorePaths.templateSections,
      documentId: section.id,
      data: section.toMap(),
    );
    if (result.isLeft()) return result;
    await _updateTemplateCounts(
        templateId: section.templateId, changedBy: changedBy);
    return _trackTemplateChange(
      history: _createHistory(
        templateId: section.templateId,
        targetType: 'section',
        targetId: section.id,
        action: 'created',
        before: const {},
        after: section.toMap(),
        changedBy: changedBy,
      ),
    );
  }

  Future<Either<Failure, void>> updateTemplateSection({
    required CrmTemplateSectionModel section,
    required String changedBy,
  }) async {
    final Map<String, dynamic> before = await _getDocumentMap(
      collectionPath: CrmFirestorePaths.templateSections,
      documentId: section.id,
    );
    if (before.isEmpty) {
      return Left(FeatureFailure('Template section not found: ${section.id}'));
    }
    final CrmTemplateSectionModel audited = section.copyWith(
      audit: _updatedAudit(before: before, changedBy: changedBy),
    );
    final Either<Failure, void> result = await _setDocument(
      collectionPath: CrmFirestorePaths.templateSections,
      documentId: section.id,
      data: audited.toMap(),
    );
    if (result.isLeft()) return result;
    await _updateTemplateAudit(
      templateId: section.templateId,
      changedBy: changedBy,
    );
    return _trackTemplateChange(
      history: _createHistory(
        templateId: section.templateId,
        targetType: 'section',
        targetId: section.id,
        action: 'updated',
        before: before,
        after: audited.toMap(),
        changedBy: changedBy,
      ),
    );
  }

  Future<Either<Failure, void>> removeTemplateSection({
    required String templateId,
    required String sectionId,
    required String changedBy,
  }) async {
    return _softDeleteTemplateItem(
      collectionPath: CrmFirestorePaths.templateSections,
      templateId: templateId,
      itemId: sectionId,
      targetType: 'section',
      changedBy: changedBy,
    );
  }

  Future<Either<Failure, void>> saveTemplateLayout({
    required CrmTemplateLayoutModel layout,
    required String changedBy,
  }) async {
    final Map<String, dynamic> before = await _getDocumentMap(
      collectionPath: CrmFirestorePaths.templateLayouts,
      documentId: layout.templateId,
    );
    final Either<Failure, void> result = await _setDocument(
      collectionPath: CrmFirestorePaths.templateLayouts,
      documentId: layout.templateId,
      data: layout.toMap(),
    );
    if (result.isLeft()) return result;
    await _updateTemplateAudit(
      templateId: layout.templateId,
      changedBy: changedBy,
      extraData: {CrmFirestoreKeys.PAGE_COUNT_KEY: layout.pages.length},
    );
    return _trackTemplateChange(
      history: _createHistory(
        templateId: layout.templateId,
        targetType: 'layout',
        targetId: layout.templateId,
        action: before.isEmpty ? 'created' : 'updated',
        before: before,
        after: layout.toMap(),
        changedBy: changedBy,
      ),
    );
  }

  Future<Either<Failure, void>> updateTemplateStatus({
    required String templateId,
    required String status,
    required String changedBy,
  }) async {
    final Map<String, dynamic> before = await _getDocumentMap(
      collectionPath: CrmFirestorePaths.templates,
      documentId: templateId,
    );
    if (before.isEmpty) {
      return Left(FeatureFailure('Template not found: $templateId'));
    }

    final String normalizedStatus = status.trim().toLowerCase();
    final Timestamp now = Timestamp.now();
    final int nextVersion =
        ((CrmFirestoreKeys.read(before, CrmFirestoreKeys.VERSION_KEY, 'version')
                        as num?)
                    ?.toInt() ??
                1) +
            1;
    final Map<String, dynamic> after = Map<String, dynamic>.from(before);
    after[CrmFirestoreKeys.STATUS_KEY] = normalizedStatus;
    after[CrmFirestoreKeys.VERSION_KEY] = nextVersion;
    if (normalizedStatus == 'active') {
      after[CrmFirestoreKeys.PUBLISHED_AT_KEY] = now;
    }

    final Map<String, dynamic> data = {
      CrmFirestoreKeys.STATUS_KEY: normalizedStatus,
      CrmFirestoreKeys.VERSION_KEY: nextVersion,
      '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}': now,
      '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
          _normalizeUser(changedBy),
    };
    if (normalizedStatus == 'active') {
      data[CrmFirestoreKeys.PUBLISHED_AT_KEY] = now;
    }

    try {
      await _firestore
          .collection(CrmFirestorePaths.templates)
          .doc(templateId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }

    return _trackTemplateChange(
      history: _createHistory(
        templateId: templateId,
        targetType: 'template',
        targetId: templateId,
        action: 'status_changed',
        before: before,
        after: after,
        changedBy: changedBy,
      ),
    );
  }

  Future<Either<Failure, void>> updateTemplateNames({
    required String templateId,
    required String nameEn,
    required String nameAr,
    required String changedBy,
  }) async {
    final Timestamp now = Timestamp.now();

    try {
      await _docRef(CrmFirestorePaths.templates, templateId).update({
        CrmFirestoreKeys.NAME_EN_KEY: nameEn.trim(),
        CrmFirestoreKeys.NAME_AR_KEY: nameAr.trim(),
        '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}': now,
        '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
            _normalizeUser(changedBy),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return Left(FeatureFailure('Template not found: $templateId'));
      }
      return Left(FirebaseFailure(e.toString()));
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }

    return const Right(null);
  }

  Future<Either<Failure, void>> _setDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final Either<FirebaseFailure, dynamic> result =
        await FirebaseRepository.setDocumentWithId(
      collection: collectionPath,
      documentId: documentId,
      data: data,
    );
    return result.fold((failure) => Left(failure), (_) => const Right(null));
  }

  Future<Either<Failure, void>> _trackTemplateChange({
    required CrmTemplateHistoryModel history,
  }) {
    return _setDocument(
      collectionPath: CrmFirestorePaths.templateHistory,
      documentId: history.id,
      data: history.toMap(),
    );
  }

  DocumentReference<Map<String, dynamic>> _docRef(
    String collectionPath,
    String documentId,
  ) {
    return _firestore.collection(collectionPath).doc(documentId);
  }

  Future<Map<String, dynamic>> _getDocumentMap({
    required String collectionPath,
    required String documentId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _docRef(collectionPath, documentId).get();
    return doc.data() ?? <String, dynamic>{};
  }

  Future<void> _updateTemplateCounts({
    required String templateId,
    required String changedBy,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> sectionsSnapshot =
        await _firestore.collection(CrmFirestorePaths.templateSections).get();
    final QuerySnapshot<Map<String, dynamic>> fieldsSnapshot =
        await _firestore.collection(CrmFirestorePaths.templateFields).get();
    final int sectionCount = sectionsSnapshot.docs
        .map((doc) => CrmTemplateSectionModel.fromMap(doc.data()))
        .where((section) => section.templateId == templateId)
        .where((section) => !section.isDeleted && section.status != 'deleted')
        .length;
    final int fieldCount = fieldsSnapshot.docs
        .map((doc) => CrmTemplateFieldModel.fromMap(doc.data()))
        .where((field) => field.templateId == templateId)
        .where((field) => !field.isDeleted && field.status != 'deleted')
        .length;
    await _updateTemplateAudit(
      templateId: templateId,
      changedBy: changedBy,
      extraData: {
        CrmFirestoreKeys.SECTION_COUNT_KEY: sectionCount,
        CrmFirestoreKeys.FIELD_COUNT_KEY: fieldCount,
      },
    );
  }

  Future<void> _updateTemplateAudit({
    required String templateId,
    required String changedBy,
    Map<String, dynamic> extraData = const {},
  }) async {
    await _firestore
        .collection(CrmFirestorePaths.templates)
        .doc(templateId)
        .set(
      {
        ...extraData,
        '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
            Timestamp.now(),
        '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
            _normalizeUser(changedBy),
      },
      SetOptions(merge: true),
    );
  }

  Future<Either<Failure, void>> _softDeleteTemplateItem({
    required String collectionPath,
    required String templateId,
    required String itemId,
    required String targetType,
    required String changedBy,
  }) async {
    final Map<String, dynamic> before = await _getDocumentMap(
      collectionPath: collectionPath,
      documentId: itemId,
    );
    if (before.isEmpty) {
      return Left(FeatureFailure('Template $targetType not found: $itemId'));
    }
    final Timestamp now = Timestamp.now();
    final Map<String, dynamic> after = Map<String, dynamic>.from(before);
    after[CrmFirestoreKeys.IS_DELETED_KEY] = true;
    after[CrmFirestoreKeys.STATUS_KEY] = 'deleted';

    try {
      await _firestore.collection(collectionPath).doc(itemId).set(
        {
          CrmFirestoreKeys.IS_DELETED_KEY: true,
          CrmFirestoreKeys.STATUS_KEY: 'deleted',
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
              now,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
              _normalizeUser(changedBy),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
    await _updateTemplateCounts(templateId: templateId, changedBy: changedBy);
    return _trackTemplateChange(
      history: _createHistory(
        templateId: templateId,
        targetType: targetType,
        targetId: itemId,
        action: 'deleted',
        before: before,
        after: after,
        changedBy: changedBy,
      ),
    );
  }

  CrmAuditModel _updatedAudit({
    required Map<String, dynamic> before,
    required String changedBy,
  }) {
    final Map<String, dynamic> audit = Map<String, dynamic>.from(
      CrmFirestoreKeys.read(before, CrmFirestoreKeys.AUDIT_KEY, 'audit')
              as Map? ??
          const {},
    );
    audit[CrmFirestoreKeys.UPDATED_AT_KEY] = Timestamp.now();
    audit[CrmFirestoreKeys.UPDATED_BY_KEY] = _normalizeUser(changedBy);
    return CrmAuditModel.fromMap(audit);
  }

  CrmTemplateHistoryModel _createHistory({
    required String templateId,
    required String targetType,
    required String targetId,
    required String action,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
    required String changedBy,
  }) {
    return CrmTemplateHistoryModel(
      id: _firestore.collection(CrmFirestorePaths.templateHistory).doc().id,
      templateId: templateId,
      targetType: targetType,
      targetId: targetId,
      action: action,
      before: before,
      after: after,
      changedBy: _normalizeUser(changedBy),
      changedAt: DateTime.now(),
    );
  }

  String _normalizeUser(String userEmail) {
    return userEmail.trim().toLowerCase();
  }
}
