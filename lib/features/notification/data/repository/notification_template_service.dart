/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_template_service.dart
/// Purpose: Reads and writes per-module notification templates.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs).
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-011: [getTemplate] reads a
///          stored body that is exactly a SUPERSEDED old default (seeded,
///          never edited) with today's default ([withoutSupersededText]).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import '../models/notification_model.dart';
import '../../domain/enums/notification_catalog.dart';
import '../../domain/enums/notification_event.dart';
import '../../domain/enums/time_tracker_module/time_tracker_events.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

class NotificationTemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /// `Demo/{companyId}/Modules/notification/notification_templates`.
  /// MOVED 24/9/2026 off the top-level `notification_templates` collection,
  /// which mixed every company's templates in one bucket. The tenant prefix
  /// comes from `ApiConstants.baseUri` (set at login) through [getBaseUrl].
  static const String templatesPath =
      'Modules/notification/notification_templates';
  String get _collectionPath => getBaseUrl(templatesPath);

  // ✅ Get template by module and event type (NO notificationType parameter needed now)
  Future<NotificationTemplateModel?> getTemplate({
    required String module,
    required String eventType,
  }) async {
    try {
      final templateId = '${module}_$eventType';

      final doc = await _firestore
          .collection(_collectionPath)
          .doc(templateId)
          .get();

      if (doc.exists) {
        final template = NotificationTemplateModel.fromFirestore(doc);
        // 9/10/2026 (Time Tracker QA KP-TT-011): a seeded old default is
        // read with today's wording; an admin-edited text is kept.
        return withoutSupersededText(template);
      } else {
        // Return default template if not found
        return _getDefaultTemplate(module: module, eventType: eventType);
      }
    } catch (e) {
      return null;
    }
  }

  /// Function Name: [withoutSupersededText]
  ///
  /// Purpose: ADDED 9/10/2026 (Time Tracker QA KP-TT-011) — a stored body
  /// that is EXACTLY an old catalogue default the catalogue has since
  /// replaced (e.g. "You currently have {{count}} requests pending…", which
  /// read "1 requests") becomes today's default; anything an admin edited
  /// stays. Status, channels and subject are never touched. Pure — no
  /// Firestore.
  ///
  /// Return type: [NotificationTemplateModel]
  static NotificationTemplateModel withoutSupersededText(NotificationTemplateModel template) {
    final List<String> old = template.module == AppModule.timeTracker.key
        ? (TimeTrackerNotificationEvent.supersededBodies[template.eventType] ?? const <String>[])
        : const <String>[];
    if (old.isEmpty) return template;
    final bool en = old.contains(template.bodyEnglish.trim());
    final bool ar = old.contains(template.bodyArabic.trim());
    if (!en && !ar) return template;
    final NotificationEvent? event = NotificationCatalog.findByKeys(
      moduleKey: template.module,
      eventKey: template.eventType,
    );
    if (event == null) return template;
    return template.copyWith(
      bodyEnglish: en ? event.bodyEn : null,
      bodyArabic: ar ? event.bodyAr : null,
    );
  }

  // Get all templates for a module
  Future<List<NotificationTemplateModel>> getTemplatesByModule(String module) async {
    try {

      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('module', isEqualTo: module)
          .get();

      final templates = querySnapshot.docs
          .map((doc) => NotificationTemplateModel.fromFirestore(doc))
          .toList();

      return templates;
    } catch (e) {
      return [];
    }
  }

  // ✅ Save or update template with selected notification types
  Future<bool> saveTemplate(NotificationTemplateModel template) async {
    try {

      final updatedTemplate = template.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionPath)
          .doc(template.id)
          .set(updatedTemplate.toFirestore(), SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  // ✅ Update only selected notification types
  Future<bool> updateSelectedNotificationTypes({
    required String module,
    required String eventType,
    required List<String> selectedTypes,
  }) async {
    try {
      final templateId = '${module}_$eventType';

      await _firestore
          .collection(_collectionPath)
          .doc(templateId)
          .set({
        'selectedNotificationTypes': selectedTypes,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete template
  Future<bool> deleteTemplate(String templateId) async {
    try {

      await _firestore
          .collection(_collectionPath)
          .doc(templateId)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // ✅ Reset to default template
  Future<bool> resetToDefault({
    required String module,
    required String eventType,
  }) async {
    try {
      final defaultTemplate = _getDefaultTemplate(
        module: module,
        eventType: eventType,
      );

      if (defaultTemplate != null) {
        return await saveTemplate(defaultTemplate);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Get default template from the module event catalog.
  //
  // Was an 830-line hand-maintained switch that had to be kept in sync with
  // the hardcoded list in notification_control.dart. Both now read the same
  // per-module event enums (domain/enums/<module>_module/), so a new
  // is added in exactly one place.
  NotificationTemplateModel? _getDefaultTemplate({
    required String module,
    required String eventType,
  }) {
    final event = NotificationCatalog.findByKeys(
      moduleKey: module,
      eventKey: eventType,
    );
    if (event == null) {
      return null;
    }
    return templateFromEvent(event);
  }

  /// Build a template model straight from a catalog event. Public so the
  /// Notification Control screen can render rows before Firestore answers.
  NotificationTemplateModel templateFromEvent(
    NotificationEvent event, {
    List<String>? selectedNotificationTypes,
    bool isEnabled = true,
  }) {
    final now = DateTime.now();
    return NotificationTemplateModel(
      id: event.templateId,
      module: event.module.key,
      eventType: event.key,
      isEnabled: isEnabled,
      // Default: Email and Push enabled for most notifications.
      selectedNotificationTypes:
          selectedNotificationTypes ?? const ['email', 'push'],
      subjectEnglish: event.titleEn,
      subjectArabic: event.titleAr,
      bodyEnglish: event.bodyEn,
      bodyArabic: event.bodyAr,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Function Name: [resetModuleToDefaults]
  ///
  /// Purpose: Force EVERY template in one module back to the wording in its
  /// event enum, overwriting whatever Firestore currently holds.
  ///
  /// ADDED 30/8/2026. [seedModuleDefaults] deliberately skips a document that
  /// already exists, so it cannot repair a module whose templates were seeded
  /// from older wording — and there was no bulk equivalent of the per-event
  /// "Reset Default" button, so correcting one module meant opening all of its
  /// events in Notification Control one at a time.
  ///
  /// ⚠️ DESTRUCTIVE. This is the one method that discards admin edits, which
  /// is the whole point: it is for "the spec text changed, put every template
  /// back to it". Never call it as part of start-up or a repair pass — that is
  /// what [seedModuleDefaults] is for.
  ///
  /// Parameters:
  /// - [module]: the module whose templates are rewritten.
  ///
  /// Returns: [Future<int>] how many template documents were written.
  Future<int> resetModuleToDefaults(AppModule module) async {
    var written = 0;
    for (final event in NotificationCatalog.eventsOf(module)) {
      if (await saveTemplate(templateFromEvent(event))) written++;
    }
    return written;
  }

  /// Seed / repair Firestore for a whole module: writes any template
  /// document that does not exist yet, leaving admin-edited ones untouched.
  Future<int> seedModuleDefaults(AppModule module) async {
    var written = 0;
    for (final event in NotificationCatalog.eventsOf(module)) {
      final doc =
          await _firestore.collection(_collectionPath).doc(event.templateId).get();
      if (doc.exists) continue;
      if (await saveTemplate(templateFromEvent(event))) written++;
    }
    return written;
  }


  // Process template variables (replace placeholders)
  String processTemplate(String template, Map<String, String> variables) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }

  /// Type-safe variant — no raw placeholder strings at call sites.
  /// `processTemplateVars(t, {TemplateVariable.serviceName: name})`
  String processTemplateVars(
    String template,
    Map<TemplateVariable, String> variables,
  ) =>
      processTemplate(template, variables.toTemplateVariables());
}