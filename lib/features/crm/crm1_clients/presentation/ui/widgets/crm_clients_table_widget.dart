// ****************** FILE INFO ******************
// File Name: crm_clients_table_widget.dart
// Purpose: Responsive client records table widget matching design system and table_widget.dart
// Author: Mohand Adel
// Created At: 08/08/2026

import 'dart:ui' as ui;

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CrmClientsTableWidget extends StatelessWidget {
  const CrmClientsTableWidget({
    required this.records,
    required this.onRecordTap,
    this.template,
    this.fields = const [],
    super.key,
  });

  final List<CrmClientRecordModel> records;
  final CrmTemplateModel? template;
  final List<CrmTemplateFieldModel> fields;
  final void Function(CrmClientRecordModel record) onRecordTap;

  bool get _isArabic => Get.locale.toString().contains('ar');

  TextStyle get _headerStyle => StyleText.fontSize14Weight600.copyWith(
        color: AppColors.white,
        fontSize: 13.sp,
      );

  TextStyle _cellStyle(BuildContext context) =>
      StyleText.fontSize14Weight400.copyWith(
        fontSize: 13.sp,
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.text
            : AppColors.white,
      );

  List<_ClientTableColumn> _buildColumns(BuildContext context) {
    final bool hasNameAr = records.any((r) => _hasNameAr(r));
    final bool hasNameEn = records.any((r) => _hasNameEn(r));
    final bool hasPhone = records.any((r) => _hasPhone(r));
    final bool hasPhoneCode = records.any((r) => _hasPhoneCode(r));
    final bool hasEmail = records.any((r) => _hasValue(r, 'email'));
    final bool hasNationalId = records
        .any((r) => _hasValue(r, 'national_id') || _hasValue(r, 'id_number'));
    final bool hasOwner = records.any(
        (r) => _hasValue(r, 'owner') || r.audit.createdBy.trim().isNotEmpty);
    final bool hasNextActivity =
        records.any((r) => _hasValue(r, 'next_activity'));
    final bool hasLanguage =
        records.any((r) => _hasValue(r, 'preferred_language'));
    final bool hasContactChannel =
        records.any((r) => _hasValue(r, 'preferred_contact_channel'));
    final bool hasCountry = records.any((r) => _hasValue(r, 'country'));
    final bool hasCity = records.any((r) => _hasValue(r, 'city'));
    final bool hasProvince = records
        .any((r) => _hasValue(r, 'state_province') || _hasValue(r, 'province'));
    final bool hasStreet = records.any((r) => _hasValue(r, 'street'));

    final List<_ClientTableColumn> cols = <_ClientTableColumn>[
      _ClientTableColumn(
        title: S.current.crmNo,
        width: FixedColumnWidth(50.sp),
        cellBuilder: (ctx, index, record) => _textCell(ctx, '${index + 1}'),
      ),
      _ClientTableColumn(
        title: S.current.crmPhoto,
        width: FixedColumnWidth(60.sp),
        cellBuilder: (ctx, index, record) => _avatarCell(ctx),
      ),
    ];

    if (_isArabic) {
      if (hasNameAr || !hasNameEn) {
        cols.add(_ClientTableColumn(
          title: 'اسم العميل',
          width: FixedColumnWidth(140.sp),
          cellBuilder: (ctx, index, record) => _textCell(
            ctx,
            _displayValue(record.valueFor(null, 'first_name_ar'),
                    languageCode: 'ar') ??
                _displayValue(record.valueFor(null, 'name_ar'),
                    languageCode: 'ar') ??
                _displayValue(record.valueFor(null, 'first_name'),
                    languageCode: 'ar') ??
                record.primaryDisplayValue ??
                '-',
          ),
        ));
      }
      if (hasNameEn) {
        cols.add(_ClientTableColumn(
          title: 'Client Name',
          width: FixedColumnWidth(140.sp),
          cellBuilder: (ctx, index, record) => _textCell(
            ctx,
            _displayValue(record.valueFor(null, 'first_name'),
                    languageCode: 'en') ??
                record.primaryDisplayValue ??
                '-',
          ),
        ));
      }
    } else {
      if (hasNameEn || !hasNameAr) {
        cols.add(_ClientTableColumn(
          title: 'Client Name',
          width: FixedColumnWidth(140.sp),
          cellBuilder: (ctx, index, record) => _textCell(
            ctx,
            _displayValue(record.valueFor(null, 'first_name'),
                    languageCode: 'en') ??
                record.primaryDisplayValue ??
                '-',
          ),
        ));
      }
      if (hasNameAr) {
        cols.add(_ClientTableColumn(
          title: 'اسم العميل',
          width: FixedColumnWidth(140.sp),
          cellBuilder: (ctx, index, record) => _textCell(
            ctx,
            _displayValue(record.valueFor(null, 'first_name_ar'),
                    languageCode: 'ar') ??
                _displayValue(record.valueFor(null, 'name_ar'),
                    languageCode: 'ar') ??
                _displayValue(record.valueFor(null, 'first_name'),
                    languageCode: 'ar') ??
                record.primaryDisplayValue ??
                '-',
          ),
        ));
      }
    }

    cols.add(_ClientTableColumn(
      title: S.current.crmStatus,
      width: FixedColumnWidth(90.sp),
      cellBuilder: (ctx, index, record) => _statusCell(ctx, record.status),
    ));

    if (hasPhoneCode) {
      cols.add(_ClientTableColumn(
        title: S.current.crmCode,
        width: FixedColumnWidth(60.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'phone_code')) ?? '+20',
        ),
      ));
    }

    if (hasPhone) {
      cols.add(_ClientTableColumn(
        title: S.current.crmPhone,
        width: FixedColumnWidth(140.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'phone_number')) ??
              _displayValue(record.valueFor(null, 'phone')) ??
              '-',
        ),
      ));
    }

    if (hasEmail) {
      cols.add(_ClientTableColumn(
        title: S.current.crmEmail,
        width: FixedColumnWidth(180.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'email')) ?? '-',
        ),
      ));
    }

    if (hasNationalId) {
      cols.add(_ClientTableColumn(
        title: S.current.crmNationalId,
        width: FixedColumnWidth(140.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'national_id')) ??
              _displayValue(record.valueFor(null, 'id_number')) ??
              '-',
        ),
      ));
    }

    if (hasOwner) {
      cols.add(_ClientTableColumn(
        title: S.current.crmOwner,
        width: FixedColumnWidth(120.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'owner')) ??
              record.audit.createdBy,
        ),
      ));
    }

    if (hasNextActivity) {
      cols.add(_ClientTableColumn(
        title: S.current.crmNextActivity,
        width: FixedColumnWidth(130.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'next_activity')) ?? '-',
        ),
      ));
    }

    cols.add(_ClientTableColumn(
      title: S.current.crmDate,
      width: FixedColumnWidth(100.sp),
      cellBuilder: (ctx, index, record) => _textCell(
        ctx,
        FormatHelper.formatDate(record.audit.createdAt, Get.locale.toString()),
      ),
    ));

    cols.add(_ClientTableColumn(
      title: S.current.crmTime,
      width: FixedColumnWidth(90.sp),
      cellBuilder: (ctx, index, record) => _textCell(
        ctx,
        DateFormat('hh:mm a', Get.locale.toString())
            .format(record.audit.createdAt),
      ),
    ));

    if (hasLanguage) {
      cols.add(_ClientTableColumn(
        title: S.current.crmPreferredLanguage,
        width: FixedColumnWidth(130.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'preferred_language')) ?? '-',
        ),
      ));
    }

    if (hasContactChannel) {
      cols.add(_ClientTableColumn(
        title: S.current.crmContactChannel,
        width: FixedColumnWidth(180.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'preferred_contact_channel')) ??
              '-',
        ),
      ));
    }

    if (hasCountry) {
      cols.add(_ClientTableColumn(
        title: S.current.crmCountry,
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'country')) ?? '-',
        ),
      ));
    }

    if (hasCity) {
      cols.add(_ClientTableColumn(
        title: S.current.crmCity,
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'city')) ?? '-',
        ),
      ));
    }

    if (hasProvince) {
      cols.add(_ClientTableColumn(
        title: S.current.crmProvince,
        width: FixedColumnWidth(110.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'state_province')) ??
              _displayValue(record.valueFor(null, 'province')) ??
              '-',
        ),
      ));
    }

    if (hasStreet) {
      cols.add(_ClientTableColumn(
        title: S.current.crmStreet,
        width: FixedColumnWidth(120.sp),
        cellBuilder: (ctx, index, record) => _textCell(
          ctx,
          _displayValue(record.valueFor(null, 'street')) ?? '-',
        ),
      ));
    }

    return cols;
  }

  bool _hasValue(CrmClientRecordModel record, String systemKey) {
    final dynamic val = record.valueFor(null, systemKey);
    final String? text = _displayValue(val);
    return text != null && text.trim().isNotEmpty && text.trim() != '-';
  }

  bool _hasNameEn(CrmClientRecordModel record) {
    final String? text = _displayValue(record.valueFor(null, 'first_name'),
            languageCode: 'en') ??
        record.primaryDisplayValue;
    return text != null && text.trim().isNotEmpty && text.trim() != '-';
  }

  bool _hasNameAr(CrmClientRecordModel record) {
    final String? text = _displayValue(record.valueFor(null, 'first_name_ar'),
            languageCode: 'ar') ??
        _displayValue(record.valueFor(null, 'name_ar'), languageCode: 'ar') ??
        _displayValue(record.valueFor(null, 'first_name'), languageCode: 'ar');
    return text != null && text.trim().isNotEmpty && text.trim() != '-';
  }

  bool _hasPhone(CrmClientRecordModel record) {
    final String? text = _displayValue(record.valueFor(null, 'phone_number')) ??
        _displayValue(record.valueFor(null, 'phone'));
    return text != null && text.trim().isNotEmpty && text.trim() != '-';
  }

  bool _hasPhoneCode(CrmClientRecordModel record) {
    final String? text = _displayValue(record.valueFor(null, 'phone_code'));
    return text != null && text.trim().isNotEmpty && text.trim() != '-';
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final bool isRtl = _isArabic;

    final List<_ClientTableColumn> columns = _buildColumns(context);
    final Map<int, TableColumnWidth> columnWidths =
        Map<int, TableColumnWidth>.fromIterables(
      List<int>.generate(columns.length, (int i) => i),
      columns.map((_ClientTableColumn c) => c.width),
    );

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.sp),
          child: Table(
            border: TableBorder.all(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: [
              // Header Row
              TableRow(
                decoration: BoxDecoration(
                  color: isLight ? AppColors.black : AppColors.dividerGrey,
                ),
                children: columns
                    .map(
                      (_ClientTableColumn col) => Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Text(
                          col.title,
                          style: _headerStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    )
                    .toList(),
              ),
              // Data Rows
              ...List.generate(records.length, (int index) {
                final CrmClientRecordModel record = records[index];
                final bool isEven = index.isEven;
                final Color rowColor = isLight
                    ? (isEven ? AppColors.oddRowColor : AppColors.white)
                    : (isEven ? AppColors.darkDashboardTable : AppColors.black);

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: columns
                      .map(
                        (_ClientTableColumn col) => InkWell(
                          onTap: () => onRecordTap(record),
                          child: col.cellBuilder(context, index, record),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  String? _displayValue(dynamic value, {String? languageCode}) {
    if (value == null) return null;
    if (value is Map) {
      final String preferred = (value[languageCode] ??
              value[languageCode?.toUpperCase()] ??
              value['en'] ??
              value['EN'] ??
              value['ar'] ??
              value['AR'] ??
              '')
          .toString()
          .trim();
      return preferred.isEmpty ? null : preferred;
    }
    if (value is List) return null;
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  Widget _textCell(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Text(
        text.isEmpty ? '-' : text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _cellStyle(context),
      ),
    );
  }

  Widget _avatarCell(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 6.sp),
      child: Container(
        width: 28.sp,
        height: 28.sp,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: CustomSvgImage(
          assetPath: AppAssets.crmPerson,
          width: 16.sp,
          height: 16.sp,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _statusCell(BuildContext context, String status) {
    final String lower = status.toLowerCase();
    Color color = AppColors.lightGreen;
    String label = S.current.crmActive;

    if (lower == 'inactive') {
      color = AppColors.red;
      label = S.current.crmInactive;
    } else if (lower == 'prospect') {
      color = AppColors.blue;
      label = S.current.crmProspect;
    } else if (lower == 'archived') {
      color = AppColors.grey;
      label = S.current.crmArchived;
    }

    return Padding(
      padding: EdgeInsets.all(10.sp),
      child: Text(
        label,
        style: _cellStyle(context).copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ClientTableColumn {
  final String title;
  final TableColumnWidth width;
  final Widget Function(
    BuildContext context,
    int index,
    CrmClientRecordModel record,
  ) cellBuilder;

  const _ClientTableColumn({
    required this.title,
    required this.width,
    required this.cellBuilder,
  });
}
