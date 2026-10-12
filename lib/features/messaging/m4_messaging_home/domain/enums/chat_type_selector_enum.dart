/// Module: messaging / home / domain/enum/chat_type_selector_enum.dart
/// ************************* FILE INFO *************************** ///
/// File Name: chat_type_selector_enum.dart
/// Purpose: Chat type selector enum — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/widgets.dart';

import 'package:knowticed_plus/generated/l10n.dart';

enum ChatTypeSelectorEnum {
  all,
  directMessages,
  groups,
}

/// ADDED 2/9/2026.
///
/// The tab strip above the chat list rendered `type.name`, which is the Dart
/// identifier — so the tabs read "all / directMessages / groups" in English
/// even with the app in Arabic, camelCase and all. [label] is the translated
/// text for each value; every key here already existed in intl_en/intl_ar.
extension ChatTypeSelectorEnumLabel on ChatTypeSelectorEnum {
  String label(BuildContext context) {
    switch (this) {
      case ChatTypeSelectorEnum.all:
        return S.of(context).all;
      case ChatTypeSelectorEnum.directMessages:
        return S.of(context).directMessage;
      case ChatTypeSelectorEnum.groups:
        return S.of(context).groups;
    }
  }
}
