// ****************** FILE INFO ******************
// File Name: crm_products_cubit.dart
// Purpose: Coordinates CRM product categories and product items with filtering, search, and view modes.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/domain/interfaces/crm_category_and_tags_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/interfaces/crm_products_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/domain/interfaces/crm_discounts_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'crm_products_state.dart';

class CrmProductsCubit extends Cubit<CrmProductsState> {
  final CrmProductsBaseRepository repository;
  final CrmControlsBaseRepository controlsRepository;
  final CrmCategoryAndTagsBaseRepository tagsRepository;
  final CrmDiscountsBaseRepository discountsRepository;
  StreamSubscription<Either<Failure, List<CrmProductCategoryModel>>>?
      _categories;
  StreamSubscription<Either<Failure, List<CrmProductItemModel>>>? _products;
  StreamSubscription? _types;
  StreamSubscription? _tags;
  StreamSubscription? _discounts;

  CrmProductsCubit({
    CrmProductsBaseRepository? repository,
    CrmControlsBaseRepository? controlsRepository,
    CrmCategoryAndTagsBaseRepository? tagsRepository,
    CrmDiscountsBaseRepository? discountsRepository,
  })  : repository = repository ?? Get.find<CrmProductsBaseRepository>(),
        controlsRepository =
            controlsRepository ?? Get.find<CrmControlsBaseRepository>(),
        tagsRepository =
            tagsRepository ?? Get.find<CrmCategoryAndTagsBaseRepository>(),
        discountsRepository =
            discountsRepository ?? Get.find<CrmDiscountsBaseRepository>(),
        super(const CrmProductsState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _categories?.cancel();
    _categories = repository.watchCategories().listen((result) => result.fold(
          _failure,
          (items) => emit(state.copyWith(
            categories: items,
            filteredCategories: _filterCategories(
              items,
              state.query,
              state.status,
              state.selectedSort,
            ),
            isLoading: false,
            clearError: true,
          )),
        ));

    await _products?.cancel();
    _products = repository.watchProducts().listen((result) => result.fold(
          _failure,
          (items) => emit(state.copyWith(
            products: items,
            filteredProducts: _filterProducts(
              items,
              state.query,
              state.status,
              state.selectedSort,
            ),
            isLoading: false,
            clearError: true,
          )),
        ));

    _types = controlsRepository.watchClientTypes().listen((result) =>
        result.fold(
            _failure,
            (items) => emit(state.copyWith(
                clientTypes: items
                    .where((item) => item.isActive && !item.isDeleted)
                    .toList()))));

    _tags = tagsRepository.watchTags().listen((result) => result.fold(
        _failure,
        (items) => emit(state.copyWith(
            tags: items
                .where((item) => item.isActive && !item.isDeleted)
                .toList()))));

    _discounts = discountsRepository.watchDiscounts().listen((result) =>
        result.fold(
            _failure,
            (items) => emit(state.copyWith(
                discounts: items
                    .where((item) => item.isActive && !item.isDeleted)
                    .toList()))));
  }

  void _failure(Failure error) {
    if (!isClosed) {
      emit(state.copyWith(isLoading: false, errorMessage: error.errMessage));
    }
  }

  void setTab(int tab) {
    emit(state.copyWith(
      currentTab: tab,
      filteredCategories: _filterCategories(
        state.categories,
        state.query,
        state.status,
        state.selectedSort,
      ),
      filteredProducts: _filterProducts(
        state.products,
        state.query,
        state.status,
        state.selectedSort,
      ),
    ));
  }

  void setViewMode(bool isGridView) {
    emit(state.copyWith(isGridView: isGridView));
  }

  void search(String value) => emit(state.copyWith(
        query: value,
        filteredCategories: _filterCategories(
          state.categories,
          value,
          state.status,
          state.selectedSort,
        ),
        filteredProducts: _filterProducts(
          state.products,
          value,
          state.status,
          state.selectedSort,
        ),
        clearError: true,
      ));

  void setStatus(String value) => emit(state.copyWith(
        status: value,
        filteredCategories: _filterCategories(
          state.categories,
          state.query,
          value,
          state.selectedSort,
        ),
        filteredProducts: _filterProducts(
          state.products,
          state.query,
          value,
          state.selectedSort,
        ),
        clearError: true,
      ));

  void setSort(String? sort) => emit(state.copyWith(
        selectedSort: sort,
        filteredCategories: _filterCategories(
          state.categories,
          state.query,
          state.status,
          sort,
        ),
        filteredProducts: _filterProducts(
          state.products,
          state.query,
          state.status,
          sort,
        ),
        clearError: true,
      ));

  // ==================== CATEGORIES ====================

  Future<bool> create(CrmProductCategoryModel category) =>
      _saveCategory(category, isNew: true);

  Future<bool> update(CrmProductCategoryModel category) =>
      _saveCategory(category);

  Future<bool> _saveCategory(CrmProductCategoryModel category,
      {bool isNew = false}) async {
    final error =
        _validateCategory(category, ignoreId: isNew ? null : category.id);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    final result = isNew
        ? await repository.createCategory(category, _email)
        : await repository.updateCategory(category, _email);
    return result.fold((failure) {
      emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
      return false;
    }, (_) {
      emit(state.copyWith(isSaving: false));
      return true;
    });
  }

  Future<bool> remove(CrmProductCategoryModel category) async {
    final result = await repository.deleteCategory(category, _email);
    return _complete(result);
  }

  Future<bool> setActive(
          CrmProductCategoryModel category, bool isActive) async =>
      _complete(
          await repository.setCategoryActive(category.id, isActive, _email));

  String? _validateCategory(CrmProductCategoryModel category,
      {String? ignoreId}) {
    if (category.nameEn.trim().isEmpty || category.nameAr.trim().isEmpty) {
      return 'Both category names are required';
    }
    if (category.clientTypeId.isEmpty) return 'Client type is required';
    if (category.noteEn.length > 500 || category.noteAr.length > 500) {
      return 'Notes cannot exceed 500 characters';
    }
    final duplicate = state.categories.any((item) =>
        item.id != ignoreId &&
        (item.nameEn.trim().toLowerCase() ==
                category.nameEn.trim().toLowerCase() ||
            item.nameAr.trim() == category.nameAr.trim()));
    return duplicate ? 'This category name already exists' : null;
  }

  // ==================== PRODUCT ITEMS ====================

  Future<bool> createProduct(CrmProductItemModel product) =>
      _saveProduct(product, isNew: true);

  Future<bool> updateProduct(CrmProductItemModel product) =>
      _saveProduct(product);

  Future<bool> _saveProduct(CrmProductItemModel product,
      {bool isNew = false}) async {
    final error =
        _validateProduct(product, ignoreId: isNew ? null : product.id);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    final result = isNew
        ? await repository.createProduct(product, _email)
        : await repository.updateProduct(product, _email);
    return result.fold((failure) {
      emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
      return false;
    }, (_) {
      emit(state.copyWith(isSaving: false));
      return true;
    });
  }

  Future<bool> removeProduct(CrmProductItemModel product) async {
    final result = await repository.deleteProduct(product, _email);
    return _complete(result);
  }

  Future<bool> setProductActive(
          CrmProductItemModel product, bool isActive) async =>
      _complete(
          await repository.setProductActive(product.id, isActive, _email));

  String? _validateProduct(CrmProductItemModel product, {String? ignoreId}) {
    if (product.nameEn.trim().isEmpty || product.nameAr.trim().isEmpty) {
      return 'Both product names are required';
    }
    if (product.categoryId.isEmpty) return 'Category is required';
    if (product.noteEn.length > 500 || product.noteAr.length > 500) {
      return 'Notes cannot exceed 500 characters';
    }
    final duplicate = state.products.any((item) =>
        item.id != ignoreId &&
        (item.nameEn.trim().toLowerCase() ==
                product.nameEn.trim().toLowerCase() ||
            item.nameAr.trim() == product.nameAr.trim()));
    return duplicate ? 'This product name already exists' : null;
  }

  bool _complete(Either<Failure, void> result) => result.fold((failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return false;
      }, (_) => true);

  List<CrmProductCategoryModel> _filterCategories(
    List<CrmProductCategoryModel> items,
    String query,
    String status,
    String? sort,
  ) {
    final normalized = query.trim().toLowerCase();
    List<CrmProductCategoryModel> result = items.where((item) {
      final matchesStatus =
          status == 'All' || item.status.toLowerCase() == status.toLowerCase();
      final matchesQuery = normalized.isEmpty ||
          item.nameEn.toLowerCase().contains(normalized) ||
          item.nameAr.toLowerCase().contains(normalized);
      return matchesStatus && matchesQuery;
    }).toList();

    if (sort != null && sort.isNotEmpty) {
      switch (sort) {
        case 'name_asc':
          result.sort((a, b) =>
              a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
          break;
        case 'name_desc':
          result.sort((a, b) =>
              b.nameEn.toLowerCase().compareTo(a.nameEn.toLowerCase()));
          break;
        case 'date_desc':
          result.sort((a, b) {
            final aDate = a.audit?.createdAt ?? DateTime(2000);
            final bDate = b.audit?.createdAt ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
          break;
        case 'date_asc':
          result.sort((a, b) {
            final aDate = a.audit?.createdAt ?? DateTime(2000);
            final bDate = b.audit?.createdAt ?? DateTime(2000);
            return aDate.compareTo(bDate);
          });
          break;
      }
    }

    return result;
  }

  List<CrmProductItemModel> _filterProducts(
    List<CrmProductItemModel> items,
    String query,
    String status,
    String? sort,
  ) {
    final normalized = query.trim().toLowerCase();
    List<CrmProductItemModel> result = items.where((item) {
      final matchesStatus =
          status == 'All' || item.status.toLowerCase() == status.toLowerCase();
      final matchesQuery = normalized.isEmpty ||
          item.nameEn.toLowerCase().contains(normalized) ||
          item.nameAr.toLowerCase().contains(normalized) ||
          item.code.toLowerCase().contains(normalized) ||
          item.categoryNameEn.toLowerCase().contains(normalized) ||
          item.categoryNameAr.toLowerCase().contains(normalized);
      return matchesStatus && matchesQuery;
    }).toList();

    if (sort != null && sort.isNotEmpty) {
      switch (sort) {
        case 'name_asc':
          result.sort((a, b) =>
              a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
          break;
        case 'name_desc':
          result.sort((a, b) =>
              b.nameEn.toLowerCase().compareTo(a.nameEn.toLowerCase()));
          break;
        case 'date_desc':
          result.sort((a, b) {
            final aDate = a.audit?.createdAt ?? DateTime(2000);
            final bDate = b.audit?.createdAt ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });
          break;
        case 'date_asc':
          result.sort((a, b) {
            final aDate = a.audit?.createdAt ?? DateTime(2000);
            final bDate = b.audit?.createdAt ?? DateTime(2000);
            return aDate.compareTo(bDate);
          });
          break;
      }
    }

    return result;
  }

  String get _email => Get.isRegistered<MainCoreEmployeeController>()
      ? Get.find<MainCoreEmployeeController>()
              .currentEmployee
              ?.email
              .toString() ??
          'system'
      : 'system';

  @override
  Future<void> close() async {
    await _categories?.cancel();
    await _products?.cancel();
    await _types?.cancel();
    await _tags?.cancel();
    await _discounts?.cancel();
    return super.close();
  }
}
