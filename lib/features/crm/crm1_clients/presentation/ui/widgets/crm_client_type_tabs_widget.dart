// ****************** FILE INFO ******************
// File Name: crm_client_type_tabs_widget.dart
// Purpose: Horizontal tabs widget utilizing CustomTabs for selecting client types
// Author: Mohand Adel
// Created At: 08/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/10-custom_tabs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_client_type_model.dart';

/// Horizontal tab selector for switching between CRM client types using [CustomTabs].
class CrmClientTypeTabsWidget extends StatelessWidget {
  final List<CrmClientTypeModel> clientTypes;
  final String selectedClientTypeId;
  final ValueChanged<String> onTabSelected;

  const CrmClientTypeTabsWidget({
    super.key,
    required this.clientTypes,
    required this.selectedClientTypeId,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (clientTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<String> tabTitles = clientTypes.map((type) {
      return FormatHelper.localizedString(
        englishName: type.nameEn.isNotEmpty ? type.nameEn : type.title,
        arabicName: type.nameAr,
      );
    }).toList();

    final int selectedIndex =
        clientTypes.indexWhere((t) => t.id == selectedClientTypeId);
    final int effectiveIndex = selectedIndex >= 0 ? selectedIndex : 0;

    final bool isMobile = MediaQuery.sizeOf(context).width < 600;
    return CustomTabs(
      tabs: tabTitles,
      selectedValue: effectiveIndex,
      spacing: isMobile ? 18.sp : 32.sp,
      textStyle: isMobile
          ? StyleText.fontSize10Weight500.copyWith(color: Color(0xff797979))
          : StyleText.fontSize16Weight600,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.secondaryBlack,
      onChanged: (int index) {
        if (index >= 0 && index < clientTypes.length) {
          onTabSelected(clientTypes[index].id);
        }
      },
    );
  }
}
