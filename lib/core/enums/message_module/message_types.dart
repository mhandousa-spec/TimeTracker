/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: message_types.dart
/// Purpose: Enum `MessageTypes` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

enum MessageTypes {
  text,
  cameraImage,
  video,
  audio,
  doc,
  location,
  contact,
  system,
  custom,
  deleted,
  edited,
  galleryImage,
  poll,
  none;

  String get messagePrimaryLanguageName {
    switch (this) {
      case MessageTypes.text:
        return "Text";
      case MessageTypes.cameraImage:
        return "Camera Image";
      case MessageTypes.video:
        return "Video";
      case MessageTypes.audio:
        return "Audio";
      case MessageTypes.doc:
        return "Document";
      case MessageTypes.location:
        return "Location";
      case MessageTypes.contact:
        return "Contact";
      case MessageTypes.system:
        return "System";
      case MessageTypes.custom:
        return "Custom";
      case MessageTypes.deleted:
        return "Deleted";
      case MessageTypes.edited:
        return "Edited";
      case MessageTypes.galleryImage:
        return "Image";
      case MessageTypes.poll:
        return "Poll";
      default:
        return "Unknown Type";
    }
  }

  String get messageArabicName {
    // arabic language
    switch (this) {
      case MessageTypes.text:
        return "رسالة نصية";
      case MessageTypes.cameraImage:
        return "صورة من الكاميرا";
      case MessageTypes.video:
        return "فيديو";
      case MessageTypes.audio:
        return "صوت";
      case MessageTypes.doc:
        return "مستند";
      case MessageTypes.location:
        return "موقع";
      case MessageTypes.contact:
        return "جهة اتصال";
      case MessageTypes.system:
        return "نظام";
      case MessageTypes.custom:
        return "مخصص";
      case MessageTypes.deleted:
        return "محذوف";
      case MessageTypes.edited:
        return "محرر";
      case MessageTypes.galleryImage:
        return "صورة";
      default:
        return "نوع غير معروف";
    }
  }
}
