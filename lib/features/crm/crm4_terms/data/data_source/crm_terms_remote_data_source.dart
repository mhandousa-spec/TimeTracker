// ****************** FILE INFO ******************
// File Name: crm_terms_remote_data_source.dart
// Purpose: Firestore remote data source for CRM Terms CRUD logic
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_keys.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/services/crm_firestore_paths.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_clause_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';

class CrmTermsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CrmTermsRemoteDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<Either<Failure, List<CrmTermModel>>> watchTerms() async* {
    try {
      final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots = _firestore
          .collection(CrmFirestorePaths.terms)
          .where(CrmFirestoreKeys.IS_DELETED_KEY, isEqualTo: false)
          .snapshots();

      await for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in snapshots) {
        final List<CrmTermModel> items = snapshot.docs
            .map((doc) => CrmTermModel.fromMap(doc.data()))
            .where((term) => !term.isDeleted)
            .toList()
          ..sort(_sortTerms);
        yield Right(items);
      }
    } catch (e) {
      yield Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, CrmTermModel>> createTerm({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<CrmTermClauseModel> clauses,
    String? termId,
  }) async {
    try {
      final String id =
          termId ?? _firestore.collection(CrmFirestorePaths.terms).doc().id;
      final int order = await _getNextTermOrder();
      final bool isActive = status.toLowerCase() == 'active';
      final CrmTermModel term = CrmTermModel(
        id: id,
        nameEn: nameEn,
        nameAr: nameAr,
        status: status,
        isActive: isActive,
        isDeleted: false,
        order: order,
        audit: CrmAuditModel.now(userEmail: userEmail),
        clauses: clauses,
      );

      await _firestore
          .collection(CrmFirestorePaths.terms)
          .doc(term.id)
          .set(term.toMap());

      return Right(term);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updateTerm({
    required CrmTermModel term,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.terms)
          .doc(term.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Term not found: ${term.id}'));
      }

      final CrmTermModel existing = CrmTermModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final CrmTermModel updated = term.copyWith(audit: audit);

      await _firestore
          .collection(CrmFirestorePaths.terms)
          .doc(term.id)
          .update(updated.toMap());

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeTerm({
    required CrmTermModel term,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.terms)
          .doc(term.id)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Term not found: ${term.id}'));
      }

      final CrmTermModel existing = CrmTermModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final Map<String, dynamic> updatePayload = {
        CrmFirestoreKeys.IS_DELETED_KEY: true,
        CrmFirestoreKeys.STATUS_KEY: 'deleted',
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      };

      await _firestore
          .collection(CrmFirestorePaths.terms)
          .doc(term.id)
          .update(updatePayload);

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> toggleTermStatus({
    required String termId,
    required bool isActive,
    required String changedBy,
  }) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(CrmFirestorePaths.terms)
          .doc(termId)
          .get();
      if (!snapshot.exists || snapshot.data() == null) {
        return Left(FeatureFailure('Term not found: $termId'));
      }

      final CrmTermModel existing = CrmTermModel.fromMap(snapshot.data()!);
      final CrmAuditModel audit =
          (existing.audit ?? CrmAuditModel.now(userEmail: changedBy)).copyWith(
        updatedAt: DateTime.now(),
        updatedBy: changedBy.trim().toLowerCase(),
      );

      final String newStatus = isActive ? 'active' : 'inactive';
      await _firestore.collection(CrmFirestorePaths.terms).doc(termId).update({
        CrmFirestoreKeys.IS_ACTIVE_KEY: isActive,
        CrmFirestoreKeys.STATUS_KEY: newStatus,
        CrmFirestoreKeys.AUDIT_KEY: audit.toMap(),
      });

      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  Future<int> _getNextTermOrder() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(CrmFirestorePaths.terms).get();
      int highest = 0;
      for (final doc in snapshot.docs) {
        final dynamic raw = doc.data()[CrmFirestoreKeys.ORDER_KEY];
        if (raw is int && raw > highest) {
          highest = raw;
        }
      }
      return highest + 1;
    } catch (_) {
      return 0;
    }
  }

  int _sortTerms(CrmTermModel a, CrmTermModel b) {
    if (a.order != b.order) {
      return a.order.compareTo(b.order);
    }
    return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
  }
}
