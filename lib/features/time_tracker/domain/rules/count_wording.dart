/// Module: time_tracker / domain / rules
///
///*************************** FILE INFO ****************************///
/// File Name: count_wording.dart
/// Purpose: Declares `TimeTrackerCountWording` — a number with its noun in
///          correct English and Arabic grammar ("1 request" / "3 requests";
///          "طلب واحد" / "طلبان" / "3 طلبات" / "11 طلبا").
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (QA KP-TT-011)
///
/// QA KP-TT-011: the pending-approvals notification read "You currently
/// have 1 requests pending…" / "لديك حالياً 1 طلبات". The templates now hold
/// `{{countedRequests}}` — the number WITH its noun — filled from here in
/// both languages (both are stored; the reader's locale picks).
/// Arabic number agreement (the CLDR plural categories, by the last two
/// digits): 1 → "طلب واحد"; 2 → "طلبان"; 3–10 → "n طلبات"; 11–99 → "n طلبا";
/// 0 and 100, 101, 102, 200, … → "n طلب". Western digits, like every other
/// value in the notification texts (and the Cloud Functions' `texts.js`,
/// which uses the same rule). No tanween (house rule).
///
/// Pure Dart — unit-tested.

class TimeTrackerCountWording {
  const TimeTrackerCountWording._();

  /// Function Name: [requests]
  ///
  /// Purpose: [count] requests, worded for the language.
  ///
  /// Parameters:
  ///   [int] count: negative counts as 0.
  ///   [bool] arabic
  ///
  /// Return type: [String]
  static String requests(int count, {required bool arabic}) {
    final int n = count < 0 ? 0 : count;
    if (!arabic) return n == 1 ? '1 request' : '$n requests';
    if (n == 1) return 'طلب واحد';
    if (n == 2) return 'طلبان';
    final int lastTwo = n % 100;
    if (lastTwo >= 3 && lastTwo <= 10) return '$n طلبات';
    if (lastTwo >= 11 && lastTwo <= 99) return '$n طلبا';
    return '$n طلب';
  }
}
