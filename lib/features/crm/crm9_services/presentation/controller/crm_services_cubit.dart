// ****************** FILE INFO ******************
// File Name: crm_services_cubit.dart
// Purpose: Coordinates CRM service categories and service items with filtering, search, and view modes.
// Author: Mohand Adel
// Created At: 25/08/2026

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/domain/interfaces/crm_category_and_tags_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/domain/interfaces/crm_discounts_base_repository.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/domain/interfaces/crm_services_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'crm_services_state.dart';

class CrmServicesCubit extends Cubit<CrmServicesState> {
  final CrmServicesBaseRepository repository;
  final CrmControlsBaseRepository controlsRepository;
  final CrmCategoryAndTagsBaseRepository tagsRepository;
  final CrmDiscountsBaseRepository discountsRepository;
  StreamSubscription<Either<Failure, List<CrmServiceCategoryModel>>>?
      _categories;
  StreamSubscription<Either<Failure, List<CrmServiceItemModel>>>? _services;
  StreamSubscription? _types;
  StreamSubscription? _tags;
  StreamSubscription? _discounts;

  CrmServicesCubit({
    CrmServicesBaseRepository? repository,
    CrmControlsBaseRepository? controlsRepository,
    CrmCategoryAndTagsBaseRepository? tagsRepository,
    CrmDiscountsBaseRepository? discountsRepository,
  })  : repository = repository ?? Get.find<CrmServicesBaseRepository>(),
        controlsRepository =
            controlsRepository ?? Get.find<CrmControlsBaseRepository>(),
        tagsRepository =
            tagsRepository ?? Get.find<CrmCategoryAndTagsBaseRepository>(),
        discountsRepository =
            discountsRepository ?? Get.find<CrmDiscountsBaseRepository>(),
        super(const CrmServicesState());

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

    await _services?.cancel();
    _services = repository.watchServices().listen((result) => result.fold(
          _failure,
          (items) => emit(state.copyWith(
            services: items,
            filteredServices: _filterServices(
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
      filteredServices: _filterServices(
        state.services,
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
        filteredServices: _filterServices(
          state.services,
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
        filteredServices: _filterServices(
          state.services,
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
        filteredServices: _filterServices(
          state.services,
          state.query,
          state.status,
          sort,
        ),
        clearError: true,
      ));

  // ==================== CATEGORIES ====================

  Future<bool> create(CrmServiceCategoryModel category) =>
      _saveCategory(category, isNew: true);

  Future<bool> update(CrmServiceCategoryModel category) =>
      _saveCategory(category);

  Future<bool> _saveCategory(CrmServiceCategoryModel category,
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

  Future<bool> remove(CrmServiceCategoryModel category) async {
    final result = await repository.deleteCategory(category, _email);
    return _complete(result);
  }

  Future<bool> setActive(
          CrmServiceCategoryModel category, bool isActive) async =>
      _complete(
          await repository.setCategoryActive(category.id, isActive, _email));

  String? _validateCategory(CrmServiceCategoryModel category,
      {String? ignoreId}) {
    if (category.nameEn.trim().isEmpty || category.nameAr.trim().isEmpty) {
      return S.current.crmRequiredField;
    }
    if (category.noteEn.length > 500 || category.noteAr.length > 500) {
      return S.current.crmConstraints;
    }
    final duplicate = state.categories.any((item) =>
        item.id != ignoreId &&
        (item.nameEn.trim().toLowerCase() ==
                category.nameEn.trim().toLowerCase() ||
            item.nameAr.trim() == category.nameAr.trim()));
    return duplicate ? S.current.crmNameAlreadyExists : null;
  }

  // ==================== SERVICE ITEMS ====================

  Future<bool> createService(CrmServiceItemModel service) =>
      _saveService(service, isNew: true);

  Future<bool> updateService(CrmServiceItemModel service) =>
      _saveService(service);

  Future<bool> _saveService(CrmServiceItemModel service,
      {bool isNew = false}) async {
    final error =
        _validateService(service, ignoreId: isNew ? null : service.id);
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    final result = isNew
        ? await repository.createService(service, _email)
        : await repository.updateService(service, _email);
    return result.fold((failure) {
      emit(state.copyWith(isSaving: false, errorMessage: failure.errMessage));
      return false;
    }, (_) {
      emit(state.copyWith(isSaving: false));
      return true;
    });
  }

  Future<bool> removeService(CrmServiceItemModel service) async {
    final result = await repository.deleteService(service, _email);
    return _complete(result);
  }

  Future<bool> setServiceActive(
          CrmServiceItemModel service, bool isActive) async =>
      _complete(
          await repository.setServiceActive(service.id, isActive, _email));

  String? _validateService(CrmServiceItemModel service, {String? ignoreId}) {
    if (service.nameEn.trim().isEmpty || service.nameAr.trim().isEmpty) {
      return S.current.crmRequiredField;
    }
    if (service.categoryId.isEmpty) return S.current.crmFieldRequired;
    if (service.noteEn.length > 500 || service.noteAr.length > 500) {
      return S.current.crmConstraints;
    }
    final duplicate = state.services.any((item) =>
        item.id != ignoreId &&
        (item.nameEn.trim().toLowerCase() ==
                service.nameEn.trim().toLowerCase() ||
            item.nameAr.trim() == service.nameAr.trim()));
    return duplicate ? S.current.crmNameAlreadyExists : null;
  }

  bool _complete(Either<Failure, void> result) => result.fold((failure) {
        emit(state.copyWith(errorMessage: failure.errMessage));
        return false;
      }, (_) => true);

  List<CrmServiceCategoryModel> _filterCategories(
    List<CrmServiceCategoryModel> items,
    String query,
    String status,
    String? sort,
  ) {
    final normalized = query.trim().toLowerCase();
    List<CrmServiceCategoryModel> result = items.where((item) {
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

  List<CrmServiceItemModel> _filterServices(
    List<CrmServiceItemModel> items,
    String query,
    String status,
    String? sort,
  ) {
    final normalized = query.trim().toLowerCase();
    List<CrmServiceItemModel> result = items.where((item) {
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
    await _services?.cancel();
    await _types?.cancel();
    await _tags?.cancel();
    await _discounts?.cancel();
    return super.close();
  }
}
