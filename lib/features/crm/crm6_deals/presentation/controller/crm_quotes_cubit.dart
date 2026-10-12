// ****************** FILE INFO ******************
// File Name: crm_quotes_cubit.dart
// Purpose: Controller Cubit for Deal Quotes managing filtering, search, view mode, and compare selection
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/data_source/crm_quotes_mock_data.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'crm_quotes_state.dart';

class CrmQuotesCubit extends Cubit<CrmQuotesState> {
  CrmQuotesCubit() : super(const CrmQuotesState());

  void init() {
    emit(state.copyWith(isLoading: true));
    final List<CrmQuoteModel> quotes = CrmQuotesMockData.getQuotes();
    emit(state.copyWith(
      isLoading: false,
      allQuotes: quotes,
      filteredQuotes: quotes,
    ));
  }

  void filterByStatus(CrmQuoteStatus status) {
    emit(state.copyWith(selectedStatus: status));
    _applyFilters();
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void setViewMode({required bool isGridView}) {
    emit(state.copyWith(isGridView: isGridView));
  }

  void toggleCompareMode() {
    final bool nextMode = !state.isCompareMode;
    emit(state.copyWith(
      isCompareMode: nextMode,
      selectedQuoteIds: nextMode ? state.selectedQuoteIds : const <String>{},
    ));
  }

  bool toggleQuoteSelection(String quoteId) {
    final Set<String> updated = Set<String>.from(state.selectedQuoteIds);
    if (updated.contains(quoteId)) {
      updated.remove(quoteId);
      emit(state.copyWith(selectedQuoteIds: updated));
      return true;
    } else {
      if (updated.length >= 3) {
        return false;
      }
      updated.add(quoteId);
      emit(state.copyWith(selectedQuoteIds: updated));
      return true;
    }
  }

  void toggleSelectAll() {
    if (state.selectedQuoteIds.length == state.filteredQuotes.length &&
        state.filteredQuotes.isNotEmpty) {
      emit(state.copyWith(selectedQuoteIds: const <String>{}));
    } else {
      final Set<String> allIds =
          state.filteredQuotes.map((CrmQuoteModel q) => q.id).toSet();
      emit(state.copyWith(selectedQuoteIds: allIds));
    }
  }

  void _applyFilters() {
    List<CrmQuoteModel> list = List<CrmQuoteModel>.from(state.allQuotes);

    // Status filter
    if (state.selectedStatus != CrmQuoteStatus.all) {
      list = list
          .where((CrmQuoteModel q) => q.clientStatus == state.selectedStatus)
          .toList();
    }

    // Search query
    final String query = state.searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((CrmQuoteModel q) {
        return q.quoteNo.toLowerCase().contains(query) ||
            q.clientStatus.labelEn.toLowerCase().contains(query) ||
            q.approvalStatus.toLowerCase().contains(query);
      }).toList();
    }

    emit(state.copyWith(filteredQuotes: list));
  }
}
