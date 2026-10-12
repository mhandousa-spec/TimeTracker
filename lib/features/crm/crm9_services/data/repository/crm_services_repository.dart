// ****************** FILE INFO ******************
// File Name: crm_services_repository.dart
// Purpose: Repository implementation for CRM service category and service item operations.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/data_source/crm_services_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/domain/interfaces/crm_services_base_repository.dart';

class CrmServicesRepository implements CrmServicesBaseRepository {
  final CrmServicesRemoteDataSource source;

  CrmServicesRepository({CrmServicesRemoteDataSource? source})
      : source = source ?? CrmServicesRemoteDataSource();

  // Categories
  @override
  Stream<Either<Failure, List<CrmServiceCategoryModel>>> watchCategories() =>
      source.watchCategories();

  @override
  Future<Either<Failure, CrmServiceCategoryModel>> createCategory(
          CrmServiceCategoryModel category, String userEmail) =>
      source.createCategory(category, userEmail);

  @override
  Future<Either<Failure, void>> updateCategory(
          CrmServiceCategoryModel category, String userEmail) =>
      source.updateCategory(category, userEmail);

  @override
  Future<Either<Failure, void>> deleteCategory(
          CrmServiceCategoryModel category, String userEmail) =>
      source.deleteCategory(category, userEmail);

  @override
  Future<Either<Failure, void>> setCategoryActive(
          String id, bool isActive, String userEmail) =>
      source.setCategoryActive(id, isActive, userEmail);

  // Service Items
  @override
  Stream<Either<Failure, List<CrmServiceItemModel>>> watchServices() =>
      source.watchServices();

  @override
  Future<Either<Failure, CrmServiceItemModel>> createService(
          CrmServiceItemModel service, String userEmail) =>
      source.createService(service, userEmail);

  @override
  Future<Either<Failure, void>> updateService(
          CrmServiceItemModel service, String userEmail) =>
      source.updateService(service, userEmail);

  @override
  Future<Either<Failure, void>> deleteService(
          CrmServiceItemModel service, String userEmail) =>
      source.deleteService(service, userEmail);

  @override
  Future<Either<Failure, void>> setServiceActive(
          String id, bool isActive, String userEmail) =>
      source.setServiceActive(id, isActive, userEmail);
}
