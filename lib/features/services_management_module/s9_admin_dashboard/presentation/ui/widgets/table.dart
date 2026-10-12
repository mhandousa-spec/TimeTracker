// ******************* FILE INFO *******************
// File Name: table
// Description: Table.
// Module: services_management_module / presentation/s9_admin_dashboard/ui/widgets
// *************************************************

// ignore_for_file: unnecessary_string_interpolations
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

/// ===============================================================
/// SERVICE REQUEST TABLE WIDGET - FULL WIDTH RESPONSIVE
/// ===============================================================
/// UPDATED FOR NEW FIREBASE STRUCTURE:
/// - Personal data (name, department, job title) comes from
///   MainCoreEmployeeController (NOT from Firebase)
/// - Only Email_Requester is stored in Firebase
/// - All personal data is fetched via email lookup in controllers
/// - Table now takes full width of screen and distributes columns proportionally
/// ===============================================================

class ServiceRequestTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filteredItems;
  final String locale; // "ar" or "en"
  final String? selectStatus;
  final Function(Map<String, dynamic>)? onRowTap;
  final Map<String, String>? enToArDepartments;

  const ServiceRequestTableWidget({
    Key? key,
    required this.filteredItems,
    required this.locale,
    this.onRowTap,
    this.selectStatus,
    this.enToArDepartments,
  }) : super(key: key);

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  // ========== STYLE HELPERS ==========
  TextStyle get _headerStyle => StyleText.fontSize14Weight600.copyWith(
      color: AppColors.white
  );

  TextStyle _cellStyle(BuildContext context) => StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
      color: Theme.of(context).brightness == Brightness.light
          ? AppColors.blackButton
          : AppColors.white
  );

  // ========== FORMAT HELPERS ==========

  String _fmtInt(int n) => _toArabicDigits(n.toString());

  String _getStatusText(String status, BuildContext context) {
    final statusLower = status.toLowerCase();
    if (_isArabic) {
      switch (statusLower) {
        case "done": return S.of(context).Done;
        case "pending": return S.of(context).Pending;
        case "inprogress": return S.of(context).Inprogress;
        case "branchsla": return S.of(context).BreachedSLA;
        case "rejected": return S.of(context).Rejected;
        case "canceled":
        case "cancel": return S.of(context).Canceled;
        case "approved": return S.of(context).Approved;
        default: return status.isNotEmpty ? status : "-";
      }
    }

    switch (statusLower) {
      case "cancel":
      case "canceled":
        return "Canceled";
      default:
        return status.isNotEmpty ? FormatHelper.capitalize(status) : "-";
    }
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    switch (statusLower) {
      case "approved": return AppColors.green;
      case "done": return AppColors.green;
      case "inprogress": return AppColors.yellow;
      case "pending": return AppColors.orange;
      case "rejected": return AppColors.red;
      case "cancel":
      case "canceled": return AppColors.darkRed;
      case "branchsla":
      case "breached sla": return AppColors.orange;
      default: return AppColors.black;
    }
  }

  // ========== RESPONSIVE COLUMN WIDTH CALCULATIONS ==========

  Map<int, TableColumnWidth> _getResponsiveColumnWidths(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Reserve space for padding and borders
    final availableWidth = screenWidth - 40.w;

    if (selectStatus == "All") {
      // 9 columns: NO, Department, Service, Requester, Req Dept, Job Title, Date, Status, Provider
      return {
        0: FlexColumnWidth(0.5),  // NO - 5%
        1: FlexColumnWidth(.9),  // Department - 15%
        2: FlexColumnWidth(1.4),  // Service Name - 15%
        3: FlexColumnWidth(1.5),  // Requester - 15%
        4: FlexColumnWidth(1.5),  // Requester Department - 15%
        5: FlexColumnWidth(1.5),  // Job Title - 10%
        6: FlexColumnWidth(1.2),  // Date - 10%
        7: FlexColumnWidth(0.8),  // Status - 8%
        8: FlexColumnWidth(1.3),  // Provider - 12%
      };
    } else {
      // 8 columns: NO, Service, Requester, Req Dept, Job Title, Date, Status, Provider
      return {
        0: FlexColumnWidth(0.5),  // NO - 6%
        1: FlexColumnWidth(1.8),  // Service Name - 20%
        2: FlexColumnWidth(1.5),  // Requester - 17%
        3: FlexColumnWidth(1.5),  // Requester Department - 17%
        4: FlexColumnWidth(1.0),  // Job Title - 11%
        5: FlexColumnWidth(1.0),  // Date - 11%
        6: FlexColumnWidth(0.8),  // Status - 9%
        7: FlexColumnWidth(1.5),  // Provider - 15%
      };
    }
  }

  // ========== DATA EXTRACTION METHODS ==========

  String _getRequestNumber(Map<String, dynamic> item, int index) {
    final no = item["no"];
    if (no != null) {
      return _fmtInt(no is int ? no : int.tryParse(no.toString()) ?? (index + 1));
    }
    return _fmtInt(index + 1);
  }

  String _getDepartmentName(Map<String, dynamic> item) {
    final department = item["department"]?.toString() ?? '';

    if (department.isEmpty || department == 'null') {
      return 'N/A';
    }

    if (_isArabic && enToArDepartments != null) {
      return enToArDepartments![department] ?? department;
    }

    return department;
  }

  String _getServiceName(Map<String, dynamic> item) {
    if (_isArabic) {
      final arabicName = item['serviceNameArabic']?.toString() ?? '';
      if (arabicName.isNotEmpty && arabicName != 'null') {
        return arabicName;
      }
    }

    final serviceName = item['serviceName']?.toString() ?? '';
    return (serviceName.isNotEmpty && serviceName != 'null') ? serviceName : 'N/A';
  }

  String _getRequesterName(Map<String, dynamic> item) {
    if (_isArabic) {
      // ✅ Try Arabic fields first
      final firstAr = item["firstNameRequesterArabic"]?.toString().trim() ?? '';
      final lastAr  = item["lastNameRequesterArabic"]?.toString().trim() ?? '';
      final nameAr  = '$firstAr $lastAr'.trim();
      if (nameAr.isNotEmpty &&
          !nameAr.toLowerCase().contains('null') &&
          nameAr.length > 1) {
        return nameAr;
      }

      // ✅ Also try "requestorArabic" key (used in DashBoardMasterMobile)
      final requestorAr = item["requestorArabic"]?.toString().trim() ?? '';
      if (requestorAr.isNotEmpty &&
          !requestorAr.toLowerCase().contains('null') &&
          requestorAr.length > 1) {
        return requestorAr;
      }
    }

    // English fallback
    final requestor = item["requestor"]?.toString().trim() ?? '';
    if (requestor.isNotEmpty && !requestor.toLowerCase().contains('null')) {
      return requestor;
    }

    final firstEn = item["firstNameRequester"]?.toString().trim() ?? '';
    final lastEn  = item["lastNameRequester"]?.toString().trim() ?? '';
    final nameEn  = '$firstEn $lastEn'.trim();
    return (nameEn.isNotEmpty && !nameEn.toLowerCase().contains('null'))
        ? nameEn
        : 'N/A';
  }

  String _getRequesterDepartment(Map<String, dynamic> item) {
    final department = item["department"]?.toString() ?? '';

    if (department.isEmpty || department == 'null') {
      return 'N/A';
    }

    if (_isArabic && enToArDepartments != null) {
      return enToArDepartments![department] ?? department;
    }

    return department;
  }

  String _getRequesterJobTitle(Map<String, dynamic> item) {
    String jobTitle = '';

    if (_isArabic) {
      final arabicJobTitle = item["jobTitleRequesterArabic"]?.toString() ?? '';
      if (arabicJobTitle.isNotEmpty && arabicJobTitle != 'null') {
        jobTitle = arabicJobTitle;
      } else {
        jobTitle = item["jobTitleRequester"]?.toString() ?? '';
      }
    } else {
      jobTitle = item["jobTitleRequester"]?.toString() ?? '';
    }

    if (jobTitle.isEmpty || jobTitle == 'null') {
      return 'N/A';
    }

    // Extract abbreviation from parentheses if present
    final regex = RegExp(r'\(([^)]+)\)');
    final match = regex.firstMatch(jobTitle);

    if (match != null && match.group(1) != null) {
      return match.group(1)!;
    }

    return jobTitle;
  }

  String _getRequestDate(Map<String, dynamic> item, {bool isArabic = false}) {
    final dateValue = item["requestDate"];

    if (dateValue == null ||
        dateValue.toString().isEmpty ||
        dateValue.toString() == 'null') {
      return 'N/A';
    }

    DateTime? dt;

    if (dateValue is Timestamp) {
      dt = dateValue.toDate();
    } else if (dateValue is Map && dateValue.containsKey('seconds')) {
      final seconds = int.tryParse('${dateValue['seconds']}');
      if (seconds != null) {
        dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
    } else if (dateValue is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(
        dateValue > 1000000000000 ? dateValue : dateValue * 1000,
      );
    } else {
      final dateStr = dateValue.toString().trim();
      dt = _parseDateString(dateStr);
    }

    if (dt == null) return dateValue.toString();

    return _formatAsDDMonYYYY(dt,);
  }

  String _getStatus(Map<String, dynamic> item, BuildContext context) {
    final status = item["status"]?.toString() ?? '';
    return _getStatusText(status, context);
  }

  String? _getRequesterGender(Map<String, dynamic> item) {
    return item["gender"]?.toString();
  }

  String? _getProviderGender(Map<String, dynamic> item) {
    final selectedProvider = item["selectedProvider"];
    if (selectedProvider is Map) {
      return selectedProvider["gender"]?.toString();
    }
    return null;
  }

  String _getProviderName(Map<String, dynamic> item, BuildContext context) {
    if (_isArabic) {
      // ✅ Try individual Arabic provider fields first
      final firstAr = item["firstNameProviderArabic"]?.toString().trim() ?? '';
      final lastAr  = item["lastNameProviderArabic"]?.toString().trim() ?? '';
      final nameAr  = '$firstAr $lastAr'.trim();
      if (nameAr.isNotEmpty &&
          !nameAr.toLowerCase().contains('null') &&
          nameAr.length > 1) {
        return nameAr;
      }

      // ✅ Try selectedProvider map Arabic fields
      final selectedProvider = item["selectedProvider"];
      if (selectedProvider is Map) {
        final spFirstAr = selectedProvider['firstNameInArabic']?.toString().trim() ?? '';
        final spLastAr  = selectedProvider['lastNameInArabic']?.toString().trim() ?? '';
        final spNameAr  = '$spFirstAr $spLastAr'.trim();
        if (spNameAr.isNotEmpty &&
            !spNameAr.toLowerCase().contains('null') &&
            spNameAr.length > 1) {
          return spNameAr;
        }
      }
    }

    // ✅ English: try pre-computed "provider" field
    final preComputed = item["provider"]?.toString().trim() ?? '';
    if (preComputed.isNotEmpty &&
        preComputed != 'null' &&
        preComputed != 'N/A') {
      return preComputed;
    }

    // ✅ English individual fields
    final firstEn = item["firstNameProvider"]?.toString().trim() ?? '';
    final lastEn  = item["lastNameProvider"]?.toString().trim() ?? '';
    final nameEn  = '$firstEn $lastEn'.trim();
    if (nameEn.isNotEmpty && !nameEn.toLowerCase().contains('null') && nameEn.length > 1) {
      return nameEn;
    }

    // ✅ selectedProvider map English fallback
    final selectedProvider = item["selectedProvider"];
    if (selectedProvider is Map) {
      final spFirstEn = selectedProvider['firstName']?.toString().trim() ?? '';
      final spLastEn  = selectedProvider['lastName']?.toString().trim() ?? '';
      final spNameEn  = '$spFirstEn $spLastEn'.trim();
      if (spNameEn.isNotEmpty &&
          !spNameEn.toLowerCase().contains('null') &&
          spNameEn.length > 1) {
        return spNameEn;
      }
    }

    return 'N/A';
  }

  // ========== CELL BUILDERS ==========

  Widget _cell(BuildContext context, Widget child, {EdgeInsets? padding, Alignment? align}) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: _cellStyle(context),
        child: child,
      ),
    );
  }

  Widget _textCell(BuildContext context, String text, {
    int maxLines = 2,
    TextAlign textAlign = TextAlign.start,
    Color? textColor,
    FontWeight? fontWeight,
  }) {
    return _cell(
      context,
      Text(
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: _cellStyle(context).copyWith(
          color: textColor,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  Widget _personCell(BuildContext context, String name, bool isMale) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final rowChildren = <Widget>[
      isArabic
          ? Flexible(
        child: Text(
          FormatHelper.capitalize(name),
          overflow: TextOverflow.ellipsis,
          textAlign: _isArabic ? TextAlign.end : TextAlign.start,
          style: _cellStyle(context),
        ),
      )
          : ClipOval(
        child: SvgPicture.asset(
          isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
          width: 22.sp,
          height: 22.sp,
        ),
      ),
      SizedBox(width: 6.w),
      isArabic
          ? ClipOval(
        child: SvgPicture.asset(
          isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
          width: 22.sp,
          height: 22.sp,
        ),
      )
          : Flexible(
        child: Text(
          FormatHelper.capitalize(name),
          overflow: TextOverflow.ellipsis,
          textAlign: _isArabic ? TextAlign.end : TextAlign.start,
          style: _cellStyle(context),
        ),
      ),
    ];

    return _cell(
      context,
      Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _isArabic ? rowChildren.reversed.toList() : rowChildren,
        ),
      ),
    );
  }

  Widget _rowTapWrapper(BuildContext context, Widget child, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: child,
    );
  }

  // ========== DATE FORMATTING ==========

  String _formatAsDDMonYYYY(DateTime dt) {
    const monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const monthsAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];

    final month = _isArabic ? monthsAr[dt.month - 1] : monthsEn[dt.month - 1];
    final day  = _isArabic ? _toArabicDigits(dt.day.toString())  : dt.day.toString();
    final year = _isArabic ? _toArabicDigits(dt.year.toString()) : dt.year.toString();

    return '$day $month $year';
    // Arabic result:  ١١ فبراير ٢٠٢٦
    // English result: 11 Feb 2026
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    if (dateValue is Timestamp) {
      return _formatAsDDMonYYYY(dateValue.toDate());
    }

    if (dateValue is Map && dateValue.containsKey('value')) {
      dateValue = dateValue['value'];
    }

    if (dateValue is Map && dateValue.containsKey('seconds')) {
      final secs = int.tryParse('${dateValue['seconds']}');
      if (secs != null) {
        return _formatAsDDMonYYYY(DateTime.fromMillisecondsSinceEpoch(secs * 1000));
      }
    }

    DateTime? dt;

    if (dateValue is DateTime) {
      dt = dateValue;
    } else if (dateValue is int) {
      if (dateValue > 1000000000000) {
        dt = DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else {
        dt = DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
      }
    } else {
      final s = dateValue.toString().trim();
      if (s.isEmpty || s == 'null') return 'N/A';

      dt = _parseDateString(s);
    }

    if (dt == null) {
      return dateValue.toString();
    }
    return _formatAsDDMonYYYY(dt);
  }

  DateTime? _parseDateString(String dateString) {
    dateString = dateString.trim();

    // W10: no try/catch — DateTime.tryParse / int.tryParse return null on failure.
    if (dateString.contains('T') || dateString.contains('-')) {
      final parsed = DateTime.tryParse(dateString);
      if (parsed != null) return parsed;
    }

    final regexDate = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
    final match = regexDate.firstMatch(dateString);
    if (match != null) {
      final year = int.tryParse(match.group(1)!);
      final month = int.tryParse(match.group(2)!);
      final day = int.tryParse(match.group(3)!);
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    if (dateString.contains('/')) {
      final parts = dateString.split('/');
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    }

    final timestamp = int.tryParse(dateString);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        timestamp > 1000000000000 ? timestamp : timestamp * 1000,
      );
    }

    return null;
  }

  String _toArabicDigits(String input) {
    if (!_isArabic) return input;

    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    String result = input;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], arabicDigits[i]);
    }
    return result;
  }

  bool _isMaleGender(String? gender) {
    return gender?.toString().toLowerCase() == 'male';
  }

  // ========== BUILD METHOD ==========

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    bool isArabicText(String text) => RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text);
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Column headers
    final headers = selectStatus == "All"
        ? <String>[
      S.of(context).number,
      S.of(context).Department,
      S.of(context).ServiceName,
      S.of(context).ServiceRequestor,
      _isArabic ? "قسم الطالب" : "Requester Department",
      _isArabic ? "مسمى الوظيفة" : "Job Title",
      S.of(context).RequestedDate,
      S.of(context).Status,
      S.of(context).ServiceProvider,
    ]
        : <String>[
      S.of(context).number,
      S.of(context).ServiceName,
      S.of(context).ServiceRequestor,
      _isArabic ? "قسم الطالب" : "Requester Department",
      _isArabic ? "مسمى الوظيفة" : "Job Title",
      S.of(context).RequestedDate,
      S.of(context).Status,
      S.of(context).ServiceProvider,
    ];

    // Get responsive column widths
    final columnWidths = _getResponsiveColumnWidths(context);

    return Directionality(
      textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth, // Take full available width
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.sp),
              child: Table(
                border: TableBorder.all(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: columnWidths,
                children: [
                  // Header Row
                  TableRow(
                    decoration: BoxDecoration(
                        color: lightMode ? AppColors.black : AppColors.black.withOpacity(0.45)
                    ),
                    children: headers.map((name) =>
                        Directionality(
                          textDirection: isArabicText(name) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                          child: Padding(
                            padding: EdgeInsets.all(10.sp),
                            child: Text(
                              name,
                              style: _headerStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                    ).toList(),
                  ),

                  // Data Rows
                  ...List.generate(filteredItems.length, (index) {
                    final item = filteredItems[index];

                    final isEven = index.isEven;
                    final rowColor = lightMode
                        ? (isEven ?  AppColors.tableLightBackground : AppColors.white)
                        : (isEven ?  AppColors.tableDarkBackground : AppColors.black);

                    VoidCallback handleTap = () {
                      if (onRowTap != null) {
                        onRowTap!(item);
                      }
                    };

                    // Get all data using methods
                    final requestNumber = _getRequestNumber(item, index);
                    final departmentName = _getDepartmentName(item);
                    final serviceName = _getServiceName(item);
                    final requesterName = _getRequesterName(item);
                    final requesterDepartment = _getRequesterDepartment(item);
                    final requesterJobTitle = _getRequesterJobTitle(item);
                    final requestDate = _getRequestDate(item);
                    final statusText = _getStatus(item, context);
                    final statusColor = _getStatusColor(item["status"]?.toString() ?? '');
                    final providerName = _getProviderName(item, context);

                    // Get gender information
                    final requesterGender = _getRequesterGender(item);
                    final providerGender = _getProviderGender(item);
                    final isRequesterMale = _isMaleGender(requesterGender);
                    final isProviderMale = _isMaleGender(providerGender);

                    return TableRow(
                      decoration: BoxDecoration(color: rowColor),
                      children: selectStatus == "All" ? [
                        // All view - WITH Department column
                        _rowTapWrapper(context, _textCell(context, requestNumber, maxLines: 1), handleTap),
                        _rowTapWrapper(context, _textCell(context, departmentName), handleTap),
                        _rowTapWrapper(context, _textCell(context, serviceName), handleTap),
                        _rowTapWrapper(context, _personCell(context, requesterName, isRequesterMale), handleTap),
                        _rowTapWrapper(context, _textCell(context, requesterDepartment), handleTap),
                        _rowTapWrapper(context, _textCell(context, requesterJobTitle), handleTap),
                        _rowTapWrapper(context, _textCell(context, requestDate, maxLines: 1), handleTap),
                        _rowTapWrapper(context, _textCell(context, statusText, textColor: statusColor, fontWeight: FontWeight.w600), handleTap),
                        _rowTapWrapper(context, _personCell(context, providerName, isProviderMale), handleTap),
                      ] : [
                        // Filtered view - WITHOUT Department column
                        _rowTapWrapper(context, _textCell(context, requestNumber, maxLines: 1), handleTap),
                        _rowTapWrapper(context, _textCell(context, serviceName), handleTap),
                        _rowTapWrapper(context, _personCell(context, requesterName, isRequesterMale), handleTap),
                        _rowTapWrapper(context, _textCell(context, requesterDepartment), handleTap),
                        _rowTapWrapper(context, _textCell(context, requesterJobTitle), handleTap),
                        _rowTapWrapper(context, _textCell(context, requestDate, maxLines: 1), handleTap),
                        _rowTapWrapper(context, _textCell(context, statusText, textColor: statusColor, fontWeight: FontWeight.w600), handleTap),
                        _rowTapWrapper(context, _personCell(context, providerName, isProviderMale), handleTap),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
