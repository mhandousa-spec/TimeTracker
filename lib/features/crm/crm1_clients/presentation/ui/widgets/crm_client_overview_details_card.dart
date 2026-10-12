// ****************** FILE INFO ******************
// File Name: crm_client_overview_details_card.dart
// Purpose: Details metadata section card for the CRM Client Profile Overview tab
// Author: Mohand Adel
// Created At: 26/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm1_clients/data/models/crm_client_record_model.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/data/models/crm_template_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmClientOverviewDetailsCard extends StatelessWidget {
  final CrmClientRecordModel record;
  final CrmTemplateModel? template;

  const CrmClientOverviewDetailsCard({
    super.key,
    required this.record,
    this.template,
  });

  String get _locale => Get.locale.toString().contains('ar') ? 'ar' : 'en';

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    final String templateName = template != null && template!.nameEn.isNotEmpty
        ? FormatHelper.localizedString(
            englishName: template!.nameEn,
            arabicName: template!.nameAr,
          )
        : FormatHelper.formatDate(record.audit.createdAt, _locale);

    final String addingDate =
        FormatHelper.formatDate(record.audit.createdAt, _locale);
    final String lastUpdate = FormatHelper.formatDate(
      record.audit.updatedAt,
      _locale,
    );
    final String authorName = _resolveEmployeeName(record.audit.createdBy);

    return CrmSectionCard(
      title: FormatHelper.localizedString(
        englishName: 'Details',
        arabicName: 'التفاصيل',
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      child: isMobile
          ? _buildMobileLayout(templateName, addingDate, authorName, lastUpdate)
          : _buildDesktopLayout(
              templateName, addingDate, authorName, lastUpdate),
    );
  }

  String _resolveEmployeeName(String rawCreatedBy) {
    final String trimmed = rawCreatedBy.trim();
    if (trimmed.isEmpty) return 'Aya Ahmed';

    try {
      if (Get.isRegistered<MainCoreEmployeeController>()) {
        final controller = AppControllers.employee;
        final employee = controller.getLocaleEmployee(trimmed) ??
            controller.allEmployeesEntities?.firstWhereOrNull(
              (e) =>
                  (e.email ?? '').toLowerCase() == trimmed.toLowerCase() ||
                  (e.id ?? '').toLowerCase() == trimmed.toLowerCase(),
            );

        if (employee != null) {
          if (_locale == 'ar') {
            final String ar =
                '${employee.firstNameInArabic ?? employee.firstName ?? ''} ${employee.lastNameInArabic ?? employee.lastName ?? ''}'
                    .trim();
            if (ar.isNotEmpty) return ar;
          }
          final String en =
              '${employee.firstName ?? ''} ${employee.lastName ?? ''}'.trim();
          if (en.isNotEmpty) return en;
        }
      }
    } catch (_) {}

    return FormatHelper.formatEmailToName(trimmed);
  }

  Widget _buildDesktopLayout(
    String templateName,
    String addingDate,
    String authorName,
    String lastUpdate,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Template Name
        _buildDetailColumn(
          label: FormatHelper.localizedString(
            englishName: 'Template Name',
            arabicName: 'اسم النموذج',
          ),
          valueWidget: Text(
            templateName,
            style: StyleText.fontSize14Weight600.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 2. Adding Date
        _buildDetailColumn(
          label: FormatHelper.localizedString(
            englishName: 'Adding Date',
            arabicName: 'تاريخ الإضافة',
          ),
          valueWidget: Text(
            addingDate,
            style: StyleText.fontSize14Weight600.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 3. By (Avatar + Author Name)
        _buildDetailColumn(
          label: FormatHelper.localizedString(
            englishName: 'By',
            arabicName: 'بواسطة',
          ),
          valueWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24.sp,
                height: 24.sp,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                  style: StyleText.fontSize10Weight400.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 6.sp),
              Text(
                authorName,
                style: StyleText.fontSize14Weight600.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // 4. Last Update
        _buildDetailColumn(
          label: FormatHelper.localizedString(
            englishName: 'Last Update',
            arabicName: 'آخر تحديث',
          ),
          valueWidget: Text(
            lastUpdate,
            style: StyleText.fontSize14Weight600.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    String templateName,
    String addingDate,
    String authorName,
    String lastUpdate,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailColumn(
              label: FormatHelper.localizedString(
                englishName: 'Template Name',
                arabicName: 'اسم النموذج',
              ),
              valueWidget: Text(templateName,
                  style: StyleText.fontSize14Weight600),
            ),
            _buildDetailColumn(
              label: FormatHelper.localizedString(
                englishName: 'Adding Date',
                arabicName: 'تاريخ الإضافة',
              ),
              valueWidget: Text(addingDate,
                  style: StyleText.fontSize14Weight600),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDetailColumn(
              label: FormatHelper.localizedString(
                englishName: 'By',
                arabicName: 'بواسطة',
              ),
              valueWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20.sp,
                    height: 20.sp,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.sp),
                  Text(authorName,
                      style: StyleText.fontSize14Weight600),
                ],
              ),
            ),
            _buildDetailColumn(
              label: FormatHelper.localizedString(
                englishName: 'Last Update',
                arabicName: 'آخر تحديث',
              ),
              valueWidget: Text(lastUpdate,
                  style: StyleText.fontSize14Weight600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailColumn({
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(width: 6.sp),
        valueWidget,
      ],
    );
  }
}
