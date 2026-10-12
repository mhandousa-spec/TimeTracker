/// Module: messaging / home / domain/enum/sort_enum.dart
/// ************************* FILE INFO *************************** ///
/// File Name: sort_enum.dart
/// Purpose: Sort enum — messaging Home sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/cupertino.dart';

enum SortEnum {
  UnRead,
  ReadMessages;

  String label(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    switch (this) {
      case SortEnum.UnRead:
        return isAr ? 'غير مقروء' : 'Unread';
      case SortEnum.ReadMessages:
        return isAr ? 'الرسائل المقروءة' : 'Read Messages';
    }
  }
}