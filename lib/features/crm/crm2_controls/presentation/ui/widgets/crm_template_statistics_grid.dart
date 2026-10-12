// ****************** FILE INFO ******************
// File Name: crm_template_statistics_grid.dart
// Purpose: Statistic cards grid for CRM template builder fields and sections
// Author: Mohand Adel
// Created At: 17/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_field_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/ui/widgets/crm_template_field_card.dart';

class CrmTemplateStatisticsGrid extends StatelessWidget {
  const CrmTemplateStatisticsGrid({
    required this.fields,
    super.key,
  });

  final List<CrmTemplateFieldModel> fields;

  static const List<Map<String, String>> _statTypes = [
    {'name': 'Email', 'key': 'email'},
    {'name': 'Phone', 'key': 'phone'},
    {'name': 'Location', 'key': 'location'},
    {'name': 'Link', 'key': 'link'},
    {'name': 'Signature', 'key': 'signature'},
    {'name': 'Website', 'key': 'website'},
    {'name': 'Sector', 'key': 'sector'},
    {'name': 'Industry', 'key': 'industry'},
    {'name': 'Company Size', 'key': 'company'},
    {'name': 'Image', 'key': 'image'},
  ];

  int _countForType(String key) {
    final String lowerKey = key.toLowerCase();
    return fields.where((CrmTemplateFieldModel field) {
      final String typeId = field.fieldTypeId.toLowerCase();
      final String nameEn = field.nameEn.toLowerCase();
      return typeId.contains(lowerKey) || nameEn.contains(lowerKey);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activeStats = _statTypes
        .map((Map<String, String> item) => <String, dynamic>{
              'name': item['name']!,
              'key': item['key']!,
              'count': _countForType(item['key']!),
            })
        .where((Map<String, dynamic> stat) => (stat['count'] as int) >= 1)
        .toList();

    if (activeStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final double width = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 5;
    if (width < 700.sp) {
      crossAxisCount = 2;
    } else if (width < 1100.sp) {
      crossAxisCount = 3;
    } else if (width < 1400.sp) {
      crossAxisCount = 4;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.sp,
        mainAxisSpacing: 12.sp,
        mainAxisExtent: 64.sp,
      ),
      itemCount: activeStats.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> item = activeStats[index];
        final String name = item['name'] as String;
        final String key = item['key'] as String;
        final int count = item['count'] as int;
        return CrmTemplateFieldCard(
          title: name,
          fieldTypeLabel: name,
          iconKey: key,
          trailingText: count.toString(),
          showCircleIcon: true,
          onTap: () {},
        );
      },
    );
  }
}
