// ******************* FILE INFO *******************
// File Name: services_local_data_source
// Description: Local (SharedPreferences) data source for the services module.
//              Holds all prefs/draft/SLA persistence so the repository only
//              delegates and maps (R02). No Firestore, no presentation deps.
// Module: services_management_module / data / data_source / local_data_source
// *************************************************

import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/services_prefs_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/sla_data_model.dart';

class ServicesLocalDataSource {
  Future<List<ServicesHistoryModel>> getLocalDrafts() async {
    return await SharedPrefsServiceMaster.loadDrafts();
  }

  Future<void> saveServiceToPrefs(ServicesHistoryModel model) async {
    // ✅ UPDATED: Use current getters
    await SharedPrefsHelper.setString(
        'service_name_en', model.currentServiceNameEnglish);
    await SharedPrefsHelper.setString(
        'service_name_ar', model.currentServiceNameArabic);
    await SharedPrefsHelper.setString(
        'service_description_en', model.currentServiceDescriptionEnglish);
    await SharedPrefsHelper.setString(
        'service_description_ar', model.currentServiceDescriptionArabic);
    await SharedPrefsHelper.setString(
        'duration_value', model.currentDurationOfServices);
    await SharedPrefsHelper.setString(
        'duration_unit', model.currentSelectedDurationUnit);
    // ✅ FIX 30/8/2026 — THE UPLOADED IMAGE NEVER REACHED THE SAVED SERVICE.
    //
    // This method is the ONLY place page 1's fields get staged for the rest of
    // the wizard, and it staged six of the seven. `service_image_url` was
    // missing, yet three later steps read it:
    //
    //   • button.dart (`_buildCompleteModelForDraft`)      — no fallback
    //   • provider_selection_cubit (`_buildModel`)          — no fallback
    //   • sla_notification_cubit (`_buildDraftModelFromStagedData`)
    //
    // The key was only ever READ and, on discard, CLEARED (dialogs.dart) —
    // never written. So for a new service every one of those reads returned ''
    // and rebuilt the model with `imageUrl: ''`, throwing away the URL the
    // upload had already put on `CreateServiceFormData`. The picture uploaded
    // to Storage fine and showed in the form; it was dropped on the way to
    // Firestore, so `ServiceGridCard` found `currentImageUrl` empty and drew
    // the headset placeholder instead.
    //
    // Written unconditionally, including when empty: that clears the previous
    // service's URL, so creating a service with no image right after one with
    // an image does not inherit the old picture.
    await SharedPrefsHelper.setString(
        'service_image_url', model.currentImageUrl);
    await SharedPrefsEmployeeHelper.saveSelectedEmployees(
        model.currentProviderServices);
  }

  Future<void> loadServiceToFormControllers(ServicesHistoryModel model) async {
    await saveServiceToPrefs(model);
  }

  Future<void> saveToSharedPrefs({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required Map<String, Map<int, bool>> notificationSwitches,
    required List<String> extraSlaValues,
    required List<String> extraSlaTwoValues,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('sla_one', slaOne);
    await prefs.setString('sla_two', slaTwo);
    await prefs.setBool('Notify Service Requester_checked', notifyRequesterChecked);
    await prefs.setBool('Notify Service Provider_checked', notifyProviderChecked);
    await prefs.setBool('Notify Provider Manager_checked', notifyManagerChecked);
    await prefs.setBool('Notify Service Requester_switch_0', notifyRequesterSwitch0);
    await prefs.setBool('Notify Provider Manager_switch_1', notifyManagerSwitch1);

    for (int i = 0; i < extraSlaValues.length; i++) {
      await prefs.setString('extra_sla_$i', extraSlaValues[i]);
    }
    await prefs.setInt('extra_sla_count', extraSlaValues.length);

    for (int i = 0; i < extraSlaTwoValues.length; i++) {
      await prefs.setString('extra_sla_two_$i', extraSlaTwoValues[i]);
    }
    await prefs.setInt('extra_sla_two_count', extraSlaTwoValues.length);

    for (final entry in notificationSwitches.entries) {
      final title = entry.key;
      final switchMap = entry.value;
      for (final switchEntry in switchMap.entries) {
        await prefs.setBool('${title}_switch_${switchEntry.key}', switchEntry.value);
      }
    }
  }

  Future<SlaDataModel> loadFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final slaOne = prefs.getString('sla_one') ?? '';
    final slaTwo = prefs.getString('sla_two') ?? '';
    final notifyRequesterChecked = prefs.getBool('Notify Service Requester_checked') ?? true;
    final notifyProviderChecked = prefs.getBool('Notify Service Provider_checked') ?? true;
    final notifyManagerChecked = prefs.getBool('Notify Provider Manager_checked') ?? true;
    final notifyRequesterSwitch0 = prefs.getBool('Notify Service Requester_switch_0') ?? false;
    final notifyManagerSwitch1 = prefs.getBool('Notify Provider Manager_switch_1') ?? false;

    final List<String> extraSlaValues = [];
    final extraCount = prefs.getInt('extra_sla_count') ?? 0;
    for (int i = 0; i < extraCount; i++) {
      extraSlaValues.add(prefs.getString('extra_sla_$i') ?? '');
    }

    final List<String> extraSlaTwoValues = [];
    final extraTwoCount = prefs.getInt('extra_sla_two_count') ?? 0;
    for (int i = 0; i < extraTwoCount; i++) {
      extraSlaTwoValues.add(prefs.getString('extra_sla_two_$i') ?? '');
    }

    final titles = [
      'Notify Service Requester',
      'Notify Service Provider',
      'Notify Provider Manager',
    ];

    Map<String, Map<int, bool>> notificationSwitches = {};
    for (final title in titles) {
      Map<int, bool> map = {};
      for (int i = 0; i < 5; i++) {
        final value = prefs.getBool('${title}_switch_$i');
        if (value != null) {
          map[i] = value;
        }
      }
      notificationSwitches[title] = map;
    }

    return SlaDataModel(
      slaOne: slaOne,
      slaTwo: slaTwo,
      notifyRequesterChecked: notifyRequesterChecked,
      notifyProviderChecked: notifyProviderChecked,
      notifyManagerChecked: notifyManagerChecked,
      notifyRequesterSwitch0: notifyRequesterSwitch0,
      notifyManagerSwitch1: notifyManagerSwitch1,
      extraSlaValues: extraSlaValues,
      extraSlaTwoValues: extraSlaTwoValues,
      notificationSwitches: notificationSwitches,
    );
  }

  Future<void> saveDraft(ServicesHistoryModel model) async {
    await SharedPrefsServiceMaster.saveDraft(model);
  }

  Future<void> updateDraft(ServicesHistoryModel oldModel, ServicesHistoryModel newModel) async {
    await SharedPrefsServiceMaster.updateDraft(oldModel, newModel);
  }

  Future<void> removeDraftById(String id) async {
    await SharedPrefsServiceMaster.removeDraftById(id);
  }

  Future<void> saveSlaToPrefs({
    required String slaOne,
    required String slaTwo,
    required bool notifyRequesterChecked,
    required bool notifyProviderChecked,
    required bool notifyManagerChecked,
    required bool notifyRequesterSwitch0,
    required bool notifyManagerSwitch1,
    required List<String> extraSlaList,
    required List<String> extraSlaTwoList,
    required Map<String, Map<int, bool>> notificationSwitches,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('sla_one', slaOne);
    await prefs.setString('sla_two', slaTwo);

    await prefs.setBool('Notify Service Requester_checked', notifyRequesterChecked);
    await prefs.setBool('Notify Service Provider_checked', notifyProviderChecked);
    await prefs.setBool('Notify Provider Manager_checked', notifyManagerChecked);

    await prefs.setBool('Notify Service Requester_switch_0', notifyRequesterSwitch0);
    await prefs.setBool('Notify Provider Manager_switch_1', notifyManagerSwitch1);

    for (int i = 0; i < extraSlaList.length; i++) {
      await prefs.setString('extra_sla_$i', extraSlaList[i]);
    }
    await prefs.setInt('extra_sla_count', extraSlaList.length);

    for (int i = 0; i < extraSlaTwoList.length; i++) {
      await prefs.setString('extra_sla_two_$i', extraSlaTwoList[i]);
    }
    await prefs.setInt('extra_sla_two_count', extraSlaTwoList.length);

    for (final entry in notificationSwitches.entries) {
      final title = entry.key;
      final switchMap = entry.value;
      for (final switchEntry in switchMap.entries) {
        final index = switchEntry.key;
        final value = switchEntry.value;
        await prefs.setBool('${title}_switch_$index', value);
      }
    }
  }
}
