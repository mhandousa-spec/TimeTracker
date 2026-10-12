// ****************** FILE INFO ******************
// File Name: crm_merge_compare_section.dart
// Purpose: Step 2 Compare & Merge field-by-field table matching Figma screenshot 2
// Author: Mohand Adel
// Created At: 27/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/data/models/crm_duplicate_pair_model.dart';
import 'package:knowticed_plus/features/crm/crm12_duplicates_merge/presentation/ui/widgets/crm_merge_group_details_header.dart';

class CrmMergeCompareSection extends StatelessWidget {
  final CrmDuplicatePairModel pair;
  final String selectedMasterId;
  final Map<String, int> selectedFieldSources;
  final ValueChanged<String> onMasterChanged;
  final Function(String fieldKey, int recordNumber) onFieldSourceChanged;

  const CrmMergeCompareSection({
    super.key,
    required this.pair,
    required this.selectedMasterId,
    required this.selectedFieldSources,
    required this.onMasterChanged,
    required this.onFieldSourceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> fields = [
      {
        'key': 'name',
        'labelEn': 'Full Name',
        'labelAr': 'الاسم الكامل',
        'v1': pair.record1.name,
        'v2': pair.record2.name,
      },
      {
        'key': 'phone',
        'labelEn': 'Phone',
        'labelAr': 'رقم الهاتف',
        'v1': pair.record1.phone,
        'v2': pair.record2.phone,
      },
      {
        'key': 'email',
        'labelEn': 'Email',
        'labelAr': 'البريد الإلكتروني',
        'v1': pair.record1.email,
        'v2': pair.record2.email,
      },
      {
        'key': 'company',
        'labelEn': 'Company',
        'labelAr': 'الشركة',
        'v1': pair.record1.company.isNotEmpty ? pair.record1.company : '—',
        'v2': pair.record2.company.isNotEmpty ? pair.record2.company : '—',
      },
      {
        'key': 'address',
        'labelEn': 'Address',
        'labelAr': 'العنوان',
        'v1': pair.record1.address.isNotEmpty ? pair.record1.address : '—',
        'v2': pair.record2.address.isNotEmpty ? pair.record2.address : '—',
      },
      {
        'key': 'note',
        'labelEn': 'Notes',
        'labelAr': 'الملاحظات',
        'v1': pair.record1.note.isNotEmpty ? pair.record1.note : '—',
        'v2': pair.record2.note.isNotEmpty ? pair.record2.note : '—',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 1. Group Details Header
        CrmMergeGroupDetailsHeader(pair: pair),
        SizedBox(height: 20.sp),

        // 2. Comparison Table Header Row
        Builder(
          builder: (BuildContext context) {
            final double labelWidth =
                MediaQuery.of(context).size.width < 600 ? 75.sp : 140.sp;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
              child: Row(
                children: <Widget>[
                  // Fields Column Header
                  SizedBox(
                    width: labelWidth,
                    child: Text(
                      FormatHelper.localizedString(
                        englishName: 'Fields',
                        arabicName: 'الحقول',
                      ),
                      style: StyleText.fontSize14Weight500.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Record A (Master) Header
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Record A ',
                        style: StyleText.fontSize14Weight500.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '(Master)',
                            style:
                                StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Record B (Duplicate) Header
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Record B ',
                        style: StyleText.fontSize14Weight500.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '(Duplicate)',
                            style:
                                StyleText.fontSize12Weight400.copyWith(
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 4.sp),

        // 3. Field Rows as separate white cards
        Column(
          children: fields.map((f) => _buildFieldRow(context, f)).toList(),
        ),
      ],
    );
  }

  Widget _buildFieldRow(BuildContext context, Map<String, String> field) {
    final double labelWidth =
        MediaQuery.of(context).size.width < 600 ? 75.sp : 140.sp;
    final String key = field['key']!;
    final String label = FormatHelper.localizedString(
      englishName: field['labelEn']!,
      arabicName: field['labelAr']!,
    );
    final String v1 = field['v1']!;
    final String v2 = field['v2']!;
    final int selectedSource = selectedFieldSources[key] ?? 1;

    return Container(
      margin: EdgeInsets.only(bottom: 10.sp),
      padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          // Field Label
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: StyleText.fontSize12Weight400.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Option 1 (Record A value)
          Expanded(
            child: InkWell(
              onTap: () => onFieldSourceChanged(key, 1),
              borderRadius: BorderRadius.circular(4.r),
              child: Row(
                children: <Widget>[
                  _buildRadioIcon(selectedSource == 1),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      v1,
                      style: StyleText.fontSize12Weight400.copyWith(
                        fontWeight: selectedSource == 1
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.sp),

          // Option 2 (Record B value)
          Expanded(
            child: InkWell(
              onTap: () => onFieldSourceChanged(key, 2),
              borderRadius: BorderRadius.circular(4.r),
              child: Row(
                children: <Widget>[
                  _buildRadioIcon(selectedSource == 2),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      v2,
                      style: StyleText.fontSize12Weight400.copyWith(
                        fontWeight: selectedSource == 2
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioIcon(bool isSelected) {
    return Container(
      width: 18.sp,
      height: 18.sp,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.darkGrey,
          width: 1.8.sp,
        ),
      ),
      alignment: Alignment.center,
      child: isSelected
          ? Container(
              width: 8.sp,
              height: 8.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}
