// ******************* FILE INFO *******************
// File Name: table_dashboard
// Description: Table dashboard.
// Module: services_management_module / presentation/s11_admin_dashboard_mobile/ui/widgets
// *************************************************
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// 'dart:math' went with the _calculateWidthOf*() helpers — its only use here
// was math.max clamping those hand-computed column widths.
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> displayedItems;
  final Map<String, String> enToArDepartments;
  final String Function(dynamic, String) formatDate;
  final Color Function(String, BuildContext) getStatusColor;
  final String noText;
  final String jobTitleText;
  final String requesterDepartmentText;
  final String serviceNameText;
  final String serviceRequestorText;
  final String requestedDateText;
  final String statusText;
  final String serviceProviderText;
  final String doneText;
  final String pendingText;
  final String inprogressText;
  final String breachedSLAText;
  final String rejectedText;
  final String canceledText;
  final String approvedText;
  final Color? headerBackgroundColor;
  final Color? headerTextColor;
  final Color? evenRowColor;
  final Color? oddRowColor;
  final Color? textColor;

  const ServicesDataTable({
    Key? key,
    required this.displayedItems,
    required this.enToArDepartments,
    required this.formatDate,
    required this.getStatusColor,
    required this.noText,
    required this.jobTitleText,
    required this.requesterDepartmentText,
    required this.serviceNameText,
    required this.serviceRequestorText,
    required this.requestedDateText,
    required this.statusText,
    required this.serviceProviderText,
    required this.doneText,
    required this.pendingText,
    required this.inprogressText,
    required this.breachedSLAText,
    required this.rejectedText,
    required this.canceledText,
    required this.approvedText,
    this.headerBackgroundColor,
    this.headerTextColor,
    this.evenRowColor,
    this.oddRowColor,
    this.textColor,
  }) : super(key: key);

  // ══════════════════════════════════════════════════════════════════════════
  // ✅ Sort helper – descending by requestDate (new → old)
  //
  // FIXED (bug report p9, "show the latest request date first"): this sorted
  // ASCENDING, so the table opened on the OLDEST requests and the ones an
  // admin actually needs to act on were pushed to the bottom — past the fold
  // once the list is any length. Every comparison below is reversed (b vs a).
  //
  // Nulls still sort to the END rather than flipping to the top along with
  // the reversal: a row with no request date is the least useful thing to
  // lead with, whichever way the rest is ordered.
  // ══════════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> _sortedByRequestDateDescending() {
    final sorted = List<Map<String, dynamic>>.from(displayedItems);
    sorted.sort((a, b) {
      final dateA = a['requestDate'];
      final dateB = b['requestDate'];

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1; // nulls go to end
      if (dateB == null) return -1;

      // ── Firestore Timestamp ──
      if (dateA is Timestamp && dateB is Timestamp) {
        return dateB.compareTo(dateA);
      }

      // ── DateTime ──
      if (dateA is DateTime && dateB is DateTime) {
        return dateB.compareTo(dateA);
      }

      // ── String fallback ──
      //
      // ⚠️ Lexicographic, so it only orders correctly for a sortable format
      // such as ISO-8601. It cannot order a rendered label like
      // "٢٦ أغسطس ٢٠٢٦" — already true when this sorted ascending, and the
      // reversal does not make it worse. If display strings ever reach this
      // list, parse them into a DateTime upstream rather than widening this
      // branch.
      return dateB.toString().compareTo(dateA.toString());
    });
    return sorted;
  }

  String _getDepartmentDisplayName(
      BuildContext context, String departmentValue, String locale) {
    if (departmentValue.isEmpty) return '';

    if (departmentValue.contains(RegExp(r'[a-zA-Z]'))) {
      if (locale == 'ar') {
        return enToArDepartments[departmentValue] ?? departmentValue;
      }
      return departmentValue;
    }

    try {
      final departmentController = context.read<MainCoreDepartmentCubit>();
      final departmentName = departmentController.getDepartmentName(
        departmentValue,
        locale == 'en',
      );
      return departmentName ?? departmentValue;
    } catch (e) {
      return departmentValue;
    }
  }

  String _getJobTitleFromRequester(Map<String, dynamic> item, String locale) {

    // ✅ Check direct keys first (jobTitleRequester, jobTitleRequesterArabic)
    final jobTitleEnglish = item['jobTitleRequester']?.toString() ?? '';
    final jobTitleArabic = item['jobTitleRequesterArabic']?.toString() ?? '';

    // ✅ Return based on locale
    String jobTitle = locale == 'ar'
        ? (jobTitleArabic.isNotEmpty ? jobTitleArabic : jobTitleEnglish)
        : (jobTitleEnglish.isNotEmpty ? jobTitleEnglish : jobTitleArabic);

    if (jobTitle.isEmpty || jobTitle == 'null') {
      // ✅ Fallback to requesterData (old structure)
      final requesterData = item['requesterData'] as Map<String, dynamic>?;
      if (requesterData != null) {
        final jobTitleFromData = locale == 'ar'
            ? requesterData['jobTitleInArabic']?.toString() ??
            requesterData['jobTitle']?.toString()
            : requesterData['jobTitle']?.toString();

        if (jobTitleFromData != null &&
            jobTitleFromData.isNotEmpty &&
            jobTitleFromData != 'null') {
          jobTitle = jobTitleFromData;
        }
      }
    }

    if (jobTitle.isEmpty || jobTitle == 'null') {
      // ✅ Fallback to model data
      final model = item['model'];
      if (model != null) {
        final jobTitleFromModel = locale == 'ar'
            ? model.currentJobTitleRequesterArabic ??
            model.currentJobTitleRequester
            : model.currentJobTitleRequester ??
            model.currentJobTitleRequesterArabic;

        if (jobTitleFromModel != null &&
            jobTitleFromModel.isNotEmpty &&
            jobTitleFromModel != 'null') {
          jobTitle = jobTitleFromModel;
        }
      }
    }

    // ✅ Extract text between parentheses if it exists
    if (jobTitle.isNotEmpty && jobTitle != 'null') {
      final regex = RegExp(r'\(([^)]+)\)');
      final match = regex.firstMatch(jobTitle);

      if (match != null && match.group(1) != null) {
        final abbreviation = match.group(1)!;
        return abbreviation;
      }

      return jobTitle;
    }

    return '-';
  }

  String _getDepartmentFromRequester(
      BuildContext context, Map<String, dynamic> item, String locale) {

    // ✅ Check direct 'department' key first
    final departmentValue = item['department']?.toString() ?? '';

    if (departmentValue.isNotEmpty && departmentValue != 'null') {
      final displayName = _getDepartmentDisplayName(context, departmentValue, locale);
      return displayName;
    }

    // ✅ Fallback to requesterData (old structure)
    final requesterData = item['requesterData'] as Map<String, dynamic>?;
    if (requesterData != null) {
      final deptValue = requesterData['department']?.toString() ?? '';
      if (deptValue.isNotEmpty) {
        final displayName = _getDepartmentDisplayName(context, deptValue, locale);
        return displayName;
      }
    }

    // ✅ Fallback to model data
    final model = item['model'];
    if (model != null) {
      final deptValue = model.currentDepartmentRequester ?? '';
      if (deptValue.isNotEmpty) {
        final displayName = _getDepartmentDisplayName(context, deptValue, locale);
        return displayName;
      }
    }

    return '-';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ✅ Provider name helper with full fallback chain
  // ══════════════════════════════════════════════════════════════════════════
  String _getProviderName(Map<String, dynamic> item, String locale) {

    // ── 1️⃣ Try selectedProvider map (locale-matched) ──
    final selectedProvider =
        item['selectedProvider'] as Map<String, dynamic>? ?? {};

    String providerName = locale == 'ar'
        ? '${selectedProvider['firstNameInArabic'] ?? ''} ${selectedProvider['lastNameInArabic'] ?? ''}'
        .trim()
        : '${selectedProvider['firstName'] ?? ''} ${selectedProvider['lastName'] ?? ''}'
        .trim();

    if (providerName.isNotEmpty && providerName != 'null') {
      return providerName;
    }

    // ── 2️⃣ Try selectedProvider map (cross-locale fallback) ──
    providerName = locale == 'ar'
        ? '${selectedProvider['firstName'] ?? ''} ${selectedProvider['lastName'] ?? ''}'
        .trim()
        : '${selectedProvider['firstNameInArabic'] ?? ''} ${selectedProvider['lastNameInArabic'] ?? ''}'
        .trim();

    if (providerName.isNotEmpty && providerName != 'null') {
      return providerName;
    }

    // ── 3️⃣ Try direct keys on item map ──
    final directProvider = locale == 'ar'
        ? '${item['providerFirstNameArabic'] ?? item['providerFirstNameInArabic'] ?? ''} ${item['providerLastNameArabic'] ?? item['providerLastNameInArabic'] ?? ''}'
        .trim()
        : '${item['providerFirstName'] ?? ''} ${item['providerLastName'] ?? ''}'
        .trim();

    if (directProvider.isNotEmpty && directProvider != 'null') {
      return directProvider;
    }

    // Cross-locale fallback for direct keys
    final directProviderFallback = locale == 'ar'
        ? '${item['providerFirstName'] ?? ''} ${item['providerLastName'] ?? ''}'
        .trim()
        : '${item['providerFirstNameArabic'] ?? item['providerFirstNameInArabic'] ?? ''} ${item['providerLastNameArabic'] ?? item['providerLastNameInArabic'] ?? ''}'
        .trim();

    if (directProviderFallback.isNotEmpty &&
        directProviderFallback != 'null') {
      return directProviderFallback;
    }

    // ── 4️⃣ Try model object ──
    final model = item['model'];
    if (model != null) {
      try {
        // Try locale-matched from model
        final modelProvider = locale == 'ar'
            ? '${model.providerFirstNameArabic ?? model.providerFirstNameInArabic ?? ''} ${model.providerLastNameArabic ?? model.providerLastNameInArabic ?? ''}'
            .trim()
            : '${model.providerFirstName ?? ''} ${model.providerLastName ?? ''}'
            .trim();

        if (modelProvider.isNotEmpty && modelProvider != 'null') {
          return modelProvider;
        }

        // Cross-locale fallback from model
        final modelProviderFallback = locale == 'ar'
            ? '${model.providerFirstName ?? ''} ${model.providerLastName ?? ''}'
            .trim()
            : '${model.providerFirstNameArabic ?? model.providerFirstNameInArabic ?? ''} ${model.providerLastNameArabic ?? model.providerLastNameInArabic ?? ''}'
            .trim();

        if (modelProviderFallback.isNotEmpty &&
            modelProviderFallback != 'null') {
          return modelProviderFallback;
        }

        // ── 5️⃣ Try selectedProvider inside model ──
        final modelSelectedProvider = model.selectedProvider;
        if (modelSelectedProvider != null &&
            modelSelectedProvider is Map<String, dynamic>) {
          final msp = locale == 'ar'
              ? '${modelSelectedProvider['firstNameInArabic'] ?? ''} ${modelSelectedProvider['lastNameInArabic'] ?? ''}'
              .trim()
              : '${modelSelectedProvider['firstName'] ?? ''} ${modelSelectedProvider['lastName'] ?? ''}'
              .trim();

          if (msp.isNotEmpty && msp != 'null') {
            return msp;
          }

          // Cross-locale
          final mspFallback = locale == 'ar'
              ? '${modelSelectedProvider['firstName'] ?? ''} ${modelSelectedProvider['lastName'] ?? ''}'
              .trim()
              : '${modelSelectedProvider['firstNameInArabic'] ?? ''} ${modelSelectedProvider['lastNameInArabic'] ?? ''}'
              .trim();

          if (mspFallback.isNotEmpty && mspFallback != 'null') {
            return mspFallback;
          }
        }
      } catch (e) {
      }
    }

    return 'N/A';
  }

  // ── Gender helper for provider ──
  String _getProviderGender(Map<String, dynamic> item) {
    final selectedProvider =
        item['selectedProvider'] as Map<String, dynamic>? ?? {};
    final gender = selectedProvider['gender']?.toString() ?? '';
    if (gender.isNotEmpty && gender != 'null') return gender;

    // Fallback to model
    final model = item['model'];
    if (model != null) {
      try {
        final modelSelectedProvider = model.selectedProvider;
        if (modelSelectedProvider != null &&
            modelSelectedProvider is Map<String, dynamic>) {
          final mGender =
              modelSelectedProvider['gender']?.toString() ?? '';
          if (mGender.isNotEmpty && mGender != 'null') return mGender;
        }
      } catch (_) {}
    }

    return 'male';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REMOVED 31/8/2026 — the seven _calculateWidthOf*() helpers and
  // _calculateColumnWidths().
  //
  // They measured every value's character count, guessed a pixel width per
  // column, then redistributed leftover screen space between them. That
  // arithmetic existed only because the hand-built `Table` cannot size a
  // column from its own content. `DefaultDataTable` wraps Flutter's
  // `DataTable`, which measures each column for itself — the same reason the
  // System Logs table dropped its own hand-guessed widths when it moved onto
  // this component (see custom_table_body.dart's file header).
  //
  // Keeping them would have fought the DataTable: two independent opinions
  // about how wide "Department" should be, with the widest one winning and the
  // other showing as ragged padding.
  // ══════════════════════════════════════════════════════════════════════════


  String _getStatusDisplayText(
      String status, String locale, BuildContext context) {
    final statusLower = status.toLowerCase();
    if (locale == 'ar') {
      switch (statusLower) {
        case "done":
        case "approved":
          return doneText;
        case "pending":
          return pendingText;
        case "inprogress":
        case "in progress":
          return inprogressText;
        case "branchsla":
        case "breached sla":
          return breachedSLAText;
        case "rejected":
          return rejectedText;
        case "cancel":
        case "canceled":
        case "cancelled":
          return canceledText;
        default:
          return statusLower.isNotEmpty ? statusLower : "-";
      }
    }
    // ✅ English display mapping
    switch (statusLower) {
      case "done":
        return "Done";
      case "approved":
        return "Approved";
      case "pending":
        return "Pending";
      case "inprogress":
      case "in progress":
        return "In Progress";
      case "branchsla":
      case "breached sla":
        return "Breached SLA";
      case "rejected":
        return "Rejected";
      case "cancel":
      case "canceled":
      case "cancelled":
        return "Canceled";
      default:
        return statusLower.isNotEmpty ? _capitalize(statusLower) : "-";
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // ── Cells, styled to match the Roles tables ───────────────────────────────
  //
  // CHANGED 31/8/2026: these were start-aligned, hand-rolled TextStyles at
  // 14/13.sp inside 10.sp Padding, built for the old `Table`. They now match
  // System Logs / Active Directory cell for cell, because those two already
  // agreed on this component's look:
  //   • heading — 14.sp semibold, white, CENTRED over its column
  //   • value   — 12.sp semibold, CENTRED under its heading, single line with
  //               an ellipsis, and `-` when the value is empty
  // See system_logs_table_header.dart and custom_table_body.dart, whose file
  // headers record why each of those numbers is what it is.

  /// One heading, as a `DataColumn`.
  ///
  /// `headingRowAlignment` rather than a `Center` around the `Text`: DataTable
  /// lays a heading out in a Row that hands its child unbounded width, so a
  /// `Center` would centre nothing. It is direction-aware, so this reads the
  /// same in Arabic.
  DataColumn _headerColumn(String text) {
    return DataColumn(
      headingRowAlignment: MainAxisAlignment.center,
      label: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Text(
          text,
          style: StyleText.fontSize14Weight600
              .copyWith(color: AppColors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// A plain value cell.
  ///
  /// Height is pinned to 38.h like `CustomTableBody`, so a row never changes
  /// height because one cell wrapped.
  DataCell _cell(String text, BuildContext context, {Color? cellTextColor}) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final defaultColor = textColor ??
        (lightMode ? AppColors.black : AppColors.white);

    return DataCell(
      SizedBox(
        height: 38.h,
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text.isEmpty ? '-' : _capitalize(text),
            style: StyleText.fontSize12Weight600
                .copyWith(color: cellTextColor ?? defaultColor),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// A value cell carrying the person's avatar.
  ///
  /// The Roles tables have no equivalent — `CustomTableBody` is text only — so
  /// this keeps the avatar the Services dashboard has always shown and matches
  /// everything else about the cell: same 38.h, same 12.sp style, centred as a
  /// unit rather than pinned to the leading edge.
  DataCell _cellWithAvatar(String name, String? gender, BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final defaultColor = textColor ??
        (lightMode ? AppColors.black : AppColors.white);

    return DataCell(
      SizedBox(
        height: 38.h,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: SvgPicture.asset(
                gender == "male"
                    ? "assets/icons_assets/main_icons_assets/male_avatar.svg"
                    : "assets/icons_assets/main_icons_assets/female_avatar.svg",
                width: 25.sp,
                height: 25.sp,
              ),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                name.isEmpty ? '-' : _capitalize(name),
                style: StyleText.fontSize12Weight600
                    .copyWith(color: defaultColor),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The service rows, as `DataRow`s.
  ///
  /// Striping is `DataRow.color`, not a `BoxDecoration` on a `TableRow`:
  /// DataTable paints the row itself, and a coloured box nested in the cell
  /// would sit inside the cell padding instead of behind the whole row. The
  /// colour pair is the one System Logs and Active Directory share.
  List<DataRow> _tableRows(BuildContext context, String locale) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final evenColor = evenRowColor ??
        (lightMode ? AppColors.evenRowColor : AppColors.oddRowColor);
    final oddColor =
        oddRowColor ?? (lightMode ? AppColors.white : AppColors.black);

    final sortedItems = _sortedByRequestDateDescending();

    return [
      for (int index = 0; index < sortedItems.length; index++)
        _dataRow(
          context: context,
          locale: locale,
          item: sortedItems[index],
          index: index,
          rowColor: index.isEven ? evenColor : oddColor,
        ),
    ];
  }

  /// One service row. Every value is resolved exactly as the old `TableRow`
  /// builder resolved it — only the widgets around them changed.
  DataRow _dataRow({
    required BuildContext context,
    required String locale,
    required Map<String, dynamic> item,
    required int index,
    required Color rowColor,
  }) {
    final serviceName = locale == 'ar'
        ? item["serviceNameArabic"] ?? item["serviceName"] ?? ''
        : item["serviceName"] ?? '';

    final requestorName = locale == 'ar'
        ? item["requestorArabic"] ?? item["requestor"] ?? ''
        : item["requestor"] ?? '';

    final jobTitle = _getJobTitleFromRequester(item, locale);
    final requesterDepartment =
        _getDepartmentFromRequester(context, item, locale);
    final providerDisplayName = _getProviderName(item, locale);
    final providerGender = _getProviderGender(item);

    final status = (item["status"] ?? '').toString().toLowerCase();
    final statusDisplayText = _getStatusDisplayText(status, locale, context);

    return DataRow(
      color: WidgetStatePropertyAll(rowColor),
      cells: [
        _cell((index + 1).toString(), context),
        _cell(serviceName, context),
        _cellWithAvatar(requestorName, item["gender"], context),
        _cell(requesterDepartment, context),
        _cell(jobTitle, context),
        _cell(formatDate(item["requestDate"], locale), context),
        _cell(
          statusDisplayText,
          context,
          cellTextColor: getStatusColor(status, context),
        ),
        _cellWithAvatar(providerDisplayName, providerGender, context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    // CHANGED 31/8/2026: was a horizontally scrolling, hand-built `Table` with
    // computed column widths and a `TableRow` header painted by
    // headerBackgroundColor.
    //
    // It is r4's DefaultDataTable now — the same component the Roles screens
    // use — so the Services dashboard reads as the same table as System Logs
    // and Active Directory: dark heading band in AppColors.header, centred
    // labels, columns measured from their own content, and DefaultDataTable
    // owning the scrolling in BOTH axes (hence no SingleChildScrollView here
    // any more — a second scroll view would have fought it).
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.sp),
      child: DefaultDataTable(
        // The eight columns here measure narrower than the dashboard's content
        // area, and DefaultDataTable's horizontal scroll view hands the table
        // unbounded width — so without this the table sized to its content and
        // left a band of empty space beside it. Opt-in, so the Roles tables
        // that share this component keep the layout they already have.
        fillWidth: true,
        columns: [
          _headerColumn(noText),
          _headerColumn(serviceNameText),
          _headerColumn(serviceRequestorText),
          _headerColumn(requesterDepartmentText),
          _headerColumn(jobTitleText),
          _headerColumn(requestedDateText),
          _headerColumn(statusText),
          _headerColumn(serviceProviderText),
        ],
        rows: _tableRows(context, locale),
      ),
    );
  }
}
