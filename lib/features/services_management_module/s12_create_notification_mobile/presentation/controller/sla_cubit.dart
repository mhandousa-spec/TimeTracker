/// Module: services_management_module
/// Description: Cubit owning the SharedPreferences-backed local I/O for the
///              s12 SLA mobile screen: seeding local prefs from an existing
///              service's raw doc JSON (edit mode) and persisting the
///              provider/manager SLA percentages + notification checkboxes/
///              switches before a create/update submit. The actual
///              create/update Firestore call remains on
///              ServicesManagerCubit (module-root, already fixed) — this
///              cubit only owns the SharedPreferences local data-source
///              calls that previously ran directly in the page's State
///              methods.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, shared_preferences, SlaNotificationKeys
/// Revision History: Initial version — extracted from
///                    s12_create_notification_mobile/ui/services_management_module/sla_screen_mobile.dart
///                    initState()'s SharedPrefsHelper seeding block and
///                    _submitAllToSharedPrefs() (audit fix 1e). First
///                    controller/ folder for s12.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_prefs_service_master.dart';
import 'package:knowticed_plus/features/services_management_module/s12_create_notification_mobile/presentation/controller/sla_state.dart';

class SlaCubit extends Cubit<SlaState> {
  // B5 FIX: guard against emit-after-close (StateError) when the user
  // navigates away mid-await. Applies to every emit in this cubit.
  @override
  void emit(state) {
    if (isClosed) return;
    super.emit(state);
  }

  SlaCubit() : super(const SlaIdle());

  /// Seeds local SharedPreferences keys from an existing service's raw doc
  /// JSON (edit mode bootstrap). Mirrors the page's original initState()
  /// block exactly.
  Future<void> seedFromDocRawJson(Map<String, dynamic>? rawJson) async {
    if (rawJson == null) return;
    emit(const SlaBusy());
    try {
      await SharedPrefsHelper.setBool('sla_switch', rawJson['branchSLA'] ?? false);
      await SharedPrefsHelper.setBool(
          'inquiry_switch', rawJson['allowInquiries'] ?? false);
      await SharedPrefsHelper.setBool(
          'comments_switch', rawJson['allowComments'] ?? false);
      await SharedPrefsHelper.setString('percentage', rawJson['percentage'] ?? '');
      await SharedPrefsHelper.setStringList(
        'notifications',
        (rawJson['notifications'] as List?)?.map((e) => e.toString()).toList() ??
            [],
      );
      emit(const SlaSuccess());
    } catch (e) {
      emit(SlaError('Error seeding SLA prefs: $e'));
    }
  }

  /// Persists the provider/manager SLA percentages and the notification
  /// checkbox/switch selections to SharedPreferences ahead of a
  /// create/update submit.
  Future<void> submitPercentagesAndSwitches({
    required String providerPercentage,
    required String managerPercentage,
    required Map<String, bool> sectionCheckboxes,
    required Map<String, bool> providerSwitches,
  }) async {
    emit(const SlaBusy());
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('sla_one', providerPercentage);
      await prefs.setString('sla_two', managerPercentage);

      await prefs.setBool('${SlaNotificationKeys.serviceRequester}_checked',
          sectionCheckboxes[SlaNotificationKeys.serviceRequester] ?? true);
      await prefs.setBool('${SlaNotificationKeys.serviceProvider}_checked',
          sectionCheckboxes[SlaNotificationKeys.serviceProvider] ?? true);
      await prefs.setBool('${SlaNotificationKeys.providerManager}_checked',
          sectionCheckboxes[SlaNotificationKeys.providerManager] ?? true);

      await prefs.setBool('${SlaNotificationKeys.serviceRequester}_switch_0',
          providerSwitches['When Service Requested And Approved'] ?? false);
      await prefs.setBool('${SlaNotificationKeys.providerManager}_switch_1',
          providerSwitches['When Service Status Changes'] ?? false);

      emit(const SlaSuccess());
    } catch (e) {
      emit(SlaError('Error saving SLA prefs: $e'));
    }
  }
}
