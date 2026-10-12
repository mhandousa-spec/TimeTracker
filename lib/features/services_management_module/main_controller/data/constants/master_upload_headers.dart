// ******************* FILE INFO *******************
// File Name: master_upload_headers
// Description: Expected Excel column headers for the master-upload screens.
// Module: services_management_module / data / constants
// *************************************************

/// Expected Excel column headers for the master-upload flow.
///
/// These are data constants (the literal column names that appear in the
/// uploaded spreadsheets, including the Arabic variants), not UI strings — so
/// they live in a constants file rather than being embedded in the page
/// widget (§13 / §15).
class MasterUploadHeaders {
  const MasterUploadHeaders._();

  // Individual column names (used for switch/validation keying).
  static const String serviceNameEn = 'Service Name';
  static const String serviceNameAr = 'اسم الخدمة';
  static const String serviceDescriptionEn = 'Service Description';
  static const String serviceDescriptionAr = 'وصف الخدمة';

  // Order restored to serviceNameEn/serviceNameAr and
  // serviceDescriptionEn/serviceDescriptionAr adjacency. In the table's
  // RTL header row, each Arabic-labeled box's text hugs its own right edge
  // and each English-labeled box's text hugs its own left edge — so the
  // two boxes that end up visually paired are whichever ones land next to
  // each other with those hugging edges facing one another. With this
  // order that's (nameAr, nameEn) and (descAr, descEn) — the correct
  // pairs. Swapping the order (as a prior revision of this file did)
  // instead pairs nameEn next to descAr and descEn next to nameAr,
  // producing the crossed "وصف الخدمة Service Name" /
  // "اسم الخدمة Service Description" mislabeling. Don't reorder this list
  // without re-tracing that adjacency.
  static const List<String> step1ExpectedHeaders = [
    serviceNameEn,
    serviceNameAr,
    serviceDescriptionEn,
    serviceDescriptionAr,
    'Duration of Service',
    'Time Unit',
    'Service Provider',
    'Limit Service Availability',
    'Departments',
    'Requires Approvals',
    'Approvers',
  ];

  /// Columns a Step-1 file cannot be parsed without. The remaining
  /// [step1ExpectedHeaders] entries are optional — a file may legitimately
  /// omit them (the shipped template leaves Departments/Approvers blank).
  static const List<String> step1RequiredHeaders = [
    serviceNameEn,
    serviceNameAr,
    serviceDescriptionEn,
    serviceDescriptionAr,
    'Duration of Service',
    'Time Unit',
    'Service Provider',
  ];

  static const List<String> step2ExpectedHeaders = [
    'Service Name',
    'Email Requester',
    'Service Provider',
    'Approvers',
    'State',
    'Requested Date',
  ];

  /// Columns a Step-2 file cannot be parsed without.
  static const List<String> step2RequiredHeaders = [
    'Service Name',
    'Email Requester',
    'State',
  ];
}