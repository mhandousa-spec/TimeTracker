// ******************* FILE INFO *******************
// File Name: shared_preference
// Description: Shared preference.
// Module: services_management_module / data/helper
// *************************************************

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

class SharedPrefsService {
  static const String _draftKey = 'draft_services_list';

  /// ✅ Save a new draft (append to the list)
  static Future<void> saveDraft(ServicesHistoryModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentDrafts = prefs.getStringList(_draftKey) ?? [];

    final jsonString = jsonEncode(model.toJson());
    currentDrafts.add(jsonString);

    await prefs.setStringList(_draftKey, currentDrafts);
  }

  /// ✅ Get all saved drafts
  static Future<List<ServicesHistoryModel>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedDrafts = prefs.getStringList(_draftKey) ?? [];

    return encodedDrafts.asMap().entries.map((entry) {
      final json = jsonDecode(entry.value) as Map<String, dynamic>;
      final docId = 'draft_${entry.key}'; // use index as fake ID
      return ServicesHistoryModel.fromJson(json, docId);
    }).toList();
  }

  /// ✅ Save all drafts at once (overwrite full list)
  static Future<void> saveAllDrafts(List<ServicesHistoryModel> models) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = models.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_draftKey, encoded);
  }

  /// ✅ Update a draft (match by unique property — e.g. name+duration)
  static Future<void> updateDraft(ServicesHistoryModel oldModel, ServicesHistoryModel newModel) async {
    final drafts = await getAllDrafts();

    // FIXED: Access current values using getter methods
    final index = drafts.indexWhere((e) =>
    e.currentServiceNameEnglish == oldModel.currentServiceNameEnglish &&
        e.currentDurationOfServices == oldModel.currentDurationOfServices
    );

    if (index != -1) {
      drafts[index] = newModel;
    } else {
      drafts.add(newModel); // fallback: save as new
    }

    await saveAllDrafts(drafts);
  }

  /// ✅ Remove a specific draft by ID
  static Future<void> removeDraftById(String draftId) async {
    final drafts = await getAllDrafts();

    // FIXED: Access current value using getter method
    drafts.removeWhere((draft) => draft.currentId == draftId);

    await saveAllDrafts(drafts);
  }

  /// ✅ Get a specific draft by ID
  static Future<ServicesHistoryModel?> getDraftById(String draftId) async {
    final drafts = await getAllDrafts();

    try {
      // FIXED: Access current value using getter method
      return drafts.firstWhere((draft) => draft.currentId == draftId);
    } catch (e) {
      return null;
    }
  }

  /// ✅ Clear all drafts
  static Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  /// ✅ Get draft count
  static Future<int> getDraftCount() async {
    final drafts = await getAllDrafts();
    return drafts.length;
  }

  /// ✅ Check if a draft exists by ID
  static Future<bool> draftExists(String draftId) async {
    final draft = await getDraftById(draftId);
    return draft != null;
  }
}
