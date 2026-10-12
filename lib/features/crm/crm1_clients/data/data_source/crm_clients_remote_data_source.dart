// ****************** FILE INFO ******************
// File Name: crm_clients_remote_data_source.dart
// Purpose: Remote Firestore data source for CRM client record CRUD operations
// Author: Mohand Adel
// Created At: 08/08/2026

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/services/firebase/repository/firebase_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';

/// Firestore data source for `Demo/{companyId}/Modules/crm/Clients/Records`.
///
/// Client records always use soft delete: [softDeleteClientRecord] toggles
/// `Status = deleted` (plus `Is_Deleted = true`) and never removes the
/// document.
class CrmClientsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmClientsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Live stream of all non-deleted client records. Pass [clientTypeId] or
  /// [templateId] to narrow the result set on the server; status/order
  /// filtering happens in Dart to avoid composite index requirements.
  Stream<Either<Failure, List<CrmClientRecordModel>>> watchClientRecords({
    String? clientTypeId,
    String? templateId,
  }) async* {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(CrmFirestorePaths.clientRecords);
      if (clientTypeId != null && clientTypeId.isNotEmpty) {
        query = query.where(
          CrmFirestoreKeys.CLIENT_TYPE_ID_KEY,
          isEqualTo: clientTypeId,
        );
      }
      if (templateId != null && templateId.isNotEmpty) {
        query = query.where(CrmFirestoreKeys.TEMPLATE_ID_KEY,
            isEqualTo: templateId);
      }

      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
          query.snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmClientRecordModel> items = snapshot.docs
            .map((doc) => CrmClientRecordModel.fromMap(doc.data()))
            .where((record) => record.status != 'deleted')
            .toList()
          ..sort(
            (a, b) => b.audit.createdAt.compareTo(a.audit.createdAt),
          );
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  /// Live stream of a single client record (null when the document is
  /// missing or soft-deleted).
  Stream<Either<Failure, CrmClientRecordModel?>> watchClientRecord({
    required String recordId,
  }) async* {
    try {
      final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          _firestore
              .collection(CrmFirestorePaths.clientRecords)
              .doc(recordId)
              .snapshots();

      await for (final DocumentSnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final Map<String, dynamic>? data = snapshot.data();
        if (data == null) {
          yield const Right(null);
          continue;
        }
        final CrmClientRecordModel record = CrmClientRecordModel.fromMap(data);
        yield Right(record.status == 'deleted' ? null : record);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  /// Creates (or fully overwrites) a client record. [record.audit] must carry
  /// the creation/update metadata decided by the caller.
  Future<Either<Failure, CrmClientRecordModel>> saveClientRecord({
    required CrmClientRecordModel record,
  }) async {
    try {
      await _firestore
          .collection(CrmFirestorePaths.clientRecords)
          .doc(record.id)
          .set(record.toMap());
      return Right(record);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Updates the status field of a client record (e.g. active, inactive).
  Future<Either<Failure, void>> updateClientStatus({
    required String recordId,
    required String status,
    required String userEmail,
  }) async {
    final String normalizedUser = userEmail.trim().toLowerCase();
    final Timestamp now = Timestamp.now();
    try {
      await _firestore
          .collection(CrmFirestorePaths.clientRecords)
          .doc(recordId)
          .set(
        {
          CrmFirestoreKeys.STATUS_KEY: status.trim().toLowerCase(),
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
              now,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
              normalizedUser,
        },
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Adds a client to the blacklist or records a pending removal request.
  Future<Either<Failure, void>> updateClientBlacklist({
    required String recordId,
    required String reason,
    required bool isRemovalRequest,
    required String userEmail,
  }) async {
    final String normalizedUser = userEmail.trim().toLowerCase();
    final Timestamp now = Timestamp.now();
    final Map<String, dynamic> blacklistDetails = isRemovalRequest
        ? <String, dynamic>{
            CrmClientRecordModel.blacklistRemovalReasonKey: reason.trim(),
            CrmClientRecordModel.blacklistRemovalRequestedAtKey: now,
            CrmClientRecordModel.blacklistRemovalRequestedByKey: normalizedUser,
            CrmClientRecordModel.blacklistRemovalStatusKey: 'completed',
          }
        : <String, dynamic>{
            CrmClientRecordModel.blacklistReasonKey: reason.trim(),
            CrmClientRecordModel.blacklistRequestedAtKey: now,
            CrmClientRecordModel.blacklistRequestedByKey: normalizedUser,
          };
    final Map<String, dynamic> update = <String, dynamic>{
      CrmClientRecordModel.blacklistDetailsKey: blacklistDetails,
      '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}': now,
      '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
          normalizedUser,
    };
    if (isRemovalRequest) {
      update[CrmFirestoreKeys.STATUS_KEY] = 'active';
    } else {
      update[CrmFirestoreKeys.STATUS_KEY] = 'blacklist';
    }
    try {
      await _firestore
          .collection(CrmFirestorePaths.clientRecords)
          .doc(recordId)
          .set(
            update,
            SetOptions(merge: true),
          );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Soft deletes a client record by toggling its status flags. The document
  /// is never removed so history is preserved.
  Future<Either<Failure, void>> softDeleteClientRecord({
    required String recordId,
    required String userEmail,
  }) async {
    final String normalizedUser = userEmail.trim().toLowerCase();
    final Timestamp now = Timestamp.now();
    try {
      await _firestore
          .collection(CrmFirestorePaths.clientRecords)
          .doc(recordId)
          .set(
        {
          CrmFirestoreKeys.STATUS_KEY: 'deleted',
          CrmFirestoreKeys.IS_DELETED_KEY: true,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_AT_KEY}':
              now,
          '${CrmFirestoreKeys.AUDIT_KEY}.${CrmFirestoreKeys.UPDATED_BY_KEY}':
              normalizedUser,
        },
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Uploads a picked image/file to Firebase Storage under the client record
  /// path and returns the download URL to be stored in the record values.
  Future<Either<Failure, String>> uploadClientFile({
    required File file,
    required String recordId,
    required String fieldId,
  }) async {
    final Either<FirebaseFailure, dynamic> result =
        await FirebaseRepository.uploadFile(
      collectionName: CrmFirestorePaths.clientRecordFileStoragePath(recordId),
      documentName: fieldId,
      filePath: file.path,
    );

    return result.fold(
      (failure) => Left(failure),
      (url) => Right(url.toString()),
    );
  }
}
