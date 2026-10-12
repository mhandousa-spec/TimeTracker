// ****************** FILE INFO ******************
// File Name: crm_terms_repository.dart
// Purpose: Repository implementation for CRM Terms operations
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/data_source/crm_terms_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_clause_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/domain/interfaces/crm_terms_base_repository.dart';

class CrmTermsRepository implements CrmTermsBaseRepository {
  final CrmTermsRemoteDataSource remoteDataSource;

  CrmTermsRepository({
    CrmTermsRemoteDataSource? remoteDataSource,
  }) : remoteDataSource = remoteDataSource ?? CrmTermsRemoteDataSource();

  @override
  Stream<Either<Failure, List<CrmTermModel>>> watchTerms() {
    return remoteDataSource.watchTerms();
  }

  @override
  Future<Either<Failure, CrmTermModel>> createTerm({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<CrmTermClauseModel> clauses,
    String? termId,
  }) {
    return remoteDataSource.createTerm(
      nameEn: nameEn,
      nameAr: nameAr,
      status: status,
      userEmail: userEmail,
      clauses: clauses,
      termId: termId,
    );
  }

  @override
  Future<Either<Failure, void>> updateTerm({
    required CrmTermModel term,
    required String changedBy,
  }) {
    return remoteDataSource.updateTerm(
      term: term,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> removeTerm({
    required CrmTermModel term,
    required String changedBy,
  }) {
    return remoteDataSource.removeTerm(
      term: term,
      changedBy: changedBy,
    );
  }

  @override
  Future<Either<Failure, void>> toggleTermStatus({
    required String termId,
    required bool isActive,
    required String changedBy,
  }) {
    return remoteDataSource.toggleTermStatus(
      termId: termId,
      isActive: isActive,
      changedBy: changedBy,
    );
  }
}
