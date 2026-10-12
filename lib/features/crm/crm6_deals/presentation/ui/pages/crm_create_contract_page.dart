// ****************** FILE INFO ******************
// File Name: crm_create_contract_page.dart
// Purpose: Create Contract preview page with stylized Contract Agreement PDF preview, Download button, Discard and Done actions matching Figma screenshot
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/crm_control_dialogs.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_client_deal_model.dart';
import 'package:knowticed_plus/features/crm/crm6_deals/data/models/crm_quote_model.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmCreateContractPage extends StatelessWidget {
  final CrmClientDealModel deal;
  final CrmQuoteModel quote;

  const CrmCreateContractPage({
    super.key,
    required this.deal,
    required this.quote,
  });

  void _onDownload(BuildContext context) {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Download Contract',
        arabicName: 'تحميل العقد',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'Contract agreement PDF downloaded successfully.',
        arabicName: 'تم تحميل ملف العقد PDF بنجاح.',
      ),
    );
  }

  void _onDone(BuildContext context) {
    CrmControlDialogs.showSuccessDialog(
      context: context,
      title: FormatHelper.localizedString(
        englishName: 'Contract Created',
        arabicName: 'تم إنشاء العقد',
      ),
      subtitle: FormatHelper.localizedString(
        englishName: 'The contract has been generated and saved.',
        arabicName: 'تم إنشاء وحفظ العقد بنجاح.',
      ),
      onComplete: () {
        Navigator.pop(context); // return to details page
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dealTitle =
        deal.dealNameEn.isNotEmpty ? deal.dealNameEn : 'ERP System Deal';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SideFrameMasterServices(
        titleText: dealTitle,
        secondTitle: FormatHelper.localizedString(
          englishName: 'Quote Details',
          arabicName: 'تفاصيل عرض الأسعار',
        ),
        thirdTitle: FormatHelper.localizedString(
          englishName: 'Create Contract',
          arabicName: 'إنشاء عقد',
        ),
        onFirstTap: () => Navigator.pop(context),
        onSecondTap: () => Navigator.pop(context),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── 1. PDF Preview Section Card ─────────────────────────────────
              CrmSectionCard(
                title: FormatHelper.localizedString(
                  englishName: 'PDF Preview',
                  arabicName: 'معاينة PDF',
                ),
                showHideToggle: true,
                trailing: customButtonWithSvg(
                  title: FormatHelper.localizedString(
                    englishName: 'Download',
                    arabicName: 'تحميل',
                  ),
                  image: AppAssets.download,
                  widthImage: 14.sp,
                  heightImage: 14.sp,
                  colorBorder: Colors.transparent,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize14Weight500.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  function: () => _onDownload(context),
                ),
                child: _buildContractDocumentSheet(context),
              ),

              SizedBox(height: 32.sp),

              // ── 2. Bottom Actions: Discard & Done ───────────────────────────
              _buildBottomActions(context),

              SizedBox(height: 32.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContractDocumentSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1.sp,
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Left grey decorative strip
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 70.sp,
            child: Container(
              color: const Color(0xFFF1F5F9),
            ),
          ),

          // Main Sheet Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 36.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header Logo
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Liceria & Co.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 20.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEAB308),
                        ),
                      ),
                      Text(
                        'Rimberio City',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF475569),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.sp),

                // Contract Agreement Title
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Text(
                    'Contract\nAgreement',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      height: 1.15,
                    ),
                  ),
                ),

                SizedBox(height: 16.sp),

                // Yellow decorative underline
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Container(
                    width: 180.sp,
                    height: 3.sp,
                    color: const Color(0xFFEAB308),
                  ),
                ),

                SizedBox(height: 40.sp),

                // Agreement Body Paragraph 1
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Text(
                    'This Independent Contract Agreement ("Agreement") is made effective as of .................................................., by and between .................................................. ("Client"), of .................................................. , and .................................................. ("Security Partner"), of ..................................................',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1E293B),
                      height: 1.6,
                    ),
                  ),
                ),

                SizedBox(height: 24.sp),

                // Agreement Body Paragraph 2
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Text(
                    'The Client engages the Security Partner for professional security and safety-related services under the following terms and conditions:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1E293B),
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: 8.sp),

                // Dotted Lines
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int i = 0; i < 5; i++)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.sp),
                          child: Text(
                            '........................................................................................................................................................................................................',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              letterSpacing: 2.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 28.sp),

                // Section 2: Description Of Services & Terms
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Text(
                    'Description Of Services & Terms',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),

                SizedBox(height: 10.sp),

                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Text(
                    'The Security Partner agrees to provide security services, including but not limited to:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1E293B),
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: 8.sp),

                // Dotted Lines Section 2
                Padding(
                  padding: EdgeInsets.only(left: 60.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int i = 0; i < 7; i++)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.sp),
                          child: Text(
                            '........................................................................................................................................................................................................',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                              letterSpacing: 2.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 48.sp),
              ],
            ),
          ),

          // Bottom yellow decorative footer bar with folder tab
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
              height: 20.sp,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFFACC15), // Yellow footer bar
                    ),
                  ),
                  Positioned(
                    right: 40.sp,
                    top: 0,
                    bottom: 0,
                    width: 80.sp,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAB308),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          topRight: Radius.circular(8.r),
                        ),
                      ),
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

  Widget _buildBottomActions(BuildContext context) {
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
          function: () => Navigator.pop(context),
        ),
        customButton(
          title: FormatHelper.localizedString(
            englishName: 'Done',
            arabicName: 'تم',
          ),
          color: AppColors.primary,
          borderColor: Colors.transparent,
          textStyle: StyleText.fontSize14Weight500.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          function: () => _onDone(context),
        ),
      ],
    );
  }
}
