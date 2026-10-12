/// Module: messaging / chat / domain/enum/chat_actions.dart
enum ChatActionsEnum {
  viewContact,
  viewGroup,
  pin,
  mediaLinksAndDocs,
  muteNotifications,
  disappearingMessages,
  scheduleMessages;

  /// Get translated label for each action
  String getLabel(bool isAr) {
    switch (this) {
      case ChatActionsEnum.viewContact:
        return isAr ? 'عرض جهة الاتصال' : 'View Contact';
      case ChatActionsEnum.viewGroup:
        return isAr ? 'عرض المجموعة' : 'View Group';
      case ChatActionsEnum.pin:
        return isAr ? 'تثبيت' : 'Pin';
      case ChatActionsEnum.mediaLinksAndDocs:
        return isAr ? 'الوسائط والروابط والمستندات' : 'Media, Links & Docs';
      case ChatActionsEnum.muteNotifications:
        return isAr ? 'كتم الإشعارات' : 'Mute Notifications';
      case ChatActionsEnum.disappearingMessages:
        return isAr ? 'الرسائل المختفية' : 'Disappearing Messages';
      case ChatActionsEnum.scheduleMessages:
        return isAr ? 'جدولة الرسائل' : 'Schedule Messages';
    }
  }

  /// Menu items for SINGLE (direct message) chat
  static List<ChatActionsEnum> singleActions = [
    viewContact,
    pin,
    mediaLinksAndDocs,
    muteNotifications,
    disappearingMessages,
    scheduleMessages,
  ];

  /// Menu items for GROUP chat
  static List<ChatActionsEnum> groupActions = [
    viewGroup,
    pin,
    mediaLinksAndDocs,
    muteNotifications,
    disappearingMessages,
    scheduleMessages,
  ];
}