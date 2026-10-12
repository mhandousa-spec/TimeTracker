/// Module: roles / r5_system_logs / domain / enums
///
import 'package:knowticed_plus/features/roles/r5_system_logs/data/models/system_logs_model.dart';

import 'package:knowticed_plus/core/helper/main_helper/date_time_helper.dart';

///*********************** FILE INFO ********************///
/// FILE NAME: system_logs_items.dart
/// Purpose: to have all the items that will be shown in the system logs
/// Author: Amr Mesbah
/// Created at: 29/1/2025

enum SystemLogsItems {
  firstName,
  middleName,
  lastName,
  role,
  country,
  city,
  date,
  time,
  lat,
  long,
  module,
  action;

  String get name {
    switch (this) {
      case SystemLogsItems.firstName:
        return 'First Name';
      case SystemLogsItems.middleName:
        return 'Middle Name';
      case SystemLogsItems.lastName:
        return 'Last Name';
      case SystemLogsItems.role:
        return 'Role';
      case SystemLogsItems.country:
        return 'Country';
      case SystemLogsItems.city:
        return 'City';
      case SystemLogsItems.date:
        return 'Date';
      case SystemLogsItems.time:
        return 'Time';
      case SystemLogsItems.lat:
        return 'Lat';
      case SystemLogsItems.long:
        return 'Long';
      case SystemLogsItems.action:
        return 'Action';
      case SystemLogsItems.module:
        return 'Module';
    }
  }

  /// Method Name: [itemValue]
  ///
  /// Description: this method will return the value of the item based on the model.
  ///
  /// Parameters:
  ///            [SystemLogsModel] model: the model that will be used to get the value
  ///            [bool] isArabic: selects the Arabic name fields
  ///
  /// Returns: [String] the value of the item or empty string if the value is null
  ///
  /// The three name cases used to read `Get.locale` directly. A `domain/` file
  /// must be framework-pure (§3) and GetX is banned, so the caller — which has
  /// a BuildContext — passes the locale in.
  String itemValue(SystemLogsModel model, {required bool isArabic}) {
    switch (this) {
      case SystemLogsItems.firstName:
        return !isArabic
            ? model.firstName ?? ""
            : model.firstNameInArabic ?? "";
      case SystemLogsItems.middleName:
        return !isArabic
            ? model.middleName ?? ""
            : model.middleNameInArabic ?? "";
      case SystemLogsItems.lastName:
        return !isArabic
            ? model.lastName ?? ""
            : model.lastNameInArabic ?? "";
      case SystemLogsItems.role:
        return model.role ?? "";
      case SystemLogsItems.country:
        return model.country ?? "";
      case SystemLogsItems.city:
        return model.city ?? "";
      case SystemLogsItems.date:
        // CHANGED 30/8/2026: was `formatDateTimeMMMDDYYYY`, i.e. "MMM dd, yyyy"
        // — on an Arabic screen that came out as "أغسطس 30, 2026": month
        // first, with a comma, the one date shape nothing else in the app
        // uses. The column now reads "30 Aug 2026" / "30 أغسطس 2026", day
        // first and no comma, like every other date in the product. The
        // language comes from the `isArabic` argument this method already
        // takes, so the formatter no longer reads `Get.locale` from `domain/`.
        return DateTimeHelper.formatDateDDMMMYYYYForLocale(
          model.timestamp?.toDate(),
          isArabic: isArabic,
        );

      case SystemLogsItems.time:
        return DateTimeHelper.formatDateTimeHHMM(model.timestamp!.toDate());
      case SystemLogsItems.lat:
        return model.lat ?? "";
      case SystemLogsItems.long:
        return model.long ?? "";
      case SystemLogsItems.action:
        return model.action ?? "";
      case SystemLogsItems.module:
        return model.module?.name ?? "";
    }
    // REMOVED 12/8/2026: an unreachable `default:` branch and a trailing
    // `return "";` — the switch above returns on every one of the 12 enum
    // values, so the analyzer flagged both as dead.
  }
}
