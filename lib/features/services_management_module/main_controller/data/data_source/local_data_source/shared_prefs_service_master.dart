// ******************* FILE INFO *******************
// File Name: shared_prefs_service_master
// Description: Local (SharedPreferences) data source for service drafts.
//              Reads the current user's email from the data-layer
//              CurrentUserContext instead of a presentation controller (R01).
// Module: services_management_module / data / helper
// *************************************************

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/helper/main_helper/current_user_context.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

class SharedPrefsServiceMaster {
  static const String _draftKey = 'draft_services';

  static Future<List<ServicesHistoryModel>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedDrafts = prefs.getStringList('draft_services_list') ?? [];

    final currentUserEmail = CurrentUserContext.email;

    return encodedDrafts.asMap().entries.map((entry) {
      final json = jsonDecode(entry.value) as Map<String, dynamic>;
      final docId = 'draft_${entry.key}';

      // Ensure emailRequester is set in the JSON before parsing
      if (json['emailRequester'] == null || json['emailRequester'].toString().isEmpty) {
        json['emailRequester'] = [currentUserEmail];
      }

      final model = ServicesHistoryModel.fromJson(json, docId);

      return model;
    }).toList();
  }

  static Future<void> saveAllDrafts(List<ServicesHistoryModel> drafts) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserEmail = CurrentUserContext.email;

    final encoded = drafts.map((e) {
      final json = e.toJson();

      // Explicitly ensure emailRequester is included
      final currentEmail = e.currentEmailRequester;
      if (currentEmail.isEmpty) {
        // Modify the JSON to include current user email
        json['emailRequester'] = [currentUserEmail ?? ''];
        json['timestamps'] = json['timestamps'] ?? [DateTime.now().millisecondsSinceEpoch];
      }

      // Ensure imageUrl is included if it exists
      final currentImageUrl = e.currentImageUrl;

      return jsonEncode(json);
    }).toList();

    await prefs.setStringList('draft_services_list', encoded);
  }

  static Future<void> removeDraftById(String id) async {
    final allDrafts = await getAllDrafts();
    allDrafts.removeWhere((model) => model.currentId == id);
    await saveAllDrafts(allDrafts);
  }

  static Future<void> saveDraft(ServicesHistoryModel model) async {
    try {
      final currentUserEmail = CurrentUserContext.email;

      // Generate unique ID if not present
      final currentId = model.currentId;
      final draftId = currentId.isEmpty
          ? 'draft_${DateTime.now().millisecondsSinceEpoch}'
          : currentId;

      // Ensure emailRequester is set
      final modelWithEmailAndId = model.copyWith(
        id: draftId,
        emailRequester: model.currentEmailRequester.isNotEmpty
            ? model.currentEmailRequester
            : currentUserEmail,
      );

      final drafts = await getAllDrafts();
      drafts.add(modelWithEmailAndId);
      await saveAllDrafts(drafts);

    } catch (e) {
      throw e;
    }
  }

  static Future<List<ServicesHistoryModel>> loadDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> drafts = prefs.getStringList('draft_services_list') ?? [];

    final currentUserEmail = CurrentUserContext.email;

    return drafts.asMap().entries.map((entry) {
      final index = entry.key;
      final jsonMap = jsonDecode(entry.value) as Map<String, dynamic>;

      // Ensure required fields are present
      jsonMap['providerServices'] ??= ['[]'];
      jsonMap['approvalCycle'] ??= ['[]'];
      jsonMap['selectDepartment'] ??= ['[]'];

      // Ensure emailRequester is set
      if (jsonMap['emailRequester'] == null || jsonMap['emailRequester'].toString().isEmpty) {
        jsonMap['emailRequester'] = [currentUserEmail];
      }

      final draftId = jsonMap['id'] ?? ['draft_$index'];

      final model = ServicesHistoryModel.fromJson(jsonMap, draftId.toString());

      return model;
    }).toList();
  }

  static Future<void> updateDraft(
      ServicesHistoryModel oldModel,
      ServicesHistoryModel newModel,
      ) async {
    try {
      final drafts = await getAllDrafts();

      final idx = drafts.indexWhere((e) => e.currentId == oldModel.currentId);

      final currentUserEmail = CurrentUserContext.email;

      final updatedModel = newModel.copyWith(
        id: oldModel.currentId,
        imageUrl: newModel.currentImageUrl.isNotEmpty
            ? newModel.currentImageUrl
            : oldModel.currentImageUrl,
        emailRequester: newModel.currentEmailRequester.isNotEmpty
            ? newModel.currentEmailRequester
            : (oldModel.currentEmailRequester.isNotEmpty
            ? oldModel.currentEmailRequester
            : currentUserEmail),
      );

      if (idx != -1) {
        drafts[idx] = updatedModel;
      } else {
        drafts.add(updatedModel);
      }

      await saveAllDrafts(drafts);
    } catch (e) {
      throw e;
    }
  }

  static Future<void> clearDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_services_list');
    await prefs.remove(_draftKey);
  }

  static Future<void> debugSavedDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getStringList('draft_services_list') ?? [];

      for (int i = 0; i < draftsJson.length; i++) {
        final json = jsonDecode(draftsJson[i]) as Map<String, dynamic>;

        // Helper to extract current value from list-based JSON
        String? extractCurrent(dynamic field) {
          if (field == null) return null;
          if (field is String) return field;
          if (field is List && field.isNotEmpty) {
            return field.last?.toString();
          }
          return null;
        }

      }
    } catch (e) {
    }
  }

  static Future<ServicesHistoryModel?> getDraftById(String id) async {
    try {
      final drafts = await getAllDrafts();
      final draft = drafts.firstWhere(
            (d) => d.currentId == id,
        orElse: () => throw StateError('Draft not found'),
      );

      return draft;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getImageUrlForDraft(String draftId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getStringList('draft_services_list') ?? [];

      for (final draftString in draftsJson) {
        final json = jsonDecode(draftString) as Map<String, dynamic>;

        // Extract ID from list format
        String? extractId(dynamic field) {
          if (field is String) return field;
          if (field is List && field.isNotEmpty) {
            return field.last?.toString();
          }
          return null;
        }

        if (extractId(json['id']) == draftId && json.containsKey('imageUrl')) {
          // Extract imageUrl from list format
          final imageUrlField = json['imageUrl'];
          if (imageUrlField is String) return imageUrlField;
          if (imageUrlField is List && imageUrlField.isNotEmpty) {
            return imageUrlField.last?.toString();
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> fixExistingDrafts() async {
    try {
      final currentUserEmail = CurrentUserContext.email;
      if (currentUserEmail == null) {
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final draftsJson = prefs.getStringList('draft_services_list') ?? [];

      if (draftsJson.isEmpty) {
        return;
      }

      bool needsUpdate = false;
      final updatedDrafts = <String>[];

      for (final draftString in draftsJson) {
        final json = jsonDecode(draftString) as Map<String, dynamic>;

        // Check if emailRequester needs fixing
        bool needsFix = false;
        final emailField = json['emailRequester'];

        if (emailField == null) {
          needsFix = true;
        } else if (emailField is String && emailField.isEmpty) {
          needsFix = true;
        } else if (emailField is List) {
          if (emailField.isEmpty || emailField.last?.toString().isEmpty == true) {
            needsFix = true;
          }
        }

        if (needsFix) {
          json['emailRequester'] = [currentUserEmail];
          // Ensure timestamps exist
          if (!json.containsKey('timestamps') || json['timestamps'] == null) {
            json['timestamps'] = [DateTime.now().millisecondsSinceEpoch];
          }
          needsUpdate = true;
        }

        updatedDrafts.add(jsonEncode(json));
      }

      if (needsUpdate) {
        await prefs.setStringList('draft_services_list', updatedDrafts);
      }
    } catch (e) {
    }
  }
}
