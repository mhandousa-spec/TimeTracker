// ******************* FILE INFO *******************
// File Name: table
// Description: Table.
// Module: services_management_module / presentation/s5_service_details/ui/widgets
// *************************************************
import 'package:get/get.dart';


// 'dart:math' removed 31/8/2026 — nothing in this file used it.
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/pages/approval_request_details_toggle.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TableDetailsServicesWidget extends StatelessWidget {
  final BuildContext context;
  final ServicesHistoryModel parentModel;
  final List<Map<String, dynamic>> map;
  final String locale;

  TableDetailsServicesWidget({
    Key? key,
    required this.context,
    required this.parentModel,
    required this.map,
    required this.locale,
  }) : super(key: key);

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  // ✅ Get controllers
  MainCoreEmployeeController get _employeeController => AppControllers.employee;
  MainCoreDepartmentCubit _departments(BuildContext context) =>
      context.read<MainCoreDepartmentCubit>();

  // Status color mapping
  final Map<String, Color> _statusTextColors = {
    'approved': AppColors.green,
    'done': AppColors.lightGreen,
    'rejected': AppColors.red,
    'pending': AppColors.pending,
    'inprogress': AppColors.secondaryPrimary,
    'cancel': AppColors.red,
    'canceled': AppColors.red,
    'breached sla': AppColors.red,
    'branchsla': AppColors.red,
  };

  // Status localization map
  final Map<String, String> statusLocalizationMap = {
    "approved": "تمت الموافقة",
    "done": "تم",
    "cancel": "أُلغي",
    "rejected": "مرفوض",
    "inprogress": "قيد التنفيذ",
    "branchsla": "انتهت المهلة",
    "breached sla": "انتهت المهلة",
    "pending": "قيد الانتظار",
    "active": "نشط",
    "inactive": "غير نشط",
  };

  TextStyle get _headerStyle => StyleText.fontSize14Weight600.copyWith(
    color: AppColors.white,
  );

  /// CHANGED 31/8/2026: 12.sp semibold, matching System Logs / Active
  /// Directory (see custom_table_body.dart) and the Services dashboard table.
  /// Was `font13SecondaryBlackCairo` — a size that existed nowhere else in the
  /// app's tables.
  TextStyle _cellStyle(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return StyleText.fontSize12Weight600.copyWith(
        color: lightMode ? AppColors.black : AppColors.white);
  }

  String _toArabicDigits(String input) {
    if (!_isArabic) return input;
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var out = input;
    for (var i = 0; i < en.length; i++) {
      out = out.replaceAll(en[i], ar[i]);
    }
    return out;
  }

  String _fmtInt(int n) => _toArabicDigits(n.toString());

  /// The body of one cell.
  ///
  /// CHANGED 31/8/2026: height pinned to 38.h and centred, so a row never
  /// changes height and each value sits under the middle of its heading —
  /// `CustomTableBody`'s shape, which is what the Roles tables use. The old
  /// `Container` with 10/8.sp padding and start-aligned text belonged to the
  /// hand-built `Table` this file no longer renders.
  Widget _cell(BuildContext context, Widget child) {
    return SizedBox(
      height: 38.h,
      child: Align(
        alignment: Alignment.center,
        child: DefaultTextStyle.merge(
          style: _cellStyle(context),
          child: child,
        ),
      ),
    );
  }

  Widget _textCell(BuildContext context, String text,
      {int maxLines = 1, TextAlign textAlign = TextAlign.center, Color? textColor}) {
    return _cell(
      context,
      Text(
        FormatHelper.capitalize(text.isEmpty ? '-' : text),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        style: textColor != null ? _cellStyle(context).copyWith(color: textColor) : null,
      ),
    );
  }

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
          style: _headerStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _requesterCell(BuildContext context, Map<String, dynamic> item) {
    final model = item['model'] as ServicesHistoryModel;

    String email = '';
    if (model.currentEmailRequester != null && model.currentEmailRequester.isNotEmpty) {
      email = model.currentEmailRequester;
    }

    String requester = '-';
    String? gender = 'male';

    if (email.isNotEmpty) {
      requester = _employeeController.getEmployeeNameEnglishArabic(email, !_isArabic);
      final employee = _employeeController.mapOfEmployeesWithEmailKey[email];
      gender = employee?.gender?.toLowerCase() ?? 'male';
    }

    final isMale = (gender ?? 'male') == 'male';

    final rowChildrenEn = <Widget>[
      ClipOval(
        child: SvgPicture.asset(
          isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
          width: 22.sp,
          height: 22.sp,
        ),
      ),
      SizedBox(width: 6.w),
      Flexible(
        child: Text(
          FormatHelper.capitalize(requester.trim().isEmpty ? '-' : requester.trim()),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
        ),
      ),
    ];

    final rowChildrenAr = <Widget>[
      ClipOval(
        child: SvgPicture.asset(
          isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
          width: 22.sp,
          height: 22.sp,
        ),
      ),
      SizedBox(width: 6.w),
      Flexible(
        child: Text(
          requester.trim().isEmpty ? '-' : requester.trim(),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
        ),
      ),
    ];

    return _cell(
      context,
      Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _isArabic ? rowChildrenAr : rowChildrenEn,
        ),
      ),
    );
  }

  Widget _providerCell(BuildContext context, Map<String, dynamic> item) {
    final model = item['model'] as ServicesHistoryModel;

    String providerName = '-';
    String? providerGender;

    if (model.currentProviderServices != null && model.currentProviderServices.isNotEmpty) {
      // ✅ FIX: Match assigned provider email instead of always using .first
      final assignedEmail = model.currentAssignedProviderEmail?.toLowerCase().trim() ?? '';

      EmployeeEntityModell? provider;

      if (assignedEmail.isNotEmpty) {
        for (final p in model.currentProviderServices) {
          if ((p.email?.toLowerCase().trim() ?? '') == assignedEmail) {
            provider = p;
            break;
          }
        }
      }

      // Fallback to first if no match found
      provider ??= model.currentProviderServices.first;

      if (_isArabic) {
        providerName = "${provider.firstNameInArabic ?? ''} ${provider.lastNameInArabic ?? ''}".trim();
        if (providerName.isEmpty) {
          providerName = "${provider.firstName ?? ''} ${provider.lastName ?? ''}".trim();
        }
      } else {
        providerName = "${provider.firstName ?? ''} ${provider.lastName ?? ''}".trim();
      }

      providerGender = provider.gender?.toLowerCase();
    }

    if (providerName.isEmpty || providerName == '') {
      return _textCell(context, '-');
    }

    final isMale = (providerGender ?? 'male') == 'male';

    final rowChildrenEn = <Widget>[
      ClipOval(
        child: SvgPicture.asset(
          isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
          width: 22.sp,
          height: 22.sp,
        ),
      ),
      SizedBox(width: 6.w),
      Flexible(
        child: Text(
          FormatHelper.capitalize(providerName),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
        ),
      ),
    ];

    final rowChildrenAr = <Widget>[
      ClipOval(
        child: SvgPicture.asset(
          isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
          width: 22.sp,
          height: 22.sp,
        ),
      ),
      SizedBox(width: 6.w),
      Flexible(
        child: Text(
          providerName,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.start,
        ),
      ),
    ];

    return _cell(
      context,
      Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _isArabic ? rowChildrenAr : rowChildrenEn,
        ),
      ),
    );
  }


  Color _getStatusColor(String status, BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return _statusTextColors[status.toLowerCase()] ??
        (lightMode ? AppColors.secondaryText : AppColors.white);
  }

  // ✅ UPDATED - Dynamic department fetching
  String _getDepartmentText(ServicesHistoryModel model) {
    String email = '';
    if (model.currentEmailRequester != null && model.currentEmailRequester.isNotEmpty) {
      email = model.currentEmailRequester;
    }

    if (email.isEmpty) return '-';

    // Get employee from controller
    final employee = _employeeController.mapOfEmployeesWithEmailKey[email];

    if (employee == null || employee.departmentId == null) {
      return '-';
    }

    // ✅ Use department controller to get department name dynamically
    return _departments(context)
            .getDepartmentName(employee.departmentId!, _isArabic ? false : true) ??
        '-';
  }

  String _getJobTitle(ServicesHistoryModel model) {
    String email = '';
    if (model.currentEmailRequester != null && model.currentEmailRequester.isNotEmpty) {
      email = model.currentEmailRequester;
    }

    if (email.isEmpty) return '-';

    return _employeeController.getEmployeeJobTitle(email);
  }

  String _formatRequestedDate(ServicesHistoryModel model) {
    if (model.timestamps.isEmpty) return '-';

    final date = DateTime.fromMillisecondsSinceEpoch(model.timestamps.first);
    final formatted = DateFormat('dd MMM yyyy', _isArabic ? 'ar' : 'en').format(date);

    return _isArabic ? _toArabicDigits(formatted) : formatted;
  }

  String _getLocalizedStatus(String status) {
    final lowerStatus = status.toLowerCase();
    return _isArabic
        ? statusLocalizationMap[lowerStatus] ?? 'غير معروف'
        : statusEnglishMap[lowerStatus] ?? FormatHelper.capitalize(lowerStatus);
  }

  final Map<String, String> statusEnglishMap = {
    "approved": "Approved",
    "done": "Done",
    "cancel": "Canceled",
    "canceled": "Canceled",
    "rejected": "Rejected",
    "inprogress": "In progress",
    "branchsla": "Breached SLA",
    "breached sla": "Breached SLA",
    "pending": "Pending",
    "active": "Active",
    "inactive": "Inactive",
  };

  @override
  Widget build(BuildContext context) {
    // CHANGED 31/8/2026: was a hand-built `Table` with FlexColumnWidth ratios
    // and a `TableRow` header painted by a lightMode ternary.
    //
    // It is r4's DefaultDataTable now — the same component System Logs and
    // Active Directory use, and the same one the Services dashboard table
    // moved onto — so all three read as one table: dark heading band in
    // AppColors.header, centred 14.sp labels over centred 12.sp values, and
    // columns measured from their own content.
    //
    // fillWidth: true keeps what the FlexColumnWidth ratios were for. Without
    // it DefaultDataTable's horizontal scroll view hands the table unbounded
    // width and it sizes to content, leaving empty space beside a seven-column
    // table. The flex RATIOS themselves are gone: DataTable distributes
    // surplus space itself, so keeping them would have been a second, ignored
    // opinion about column widths.
    return Column(
      children: [
        Directionality(
          textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: DefaultDataTable(
              fillWidth: true,
              columns: [
                _headerColumn(S.of(context).number),
                _headerColumn(S.of(context).serviceRequester),
                _headerColumn(S.of(context).department),
                _headerColumn(S.of(context).jobTitle),
                _headerColumn(S.of(context).RequestedDate),
                _headerColumn(S.of(context).status),
                _headerColumn(S.of(context).serviceProvider),
              ],
              rows: _dataRows(context),
            ),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  /// The request rows.
  ///
  /// Striping rides on `DataRow.color` rather than a `BoxDecoration`: DataTable
  /// paints the row itself, so a coloured box nested in a cell would sit inside
  /// the cell padding instead of behind the whole row.
  ///
  /// The row tap is `DataRow.onSelectChanged`, which replaces the per-cell
  /// InkWell wrapper (`_rowTapWrapper`) the old Table needed — seven InkWells
  /// per row, each with its own ripple, to fake one tappable row.
  /// DefaultDataTable sets `showCheckboxColumn: false`, so making rows
  /// selectable adds no checkbox column.
  List<DataRow> _dataRows(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return List.generate(map.length, (index) {
      final item = map[index];
      final model = item['model'] as ServicesHistoryModel;
      final isEven = index.isEven;
      final rowColor = lightMode
          ? (isEven ? AppColors.background : AppColors.white)
          : (isEven ? AppColors.darkDashboardTable : AppColors.black);

      void goToDetails() {
        final detailsIndex = map.indexOf(item);

        if (model.currentProviderServices == null ||
            model.currentProviderServices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).requestHasNoAssignedProvider),
              backgroundColor: AppColors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        navigateTo(
          context,
          ServicesApprovalDetailsToggle(
            createServicesModel: model,
            index: detailsIndex,
            approvalModel: model,
            fromTable: true,
          ),
        );
      }

      return DataRow(
        color: WidgetStatePropertyAll(rowColor),
        onSelectChanged: (_) => goToDetails(),
        cells: [
          DataCell(_textCell(context, _fmtInt(index + 1))),
          DataCell(_requesterCell(context, item)),
          DataCell(_textCell(context, _getDepartmentText(model))),
          DataCell(_textCell(context, _getJobTitle(model))),
          DataCell(_textCell(context, _formatRequestedDate(model))),
          DataCell(
            _textCell(
              context,
              _getLocalizedStatus(item['status']?.toString() ?? ''),
              textColor:
                  _getStatusColor(item['status']?.toString() ?? '', context),
            ),
          ),
          DataCell(_providerCell(context, item)),
        ],
      );
    });
  }
}


Widget tableDetailsServices(
    BuildContext context,
    ServicesHistoryModel parentModel,
    List<Map<String, dynamic>> map,
    ) {
  final locale = Localizations.localeOf(context).languageCode;

  return TableDetailsServicesWidget(
    context: context,
    parentModel: parentModel,
    map: map,
    locale: locale,
  );
}
