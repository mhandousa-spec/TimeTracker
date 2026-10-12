// ****************** FILE INFO ******************
// File Name: crm_client_deal_model.dart
// Purpose: Data model representing a CRM Client Deal for Table & Kanban views
// Author: Mohand Adel
// Created At: 29/08/2026

class CrmClientDealModel {
  final String id;
  final int no;
  final String category;
  final String dealNameEn;
  final String dealNameAr;
  final double expectedValue;
  final String expectedValueFormatted;
  final String
      stage; // new, discovery, qualified, proposal, negotiation, closedLost, closedWon
  final String stageLabelEn;
  final String stageLabelAr;
  final String noteEn;
  final String noteAr;
  final String likelihood;
  final double likelihoodValue;
  final bool isPositiveTrend;
  final String assignedEmployee;
  final String department;
  final String manager;
  final String startDate;
  final String closeDate;
  final String lastActivity;
  final double progress;
  final double amount;
  final List<CrmDealProductItem> products;
  final List<CrmDealServiceItem> services;
  final DateTime createdAt;

  const CrmClientDealModel({
    required this.id,
    required this.no,
    required this.category,
    required this.dealNameEn,
    required this.dealNameAr,
    required this.expectedValue,
    required this.expectedValueFormatted,
    required this.stage,
    required this.stageLabelEn,
    required this.stageLabelAr,
    this.noteEn = '',
    this.noteAr = '',
    this.likelihood = '10%',
    this.likelihoodValue = 10,
    this.isPositiveTrend = false,
    required this.assignedEmployee,
    this.department = 'Department',
    this.manager = 'Manager Name',
    required this.startDate,
    required this.closeDate,
    this.lastActivity = 'Today',
    this.progress = 5,
    this.amount = 300,
    this.products = const [],
    this.services = const [],
    required this.createdAt,
  });

  CrmClientDealModel copyWith({
    String? id,
    int? no,
    String? category,
    String? dealNameEn,
    String? dealNameAr,
    double? expectedValue,
    String? expectedValueFormatted,
    String? stage,
    String? stageLabelEn,
    String? stageLabelAr,
    String? noteEn,
    String? noteAr,
    String? likelihood,
    double? likelihoodValue,
    bool? isPositiveTrend,
    String? assignedEmployee,
    String? department,
    String? manager,
    String? startDate,
    String? closeDate,
    String? lastActivity,
    double? progress,
    double? amount,
    List<CrmDealProductItem>? products,
    List<CrmDealServiceItem>? services,
    DateTime? createdAt,
  }) {
    return CrmClientDealModel(
      id: id ?? this.id,
      no: no ?? this.no,
      category: category ?? this.category,
      dealNameEn: dealNameEn ?? this.dealNameEn,
      dealNameAr: dealNameAr ?? this.dealNameAr,
      expectedValue: expectedValue ?? this.expectedValue,
      expectedValueFormatted:
          expectedValueFormatted ?? this.expectedValueFormatted,
      stage: stage ?? this.stage,
      stageLabelEn: stageLabelEn ?? this.stageLabelEn,
      stageLabelAr: stageLabelAr ?? this.stageLabelAr,
      noteEn: noteEn ?? this.noteEn,
      noteAr: noteAr ?? this.noteAr,
      likelihood: likelihood ?? this.likelihood,
      likelihoodValue: likelihoodValue ?? this.likelihoodValue,
      isPositiveTrend: isPositiveTrend ?? this.isPositiveTrend,
      assignedEmployee: assignedEmployee ?? this.assignedEmployee,
      department: department ?? this.department,
      manager: manager ?? this.manager,
      startDate: startDate ?? this.startDate,
      closeDate: closeDate ?? this.closeDate,
      lastActivity: lastActivity ?? this.lastActivity,
      progress: progress ?? this.progress,
      amount: amount ?? this.amount,
      products: products ?? this.products,
      services: services ?? this.services,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CrmClientDealModel.getEmptyModel() {
    return CrmClientDealModel(
      id: '1',
      no: 1,
      category: 'Software',
      dealNameEn: 'ERP System Deal',
      dealNameAr: 'صفقة نظام تخطيط الموارد',
      expectedValue: 1000,
      expectedValueFormatted: '\$1,000',
      stage: 'proposal',
      stageLabelEn: 'Proposal',
      stageLabelAr: 'عرض السعر',
      assignedEmployee: 'Amro Handousa',
      startDate: '7 Jun 2026',
      closeDate: '7 Jul 2026',
      createdAt: DateTime(2026, 6, 7),
    );
  }
}

class CrmDealProductItem {
  final String productName;
  final String category;
  final int qty;
  final double price;
  final double discount;
  final double tax;
  final double total;

  const CrmDealProductItem({
    required this.productName,
    required this.category,
    required this.qty,
    required this.price,
    required this.discount,
    required this.tax,
    required this.total,
  });
}

class CrmDealServiceItem {
  final String serviceName;
  final String category;
  final double price;
  final double discount;
  final double tax;
  final double total;

  const CrmDealServiceItem({
    required this.serviceName,
    required this.category,
    required this.price,
    required this.discount,
    required this.tax,
    required this.total,
  });
}
