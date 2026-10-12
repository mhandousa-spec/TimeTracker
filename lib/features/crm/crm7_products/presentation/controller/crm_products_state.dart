// ****************** FILE INFO ******************
// File Name: crm_products_state.dart
// Purpose: Immutable UI state for CRM product categories and product items management.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';

class CrmProductsState {
  final List<CrmProductCategoryModel> categories;
  final List<CrmProductCategoryModel> filteredCategories;
  final List<CrmProductItemModel> products;
  final List<CrmProductItemModel> filteredProducts;
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTagModel> tags;
  final List<CrmDiscountModel> discounts;
  final String query;
  final String status;
  final String? selectedSort;
  final int currentTab;
  final bool isGridView;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const CrmProductsState({
    this.categories = const <CrmProductCategoryModel>[],
    this.filteredCategories = const <CrmProductCategoryModel>[],
    this.products = const <CrmProductItemModel>[],
    this.filteredProducts = const <CrmProductItemModel>[],
    this.clientTypes = const <CrmClientTypeModel>[],
    this.tags = const <CrmTagModel>[],
    this.discounts = const <CrmDiscountModel>[],
    this.query = '',
    this.status = 'All',
    this.selectedSort,
    this.currentTab = 0,
    this.isGridView = false,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  CrmProductsState copyWith({
    List<CrmProductCategoryModel>? categories,
    List<CrmProductCategoryModel>? filteredCategories,
    List<CrmProductItemModel>? products,
    List<CrmProductItemModel>? filteredProducts,
    List<CrmClientTypeModel>? clientTypes,
    List<CrmTagModel>? tags,
    List<CrmDiscountModel>? discounts,
    String? query,
    String? status,
    String? selectedSort,
    int? currentTab,
    bool? isGridView,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CrmProductsState(
        categories: categories ?? this.categories,
        filteredCategories: filteredCategories ?? this.filteredCategories,
        products: products ?? this.products,
        filteredProducts: filteredProducts ?? this.filteredProducts,
        clientTypes: clientTypes ?? this.clientTypes,
        tags: tags ?? this.tags,
        discounts: discounts ?? this.discounts,
        query: query ?? this.query,
        status: status ?? this.status,
        selectedSort: selectedSort ?? this.selectedSort,
        currentTab: currentTab ?? this.currentTab,
        isGridView: isGridView ?? this.isGridView,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      );
}
