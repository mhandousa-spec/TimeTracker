// ***************************** FILE INFO ***************************** //
// File Name: add_employee_relationship_option.dart
// Purpose: Defines emergency-contact relationship options.
// Author: Mohamed Elrashidy
// Created At: 2026-08-18
// ********************************************************************* //

import '../../../../../../generated/l10n.dart';

enum RelationshipOption {
  parent,
  spouse,
  sibling,
  child,
  relative,
  friend,
  other;

  String get value => name;

  String get title {
    switch (this) {
      case parent:
        return S.current.parent;
      case spouse:
        return S.current.spouse;
      case sibling:
        return S.current.sibling;
      case child:
        return S.current.child;
      case relative:
        return S.current.relative;
      case friend:
        return S.current.friend;
      case other:
        return S.current.other;
    }
  }
}
