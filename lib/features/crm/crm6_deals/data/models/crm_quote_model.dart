// ****************** FILE INFO ******************
// File Name: crm_quote_model.dart
// Purpose: Data model representing a Deal Quote with status, products, services, and dates
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

enum CrmQuoteStatus {
  all,
  pending,
  approved,
  adjustment,
  reject,
  expired;

  String get labelEn {
    switch (this) {
      case CrmQuoteStatus.all:
        return 'All';
      case CrmQuoteStatus.pending:
        return 'Pending';
      case CrmQuoteStatus.approved:
        return 'Approved';
      case CrmQuoteStatus.adjustment:
        return 'Adjustment';
      case CrmQuoteStatus.reject:
        return 'Reject';
      case CrmQuoteStatus.expired:
        return 'Expired';
    }
  }

  String get labelAr {
    switch (this) {
      case CrmQuoteStatus.all:
        return 'الكل';
      case CrmQuoteStatus.pending:
        return 'معلق';
      case CrmQuoteStatus.approved:
        return 'معتمد';
      case CrmQuoteStatus.adjustment:
        return 'تعديل';
      case CrmQuoteStatus.reject:
        return 'مرفوض';
      case CrmQuoteStatus.expired:
        return 'منتهي';
    }
  }

  Color get color {
    switch (this) {
      case CrmQuoteStatus.all:
        return AppColors.primary;
      case CrmQuoteStatus.pending:
        return const Color(0xFFFF7A00); // Orange
      case CrmQuoteStatus.approved:
        return AppColors.green;
      case CrmQuoteStatus.adjustment:
        return const Color(0xFF2563EB); // Blue
      case CrmQuoteStatus.reject:
        return const Color(0xFFDC2626); // Red
      case CrmQuoteStatus.expired:
        return AppColors.darkGrey;
    }
  }
}

class CrmQuoteModel {
  final String id;
  final int no;
  final String quoteNo;
  final String version;
  final CrmQuoteStatus clientStatus;
  final String approvalStatus; // Approved, Pending Approved
  final Color approvalStatusColor;
  final String validUntil;
  final String createdDate;
  final double total;
  final String totalFormatted;
  final String productsCategory;
  final String products;
  final int qty;
  final String productDiscount;
  final String productTax;
  final String productTotal;
  final String servicesCategory;
  final String services;
  final String serviceDiscount;
  final String serviceTax;
  final String serviceTotal;
  final String paymentTerms;
  final String deliveryTerms;
  final String noteEn;
  final String noteAr;

  const CrmQuoteModel({
    required this.id,
    required this.no,
    required this.quoteNo,
    required this.version,
    required this.clientStatus,
    required this.approvalStatus,
    required this.approvalStatusColor,
    required this.validUntil,
    required this.createdDate,
    required this.total,
    required this.totalFormatted,
    this.productsCategory = 'Software',
    this.products = 'ERP License',
    this.qty = 5,
    this.productDiscount = '20%',
    this.productTax = '\$50',
    this.productTotal = '\$400',
    this.servicesCategory = 'Technical',
    this.services = 'Setup & Support',
    this.serviceDiscount = '10%',
    this.serviceTax = '\$50',
    this.serviceTotal = '\$100',
    this.paymentTerms = '30 Days Net',
    this.deliveryTerms = 'Immediate',
    this.noteEn = 'Standard enterprise deal quote terms.',
    this.noteAr = 'شروط عرض أسعار صفقة المؤسسة القياسية.',
  });

  factory CrmQuoteModel.getEmptyModel() {
    return CrmQuoteModel(
      id: '1',
      no: 1,
      quoteNo: '78855A',
      version: '1',
      clientStatus: CrmQuoteStatus.approved,
      approvalStatus: 'Approved',
      approvalStatusColor: AppColors.green,
      validUntil: '7 Jun 2026',
      createdDate: '7 Jun 2026',
      total: 1000,
      totalFormatted: '\$1,000',
    );
  }
}
