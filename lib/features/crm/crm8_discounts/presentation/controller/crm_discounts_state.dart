// ****************** FILE INFO ******************
// File Name: crm_discounts_state.dart
// Purpose: State model for CRM Discounts UI and state management
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';

class CrmDiscountsState {
  final List<CrmDiscountModel> items;
  final List<CrmDiscountModel> filteredItems;
  final List<CrmProductCategoryModel> categories;
  final List<CrmProductItemModel> products;
  final List<CrmClientTypeModel> clientTypes;
  final List<CrmTagModel> tags;
  final String searchQuery;
  final String selectedStatus; // 'All', 'Active', 'Inactive'
  final String? selectedSort;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  const CrmDiscountsState({
    this.items = const <CrmDiscountModel>[],
    this.filteredItems = const <CrmDiscountModel>[],
    this.categories = const <CrmProductCategoryModel>[],
    this.products = const <CrmProductItemModel>[],
    this.clientTypes = const <CrmClientTypeModel>[],
    this.tags = const <CrmTagModel>[],
    this.searchQuery = '',
    this.selectedStatus = 'All',
    this.selectedSort,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  CrmDiscountsState copyWith({
    List<CrmDiscountModel>? items,
    List<CrmDiscountModel>? filteredItems,
    List<CrmProductCategoryModel>? categories,
    List<CrmProductItemModel>? products,
    List<CrmClientTypeModel>? clientTypes,
    List<CrmTagModel>? tags,
    String? searchQuery,
    String? selectedStatus,
    String? selectedSort,
    bool clearSelectedSort = false,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return CrmDiscountsState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      clientTypes: clientTypes ?? this.clientTypes,
      tags: tags ?? this.tags,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSort:
          clearSelectedSort ? null : selectedSort ?? this.selectedSort,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : errorMessage,
      successMessage: clearMessages ? null : successMessage,
    );
  }
}
