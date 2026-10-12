/// Module: services_management_module
/// Description: Pure duration-unit localization helper for the home
///              services page (maps free-text unit abbreviations —
///              "hr"/"hrs"/"hour" etc. — to a canonical unit, then to its
///              localized display string). Also hosts formatStartDate, a
///              pure Timestamp/DateTime -> display-string formatter.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: generated/l10n.dart (S), cloud_firestore (Timestamp), intl
/// Revision History:
///   - 02/07/2026 (Knowticed Team): Extracted from home_page_services.dart
///     (fix item 1c — build-method/class-size decomposition).
///   - 02/07/2026 (Knowticed Team): Added formatStartDate — moved from
///     home_page_services.dart to bring the page back under the 800-LOC
///     target.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class HomeServicesDurationUtils {
  const HomeServicesDurationUtils._();

  /// Formats a Firestore [Timestamp] or [DateTime] as "dd MMM yyyy".
  /// Returns '-' for null or any other type.
  static String formatStartDate(dynamic timestampOrDateTime) {
    if (timestampOrDateTime == null) return '-';

    DateTime date;

    if (timestampOrDateTime is Timestamp) {
      date = timestampOrDateTime.toDate();
    } else if (timestampOrDateTime is DateTime) {
      date = timestampOrDateTime;
    } else {
      return '-';
    }

    return DateFormat('dd MMM yyyy').format(date);
  }

  static String getLocalizedDurationUnit(S localizer, String? rawUnit) {
    if (rawUnit == null) return '';

    final k = rawUnit.trim().toLowerCase();

    String canonical;
    switch (k) {
      case 'h':
      case 'hr':
      case 'hrs':
      case 'hour':
      case 'hours':
        canonical = 'hours';
        break;
      case 'm':
      case 'min':
      case 'mins':
      case 'minute':
      case 'minutes':
        canonical = 'minutes';
        break;
      case 's':
      case 'sec':
      case 'secs':
      case 'second':
      case 'seconds':
        canonical = 'seconds';
        break;
      case 'w':
      case 'wk':
      case 'wks':
      case 'week':
      case 'weeks':
        canonical = 'week';
        break;
      case 'd':
      case 'day':
      case 'days':
        canonical = 'day';
        break;
      case 'mo':
      case 'month':
      case 'months':
        canonical = 'month';
        break;
      case 'y':
      case 'yr':
      case 'yrs':
      case 'year':
      case 'years':
        canonical = 'year';
        break;
      default:
        return rawUnit;
    }

    switch (canonical) {
      case 'hours':
        return localizer.hours;
      case 'minutes':
        return localizer.minutes;
      case 'seconds':
        return localizer.seconds;
      case 'week':
        return localizer.week;
      case 'day':
        return localizer.day;
      case 'month':
        return localizer.month;
      case 'year':
        return localizer.year;
      default:
        return rawUnit;
    }
  }
}
