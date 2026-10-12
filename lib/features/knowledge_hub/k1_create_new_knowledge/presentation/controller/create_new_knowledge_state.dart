/// Module: knowledge_hub / presentation / cubit / create_new_knowledge_state.dart
/// ************************* FILE INFO *************************** ///
/// File Name: create_new_knowledge_state.dart
/// Purpose: Contains all the states of create new knowledge screen.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'dart:io';

import 'package:flutter/material.dart';

abstract class CreatingKnowledgeState {}

class CreatingKnowledgeInitial extends CreatingKnowledgeState {}

class CreatingKnowledgeLoading extends CreatingKnowledgeState {}

class CreatingKnowledgeSuccess extends CreatingKnowledgeState {
  final String message;
  CreatingKnowledgeSuccess(this.message);
}

class CreatingKnowledgeError extends CreatingKnowledgeState {
  final String message;
  CreatingKnowledgeError(this.message);
}

class ImagePickedSuccess extends CreatingKnowledgeState {
  final File imageFile;
  ImagePickedSuccess(this.imageFile);
}

class DocumentPickedSuccess extends CreatingKnowledgeState {
  final File documentFile;
  final String fileName;
  final String extension;
  final String icon;
  final int size;
  final DateTime uploadedDate;
  DocumentPickedSuccess({
    required this.documentFile,
    required this.fileName,
    required this.extension,
    required this.icon,
    required this.size,
    required this.uploadedDate,
  });
}

class DropdownChanged extends CreatingKnowledgeState {
  final String newText;
  DropdownChanged(this.newText);
}

class LimitDepartmentAvailabilityToggled extends CreatingKnowledgeState {
  final bool value;
  LimitDepartmentAvailabilityToggled(this.value);
}

class DepartmentSelected extends CreatingKnowledgeState {
  final Map<String, bool> departmentSelections;
  DepartmentSelected(this.departmentSelections);
}

class SchedulePublishingToggled extends CreatingKnowledgeState {
  final bool value;
  SchedulePublishingToggled(this.value);
}

class StartDateSelected extends CreatingKnowledgeState {
  final DateTime? date;
  StartDateSelected(this.date);
}

class StartTimeSelected extends CreatingKnowledgeState {
  final TimeOfDay? time;
  StartTimeSelected(this.time);
}

class EndDateSelected extends CreatingKnowledgeState {
  final DateTime? date;
  EndDateSelected(this.date);
}

class EndTimeSelected extends CreatingKnowledgeState {
  final TimeOfDay? time;
  EndTimeSelected(this.time);
}

class EnglishCharCountUpdated extends CreatingKnowledgeState {
  final int count;
  EnglishCharCountUpdated(this.count);
}

class ArabicCharCountUpdated extends CreatingKnowledgeState {
  final int count;
  ArabicCharCountUpdated(this.count);
}

class KnowledgeFormValidationFailed extends CreatingKnowledgeState {
  final String message;
  KnowledgeFormValidationFailed(this.message);
}

class ShowConfirmationDialog extends CreatingKnowledgeState {
  ShowConfirmationDialog();
}