// ****************** FILE INFO ******************
// File Name: crm_terms_base_repository.dart
// Purpose: Feature-facing repository contract for CRM Terms
// Author: Mohand Adel
// Created At: 16/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_clause_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';

abstract class CrmTermsBaseRepository {
  Stream<Either<Failure, List<CrmTermModel>>> watchTerms();

  Future<Either<Failure, CrmTermModel>> createTerm({
    required String nameEn,
    required String nameAr,
    required String status,
    required String userEmail,
    required List<CrmTermClauseModel> clauses,
    String? termId,
  });

  Future<Either<Failure, void>> updateTerm({
    required CrmTermModel term,
    required String changedBy,
  });

  Future<Either<Failure, void>> removeTerm({
    required CrmTermModel term,
    required String changedBy,
  });

  Future<Either<Failure, void>> toggleTermStatus({
    required String termId,
    required bool isActive,
    required String changedBy,
  });
}
