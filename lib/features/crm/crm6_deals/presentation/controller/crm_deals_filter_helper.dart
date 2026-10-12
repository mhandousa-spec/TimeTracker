// ****************** FILE INFO ******************
// File Name: crm_deals_filter_helper.dart
// Purpose: Helper methods for filtering and sorting CRM Deal Categories and Stages
// Author: Mohand Adel
// Created At: 22/08/2026

import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_category_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_stage_model.dart';

abstract class CrmDealsFilterHelper {
  /// Filters and sorts a list of CRM Deal Categories.
  static List<CrmDealCategoryModel> filterAndSortCategories({
    required List<CrmDealCategoryModel> categories,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) {
    List<CrmDealCategoryModel> result =
        List<CrmDealCategoryModel>.from(categories);

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      result = result.where((cat) {
        final bool nameEnMatch = cat.nameEn.toLowerCase().contains(q);
        final bool nameArMatch = cat.nameAr.toLowerCase().contains(q);
        return nameEnMatch || nameArMatch;
      }).toList();
    }

    final String status = selectedStatus.toLowerCase();
    if (status == 'active') {
      result = result.where((cat) => cat.isActive).toList();
    } else if (status == 'inactive') {
      result = result.where((cat) => !cat.isActive).toList();
    }

    result.sort((a, b) {
      if (selectedSort != null && selectedSort.isNotEmpty) {
        switch (selectedSort) {
          case 'name_asc':
            return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
          case 'name_desc':
            return b.nameEn.toLowerCase().compareTo(a.nameEn.toLowerCase());
          case 'date_asc':
            final DateTime aDate =
                a.audit?.createdAt ?? a.audit?.updatedAt ?? DateTime(1970);
            final DateTime bDate =
                b.audit?.createdAt ?? b.audit?.updatedAt ?? DateTime(1970);
            return aDate.compareTo(bDate);
          case 'date_desc':
            final DateTime aDate =
                a.audit?.createdAt ?? a.audit?.updatedAt ?? DateTime(1970);
            final DateTime bDate =
                b.audit?.createdAt ?? b.audit?.updatedAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
        }
      }

      // Default sorting: oldest first, newly added at the end
      final int orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      final DateTime aCreated =
          a.audit?.createdAt ?? a.audit?.updatedAt ?? DateTime(1970);
      final DateTime bCreated =
          b.audit?.createdAt ?? b.audit?.updatedAt ?? DateTime(1970);
      final int createdCompare = aCreated.compareTo(bCreated);
      if (createdCompare != 0) return createdCompare;
      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });

    return result;
  }

  /// Filters and sorts a list of CRM Deal Stages.
  static List<CrmDealStageModel> filterAndSortStages({
    required List<CrmDealStageModel> stages,
    required String query,
    required String selectedStatus,
    required String? selectedSort,
  }) {
    List<CrmDealStageModel> result = List<CrmDealStageModel>.from(stages);

    if (query.isNotEmpty) {
      final String q = query.toLowerCase();
      result = result.where((stg) {
        final bool nameEnMatch = stg.nameEn.toLowerCase().contains(q);
        final bool nameArMatch = stg.nameAr.toLowerCase().contains(q);
        return nameEnMatch || nameArMatch;
      }).toList();
    }

    final String status = selectedStatus.toLowerCase();
    if (status == 'active') {
      result = result.where((stg) => stg.isActive).toList();
    } else if (status == 'inactive') {
      result = result.where((stg) => !stg.isActive).toList();
    }

    result.sort((a, b) {
      if (selectedSort != null && selectedSort.isNotEmpty) {
        switch (selectedSort) {
          case 'name_asc':
            return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
          case 'name_desc':
            return b.nameEn.toLowerCase().compareTo(a.nameEn.toLowerCase());
          case 'date_asc':
            final DateTime aDate =
                stgAuditDate(a.audit?.createdAt, a.audit?.updatedAt);
            final DateTime bDate =
                stgAuditDate(b.audit?.createdAt, b.audit?.updatedAt);
            return aDate.compareTo(bDate);
          case 'date_desc':
            final DateTime aDate =
                stgAuditDate(a.audit?.createdAt, a.audit?.updatedAt);
            final DateTime bDate =
                stgAuditDate(b.audit?.createdAt, b.audit?.updatedAt);
            return bDate.compareTo(aDate);
        }
      }

      // Default sorting: oldest first, newly added at the end
      final int orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      final DateTime aCreated =
          stgAuditDate(a.audit?.createdAt, a.audit?.updatedAt);
      final DateTime bCreated =
          stgAuditDate(b.audit?.createdAt, b.audit?.updatedAt);
      final int createdCompare = aCreated.compareTo(bCreated);
      if (createdCompare != 0) return createdCompare;
      return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
    });

    return result;
  }

  static DateTime stgAuditDate(DateTime? created, DateTime? updated) {
    return created ?? updated ?? DateTime(1970);
  }
}
