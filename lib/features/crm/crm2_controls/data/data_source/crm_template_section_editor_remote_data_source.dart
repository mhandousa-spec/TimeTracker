// ****************** FILE INFO ******************
// File Name: crm_template_section_editor_remote_data_source.dart
// Purpose: Batch Firestore operations for CRM template section editing
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_history_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmTemplateSectionEditorRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmTemplateSectionEditorRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Either<Failure, void>> saveSectionWithFields({
    required CrmTemplateSectionModel section,
    required List<CrmTemplateFieldModel> fields,
    required String changedBy,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();
      final String user = _normalizeUser(changedBy);
      final Map<String, dynamic> sectionBefore = await _getDocumentMap(
        collectionPath: CrmFirestorePaths.templateSections,
        documentId: section.id,
      );
      final CrmTemplateSectionModel savedSection = section.copyWith(
        audit: _updatedAudit(before: sectionBefore, changedBy: user),
      );
      batch.set(
        _firestore
            .collection(CrmFirestorePaths.templateSections)
            .doc(section.id),
        savedSection.toMap(),
      );
      _history(
        batch: batch,
        templateId: section.templateId,
        targetType: 'section',
        targetId: section.id,
        action: sectionBefore.isEmpty ? 'created' : 'updated',
        before: sectionBefore,
        after: savedSection.toMap(),
        changedBy: user,
      );

      for (final CrmTemplateFieldModel field in fields) {
        final Map<String, dynamic> before = await _getDocumentMap(
          collectionPath: CrmFirestorePaths.templateFields,
          documentId: field.id,
        );
        final CrmTemplateFieldModel savedField = field.copyWith(
          audit: _updatedAudit(before: before, changedBy: user),
        );
        batch.set(
          _firestore.collection(CrmFirestorePaths.templateFields).doc(field.id),
          savedField.toMap(),
        );
        _history(
          batch: batch,
          templateId: field.templateId,
          targetType: 'field',
          targetId: field.id,
          action: before.isEmpty ? 'created' : 'updated',
          before: before,
          after: savedField.toMap(),
          changedBy: user,
        );
      }

      await batch.commit();
      await _updateCounts(templateId: section.templateId, user: user);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeSectionWithFields({
    required String templateId,
    required String sectionId,
    required String changedBy,
  }) async {
    try {
      final WriteBatch batch = _firestore.batch();
      final String user = _normalizeUser(changedBy);
      final Map<String, dynamic> sectionBefore = await _getDocumentMap(
        collectionPath: CrmFirestorePaths.templateSections,
        documentId: sectionId,
      );
      if (sectionBefore.isEmpty) {
        return Left(FeatureFailure('Template section not found: $sectionId'));
      }
      final Map<String, dynamic> sectionAfter =
          _deletedMap(sectionBefore, changedBy: user);
      batch.set(
        _firestore
            .collection(CrmFirestorePaths.templateSections)
            .doc(sectionId),
        sectionAfter,
        SetOptions(merge: true),
      );
      _history(
        batch: batch,
        templateId: templateId,
        targetType: 'section',
        targetId: sectionId,
        action: 'deleted',
        before: sectionBefore,
        after: sectionAfter,
        changedBy: user,
      );

      final QuerySnapshot<Map<String, dynamic>> fields =
          await _firestore.collection(CrmFirestorePaths.templateFields).get();
      for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
          in fields.docs) {
        final CrmTemplateFieldModel field =
            CrmTemplateFieldModel.fromMap(doc.data());
        if (field.templateId != templateId || field.sectionId != sectionId) {
          continue;
        }
        if (field.isDeleted || field.status == 'deleted') continue;
        final Map<String, dynamic> before = doc.data();
        final Map<String, dynamic> after = _deletedMap(before, changedBy: user);
        batch.set(doc.reference, after, SetOptions(merge: true));
        _history(
          batch: batch,
          templateId: templateId,
          targetType: 'field',
          targetId: field.id,
          action: 'deleted',
          before: before,
          after: after,
          changedBy: user,
        );
      }

      await batch.commit();
      await _updateCounts(templateId: templateId, user: user);
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Map<String, dynamic>> _getDocumentMap({
    required String collectionPath,
    required String documentId,
  }) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection(collectionPath).doc(documentId).get();
    return doc.data() ?? <String, dynamic>{};
  }

  Future<void> _setCounts({
    required WriteBatch batch,
    required String templateId,
    required String user,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> sections =
        await _firestore.collection(CrmFirestorePaths.templateSections).get();
    final QuerySnapshot<Map<String, dynamic>> fields =
        await _firestore.collection(CrmFirestorePaths.templateFields).get();
    final int sectionCount = sections.docs
        .map((doc) => CrmTemplateSectionModel.fromMap(doc.data()))
        .where((item) => item.templateId == templateId)
        .where((item) => !item.isDeleted && item.status != 'deleted')
        .length;
    final int fieldCount = fields.docs
        .map((doc) => CrmTemplateFieldModel.fromMap(doc.data()))
        .where((item) => item.templateId == templateId)
        .where((item) => !item.isDeleted && item.status != 'deleted')
        .length;
    batch.set(
      _firestore.collection(CrmFirestorePaths.templates).doc(templateId),
      {
        CrmFirestoreKeys.SECTION_COUNT_KEY: sectionCount,
        CrmFirestoreKeys.FIELD_COUNT_KEY: fieldCount,
        '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
            Timestamp.now(),
        '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
            user,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> _updateCounts({
    required String templateId,
    required String user,
  }) async {
    final WriteBatch batch = _firestore.batch();
    await _setCounts(batch: batch, templateId: templateId, user: user);
    await batch.commit();
  }

  Map<String, dynamic> _deletedMap(
    Map<String, dynamic> before, {
    required String changedBy,
  }) {
    return {
      ...before,
      CrmFirestoreKeys.IS_DELETED_KEY: true,
      CrmFirestoreKeys.STATUS_KEY: 'deleted',
      '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
          Timestamp.now(),
      '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
          changedBy,
    };
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
    audit[CrmFirestoreKeys.UPDATED_BY_KEY] = changedBy;
    return CrmAuditModel.fromMap(audit);
  }

  void _history({
    required WriteBatch batch,
    required String templateId,
    required String targetType,
    required String targetId,
    required String action,
    required Map<String, dynamic> before,
    required Map<String, dynamic> after,
    required String changedBy,
  }) {
    final DocumentReference<Map<String, dynamic>> ref =
        _firestore.collection(CrmFirestorePaths.templateHistory).doc();
    final CrmTemplateHistoryModel history = CrmTemplateHistoryModel(
      id: ref.id,
      templateId: templateId,
      targetType: targetType,
      targetId: targetId,
      action: action,
      before: before,
      after: after,
      changedBy: changedBy,
      changedAt: DateTime.now(),
    );
    batch.set(ref, history.toMap());
  }

  String _normalizeUser(String userEmail) {
    return userEmail.trim().toLowerCase();
  }
}
