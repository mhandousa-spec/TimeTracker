// ****************** FILE INFO ******************
// File Name: crm_saved_sections_remote_data_source.dart
// Purpose: Firebase data source for reusable CRM saved sections
// Author: Mohand Adel
// Created At: 05/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_saved_section_template_draft_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_template_default_sync_helper.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_template_defaults.dart';

class CrmSavedSectionsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmSavedSectionsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _savedSections =>
      _firestore.collection(CrmFirestorePaths.savedSections);

  CollectionReference<Map<String, dynamic>> get _savedSectionFields =>
      _firestore.collection(CrmFirestorePaths.savedSectionFields);

  Future<Either<Failure, void>> ensureDefaultSavedSections({
    required String clientTypeId,
    required String userEmail,
  }) async {
    try {
      final String safeClientTypeId = _safeId(clientTypeId);
      final String seedTemplateId = '${safeClientTypeId}_saved_defaults';
      final CrmAuditModel audit = CrmAuditModel.now(
        userEmail: _normalizeUser(userEmail),
      );
      final List<CrmTemplateSectionModel> sections =
          CrmTemplateDefaults.sections(
        templateId: seedTemplateId,
        clientTypeId: clientTypeId,
        userEmail: audit.createdBy,
      );
      final List<CrmTemplateFieldModel> fields = CrmTemplateDefaults.fields(
        templateId: seedTemplateId,
        clientTypeId: clientTypeId,
        userEmail: audit.createdBy,
      );
      final WriteBatch batch = _firestore.batch();
      int writes = 0;

      for (final CrmTemplateSectionModel section in sections) {
        final String savedSectionId =
            '${safeClientTypeId}_${_safeId(section.systemKey)}';
        final DocumentSnapshot<Map<String, dynamic>> sectionDoc =
            await _savedSections.doc(savedSectionId).get();
        final bool sectionIsDeleted = _isDeleted(sectionDoc.data());

        if (!sectionDoc.exists) {
          batch.set(
            _savedSections.doc(savedSectionId),
            CrmSavedSectionModel.fromTemplateSection(
              id: savedSectionId,
              section: section.copyWith(
                configuration: {
                  ...section.configuration,
                  CrmFirestoreKeys.SOURCE_SYSTEM_KEY_KEY: section.systemKey,
                },
              ),
              audit: audit,
              isSystem: true,
              isDefault: true,
              order: section.order,
            ).toMap(),
          );
          writes++;
        }

        if (sectionIsDeleted) continue;

        final Iterable<CrmTemplateFieldModel> sectionFields =
            fields.where((field) => field.sectionId == section.id);
        for (final CrmTemplateFieldModel field in sectionFields) {
          final String savedFieldId =
              '${savedSectionId}_${_safeId(field.systemKey)}';
          final DocumentSnapshot<Map<String, dynamic>> fieldDoc =
              await _savedSectionFields.doc(savedFieldId).get();
          if (fieldDoc.exists) {
            final CrmSavedSectionFieldModel existing =
                CrmSavedSectionFieldModel.fromMap(
              fieldDoc.data() ?? <String, dynamic>{},
            );
            final CrmTemplateFieldModel existingField =
                existing.toTemplateField(
              id: field.id,
              templateId: seedTemplateId,
              sectionId: section.id,
              clientTypeId: clientTypeId,
              audit: audit,
              order: field.order,
              sourceSavedSectionId: savedSectionId,
            );
            final CrmTemplateFieldModel merged =
                CrmTemplateDefaultSyncHelper.mergeFieldWithDefault(
              existing: existingField,
              defaultField: field,
            );
            if (!CrmTemplateDefaultSyncHelper.needsSync(
              existing: existingField,
              merged: merged,
            )) {
              continue;
            }
            batch.set(
              _savedSectionFields.doc(savedFieldId),
              CrmSavedSectionFieldModel.fromTemplateField(
                id: savedFieldId,
                savedSectionId: savedSectionId,
                field: merged,
                audit: audit,
                isSystem: true,
                isDefault: true,
                order: field.order,
              ).toMap(),
            );
            writes++;
            continue;
          }
          batch.set(
            _savedSectionFields.doc(savedFieldId),
            CrmSavedSectionFieldModel.fromTemplateField(
              id: savedFieldId,
              savedSectionId: savedSectionId,
              field: field,
              audit: audit,
              isSystem: true,
              isDefault: true,
              order: field.order,
            ).toMap(),
          );
          writes++;
        }
      }

      if (writes > 0) {
        await batch.commit();
      }
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Stream<Either<Failure, List<CrmSavedSectionModel>>> watchSavedSections({
    required String clientTypeId,
  }) async* {
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _savedSections.snapshots()) {
        final List<CrmSavedSectionModel> items = snapshot.docs
            .map((doc) => CrmSavedSectionModel.fromMap(doc.data()))
            .where(
              (item) =>
                  item.clientTypeId == clientTypeId &&
                  _isVisible(item.status, item.isDeleted),
            )
            .toList()
          ..sort(_compareSections);
        yield Right(items);
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Stream<Either<Failure, List<CrmSavedSectionFieldModel>>>
      watchSavedSectionFields({
    required String savedSectionId,
  }) async* {
    try {
      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _savedSectionFields.snapshots()) {
        final List<CrmSavedSectionFieldModel> items = snapshot.docs
            .map((doc) => CrmSavedSectionFieldModel.fromMap(doc.data()))
            .where(
              (item) =>
                  item.savedSectionId == savedSectionId &&
                  _isVisible(item.status, item.isDeleted),
            )
            .toList()
          ..sort(_compareFields);
        yield Right(items);
      }
    } catch (error) {
      yield Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, List<CrmSavedSectionFieldModel>>>
      getSavedSectionFields({
    required String savedSectionId,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _savedSectionFields.get();
      final List<CrmSavedSectionFieldModel> items = snapshot.docs
          .map((doc) => CrmSavedSectionFieldModel.fromMap(doc.data()))
          .where(
            (item) =>
                item.savedSectionId == savedSectionId &&
                _isVisible(item.status, item.isDeleted),
          )
          .toList()
        ..sort(_compareFields);
      return Right(items);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, void>> saveReusableSectionWithFields({
    required CrmSavedSectionModel section,
    required List<CrmSavedSectionFieldModel> fields,
    required String changedBy,
  }) async {
    try {
      if (section.nameEn.trim().isEmpty || section.nameAr.trim().isEmpty) {
        return const Left(FeatureFailure('Section names are required'));
      }
      if (fields.isEmpty) {
        return const Left(FeatureFailure('Add at least one field'));
      }
      final WriteBatch batch = _firestore.batch();
      batch.set(_savedSections.doc(section.id), section.toMap());
      for (final CrmSavedSectionFieldModel field in fields) {
        batch.set(_savedSectionFields.doc(field.id), field.toMap());
      }
      await batch.commit();
      return const Right(null);
    } catch (error) {
      return Left(FirebaseFailure(error.toString()));
    }
  }

  Future<Either<Failure, CrmSavedSectionTemplateDraftModel>>
      buildTemplateSectionFromSavedSection({
    required String templateId,
    required String clientTypeId,
    required CrmSavedSectionModel savedSection,
    required int order,
    required String changedBy,
  }) async {
    final Either<Failure, List<CrmSavedSectionFieldModel>> fieldsResult =
        await getSavedSectionFields(savedSectionId: savedSection.id);
    return fieldsResult.fold(
      Left.new,
      (List<CrmSavedSectionFieldModel> savedFields) {
        final String sourceKey = savedSection.systemKey.trim().isEmpty
            ? 'custom'
            : savedSection.systemKey;
        final String sectionId =
            '${templateId}_${_safeId(sourceKey)}_${DateTime.now().millisecondsSinceEpoch}';
        final CrmAuditModel audit = CrmAuditModel.now(
          userEmail: _normalizeUser(changedBy),
        );
        final CrmTemplateSectionModel section = CrmTemplateSectionModel(
          id: sectionId,
          templateId: templateId,
          clientTypeId: clientTypeId,
          nameEn: savedSection.nameEn,
          nameAr: savedSection.nameAr,
          systemKey: '',
          isDefault: false,
          isDeleted: false,
          configuration: {
            ...savedSection.configuration,
            CrmFirestoreKeys.SOURCE_SAVED_SECTION_ID_KEY: savedSection.id,
            CrmFirestoreKeys.SOURCE_SYSTEM_KEY_KEY: sourceKey,
          },
          order: order,
          isCollapsible: true,
          status: 'active',
          audit: audit,
        );
        final List<CrmTemplateFieldModel> fields = savedFields
            .asMap()
            .entries
            .map(
              (entry) => entry.value.toTemplateField(
                id: _templateFieldId(sectionId, entry.value, entry.key),
                templateId: templateId,
                sectionId: sectionId,
                clientTypeId: clientTypeId,
                audit: audit,
                order: entry.key + 1,
                sourceSavedSectionId: savedSection.id,
              ),
            )
            .toList();
        return Right(
          CrmSavedSectionTemplateDraftModel(
            section: section,
            fields: fields,
          ),
        );
      },
    );
  }

  String _templateFieldId(
    String sectionId,
    CrmSavedSectionFieldModel field,
    int index,
  ) {
    final String sourceKey =
        field.systemKey.trim().isEmpty ? field.nameEn : field.systemKey;
    return '${sectionId}_${_safeId(sourceKey)}_${index + 1}';
  }

  int _compareSections(
    CrmSavedSectionModel first,
    CrmSavedSectionModel second,
  ) {
    final int defaultCompare = _defaultRank(first).compareTo(
      _defaultRank(second),
    );
    if (defaultCompare != 0) return defaultCompare;
    final int orderCompare = first.order.compareTo(second.order);
    if (orderCompare != 0) return orderCompare;
    return first.nameEn.toLowerCase().compareTo(second.nameEn.toLowerCase());
  }

  int _compareFields(
    CrmSavedSectionFieldModel first,
    CrmSavedSectionFieldModel second,
  ) {
    final int orderCompare = first.order.compareTo(second.order);
    if (orderCompare != 0) return orderCompare;
    return first.nameEn.toLowerCase().compareTo(second.nameEn.toLowerCase());
  }

  int _defaultRank(CrmSavedSectionModel section) {
    if (section.systemKey == 'address') return 0;
    if (section.systemKey == 'point_of_contact') return 1;
    return section.isDefault ? 2 : 3;
  }

  bool _isVisible(String status, bool isDeleted) {
    return !isDeleted && status != 'deleted';
  }

  bool _isDeleted(Map<String, dynamic>? data) {
    if (data == null) return false;
    final bool deleted = CrmFirestoreKeys.read(
            data, CrmFirestoreKeys.IS_DELETED_KEY, 'isDeleted') ==
        true;
    final String status =
        (CrmFirestoreKeys.read(data, CrmFirestoreKeys.STATUS_KEY, 'status') ??
                '')
            .toString();
    return deleted || status == 'deleted';
  }

  String _normalizeUser(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? 'system' : trimmed;
  }

  String _safeId(String value) {
    final String cleaned = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return cleaned.isEmpty ? 'item' : cleaned;
  }
}
