// ****************** FILE INFO ******************
// File Name: crm_duplicates_enums.dart
// Purpose: Domain enums for CRM Duplicates Review & Merge module
// Author: Mohand Adel
// Created At: 27/08/2026

enum CrmMergeStep {
  selectDuplicates, // Step 1
  compareAndMerge, // Step 2
  reviewAndConfirm, // Step 3
  completed, // Step 4
}

enum CrmDuplicateMatchLevel {
  exact, // 95-100%
  high, // 80-94%
  medium, // 60-79%
}

enum CrmDuplicateStatus {
  pending,
  merged,
  ignored,
}

enum CrmDuplicatesTab {
  duplicate,
  merge,
}
