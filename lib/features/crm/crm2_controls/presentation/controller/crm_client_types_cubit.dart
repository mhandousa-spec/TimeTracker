// ****************** FILE INFO ******************
// File Name: crm_client_types_cubit.dart
// Purpose: Cubit for CRM client types Firebase integration and UI logic
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'crm_client_types_state.dart';

class CrmClientTypesCubit extends Cubit<CrmClientTypesState> {
  final CrmControlsBaseRepository repository;
  StreamSubscription<Either<Failure, List<CrmClientTypeModel>>>?
      _clientTypesSubscription;
  bool _defaultsEnsured = false;

  CrmClientTypesCubit({
    CrmControlsBaseRepository? repository,
  })  : repository = repository ?? Get.find<CrmControlsBaseRepository>(),
        super(const CrmClientTypesState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    final String userEmail = _currentUserEmail;

    if (!_defaultsEnsured) {
      final Either<Failure, void> defaultsResult =
          await repository.ensureDefaults(userEmail: userEmail);
      if (defaultsResult.isLeft()) {
        defaultsResult.fold(
          (failure) => emit(
            state.copyWith(
              isLoading: false,
              errorMessage: failure.errMessage,
            ),
          ),
          (_) {},
        );
        return;
      }
      _defaultsEnsured = true;
    }

    await watchClientTypes();
  }

  Future<void> watchClientTypes() async {
    await _clientTypesSubscription?.cancel();
    _clientTypesSubscription = repository.watchClientTypes().listen((result) {
      result.fold(
        (failure) => emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.errMessage,
          ),
        ),
        (items) => emit(
          state.copyWith(
            items: items,
            filteredItems: _filterItems(items, state.searchQuery),
            isLoading: false,
            clearMessages: true,
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
        filteredItems: _filterItems(state.items, normalizedQuery),
        clearMessages: true,
      ),
    );
  }

  void selectType(CrmClientTypeModel type) {
    emit(state.copyWith(selectedType: type, clearMessages: true));
  }

  Future<bool> createType({
    required String nameEn,
    required String nameAr,
    File? image,
  }) async {
    if (!_validateNames(nameEn: nameEn, nameAr: nameAr)) return false;

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final String typeId =
        'client_type_${DateTime.now().microsecondsSinceEpoch}';
    final String iconUrl = await _uploadIconIfNeeded(
      image: image,
      typeId: typeId,
    );
    if (state.errorMessage != null) return false;

    final Either<Failure, CrmClientTypeModel> result =
        await repository.createClientType(
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      userEmail: _currentUserEmail,
      iconUrl: iconUrl,
      svgAsset: iconUrl.isEmpty ? AppAssets.crmPerson : '',
      iconKey: iconUrl.isEmpty ? 'crmPerson' : '',
      typeId: typeId,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (clientType) {
        emit(
          state.copyWith(
            selectedType: clientType,
            isSaving: false,
            successMessage: 'created',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> updateType({
    required CrmClientTypeModel currentType,
    required String nameEn,
    required String nameAr,
    File? image,
  }) async {
    if (!_validateNames(nameEn: nameEn, nameAr: nameAr)) return false;

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final String iconUrl = await _uploadIconIfNeeded(
      image: image,
      typeId: currentType.id,
    );
    if (state.errorMessage != null) return false;

    final CrmClientTypeModel updatedType = currentType.copyWith(
      title: nameEn.trim(),
      nameEn: nameEn.trim(),
      nameAr: nameAr.trim(),
      iconUrl: iconUrl.isEmpty ? currentType.iconUrl : iconUrl,
      svgAsset: iconUrl.isEmpty ? currentType.svgAsset : '',
      iconKey: iconUrl.isEmpty ? currentType.iconKey : '',
    );

    final Either<Failure, void> result = await repository.updateClientType(
      clientType: updatedType,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            selectedType: updatedType,
            isSaving: false,
            successMessage: 'updated',
          ),
        );
        return true;
      },
    );
  }

  Future<bool> removeType(CrmClientTypeModel clientType) async {
    if (clientType.isDefault) {
      emit(
        state.copyWith(
          errorMessage: 'Default client types cannot be removed',
        ),
      );
      return false;
    }

    emit(state.copyWith(isSaving: true, clearMessages: true));
    final Either<Failure, void> result = await repository.removeClientType(
      clientType: clientType,
      changedBy: _currentUserEmail,
    );

    return result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return false;
      },
      (_) {
        emit(
          state.copyWith(
            clearSelectedType: true,
            isSaving: false,
            successMessage: 'removed',
          ),
        );
        return true;
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  bool _validateNames({
    required String nameEn,
    required String nameAr,
  }) {
    if (nameEn.trim().isEmpty || nameAr.trim().isEmpty) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Client type English and Arabic names are required',
        ),
      );
      return false;
    }
    return true;
  }

  Future<String> _uploadIconIfNeeded({
    required File? image,
    required String typeId,
  }) async {
    if (image == null) return '';

    final Either<Failure, String> uploadResult =
        await repository.uploadClientTypeIcon(
      image: image,
      typeId: typeId,
    );

    return uploadResult.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.errMessage,
          ),
        );
        return '';
      },
      (url) => url,
    );
  }

  List<CrmClientTypeModel> _filterItems(
    List<CrmClientTypeModel> items,
    String query,
  ) {
    final String normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) return items;
    return items.where((item) {
      return item.nameEn.toLowerCase().contains(normalizedQuery) ||
          item.nameAr.toLowerCase().contains(normalizedQuery) ||
          item.title.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  String get _currentUserEmail {
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final String? email =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email;
      if (email != null && email.trim().isNotEmpty) {
        return email.trim().toLowerCase();
      }
    }
    final String? fallbackEmail = Constant.emailUser;
    if (fallbackEmail != null && fallbackEmail.trim().isNotEmpty) {
      return fallbackEmail.trim().toLowerCase();
    }
    return 'system';
  }

  @override
  Future<void> close() async {
    await _clientTypesSubscription?.cancel();
    return super.close();
  }
}
