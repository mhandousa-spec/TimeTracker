/// Module: database / db3_create_table / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: table_comments_access.dart
/// Purpose: Declares `TableCommentsAccess`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The two values the "Comments Access" dropdown offers on the Creating Table
/// card — Figma `Columns type` 7398:8220 (iPad H) / 7398:8224 (iPad V), the
/// 208x90 popover with just Private and Shared in it.
///
/// The Figma also draws a hover card next to that dropdown (`Hover Stat`,
/// 7398:6706) spelling out what each value means. Those two sentences are the
/// enum's own vocabulary too, so they live here as [hintEn] / [hintAr] and the
/// card renders them — rather than being retyped next to the dropdown, where
/// they would drift from whatever the values actually do.

enum TableCommentsAccess {
  /// Only admins can view and manage the comments. The Figma shows this
  /// pre-selected, and it is the safe fallback for an unreadable value: least
  /// exposure, not most.
  private,

  /// All employees can view, reply to, and engage with the comments.
  shared;

  String get storageKey {
    switch (this) {
      case TableCommentsAccess.private:
        return 'private';
      case TableCommentsAccess.shared:
        return 'shared';
    }
  }

  String get labelEn {
    switch (this) {
      case TableCommentsAccess.private:
        return 'Private';
      case TableCommentsAccess.shared:
        return 'Shared';
    }
  }

  String get labelAr {
    switch (this) {
      case TableCommentsAccess.private:
        return 'خاص';
      case TableCommentsAccess.shared:
        return 'مشترك';
    }
  }

  /// The explanatory line from the Figma's hover card (7398:6709).
  String get hintEn {
    switch (this) {
      case TableCommentsAccess.private:
        return 'Private: Only admins can view and manage the comments.';
      case TableCommentsAccess.shared:
        return 'Shared: All employees can view, reply to, and engage with the '
            'comments.';
    }
  }

  String get hintAr {
    switch (this) {
      case TableCommentsAccess.private:
        return 'خاص: يمكن للمسؤولين فقط عرض التعليقات وإدارتها.';
      case TableCommentsAccess.shared:
        return 'مشترك: يمكن لجميع الموظفين عرض التعليقات والرد عليها '
            'والتفاعل معها.';
    }
  }

  String localizedLabel({required bool isArabic}) =>
      isArabic ? labelAr : labelEn;

  String localizedHint({required bool isArabic}) => isArabic ? hintAr : hintEn;

  static TableCommentsAccess fromStorageKey(String? key) {
    return TableCommentsAccess.values.firstWhere(
      (TableCommentsAccess access) => access.storageKey == key,
      orElse: () => TableCommentsAccess.private,
    );
  }
}
