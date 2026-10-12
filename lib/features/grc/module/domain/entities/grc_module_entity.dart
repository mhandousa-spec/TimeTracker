/// Module: GRC Module Management
/// Description: Defines the Entity used by the app's UI/business logic layer.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-30
/// Dependencies: None
/// Revision History: 2026-06-30 - Initial creation
///                   2026-07-06 - Aligned field names and Firestore keys to the
///                                updated schema; replaced isDeleted with
///                                Status:"Removed"; Editors→Modifiers (email);
///                                added "Scheduled" status value
///                                (Mohamed Magdy Abdelkhalek)

/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_entity.dart
/// Purpose: Contains the GRCModuleEntity class, a flat (non-list) representation
///          of a GRC Module record, derived from the latest index of the Model.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 30/6/2026

import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';

/// class name: [GRCModuleEntity]
///
/// purpose: holds the current (latest) values of a GRC Module record as plain
///          single fields, ready to be consumed directly by the UI and the
///          business logic.
///
///          Soft-delete is no longer a separate [isDeleted] flag — it is now
///          expressed as [status] == "Removed". Use [isRemoved] getter to check.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 30/6/2026
class GRCModuleEntity {
  final String moduleId;
  final String? moduleImage;
  final String moduleNameEn;
  final String moduleNameAr;
  final String moduleDescriptionEn;
  final String moduleDescriptionAr;
  final String moduleOwningDepartment;
  final DateTime moduleActivationDate;

  /// Latest owners snapshot (list of user ids).
  final List<String> moduleOwners;

  /// One of: "Active" | "Inactive" | "Scheduled" | "Removed".
  /// "Removed" replaces the old isDeleted flag.
  final String status;

  final double score;

  // Tracking fields (latest values only)
  final DateTime createdAt;
  final DateTime modificationDate;

  /// Email of the last user who modified this record.
  final String lastModifier;

  const GRCModuleEntity({
    required this.moduleId,
    required this.moduleImage,
    required this.moduleNameEn,
    required this.moduleNameAr,
    required this.moduleDescriptionEn,
    required this.moduleDescriptionAr,
    required this.moduleOwningDepartment,
    required this.moduleActivationDate,
    required this.moduleOwners,
    required this.status,
    required this.score,
    required this.createdAt,
    required this.modificationDate,
    required this.lastModifier,
  });

  /// Convenience getter — true when this module has been soft-deleted.
  bool get isRemoved => status == GrcModuleStatus.removed.value;

  /// The module name in the caller's language. Extracted because
  /// `context.isArabic ? moduleNameAr : moduleNameEn` was repeated in 3
  /// presentation files instead of living once on the entity.
  String localizedName({required bool isArabic}) =>
      isArabic ? moduleNameAr : moduleNameEn;

  /// function name: [copyWith]
  ///
  /// purpose: create a new [GRCModuleEntity] instance with selected fields
  ///          replaced by new values, keeping all other fields unchanged.
  ///
  /// parameters:
  ///            [String] moduleImage: new image url/path, if provided
  ///            [String] moduleNameEn: new English module name, if provided
  ///            [String] moduleNameAr: new Arabic module name, if provided
  ///            [String] moduleDescriptionEn: new English description, if provided
  ///            [String] moduleDescriptionAr: new Arabic description, if provided
  ///            [String] moduleOwningDepartment: new owning department, if provided
  ///            [DateTime] moduleActivationDate: new activation date, if provided
  ///            [List<String>] moduleOwners: new owners list, if provided
  ///            [String] status: new status ("Active" | "Inactive" | "Removed"), if provided
  ///
  /// return type: [GRCModuleEntity] - the updated entity instance
  GRCModuleEntity copyWith({
    String? moduleImage,
    String? moduleNameEn,
    String? moduleNameAr,
    String? moduleDescriptionEn,
    String? moduleDescriptionAr,
    String? moduleOwningDepartment,
    DateTime? moduleActivationDate,
    List<String>? moduleOwners,
    String? status,
    double? score,
  }) {
    return GRCModuleEntity(
      moduleId: moduleId,
      moduleImage: moduleImage ?? this.moduleImage,
      moduleNameEn: moduleNameEn ?? this.moduleNameEn,
      moduleNameAr: moduleNameAr ?? this.moduleNameAr,
      moduleDescriptionEn: moduleDescriptionEn ?? this.moduleDescriptionEn,
      moduleDescriptionAr: moduleDescriptionAr ?? this.moduleDescriptionAr,
      moduleOwningDepartment:
          moduleOwningDepartment ?? this.moduleOwningDepartment,
      moduleActivationDate: moduleActivationDate ?? this.moduleActivationDate,
      moduleOwners: moduleOwners ?? this.moduleOwners,
      status: status ?? this.status,
      score: score ?? this.score,
      createdAt: createdAt,
      modificationDate: modificationDate,
      lastModifier: lastModifier,
    );
  }
}