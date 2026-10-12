// ****************** FILE INFO ******************
// File Name: crm_blacklist_cubit.dart
// Purpose: Business logic and controller for CRM Blacklisted clients & requests.
// Author: Mohand Adel
// Created At: 27/08/2026

import 'dart:async';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/data/models/crm_blacklist_item_model.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/data/repository/crm_blacklist_repository.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/controller/crm_blacklist_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class CrmBlacklistCubit extends Cubit<CrmBlacklistState> {
  final CrmBlacklistRepository _repository;
  StreamSubscription? _clientsSub;
  StreamSubscription? _typesSub;

  CrmBlacklistCubit({CrmBlacklistRepository? repository})
      : _repository = repository ?? CrmBlacklistRepository(),
        super(const CrmBlacklistState());

  /// Function Name: init
  ///
  /// Purpose: Initializes the cubit by streaming client records and client types.
  void init() {
    emit(state.copyWith(isLoading: true, clearError: true));

    _typesSub = _repository.watchClientTypes().listen((result) {
      result.fold(
        (failure) {},
        (List<CrmClientTypeModel> types) {
          if (!isClosed) {
            emit(state.copyWith(clientTypes: types));
          }
        },
      );
    });

    _clientsSub = _repository.watchAllClientRecords().listen(
      (result) {
        result.fold(
          (failure) {
            if (!isClosed) {
              emit(state.copyWith(
                isLoading: false,
                errorMessage: failure.errMessage,
              ));
            }
          },
          (List<CrmClientRecordModel> records) {
            if (!isClosed) {
              _processRecords(records);
            }
          },
        );
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(
              state.copyWith(isLoading: false, errorMessage: error.toString()));
        }
      },
    );
  }

  void _processRecords(List<CrmClientRecordModel> records) {
    final Map<String, String> typeMap = <String, String>{};
    for (final CrmClientTypeModel t in state.clientTypes) {
      typeMap[t.id] =
          t.nameEn.isNotEmpty ? t.nameEn : (t.systemKey ?? 'Person');
    }

    final Map<String, String> empMap = <String, String>{};
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      final employees =
          Get.find<MainCoreEmployeeController>().allEmployeesEntities ?? [];
      for (final emp in employees) {
        final String fullName = [emp.firstName, emp.lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        if (fullName.isNotEmpty) {
          if (emp.email != null && emp.email!.isNotEmpty) {
            empMap[emp.email!.toLowerCase()] = fullName;
          }
          if (emp.id != null && emp.id!.isNotEmpty) {
            empMap[emp.id!] = fullName;
          }
        }
      }
    }

    final List<CrmBlacklistItemModel> blacklistedItems = [];
    for (final CrmClientRecordModel record in records) {
      if (record.status == 'deleted') continue;

      final bool hasBlacklistInfo = record.isBlacklisted ||
          record.blacklistDetails.isNotEmpty ||
          record.status.toLowerCase() == 'blacklist';

      if (hasBlacklistInfo) {
        final String typeName = typeMap[record.clientTypeId] ?? 'Person';
        final String reqBy = record.blacklistRequestedBy.toLowerCase();
        final String empName = empMap[reqBy] ??
            (record.blacklistRequestedBy.isNotEmpty
                ? record.blacklistRequestedBy.split('@').first
                : 'Staff');

        blacklistedItems.add(
          CrmBlacklistItemModel.fromClientRecord(
            record,
            clientTypeName: typeName,
            employeeDisplayName: empName,
          ),
        );
      }
    }

    emit(state.copyWith(
      items: blacklistedItems,
      isLoading: false,
    ));
  }

  /// Filtered list based on active tab, status filter, client type, search query, and sort.
  List<CrmBlacklistItemModel> get visibleItems {
    final String q = state.searchQuery.trim().toLowerCase();
    final String typeFilter = state.selectedClientType.trim().toLowerCase();

    final List<CrmBlacklistItemModel> filtered = state.items.where((item) {
      // 1. Tab filter
      if (state.selectedMainTab == 0) {
        // Blocked tab -> shows all currently blocked items
        if (!item.isBlocked) return false;
      } else {
        // Requests tab -> filter by requestStatusFilter
        if (state.requestStatusFilter != 'all' &&
            item.status != state.requestStatusFilter) {
          return false;
        }
      }

      // 2. Client type filter
      if (typeFilter != 'all' && typeFilter.isNotEmpty) {
        if (item.clientType.toLowerCase() != typeFilter &&
            item.clientTypeId.toLowerCase() != typeFilter) {
          return false;
        }
      }

      // 3. Search query filter
      if (q.isNotEmpty) {
        final bool matchName = item.clientNameEn.toLowerCase().contains(q) ||
            item.clientNameAr.contains(q);
        final bool matchReason = item.reason.toLowerCase().contains(q);
        final bool matchType = item.clientType.toLowerCase().contains(q);
        final bool matchBy = item.requestedByName.toLowerCase().contains(q);
        if (!matchName && !matchReason && !matchType && !matchBy) {
          return false;
        }
      }

      return true;
    }).toList();

    // 4. Sorting
    switch (state.sortOption) {
      case 'oldest':
        filtered.sort((a, b) => a.rawDate.compareTo(b.rawDate));
        break;
      case 'name_asc':
        filtered.sort((a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        break;
      case 'name_desc':
        filtered.sort((a, b) =>
            b.displayName.toLowerCase().compareTo(a.displayName.toLowerCase()));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.rawDate.compareTo(a.rawDate));
        break;
    }

    return filtered;
  }

  int get totalBlockedCount =>
      state.items.where((item) => item.isBlocked).length;

  int get totalRequestsCount => state.items.length;

  int get pendingRequestsCount =>
      state.items.where((item) => item.isPending).length;

  int get approvedRequestsCount =>
      state.items.where((item) => item.isApproved).length;

  int get rejectedRequestsCount =>
      state.items.where((item) => item.isRejected).length;

  /// Function Name: unblockClient
  ///
  /// Purpose: Unblocks a client and removes them from the blacklist.
  Future<bool> unblockClient({
    required String recordId,
    required String reason,
  }) async {
    try {
      final result = await _repository.unblockClient(
        recordId: recordId,
        reason: reason,
      );
      return result.fold(
        (failure) {
          if (!isClosed) {
            emit(state.copyWith(
              errorMessage: failure.errMessage,
            ));
          }
          return false;
        },
        (_) {
          if (!isClosed) {
            emit(state.copyWith(
              successMessage: 'Client removed from blacklist successfully',
            ));
          }
          return true;
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: e.toString()));
      }
      return false;
    }
  }

  void setMainTab(int index) {
    if (!isClosed) emit(state.copyWith(selectedMainTab: index));
  }

  void setRequestStatusFilter(String status) {
    if (!isClosed) emit(state.copyWith(requestStatusFilter: status));
  }

  void setSelectedClientType(String clientType) {
    if (!isClosed) emit(state.copyWith(selectedClientType: clientType));
  }

  void setGridView(bool isGrid) {
    if (!isClosed) emit(state.copyWith(isGridView: isGrid));
  }

  void setSearchQuery(String query) {
    if (!isClosed) emit(state.copyWith(searchQuery: query));
  }

  void setSortOption(String sort) {
    if (!isClosed) emit(state.copyWith(sortOption: sort));
  }

  void clearMessages() {
    if (!isClosed) emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  @override
  Future<void> close() async {
    await _clientsSub?.cancel();
    await _typesSub?.cancel();
    return super.close();
  }
}
