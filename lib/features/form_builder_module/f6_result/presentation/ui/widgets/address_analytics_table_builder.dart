/// Module: services_app_module/result
///
/// FILE INFO
/// File Name   : address_analytics_table_builder.dart
/// Objective   : Presentation-layer builder for the address-analytics table.
///               The Material DataRow/DataColumn construction was moved here
///               out of domain/entity/address_analytics_entity.dart so the
///               domain layer stays UI-free (§3).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';

import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/address_analytics_entity.dart';

extension AddressAnalyticsTableBuilder on AddressAnalyticsEntity {
  List<DataRow> DataCells() {
    List<DataRow> rows = [];
    for (int tableIndex = 0;
        tableIndex < addressTableList!.length;
        tableIndex++) {
      List<DataCell> cells = [];
      for (int rowIndex = 0;
          rowIndex < addressTableList![tableIndex].length;
          rowIndex++) {
        cells.add(DataCell((rowIndex == 0)
            ? Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundImage: (images![tableIndex].contains('http'))
                        ? NetworkImage(images![tableIndex])
                        : appImageProvider(images![tableIndex]) as ImageProvider,
                  ),
                  SizedBox(width: 8.sp),
                  Text(
                    addressTableList![tableIndex][rowIndex],
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack),
                  )
                ],
              )
            : Text(
                addressTableList![tableIndex][rowIndex],
                style: StyleText.fontSize12Weight500.copyWith(color: AppColors.fullBlack),
              )));
      }
      rows.add(DataRow(
        cells: cells,
        color: WidgetStatePropertyAll(
          tableIndex % 2 == 0 ? AppColors.evenRowColor : AppColors.oddRowColor,
        ),
      ));
    }
    return rows;
  }

  List<DataColumn> DataColumns() {
    List<DataColumn> columns = [];
    for (int headerIndex = 0;
        headerIndex < headerItems!.length;
        headerIndex++) {
      columns.add(DataColumn(
          label: Text(
        headerItems![headerIndex],
        style: StyleText.fontSize16Weight400.copyWith(color: Colors.white),
      )));
    }
    return columns;
  }
}
