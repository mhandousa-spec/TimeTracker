// ****************** FILE INFO ******************
// File Name: crm_router.dart
// Purpose: Route generator for managing CRM internal navigation.
// Author: Mohand Adel
// Created At: 03/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/crm_helper/routing/crm_routes/crm_routes.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_client_form_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_add_client_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_bulk_upload_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_client_profile_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_client_template_details_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_clients_dashboard_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_template_dashboard_page.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/pages/crm_clients_list_page.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/controller/crm_blacklist_cubit.dart';
import 'package:knowticed_plus/features/crm/crm10_blacklist/presentation/ui/pages/crm_blacklisted_page.dart';
import 'package:knowticed_plus/features/crm/crm_di.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_merge_level_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_merge_levels_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_client_type_form_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_client_types_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_controls_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_merge_level_form_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_merge_levels_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_template_builder_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_template_element_form_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_template_layout_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_template_preview_page.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/pages/crm_templates_page.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/presentation/ui/pages/crm_relationship_list_page.dart';
import 'package:knowticed_plus/features/crm/crm3_relationship/presentation/ui/pages/crm_relationship_add_category_page.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/data/models/crm_term_model.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/presentation/ui/pages/crm_terms_list_page.dart';
import 'package:knowticed_plus/features/crm/crm4_terms/presentation/ui/pages/crm_term_form_page.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_category_model.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/pages/crm_activity_main_page.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/presentation/ui/pages/crm_category_form_page.dart';
import 'package:knowticed_plus/features/crm/crm5_category_and_tags/data/models/crm_tag_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_category_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/data/models/crm_product_item_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/pages/crm_products_page.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/data/models/crm_discount_model.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/pages/crm_product_category_form_page.dart';
import 'package:knowticed_plus/features/crm/crm7_products/presentation/ui/pages/crm_product_item_form_page.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_category_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/data/models/crm_service_item_model.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/pages/crm_services_page.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/pages/crm_service_category_form_page.dart';
import 'package:knowticed_plus/features/crm/crm9_services/presentation/ui/pages/crm_service_item_form_page.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/presentation/ui/pages/crm_discounts_page.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/presentation/ui/pages/crm_discount_form_page.dart';
import 'package:knowticed_plus/features/crm/crm8_discounts/presentation/ui/pages/crm_discount_details_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_activity_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_deal_request_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_add_deal_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_add_quote_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_compare_quotes_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_create_contract_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_deal_add_activity_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_deal_details_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_deals_main_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_quote_details_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_request_details_page.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/pages/crm_requests_page.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/data/models/crm_team_model.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/controller/crm_teams_cubit.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/pages/crm_team_details_page.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/pages/crm_team_form_page.dart';
import 'package:knowticed_plus/features/crm/crm11_teams/presentation/ui/pages/crm_teams_page.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/domain/interfaces/crm_duplicates_repository_interface.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_merge_history_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/controller/crm_duplicates_cubit.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_duplicates_page.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_merge_wizard_page.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_merge_history_page.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/pages/crm_merge_history_details_page.dart';

abstract class CrmRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case CrmRoutes.dashboard:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmClientsListCubit>(
            create: (_) => CrmClientsListCubit()..init(),
            child: const CrmClientsDashboardPage(),
          ),
        );

      case CrmRoutes.clientsList:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmClientsListCubit>(
            create: (_) => CrmClientsListCubit(),
            child: const CrmClientsListPage(),
          ),
        );

      case CrmRoutes.templateDetails:
        String templateName = 'Template Details';
        String clientType = 'Person';
        String? clientTypeId;
        String? templateId;
        String? recordId;
        final Object? args = settings.arguments;
        if (args is Map<String, dynamic>) {
          templateName = args['templateName'] as String? ?? 'Template Details';
          clientType = args['clientType'] as String? ?? 'Person';
          clientTypeId = args['clientTypeId'] as String?;
          templateId = args['templateId'] as String?;
          recordId = args['recordId'] as String?;
        } else if (args is String) {
          templateName = args;
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmClientsListCubit>(
            create: (_) => CrmClientsListCubit()
              ..init(
                preferredClientTypeId: clientTypeId,
              ),
            child: CrmClientTemplateDetailsPage(
              templateName: templateName,
              clientType: clientType,
              clientTypeId: clientTypeId,
              templateId: templateId,
              recordId: recordId,
            ),
          ),
        );

      case CrmRoutes.clientProfile:
        String templateName = 'Client Profile';
        String clientType = 'Person';
        String? clientTypeId;
        String? templateId;
        String recordId = '';
        final Object? profileArgs = settings.arguments;
        if (profileArgs is Map<String, dynamic>) {
          templateName =
              profileArgs['templateName'] as String? ?? 'Client Profile';
          clientType = profileArgs['clientType'] as String? ?? 'Person';
          clientTypeId = profileArgs['clientTypeId'] as String?;
          templateId = profileArgs['templateId'] as String?;
          recordId = profileArgs['recordId'] as String? ?? '';
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmClientsListCubit>(
            create: (_) => CrmClientsListCubit()
              ..init(
                preferredClientTypeId: clientTypeId,
              ),
            child: CrmClientProfilePage(
              recordId: recordId,
              templateName: templateName,
              clientType: clientType,
              clientTypeId: clientTypeId,
              templateId: templateId,
            ),
          ),
        );

      case CrmRoutes.blacklisted:
        registerCrmDependencies();
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmBlacklistCubit>(
            create: (_) => CrmBlacklistCubit()..init(),
            child: const CrmBlacklistedPage(),
          ),
        );

      case CrmRoutes.templateDashboard:
        String templateName = 'Template Details';
        String clientType = 'Person';
        String? clientTypeId;
        String? templateId;
        final Object? dashArgs = settings.arguments;
        if (dashArgs is Map<String, dynamic>) {
          templateName =
              dashArgs['templateName'] as String? ?? 'Template Details';
          clientType = dashArgs['clientType'] as String? ?? 'Person';
          clientTypeId = dashArgs['clientTypeId'] as String?;
          templateId = dashArgs['templateId'] as String?;
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmClientsListCubit>(
            create: (_) => CrmClientsListCubit()
              ..init(
                preferredClientTypeId: clientTypeId,
              ),
            child: CrmTemplateDashboardPage(
              templateId: templateId ?? '',
              templateName: templateName,
              clientType: clientType,
              clientTypeId: clientTypeId,
            ),
          ),
        );

      case CrmRoutes.addClient:
        String templateName = 'Add New Client';
        String clientType = 'Person';
        String? clientTypeId;
        String? templateId;
        dynamic editingRecord;
        final Object? addArgs = settings.arguments;
        if (addArgs is Map<String, dynamic>) {
          templateName = addArgs['templateName'] as String? ?? 'Add New Client';
          clientType = addArgs['clientType'] as String? ?? 'Person';
          clientTypeId = addArgs['clientTypeId'] as String?;
          templateId = addArgs['templateId'] as String?;
          editingRecord = addArgs['editingRecord'];
        } else if (addArgs is String) {
          clientType = addArgs;
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmClientFormCubit>(
            create: (_) => CrmClientFormCubit(),
            child: CrmAddClientPage(
              templateName: templateName,
              clientType: clientType,
              clientTypeId: clientTypeId,
              templateId: templateId,
              editingRecord: editingRecord,
            ),
          ),
        );

      case CrmRoutes.bulkUpload:
        String templateName = 'Template Name';
        String clientType = 'Person';
        String? clientTypeId;
        String? templateId;
        final Object? uploadArgs = settings.arguments;
        if (uploadArgs is Map<String, dynamic>) {
          templateName =
              uploadArgs['templateName'] as String? ?? 'Template Name';
          clientType = uploadArgs['clientType'] as String? ?? 'Person';
          clientTypeId = uploadArgs['clientTypeId'] as String?;
          templateId = uploadArgs['templateId'] as String?;
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmBulkUploadPage(
            templateName: templateName,
            clientType: clientType,
            clientTypeId: clientTypeId,
            templateId: templateId,
          ),
        );

      case CrmRoutes.controls:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmControlsPage(),
        );

      case CrmRoutes.clientTypes:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmClientTypesPage(),
        );

      case CrmRoutes.clientTypeForm:
        CrmClientTypeFormMode initialMode = CrmClientTypeFormMode.add;
        CrmClientTypeModel? clientType;
        String? typeName;
        String? typeNameAr;
        String? svgAsset;

        final Object? formArgs = settings.arguments;
        if (formArgs is Map<String, dynamic>) {
          initialMode = formArgs['mode'] as CrmClientTypeFormMode? ??
              CrmClientTypeFormMode.add;
          clientType = formArgs['clientType'] as CrmClientTypeModel?;
          typeName = formArgs['typeName'] as String?;
          typeNameAr = formArgs['typeNameAr'] as String?;
          svgAsset = formArgs['svgAsset'] as String?;
        }
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmClientTypeFormPage(
            initialMode: initialMode,
            clientType: clientType,
            typeName: typeName,
            typeNameAr: typeNameAr,
            svgAsset: svgAsset,
          ),
        );

      case CrmRoutes.controlTemplates:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmTemplatesPage(),
        );

      case CrmRoutes.controlTemplateBuilder:
        final Map<String, dynamic> builderArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmTemplateBuilderPage(
            templateId: builderArgs['templateId'] as String? ?? '',
            templateName: builderArgs['templateName'] as String? ?? 'Temp Name',
            clientTypeId: builderArgs['clientTypeId'] as String? ?? '',
            clientType: builderArgs['clientType'] as String? ?? 'Individuals',
          ),
        );

      case CrmRoutes.controlTemplateElementForm:
        final Map<String, dynamic> formArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmTemplateElementFormPage(
            templateId: formArgs['templateId'] as String? ?? '',
            templateName: formArgs['templateName'] as String? ?? 'Temp Name',
            clientTypeId: formArgs['clientTypeId'] as String? ?? '',
            clientType: formArgs['clientType'] as String? ?? 'Individuals',
            sectionId: formArgs['sectionId'] as String? ?? '',
            fieldId: formArgs['fieldId'] as String? ?? '',
            isSection: formArgs['isSection'] as bool? ?? false,
            isEditing: formArgs['isEditing'] as bool? ?? false,
          ),
        );

      case CrmRoutes.controlTemplateLayout:
        final Map<String, dynamic> layoutArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmTemplateLayoutPage(
            templateId: layoutArgs['templateId'] as String? ?? '',
            templateName: layoutArgs['templateName'] as String? ?? 'Temp Name',
            clientTypeId: layoutArgs['clientTypeId'] as String? ?? '',
            clientType: layoutArgs['clientType'] as String? ?? 'Individuals',
          ),
        );

      case CrmRoutes.controlTemplatePreview:
        final Map<String, dynamic> previewArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmTemplatePreviewPage(
            templateName: previewArgs['templateName'] as String? ?? 'Temp Name',
            clientType: previewArgs['clientType'] as String? ?? 'Individuals',
            layoutPages: previewArgs['layoutPages'],
            templateSections: previewArgs['templateSections']
                    as List<CrmTemplateSectionModel>? ??
                <CrmTemplateSectionModel>[],
            templateFields:
                previewArgs['templateFields'] as List<CrmTemplateFieldModel>? ??
                    <CrmTemplateFieldModel>[],
          ),
        );

      case CrmRoutes.controlRelationships:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmRelationshipListPage(),
        );

      case CrmRoutes.controlRelationshipAddCategory:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmRelationshipAddCategoryPage(),
        );

      case CrmRoutes.controlTerms:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmTermsListPage(),
        );

      case CrmRoutes.controlTermForm:
        final Map<String, dynamic> formArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmTermFormPage(
            term: formArgs['term'] as CrmTermModel?,
            mode: formArgs['mode'] as String? ?? 'add',
          ),
        );

      case CrmRoutes.controlActivity:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmActivityMainPage(),
        );

      case CrmRoutes.controlCategoryForm:
        final Map<String, dynamic> catFormArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmCategoryFormPage(
            category: catFormArgs['category'] as CrmCategoryModel?,
            mode: catFormArgs['mode'] as String? ?? 'add',
          ),
        );

      case CrmRoutes.controlDeals:
      case CrmRoutes.deals:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmDealsMainPage(),
        );

      case CrmRoutes.dealDetails:
        final Map<String, dynamic> dealArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmDealDetailsPage(
            deal: dealArgs['deal'] as CrmClientDealModel,
          ),
        );

      case CrmRoutes.addDeal:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmAddDealPage(),
        );

      case CrmRoutes.addQuote:
        final Map<String, dynamic> quoteArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmAddQuotePage(
            deal: quoteArgs['deal'] as CrmClientDealModel?,
          ),
        );

      case CrmRoutes.compareQuotes:
        final Map<String, dynamic> compArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmCompareQuotesPage(
            deal: compArgs['deal'] as CrmClientDealModel,
            quotes: compArgs['quotes'] as List<CrmQuoteModel>,
          ),
        );

      case CrmRoutes.quoteDetails:
        final Map<String, dynamic> quoteDetailsArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmQuoteDetailsPage(
            deal: quoteDetailsArgs['deal'] as CrmClientDealModel? ??
                CrmClientDealModel.getEmptyModel(),
            quote: quoteDetailsArgs['quote'] as CrmQuoteModel? ??
                CrmQuoteModel.getEmptyModel(),
          ),
        );

      case CrmRoutes.createContract:
        final Map<String, dynamic> contractArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmCreateContractPage(
            deal: contractArgs['deal'] as CrmClientDealModel? ??
                CrmClientDealModel.getEmptyModel(),
            quote: contractArgs['quote'] as CrmQuoteModel? ??
                CrmQuoteModel.getEmptyModel(),
          ),
        );

      case CrmRoutes.requests:
        final Map<String, dynamic> reqArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmRequestsPage(
            dealTitle: reqArgs['dealTitle'] as String? ?? 'ERP System Deal',
          ),
        );

      case CrmRoutes.requestDetails:
        final Map<String, dynamic> reqDetailsArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmRequestDetailsPage(
            dealTitle:
                reqDetailsArgs['dealTitle'] as String? ?? 'ERP System Deal',
            request: reqDetailsArgs['request'] as CrmDealRequestModel? ??
                const CrmDealRequestModel(id: '1', no: 1, quoteNo: '15256'),
          ),
        );

      case CrmRoutes.dealAddActivity:
        final Map<String, dynamic> addActArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmDealAddActivityPage(
            dealTitle:
                addActArgs['dealTitle'] as String? ?? 'ERP System Deal',
            mode: addActArgs['mode'] as String? ?? 'add',
            activity: addActArgs['activity'] as CrmDealActivityModel?,
            onActivityAdded:
                addActArgs['onActivityAdded'] as ValueChanged<CrmDealActivityModel>?,
            onActivityUpdated:
                addActArgs['onActivityUpdated'] as ValueChanged<CrmDealActivityModel>?,
            onActivityDeleted:
                addActArgs['onActivityDeleted'] as ValueChanged<String>?,
          ),
        );

      case CrmRoutes.products:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => const CrmProductsPage());

      case CrmRoutes.productCategoryForm:
        final args = (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmProductCategoryFormPage(
            category: args['category'] as CrmProductCategoryModel?,
            mode: args['mode'] as String? ?? 'add',
            clientTypes: args['clientTypes'] as List<CrmClientTypeModel>? ??
                const <CrmClientTypeModel>[],
            tags: args['tags'] as List<CrmTagModel>? ?? const <CrmTagModel>[],
            existingCategories:
                args['existingCategories'] as List<CrmProductCategoryModel>? ??
                    const <CrmProductCategoryModel>[],
          ),
        );

      case CrmRoutes.productItemForm:
        final itemArgs = (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmProductItemFormPage(
            product: itemArgs['product'] as CrmProductItemModel?,
            mode: itemArgs['mode'] as String? ?? 'add',
            categories:
                itemArgs['categories'] as List<CrmProductCategoryModel>? ??
                    const <CrmProductCategoryModel>[],
            existingProducts:
                itemArgs['existingProducts'] as List<CrmProductItemModel>? ??
                    const <CrmProductItemModel>[],
            discounts: itemArgs['discounts'] as List<CrmDiscountModel>? ??
                const <CrmDiscountModel>[],
          ),
        );

      case CrmRoutes.services:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => const CrmServicesPage());

      case CrmRoutes.serviceCategoryForm:
        final args = (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmServiceCategoryFormPage(
            category: args['category'] as CrmServiceCategoryModel?,
            mode: args['mode'] as String? ?? 'add',
            clientTypes: args['clientTypes'] as List<CrmClientTypeModel>? ??
                const <CrmClientTypeModel>[],
            tags: args['tags'] as List<CrmTagModel>? ?? const <CrmTagModel>[],
            existingCategories:
                args['existingCategories'] as List<CrmServiceCategoryModel>? ??
                    const <CrmServiceCategoryModel>[],
          ),
        );

      case CrmRoutes.serviceItemForm:
        final serviceItemArgs = (settings.arguments as Map<String, dynamic>?) ??
            <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmServiceItemFormPage(
            service: serviceItemArgs['service'] as CrmServiceItemModel?,
            mode: serviceItemArgs['mode'] as String? ?? 'add',
            categories: serviceItemArgs['categories']
                    as List<CrmServiceCategoryModel>? ??
                const <CrmServiceCategoryModel>[],
            existingServices: serviceItemArgs['existingServices']
                    as List<CrmServiceItemModel>? ??
                const <CrmServiceItemModel>[],
            discounts:
                serviceItemArgs['discounts'] as List<CrmDiscountModel>? ??
                    const <CrmDiscountModel>[],
          ),
        );

      case CrmRoutes.controlDiscounts:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => const CrmDiscountsPage(),
        );

      case CrmRoutes.controlDiscountForm:
        final discountFormArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmDiscountFormPage(
            discount: discountFormArgs['discount'] as CrmDiscountModel?,
            mode: discountFormArgs['mode'] as String? ?? 'add',
            existingDiscounts: discountFormArgs['existingDiscounts']
                    as List<CrmDiscountModel>? ??
                const <CrmDiscountModel>[],
            categories: discountFormArgs['categories']
                    as List<CrmProductCategoryModel>? ??
                const <CrmProductCategoryModel>[],
            products:
                discountFormArgs['products'] as List<CrmProductItemModel>? ??
                    const <CrmProductItemModel>[],
            clientTypes:
                discountFormArgs['clientTypes'] as List<CrmClientTypeModel>? ??
                    const <CrmClientTypeModel>[],
            tags: discountFormArgs['tags'] as List<CrmTagModel>? ??
                const <CrmTagModel>[],
          ),
        );

      case CrmRoutes.controlDiscountDetails:
        final discountDetailsArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => CrmDiscountDetailsPage(
            discount: discountDetailsArgs['discount'] as CrmDiscountModel? ??
                CrmDiscountModel.getEmptyModel(),
            existingDiscounts: discountDetailsArgs['existingDiscounts']
                    as List<CrmDiscountModel>? ??
                const <CrmDiscountModel>[],
            categories: discountDetailsArgs['categories']
                    as List<CrmProductCategoryModel>? ??
                const <CrmProductCategoryModel>[],
            products:
                discountDetailsArgs['products'] as List<CrmProductItemModel>? ??
                    const <CrmProductItemModel>[],
            clientTypes: discountDetailsArgs['clientTypes']
                    as List<CrmClientTypeModel>? ??
                const <CrmClientTypeModel>[],
            tags: discountDetailsArgs['tags'] as List<CrmTagModel>? ??
                const <CrmTagModel>[],
          ),
        );

      case CrmRoutes.controlMerge:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmMergeLevelsCubit>(
            create: (_) => CrmMergeLevelsCubit(),
            child: const CrmMergeLevelsPage(),
          ),
        );

      case CrmRoutes.controlMergeForm:
        final Map<String, dynamic> mergeFormArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmMergeLevelsCubit>(
            create: (_) => CrmMergeLevelsCubit(),
            child: CrmMergeLevelFormPage(
              initialMode: mergeFormArgs['mode'] as CrmMergeLevelFormMode? ??
                  CrmMergeLevelFormMode.add,
              level: mergeFormArgs['level'] as CrmMergeLevelModel?,
            ),
          ),
        );

      case CrmRoutes.teams:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmTeamsCubit>(
            create: (_) => CrmTeamsCubit()..init(),
            child: const CrmTeamsPage(),
          ),
        );

      case CrmRoutes.teamForm:
        final Map<String, dynamic> teamFormArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmTeamsCubit>(
            create: (_) => CrmTeamsCubit()..init(),
            child: CrmTeamFormPage(
              team: teamFormArgs['team'] as CrmTeamModel?,
              mode: teamFormArgs['mode'] as String? ?? 'add',
              existingTeams:
                  teamFormArgs['existingTeams'] as List<CrmTeamModel>? ??
                      const <CrmTeamModel>[],
            ),
          ),
        );

      case CrmRoutes.teamDetails:
        final Map<String, dynamic> teamDetailsArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmTeamsCubit>(
            create: (_) => CrmTeamsCubit()..init(),
            child: CrmTeamDetailsPage(
              team: teamDetailsArgs['team'] as CrmTeamModel,
            ),
          ),
        );

      case CrmRoutes.duplicates:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmDuplicatesCubit>(
            create: (_) => CrmDuplicatesCubit(
              repository: Get.find<ICrmDuplicatesRepository>(),
            ),
            child: const CrmDuplicatesPage(),
          ),
        );

      case CrmRoutes.mergeWizard:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmDuplicatesCubit>(
            create: (_) => CrmDuplicatesCubit(
              repository: Get.find<ICrmDuplicatesRepository>(),
            ),
            child: const CrmMergeWizardPage(),
          ),
        );

      case CrmRoutes.mergeHistory:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmDuplicatesCubit>(
            create: (_) => CrmDuplicatesCubit(
              repository: Get.find<ICrmDuplicatesRepository>(),
            ),
            child: const CrmMergeHistoryPage(),
          ),
        );

      case CrmRoutes.mergeHistoryDetails:
        final Map<String, dynamic> historyArgs =
            (settings.arguments as Map<String, dynamic>?) ??
                <String, dynamic>{};
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmDuplicatesCubit>(
            create: (_) => CrmDuplicatesCubit(
              repository: Get.find<ICrmDuplicatesRepository>(),
            ),
            child: CrmMergeHistoryDetailsPage(
              history: historyArgs['history'] as CrmMergeHistoryModel,
            ),
          ),
        );

      default:
        return MaterialPageRoute<dynamic>(
          settings: settings,
          builder: (_) => BlocProvider<CrmClientsListCubit>(
            create: (_) => CrmClientsListCubit()..init(),
            child: const CrmClientsDashboardPage(),
          ),
        );
    }
  }
}
