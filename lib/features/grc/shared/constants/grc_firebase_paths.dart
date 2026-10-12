/// Module: grc/shared/constants
///
///*************************** FILE INFO ****************************///
/// File Name: grc_firebase_paths.dart
/// Purpose: Single source of truth for every GRC Firestore / Storage path.
/// Created at: 24/9/2026
///
/// All GRC data lives under the module root `Demo/{companyId}/Modules/grc`.
/// Before 24/9/2026 the module collection was the tenant-level `Demo/{id}/grc`
/// and the Storage folders (`GRC_Modules_Images`, `Policies_Files`,
/// `Assignment_Controls_Files`) sat at the bucket root, shared by all companies.
library;

import 'package:knowticed_plus/core/network/get_base_url.dart';

abstract final class GrcFirebasePaths {
  const GrcFirebasePaths._();

  /// Relative module root (use with getBaseUrl).
  static const String moduleBase = 'Modules/grc';

  /// Firestore collection holding one document per GRC module:
  /// `Demo/{companyId}/Modules/grc/GRC_Modules`.
  /// Policies, Controls, Champions, Owners, Requests, Approvals, My Audit and
  /// the inquiry threads are sub-collections of these documents.
  static String get modulesCollection => getBaseUrl('$moduleBase/GRC_Modules');

  // ── Cloud Storage folders ────────────────────────────────────────────
  /// `Demo/{companyId}/Modules/grc/GRC_Modules_Images`
  static String get moduleImagesFolder =>
      getBaseUrl('$moduleBase/GRC_Modules_Images');

  /// `Demo/{companyId}/Modules/grc/Policies_Files`
  static String get policiesFilesFolder =>
      getBaseUrl('$moduleBase/Policies_Files');

  /// `Demo/{companyId}/Modules/grc/Assignment_Controls_Files`
  static String get assignmentControlsFilesFolder =>
      getBaseUrl('$moduleBase/Assignment_Controls_Files');
}
