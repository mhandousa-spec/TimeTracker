// ******************* FILE INFO *******************
// File Name: custom_table.dart
// Description: this is custom table which not use now but its work good can reuse
// Created by: Amr Mesbah
// Last Update: 14/10/2025
import 'package:get/get.dart';

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

class CustomDataTable<T> extends StatelessWidget {
  final List<T> data;
  final List<CustomTableColumn<T>> columns;
  final double tableWidth;
  final Color? headerBackgroundColor;
  final Color? rowEvenColor;
  final Color? rowOddColor;
  final bool useAlternatingRowColors;
  final void Function(T model)? onRowTap;

  const CustomDataTable({
    Key? key,
    required this.data,
    required this.columns,
    this.tableWidth = 2000,
    this.headerBackgroundColor,
    this.rowEvenColor,
    this.rowOddColor,
    this.useAlternatingRowColors = true,
    this.onRowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: tableWidth.sp,
        decoration: BoxDecoration(
          color: isLight ? AppColors.background : AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 0.sp),
              decoration: BoxDecoration(
                color: headerBackgroundColor ?? (isLight ? AppColors.header : AppColors.chatBackground),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              ),
              child: Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: columns.map((col) => _HeaderCell(col.title, flex: col.flex, textAlign: col.textAlign)).toList(),
              ),
            ),

            // Rows
            ...List.generate(data.length, (index) {
              final row = data[index];
              final isEven = index % 2 == 0;

              return MouseRegion(
                cursor: onRowTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
                child: Material(
                  color: useAlternatingRowColors
                      ? (isEven
                      ? (rowEvenColor ?? (isLight ? AppColors.background : AppColors.darkDashboardTable))
                      : (rowOddColor ?? (isLight ? AppColors.white : AppColors.darkDashboardTable)))
                      : Colors.transparent,
                  child: InkWell(
                    onTap: onRowTap == null ? null : () => onRowTap!(row),
                    hoverColor: AppColors.black.withOpacity(0.04),
                    splashColor: AppColors.black.withOpacity(0.08),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 0.sp),
                      child: Row(
                        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                        children: columns.map((col) => col.builder(context, row)).toList(),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class CustomTableColumn<T> {
  final String title;
  final int flex;
  final Widget Function(BuildContext context, T model) builder;
  final TextAlign? textAlign;
  final String? svgAssetPath;

  CustomTableColumn({
    required this.title,
    required this.flex,
    required this.builder,
    this.textAlign,
    this.svgAssetPath,
  });
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign? textAlign;

  const _HeaderCell(this.text, {required this.flex, this.textAlign});
  bool _isArabic(String input) {
    // Arabic Unicode range
    return RegExp(r'[\u0600-\u06FF]').hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness == Brightness.light;
    final bool isArabic = _isArabic(text);
    final align = textAlign ?? (isArabic ? TextAlign.end : TextAlign.start);
    return Expanded(
      flex: flex,
      child: Padding(
        padding: isArabic ? EdgeInsetsDirectional.only(end: 20.sp) : EdgeInsetsDirectional.only(start: 20.sp),
        child: Text(
          FormatHelper.capitalize(text),
          textAlign: textAlign ?? (isArabic ? TextAlign.right : TextAlign.left),
          style: StyleText.fontSize15Weight400.copyWith(
            color: themeMode ? AppColors.white : AppColors.white,
          ),
        ),
      ),
    );
  }
}

class Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isBold;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final String? svgAssetPath;

  const Cell(
      this.text, {
        Key? key,
        required this.flex,
        this.isBold = true,
        this.color,
        this.textAlign,
        this.maxLines,
        this.svgAssetPath,
      }) : super(key: key);

  bool _isArabic(String input) {
    // Detects if string contains Arabic letters
    return RegExp(r'[\u0600-\u06FF]').hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = Theme.of(context).brightness == Brightness.light;
    final bool isArabic = _isArabic(text);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: isArabic
            ? EdgeInsetsDirectional.only(end: 20.sp) // space near right-aligned text
            : EdgeInsetsDirectional.only(start: 20.sp), // space near left-aligned text
        child: Text(
          FormatHelper.capitalize(text),
          maxLines: maxLines,
          softWrap: true,
          overflow: maxLines != null ? TextOverflow.ellipsis : null,
          textAlign: textAlign ?? (isArabic ? TextAlign.right : TextAlign.left),
          style: (isBold ? StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack) : StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack)).copyWith(
            color: color ?? (themeMode ? AppColors.blackButton : AppColors.white),
          ),
        ),
      ),
    );
  }
}

class ServicesTableWidget extends StatelessWidget {
  final List<ServicesHistoryModel> services;
  final String locale;
  final void Function(ServicesHistoryModel)? onRowTap;

  ServicesTableWidget({
    Key? key,
    required this.services,
    required this.locale,
    this.onRowTap,
  }) : super(key: key);

  bool get _isArabic => locale.toLowerCase().startsWith('ar');

  TextStyle get _headerStyle => StyleText.fontSize15Weight400.copyWith(color: AppColors.white);

  TextStyle _cellStyle(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(color: lightMode ? AppColors.blackButton : AppColors.white);
  }

  // Helper functions
  String _getLocalizedTimeUnit(String timeUnit) {
    if (timeUnit.isEmpty) return '';

    final units = {
      'days': _isArabic ? 'أيام' : 'Days',
      'weeks': _isArabic ? 'أسابيع' : 'Weeks',
      'months': _isArabic ? 'أشهر' : 'Months',
      'years': _isArabic ? 'سنوات' : 'Years',
      'hours': _isArabic ? 'ساعات' : 'Hours',
      'day': _isArabic ? 'يوم' : 'Day',
      'week': _isArabic ? 'أسبوع' : 'Week',
      'month': _isArabic ? 'شهر' : 'Month',
      'year': _isArabic ? 'سنة' : 'Year',
      'hour': _isArabic ? 'ساعة' : 'Hour',
    };

    return units[timeUnit.toLowerCase()] ?? timeUnit;
  }

  // ✅ UPDATED: Get service status using ServicesHistoryModel
  String _getServiceStatus(ServicesHistoryModel service) {
    final stateField = service.currentState.toLowerCase().trim();

    // Handle direct state values first
    if (['cancel', 'inprogress', 'done', 'branchsla', 'breached sla'].contains(stateField)) {
      return _getLocalizedStatus(stateField);
    }

    // Check if approval cycle exists and is not empty
    final approvalCycle = service.currentApprovalCycle;
    final hasApprovalCycle = approvalCycle.isNotEmpty;

    if (!hasApprovalCycle) {
      // No approval cycle - handle auto-approved services
      if (stateField.isEmpty || stateField == 'pending') {
        return _getLocalizedStatus('approved'); // Auto-approved services
      }
      return _getLocalizedStatus(stateField.isEmpty ? 'approved' : stateField);
    }

    // Handle approval cycle logic
    final states = approvalCycle.where((e) => e.state != null && e.state!.isNotEmpty).map((e) => e.state!.toLowerCase()).toList();

    if (states.contains('cancel')) return _getLocalizedStatus('cancel');
    if (states.contains('rejected')) return _getLocalizedStatus('rejected');
    if (states.every((s) => s == 'approved') && states.isNotEmpty) return _getLocalizedStatus('approved');
    if (states.contains('pending')) return _getLocalizedStatus('pending');

    // Fallback logic
    if (stateField.isNotEmpty) {
      return _getLocalizedStatus(stateField);
    }

    return _getLocalizedStatus('approved'); // Default for services without clear state
  }

  String _getLocalizedStatus(String status) {
    final lowerStatus = status.toLowerCase();

    if (_isArabic) {
      switch (lowerStatus) {
        case 'done':
          return 'تم الإنجاز';
        case 'approved':
          return 'تمت الموافقة';
        case 'inprogress':
          return 'قيد التنفيذ';
        case 'branchsla':
        case 'breached sla':
          return 'تجاوز الوقت المحدد';
        case 'cancel':
          return 'ملغي';
        case 'rejected':
          return 'مرفوض';
        case 'pending':
          return 'قيد المراجعة';
        default:
          return status;
      }
    } else {
      switch (lowerStatus) {
        case 'done':
          return 'Done';
        case 'approved':
          return 'Approved';
        case 'inprogress':
          return 'In Progress';
        case 'branchsla':
        case 'breached sla':
          return 'Breached SLA';
        case 'cancel':
          return 'Canceled';
        case 'rejected':
          return 'Rejected';
        case 'pending':
          return 'Pending';
        default:
          return status;
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'تمت الموافقة':
        return AppColors.lightGreen; // Green
      case 'done':
      case 'تم الإنجاز':
        return AppColors.green!; // Dark Green
      case 'rejected':
      case 'مرفوض':
        return AppColors.red!; // Red
      case 'cancel':
      case 'ملغي':
        return AppColors.darkRed!; // Dark Red
      case 'inprogress':
      case 'in progress':
      case 'قيد التنفيذ':
        return AppColors.secondaryPrimary; // Yellow
      case 'pending':
      case 'قيد المراجعة':
        return AppColors.pending; // Orange
      case 'breached sla':
      case 'تجاوز الوقت المحدد':
        return AppColors.block; // Dark Red
      default:
        return AppColors.grey;
    }
  }

  // ✅ UPDATED: Dynamic width calculation functions using ServicesHistoryModel
  double _calculateNoWidth(BuildContext context) {
    return context.isPortrait ? 50.w : 60.w;
  }

  double _calculateServiceNameWidth(BuildContext context) {
    double maxLength = 0;
    for (var service in services) {
      final name = _isArabic ? service.currentServiceNameArabic : service.currentServiceNameEnglish;
      if (name.isNotEmpty) {
        maxLength = math.max(maxLength, name.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 250.w);
    double minWidth = context.isPortrait ? 100.sp : 120.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateRequesterWidth(BuildContext context) {
    double maxLength = 0;
    for (var service in services) {
      final name = _isArabic
          ? "${service.currentFirstNameRequesterArabic} ${service.currentLastNameRequesterArabic}"
          : "${service.currentFirstNameRequester} ${service.currentLastNameRequester}";
      if (name.trim().isNotEmpty) {
        maxLength = math.max(maxLength, name.trim().length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 150.w : 180.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 60.sp, 200.w);
    double minWidth = context.isPortrait ? 130.sp : 150.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateDateWidth(BuildContext context) {
    return context.isPortrait ? 100.w : 120.w;
  }

  double _calculateDepartmentWidth(BuildContext context) {
    double maxLength = 0;
    for (var service in services) {
      final dept = service.currentDepartmentRequester;
      if (dept.isNotEmpty) {
        maxLength = math.max(maxLength, dept.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 100.w : 120.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 180.w);
    double minWidth = context.isPortrait ? 80.sp : 100.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateJobTitleWidth(BuildContext context) {
    double maxLength = 0;
    for (var service in services) {
      final jobTitle = _isArabic ? service.currentJobTitleRequesterArabic : service.currentJobTitleRequester;
      if (jobTitle.isNotEmpty) {
        maxLength = math.max(maxLength, jobTitle.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 200.w);
    double minWidth = context.isPortrait ? 100.sp : 130.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateDurationWidth(BuildContext context) {
    double maxLength = 0;
    for (var service in services) {
      final duration = service.currentDurationOfServices;
      if (duration.isNotEmpty) {
        maxLength = math.max(maxLength, duration.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 120.w);
    double minWidth = context.isPortrait ? 70.sp : 80.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateTimeUnitWidth(BuildContext context) {
    double maxLength = 0;
    for (var service in services) {
      final timeUnit = _getLocalizedTimeUnit(service.currentSelectedDurationUnit);
      if (timeUnit.isNotEmpty) {
        maxLength = math.max(maxLength, timeUnit.length.toDouble());
      }
    }
    if (maxLength == 0) return context.isPortrait ? 80.w : 100.w;
    double calculatedWidth = math.min((maxLength * 8.sp) + 40.sp, 120.w);
    double minWidth = context.isPortrait ? 90.sp : 100.sp;
    return math.max(calculatedWidth, minWidth);
  }

  double _calculateStatusWidth(BuildContext context) {
    return context.isPortrait ? 100.w : 120.w;
  }

  Widget _cell(BuildContext context, Widget child) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
      child: DefaultTextStyle.merge(
        style: _cellStyle(context),
        child: child,
      ),
    );
  }

  Widget _textCell(BuildContext context, String text, {int maxLines = 2, bool isBold = false, Color? color}) {
    return _cell(
      context,
      Text(
        FormatHelper.capitalize(
          text.isEmpty ? '-' : text,
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: _cellStyle(context).copyWith(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          color: color ?? _cellStyle(context).color,
        ),
      ),
    );
  }

  // ✅ UPDATED: Requester cell using ServicesHistoryModel
  Widget _requesterCell(BuildContext context, ServicesHistoryModel service) {
    final gender = service.currentGenderRequester.toLowerCase();
    final avatar = gender == 'male'
        ? 'assets/icons_assets/main_icons_assets/male_avatar.svg'
        : gender == 'female'
        ? 'assets/icons_assets/main_icons_assets/female_avatar.svg'
        : 'assets/icons_assets/main_icons_assets/person_outline.svg';

    final name = _isArabic
        ? "${service.currentFirstNameRequesterArabic} ${service.currentLastNameRequesterArabic}"
        : "${service.currentFirstNameRequester} ${service.currentLastNameRequester}";

    return _cell(
      context,
      Row(
        children: [
          ClipOval(
            child: SvgPicture.asset(
              avatar,
              fit: BoxFit.scaleDown,
              width: 25.w,
              height: 25.h,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              FormatHelper.capitalize(name.trim().isEmpty ? '-' : name.trim()),
              overflow: TextOverflow.ellipsis,
              style: _cellStyle(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _clickableCell(BuildContext context, Widget child, ServicesHistoryModel service) {
    return GestureDetector(
      onTap: onRowTap == null ? null : () => onRowTap!(service),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    // Headers
    final headers = <String>[
      _isArabic ? 'رقم' : 'No',
      _isArabic ? 'اسم الخدمة' : 'Service Name',
      _isArabic ? 'طالب الخدمة' : 'Service Requester',
      _isArabic ? 'تاريخ الطلب' : 'Request Date',
      _isArabic ? 'القسم' : 'Department',
      _isArabic ? 'المسمى الوظيفي' : 'Job Title',
      _isArabic ? 'المدة' : 'Duration',
      _isArabic ? 'وحدة الوقت' : 'Time Unit',
      _isArabic ? 'الحالة' : 'Status',
    ];

    // Dynamic column widths based on content
    final columnWidths = <int, TableColumnWidth>{
      0: FixedColumnWidth(_calculateNoWidth(context)),
      1: FixedColumnWidth(_calculateServiceNameWidth(context)),
      2: FixedColumnWidth(_calculateRequesterWidth(context)),
      3: FixedColumnWidth(_calculateDateWidth(context)),
      4: FixedColumnWidth(_calculateDepartmentWidth(context)),
      5: FixedColumnWidth(_calculateJobTitleWidth(context)),
      6: FixedColumnWidth(_calculateDurationWidth(context)),
      7: FixedColumnWidth(_calculateTimeUnitWidth(context)),
      8: FixedColumnWidth(_calculateStatusWidth(context)),
    };

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Table(
            border: TableBorder.all(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: [
              // Header Row
              TableRow(
                decoration: BoxDecoration(
                  color: lightMode ? AppColors.text : AppColors.chatBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                ),
                children: headers
                    .map((name) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
                  child: Text(
                    name,
                    style: _headerStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ))
                    .toList(),
              ),

              // ✅ UPDATED: Data Rows using ServicesHistoryModel
              ...List.generate(services.length, (index) {
                final service = services[index];
                final isEven = index.isEven;
                final rowColor = lightMode
                    ? (isEven ? AppColors.whiteDashboardTable : AppColors.white)
                    : (isEven ? AppColors.background : AppColors.chatBackground);

                final serviceStatus = _getServiceStatus(service);

                return TableRow(
                  decoration: BoxDecoration(color: rowColor),
                  children: [
                    _clickableCell(
                      context,
                      _textCell(context, '${index + 1}', maxLines: 1),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _textCell(
                        context,
                        _isArabic ? service.currentServiceNameArabic : service.currentServiceNameEnglish,
                      ),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _requesterCell(context, service),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _textCell(
                        context,
                        DateFormat('dd MMM yyyy').format(
                          service.currentDurationOfServicesTimestamp.toDate(),
                        ),
                        maxLines: 1,
                      ),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _textCell(context, service.currentDepartmentRequester),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _textCell(
                        context,
                        _isArabic ? service.currentJobTitleRequesterArabic : service.currentJobTitleRequester,
                      ),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _textCell(context, service.currentDurationOfServices),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _textCell(
                        context,
                        _getLocalizedTimeUnit(service.currentSelectedDurationUnit),
                      ),
                      service,
                    ),
                    _clickableCell(
                      context,
                      _textCell(
                        context,
                        serviceStatus,
                        isBold: true,
                        color: _getStatusColor(serviceStatus),
                      ),
                      service,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
