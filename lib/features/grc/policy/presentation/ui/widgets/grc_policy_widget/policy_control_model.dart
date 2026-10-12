/// Module: GRC Policy Management
/// Description: Data model for a single policy control entry.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-01
/// Dependencies: Flutter SDK
/// Revision History: 2026-07-01 - Initial creation
///                   2026-07-14 - Split single `document` into `documentEn`/`documentAr`
///                   2026-07-14 - Added Control Number (EN/AR) controllers
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_control_model.dart
/// Purpose: Contains PolicyControlModel, the model holding text controllers
///          and state for a single control card in the controls list.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 1/7/2026

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';

class PolicyControlModel {
  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController numberController;
  final TextEditingController numberArController;
  final TextEditingController descriptionController;
  final TextEditingController descriptionArController;
  final TextEditingController weightController;

  String? frequency;
  DateTime? startDate;
  DateTime? endDate;
  PolicyDocumentInfo? documentEn;
  PolicyDocumentInfo? documentAr;

  /// Non-null when this card was prefilled from an already-saved Control
  /// (resuming a Draft) — a later Save For Later/Publish updates that same
  /// Control instead of creating a duplicate.
  final String? existingControlId;

  PolicyControlModel({
    TextEditingController? nameController,
    TextEditingController? nameArController,
    TextEditingController? numberController,
    TextEditingController? numberArController,
    TextEditingController? descriptionController,
    TextEditingController? descriptionArController,
    TextEditingController? weightController,
    this.frequency,
    this.startDate,
    this.endDate,
    this.documentEn,
    this.documentAr,
    this.existingControlId,
  })  : nameController = nameController ?? TextEditingController(),
        nameArController = nameArController ?? TextEditingController(),
        numberController = numberController ?? TextEditingController(),
        numberArController = numberArController ?? TextEditingController(),
        descriptionController =
            descriptionController ?? TextEditingController(),
        descriptionArController =
            descriptionArController ?? TextEditingController(),
        weightController = weightController ?? TextEditingController();

  void dispose() {
    nameController.dispose();
    nameArController.dispose();
    numberController.dispose();
    numberArController.dispose();
    descriptionController.dispose();
    descriptionArController.dispose();
    weightController.dispose();
  }
}
