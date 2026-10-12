// ****************** FILE INFO ******************
// File Name: crm_add_quote_step4_review_pdf.dart
// Purpose: Step 4 Review & PDF Preview form for Add Quote wizard matching Figma screenshot 5
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/presentation/ui/widgets/crm_section_card.dart';

class CrmAddQuoteStep4ReviewPdf extends StatelessWidget {
  final String subtotalProducts;
  final String subtotalServices;
  final String taxes;
  final String discount;
  final String grandTotal;
  final String quoteNumber;
  final String quoteDate;
  final String quoteDateUntil;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final VoidCallback onDownloadPdf;

  const CrmAddQuoteStep4ReviewPdf({
    super.key,
    this.subtotalProducts = '1400 GEP',
    this.subtotalServices = '1400 GEP',
    this.taxes = '100 EGP',
    this.discount = '-200 EGP',
    this.grandTotal = '1,000 EGP',
    this.quoteNumber = '78855A',
    this.quoteDate = '7 Jun 2026',
    this.quoteDateUntil = '14 Jun 2026',
    this.clientName = 'John Doe Enterprises',
    this.clientEmail = 'contact@johndoe.com',
    this.clientPhone = '+20 100 123 4567',
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── 1. Summary Section ────────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'Summary',
            arabicName: 'الملخص',
          ),
          showHideToggle: true,
          child: Column(
            children: <Widget>[
              _buildSummaryRow(
                label: FormatHelper.localizedString(
                  englishName: 'Subtotal Products (2 item)',
                  arabicName: 'إجمالي المنتجات (2 عناصر)',
                ),
                value: subtotalProducts,
              ),
              SizedBox(height: 8.sp),
              _buildSummaryRow(
                label: FormatHelper.localizedString(
                  englishName: 'Subtotal Services (2 services)',
                  arabicName: 'إجمالي الخدمات (2 خدمات)',
                ),
                value: subtotalServices,
              ),
              SizedBox(height: 8.sp),
              _buildSummaryRow(
                label: FormatHelper.localizedString(
                  englishName: 'Taxes',
                  arabicName: 'الضرائب',
                ),
                value: taxes,
              ),
              SizedBox(height: 8.sp),
              _buildSummaryRow(
                label: FormatHelper.localizedString(
                  englishName: 'Discount (20%)',
                  arabicName: 'الخصم (20%)',
                ),
                value: discount,
                valueColor: const Color(0xFFFF7A00),
              ),
              SizedBox(height: 12.sp),
              const Divider(color: Color(0xFFE5E7EB)),
              SizedBox(height: 8.sp),
              _buildSummaryRow(
                label: FormatHelper.localizedString(
                  englishName: 'Total',
                  arabicName: 'الإجمالي النهائي',
                ),
                value: grandTotal,
                isBold: true,
              ),
            ],
          ),
        ),

        SizedBox(height: 16.sp),

        // ── 2. PDF Preview Section ────────────────────────────────────────────
        CrmSectionCard(
          title: FormatHelper.localizedString(
            englishName: 'PDF Preview',
            arabicName: 'معاينة ملف PDF',
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
            color: AppColors.primary,
            colorBorder: Colors.transparent,
            textStyle: StyleText.fontSize14Weight500.copyWith(
              fontWeight: FontWeight.bold,
            ),
            function: onDownloadPdf,
          ),
          child: _buildPdfInvoicePreview(context),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.black : const Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: StyleText.fontSize14Weight500.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ??
                (isBold ? AppColors.black : const Color(0xFF111827)),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfInvoicePreview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.sp),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ── Header: Logo ────────────────────────────────────────────────────
          Container(
            width: 70.sp,
            height: 70.sp,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFEF9C3),
            ),
            padding: EdgeInsets.all(12.sp),
            child: CustomSvgImage(
              assetPath: AppAssets.logo,
              width: 46.sp,
              height: 46.sp,
            ),
          ),

          SizedBox(height: 20.sp),

          // ── 2-Column Info Grid: TO vs QUOTEINFO ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // TO: Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'TO:',
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Text('CLIENT NAME: $clientName', style: _pdfTextStyle),
                  Text('CLIENT EMAIL: $clientEmail', style: _pdfTextStyle),
                  Text('CLIENT PHONE: $clientPhone', style: _pdfTextStyle),
                ],
              ),

              // QUOTEINFO: Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'QUOTEINFO:',
                    style: StyleText.fontSize14Weight500.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Text('QUOTE NO: $quoteNumber', style: _pdfTextStyle),
                  Text('DATE: $quoteDate', style: _pdfTextStyle),
                  Text('VALID UNTIL: $quoteDateUntil', style: _pdfTextStyle),
                ],
              ),
            ],
          ),

          SizedBox(height: 24.sp),

          // ── Product Table with Yellow Header Bar ───────────────────────────
          Table(
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(2.0),
              1: FlexColumnWidth(1.0),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.2),
            },
            children: <TableRow>[
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8B931),
                ),
                children: <Widget>[
                  _buildPdfTableHeader('PRODUCT'),
                  _buildPdfTableHeader('QTY'),
                  _buildPdfTableHeader('PRICE'),
                  _buildPdfTableHeader('DISCOUNT'),
                  _buildPdfTableHeader('TAX'),
                  _buildPdfTableHeader('TOTAL'),
                ],
              ),
              TableRow(
                children: <Widget>[
                  _buildPdfTableCell('z'),
                  _buildPdfTableCell('3'),
                  _buildPdfTableCell('\$500'),
                  _buildPdfTableCell('3%'),
                  _buildPdfTableCell('\$50'),
                  _buildPdfTableCell('\$100'),
                ],
              ),
            ],
          ),

          SizedBox(height: 20.sp),

          // ── Subtotal, Tax, and Yellow Total Block ───────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 220.w,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('SUBTOTAL',
                          style: _pdfTextStyle.copyWith(
                              fontWeight: FontWeight.bold)),
                      Text('\$100',
                          style: _pdfTextStyle.copyWith(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 6.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Tax 10%', style: _pdfTextStyle),
                      Text('\$105', style: _pdfTextStyle),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
                    color: const Color(0xFFE8B931),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'TOTAL',
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$550',
                          style: StyleText.fontSize14Weight500.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30.sp),

          // ── Payment Info & Contact Info Columns ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left: Payment Info & Notes
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('PAYMENT INFO:', style: _pdfHeaderStyle),
                  SizedBox(height: 4.sp),
                  Text('FIRST PAYMENT ATTEMPT:', style: _pdfTextStyle),
                  Text('SUCCESSFUL PAYMENT DATE:', style: _pdfTextStyle),
                  Text('PAYMENT METHOD:', style: _pdfTextStyle),
                  SizedBox(height: 12.sp),
                  Text('NOTES:', style: _pdfHeaderStyle),
                  SizedBox(height: 4.sp),
                  Text('• .....', style: _pdfTextStyle),
                  Text('• ......', style: _pdfTextStyle),
                ],
              ),

              // Right: Contact Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('CONTACT INFO:', style: _pdfHeaderStyle),
                  SizedBox(height: 4.sp),
                  Text('EMAIL: $clientEmail', style: _pdfTextStyle),
                  Text('PHONE: $clientPhone', style: _pdfTextStyle),
                ],
              ),
            ],
          ),

          SizedBox(height: 36.sp),

          // ── Thank you note and signature on bottom right ────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'THANK YOU FOR USING SPA CARE TIME!',
                  style: StyleText.fontSize12Weight400.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.sp),
                Text(
                  'CareTime',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                    fontSize: 22.sp,
                    color: const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static TextStyle get _pdfTextStyle =>
      StyleText.fontSize12Weight400.copyWith(
        color: const Color(0xFF374151),
        fontSize: 11.sp,
        height: 1.5,
      );

  static TextStyle get _pdfHeaderStyle =>
      StyleText.fontSize12Weight400.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.black,
        letterSpacing: 0.5,
      );

  Widget _buildPdfTableHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: Text(
        title,
        style: StyleText.fontSize12Weight400.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
          fontSize: 11.sp,
        ),
      ),
    );
  }

  Widget _buildPdfTableCell(String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: Text(
        value,
        style: StyleText.fontSize12Weight400.copyWith(
          color: const Color(0xFF374151),
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
