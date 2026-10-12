// ****************** FILE INFO ******************
// File Name: crm_controls_remote_data_source.dart
// Purpose: Remote Firestore data source for CRM controls schema and templates
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_field_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_settings_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_controls_defaults.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

class CrmControlsRemoteDataSource {
  final FirebaseFirestore _firestore;

  /// Session-scoped guard: control defaults are idempotent seed data, so they
  /// only need to be checked once per app process. Without this guard the
  /// templates page re-ran ~26 sequential Firestore calls on every open.
  static bool _defaultsEnsuredThisSession = false;

  CrmControlsRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Either<Failure, void>> ensureDefaults({
    required String userEmail,
  }) async {
    if (_defaultsEnsuredThisSession) return const Right(null);
    try {
      final List<CrmClientTypeModel> clientTypes =
          CrmControlsDefaults.clientTypes(userEmail: userEmail);
      final List<CrmFieldTypeModel> fieldTypes =
          CrmControlsDefaults.fieldTypes();

      // One parallel read batch replaces ~26 sequential .get() calls; only the
      // documents that are actually missing get written, so user
      // customizations are never overwritten.
      final List<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          await Future.wait(<Future<DocumentSnapshot<Map<String, dynamic>>>>[
        ...clientTypes.map(
          (CrmClientTypeModel type) =>
              _docRef(CrmFirestorePaths.clientTypes, type.id).get(),
        ),
        ...fieldTypes.map(
          (CrmFieldTypeModel fieldType) =>
              _docRef(CrmFirestorePaths.fieldTypes, fieldType.id).get(),
        ),
      ]);
      final Set<String> existingIds = snapshots
          .where((DocumentSnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.exists)
          .map((DocumentSnapshot<Map<String, dynamic>> snapshot) => snapshot.id)
          .toSet();

      for (final CrmClientTypeModel type in clientTypes) {
        if (existingIds.contains(type.id)) continue;
        await _setDocument(
          collectionPath: CrmFirestorePaths.clientTypes,
          documentId: type.id,
          data: type.toMap(),
        );
      }

      for (final CrmFieldTypeModel fieldType in fieldTypes) {
        if (existingIds.contains(fieldType.id)) continue;
        await _setDocument(
          collectionPath: CrmFirestorePaths.fieldTypes,
          documentId: fieldType.id,
          data: fieldType.toMap(),
        );
      }

      _defaultsEnsuredThisSession = true;
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, List<CrmClientTypeModel>>> watchClientTypes() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.clientTypes)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmClientTypeModel> items = snapshot.docs
            .map((doc) => CrmClientTypeModel.fromMap(doc.data()))
            .where((type) => type.isActive && !type.isDeleted)
            .toList();
        items.sort((a, b) => a.order.compareTo(b.order));
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, List<CrmFieldTypeModel>>> watchFieldTypes({
    required String clientTypeId,
  }) async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.fieldTypes)
          .orderBy(CrmFirestoreKeys.ORDER_KEY)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmFieldTypeModel> items = snapshot.docs
            .map((doc) => CrmFieldTypeModel.fromMap(doc.data()))
            .where((type) => type.isActive)
            .where((type) => type.isAllowedForClientType(clientTypeId))
            .toList();
        final Map<String, CrmFieldTypeModel> mergedById =
            <String, CrmFieldTypeModel>{};
        for (final CrmFieldTypeModel fieldType
            in CrmControlsDefaults.fieldTypesForClientType(clientTypeId)) {
          mergedById[fieldType.id] = fieldType;
        }
        for (final CrmFieldTypeModel fieldType in items) {
          mergedById[fieldType.id] = fieldType;
        }
        final List<CrmFieldTypeModel> mergedItems = mergedById.values.toList()
          ..sort(
            (CrmFieldTypeModel a, CrmFieldTypeModel b) =>
                a.order.compareTo(b.order),
          );
        yield Right(mergedItems);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmClientTypeModel>> createClientType({
    required String nameEn,
    required String nameAr,
    required String userEmail,
    String iconUrl = '',
    String svgAsset = '',
    String iconKey = '',
    String? typeId,
  }) async {
    try {
      final String id = typeId ??
          _firestore.collection(CrmFirestorePaths.clientTypes).doc().id;
      final int order = await _getNextClientTypeOrder();
      final CrmClientTypeModel clientType = CrmClientTypeModel(
        id: id,
        title: nameEn,
        nameEn: nameEn,
        nameAr: nameAr,
        svgAsset: svgAsset,
        iconKey: iconKey,
        iconUrl: iconUrl,
        isDefault: false,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      final Either<Failure, void> result = await _setDocument(
        collectionPath: CrmFirestorePaths.clientTypes,
        documentId: clientType.id,
        data: clientType.toMap(),
      );

      return result.fold(
        (failure) => Left(failure),
        (_) => Right(clientType),
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateClientType({
    required CrmClientTypeModel clientType,
    required String changedBy,
  }) async {
    final Map<String, dynamic> before = await _getDocumentMap(
      collectionPath: CrmFirestorePaths.clientTypes,
      documentId: clientType.id,
    );
    if (before.isEmpty) {
      return Left(FeatureFailure('Client type not found: ${clientType.id}'));
    }

    final Timestamp now = Timestamp.now();
    final String normalizedChangedBy = changedBy.trim().toLowerCase();
    final Map<String, dynamic> audit = Map<String, dynamic>.from(
      CrmFirestoreKeys.read(before, CrmFirestoreKeys.AUDIT_KEY, 'audit')
              as Map? ??
          const {},
    );
    audit[CrmFirestoreKeys.UPDATED_AT_KEY] = now;
    audit[CrmFirestoreKeys.UPDATED_BY_KEY] = normalizedChangedBy;

    final Map<String, dynamic> data = clientType
        .copyWith(
          title: clientType.nameEn,
          audit: CrmAuditModel.fromMap(audit),
        )
        .toMap();

    return _setDocument(
      collectionPath: CrmFirestorePaths.clientTypes,
      documentId: clientType.id,
      data: data,
    );
  }

  Future<Either<Failure, void>> removeClientType({
    required CrmClientTypeModel clientType,
    required String changedBy,
  }) async {
    if (clientType.isDefault) {
      return Left(FeatureFailure('Default client types cannot be removed'));
    }

    final Timestamp now = Timestamp.now();
    final String normalizedChangedBy = changedBy.trim().toLowerCase();

    try {
      await _firestore
          .collection(CrmFirestorePaths.clientTypes)
          .doc(clientType.id)
          .set(
        {
          CrmFirestoreKeys.IS_DELETED_KEY: true,
          CrmFirestoreKeys.IS_ACTIVE_KEY: false,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
              now,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
              normalizedChangedBy,
        },
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> uploadClientTypeIcon({
    required File image,
    required String typeId,
  }) async {
    final Either<FirebaseFailure, dynamic> result =
        await FirebaseRepository.uploadFile(
      collectionName: CrmFirestorePaths.clientTypeIconStoragePath(typeId),
      documentName: typeId,
      filePath: image.path,
    );

    return result.fold(
      (failure) => Left(failure),
      (url) => Right(url.toString()),
    );
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
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
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
        await _firestore.collection(collectionPath).doc(documentId).get();
    return doc.data() ?? <String, dynamic>{};
  }

  Future<int> _getNextClientTypeOrder() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(CrmFirestorePaths.clientTypes)
        .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
        .get();
    if (snapshot.docs.isEmpty) return 1;
    final Iterable<int> orders = snapshot.docs.map((doc) {
      return (CrmFirestoreKeys.read(
            doc.data(),
            CrmFirestoreKeys.ORDER_KEY,
            'order',
          ) as num?)
              ?.toInt() ??
          0;
    });
    return orders.reduce((int a, int b) => a > b ? a : b) + 1;
  }

  Stream<Either<Failure, List<CrmMergeLevelModel>>> watchMergeLevels() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.mergeLevels)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmMergeLevelModel> items = snapshot.docs
            .map((doc) => CrmMergeLevelModel.fromMap(doc.data()))
            .where((level) => !level.isDeleted)
            .toList();
        items.sort((a, b) => a.order.compareTo(b.order));
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Stream<Either<Failure, CrmMergeSettingsModel>> watchMergeSettings() async* {
    try {
      final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          _firestore
              .collection(CrmFirestorePaths.mergeSettings)
              .doc(CrmMergeSettingsModel.documentId)
              .snapshots();
      await for (final DocumentSnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        yield Right(snapshot.exists && snapshot.data() != null
            ? CrmMergeSettingsModel.fromMap(snapshot.data()!)
            : CrmMergeSettingsModel.defaults());
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> saveMergeSettings({
    required CrmMergeSettingsModel settings,
    required String changedBy,
  }) async {
    final Timestamp now = Timestamp.now();
    final String normalizedChangedBy = changedBy.trim().toLowerCase();
    try {
      final DocumentReference<Map<String, dynamic>> reference = _firestore
          .collection(CrmFirestorePaths.mergeSettings)
          .doc(CrmMergeSettingsModel.documentId);
      final DocumentSnapshot<Map<String, dynamic>> existing =
          await reference.get();
      final Map<String, dynamic> audit = existing.data() == null
          ? CrmAuditModel.now(userEmail: normalizedChangedBy).toMap()
          : Map<String, dynamic>.from(
              CrmFirestoreKeys.read(
                    existing.data()!,
                    CrmFirestoreKeys.AUDIT_KEY,
                    'audit',
                  ) as Map? ??
                  const <String, dynamic>{},
            );
      audit[CrmFirestoreKeys.UPDATED_AT_KEY] = now;
      audit[CrmFirestoreKeys.UPDATED_BY_KEY] = normalizedChangedBy;
      await reference.set(
        settings.copyWith(audit: CrmAuditModel.fromMap(audit)).toMap(),
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmMergeLevelModel>> createMergeLevel({
    required String nameEn,
    required String nameAr,
    required double rangeFrom,
    required double rangeTo,
    required String colorHex,
    required String userEmail,
    String? levelId,
  }) async {
    try {
      final String id = levelId ??
          _firestore.collection(CrmFirestorePaths.mergeLevels).doc().id;
      final int order = await _getNextMergeLevelOrder();
      final CrmMergeLevelModel level = CrmMergeLevelModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        rangeFrom: rangeFrom,
        rangeTo: rangeTo,
        colorHex: colorHex,
        isActive: true,
        isDeleted: false,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
      );

      final Either<Failure, void> result = await _setDocument(
        collectionPath: CrmFirestorePaths.mergeLevels,
        documentId: level.id,
        data: level.toMap(),
      );

      return result.fold(
        (failure) => Left(failure),
        (_) => Right(level),
      );
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateMergeLevel({
    required CrmMergeLevelModel level,
    required String changedBy,
  }) async {
    final Map<String, dynamic> before = await _getDocumentMap(
      collectionPath: CrmFirestorePaths.mergeLevels,
      documentId: level.id,
    );
    if (before.isEmpty) {
      return Left(FeatureFailure('Merge level not found: ${level.id}'));
    }

    final Timestamp now = Timestamp.now();
    final String normalizedChangedBy = changedBy.trim().toLowerCase();
    final Map<String, dynamic> audit = Map<String, dynamic>.from(
      CrmFirestoreKeys.read(before, CrmFirestoreKeys.AUDIT_KEY, 'audit')
              as Map? ??
          const {},
    );
    audit[CrmFirestoreKeys.UPDATED_AT_KEY] = now;
    audit[CrmFirestoreKeys.UPDATED_BY_KEY] = normalizedChangedBy;

    final Map<String, dynamic> data = level
        .copyWith(
          audit: CrmAuditModel.fromMap(audit),
        )
        .toMap();

    return _setDocument(
      collectionPath: CrmFirestorePaths.mergeLevels,
      documentId: level.id,
      data: data,
    );
  }

  Future<Either<Failure, void>> removeMergeLevel({
    required CrmMergeLevelModel level,
    required String changedBy,
  }) async {
    final Timestamp now = Timestamp.now();
    final String normalizedChangedBy = changedBy.trim().toLowerCase();

    try {
      await _firestore
          .collection(CrmFirestorePaths.mergeLevels)
          .doc(level.id)
          .set(
        {
          CrmFirestoreKeys.IS_DELETED_KEY: true,
          CrmFirestoreKeys.IS_ACTIVE_KEY: false,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
              now,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
              normalizedChangedBy,
        },
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<int> _getNextMergeLevelOrder() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.mergeLevels)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .get();
      if (snapshot.docs.isEmpty) return 1;
      final Iterable<int> orders = snapshot.docs.map((doc) {
        return (CrmFirestoreKeys.read(
              doc.data(),
              CrmFirestoreKeys.ORDER_KEY,
              'order',
            ) as num?)
                ?.toInt() ??
            0;
      });
      return orders.reduce((int a, int b) => a > b ? a : b) + 1;
    } catch (_) {
      return 1;
    }
  }
}
