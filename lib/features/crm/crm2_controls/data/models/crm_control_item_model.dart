// ****************** FILE INFO ******************
// File Name: crm_control_item_model.dart
// Purpose: Data model representing a Control page menu item card in CRM
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';

class CrmControlItemModel {
  final String title;
  final String description;
  final String svgAsset;
  final VoidCallback? onTap;

  const CrmControlItemModel({
    required this.title,
    required this.description,
    required this.svgAsset,
    this.onTap,
  });
}
