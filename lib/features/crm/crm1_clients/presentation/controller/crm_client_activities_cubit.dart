// ****************** FILE INFO ******************
// File Name: crm_client_activities_cubit.dart
// Purpose: Business logic for CRM client activities.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'dart:async';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/repository/crm_client_activity_repository.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_activities_state.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_audit_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/repository/crm_category_and_tags_repository.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CrmClientActivitiesCubit extends Cubit<CrmClientActivitiesState> {
  final String clientId;
  final CrmClientActivityRepository _repository;
  final CrmCategoryAndTagsRepository _controls;
  StreamSubscription? _activitiesSub;
  StreamSubscription? _categoriesSub;
  StreamSubscription? _tagsSub;
  CrmClientActivitiesCubit(
      {required this.clientId,
      CrmClientActivityRepository? repository,
      CrmCategoryAndTagsRepository? controls})
      : _repository = repository ?? CrmClientActivityRepository(),
        _controls = controls ?? CrmCategoryAndTagsRepository(),
        super(const CrmClientActivitiesState());
  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _activitiesSub = _repository.watch(clientId).listen((items) {
      if (!isClosed) emit(state.copyWith(activities: items, isLoading: false));
    }, onError: (Object e) {
      if (!isClosed)
        emit(state.copyWith(isLoading: false, error: e.toString()));
    });
    _categoriesSub =
        _controls.watchCategories().listen((result) => result.fold((failure) {
              if (!isClosed) emit(state.copyWith(error: failure.errMessage));
            }, (items) {
              if (!isClosed)
                emit(state.copyWith(
                    categories: items
                        .where((item) => item.isActive && !item.isDeleted)
                        .toList()));
            }));
    _tagsSub = _controls.watchTags().listen((result) => result.fold((failure) {
          if (!isClosed) emit(state.copyWith(error: failure.errMessage));
        }, (items) {
          if (!isClosed)
            emit(state.copyWith(
                tags: items
                    .where((item) => item.isActive && !item.isDeleted)
                    .toList()));
        }));
  }

  List<CrmClientActivityModel> get visibleActivities {
    final items = state.activities.where((item) {
      final q = state.query.toLowerCase();
      return (state.status == 'all' || item.status == state.status) &&
          (q.isEmpty ||
              item.subjectEn.toLowerCase().contains(q) ||
              item.subjectAr.contains(q) ||
              item.assigneeName.toLowerCase().contains(q));
    }).toList();
    if (state.sort == 'oldest')
      items.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    else
      items.sort((a, b) => b.dueAt.compareTo(a.dueAt));
    return items;
  }

  List<EmployeeEntityPro> get employees =>
      Get.isRegistered<MainCoreEmployeeController>()
          ? (Get.find<MainCoreEmployeeController>().allEmployeesEntities ??
              <EmployeeEntityPro>[])
          : <EmployeeEntityPro>[];
  void setQuery(String value) {
    if (!isClosed) emit(state.copyWith(query: value));
  }

  void setStatus(String value) {
    if (!isClosed) emit(state.copyWith(status: value));
  }

  void setGrid(bool value) {
    if (!isClosed) emit(state.copyWith(isGrid: value));
  }

  void setSort(String? value) {
    if (!isClosed) emit(state.copyWith(sort: value, clearSort: value == null));
  }

  int count(String status) => state.activities
      .where((item) => status == 'all' ? !item.isDraft : item.status == status)
      .length;
  Future<bool> save(CrmClientActivityModel activity) async {
    if (!_valid(activity)) {
      emit(state.copyWith(error: 'Complete the required activity fields.'));
      return false;
    }
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final email = Get.isRegistered<MainCoreEmployeeController>()
          ? Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? ''
          : '';
      await _repository
          .save(activity.copyWith(audit: CrmAuditModel.now(userEmail: email)));
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(isSaving: false, error: e.toString()));
      return false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _repository.remove(clientId: clientId, activityId: id);
    } catch (e) {
      if (!isClosed) emit(state.copyWith(error: e.toString()));
    }
  }

  Future<bool> complete(
          CrmClientActivityModel item, DateTime endAt, String note) =>
      save(
          item.copyWith(status: 'completed', completedAt: endAt, noteEn: note));
  Future<bool> cancel(CrmClientActivityModel item) =>
      save(item.copyWith(status: 'cancelled'));
  bool _valid(CrmClientActivityModel item) =>
      item.status == 'draft' ||
      (item.categoryId.isNotEmpty &&
          item.typeId.isNotEmpty &&
          item.subjectEn.trim().isNotEmpty &&
          item.subjectAr.trim().isNotEmpty &&
          item.assigneeId.isNotEmpty);
  @override
  Future<void> close() async {
    await _activitiesSub?.cancel();
    await _categoriesSub?.cancel();
    await _tagsSub?.cancel();
    return super.close();
  }
}
