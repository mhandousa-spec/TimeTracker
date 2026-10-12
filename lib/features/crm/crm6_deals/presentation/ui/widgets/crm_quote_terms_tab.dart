// ****************** FILE INFO ******************
// File Name: crm_quote_terms_tab.dart
// Purpose: Terms tab content for Quote Details page supporting View mode and Edit mode matching Figma screenshots 1 & 2
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/55-custom_responsive_fields.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmQuoteTermsTab extends StatefulWidget {
  final bool isEditMode;
  final VoidCallback? onEditTap;
  final VoidCallback? onDiscardTap;
  final VoidCallback? onSaveTap;

  const CrmQuoteTermsTab({
    super.key,
    this.isEditMode = false,
    this.onEditTap,
    this.onDiscardTap,
    this.onSaveTap,
  });

  @override
  State<CrmQuoteTermsTab> createState() => _CrmQuoteTermsTabState();
}

class _CrmQuoteTermsTabState extends State<CrmQuoteTermsTab> {
  String? _paymentTerm = 'Choose';
  String? _deliveryTerm = 'Choose';

  late final TextEditingController _noteEnCtrl;
  late final TextEditingController _noteArCtrl;

  static const List<String> _paymentTermOptions = <String>[
    'Choose',
    'Net 15 Days',
    'Net 30 Days',
    'Net 60 Days',
    '100% Advance',
    '50% Advance, 50% on Delivery',
  ];

  static const List<String> _deliveryTermOptions = <String>[
    'Choose',
    'Immediate',
    'Within 7 Days',
    'Within 14 Days',
    'Within 30 Days',
  ];

  @override
  void initState() {
    super.initState();
    _noteEnCtrl = TextEditingController();
    _noteArCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _noteEnCtrl.dispose();
    _noteArCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Terms Section Card ─────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Terms',
            arabicName: 'الشروط والأحكام',
          ),
          showHideToggle: false,
          trailing: (!widget.isEditMode && widget.onEditTap != null)
              ? _buildEditButton(context)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Row 1: Payment Terms & Delivery Terms
              buildResponsiveFields(
                context: context,
                left: widget.isEditMode
                    ? CustomDropdown<String>(
                        label: 'Payment Terms',
                        hint: 'Choose',
                        value: _paymentTerm,
                        items: _paymentTermOptions
                            .map((String t) =>
                                DropdownItem<String>(value: t, label: t))
                            .toList(),
                        fillColor: AppColors.background,
                        onChanged: (String? val) {
                          if (val != null) setState(() => _paymentTerm = val);
                        },
                      )
                    : CustomTextField(
                        label: 'Payment Terms',
                        hint: 'Choose',
                        readOnly: true,
                        fillColor: AppColors.background,
                      ),
                right: widget.isEditMode
                    ? CustomDropdown<String>(
                        label: 'Delivery Terms',
                        hint: 'Choose',
                        value: _deliveryTerm,
                        items: _deliveryTermOptions
                            .map((String t) =>
                                DropdownItem<String>(value: t, label: t))
                            .toList(),
                        fillColor: AppColors.background,
                        onChanged: (String? val) {
                          if (val != null) setState(() => _deliveryTerm = val);
                        },
                      )
                    : CustomTextField(
                        label: 'Delivery Terms',
                        hint: 'Choose',
                        readOnly: true,
                        fillColor: AppColors.background,
                      ),
              ),

              SizedBox(height: 14.sp),

              // Row 2: Note EN
              CustomTextField(
                label: 'Note',
                controller: _noteEnCtrl,
                hint: 'Description',
                fillColor: AppColors.background,
                readOnly: !widget.isEditMode,
                maxLines: 3,
                minLines: 3,
                maxLength: 500,
                showCharCount: true,
              ),

              SizedBox(height: 14.sp),

              // Row 3: Note AR
              Directionality(
                textDirection: TextDirection.rtl,
                child: CustomTextField(
                  label: 'ملاحظة',
                  controller: _noteArCtrl,
                  hint: 'اكتب هنا',
                  fillColor: AppColors.background,
                  readOnly: !widget.isEditMode,
                  maxLines: 3,
                  minLines: 3,
                  maxLength: 500,
                  showCharCount: true,
                  textAlign: TextAlign.right,
                ),
              ),

              SizedBox(height: 16.sp),

              // Row 4: File Section
              if (!widget.isEditMode) ...<Widget>[
                // In View Mode: Attached File Card
                SizedBox(
                  width: 320.sp,
                  child: Container(
                    padding: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: <Widget>[
                        // PDF icon from AppAssets
                        Container(
                          width: 32.sp,
                          height: 32.sp,
                          alignment: Alignment.center,
                          child: CustomSvgImage(
                            assetPath: AppAssets.pdf,
                            width: 30.sp,
                            height: 30.sp,
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Watermark.png',
                                style: StyleText.fontSize12Weight400
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '62 KB',
                                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack)
                                    .copyWith(
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              Text(
                                'Uploaded By: Aya Ahmed',
                                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack)
                                    .copyWith(
                                  color: AppColors.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Uploaded On: 28 Dec 2024',
                          style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack)
                              .copyWith(
                            color: AppColors.darkGrey,
                            fontSize: 8.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...<Widget>[
                // In Edit Mode: Upload Button & + Add Files Button
                Text(
                  FormatHelper.localizedString(
                    englishName: 'File',
                    arabicName: 'ملف',
                  ),
                  style: StyleText.fontSize12Weight400.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.sp),

                // Yellow Upload Button
                InkWell(
                  onTap: () {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: 'Upload File',
                      subtitle: 'File picker dialog will open here.',
                    );
                  },
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    width: 320.sp,
                    padding: EdgeInsets.symmetric(vertical: 10.sp),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.file_upload_outlined,
                            size: 18.sp, color: AppColors.black),
                        SizedBox(width: 8.sp),
                        Text(
                          FormatHelper.localizedString(
                            englishName: 'Upload',
                            arabicName: 'رفع',
                          ),
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10.sp),

                // Dark + Add Files Button
                InkWell(
                  onTap: () {
                    CrmControlDialogs.showSuccessDialog(
                      context: context,
                      title: 'Add Files',
                      subtitle: 'Additional file picker opened.',
                    );
                  },
                  borderRadius: BorderRadius.circular(6.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.sp, vertical: 8.sp),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.add, color: AppColors.white, size: 16.sp),
                        SizedBox(width: 6.sp),
                        Text(
                          FormatHelper.localizedString(
                            englishName: 'Add Files',
                            arabicName: 'إضافة ملفات',
                          ),
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── 2. Bottom Discard / Save Action Bar (in edit mode) ───────────────
        if (widget.isEditMode) ...<Widget>[
          SizedBox(height: 32.sp),
          _buildEditBottomBar(context),
        ],
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return customButtonWithSvg(
      title: FormatHelper.localizedString(
        englishName: 'Edit',
        arabicName: 'تعديل',
      ),
      image: AppAssets.edit,
      widthImage: 14.sp,
      heightImage: 14.sp,
      colorBorder: Colors.transparent,
      color: AppColors.primary,
      textStyle: StyleText.fontSize14Weight500.copyWith(
        fontWeight: FontWeight.bold,
      ),
      function: widget.onEditTap!,
    );
  }

  Widget _buildEditBottomBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Discard',
            arabicName: 'تراجع',
          ),
          color: const Color(0xFFE5E7EB),
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          function: widget.onDiscardTap ?? () {},
        ),
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Save',
            arabicName: 'حفظ',
          ),
          color: AppColors.primary,
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          function: widget.onSaveTap ?? () {},
        ),
      ],
    );
  }
}
