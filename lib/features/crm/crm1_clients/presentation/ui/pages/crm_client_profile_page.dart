// ****************** FILE INFO ******************
// File Name: crm_client_profile_page.dart
// Purpose: Full CRM Client Profile page with Champion Header Card, 8-tab switcher,
//          Dashboard read-only fields renderer, and dynamic Overview tab with charts.
// Author: Mohand Adel
// Created At: 26/08/2026

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/crm_helper/crm_navigation_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_cubit.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_state.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_champion_card.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_blacklist_banner.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_activities_tab.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_dashboard_tab.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_documents_tab.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_overview_tab.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_relationships_tab.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_relationship_map_tab.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/ui/widgets/crm_client_timeline_tab.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/presentation/ui/widgets/crm_client_deals_tab.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/base_repository/crm_controls_base_repository.dart';
import 'package:knowticed_plus/generated/l10n.dart';

enum _CrmProfileTabKey {
  dashboard,
  overview,
  timeline,
  contacts,
  deals,
  documents,
  activities,
  relationships,
  relationshipMap,
}

class CrmClientProfilePage extends StatefulWidget {
  final String recordId;
  final String templateName;
  final String clientType;
  final String? clientTypeId;
  final String? templateId;

  const CrmClientProfilePage({
    super.key,
    required this.recordId,
    this.templateName = 'Client Profile',
    this.clientType = 'Person',
    this.clientTypeId,
    this.templateId,
  });

  @override
  State<CrmClientProfilePage> createState() => _CrmClientProfilePageState();
}

class _CrmClientProfilePageState extends State<CrmClientProfilePage> {
  late final CrmControlsBaseRepository _controlsRepository =
      Get.find<CrmControlsBaseRepository>();
  StreamSubscription? _fieldsSubscription;
  StreamSubscription? _sectionsSubscription;
  List<CrmTemplateFieldModel> _fields = [];
  List<CrmTemplateSectionModel> _sections = [];
  String? _watchedTemplateId;
  int _selectedTabIndex = 0; // 0: Dashboard, 1: Overview

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null && widget.templateId!.isNotEmpty) {
      _ensureWatchingTemplate(widget.templateId!);
    }
  }

  void _ensureWatchingTemplate(String templateId) {
    if (templateId.isEmpty || templateId == _watchedTemplateId) return;
    _watchedTemplateId = templateId;
    _fieldsSubscription?.cancel();
    _sectionsSubscription?.cancel();

    _fieldsSubscription = _controlsRepository
        .watchTemplateFields(templateId: templateId)
        .listen((result) {
      if (mounted) {
        setState(() {
          _fields = result.fold(
            (_) => [],
            (fields) => fields.where((f) => !f.isDeleted).toList(),
          );
        });
      }
    });

    _sectionsSubscription = _controlsRepository
        .watchTemplateSections(templateId: templateId)
        .listen((result) {
      if (mounted) {
        setState(() {
          _sections = result.fold(
            (_) => [],
            (sections) => sections,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _fieldsSubscription?.cancel();
    _sectionsSubscription?.cancel();
    super.dispose();
  }

  bool _isGovernmentOrCompany(
    CrmClientTypeModel? type,
    CrmClientRecordModel? record,
  ) {
    final String typeKey = (type?.systemKey ?? '').toLowerCase();
    final String typeName = (type?.nameEn ?? '').toLowerCase();
    final String typeNameAr = (type?.nameAr ?? '').toLowerCase();
    final String widgetType = widget.clientType.toLowerCase();

    return typeKey == 'government' ||
        typeKey == 'company' ||
        typeName == 'government' ||
        typeName == 'company' ||
        typeName.contains('govern') ||
        typeName.contains('company') ||
        typeNameAr.contains('حكوم') ||
        typeNameAr.contains('شرك') ||
        widgetType.contains('govern') ||
        widgetType.contains('company');
  }

  List<_CrmProfileTabKey> _getAvailableTabs(
    CrmClientTypeModel? type,
    CrmClientRecordModel? record,
  ) {
    final bool showContacts = _isGovernmentOrCompany(type, record);
    return [
      _CrmProfileTabKey.dashboard,
      _CrmProfileTabKey.overview,
      _CrmProfileTabKey.timeline,
      if (showContacts) _CrmProfileTabKey.contacts,
      _CrmProfileTabKey.deals,
      _CrmProfileTabKey.documents,
      _CrmProfileTabKey.activities,
      _CrmProfileTabKey.relationships,
      _CrmProfileTabKey.relationshipMap,
    ];
  }

  String _getTabTitle(_CrmProfileTabKey tab) {
    switch (tab) {
      case _CrmProfileTabKey.dashboard:
        return FormatHelper.localizedString(
          englishName: 'Dashboard',
          arabicName: 'لوحة المعلومات',
        );
      case _CrmProfileTabKey.overview:
        return FormatHelper.localizedString(
          englishName: 'Overview',
          arabicName: 'نظرة عامة',
        );
      case _CrmProfileTabKey.timeline:
        return FormatHelper.localizedString(
          englishName: 'Timeline',
          arabicName: 'الجدول الزمني',
        );
      case _CrmProfileTabKey.contacts:
        return FormatHelper.localizedString(
          englishName: 'Contacts',
          arabicName: 'جهات الاتصال',
        );
      case _CrmProfileTabKey.deals:
        return FormatHelper.localizedString(
          englishName: 'Deals',
          arabicName: 'الصفقات',
        );
      case _CrmProfileTabKey.documents:
        return FormatHelper.localizedString(
          englishName: 'Documents',
          arabicName: 'المستندات',
        );
      case _CrmProfileTabKey.activities:
        return FormatHelper.localizedString(
          englishName: 'Activities',
          arabicName: 'الأنشطة',
        );
      case _CrmProfileTabKey.relationships:
        return FormatHelper.localizedString(
          englishName: 'Relationships',
          arabicName: 'العلاقات',
        );
      case _CrmProfileTabKey.relationshipMap:
        return FormatHelper.localizedString(
          englishName: 'Relationship Map',
          arabicName: 'خريطة العلاقات',
        );
    }
  }

  CrmClientTypeModel? _resolveClientType(CrmClientsListState state) {
    if (widget.clientTypeId != null && widget.clientTypeId!.isNotEmpty) {
      for (final CrmClientTypeModel type in state.clientTypes) {
        if (type.id == widget.clientTypeId) return type;
      }
    }
    final String normalizedName = widget.clientType.trim().toLowerCase();
    for (final CrmClientTypeModel type in state.clientTypes) {
      if ((type.systemKey ?? '').toLowerCase() == normalizedName ||
          type.nameEn.toLowerCase() == normalizedName) {
        return type;
      }
    }
    return state.clientTypes.isEmpty ? null : state.clientTypes.first;
  }

  CrmTemplateModel? _resolveTemplate(
      CrmClientsListState state, CrmClientRecordModel? record) {
    final String templateId = record?.templateId.isNotEmpty == true
        ? record!.templateId
        : (widget.templateId ?? '');
    if (templateId.isNotEmpty) {
      for (final CrmTemplateModel template in state.templates) {
        if (template.id == templateId) return template;
      }
    }
    final CrmClientTypeModel? type = _resolveClientType(state);
    if (type != null) {
      return context.read<CrmClientsListCubit>().activeTemplateFor(type.id);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String pageThirdTitle = FormatHelper.localizedString(
      englishName: 'Client Profile',
      arabicName: 'ملف العميل',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: S.current.crm,
        secondTitle: S.current.crmClients,
        thirdTitle: pageThirdTitle,
        onFirstTap: () => CrmNavigationHelper.popToDashboard(context),
        onSecondTap: () => CrmNavigationHelper.pop(context),
        child: BlocListener<CrmClientsListCubit, CrmClientsListState>(
          listener: (BuildContext context, CrmClientsListState state) {
            final String? message = state.errorMessage;
            if (message != null && message.isNotEmpty) {
              CrmControlDialogs.showErrorDialog(
                context: context,
                title: S.current.errorOccurred,
                subtitle: message,
              );
              context.read<CrmClientsListCubit>().clearMessages();
            }
          },
          child: BlocBuilder<CrmClientsListCubit, CrmClientsListState>(
            builder: (BuildContext context, CrmClientsListState state) {
              if (state.isLoading && state.records.isEmpty) {
                return const CircleProgressMaster();
              }

              CrmClientRecordModel? record;
              for (final CrmClientRecordModel item in state.records) {
                if (item.id == widget.recordId) {
                  record = item;
                  break;
                }
              }

              if (record == null) {
                return Center(
                  child: Text(
                    S.current.noData,
                    style: StyleText.fontSize16Weight600.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                );
              }

              final CrmClientRecordModel activeRecord = record;
              final CrmClientTypeModel? type = _resolveClientType(state);
              final CrmTemplateModel? template =
                  _resolveTemplate(state, activeRecord);
              if (template != null) {
                _ensureWatchingTemplate(template.id);
              }

              final List<_CrmProfileTabKey> availableTabs =
                  _getAvailableTabs(type, activeRecord);

              final int safeTabIndex = _selectedTabIndex < availableTabs.length
                  ? _selectedTabIndex
                  : 0;
              final _CrmProfileTabKey currentActiveTab =
                  availableTabs[safeTabIndex];

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Champion Large Card with Profile Info & Quick Actions
                    CrmClientChampionCard(
                      record: activeRecord,
                      clientType: type,
                      fallbackTitle: widget.templateName,
                      onCall: () => CrmControlDialogs.showSuccessDialog(
                        context: context,
                        title: FormatHelper.localizedString(
                          englishName: 'Call Client',
                          arabicName: 'الاتصال بالعميل',
                        ),
                        subtitle: activeRecord.secondaryDisplayValue ?? '',
                      ),
                      onEmail: () => CrmControlDialogs.showSuccessDialog(
                        context: context,
                        title: FormatHelper.localizedString(
                          englishName: 'Send Email',
                          arabicName: 'إرسال بريد إلكتروني',
                        ),
                        subtitle: activeRecord.secondaryDisplayValue ?? '',
                      ),
                      onMessage: () => CrmControlDialogs.showSuccessDialog(
                        context: context,
                        title: FormatHelper.localizedString(
                          englishName: 'Send Message',
                          arabicName: 'إرسال رسالة',
                        ),
                        subtitle: activeRecord.primaryDisplayValue ?? '',
                      ),
                      onStatusChanged: (String newStatus) async {
                        final bool success = await context
                            .read<CrmClientsListCubit>()
                            .updateClientStatus(
                              recordId: activeRecord.id,
                              status: newStatus,
                            );
                        if (context.mounted && success) {
                          CrmControlDialogs.showSuccessDialog(
                            context: context,
                            title: S.current.crmStatus,
                            subtitle: FormatHelper.localizedString(
                              englishName:
                                  'Client status updated to ${newStatus == 'active' ? 'Active' : 'Inactive'}',
                              arabicName: newStatus == 'active'
                                  ? 'تم تفعيل العميل بنجاح'
                                  : 'تم تغيير حالة العميل إلى غير نشط',
                            ),
                          );
                        }
                      },
                      onBlacklist: () => _handleBlacklist(activeRecord),
                      onRemove: () {
                        CrmControlDialogs.showRemoveDialog(
                          context: context,
                          title: FormatHelper.localizedString(
                            englishName: 'Remove Client',
                            arabicName: 'حذف العميل',
                          ),
                          subtitle: FormatHelper.localizedString(
                            englishName:
                                'Are you sure you want to remove this client record?',
                            arabicName:
                                'هل أنت متأكد من رغبتك في حذف هذا العميل؟',
                          ),
                          onConfirm: () async {
                            final bool success = await context
                                .read<CrmClientsListCubit>()
                                .softDeleteClientRecord(activeRecord.id);
                            if (context.mounted && success) {
                              CrmNavigationHelper.pop(context);
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16.sp),
                    if (activeRecord.isBlacklisted) ...<Widget>[
                      CrmClientBlacklistBanner(record: activeRecord),
                      SizedBox(height: 16.sp),
                    ],

                    // 2. Profile Tabs Header
                    CustomTabs(
                      tabs: availableTabs.map(_getTabTitle).toList(),
                      selectedValue: safeTabIndex,
                      spacing: 24.sp,
                      textStyle: StyleText.fontSize16Weight600,
                      onChanged: (int index) {
                        setState(() => _selectedTabIndex = index);
                      },
                    ),
                    SizedBox(height: 16.sp),

                    // 3. Tab Content View
                    _buildActiveTabContent(
                      currentActiveTab,
                      activeRecord,
                      template,
                      type,
                    ),
                    SizedBox(height: 32.sp),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleBlacklist(CrmClientRecordModel record) async {
    final bool isRemovalRequest = record.isBlacklisted;
    final bool confirmed =
        await CrmControlDialogs.showBlacklistConfirmationDialog(
      context: context,
      isRemoval: isRemovalRequest,
    );
    if (!confirmed || !mounted) return;

    final String? reason = await CrmControlDialogs.showBlacklistReasonDialog(
      context: context,
      isRemoval: isRemovalRequest,
    );
    if (reason == null || !mounted) return;

    final bool success =
        await context.read<CrmClientsListCubit>().updateClientBlacklist(
              recordId: record.id,
              reason: reason,
              isRemovalRequest: isRemovalRequest,
            );
    if (!mounted || !success) return;
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: isRemovalRequest
          ? 'Client Removed from Blacklist'
          : 'Blacklist Request Sent',
      subtitle: isRemovalRequest
          ? 'This client is active again and no longer restricted.'
          : 'This client is now blacklisted.',
    );
  }

  Widget _buildActiveTabContent(
    _CrmProfileTabKey currentTab,
    CrmClientRecordModel record,
    CrmTemplateModel? template,
    CrmClientTypeModel? type,
  ) {
    switch (currentTab) {
      case _CrmProfileTabKey.dashboard:
        return CrmClientDashboardTab(
          record: record,
          template: template,
          clientType: type,
          fields: _fields,
        );

      case _CrmProfileTabKey.overview:
        return CrmClientOverviewTab(
          record: record,
          template: template,
          clientType: type,
          fields: _fields,
          sections: _sections,
        );

      case _CrmProfileTabKey.timeline:
        return CrmClientTimelineTab(
          record: record,
          template: template,
          clientType: type,
        );

      case _CrmProfileTabKey.contacts:
        return _buildComingSoonPlaceholder();

      case _CrmProfileTabKey.activities:
        return CrmClientActivitiesTab(clientId: record.id);

      case _CrmProfileTabKey.relationships:
        return CrmClientRelationshipsTab(
          record: record,
        );

      case _CrmProfileTabKey.relationshipMap:
        return CrmClientRelationshipMapTab(
          record: record,
        );

      case _CrmProfileTabKey.documents:
        return CrmClientDocumentsTab(clientId: record.id);

      case _CrmProfileTabKey.deals:
        return CrmClientDealsTab(clientId: record.id);
    }
  }

  Widget _buildComingSoonPlaceholder() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.sp, horizontal: 16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10.sp),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath: AppAssets.crmTemplateEmpty,
            width: 120.sp,
            height: 120.sp,
          ),
          SizedBox(height: 16.sp),
          Text(
            FormatHelper.localizedString(
              englishName: 'Coming Soon',
              arabicName: 'قريباً',
            ),
            style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
