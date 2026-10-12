// ****************** FILE INFO ******************
// File Name: crm_navigation_helper.dart
// Purpose: Helper class for handling CRM internal route transitions.
// Author: Mohand Adel
// Created At: 03/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/helper/crm_helper/routing/crm_routes/crm_routes.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_client_type_form_page.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';

abstract class CrmNavigationHelper {
  /// Navigates to the CRM Clients List page.
  static Future<T?> navigateToClientsList<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.clientsList);
  }

  /// Navigates to the CRM Template Details page with template name and client type.
  static Future<T?> navigateToTemplateDetails<T>(
    BuildContext context, {
    required String templateName,
    String clientType = 'Person',
    String? clientTypeId,
    String? templateId,
    String? recordId,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.templateDetails,
      arguments: <String, dynamic>{
        'templateName': templateName,
        'clientType': clientType,
        'clientTypeId': clientTypeId,
        'templateId': templateId,
        'recordId': recordId,
      },
    );
  }

  /// Navigates to the CRM Client Profile page with all tabs and dynamic overview.
  static Future<T?> navigateToClientProfile<T>(
    BuildContext context, {
    required String recordId,
    String templateName = 'Client Profile',
    String clientType = 'Person',
    String? clientTypeId,
    String? templateId,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.clientProfile,
      arguments: <String, dynamic>{
        'recordId': recordId,
        'templateName': templateName,
        'clientType': clientType,
        'clientTypeId': clientTypeId,
        'templateId': templateId,
      },
    );
  }

  /// Navigates to the CRM Template Dashboard page with template name and client type.
  static Future<T?> navigateToTemplateDashboard<T>(
    BuildContext context, {
    required String templateName,
    String clientType = 'Person',
    String? clientTypeId,
    String? templateId,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.templateDashboard,
      arguments: <String, dynamic>{
        'templateName': templateName,
        'clientType': clientType,
        'clientTypeId': clientTypeId,
        'templateId': templateId,
      },
    );
  }

  /// Navigates to the CRM Add Client form page.
  static Future<T?> navigateToAddClient<T>(
    BuildContext context, {
    String? templateName,
    String? clientType,
    String? clientTypeId,
    String? templateId,
    dynamic editingRecord,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.addClient,
      arguments: <String, dynamic>{
        'templateName': templateName ?? 'Add New Client',
        'clientType': clientType ?? 'Person',
        'clientTypeId': clientTypeId,
        'templateId': templateId,
        'editingRecord': editingRecord,
      },
    );
  }

  /// Navigates to the CRM bulk upload review page.
  static Future<T?> navigateToBulkUpload<T>(
    BuildContext context, {
    String? templateName,
    String? clientType,
    String? clientTypeId,
    String? templateId,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.bulkUpload,
      arguments: <String, dynamic>{
        'templateName': templateName ?? 'Template Name',
        'clientType': clientType ?? 'Person',
        'clientTypeId': clientTypeId,
        'templateId': templateId,
      },
    );
  }

  /// Navigates to the CRM Controls page.
  static Future<T?> navigateToControls<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controls);
  }

  /// Navigates to the CRM Client Types page.
  static Future<T?> navigateToClientTypes<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.clientTypes);
  }

  /// Navigates to the CRM Templates page inside Controls.
  static Future<T?> navigateToControlTemplates<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controlTemplates);
  }

  /// Navigates to the CRM Template Builder page.
  static Future<T?> navigateToControlTemplateBuilder<T>(
    BuildContext context, {
    required String templateId,
    required String templateName,
    required String clientTypeId,
    String clientType = 'Individuals',
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlTemplateBuilder,
      arguments: <String, dynamic>{
        'templateId': templateId,
        'templateName': templateName,
        'clientTypeId': clientTypeId,
        'clientType': clientType,
      },
    );
  }

  /// Navigates to the CRM Template element form page.
  static Future<T?> navigateToControlTemplateElementForm<T>(
    BuildContext context, {
    String? templateId,
    required String templateName,
    String? clientTypeId,
    String clientType = 'Individuals',
    String? sectionId,
    String? fieldId,
    bool isSection = false,
    bool isEditing = false,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlTemplateElementForm,
      arguments: <String, dynamic>{
        'templateId': templateId,
        'templateName': templateName,
        'clientTypeId': clientTypeId,
        'clientType': clientType,
        'sectionId': sectionId,
        'fieldId': fieldId,
        'isSection': isSection,
        'isEditing': isEditing,
      },
    );
  }

  /// Navigates to the CRM Template layout page.
  static Future<T?> navigateToControlTemplateLayout<T>(
    BuildContext context, {
    String? templateId,
    required String templateName,
    String? clientTypeId,
    String clientType = 'Individuals',
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlTemplateLayout,
      arguments: <String, dynamic>{
        'templateId': templateId,
        'templateName': templateName,
        'clientTypeId': clientTypeId,
        'clientType': clientType,
      },
    );
  }

  /// Navigates to the CRM Template preview page.
  static Future<T?> navigateToControlTemplatePreview<T>(
    BuildContext context, {
    String? templateId,
    required String templateName,
    String? clientTypeId,
    String clientType = 'Individuals',
    dynamic layoutPages,
    List<CrmTemplateSectionModel> templateSections =
        const <CrmTemplateSectionModel>[],
    List<CrmTemplateFieldModel> templateFields =
        const <CrmTemplateFieldModel>[],
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlTemplatePreview,
      arguments: <String, dynamic>{
        'templateId': templateId,
        'templateName': templateName,
        'clientTypeId': clientTypeId,
        'clientType': clientType,
        'layoutPages': layoutPages,
        'templateSections': templateSections,
        'templateFields': templateFields,
      },
    );
  }

  /// Navigates to the CRM Client Type Form page (Add, Edit, or Details).
  static Future<T?> navigateToClientTypeForm<T>(
    BuildContext context, {
    CrmClientTypeFormMode mode = CrmClientTypeFormMode.add,
    CrmClientTypeModel? clientType,
    String? typeName,
    String? typeNameAr,
    String? svgAsset,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.clientTypeForm,
      arguments: <String, dynamic>{
        'mode': mode,
        'clientType': clientType,
        'typeName': typeName,
        'typeNameAr': typeNameAr,
        'svgAsset': svgAsset,
      },
    );
  }

  /// Navigates to the CRM Control Relationships list page.
  static Future<T?> navigateToControlRelationships<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controlRelationships);
  }

  /// Navigates to the CRM Control Relationship Add/Edit Category page.
  static Future<T?> navigateToControlRelationshipAddCategory<T>(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlRelationshipAddCategory,
      arguments: arguments,
    );
  }

  /// Navigates to the CRM Control Terms list page.
  static Future<T?> navigateToControlTerms<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controlTerms);
  }

  /// Navigates to the CRM Control Term Form/Details page.
  static Future<T?> navigateToControlTermForm<T>(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlTermForm,
      arguments: arguments,
    );
  }

  /// Navigates to the CRM Control Activity (Categories & Tags) page.
  static Future<T?> navigateToControlActivity<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controlActivity);
  }

  /// Navigates to the CRM Control Category Form/Details page.
  static Future<T?> navigateToControlCategoryForm<T>(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlCategoryForm,
      arguments: arguments,
    );
  }

  /// Navigates to the CRM Control Deals page.
  static Future<T?> navigateToControlDeals<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controlDeals);
  }

  /// Navigates to the CRM Client Deals main page.
  static Future<T?> navigateToDeals<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.deals);
  }

  /// Navigates to the CRM Deal Details page.
  static Future<T?> navigateToDealDetails<T>(
    BuildContext context, {
    required dynamic deal,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.dealDetails,
      arguments: <String, dynamic>{'deal': deal},
    );
  }

  /// Navigates to the CRM Add Deal creation wizard page.
  static Future<T?> navigateToCreateDeal<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.addDeal);
  }

  /// Navigates to the Add Quote creation wizard page.
  static Future<T?> navigateToCreateQuote<T>(
    BuildContext context, {
    required dynamic deal,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.addQuote,
      arguments: <String, dynamic>{'deal': deal},
    );
  }

  /// Navigates to the Quote Comparison page.
  static Future<T?> navigateToCompareQuotes<T>(
    BuildContext context, {
    required dynamic deal,
    required List<dynamic> quotes,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.compareQuotes,
      arguments: <String, dynamic>{
        'deal': deal,
        'quotes': quotes,
      },
    );
  }

  /// Navigates to CRM Products category management.
  static Future<T?> navigateToProducts<T>(BuildContext context) =>
      Navigator.pushNamed<T>(context, CrmRoutes.products);

  /// Navigates to the product category form in add, view, or edit mode.
  static Future<T?> navigateToProductCategoryForm<T>(
    BuildContext context, {
    required Map<String, dynamic> arguments,
  }) =>
      Navigator.pushNamed<T>(context, CrmRoutes.productCategoryForm,
          arguments: arguments);

  /// Navigates to the product item form in add, view, or edit mode.
  static Future<T?> navigateToProductItemForm<T>(
    BuildContext context, {
    required Map<String, dynamic> arguments,
  }) =>
      Navigator.pushNamed<T>(context, CrmRoutes.productItemForm,
          arguments: arguments);

  /// Navigates to CRM Services category management.
  static Future<T?> navigateToServices<T>(BuildContext context) =>
      Navigator.pushNamed<T>(context, CrmRoutes.services);

  /// Navigates to the service category form in add, view, or edit mode.
  static Future<T?> navigateToServiceCategoryForm<T>(
    BuildContext context, {
    required Map<String, dynamic> arguments,
  }) =>
      Navigator.pushNamed<T>(context, CrmRoutes.serviceCategoryForm,
          arguments: arguments);

  /// Navigates to the service item form in add, view, or edit mode.
  static Future<T?> navigateToServiceItemForm<T>(
    BuildContext context, {
    required Map<String, dynamic> arguments,
  }) =>
      Navigator.pushNamed<T>(context, CrmRoutes.serviceItemForm,
          arguments: arguments);

  /// Navigates to the CRM Control Discounts page.
  static Future<T?> navigateToControlDiscounts<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controlDiscounts);
  }

  /// Navigates to the CRM Control Discount form page.
  static Future<T?> navigateToControlDiscountForm<T>(
    BuildContext context, {
    required Map<String, dynamic> arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlDiscountForm,
      arguments: arguments,
    );
  }

  /// Navigates to the CRM Control Discounts details page.
  static Future<T?> navigateToControlDiscountDetails<T>(
    BuildContext context, {
    required Map<String, dynamic> arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlDiscountDetails,
      arguments: arguments,
    );
  }

  /// Navigates to the CRM Control Merge Levels page.
  static Future<T?> navigateToControlMerge<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.controlMerge);
  }

  /// Navigates to the CRM Control Merge Level form page.
  static Future<T?> navigateToControlMergeForm<T>(
    BuildContext context, {
    required Map<String, dynamic> arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.controlMergeForm,
      arguments: arguments,
    );
  }

  /// Navigates to the CRM Blacklisted Clients page.
  static Future<T?> navigateToBlacklisted<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.blacklisted);
  }

  /// Navigates to the CRM Teams list page.
  static Future<T?> navigateToTeams<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.teams);
  }

  /// Navigates to the CRM Add Team form page.
  static Future<T?> navigateToAddTeam<T>(
    BuildContext context, {
    List<CrmTeamModel>? existingTeams,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.teamForm,
      arguments: <String, dynamic>{
        'mode': 'add',
        'existingTeams': existingTeams,
      },
    );
  }

  /// Navigates to the CRM Edit Team form page.
  static Future<T?> navigateToEditTeam<T>(
    BuildContext context, {
    required CrmTeamModel team,
    List<CrmTeamModel>? existingTeams,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.teamForm,
      arguments: <String, dynamic>{
        'mode': 'edit',
        'team': team,
        'existingTeams': existingTeams,
      },
    );
  }

  /// Navigates to the CRM Team Details page.
  static Future<T?> navigateToTeamDetails<T>(
    BuildContext context, {
    required CrmTeamModel team,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.teamDetails,
      arguments: <String, dynamic>{
        'team': team,
      },
    );
  }

  /// Navigates to the CRM Duplicates Review & Merge page.
  static Future<T?> navigateToDuplicates<T>(BuildContext context) {
    return Navigator.pushNamed<T>(context, CrmRoutes.duplicates);
  }

  /// Navigates to the Quote Details page for a specific quote inside a deal.
  static Future<T?> navigateToQuoteDetails<T>(
    BuildContext context, {
    required String dealId,
    required String quoteId,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.quoteDetails,
      arguments: <String, dynamic>{
        'dealId': dealId,
        'quoteId': quoteId,
      },
    );
  }

  /// Navigates to the Deal Requests page.
  static Future<T?> navigateToRequests<T>(
    BuildContext context, {
    String dealTitle = 'ERP System Deal',
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.requests,
      arguments: <String, dynamic>{
        'dealTitle': dealTitle,
      },
    );
  }

  /// Navigates to the Request Details page.
  static Future<T?> navigateToRequestDetails<T>(
    BuildContext context, {
    String dealTitle = 'ERP System Deal',
    dynamic request,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.requestDetails,
      arguments: <String, dynamic>{
        'dealTitle': dealTitle,
        'request': request,
      },
    );
  }

  /// Navigates to the Create Contract page.
  static Future<T?> navigateToCreateContract<T>(
    BuildContext context, {
    dynamic deal,
    dynamic quote,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.createContract,
      arguments: <String, dynamic>{
        'deal': deal,
        'quote': quote,
      },
    );
  }

  /// Navigates to the Add / View / Edit / Reschedule Deal Activity page.
  static Future<T?> navigateToDealAddActivity<T>(
    BuildContext context, {
    String dealTitle = 'ERP System Deal',
    String mode = 'add',
    dynamic activity,
    ValueChanged<dynamic>? onActivityAdded,
    ValueChanged<dynamic>? onActivityUpdated,
    ValueChanged<dynamic>? onActivityDeleted,
  }) {
    return Navigator.pushNamed<T>(
      context,
      CrmRoutes.dealAddActivity,
      arguments: <String, dynamic>{
        'dealTitle': dealTitle,
        'mode': mode,
        'activity': activity,
        'onActivityAdded': onActivityAdded,
        'onActivityUpdated': onActivityUpdated,
        'onActivityDeleted': onActivityDeleted,
      },
    );
  }

  /// Pops the current route from the CRM nested navigator stack.
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pops back to the CRM Controls route if present, or pops.
  static void popToControls(BuildContext context) {
    Navigator.popUntil(
      context,
      (Route<dynamic> route) =>
          route.settings.name == CrmRoutes.controls || route.isFirst,
    );
  }

  /// Pops all routes until returning to the root CRM Dashboard.
  static void popToDashboard(BuildContext context) {
    Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
  }
}
