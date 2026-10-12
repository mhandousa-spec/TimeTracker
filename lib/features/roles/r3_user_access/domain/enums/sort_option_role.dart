/// Module: roles / r3_user_access / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: sort_option_role.dart
/// Purpose: Declares `SortOptionRole`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Moved here from
///          `presentation/ui/widgets/filter_widget.dart`. It is a domain
///          concept and the cubit imported it, which meant a controller was
///          reaching into `presentation/ui/widgets/` for its vocabulary. Its
///          hardcoded English/Arabic label pairs were replaced by an
///          `S.of(context)` lookup that lives with the widget that renders it.

/// Sort keys the user-access list can be ordered by.
enum SortOptionRole {
  firstName,
  lastName,
  firstLogin,
  lastLogin;

  /// The options actually offered in the Sort menu.
  ///
  /// REDUCED 25/8/2026: first name and last name were dropped from the menu.
  ///
  /// The two VALUES stay in the enum on purpose. `UserAccessCubit
  /// .sortAccountsStatusEntities` still holds a working comparator for each,
  /// and keeping them means an in-flight or stored selection never becomes an
  /// unhandled case — deleting an enum value is a breaking change to every
  /// switch over it, a far bigger edit than removing two rows from a menu.
  ///
  /// The list lives here, beside the values, rather than as a `.where()` inside
  /// the dropdown: what the product offers is enum vocabulary, and one place to
  /// change it beats hunting for a filter in a widget.
  static const List<SortOptionRole> selectable = <SortOptionRole>[
    firstLogin,
    lastLogin,
  ];
}
