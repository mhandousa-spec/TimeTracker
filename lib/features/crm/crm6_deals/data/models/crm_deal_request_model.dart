// ****************** FILE INFO ******************
// File Name: crm_deal_request_model.dart
// Purpose: Data model representing Deal Requests (quote requests, approval statuses, details)
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

enum CrmRequestStatus {
  all('All', 'الكل'),
  pending('Pending', 'معلق'),
  approved('Approved', 'معتمد'),
  reject('Reject', 'مرفوض');

  final String labelEn;
  final String labelAr;

  const CrmRequestStatus(this.labelEn, this.labelAr);

  Color get color {
    switch (this) {
      case CrmRequestStatus.approved:
        return const Color(0xFF16A34A);
      case CrmRequestStatus.pending:
        return const Color(0xFFFF7A00);
      case CrmRequestStatus.reject:
        return const Color(0xFFDC2626);
      case CrmRequestStatus.all:
        return AppColors.primary;
    }
  }

  String get tableStatusLabel {
    switch (this) {
      case CrmRequestStatus.approved:
        return 'Approved';
      case CrmRequestStatus.pending:
        return 'Pending Approved';
      case CrmRequestStatus.reject:
        return 'Reject';
      case CrmRequestStatus.all:
        return 'All';
    }
  }
}

class CrmDealRequestModel {
  final String id;
  final int no;
  final String quoteNo;
  final String version;
  final CrmRequestStatus status;
  final String productsCategory;
  final String products;
  final String quantity;
  final String productDiscount;
  final String productTax;
  final String productTotal;
  final String servicesCategory;
  final String services;
  final String serviceDiscount;
  final String serviceTax;
  final String serviceTotal;
  final String createdDate;
  final String validUntil;
  final String paymentTerms;
  final String deliveryTerms;
  final String note;
  final String noteAr;
  final String approverName;
  final String approverRole;
  final String approverDepartment;
  final String approverPhone;
  final String approverEmail;
  final String approvalDate;
  final String approvalTime;
  final String totalFormatted;

  const CrmDealRequestModel({
    required this.id,
    required this.no,
    required this.quoteNo,
    this.version = 'V1',
    this.status = CrmRequestStatus.approved,
    this.productsCategory = '',
    this.products = '',
    this.quantity = '',
    this.productDiscount = '',
    this.productTax = '',
    this.productTotal = '',
    this.servicesCategory = '',
    this.services = '',
    this.serviceDiscount = '',
    this.serviceTax = '',
    this.serviceTotal = '',
    this.createdDate = '7/7/2026',
    this.validUntil = '7/12/2026',
    this.paymentTerms = '',
    this.deliveryTerms = '',
    this.note = 'Description',
    this.noteAr = 'اكتب هنا',
    this.approverName = 'Amro Handousa',
    this.approverRole = 'Engineer',
    this.approverDepartment = 'IT',
    this.approverPhone = '011587964555',
    this.approverEmail = 'Amr@gmail.com',
    this.approvalDate = '7/7/2026',
    this.approvalTime = '11:30 am',
    this.totalFormatted = '\$500',
  });

  CrmDealRequestModel copyWith({
    String? id,
    int? no,
    String? quoteNo,
    String? version,
    CrmRequestStatus? status,
    String? productsCategory,
    String? products,
    String? quantity,
    String? productDiscount,
    String? productTax,
    String? productTotal,
    String? servicesCategory,
    String? services,
    String? serviceDiscount,
    String? serviceTax,
    String? serviceTotal,
    String? createdDate,
    String? validUntil,
    String? paymentTerms,
    String? deliveryTerms,
    String? note,
    String? noteAr,
    String? approverName,
    String? approverRole,
    String? approverDepartment,
    String? approverPhone,
    String? approverEmail,
    String? approvalDate,
    String? approvalTime,
    String? totalFormatted,
  }) {
    return CrmDealRequestModel(
      id: id ?? this.id,
      no: no ?? this.no,
      quoteNo: quoteNo ?? this.quoteNo,
      version: version ?? this.version,
      status: status ?? this.status,
      productsCategory: productsCategory ?? this.productsCategory,
      products: products ?? this.products,
      quantity: quantity ?? this.quantity,
      productDiscount: productDiscount ?? this.productDiscount,
      productTax: productTax ?? this.productTax,
      productTotal: productTotal ?? this.productTotal,
      servicesCategory: servicesCategory ?? this.servicesCategory,
      services: services ?? this.services,
      serviceDiscount: serviceDiscount ?? this.serviceDiscount,
      serviceTax: serviceTax ?? this.serviceTax,
      serviceTotal: serviceTotal ?? this.serviceTotal,
      createdDate: createdDate ?? this.createdDate,
      validUntil: validUntil ?? this.validUntil,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      deliveryTerms: deliveryTerms ?? this.deliveryTerms,
      note: note ?? this.note,
      noteAr: noteAr ?? this.noteAr,
      approverName: approverName ?? this.approverName,
      approverRole: approverRole ?? this.approverRole,
      approverDepartment: approverDepartment ?? this.approverDepartment,
      approverPhone: approverPhone ?? this.approverPhone,
      approverEmail: approverEmail ?? this.approverEmail,
      approvalDate: approvalDate ?? this.approvalDate,
      approvalTime: approvalTime ?? this.approvalTime,
      totalFormatted: totalFormatted ?? this.totalFormatted,
    );
  }
}
