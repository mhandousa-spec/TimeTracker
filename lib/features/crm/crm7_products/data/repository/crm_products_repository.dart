// ****************** FILE INFO ******************
// File Name: crm_products_repository.dart
// Purpose: Repository implementation for CRM product category and product item operations.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/data_source/crm_products_remote_data_source.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/interfaces/crm_products_base_repository.dart';

class CrmProductsRepository implements CrmProductsBaseRepository {
  final CrmProductsRemoteDataSource source;

  CrmProductsRepository({CrmProductsRemoteDataSource? source})
      : source = source ?? CrmProductsRemoteDataSource();

  // Categories
  @override
  Stream<Either<Failure, List<CrmProductCategoryModel>>> watchCategories() =>
      source.watchCategories();

  @override
  Future<Either<Failure, CrmProductCategoryModel>> createCategory(
          CrmProductCategoryModel category, String userEmail) =>
      source.createCategory(category, userEmail);

  @override
  Future<Either<Failure, void>> updateCategory(
          CrmProductCategoryModel category, String userEmail) =>
      source.updateCategory(category, userEmail);

  @override
  Future<Either<Failure, void>> deleteCategory(
          CrmProductCategoryModel category, String userEmail) =>
      source.deleteCategory(category, userEmail);

  @override
  Future<Either<Failure, void>> setCategoryActive(
          String id, bool isActive, String userEmail) =>
      source.setCategoryActive(id, isActive, userEmail);

  // Product Items
  @override
  Stream<Either<Failure, List<CrmProductItemModel>>> watchProducts() =>
      source.watchProducts();

  @override
  Future<Either<Failure, CrmProductItemModel>> createProduct(
          CrmProductItemModel product, String userEmail) =>
      source.createProduct(product, userEmail);

  @override
  Future<Either<Failure, void>> updateProduct(
          CrmProductItemModel product, String userEmail) =>
      source.updateProduct(product, userEmail);

  @override
  Future<Either<Failure, void>> deleteProduct(
          CrmProductItemModel product, String userEmail) =>
      source.deleteProduct(product, userEmail);

  @override
  Future<Either<Failure, void>> setProductActive(
          String id, bool isActive, String userEmail) =>
      source.setProductActive(id, isActive, userEmail);
}
