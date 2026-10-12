/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: app_bar_enum.dart
/// Purpose: Enum `AppBarOptions` used by this feature.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

enum AppBarOptions {
  roles,
  userAcess,
  UserManagement,
  English;

  String get icon {
    switch (this) {
      default:
        return 'assets/icons_assets/roles_assets/roles_people_gear.svg';
    }
  }

  String get databaseName {
    switch (this) {
      case AppBarOptions.roles:
        return 'Roles';
      case AppBarOptions.userAcess:
        return 'User_Access';
      case AppBarOptions.UserManagement:
        return 'User_Management';
      case AppBarOptions.English:
        return 'English';
    }
  }
}
