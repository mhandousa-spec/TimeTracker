// ****************** FILE INFO ******************
// File Name: crm_routes.dart
// Purpose: Route name constants for the CRM module.
// Author: Mohand Adel
// Created At: 03/08/2026

abstract class CrmRoutes {
  static const String dashboard = '/';
  static const String clientsList = '/crm/clients-list';
  static const String templateDetails = '/crm/template-details';
  static const String addClient = '/crm/add-client';
  static const String bulkUpload = '/crm/bulk-upload';
  static const String controls = '/crm/controls';
  static const String clientTypes = '/crm/controls/client-types';
  static const String clientTypeForm = '/crm/controls/client-type-form';
  static const String controlTemplates = '/crm/controls/templates';
  static const String controlTemplateBuilder =
      '/crm/controls/templates/builder';
  static const String controlTemplateElementForm =
      '/crm/controls/templates/element-form';
  static const String controlTemplateLayout = '/crm/controls/templates/layout';
  static const String controlTemplatePreview =
      '/crm/controls/templates/preview';
  static const String templateDashboard = '/crm/template-dashboard';
  static const String controlRelationships = '/crm/controls/relationships';
  static const String controlRelationshipAddCategory =
      '/crm/controls/relationship-add-category';
  static const String controlTerms = '/crm/controls/terms';
  static const String controlTermForm = '/crm/controls/term-form';
  static const String controlActivity = '/crm/controls/activity';
  static const String controlCategoryForm = '/crm/controls/category-form';
  static const String controlDeals = '/crm/controls/deals';
  static const String deals = '/crm/deals';
  static const String dealDetails = '/crm/deals/details';
  static const String addDeal = '/crm/deals/add';
  static const String addQuote = '/crm/deals/quotes/add';
  static const String quoteDetails = '/crm/deals/quotes/details';
  static const String compareQuotes = '/crm/deals/quotes/compare';
  static const String createContract = '/crm/deals/quotes/create-contract';
  static const String requests = '/crm/deals/requests';
  static const String requestDetails = '/crm/deals/requests/details';
  static const String dealAddActivity = '/crm/deals/activities/add';
  static const String products = '/crm/products';
  static const String productCategoryForm = '/crm/products/category-form';
  static const String productItemForm = '/crm/products/item-form';
  static const String services = '/crm/services';
  static const String serviceCategoryForm = '/crm/services/category-form';
  static const String serviceItemForm = '/crm/services/item-form';
  static const String controlDiscounts = '/crm/controls/discounts';
  static const String controlDiscountForm = '/crm/controls/discount-form';
  static const String controlDiscountDetails = '/crm/controls/discount-details';
  static const String controlMerge = '/crm/controls/merge';
  static const String controlMergeForm = '/crm/controls/merge-form';
  static const String clientProfile = '/crm/client-profile';
  static const String blacklisted = '/crm/blacklisted';
  static const String teams = '/crm/teams';
  static const String teamForm = '/crm/teams/form';
  static const String teamDetails = '/crm/teams/details';
  static const String duplicates = '/crm/duplicates';
  static const String mergeWizard = '/crm/duplicates/wizard';
  static const String mergeHistory = '/crm/duplicates/history';
  static const String mergeHistoryDetails = '/crm/duplicates/history-details';
}
