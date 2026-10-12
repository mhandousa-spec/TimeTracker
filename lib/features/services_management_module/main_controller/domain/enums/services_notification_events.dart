/// ************************* FILE INFO ************************* ///
/// File Name: services_notification_events.dart
/// Status:   DEPRECATED — kept only so older imports keep resolving.
///
/// The Services event list moved to the shared per-module catalog at
/// `features/notification/domain/enums/services_module/services_events.dart`,
/// where it now carries its default bilingual title/body and its
/// placeholder set alongside the key. Every module lives beside it in the
/// same folder, and NotificationCatalog walks them all.
///
/// The keys and value names are unchanged, so this is a pure re-export —
/// nothing at a call site needs to change. Import the canonical path in
/// new code and delete this file once no import points here.

export 'package:knowticed_plus/features/notification/domain/enums/services_module/services_events.dart'
    show ServicesNotificationEvent;
