// ****************** FILE INFO ******************
// File Name: crm_discounts_cubit.dart
// Purpose: Cubit for CRM Discounts Firebase integration, state management, and UI logic
// Author: Mohand Adel
// Created At: 23/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/domain/interfaces/crm_category_and_tags_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/domain/interfaces/crm_products_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/domain/interfaces/crm_discounts_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'crm_discounts_state.dart';

class CrmDiscountsCubit extends Cubit<CrmDiscountsState> {
  final CrmDiscountsBaseRepository repository;
  final CrmProductsBaseRepository productsRepository;
  final CrmControlsBaseRepository controlsRepository;
  final CrmCategoryAndTagsBaseRepository tagsRepository;

  StreamSubscription<Either<Failure, List<CrmDiscountModel>>>? _discountsSub;
  StreamSubscription<Either<Failure, List<CrmProductCategoryModel>>>?
      _categoriesSub;
  StreamSubscription<Either<Failure, List<CrmProductItemModel>>>? _productsSub;
  StreamSubscription<Either<Failure, List<CrmClientTypeModel>>>?
      _clientTypesSub;
  StreamSubscription<Either<Failure, List<CrmTagModel>>>? _tagsSub;

  CrmDiscountsCubit({
    CrmDiscountsBaseRepository? repository,
    CrmProductsBaseRepository? productsRepository,
    CrmControlsBaseRepository? controlsRepository,
    CrmCategoryAndTagsBaseRepository? tagsRepository,
  })  : repository = repository ?? Get.find<CrmDiscountsBaseRepository>(),
        productsRepository =
            productsRepository ?? Get.find<CrmProductsBaseRepository>(),
        controlsRepository =
            controlsRepository ?? Get.find<CrmControlsBaseRepository>(),
        tagsRepository =
            tagsRepository ?? Get.find<CrmCategoryAndTagsBaseRepository>(),
        super(const CrmDiscountsState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    await _cancelSubscriptions();

    _discountsSub = repository
        .watchDiscounts()
        .listen((Either<Failure, List<CrmDiscountModel>> result) {
      result.fold(
        (Failure failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (List<CrmDiscountModel> items) => emit(
          state.copyWith(
            items: items,
            filteredItems: _filterAndSort(
              items: items,
              query: state.searchQuery,
              selectedStatus: state.selectedStatus,
              selectedSort: state.selectedSort,
            ),
            isLoading: false,
            clearMessages: true,
          ),
        ),
      );
    });

    _categoriesSub = productsRepository.watchCategories().listen((result) {
      result.fold(
        (_) {},
        (List<CrmProductCategoryModel> categories) => emit(
          state.copyWith(
            categories:
                categories.where((c) => !c.isDeleted && c.isActive).toList(),
          ),
        ),
      );
    });

    _productsSub = productsRepository.watchProducts().listen((result) {
      result.fold(
        (_) {},
        (List<CrmProductItemModel> products) => emit(
          state.copyWith(
            products:
                products.where((p) => !p.isDeleted && p.isActive).toList(),
          ),
        ),
      );
    });

    _clientTypesSub = controlsRepository.watchClientTypes().listen((result) {
      result.fold(
        (_) {},
        (List<CrmClientTypeModel> clientTypes) => emit(
          state.copyWith(
            clientTypes:
                clientTypes.where((t) => !t.isDeleted && t.isActive).toList(),
          ),
        ),
      );
    });

    _tagsSub = tagsRepository.watchTags().listen((result) {
      result.fold(
        (_) {},
        (List<CrmTagModel> tags) => emit(
          state.copyWith(
            tags: tags.where((t) => !t.isDeleted && t.isActive).toList(),
          ),
        ),
      );
    });
  }

  void search(String query) {
    final String normalizedQuery = query.trim();
    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        filteredItems: _filterAndSort(
          items: state.items,
          query: normalizedQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: state.selectedSort,
        ),
        clearMessages: true,
      ),
    );
  }

  void setStatusFilter(String status) {
    emit(
      state.copyWith(
        selectedStatus: status,
        filteredItems: _filterAndSort(
          items: state.items,
          query: state.searchQuery,
          selectedStatus: status,
          selectedSort: state.selectedSort,
        ),
        clearMessages: true,
      ),
    );
  }

  void setSort(String? sort) {
    emit(
      state.copyWith(
        selectedSort: sort,
        filteredItems: _filterAndSort(
          items: state.items,
          query: state.searchQuery,
          selectedStatus: state.selectedStatus,
          selectedSort: sort,
        ),
        clearMessages: true,
      ),
    );
  }

  Future<bool> createDiscount(CrmDiscountModel discount) async {
    final String? validationError = _validateInputs(
      discount: discount,
      isEdit: false,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, CrmDiscountModel> result =
        await repository.createDiscount(
      discount: discount,
      userEmail: _currentUserEmail,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'created'));
        return true;
      },
    );
  }

  Future<bool> updateDiscount(CrmDiscountModel discount) async {
    final String? validationError = _validateInputs(
      discount: discount,
      isEdit: true,
    );
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError, isSaving: false));
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.updateDiscount(
      discount: discount,
      userEmail: _currentUserEmail,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'updated'));
        return true;
      },
    );
  }

  Future<bool> deleteDiscount(CrmDiscountModel discount) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.deleteDiscount(
      discount: discount,
      userEmail: _currentUserEmail,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'deleted'));
        return true;
      },
    );
  }

  Future<bool> toggleStatus(CrmDiscountModel discount, bool isActive) async {
    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.toggleStatus(
      discountId: discount.id,
      isActive: isActive,
      userEmail: _currentUserEmail,
    );

    return result.fold(
      (Failure failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
        return false;
      },
      (_) {
        emit(state.copyWith(isSaving: false, successMessage: 'updated'));
        return true;
      },
    );
  }

  String? _validateInputs({
    required CrmDiscountModel discount,
    required bool isEdit,
  }) {
    final String nameEn = discount.nameEn.trim();
    final String nameAr = discount.nameAr.trim();

    if (nameEn.isEmpty) {
      return S.current.crmPleaseEnterRuleNameEn;
    }
    if (nameAr.isEmpty) {
      return S.current.crmPleaseEnterRuleNameAr;
    }

    // Check English characters constraint (no Arabic letters)
    final RegExp arabicRegex = RegExp(r'[\u0600-\u06FF]');
    if (arabicRegex.hasMatch(nameEn)) {
      return S.current.crmEnglishLettersOnlyTitle;
    }

    // Check Arabic characters constraint (no English letters)
    final RegExp englishRegex = RegExp(r'[a-zA-Z]');
    if (englishRegex.hasMatch(nameAr)) {
      return S.current.crmArabicLettersOnlyTitle;
    }

    // Duplicate check
    final bool duplicate = state.items.any((CrmDiscountModel item) {
      if (isEdit && item.id == discount.id) return false;
      return item.nameEn.trim().toLowerCase() == nameEn.toLowerCase() ||
          item.nameAr.trim() == nameAr;
    });

    if (duplicate) {
      return S.current.crmNameAlreadyExists;
    }

    if (discount.discountValue <= 0) {
      return S.current.crmPleaseEnterDiscountValue;
    }

    return null;
  }

  List<CrmDiscountModel> _filterAndSort({
    required List<CrmDiscountModel> items,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) {
    List<CrmDiscountModel> result =
        items.where((CrmDiscountModel item) => !item.isDeleted).toList();

    // 1. Status Filter
    if (selectedStatus == 'Active') {
      result = result.where((CrmDiscountModel item) => item.isActive).toList();
    } else if (selectedStatus == 'Inactive') {
      result = result.where((CrmDiscountModel item) => !item.isActive).toList();
    }

    // 2. Search Query
    if (query.isNotEmpty) {
      final String lowerQuery = query.toLowerCase();
      result = result.where((CrmDiscountModel item) {
        final bool matchNameEn = item.nameEn.toLowerCase().contains(lowerQuery);
        final bool matchNameAr = item.nameAr.contains(query);
        final bool matchType = item.type.toLowerCase().contains(lowerQuery);
        final bool matchCategory =
            item.categoryNameEn.toLowerCase().contains(lowerQuery) ||
                item.categoryNameAr.contains(query);
        final bool matchProduct =
            item.productNameEn.toLowerCase().contains(lowerQuery) ||
                item.productNameAr.contains(query);
        final bool matchTeam =
            item.applyOnTeam.toLowerCase().contains(lowerQuery);
        final bool matchClientType =
            item.clientTypeName.toLowerCase().contains(lowerQuery);
        return matchNameEn ||
            matchNameAr ||
            matchType ||
            matchCategory ||
            matchProduct ||
            matchTeam ||
            matchClientType;
      }).toList();
    }

    // 3. Sorting
    if (selectedSort != null) {
      switch (selectedSort) {
        case 'newest':
          result.sort((CrmDiscountModel a, CrmDiscountModel b) {
            final DateTime dtA =
                a.audit?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final DateTime dtB =
                b.audit?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dtB.compareTo(dtA);
          });
          break;
        case 'oldest':
          result.sort((CrmDiscountModel a, CrmDiscountModel b) {
            final DateTime dtA =
                a.audit?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final DateTime dtB =
                b.audit?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return dtA.compareTo(dtB);
          });
          break;
        case 'a_z':
          result.sort((CrmDiscountModel a, CrmDiscountModel b) =>
              a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
          break;
        case 'z_a':
          result.sort((CrmDiscountModel a, CrmDiscountModel b) =>
              b.nameEn.toLowerCase().compareTo(a.nameEn.toLowerCase()));
          break;
        case 'high_low':
          result.sort((CrmDiscountModel a, CrmDiscountModel b) =>
              b.discountValue.compareTo(a.discountValue));
          break;
        case 'low_high':
          result.sort((CrmDiscountModel a, CrmDiscountModel b) =>
              a.discountValue.compareTo(b.discountValue));
          break;
        default:
          result.sort((CrmDiscountModel a, CrmDiscountModel b) =>
              a.order.compareTo(b.order));
          break;
      }
    } else {
      result.sort((CrmDiscountModel a, CrmDiscountModel b) =>
          a.order.compareTo(b.order));
    }

    return result;
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    return 'system';
  }

  Future<void> _cancelSubscriptions() async {
    await _discountsSub?.cancel();
    await _categoriesSub?.cancel();
    await _productsSub?.cancel();
    await _clientTypesSub?.cancel();
    await _tagsSub?.cancel();
  }

  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
