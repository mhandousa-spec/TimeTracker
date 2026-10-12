// ****************** FILE INFO ******************
// File Name: crm_services_base_repository.dart
// Purpose: Repository contract for CRM service categories and service items persistence.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';

abstract class CrmServicesBaseRepository {
  // Categories
  Stream<Either<Failure, List<CrmServiceCategoryModel>>> watchCategories();
  Future<Either<Failure, CrmServiceCategoryModel>> createCategory(
      CrmServiceCategoryModel category, String userEmail);
  Future<Either<Failure, void>> updateCategory(
      CrmServiceCategoryModel category, String userEmail);
  Future<Either<Failure, void>> deleteCategory(
      CrmServiceCategoryModel category, String userEmail);
  Future<Either<Failure, void>> setCategoryActive(
      String id, bool isActive, String userEmail);

  // Service Items
  Stream<Either<Failure, List<CrmServiceItemModel>>> watchServices();
  Future<Either<Failure, CrmServiceItemModel>> createService(
      CrmServiceItemModel service, String userEmail);
  Future<Either<Failure, void>> updateService(
      CrmServiceItemModel service, String userEmail);
  Future<Either<Failure, void>> deleteService(
      CrmServiceItemModel service, String userEmail);
  Future<Either<Failure, void>> setServiceActive(
      String id, bool isActive, String userEmail);
}
