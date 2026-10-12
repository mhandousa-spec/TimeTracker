/// Module: GRC Policy Bulk Upload
/// Description: Shared dd-MM-yyyy date parsing/formatting for the bulk
///              upload sheet and its editable preview table. Both the Excel
///              parser (Task 2) and the per-row validator (Task 3) need the
///              same format so a value round-trips unchanged.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-11

/// ************************* FILE INFO *************************** ///
/// File Name: policy_bulk_date_format.dart
/// Purpose: Contains parsePolicyBulkDate() and formatPolicyBulkDate(), the
///          single source of truth for the bulk upload sheet's date format.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 11/7/2026

final RegExp _policyBulkDatePattern = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{4})$');

/// function name: [parsePolicyBulkDate]
///
/// purpose: parse a dd-MM-yyyy string (as typed in the bulk upload sheet or
///          preview table) into a [DateTime], rejecting anything that isn't
///          a real calendar date.
///
/// parameters:
///            [String] text: the raw cell/field text
///
/// return type: [DateTime?] - the parsed date, or null if [text] isn't a valid dd-MM-yyyy date
DateTime? parsePolicyBulkDate(String text) {
  final match = _policyBulkDatePattern.firstMatch(text.trim());
  if (match == null) return null;

  final day = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final year = int.parse(match.group(3)!);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;

  final date = DateTime(year, month, day);
  // DateTime normalizes out-of-range days (e.g. 31 April -> 1 May); reject those.
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

/// function name: [formatPolicyBulkDate]
///
/// purpose: format a [DateTime] back into the bulk upload sheet's
///          dd-MM-yyyy text representation.
///
/// parameters:
///            [DateTime] date: the date to format
///
/// return type: [String] - the dd-MM-yyyy formatted date
String formatPolicyBulkDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}-${two(date.month)}-${date.year}';
}
