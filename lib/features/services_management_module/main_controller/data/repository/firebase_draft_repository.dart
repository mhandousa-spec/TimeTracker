/// Module: services_management_module
/// Description: Repository for saving/loading drafts from Firebase. Drafts
///              are saved in the MAIN CreateServices collection with
///              status="draft".
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: cloud_firestore, core/network/get_base_url.dart,
///               core/network/api_constants.dart
/// Revision History: A repository must not depend on a GetX UI controller.
///                    [employeeEmail] is now an optional constructor param —
///                    callers that already know the current user (cubits)
///                    should pass it in. When omitted, the repository falls
///                    back to reading MainCoreEmployeeController via Get.find
///                    so the existing zero-arg `FirebaseDraftRepository()`
///                    call sites (ServiceDraftManager, module-root — not
///                    modified here) keep working unchanged (audit fix #4c).
import 'package:get/get.dart';

import 'dart:convert';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';

class FirebaseDraftRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// The current user's email, injected by the caller. When null, falls
  /// back to AppControllers.employee for backwards
  /// compatibility with existing call sites that don't inject it yet.
  final String? employeeEmail;

  FirebaseDraftRepository({this.employeeEmail});

  // Page identifiers
  static const int pageCreateService = 1;      // CreateNewServicesLayout
  static const int pageSelectProvider = 2;     // ServicesProviderLayout
  static const int pageDetailsApproval = 3;    // DetailsToggleScreen
  static const int pageSlaNotification = 4;    // ToggleSlaScreen

  /// Get current user email — prefers the injected [employeeEmail]; falls
  /// back to Get.find only when the caller didn't inject one (audit fix #4c).
  String get _currentUserEmail {
    if (employeeEmail != null && employeeEmail!.isNotEmpty) {
      return employeeEmail!;
    }
    try {
      final controller = AppControllers.employee;
      return controller.employeeEntity?.email ?? '';
    } catch (e) {
      return '';
    }
  }

  /// 🔥 Get the main CreateServices collection path
  String get _createServicesPath {
    return getBaseUrl(FirestoreCollections.createServicesRoot);
  }

  /// Save draft to MAIN CreateServices collection with draft status
  Future<String> saveDraft({
    required ServicesHistoryModel model,
    required int currentPage,
    String? existingDraftId,
  }) async {
    try {
      final userEmail = _currentUserEmail;
      if (userEmail.isEmpty) {
        throw Exception('User not authenticated');
      }

      // ✅ CRITICAL FIX: Check if we should update existing or create new
      String draftId;
      bool isUpdate = false;
      Map<String, dynamic>? existingData;

      if (existingDraftId != null && existingDraftId.isNotEmpty) {
        // Check if document actually exists
        final existingDoc = await _firestore
            .collection(_createServicesPath)
            .doc(existingDraftId)
            .get();

        if (existingDoc.exists) {
          draftId = existingDraftId;
          isUpdate = true;
          existingData = existingDoc.data();
        } else {
          // Document doesn't exist, create new
          draftId = 'draft_${DateTime.now().millisecondsSinceEpoch}_$userEmail';
          isUpdate = false;
        }
      } else {
        // No existing ID, create new
        draftId = 'draft_${DateTime.now().millisecondsSinceEpoch}_$userEmail';
        isUpdate = false;
      }

      // Build draft data
      final modelJson = model.toJsonForCreate();
      final cleanedJson = _cleanEmptyValues(modelJson);

      // ✅ FIX (draft bug #1 — service came back INACTIVE after completing a
      // draft): the draft document overwrites `status` with the literal
      // 'draft', which is a *lifecycle* marker, not an availability status.
      // When the draft was reopened, the create form read that 'draft' back,
      // decided `isActive = ('draft' == 'active') == false`, and the final
      // save then persisted the service as inactive.
      //
      // Keep the user's intended availability ('active' / 'inactive') in the
      // draft metadata so it survives the round-trip.
      final intendedStatus = _resolveIntendedStatus(
        model.currentStatus,
        existingData,
      );

      final draftData = {
        ...cleanedJson,

        // Draft metadata
        'draftMetadata': {
          'draftId': draftId,
          'createdAt': isUpdate
              ? existingData?['draftMetadata']?['createdAt']
              ?? FieldValue.serverTimestamp()
              : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdBy': userEmail,
          'currentPage': currentPage,
          'isDraft': true,
          'draftState': 'in_progress',
          // ✅ The availability the service should get once it goes live.
          'intendedStatus': intendedStatus,
        },

        // Override status and state to be draft
        'status': ['draft'],
        'state': ['draft'],

        // ✅ FIX ("saving for later without choosing a provider still shows one
        // selected"): an EMPTY selection has to be written, not omitted.
        //
        // toJsonForCreate() drops Provider_Services when the latest revision is
        // empty or '[]', and _cleanEmptyValues() drops it again for good
        // measure. Since drafts are written with update()/set(merge: true), a
        // missing key means "leave the existing value alone" — so deselecting
        // every provider and saving kept whatever was on the document, and the
        // draft reopened with a provider already ticked that nobody had chosen.
        //
        // Writing the empty marker explicitly makes "no provider" a real,
        // persisted state.
        ...ServicesHistoryModel.emptyableSelectionJson(model),

        // ✅ Ensure ID is set in the data too
        'id': [draftId],
      };

      if (isUpdate) {
        // ✅ UPDATE existing document
        await _firestore
            .collection(_createServicesPath)
            .doc(draftId)
            .update(draftData);
      } else {
        // ✅ CREATE new document
        await _firestore
            .collection(_createServicesPath)
            .doc(draftId)
            .set(draftData, SetOptions(merge: true));
      }

      return draftId;

    } catch (e, stackTrace) {
      rethrow;
    }
  }

  /// Resolves the availability status a draft should be published with.
  ///
  /// Order: the status carried by the model → the one already recorded on the
  /// draft → 'active'. Anything that is not a real availability value (most
  /// notably the 'draft' lifecycle marker itself, or an empty string) is
  /// ignored so it can never be mistaken for "inactive".
  String _resolveIntendedStatus(
    String? modelStatus,
    Map<String, dynamic>? existingData,
  ) {
    final fromModel = _normalizeAvailability(modelStatus);
    if (fromModel != null) return fromModel;

    final fromDoc = _normalizeAvailability(
      existingData?['draftMetadata']?['intendedStatus'] as String?,
    );
    if (fromDoc != null) return fromDoc;

    return 'active';
  }

  /// Returns 'active' / 'inactive' for real availability values, null for
  /// anything else ('draft', '', null, unknown values).
  String? _normalizeAvailability(String? raw) {
    final value = (raw ?? '').trim().toLowerCase();
    if (value == 'active' || value == 'inactive') return value;
    return null;
  }

  /// 🔥 NEW: Helper to clean empty/placeholder values from JSON
  Map<String, dynamic> _cleanEmptyValues(Map<String, dynamic> json) {
    final cleaned = <String, dynamic>{};

    json.forEach((key, value) {
      if (value == null) return; // Skip nulls

      if (value is List) {
        // Skip empty lists
        if (value.isEmpty) return;

        // Skip lists containing only empty strings
        if (value.every((item) => item == null || item == '' || item == '[]' || item == '""')) {
          return;
        }

        // For lists with actual values, keep them
        cleaned[key] = value;
      } else if (value is String) {
        // Skip empty strings
        if (value.isEmpty || value == '[]' || value == '""') return;
        cleaned[key] = value;
      } else if (value is Map) {
        // Recursively clean nested maps
        final cleanedMap = _cleanEmptyValues(Map<String, dynamic>.from(value));
        if (cleanedMap.isNotEmpty) {
          cleaned[key] = cleanedMap;
        }
      } else {
        // Keep other types (numbers, booleans, timestamps)
        cleaned[key] = value;
      }
    });

    return cleaned;
  }

  /// Update existing draft with new page progress
  Future<void> updateDraftPage({
    required String draftId,
    required int currentPage,
    required ServicesHistoryModel updatedModel,
  }) async {
    try {
      final userEmail = _currentUserEmail;

      final path = _createServicesPath;

      // ✅ FIX (draft bug #1): keep the intended availability in step with the
      // model, and never let the 'draft' marker overwrite it.
      final existingData =
          (await _firestore.collection(path).doc(draftId).get()).data();
      final intendedStatus = _resolveIntendedStatus(
        updatedModel.currentStatus,
        existingData,
      );

      final updateData = {
        ...updatedModel.toJson(),
        'draftMetadata.updatedAt': FieldValue.serverTimestamp(),
        'draftMetadata.currentPage': currentPage,
        'draftMetadata.intendedStatus': intendedStatus,
        // Ensure it stays as draft
        'status': ['draft'],
        'state': ['draft'],
        // ✅ Same reason as in saveDraft: an empty provider / approver /
        // department selection must be written, or update() silently keeps the
        // previous one and it looks like a default selection.
        ...ServicesHistoryModel.emptyableSelectionJson(updatedModel),
      };

      await _firestore
          .collection(path)
          .doc(draftId)
          .update(updateData);

    } catch (e) {
      rethrow;
    }
  }

  /// Get all drafts for current user from CreateServices collection
  /// Get all drafts for current user from CreateServices collection
  Future<List<ServicesHistoryModel>> getUserDrafts() async {
    try {
      final userEmail = _currentUserEmail;
      if (userEmail.isEmpty) {
        return [];
      }

      final path = _createServicesPath;

      QuerySnapshot<Map<String, dynamic>> snapshot;

      try {
        // Query for documents where status is draft AND created by this user
        // AND draftState is still in_progress
        snapshot = await _firestore
            .collection(path)
            .where('status', arrayContains: 'draft')
            .where('draftMetadata.createdBy', isEqualTo: userEmail)
            .where('draftMetadata.draftState', isEqualTo: 'in_progress')
            .orderBy('draftMetadata.updatedAt', descending: true)
            .get();
      } catch (e) {
        // Fallback without orderBy
        snapshot = await _firestore
            .collection(path)
            .where('status', arrayContains: 'draft')
            .where('draftMetadata.createdBy', isEqualTo: userEmail)
            .where('draftMetadata.draftState', isEqualTo: 'in_progress')
            .get();
      }

      // ✅ ADDITIONAL FILTER: Double-check in memory to ensure no published drafts slip through
      final drafts = snapshot.docs
          .where((doc) {
        final data = doc.data();
        final draftState = data['draftMetadata']?['draftState'];
        final status = data['status'];

        // Extra safety: ensure it's still a draft
        bool isDraftStatus = false;
        if (status is List && status.isNotEmpty) {
          isDraftStatus = status.last == 'draft';
        } else if (status is String) {
          isDraftStatus = status == 'draft';
        }

        return draftState == 'in_progress' && isDraftStatus;
      })
          .map((doc) {
        final data = doc.data();
        final model = ServicesHistoryModel.fromJson(data, doc.id);
        return model;
      })
          .toList();

      return drafts;

    } catch (e, stackTrace) {
      return [];
    }
  }

  /// Get specific draft with page info
  Future<DraftWithPage?> getDraftWithPage(String draftId) async {
    try {
      final path = _createServicesPath;

      final doc = await _firestore
          .collection(path)
          .doc(draftId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;

      // Verify it's actually a draft
      final status = data['status'];
      bool isDraft = false;
      if (status is List && status.isNotEmpty) {
        isDraft = status.last == 'draft';
      } else if (status is String) {
        isDraft = status == 'draft';
      }

      if (!isDraft) {
        return null;
      }

      // ✅ CRITICAL: Ensure the ID is set in the data before parsing
      data['id'] = [draftId]; // Set the ID to the draft ID

      // Extract page from metadata
      final metadata = data['draftMetadata'] as Map<String, dynamic>?;
      final currentPage = metadata?['currentPage'] as int? ?? pageCreateService;

      // ✅ FIX (draft bug #1): hand the wizard the *intended* availability
      // instead of the 'draft' marker. `state` stays 'draft' — that is what
      // every draft check in the UI looks at — but `status` now carries a real
      // active/inactive value, so the create form no longer reads 'draft' and
      // silently seeds the status switch to OFF.
      data['status'] = [
        _resolveIntendedStatus(null, data),
      ];

      final model = ServicesHistoryModel.fromJson(data, doc.id);

      return DraftWithPage(
        model: model,
        currentPage: currentPage,
        draftId: draftId,
      );

    } catch (e) {
      return null;
    }
  }

  /// Mark draft as completed (when user finishes or cancels)
  Future<void> deleteDraft(String draftId) async {
    try {
      final path = _createServicesPath;

      // Instead of deleting, mark as completed
      // This keeps the history but removes from active drafts
      await _firestore
          .collection(path)
          .doc(draftId)
          .update({
        'draftMetadata.draftState': 'completed',
        'draftMetadata.completedAt': FieldValue.serverTimestamp(),
        // Optionally change status to inactive or keep as draft for history
        // 'status': ['inactive'],
      });

    } catch (e) {
    }
  }

  /// Permanently delete draft (rarely used)
  Future<void> permanentlyDeleteDraft(String draftId) async {
    try {
      final path = _createServicesPath;

      await _firestore
          .collection(path)
          .doc(draftId)
          .delete();

    } catch (e) {
    }
  }

  /// Publish draft - convert to active service
  /// Publish draft - convert to active service
  Future<String> publishDraft(
      String draftId,
      ServicesHistoryModel completeModel
      ) async {
    try {
      final path = _createServicesPath;

      // Generate new service ID if needed (optional - you can keep same ID)
      final now = DateTime.now();
      final formattedDate = "${_monthAbbreviation(now.month)}${now.day}_${now.year}";
      final randomId = now.millisecondsSinceEpoch % 100000;
      final newServiceId = "SRV$randomId$formattedDate";

      // Option 1: Update existing document to active status (keeps same ID)
      await _firestore
          .collection(path)
          .doc(draftId)
          .update({
        ...completeModel.toJsonForCreate(),
        'status': ['active'],
        'state': ['active'],
        'draftMetadata.draftState': 'published',
        'draftMetadata.publishedAt': FieldValue.serverTimestamp(),
        'draftMetadata.publishedServiceId': newServiceId, // Optional: track new ID
        'id': [newServiceId], // Update to new service ID
      });

      // Note: The cubit will handle clearing its draft tracking
      return draftId;

    } catch (e) {
      rethrow;
    }
  }

  /// Alternative: Publish by creating new document and deleting draft
  Future<String> publishDraftAsNew(
      String draftId,
      ServicesHistoryModel completeModel
      ) async {
    try {
      // Generate new service ID
      final now = DateTime.now();
      final formattedDate = "${_monthAbbreviation(now.month)}${now.day}_${now.year}";
      final randomId = now.millisecondsSinceEpoch % 100000;
      final serviceId = "User$randomId$formattedDate";

      final path = _createServicesPath;

      // Create new active service
      await _firestore
          .collection(path)
          .doc(serviceId)
          .set({
        ...completeModel.toJson(),
        'status': ['active'],
        'state': ['active'],
        'publishedAt': FieldValue.serverTimestamp(),
        'draftId': draftId,  // Reference to original draft
      });

      // Mark original draft as published
      await _firestore
          .collection(path)
          .doc(draftId)
          .update({
        'draftMetadata.draftState': 'published',
        'draftMetadata.publishedAt': FieldValue.serverTimestamp(),
        'draftMetadata.publishedServiceId': serviceId,
      });

      return serviceId;

    } catch (e) {
      rethrow;
    }
  }

  String _monthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

/// Helper class to return draft with page info
class DraftWithPage {
  final ServicesHistoryModel model;
  final int currentPage;
  final String draftId;

  DraftWithPage({
    required this.model,
    required this.currentPage,
    required this.draftId,
  });
}
