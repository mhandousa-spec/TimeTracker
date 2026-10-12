// ****************** FILE INFO ******************
// File Name: crm_products_base_repository.dart
// Purpose: Repository contract for CRM product categories and product items persistence.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';

abstract class CrmProductsBaseRepository {
  // Categories
  Stream<Either<Failure, List<CrmProductCategoryModel>>> watchCategories();
  Future<Either<Failure, CrmProductCategoryModel>> createCategory(
      CrmProductCategoryModel category, String userEmail);
  Future<Either<Failure, void>> updateCategory(
      CrmProductCategoryModel category, String userEmail);
  Future<Either<Failure, void>> deleteCategory(
      CrmProductCategoryModel category, String userEmail);
  Future<Either<Failure, void>> setCategoryActive(
      String id, bool isActive, String userEmail);

  // Product Items
  Stream<Either<Failure, List<CrmProductItemModel>>> watchProducts();
  Future<Either<Failure, CrmProductItemModel>> createProduct(
      CrmProductItemModel product, String userEmail);
  Future<Either<Failure, void>> updateProduct(
      CrmProductItemModel product, String userEmail);
  Future<Either<Failure, void>> deleteProduct(
      CrmProductItemModel product, String userEmail);
  Future<Either<Failure, void>> setProductActive(
      String id, bool isActive, String userEmail);
}
