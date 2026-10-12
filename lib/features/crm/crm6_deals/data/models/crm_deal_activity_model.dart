// ****************** FILE INFO ******************
// File Name: crm_deal_activity_model.dart
// Purpose: Deal Activity entity model supporting grid and table views and creation forms matching Figma screenshots
// Author: Mohand Adel
// Created At: 29/08/2026

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';

enum CrmDealActivityStatus {
  all,
  scheduled,
  inProgress,
  completed,
  cancelled;

  String get labelEn {
    switch (this) {
      case CrmDealActivityStatus.all:
        return 'All';
      case CrmDealActivityStatus.scheduled:
        return 'Scheduled';
      case CrmDealActivityStatus.inProgress:
        return 'In Progress';
      case CrmDealActivityStatus.completed:
        return 'Completed';
      case CrmDealActivityStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get badgeLabel {
    switch (this) {
      case CrmDealActivityStatus.all:
        return 'All';
      case CrmDealActivityStatus.scheduled:
        return 'Schedules';
      case CrmDealActivityStatus.inProgress:
        return 'In Progress';
      case CrmDealActivityStatus.completed:
        return 'Completed';
      case CrmDealActivityStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get labelAr {
    switch (this) {
      case CrmDealActivityStatus.all:
        return 'الكل';
      case CrmDealActivityStatus.scheduled:
        return 'مجدول';
      case CrmDealActivityStatus.inProgress:
        return 'قيد التنفيذ';
      case CrmDealActivityStatus.completed:
        return 'مكتمل';
      case CrmDealActivityStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case CrmDealActivityStatus.all:
        return AppColors.primary;
      case CrmDealActivityStatus.scheduled:
        return const Color(0xFF2563EB); // Blue
      case CrmDealActivityStatus.inProgress:
        return const Color(0xFFFF7A00); // Orange
      case CrmDealActivityStatus.completed:
        return const Color(0xFF16A34A); // Green
      case CrmDealActivityStatus.cancelled:
        return const Color(0xFF6B7280); // Grey
    }
  }
}

class CrmDealActivityModel {
  final String id;
  final int no;
  final String dealId;
  final String categoryName;
  final String activityType;
  final String subjectEn;
  final String subjectAr;
  final String assigneeName;
  final String assigneeRole;
  final String dueDate;
  final String time;
  final String tags;
  final CrmDealActivityStatus status;
  final String noteEn;
  final String noteAr;

  const CrmDealActivityModel({
    required this.id,
    required this.no,
    this.dealId = '1',
    this.categoryName = 'IT',
    this.activityType = 'Communication',
    this.subjectEn = 'Connect',
    this.subjectAr = 'الاتصال',
    this.assigneeName = 'Aya Ali',
    this.assigneeRole = 'CEO',
    this.dueDate = '7/12/2026',
    this.time = '11:30 am',
    this.tags = 'Deals',
    this.status = CrmDealActivityStatus.scheduled,
    this.noteEn = "it's ................",
    this.noteAr = 'إنه كذلك ................',
  });

  CrmDealActivityModel copyWith({
    String? id,
    int? no,
    String? dealId,
    String? categoryName,
    String? activityType,
    String? subjectEn,
    String? subjectAr,
    String? assigneeName,
    String? assigneeRole,
    String? dueDate,
    String? time,
    String? tags,
    CrmDealActivityStatus? status,
    String? noteEn,
    String? noteAr,
  }) {
    return CrmDealActivityModel(
      id: id ?? this.id,
      no: no ?? this.no,
      dealId: dealId ?? this.dealId,
      categoryName: categoryName ?? this.categoryName,
      activityType: activityType ?? this.activityType,
      subjectEn: subjectEn ?? this.subjectEn,
      subjectAr: subjectAr ?? this.subjectAr,
      assigneeName: assigneeName ?? this.assigneeName,
      assigneeRole: assigneeRole ?? this.assigneeRole,
      dueDate: dueDate ?? this.dueDate,
      time: time ?? this.time,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      noteEn: noteEn ?? this.noteEn,
      noteAr: noteAr ?? this.noteAr,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'no': no,
      'dealId': dealId,
      'categoryName': categoryName,
      'activityType': activityType,
      'subjectEn': subjectEn,
      'subjectAr': subjectAr,
      'assigneeName': assigneeName,
      'assigneeRole': assigneeRole,
      'dueDate': dueDate,
      'time': time,
      'tags': tags,
      'status': status.name,
      'noteEn': noteEn,
      'noteAr': noteAr,
    };
  }

  factory CrmDealActivityModel.fromMap(Map<String, dynamic> map) {
    return CrmDealActivityModel(
      id: map['id']?.toString() ?? '',
      no: (map['no'] as num?)?.toInt() ?? 1,
      dealId: map['dealId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? 'IT',
      activityType: map['activityType']?.toString() ?? 'Communication',
      subjectEn: map['subjectEn']?.toString() ?? 'Connect',
      subjectAr: map['subjectAr']?.toString() ?? 'الاتصال',
      assigneeName: map['assigneeName']?.toString() ?? 'Aya Ali',
      assigneeRole: map['assigneeRole']?.toString() ?? 'CEO',
      dueDate: map['dueDate']?.toString() ?? '7/12/2026',
      time: map['time']?.toString() ?? '11:30 am',
      tags: map['tags']?.toString() ?? 'Deals',
      status: CrmDealActivityStatus.values.firstWhere(
        (CrmDealActivityStatus s) => s.name == map['status'],
        orElse: () => CrmDealActivityStatus.scheduled,
      ),
      noteEn: map['noteEn']?.toString() ?? "it's ................",
      noteAr: map['noteAr']?.toString() ?? 'إنه كذلك ................',
    );
  }
}
