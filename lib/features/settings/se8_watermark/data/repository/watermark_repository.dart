/// Module: settings / se8_watermark / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: watermark_repository.dart
/// Purpose: Declares `WatermarkRepository` — reads and writes the company-wide
///          watermark settings.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// ⚠️ CONFIRM THE DOCUMENT PATH BEFORE RELYING ON THIS.
///
/// The watermark is company policy, not a per-employee preference — one admin
/// sets it and every employee's screens carry it — so it is stored once, beside
/// the other module configuration, at:
///
///     {ApiConstants.baseUri}/Modules/settings   →   field `watermark`
///
/// That mirrors the convention the roles module uses
/// (`getBaseUrl('Modules')/roles` + a collection), which is the only
/// module-config path in the codebase to copy from. If this project already
/// keeps company settings somewhere else, change [_documentPath] — nothing
/// above this file knows where the data lives.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/settings/se8_watermark/domain/entities/watermark_settings.dart';

class WatermarkRepository {
  /// The single document holding module-wide settings.
  String get _documentPath => '${getBaseUrl('Modules')}/settings';

  /// Field inside that document. Namespaced so this feature can never collide
  /// with another setting stored in the same doc.
  static const String _field = 'watermark';

  /// Function Name: [load]
  ///
  /// Purpose: Read the stored settings.
  ///
  /// Returns: [Future<WatermarkSettings>] — the defaults when the document or
  /// the field does not exist yet, which is the state on a fresh company.
  Future<WatermarkSettings> load() async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.doc(_documentPath).get();

    if (!snapshot.exists) return WatermarkSettings.initial;

    final Object? raw = snapshot.data()?[_field];
    if (raw is! Map) return WatermarkSettings.initial;

    return WatermarkSettings.fromMap(Map<String, dynamic>.from(raw));
  }

  /// Function Name: [save]
  ///
  /// Purpose: Persist [settings].
  ///
  /// `SetOptions(merge: true)` rather than `update`: the document may not exist
  /// on a company that has never opened this screen, and `update` throws on a
  /// missing document while a merging `set` creates it. Merge also leaves every
  /// other field in that document untouched.
  ///
  /// Parameters:
  /// - [settings]: the settings to store.
  ///
  /// Returns: [Future<void>]
  Future<void> save(WatermarkSettings settings) async {
    await FirebaseFirestore.instance.doc(_documentPath).set(
      <String, dynamic>{_field: settings.toMap()},
      SetOptions(merge: true),
    );
  }
}
