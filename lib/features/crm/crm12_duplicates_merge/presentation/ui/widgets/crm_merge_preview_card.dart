// ****************** FILE INFO ******************
// File Name: crm_merge_preview_card.dart
// Purpose: Step 3 Review & Confirm view with What Happens After Merge, Summary, and Preview matching Figma screenshot 4
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';

class CrmMergePreviewCard extends StatefulWidget {
  final CrmDuplicatePairModel pair;
  final String masterId;
  final Map<String, int> selectedFieldSources;

  const CrmMergePreviewCard({
    super.key,
    required this.pair,
    required this.masterId,
    required this.selectedFieldSources,
  });

  @override
  State<CrmMergePreviewCard> createState() => _CrmMergePreviewCardState();
}

class _CrmMergePreviewCardState extends State<CrmMergePreviewCard> {
  bool _isSummaryExpanded = true;
  bool _isPreviewExpanded = true;

  @override
  Widget build(BuildContext context) {
    final String chosenName = (widget.selectedFieldSources['name'] ?? 1) == 1
        ? widget.pair.record1.name
        : widget.pair.record2.name;
    final String chosenPhone = (widget.selectedFieldSources['phone'] ?? 1) == 1
        ? widget.pair.record1.phone
        : widget.pair.record2.phone;
    final String chosenEmail = (widget.selectedFieldSources['email'] ?? 1) == 1
        ? widget.pair.record1.email
        : widget.pair.record2.email;
    final String chosenCompany =
        (widget.selectedFieldSources['company'] ?? 1) == 1
            ? (widget.pair.record1.company.isNotEmpty
                ? widget.pair.record1.company
                : 'UX/UI')
            : (widget.pair.record2.company.isNotEmpty
                ? widget.pair.record2.company
                : 'UX/UI');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 1. What Happens After Merge Section
        Text(
          FormatHelper.localizedString(
            englishName: 'What Happens After Merge',
            arabicName: 'ماذا يحدث بعد الدمج',
          ),
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.sp),
        _buildWhatHappensCard(),
        SizedBox(height: 20.sp),

        // 2. Merge Summary Section with Hide Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              FormatHelper.localizedString(
                englishName: 'Merge Summary',
                arabicName: 'ملخص الدمج',
              ),
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () =>
                  setState(() => _isSummaryExpanded = !_isSummaryExpanded),
              child: Text(
                _isSummaryExpanded
                    ? FormatHelper.localizedString(
                        englishName: 'Hide',
                        arabicName: 'إخفاء',
                      )
                    : FormatHelper.localizedString(
                        englishName: 'Show',
                        arabicName: 'عرض',
                      ),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (_isSummaryExpanded) ...<Widget>[
          SizedBox(height: 12.sp),
          _buildSummaryCard(),
        ],
        SizedBox(height: 20.sp),

        // 3. Merge Preview Section with Hide Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              FormatHelper.localizedString(
                englishName: 'Merge Preview',
                arabicName: 'معاينة الدمج',
              ),
              style: StyleText.fontSize14Weight500.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () =>
                  setState(() => _isPreviewExpanded = !_isPreviewExpanded),
              child: Text(
                _isPreviewExpanded
                    ? FormatHelper.localizedString(
                        englishName: 'Hide',
                        arabicName: 'إخفاء',
                      )
                    : FormatHelper.localizedString(
                        englishName: 'Show',
                        arabicName: 'عرض',
                      ),
                style: StyleText.fontSize12Weight500.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (_isPreviewExpanded) ...<Widget>[
          SizedBox(height: 12.sp),
          _buildPreviewContent(
            name: chosenName,
            phone: chosenPhone,
            email: chosenEmail,
            jobTitle: chosenCompany,
          ),
        ],
      ],
    );
  }

  Widget _buildWhatHappensCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildBulletRow(
            FormatHelper.localizedString(
              englishName: 'Duplicate Record will be archived',
              arabicName: 'سيتم أرشفة السجل المكرر',
            ),
          ),
          SizedBox(height: 10.sp),
          _buildBulletRow(
            FormatHelper.localizedString(
              englishName: 'All Related Data move to master Record',
              arabicName: 'نقل كافة البيانات المرتبطة إلى السجل الرئيسي',
            ),
          ),
          SizedBox(height: 10.sp),
          _buildBulletRow(
            FormatHelper.localizedString(
              englishName: 'This action will be undone within 30 days.',
              arabicName: 'يمكن التراجع عن هذا الإجراء خلال 30 يوماً.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildSummaryItem(
            label: FormatHelper.localizedString(
              englishName: 'Fields Update',
              arabicName: 'الحقول المحدثة',
            ),
            count: '4',
          ),
          _buildSummaryItem(
            label: FormatHelper.localizedString(
              englishName: 'New Values',
              arabicName: 'قيم جديدة',
            ),
            count: '4',
          ),
          _buildSummaryItem(
            label: FormatHelper.localizedString(
              englishName: 'Unchanged',
              arabicName: 'بدون تغيير',
            ),
            count: '4',
          ),
        ],
      ),
    );
  }

  Widget _buildBulletRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(Icons.check, color: AppColors.primary, size: 16.sp),
        SizedBox(width: 8.sp),
        Expanded(
          child: Text(
            text,
            style: StyleText.fontSize12Weight400,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({required String label, required String count}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          '$label  ',
          style: StyleText.fontSize12Weight400.copyWith(
            color: AppColors.darkGrey,
          ),
        ),
        Text(
          count,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewContent({
    required String name,
    required String phone,
    required String email,
    required String jobTitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildPreviewRow(
            label: FormatHelper.localizedString(
              englishName: 'Full Name',
              arabicName: 'الاسم الكامل',
            ),
            value: name,
          ),
          SizedBox(height: 12.sp),
          _buildPreviewRow(
            label: FormatHelper.localizedString(
              englishName: 'Phone',
              arabicName: 'رقم الهاتف',
            ),
            value: phone,
          ),
          SizedBox(height: 12.sp),
          _buildPreviewRow(
            label: FormatHelper.localizedString(
              englishName: 'Email',
              arabicName: 'البريد الإلكتروني',
            ),
            value: email,
          ),
          SizedBox(height: 12.sp),
          _buildPreviewRow(
            label: FormatHelper.localizedString(
              englishName: 'Job Title',
              arabicName: 'المسمى الوظيفي',
            ),
            value: jobTitle,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 90.sp,
          child: Text(
            label,
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.darkGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
