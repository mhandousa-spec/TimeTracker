/// Module: services_management_module
/// Description: Table (list) view of services, used as an alternate to the
///              grid view on the home services page.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: ServicesHistoryModel, ServiceDisplayStatus, FormatHelper
/// Revision History:
///   - Initial version.
///   - 02/07/2026 (Knowticed Team): Reformatted import block (was
///     inconsistently indented/interleaved); grouped dart/flutter,
///     third-party, then project imports.

// ignore_for_file: unnecessary_string_interpolations
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/enums/service_display_status.dart';
import 'package:knowticed_plus/features/services_management_module/s4_bulk_upload_services/presentation/ui/pages/create_new_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s5_service_details/presentation/ui/pages/details_services_toggle.dart';
import 'package:knowticed_plus/generated/l10n.dart';

  class ServiceTableWidget extends StatelessWidget {
    final List<ServicesHistoryModel> filteredModel;
    final Map<String, dynamic> selectedProviders;
    final String locale; // "ar" or "en"

    const ServiceTableWidget({
      Key? key,
      required this.filteredModel,
      required this.selectedProviders,
      required this.locale,
    }) : super(key: key);

    bool get _isArabic => locale.toLowerCase().startsWith('ar');

    // ---------- helpers ----------
    get _headerStyle => StyleText.fontSize14Weight600.copyWith(
        color: AppColors.white
    );

    TextStyle _cellStyle(BuildContext context) => StyleText.fontSize14Weight400.copyWith(
      fontSize: 13.sp,
      color: Theme.of(context).brightness == Brightness.light
          ? AppColors.text
          : AppColors.white,
    );

    // W14: localized digits via intl's NumberFormat instead of a custom map.
    NumberFormat get _numberFormat => NumberFormat('0', 'en');

    String _fmtInt(int n) => _numberFormat.format(n);

    // W15: status is a typed enum; W13: text comes from the .arb localization.
    //
    // ✅ FIX 26/8/2026 — this used to be
    //
    //     ServiceDisplayStatus.fromRaw(
    //       item.currentStatus.isEmpty ? item.currentState : item.currentStatus)
    //
    // which reaches for `state` ONLY when `status` happens to be empty. A
    // draft's status is never empty — it holds the availability the service
    // will have once published, 'active' by default — so `state` was never
    // consulted and every draft row was labelled Active.
    //
    // `ServiceDisplayStatus.of` reads both, with draft winning.
    ServiceDisplayStatus _statusOf(ServicesHistoryModel item) =>
        ServiceDisplayStatus.of(
          state: item.currentState,
          status: item.currentStatus,
        );

    String _statusText(BuildContext context, ServiceDisplayStatus status) {
      final l = S.of(context);
      switch (status) {
        case ServiceDisplayStatus.active:
          return l.active;
        case ServiceDisplayStatus.inactive:
          return l.inactive;
        case ServiceDisplayStatus.draft:
          return l.draft;
      }
    }

    Color _statusColor(BuildContext context, ServiceDisplayStatus status) {
      switch (status) {
        case ServiceDisplayStatus.active:
          return AppColors.lightGreen;
        case ServiceDisplayStatus.inactive:
          return AppColors.red;
        case ServiceDisplayStatus.draft:
          return Theme.of(context).brightness == Brightness.light
              ? AppColors.text
              : AppColors.white;
      }
    }

    String _localizedUnit(BuildContext context, String? key) {
      final k = (key ?? '').toLowerCase().trim();
      final l = S.of(context);
      switch (k) {
        case 'hour':
        case 'hours':
          return l.hours;
        case 'minute':
        case 'minutes':
          return l.minutes;
        case 'second':
        case 'seconds':
          return l.seconds;
        case 'day':
        case 'days':
          return l.day;
        case 'week':
        case 'weeks':
          return l.week;
        default:
          return _isArabic ? (key ?? '') : FormatHelper.capitalize(key ?? '');
      }
    }

    String _yesNo(BuildContext context, bool yes) {
      final l = S.of(context);
      return yes ? l.yes : l.no;
    }

    String _formatStartDate(dynamic timestampOrDateTime) {
      if (timestampOrDateTime == null) return '-';
      DateTime date;
      if (timestampOrDateTime is DateTime) {
        date = timestampOrDateTime;
      } else if (timestampOrDateTime is Timestamp) {
        date = timestampOrDateTime.toDate();
      } else if (timestampOrDateTime is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestampOrDateTime);
      } else {
        return '-';
      }
      // DateFormat with the 'ar' locale already renders Eastern-Arabic digits.
      return DateFormat('dd MMM yyyy', _isArabic ? 'ar' : 'en').format(date);
    }

    String _fmtDuration(BuildContext context, ServicesHistoryModel m) {
      final value = m.currentDurationOfServices.trim();
      if (value.isEmpty) return '-';
      final parsed = num.tryParse(value);
      return parsed != null ? _numberFormat.format(parsed) : value;
    }

    // Basic padded cell builder
    Widget _cell(BuildContext context, Widget child,
        {EdgeInsets? padding, Alignment? align}) {
      return Container(
        // alignment: align ?? Alignment.centerLeft,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: DefaultTextStyle.merge(
          style: _cellStyle(context),
          child: child,
        ),
      );
    }

    // Text cell with ellipsis and optional maxLines
    Widget _textCell(BuildContext context, String text,
        {int maxLines = 2, TextAlign textAlign = TextAlign.start}) {
      return _cell(
        context,
        Text(
          text.isEmpty ? '-' : text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
        ),
      );
    }

    // Wrap a row child to make the whole row tappable
    Widget _rowTapWrapper(BuildContext context, Widget child, VoidCallback onTap) {
      // Each Table child is wrapped with InkWell so tapping anywhere in the row works.
      return InkWell(
        onTap: onTap,
        child: child,
      );
    }

    // Provider name + avatar cell
    Widget _providerCell(BuildContext context, Map<String, dynamic>? selected) {
      final isArabic = Get.locale?.languageCode == 'ar';
      final isAr = _isArabic;
      if (selected == null) {
        return _cell(
          context,
          Text('—',
              style: _cellStyle(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              )),
          align: Alignment.center,
        );
      }
      final firstAr = (selected['firstNameInArabic'] ?? selected['firstNameArabic'] ?? '').toString().trim();
      final lastAr  = (selected['lastNameInArabic']  ?? selected['lastNameArabic']  ?? '').toString().trim();
      final firstEn = (selected['firstName'] ?? '').toString().trim();
      final lastEn  = (selected['lastName']  ?? '').toString().trim();

      String name;
      if (isAr) {
        name = ('$firstAr $lastAr').trim();
        if (name.isEmpty) name = ('$firstEn $lastEn').trim();
      } else {
        final raw = ('$firstEn $lastEn').trim();
        name = raw.isEmpty ? ('$firstAr $lastAr').trim() : FormatHelper.capitalize(raw);
      }
      if (name.isEmpty) {
        final email = (selected['email']?.toString() ?? '');
        name = email.contains('@') ? email.split('@').first : '-';
      }
      final isMale = (selected['gender']?.toString().toLowerCase() ?? '') == 'male';

      // Arabic: Image LEFT, Text RIGHT (using LTR direction)
      final rowChildrenAr = <Widget>[
        ClipOval(
          child: SvgPicture.asset(
            isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
            width: 22.sp, height: 22.sp,
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
      ];

      // English: Image RIGHT, Text LEFT (using LTR direction)
      final rowChildrenEn = <Widget>[
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(width: 6.w),
        ClipOval(
          child: SvgPicture.asset(
            isMale ? "assets/icons_assets/main_icons_assets/male_avatar.svg" : "assets/icons_assets/main_icons_assets/female_avatar.svg",
            width: 22.sp, height: 22.sp,
          ),
        ),
      ];

      return _cell(
        context,
        Directionality(
          // Always use LTR direction and control order through children array
          textDirection: ui.TextDirection.ltr,
          child: Row(
            mainAxisAlignment: !isArabic ? MainAxisAlignment.start :  MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: isAr ? rowChildrenEn :rowChildrenAr ,
          ),
        ),
      );
    }

    // New method for department cell
    Widget _departmentCell(BuildContext context, ServicesHistoryModel m) {
      if (m.currentSelectDepartment.isEmpty) {
        return _textCell(context, '-');
      }

      final departments = m.currentSelectDepartment;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      // Show max 2 departments per row, then scroll horizontally
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 8.sp),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            direction: Axis.horizontal,
            children: departments.map((dept) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkGrey : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(6.r),

                ),
                child: Text(
                  dept,
                  style: _cellStyle(context).copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    // Replace the existing width calculation methods with these improved versions:

    double calculateWidthOfServicesNameEn(BuildContext context, List<ServicesHistoryModel> visionsList) {
      double maxLength = 0;
      for (var vision in visionsList) {
        final name = vision.currentServiceNameEnglish ?? '';
        if (name.isNotEmpty) {
          maxLength = math.max(maxLength, name.length.toDouble());
        }
      }
      if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
      double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
      double minWidth = context.isPortrait ? 120.sp : 140.sp;
      return math.max(calculatedWidth, minWidth);
    }

    double calculateWidthOfServicesNameAR(BuildContext context, List<ServicesHistoryModel> visionsList) {
      double maxLength = 0;
      for (var vision in visionsList) {
        final name = vision.currentServiceNameArabic ?? '';
        if (name.isNotEmpty) {
          maxLength = math.max(maxLength, name.length.toDouble());
        }
      }
      if (maxLength == 0) return context.isPortrait ? 120.w : 150.w;
      double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
      double minWidth = context.isPortrait ? 120.sp : 140.sp;
      return math.max(calculatedWidth, minWidth);
    }

    double calculateWidthOfServicesDesEN(BuildContext context, List<ServicesHistoryModel> visionsList) {
      double maxLength = 0;
      for (var vision in visionsList) {
        final desc = vision.currentServiceDescriptionEnglish ?? '';
        if (desc.isNotEmpty) {
          maxLength = math.max(maxLength, desc.length.toDouble());
        }
      }
      if (maxLength == 0) return context.isPortrait ? 150.w : 180.w;
      double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
      double minWidth = context.isPortrait ? 150.sp : 180.sp;
      return math.max(calculatedWidth, minWidth);
    }

    double calculateWidthOfServicesDesAR(BuildContext context, List<ServicesHistoryModel> visionsList) {
      double maxLength = 0;
      for (var vision in visionsList) {
        final desc = vision.currentServiceDescriptionArabic ?? '';
        if (desc.isNotEmpty) {
          maxLength = math.max(maxLength, desc.length.toDouble());
        }
      }
      if (maxLength == 0) return context.isPortrait ? 150.w : 180.w;
      double calculatedWidth = math.min((maxLength * 8.sp) + 0.sp, 300.w);
      double minWidth = context.isPortrait ? 150.sp : 180.sp;
      return math.max(calculatedWidth, minWidth);
    }

    @override
    Widget build(BuildContext context) {
      var lightMode = Theme.of(context).brightness == Brightness.light;
      final isLight = Theme.of(context).brightness == Brightness.light;
      bool isArabic(String text) => RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(text);

      // ---- Column headers - order changes based on locale ----
      final headers = _isArabic
          ? <String>[
        'رقم',
        'اسم الخدمة',
        'Service Name',
        'وصف الخدمة',
        'Service Description',
        S.of(context).status,
        S.of(context).duration,
        S.of(context).timeUnit,
        S.of(context).limitServiceAvailability,
        _isArabic ? 'الأقسام المحددة' : 'Selected Departments', // New column header
        S.of(context).requiresApproval,
        S.of(context).startDate,
        S.of(context).serviceProvider,
      ]
          : <String>[
        'No',
        'Service Name',
        'اسم الخدمة',
        'Service Description',
        'وصف الخدمة',
        S.of(context).status,
        S.of(context).duration,
        S.of(context).timeUnit,
        S.of(context).limitServiceAvailability,
        _isArabic ? 'الأقسام المحددة' : 'Selected Departments', // New column header
        S.of(context).requiresApproval,
        S.of(context).creationDate,
        S.of(context).serviceProvider,
      ];

      final columnWidths = _isArabic
          ? <int, TableColumnWidth>{
        0: FixedColumnWidth(60.sp),
        1: FixedColumnWidth(calculateWidthOfServicesNameAR(context, filteredModel)),
        2: FixedColumnWidth(calculateWidthOfServicesNameEn(context, filteredModel)),
        3: FixedColumnWidth(calculateWidthOfServicesDesAR(context, filteredModel)),
        4: FixedColumnWidth(calculateWidthOfServicesDesEN(context, filteredModel)),
        5: FixedColumnWidth(80.sp),
        6: FixedColumnWidth(55.sp),
        7: FixedColumnWidth(80.sp),
        8: FixedColumnWidth(120.sp),
        9: FixedColumnWidth(200.sp), // New department column
        10: FixedColumnWidth(180.sp),
        11: FixedColumnWidth(120.sp),
        12: FixedColumnWidth(130.sp),
      }
          : <int, TableColumnWidth>{
        0: FixedColumnWidth(60.sp),
        1: FixedColumnWidth(calculateWidthOfServicesNameEn(context, filteredModel)),
        2: FixedColumnWidth(calculateWidthOfServicesNameAR(context, filteredModel)),
        3: FixedColumnWidth(calculateWidthOfServicesDesEN(context, filteredModel)),
        4: FixedColumnWidth(calculateWidthOfServicesDesAR(context, filteredModel)),
        5: FixedColumnWidth(80.sp),
        6: FixedColumnWidth(90.sp),
        7: FixedColumnWidth(90.sp),
        8: FixedColumnWidth(180.sp),
        9: FixedColumnWidth(220.sp), // New department column
        10: FixedColumnWidth(180.sp),
        11: FixedColumnWidth(120.sp),
        12: FixedColumnWidth(180.sp),
      };

      return AnimatedSizeWrap(child: Directionality(
        textDirection: _isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.sp),
            child: Table(
              border: TableBorder.all(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.sp),
              ),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: columnWidths,
              children: [
                // ---------- Header Row ----------
                TableRow(
                  decoration: BoxDecoration(color: lightMode ? AppColors.black : AppColors.dividerGrey),
                  children: headers
                      .map(
                        (name) => Directionality(
                      textDirection: isArabic(name) ? ui.TextDirection.rtl : ui.TextDirection.ltr,
                      child: Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Text(
                          name,
                          style: _headerStyle,
                          maxLines: 1,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),

                // ---------- Data Rows ----------
                ...List.generate(filteredModel.length, (index) {
                  final m = filteredModel[index];
                  final isEven = index.isEven;
                  final rowColor = isLight
                      ? (isEven ? AppColors.oddRowColor : AppColors.white)
                      : (isEven ? AppColors.darkDashboardTable : AppColors.black);

                  // ✅ FIX 26/8/2026 — this row went straight to the details
                  // screen for EVERY service, drafts included. A draft has no
                  // details worth showing: it has no requests, no statistics
                  // and quite possibly no provider or SLA yet, because the
                  // whole point is that the user has not finished creating it.
                  // Tapping one has to resume the wizard.
                  //
                  // `ServiceGridCard` already did exactly that, so the grid
                  // view behaved correctly and the table view did not — the
                  // same service opened two different screens depending on
                  // which view toggle happened to be selected. The logic below
                  // mirrors that card deliberately, so the two stay in step.
                  VoidCallback _goToService = () async {
                    final bool isDraft =
                        _statusOf(m) == ServiceDisplayStatus.draft;

                    final cubit = ServicesManagerCubit.get(context);

                    if (isDraft) {
                      // A Firebase draft carries its saved progress; an older
                      // SharedPrefs draft does not, and reopens from the model
                      // it already has. Either way the wizard starts at step 1
                      // with everything prefilled — see the note on
                      // `ServiceGridCard._navigateToDraftPage`.
                      final draftWithPage =
                          await cubit.getDraftWithPage(m.currentId);
                      if (!context.mounted) return;

                      navigateTo(
                        context,
                        draftWithPage != null
                            ? CreateNewServicesLayout(
                                editingModel: draftWithPage.model,
                                docId: draftWithPage.draftId,
                              )
                            : CreateNewServicesLayout(editingModel: m),
                      );
                      return;
                    }

                    final serviceId = m.currentId;
                    if (serviceId.isEmpty) return;

                    // The details screen renders these two straight away, so
                    // they are loaded before navigating rather than after.
                    await cubit.getRequestedServices(serviceId);
                    await cubit.getStatistics(serviceId);
                    if (!context.mounted) return;

                    navigateTo(
                      context,
                      ToggleDetailsServicesLayout(createServicesModel: m),
                    );
                  };

                  // Build cells in the correct order based on locale
                  final cells = _isArabic
                      ? [
                    // No.
                    _textCell(context, _fmtInt(index + 1), maxLines: 1),

                    // Service Name (AR) - FIRST in Arabic
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          m.currentServiceNameArabic.isEmpty ? '-' : m.currentServiceNameArabic,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // Service Name (EN) - SECOND in Arabic
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Text(
                          m.currentServiceNameEnglish.isEmpty ? '-' : m.currentServiceNameEnglish,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // Arabic Description - FIRST in Arabic
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          m.currentServiceDescriptionArabic.isEmpty ? '-' : m.currentServiceDescriptionArabic,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // English Description - SECOND in Arabic
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Text(
                          m.currentServiceDescriptionEnglish.isEmpty ? '-' : m.currentServiceDescriptionEnglish,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // Status
                    _cell(
                      context,
                      Text(
                        _statusText(context, _statusOf(m)),
                        style: _cellStyle(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: _statusColor(context, _statusOf(m)),
                        ),

                      ),
                    ),
                    // Duration
                    _textCell(context, _fmtDuration(context, m), maxLines: 1),
                    // Time Unit
                    _textCell(context, _localizedUnit(context, m.currentSelectedDurationUnit), maxLines: 1),
                    // Limit Service Availability
                    _textCell(context, _yesNo(context, m.currentSelectDepartment.isNotEmpty)),
                    // NEW: Selected Departments
                    _departmentCell(context, m),
                    // Requires Approval
                    _textCell(context, _yesNo(context, m.currentApprovalCycle.isNotEmpty)),
                    // Start Date
                    _textCell(context, _formatStartDate(m.getTimestampAt(0)), maxLines: 1),
                    // Service Provider
                    _providerCell(context, selectedProviders[m.currentId]),
                  ]
                      : [
                    // No.
                    _textCell(context, _fmtInt(index + 1), maxLines: 1),

                    // Service Name (EN) - FIRST in English
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Text(
                          m.currentServiceNameEnglish.isEmpty ? '-' : m.currentServiceNameEnglish,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // Service Name (AR) - SECOND in English
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          m.currentServiceNameArabic.isEmpty ? '-' : m.currentServiceNameArabic,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // English Description - FIRST in English
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.ltr,
                        child: Text(
                          m.currentServiceDescriptionEnglish.isEmpty ? '-' : m.currentServiceDescriptionEnglish,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // Arabic Description - SECOND in English
                    _cell(
                      context,
                      Directionality(
                        textDirection: ui.TextDirection.rtl,
                        child: Text(
                          m.currentServiceDescriptionArabic.isEmpty ? '-' : m.currentServiceDescriptionArabic,
                          textAlign: TextAlign.start,
                          style: _cellStyle(context),
                        ),
                      ),
                    ),

                    // Status
                    _cell(
                      context,
                      Text(
                        _statusText(context, _statusOf(m)),
                        style: _cellStyle(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: _statusColor(context, _statusOf(m)),
                        ),
                      ),
                    ),
                    // Duration
                    _textCell(context, _fmtDuration(context, m), maxLines: 1),
                    // Time Unit
                    _textCell(context, _localizedUnit(context, m.currentSelectedDurationUnit), maxLines: 1),
                    // Limit Service Availability
                    _textCell(context, _yesNo(context, m.currentSelectDepartment.isNotEmpty)),
                    // NEW: Selected Departments
                    _departmentCell(context, m),
                    // Requires Approval
                    _textCell(context, _yesNo(context, m.currentApprovalCycle.isNotEmpty)),
                    // Start Date
                    _textCell(context, _formatStartDate(m.getTimestampAt(0)), maxLines: 1),
                    // Service Provider
                    _providerCell(context, selectedProviders[m.currentId]),
                  ];

                  return TableRow(
                    decoration: BoxDecoration(color: rowColor),
                    children: cells.map((cell) => _rowTapWrapper(context, cell, _goToService)).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ));
    }
  }

