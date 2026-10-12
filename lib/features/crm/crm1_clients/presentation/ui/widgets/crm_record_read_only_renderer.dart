// ****************** FILE INFO ******************
// File Name: crm_record_read_only_renderer.dart
// Purpose: Read-only renderer for CRM client record values based on template
// Author: Mohand Adel
// Created At: 08/08/2026

import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/presentation/controller/crm_clients_list_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_section_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';

class CrmRecordReadOnlyRenderer extends StatefulWidget {
  final CrmTemplateModel template;
  final CrmClientRecordModel record;

  const CrmRecordReadOnlyRenderer({
    super.key,
    required this.template,
    required this.record,
  });

  @override
  State<CrmRecordReadOnlyRenderer> createState() =>
      _CrmRecordReadOnlyRendererState();
}

class _CrmRecordReadOnlyRendererState extends State<CrmRecordReadOnlyRenderer> {
  List<CrmTemplateSectionModel> _sections = const <CrmTemplateSectionModel>[];
  List<CrmTemplateFieldModel> _fields = const <CrmTemplateFieldModel>[];
  bool _isLoaded = false;
  StreamSubscription<Either<Failure, List<CrmTemplateSectionModel>>>?
      _sectionsSubscription;
  StreamSubscription<Either<Failure, List<CrmTemplateFieldModel>>>?
      _fieldsSubscription;

  @override
  void initState() {
    super.initState();
    final CrmClientsListCubit cubit = context.read<CrmClientsListCubit>();
    _sectionsSubscription = cubit.controlsRepository
        .watchTemplateSections(templateId: widget.template.id)
        .listen((result) {
      result.fold(
        (Failure failure) => _handleFailure(failure),
        (List<CrmTemplateSectionModel> sections) {
          if (!mounted) return;
          setState(() {
            _sections = sections;
            _isLoaded = true;
          });
        },
      );
    });
    _fieldsSubscription = cubit.controlsRepository
        .watchTemplateFields(templateId: widget.template.id)
        .listen((result) {
      result.fold(
        (Failure failure) => _handleFailure(failure),
        (List<CrmTemplateFieldModel> fields) {
          if (!mounted) return;
          setState(() {
            _fields = fields;
            _isLoaded = true;
          });
        },
      );
    });
  }

  void _handleFailure(Failure failure) {
    debugPrint('CrmRecordReadOnlyRenderer error: ${failure.errMessage}');
  }

  @override
  void dispose() {
    _sectionsSubscription?.cancel();
    _fieldsSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: const CircleProgressMaster(),
      );
    }

    final List<CrmTemplateSectionModel> orderedSections =
        List<CrmTemplateSectionModel>.from(_sections)
          ..sort((a, b) => a.order.compareTo(b.order));

    if (orderedSections.isEmpty) {
      return _buildSectionCard(context, null, _fields);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: orderedSections
          .map(
            (CrmTemplateSectionModel section) => _buildSectionCard(
              context,
              section,
              _fields.where((field) => field.sectionId == section.id).toList(),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    CrmTemplateSectionModel? section,
    List<CrmTemplateFieldModel> sectionFields,
  ) {
    final List<CrmTemplateFieldModel> ordered =
        List<CrmTemplateFieldModel>.from(sectionFields)
          ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section != null && section.nameEn.isNotEmpty) ...[
          Text(
            FormatHelper.localizedString(
              englishName: section.nameEn,
              arabicName: section.nameAr,
            ),
            style: StyleText.fontSize16Weight600.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ordered.isEmpty
                ? <Widget>[
                    Text(
                      S.current.noData,
                      style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey),
                    ),
                  ]
                : ordered
                    .map(
                      (CrmTemplateFieldModel field) => CrmReadOnlyValueTile(
                        label: FormatHelper.localizedString(
                          englishName: field.nameEn,
                          arabicName: field.nameAr,
                        ),
                        value:
                            widget.record.valueFor(field.id, field.systemKey),
                      ),
                    )
                    .toList(),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

class CrmReadOnlyValueTile extends StatelessWidget {
  final String label;
  final dynamic value;

  const CrmReadOnlyValueTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 2.h),
          Text(_displayValue, style: StyleText.fontSize14Weight600),
          Divider(height: 12.h, color: AppColors.background),
        ],
      ),
    );
  }

  String get _displayValue {
    if (value == null) return '-';
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .join(_locale == 'ar' ? '، ' : ', ');
    }
    if (value is Map) {
      final List<String> entries =
          value.entries.map((entry) => '${entry.key}: ${entry.value}').toList();
      return entries.join(_locale == 'ar' ? '، ' : ', ');
    }
    if (value is DateTime) {
      return FormatHelper.formatDate(value, _locale);
    }
    return value.toString();
  }

  String get _locale => Get.locale.toString().contains('ar') ? 'ar' : 'en';
}
