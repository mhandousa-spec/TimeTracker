// ****************** FILE INFO ******************
// File Name: crm_template_layout_row_card.dart
// Purpose: Single layout row editor card: column count, Field/Section mode,
//          and the column assignment dropdowns
// Author: Mohand Adel
// Created At: 12/08/2026

import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

import 'crm_template_layout_data.dart';
import 'crm_template_shared_widgets.dart';

/// Editable layout row inside the template layout editor.
///
/// Mutates [row] directly and then invokes [onChanged] so the owning page can
/// rebuild — mirroring the original page-level state management.
class CrmTemplateLayoutRowCard extends StatelessWidget {
  const CrmTemplateLayoutRowCard({
    super.key,
    required this.row,
    required this.availableSections,
    required this.availableFields,
    required this.placed,
    required this.onChanged,
  });

  final CrmLayoutRowData row;
  final List<CrmLayoutItem> availableSections;
  final List<CrmLayoutItem> availableFields;

  /// Ids of items already placed in any row/column of the layout.
  final Set<String> placed;

  /// Called after any mutation of [row] so the parent can rebuild.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return CrmTemplateSectionShell(
      title: row.title,
      isExpanded: row.isExpanded,
      onToggleExpand: () {
        row.isExpanded = !row.isExpanded;
        onChanged();
      },
      headerBanner: row.numberOfColumns == 1
          ? Container(
              width: 420.sp,
              padding: EdgeInsets.symmetric(
                horizontal: 14.sp,
                vertical: 10.sp,
              ),
              decoration: BoxDecoration(
                color: const Color(0xffFFF7D5),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Row(
                children: [
                  CustomSvgImage(
                    assetPath: AppAssets.crmHint,
                    width: 20.sp,
                    height: 20.sp,
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Text(
                      S.current.crmToAddSectionHint,
                      style: StyleText.fontSize14Weight600.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildResponsiveFields(
            context: context,
            left: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.current.crmNumberOfColumns,
                  style: StyleText.fontSize14Weight600.copyWith(
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 10.sp),
                CustomTextField(
                  controller: row.columnsController,
                  enabled: !row.isSectionMode,
                  readOnly: row.isSectionMode,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (String text) {
                    if (row.isSectionMode) {
                      row.columnsController.text = '1';
                      return;
                    }
                    final int? val = int.tryParse(text);
                    if (val != null && val > 0) {
                      final int clamped = val.clamp(1, 2);
                      row.numberOfColumns = clamped;
                      if (clamped == 1) {
                        row.column2 = null;
                      } else {
                        row.column2 ??= CrmLayoutColumnData();
                      }
                      onChanged();
                    }
                  },
                ),
              ],
            ),
            right: const SizedBox.shrink(),
          ),
          SizedBox(height: 16.sp),
          if (row.numberOfColumns == 1) ...[
            buildResponsiveFields(
              context: context,
              left: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.current.crmColumn,
                        style: StyleText.fontSize14Weight600.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(
                        width: 100.w,
                        child: CustomSegmentedTabs(
                          tabs: [S.current.crmField, S.current.crmSection],
                          selectedIndex: row.isSectionMode ? 1 : 0,
                          onTabSelected: (int index) {
                            if (index == 0) {
                              row.isSectionMode = false;
                              row.columnsController.text =
                                  '${row.numberOfColumns}';
                              if (row.column1?.isSection == true) {
                                row.column1 = null;
                              }
                            } else {
                              row.isSectionMode = true;
                              row.numberOfColumns = 1;
                              row.columnsController.text = '1';
                              row.column2 = null;
                              if (row.column1?.isSection == false) {
                                row.column1 = null;
                              }
                            }
                            onChanged();
                          },
                          equalWidth: true,
                          containerPadding: EdgeInsets.all(1.sp),
                          containerColor: AppColors.background,
                          spacing: 4.sp,
                          selectedColor: AppColors.primary,
                          unselectedColor: AppColors.background,
                          selectedTextColor: AppColors.black,
                          unselectedTextColor: AppColors.lightGrey,
                          textStyle: StyleText.fontSize12Weight500.copyWith(color: AppColors.textButton),
                          borderRadius: 6.r,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  _buildColumnDropdown(
                    context,
                    currentData: row.column1,
                    isSectionMode: row.isSectionMode,
                    onSelected: (item) {
                      row.column1 = CrmLayoutColumnData(
                        selectedItemId: item.id,
                        selectedItemName: item.name,
                        isSection: item.isSection,
                      );
                      onChanged();
                    },
                  ),
                ],
              ),
              right: const SizedBox.shrink(),
            ),
          ] else ...[
            buildResponsiveFields(
              context: context,
              left: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${S.current.crmColumn} 1',
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  _buildColumnDropdown(
                    context,
                    currentData: row.column1,
                    isSectionMode: false,
                    onSelected: (item) {
                      row.column1 = CrmLayoutColumnData(
                        selectedItemId: item.id,
                        selectedItemName: item.name,
                        isSection: false,
                      );
                      onChanged();
                    },
                  ),
                ],
              ),
              right: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${S.current.crmColumn} 2',
                    style: StyleText.fontSize14Weight600.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  _buildColumnDropdown(
                    context,
                    currentData: row.column2,
                    isSectionMode: false,
                    onSelected: (item) {
                      row.column2 = CrmLayoutColumnData(
                        selectedItemId: item.id,
                        selectedItemName: item.name,
                        isSection: false,
                      );
                      onChanged();
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColumnDropdown(
    BuildContext context, {
    required CrmLayoutColumnData? currentData,
    required bool isSectionMode,
    required ValueChanged<CrmLayoutItem> onSelected,
  }) {
    final List<CrmLayoutItem> pool =
        isSectionMode ? availableSections : availableFields;

    final String? selectedId = currentData?.selectedItemId;
    CrmLayoutItem? selectedItem;
    if (selectedId != null) {
      for (final CrmLayoutItem item in pool) {
        if (item.id == selectedId) {
          selectedItem = item;
          break;
        }
      }
    }

    final List<DropdownItem<CrmLayoutItem>> dropdownItems = pool.map((item) {
      final bool isPlaced = placed.contains(item.id);
      final bool isCurrent = item.id == selectedId;
      return DropdownItem<CrmLayoutItem>(
        value: item,
        label: item.name,
        enabled: !isPlaced || isCurrent,
        trailing: isPlaced
            ? Icon(
                Icons.check_rounded,
                color: AppColors.primary,
                size: 20.sp,
              )
            : null,
      );
    }).toList();

    return CustomDropdown<CrmLayoutItem>(
      hint:
          isSectionMode ? S.current.crmSelectSection : S.current.crmSelectField,
      value: selectedItem,
      items: dropdownItems,
      onChanged: (CrmLayoutItem? newItem) {
        if (newItem != null) {
          onSelected(newItem);
        }
      },
    );
  }
}
