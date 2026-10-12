/// Module: Policy Management
/// Description: Defines the Policy Entity used by the app's UI/business
///              logic layer. Holds the latest (current) values of a Policy
///              record as plain single fields.
/// Author: Mohamed Elrashidy
/// Date: 2025-01-15
/// Dependencies: PolicyStatus
/// Revision History: 2025-01-15 - Initial creation
///                   2026-07-06 - Added PolicyStatus field (Mohamed Elrashidy)
///                   2026-07-14 - Migrated to the new schema: Controls moved
///                                out into their own subcollection (removed
///                                the [controls] field), split
///                                policyDocument into En/Ar, renamed image
///                                to policyImage, and removed isDeleted in
///                                favor of PolicyStatus.removed
///                                (Mohamed Elrashidy)

import 'policy_status.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_entity.dart
/// Purpose: Contains the PolicyEntity class, a flat (non-list)
///          representation of a Policy record derived from the latest index
///          of the PolicyModel. This is what the Presentation and Domain
///          layers consume directly. Controls are no longer nested here -
///          they live in their own Controls subcollection under the Policy
///          document and are fetched separately.
/// Author: Mohamed Elrashidy
/// Created At: 15/1/2025

/// class name: [PolicyEntity]
///
/// purpose: holds the current (latest) values of a Policy record as plain
///          single fields.
///
/// authors: Mohamed Elrashidy
///
/// created at: 15/1/2025
class PolicyEntity {
  final String id;
  final String moduleId;
  final String? policyImage;
  final String policyNameEn;
  final String policyNameAr;
  final String policyNumberEn;
  final String policyNumberAr;
  final String policyDescriptionEn;
  final String policyDescriptionAr;
  final DateTime startDate;
  final DateTime endDate;
  final double policyWeight;
  final String? policyDocumentEn;
  final String? policyDocumentAr;
  final PolicyStatus status;
  final double score;

  // Tracking fields (latest values only)
  final DateTime lastModifiedDate;
  final String lastEditor;

  /// When this policy was first saved.
  ///
  /// Not a new stored field: PolicyModel keeps every field as a revision
  /// history list, so revision 0's modification date IS the creation date --
  /// `lastModifiedDate.first` where [lastModifiedDate] here is `.last`. The
  /// policy list card draws it ("Creation Date" in the design) and it had no
  /// source on the entity before.
  final DateTime createdAt;

  const PolicyEntity({
    required this.id,
    required this.moduleId,
    required this.policyImage,
    required this.policyNameEn,
    required this.policyNameAr,
    required this.policyNumberEn,
    required this.policyNumberAr,
    required this.policyDescriptionEn,
    required this.policyDescriptionAr,
    required this.startDate,
    required this.endDate,
    required this.policyWeight,
    required this.policyDocumentEn,
    required this.policyDocumentAr,
    required this.status,
    required this.score,
    required this.lastModifiedDate,
    required this.lastEditor,
    required this.createdAt,
  });

  /// The policy name in the caller's language. Extracted so
  /// `context.isArabic ? policyNameAr : policyNameEn` doesn't get repeated
  /// across presentation files (mirrors [GRCModuleEntity.localizedName]).
  String localizedName({required bool isArabic}) =>
      isArabic ? policyNameAr : policyNameEn;

  /// function name: [copyWith]
  ///
  /// purpose: create a new [PolicyEntity] with selected fields replaced
  ///          by new values, keeping all other fields unchanged.
  ///
  /// parameters:
  ///            [String] policyImage: new image url/path, if changed
  ///            [String] policyNameEn: new English policy name, if changed
  ///            [String] policyNameAr: new Arabic policy name, if changed
  ///            [String] policyNumberEn: new English policy number, if changed
  ///            [String] policyNumberAr: new Arabic policy number, if changed
  ///            [String] policyDescriptionEn: new English description, if changed
  ///            [String] policyDescriptionAr: new Arabic description, if changed
  ///            [DateTime] startDate: new start date, if changed
  ///            [DateTime] endDate: new end date, if changed
  ///            [double] policyWeight: new weight value, if changed
  ///            [String] policyDocumentEn: new English document url/path, if changed
  ///            [String] policyDocumentAr: new Arabic document url/path, if changed
  ///            [PolicyStatus] status: new status, if changed
  ///
  /// return type: [PolicyEntity] - the updated entity instance
  PolicyEntity copyWith({
    String? policyImage,
    String? policyNameEn,
    String? policyNameAr,
    String? policyNumberEn,
    String? policyNumberAr,
    String? policyDescriptionEn,
    String? policyDescriptionAr,
    DateTime? startDate,
    DateTime? endDate,
    double? policyWeight,
    String? policyDocumentEn,
    String? policyDocumentAr,
    PolicyStatus? status,
    double? score,
  }) {
    return PolicyEntity(
      id: id,
      moduleId: moduleId,
      policyImage: policyImage ?? this.policyImage,
      policyNameEn: policyNameEn ?? this.policyNameEn,
      policyNameAr: policyNameAr ?? this.policyNameAr,
      policyNumberEn: policyNumberEn ?? this.policyNumberEn,
      policyNumberAr: policyNumberAr ?? this.policyNumberAr,
      policyDescriptionEn: policyDescriptionEn ?? this.policyDescriptionEn,
      policyDescriptionAr: policyDescriptionAr ?? this.policyDescriptionAr,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      policyWeight: policyWeight ?? this.policyWeight,
      policyDocumentEn: policyDocumentEn ?? this.policyDocumentEn,
      policyDocumentAr: policyDocumentAr ?? this.policyDocumentAr,
      status: status ?? this.status,
      score: score ?? this.score,
      lastModifiedDate: lastModifiedDate,
      lastEditor: lastEditor,
      createdAt: createdAt,
    );
  }
}