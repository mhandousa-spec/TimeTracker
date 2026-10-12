/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: app_notification_sender.dart
/// Purpose: Sends a push notification through FCM.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - Added the standard header (Docs). See the placement note in
///          `firebase_notification_handler.dart`.

/// ************************* FILE INFO ************************* ///
/// File Name: app_notification_sender.dart
/// Purpose: ONE shared facade for sending notifications from any module.
///          Wraps the 3 steps every module was repeating:
///            1. Fetch bilingual template + replace {{variables}}
///            2. Save in-app notification to Firestore
///            3. Send FCM push
/// Updated: 7/10/2026 - Optional `requestId` on send / sendFromTemplate /
///          sendEvent, stored as `Request_Id` (the record a notification is
///          about — see NotificationModelSystem.requestId).
/// Usage: Modules should NOT call this directly from UI/cubits.
///        Each module has its own thin service (e.g.
///        ServicesNotificationService) with intent-named methods
///        that call this facade.

import 'package:flutter/foundation.dart';
import 'package:knowticed_plus/core/constants/app_keys.dart';
import 'package:knowticed_plus/features/notification/data/data_source/notification_page_config.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';

import 'package:knowticed_plus/features/notification/domain/enums/notification_event.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/enums/template_variable.dart';

class AppNotificationSender {
  AppNotificationSender._();

  static final FirestoreNotificationService _firestoreService =
      FirestoreNotificationService();
  static final NotificationTemplateService _templateService =
      NotificationTemplateService();

  /// LOW-LEVEL: save in-app notification + (optionally) send FCM push.
  /// Use when you already have a final title/body (no template).
  /// Returns the Firestore document id, or null on failure.
  ///
  /// [title] / [body] must be the ENGLISH text; [titleAr] / [bodyAr] carry the
  /// Arabic. Both are stored, and the card picks by the READER's locale — see
  /// the language note in `notification_data_model.dart`. The FCM push uses
  /// the English text, because the push is built before we know anything about
  /// the receiving device's language.
  static Future<String?> send({
    required AppModule module,
    required String pageKey,
    required String title,
    required String body,
    required String senderEmail,
    required String receiverEmail,
    String titleAr = '',
    String bodyAr = '',
    bool isPinned = false,
    bool sendPush = true,
    String requestId = '',
  }) async {
    if (receiverEmail.isEmpty) return null;

    final String? docId;
    try {
      docId = await _firestoreService.uploadNotification(
        NotificationModelSystem(
          title: title,
          body: body,
          titleAr: titleAr,
          bodyAr: bodyAr,
          nameOfModule: module.key,
          senderEmail: senderEmail,
          receiverEmail: receiverEmail,
          nameOfPage: pageKey,
          isPinned: isPinned,
          requestId: requestId,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[notify] ${module.key} in-app write FAILED — $e\n$stackTrace');
      return null;
    }

    // ✅ FIX 26/8/2026 — push now has its own try/catch, and its failure no
    // longer discards a notification that was already written.
    //
    // Both steps used to share one `try { … } catch (e) { return null; }`. The
    // in-app document is written FIRST, so when the push threw — which it does
    // on every build without the FCM `--dart-define` values, because
    // `AppKeys.fcmServiceAccountJson()` raises a StateError on purpose — this
    // returned null for a notification that had genuinely been saved. The
    // caller reported failure, and `sendFromTemplate` logged "FAILED to write"
    // about a document sitting in Firestore.
    //
    // The two deliveries are independent and are now treated that way: the
    // in-app record decides the return value, push is best-effort on top of it.
    if (sendPush) {
      if (!AppKeys.isFcmConfigured) {
        // One clear line instead of a stack trace per notification. This is a
        // build-configuration gap, not a code fault — supply the dart-defines
        // and push starts working with no code change.
        debugPrint(
          '[notify] ${module.key} push SKIPPED — FCM service account not '
          'configured (pass --dart-define=FCM_PROJECT_ID, FCM_PRIVATE_KEY_ID, '
          'FCM_PRIVATE_KEY, FCM_CLIENT_EMAIL, FCM_CLIENT_ID). The in-app '
          'notification was saved and appears in the notifications page.',
        );
      } else {
        try {
          await NotificationServiceApp.sendNotification(
            title,
            body,
            receiverEmail,
            moduleKey: module.key,
            pageKey: pageKey,
          );
        } catch (e, stackTrace) {
          debugPrint(
            '[notify] ${module.key} push FAILED (in-app notification $docId '
            'was still saved) — $e\n$stackTrace',
          );
        }
      }
    }

    return docId;
  }

  /// HIGH-LEVEL: fetch the bilingual template `<module>_<eventType>`,
  /// replace {{variables}}, then save + push.
  /// Returns true if the notification was sent.
  static Future<bool> sendFromTemplate({
    required AppModule module,
    required String eventType,
    required String pageKey,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    Map<String, String> variables = const {},
    Map<String, String> variablesAr = const {},
    bool isPinned = false,
    bool sendPush = true,
    String requestId = '',
  }) async {
    if (receiverEmail.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[notify] ${module.key}_$eventType SKIPPED — empty receiver email.',
        );
      }
      return false;
    }
    try {
      final template = await _templateService.getTemplate(
        module: module.key,
        eventType: eventType,
      );

      // `isEnabled` is the master switch — off means this notification is
      // silenced completely.
      //
      // Both refusals are logged (ADDED 25/8/2026). They are the two ways a
      // notification can vanish without an error anywhere: the event is not in
      // `NotificationCatalog`, so `getTemplate` cannot even build a default; or
      // an admin switched it off in Notification Control. From the UI the two
      // are indistinguishable from "the code never ran".
      if (template == null) {
        if (kDebugMode) {
          debugPrint(
            '[notify] ${module.key}_$eventType NOT SENT — no template and no '
            'catalog default. Is the event registered in NotificationCatalog?',
          );
        }
        return false;
      }
      if (!template.isEnabled) {
        if (kDebugMode) {
          debugPrint(
            '[notify] ${module.key}_$eventType NOT SENT — the template is '
            'disabled in Notification Control.',
          );
        }
        return false;
      }

      // The channel checkboxes only decide HOW it is delivered. Previously an
      // admin who unchecked "Push" but left "Email" on lost the in-app
      // notification as well, because push was treated as mandatory. The
      // in-app record is now always written; push fires only when selected.
      final pushAllowed = sendPush && template.hasPush;

      // ⚠️ CHANGED 30/8/2026 — the sender's language no longer decides what
      // the receiver reads.
      //
      // These two lines used to be `isArabic ? …Arabic : …English`, so the
      // acting user's app language was baked into the stored document. An
      // approver working in Arabic sent Arabic text to an English reader and
      // there was no way back: only one language was ever written.
      //
      // Both renderings are produced and both are stored. The card chooses at
      // build time from the VIEWER's locale
      // (`NotificationModelSystem.titleFor` / `displayBodyFor`), so switching
      // the app to Arabic re-renders the whole inbox — including notifications
      // already in it.
      //
      // [isArabic] is kept on the signature because every module's service
      // passes it and it still has one job: nothing here, but callers use it
      // for their own wording. It no longer influences what is stored.
      final title = _templateService.processTemplate(
        template.subjectEnglish,
        variables,
      );
      final body = _templateService.processTemplate(
        template.bodyEnglish,
        variables,
      );
      // ADDED 1/9/2026 — per-language placeholder values.
      //
      // Both renderings used to be built from ONE `variables` map, which is
      // right for a date or a number but wrong for anything that is itself
      // bilingual. Knowledge Hub documents carry `nameEnglish` AND
      // `nameArabic`, so with a single map the Arabic body read
      // "تم إرسال المستند Q3 Security Policy" — Arabic sentence, English
      // noun — and the module had been working around it by storing
      // 'English / عربي' as one value, printing both names in both bodies.
      //
      // [variablesAr] is an OVERRIDE, not a replacement: anything it does not
      // define falls back to [variables], so every existing caller is
      // unaffected and a caller that only has one bilingual value only has to
      // supply that one.
      final Map<String, String> arabicVariables = variablesAr.isEmpty
          ? variables
          : <String, String>{...variables, ...variablesAr};

      final titleAr = _templateService.processTemplate(
        template.subjectArabic,
        arabicVariables,
      );
      final bodyAr = _templateService.processTemplate(
        template.bodyArabic,
        arabicVariables,
      );

      final docId = await send(
        module: module,
        pageKey: pageKey,
        title: title,
        body: body,
        titleAr: titleAr,
        bodyAr: bodyAr,
        senderEmail: senderEmail,
        receiverEmail: receiverEmail,
        isPinned: isPinned,
        sendPush: pushAllowed,
        requestId: requestId,
      );

      if (kDebugMode) {
        debugPrint(
          docId != null
              ? '[notify] ${module.key}_$eventType → $receiverEmail  ok (doc $docId'
                  '${pushAllowed ? ', push' : ', no push'})'
              : '[notify] ${module.key}_$eventType → $receiverEmail  FAILED to write',
        );
      }
      return docId != null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[notify] ${module.key}_$eventType → $receiverEmail threw: '
          '$e\n$stackTrace',
        );
      }
      return false;
    }
  }

  /// PREFERRED: send a catalog event. No raw module / eventType / placeholder
  /// strings anywhere at the call site.
  ///
  ///   AppNotificationSender.sendEvent(
  ///     event: ServicesNotificationEvent.requestApproved,
  ///     pageKey: ServicesNotificationPage.approvalRequestCard.key,
  ///     senderEmail: me, receiverEmail: requester, isArabic: isAr,
  ///     variables: {TemplateVariable.serviceName: service.name},
  ///   );
  ///
  /// The Firestore template still wins — the enum text is only the fallback
  /// when no admin has customised `<module>_<key>` yet.
  static Future<bool> sendEvent({
    required NotificationEvent event,
    required String pageKey,
    required String senderEmail,
    required String receiverEmail,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
    Map<TemplateVariable, String> variablesAr = const {},
    bool isPinned = false,
    bool sendPush = true,
    String requestId = '',
  }) {
    assert(
      variables.keys.toSet().containsAll(event.variables),
      'Missing placeholders for ${event.templateId}: '
      '${event.variables.difference(variables.keys.toSet())}',
    );
    return sendFromTemplate(
      module: event.module,
      eventType: event.key,
      pageKey: pageKey,
      senderEmail: senderEmail,
      receiverEmail: receiverEmail,
      isArabic: isArabic,
      variables: variables.toTemplateVariables(),
      variablesAr: variablesAr.toTemplateVariables(),
      isPinned: isPinned,
      sendPush: sendPush,
      requestId: requestId,
    );
  }

  /// Same event, many recipients. Returns how many were sent.
  ///
  /// PARALLELISED 25/8/2026. This was a `for` loop with an `await` inside, so
  /// every recipient cost a template read, a Firestore write, an OAuth
  /// handshake and an FCM post BEFORE the next recipient started. The settings
  /// change-request fan-out resolved 19 reviewers, and the submit dialog waits
  /// on this — nineteen sequential round trips of it.
  ///
  /// The sends are independent, so they run together. Recipients are still
  /// de-duplicated first, and one failure cannot take down the batch:
  /// `sendEvent` already resolves to `false` rather than throwing.
  static Future<int> sendEventToAll({
    required NotificationEvent event,
    required String pageKey,
    required String senderEmail,
    required Iterable<String> receiverEmails,
    required bool isArabic,
    Map<TemplateVariable, String> variables = const {},
    Map<TemplateVariable, String> variablesAr = const {},
    bool isPinned = false,
    bool sendPush = true,
  }) async {
    final Set<String> recipients = receiverEmails.toSet();
    if (recipients.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[notify] ${event.templateId} NOT SENT — recipient list was empty. '
          'The caller resolved nobody to send to.',
        );
      }
      return 0;
    }
    if (kDebugMode) {
      debugPrint('[notify] ${event.templateId} fan-out starting -> $recipients');
    }

    final List<bool> results = await Future.wait(
      recipients.map(
        (String email) => sendEvent(
          event: event,
          pageKey: pageKey,
          senderEmail: senderEmail,
          receiverEmail: email,
          isArabic: isArabic,
          variables: variables,
          variablesAr: variablesAr,
          isPinned: isPinned,
          sendPush: sendPush,
        ),
      ),
    );

    final int sent = results.where((bool ok) => ok).length;

    if (kDebugMode) {
      debugPrint(
        '[notify] ${event.templateId} fan-out: $sent/${recipients.length} sent.',
      );
    }
    return sent;
  }
}
