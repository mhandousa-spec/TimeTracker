/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_filter_row.dart
/// Purpose: The Sender Type / By Type / Department / Time filter row shared by
///          the three notification inboxes, plus the predicate that applies it.
/// Author: Knowticed Plus team
/// Created at: 26/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The row was built inside notification_page.dart only, so the Pinned and
/// Cleared lists had a search field and a sort menu but none of the four
/// dropdowns. Rather than paste a third copy of the options builders and the
/// filter predicate into each page, both the widget and the filtering live
/// here and the pages hold nothing but the four selected values.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/enums/app_module.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_sender_info.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The four values a page keeps, and the predicate that applies them.
///
/// All four open on [all] — a real entry in every option list — so "All" is
/// the selection from the first frame instead of the menu opening on `null`
/// with nothing highlighted.
abstract class NotificationFilters {
  /// The value carried by the "All" option in every list.
  static const String all = '__all__';

  /// Whether [value] narrows the list. "All" and `null` never do.
  static bool isFiltering(String? value) => value != null && value != all;

  /// The language department names are compared in. Get.locale, as the old
  /// `getEmployeeDepartmentName` used, so the menu and the predicate agree.
  static bool get _isEnglish => Get.locale.toString().contains('en');

  /// Function Name: [apply]
  ///
  /// Purpose: Narrow [source] by the four selections.
  ///
  /// [source] is the page's already-scoped list — pinned for the Pinned page,
  /// cleaned for the Cleared page — so this only ever applies the toolbar.
  static List<NotificationModelSystem> apply({
    required List<NotificationModelSystem> source,
    required MainCoreEmployeeController employeeController,
    String? senderType,
    String? byType,
    String? department,
    String? time,
  }) {
    List<NotificationModelSystem> filtered = source;

    // Person vs system — the same test the card layout uses, so what the
    // filter calls a system notification is exactly what renders without an
    // avatar chip.
    if (isFiltering(senderType)) {
      final bool wantEmployee = senderType == 'employee';
      filtered = filtered
          .where((n) =>
              employeeController.isKnownEmployee(n.senderEmail) == wantEmployee)
          .toList();
    }

    // The module key stored on the notification. This is the only "type" the
    // model actually carries.
    if (isFiltering(byType)) {
      filtered = filtered
          .where((n) => n.nameOfModule.toLowerCase() == byType!.toLowerCase())
          .toList();
    }

    if (isFiltering(department)) {
      filtered = filtered
          .where((n) =>
              NotificationSenderInfo.departmentName(
                employeeController,
                n.senderEmail,
                isEnglish: _isEnglish,
              ) ==
              department)
          .toList();
    }

    // Whole days back from now.
    if (isFiltering(time)) {
      final int days = switch (time) {
        'day' => 1,
        'week' => 7,
        'month' => 30,
        'year' => 365,
        _ => 0,
      };
      if (days > 0) {
        final int cutoff =
            DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
        filtered = filtered.where((n) => n.timestamp >= cutoff).toList();
      }
    }

    return filtered;
  }
}

/// The four dropdowns. Desktop and tablet lay them out in one row, leading
/// pair then trailing pair; mobile wraps them into two rows of two so nothing
/// is clipped at 375px.
class NotificationFilterRow extends StatelessWidget {
  const NotificationFilterRow({
    super.key,
    required this.notifications,
    required this.employeeController,
    required this.isMobile,
    required this.senderType,
    required this.byType,
    required this.department,
    required this.time,
    required this.onSenderTypeChanged,
    required this.onByTypeChanged,
    required this.onDepartmentChanged,
    required this.onTimeChanged,
    this.stacked = false,
  });

  /// Lay the four out as one full-width column instead of the toolbar rows.
  ///
  /// ADDED 13/9/2026 for [showNotificationFilterDialog]. Same fields, same
  /// option builders — only the arrangement differs, so the dialog cannot
  /// drift away from the toolbar as options are added.
  final bool stacked;

  /// The list this toolbar sits above — the By Type and Department options are
  /// built from it, so the menus never offer something that matches nothing.
  final List<NotificationModelSystem> notifications;
  final MainCoreEmployeeController employeeController;
  final bool isMobile;

  final String? senderType;
  final String? byType;
  final String? department;
  final String? time;

  final ValueChanged<String?> onSenderTypeChanged;
  final ValueChanged<String?> onByTypeChanged;
  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    final Widget senderTypeField = _dropdown(
      context,
      label: s.senderType,
      value: senderType,
      options: _senderTypeOptions(s),
      onChanged: onSenderTypeChanged,
    );
    final Widget byTypeField = _dropdown(
      context,
      label: s.byType,
      value: byType,
      options: _byTypeOptions(context, s),
      onChanged: onByTypeChanged,
    );
    final Widget departmentField = _dropdown(
      context,
      label: s.department,
      value: department,
      options: _departmentOptions(s),
      onChanged: onDepartmentChanged,
    );
    final Widget timeField = _dropdown(
      context,
      label: s.time,
      value: time,
      options: _timeOptions(s),
      onChanged: onTimeChanged,
    );

    // ADDED 13/9/2026 — the dialog stacks all four full width, one per line,
    // each showing its own name as the hint (Figma: Time / Department /
    // Sender Type / Type). Nothing else in this build is used on that path.
    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          timeField,
          SizedBox(height: 12.h),
          departmentField,
          SizedBox(height: 12.h),
          senderTypeField,
          SizedBox(height: 12.h),
          byTypeField,
        ],
      );
    }

    // CHANGED 12/9/2026: the last dropdown row sat flush against the first
    // notification card. The gap belongs to the toolbar rather than to each
    // page's list, so it is bottom padding here and every inbox gets it.
    final Widget rows = isMobile
        ? Column(
            children: [
              Row(children: [
                Expanded(child: senderTypeField),
                SizedBox(width: 8.w),
                Expanded(child: byTypeField),
              ]),
              SizedBox(height: 8.h),
              Row(children: [
                Expanded(child: departmentField),
                SizedBox(width: 8.w),
                Expanded(child: timeField),
              ]),
            ],
          )
        : Row(
            children: [
              SizedBox(width: 150.w, child: senderTypeField),
              SizedBox(width: 8.w),
              SizedBox(width: 170.w, child: byTypeField),
              const Spacer(),
              SizedBox(width: 170.w, child: departmentField),
              SizedBox(width: 8.w),
              SizedBox(width: 130.w, child: timeField),
            ],
          );

    return Padding(
      padding: EdgeInsets.only(bottom: context.isPhone ? 0.sp :  0.h),
      child: rows,
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String label,
    required String? value,
    required List<MapEntry<String?, String>> options,
    required ValueChanged<String?> onChanged,
  }) {
    // CHANGED 26/8/2026: was AppDropdown (45-custom_app_dropdown). All four
    // now use the shared CustomDropdown, so these match every other dropdown
    // in the app — one placeholder grey, one chevron, one overlay.
    return CustomDropdown<String?>(
      hint: label,
      // The trigger shows the current selection in place of the hint once a
      // choice is made (default CustomDropdown behavior); the hint (filter
      // name) shows only while nothing is selected.
      //
      // CHANGED 13/9/2026 — in the stacked dialog, "All" is passed down as
      // null so the field reads "Time" / "Department" / "Sender Type" /
      // "Type" rather than four identical "All"s, which is what Figma draws
      // and the only way the sheet says what each row selects. The toolbar
      // keeps showing "All" as a real selection.
      value: stacked && !NotificationFilters.isFiltering(value) ? null : value,
      // A RAW number on purpose, not 38.h: CustomDropdown.height is documented
      // as being interpreted in .sp and is scaled inside the widget, so a
      // pre-scaled value would be scaled a second time.
      height: 38,
      fillColor: context.isPhone ?  AppColors.background : AppColors.card,
      hintStyle: StyleText.fontSize12Weight400,
      valueStyle:
          StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      itemStyle: StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
      items: options
          .map((e) => DropdownItem<String?>(value: e.key, label: e.value))
          .toList(),
      onChanged: onChanged,
    );
  }

  /// Person-sent vs system-raised.
  List<MapEntry<String?, String>> _senderTypeOptions(S s) =>
      <MapEntry<String?, String>>[
        MapEntry(NotificationFilters.all, s.all),
        MapEntry('employee', s.employee),
        MapEntry('system', s.system),
      ];

  /// The modules that actually appear in this list.
  List<MapEntry<String?, String>> _byTypeOptions(BuildContext context, S s) {
    final Set<String> keys = notifications
        .map((n) => n.nameOfModule)
        .where((k) => k.trim().isNotEmpty)
        .toSet();

    final bool isArabic = Localizations.localeOf(context).languageCode ==
        AppConstants.arabicLanguageCode;

    return <MapEntry<String?, String>>[
      MapEntry(NotificationFilters.all, s.all),
      for (final String key in keys.toList()..sort())
        MapEntry(key, AppModule.fromKey(key)?.label(isArabic: isArabic) ?? key),
    ];
  }

  /// Departments of the people who sent something in this list.
  List<MapEntry<String?, String>> _departmentOptions(S s) {
    final Set<String> names = notifications
        .where((n) => employeeController.isKnownEmployee(n.senderEmail))
        // Null-safe lookup — see notification_sender_info.dart (7/10/2026).
        .map((n) => NotificationSenderInfo.departmentName(
              employeeController,
              n.senderEmail,
              isEnglish: NotificationFilters._isEnglish,
            ))
        .where((d) => d.trim().isNotEmpty)
        .toSet();

    return <MapEntry<String?, String>>[
      MapEntry(NotificationFilters.all, s.all),
      for (final String name in names.toList()..sort()) MapEntry(name, name),
    ];
  }

  /// How far back to look.
  ///
  /// All / Day / Week / Month only — 'year' was dropped 26/8/2026. The
  /// mapping in [NotificationFilters.apply] still understands it, so a stored
  /// or in-flight 'year' selection keeps working; it just is not offered.
  List<MapEntry<String?, String>> _timeOptions(S s) =>
      <MapEntry<String?, String>>[
        MapEntry(NotificationFilters.all, s.all),
        MapEntry('day', s.day),
        MapEntry('week', s.week),
        MapEntry('month', s.month),
      ];
}


// ─────────────────────────────────────────────────────────────────────────────
// Mobile: the four dropdowns move into a dialog behind a Filter button
//
// ADDED 13/9/2026 (Figma MESBAH — mobile Notification screen). At 375px the
// toolbar's 2x2 grid of dropdowns ate a third of the screen before a single
// card was visible. On mobile the row is hidden, the Sort button becomes a
// Filter button, and the four live in a dialog that commits on Apply.
// ─────────────────────────────────────────────────────────────────────────────

/// The four values the dialog hands back. Nothing is committed until Apply.
class NotificationFilterSelection {
  const NotificationFilterSelection({
    required this.senderType,
    required this.byType,
    required this.department,
    required this.time,
  });

  /// Every filter cleared — what Reset produces.
  const NotificationFilterSelection.cleared()
      : senderType = NotificationFilters.all,
        byType = NotificationFilters.all,
        department = NotificationFilters.all,
        time = NotificationFilters.all;

  final String? senderType;
  final String? byType;
  final String? department;
  final String? time;
}

/// Opens the mobile filter dialog.
///
/// Returns the chosen values on Apply, or null if the sheet was dismissed or
/// cancelled — so a caller can `if (result == null) return;` and leave the
/// page's own state untouched.
Future<NotificationFilterSelection?> showNotificationFilterDialog({
  required BuildContext context,
  required List<NotificationModelSystem> notifications,
  required MainCoreEmployeeController employeeController,
  required NotificationFilterSelection current,
}) {
  return showDialog<NotificationFilterSelection>(
    context: context,
    builder: (BuildContext dialogContext) => _NotificationFilterDialog(
      notifications: notifications,
      employeeController: employeeController,
      current: current,
    ),
  );
}

class _NotificationFilterDialog extends StatefulWidget {
  const _NotificationFilterDialog({
    required this.notifications,
    required this.employeeController,
    required this.current,
  });

  final List<NotificationModelSystem> notifications;
  final MainCoreEmployeeController employeeController;
  final NotificationFilterSelection current;

  @override
  State<_NotificationFilterDialog> createState() =>
      _NotificationFilterDialogState();
}

class _NotificationFilterDialogState extends State<_NotificationFilterDialog> {
  // A DRAFT, not the page's state: picking a value here changes nothing until
  // Apply, so dismissing the sheet leaves the list exactly as it was.
  late String? _senderType = widget.current.senderType;
  late String? _byType = widget.current.byType;
  late String? _department = widget.current.department;
  late String? _time = widget.current.time;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);

    return Dialog(
      backgroundColor: AppColors.card,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.sp),
        // SingleChildScrollView: four fields plus the buttons do not fit a
        // small phone in landscape, and a Dialog gives its child unbounded
        // height, so without this the column overflows rather than scrolls.
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 30.sp,
                    height: 30.sp,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary
                    ),
                    child: CustomSvgImage(
                      assetPath: AppAssets.filter,
                      width: 20.sp,
                      height: 20.sp,
                      color: AppColors.textButton,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    s.filter,
                    style: StyleText.fontSize16Weight600
                        .copyWith(color: AppColors.text),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Same widget as the toolbar, stacked — see [stacked].
              NotificationFilterRow(
                notifications: widget.notifications,
                employeeController: widget.employeeController,
                isMobile: true,
                stacked: true,
                senderType: _senderType,
                byType: _byType,
                department: _department,
                time: _time,
                onSenderTypeChanged: (String? v) =>
                    setState(() => _senderType = v),
                onByTypeChanged: (String? v) => setState(() => _byType = v),
                onDepartmentChanged: (String? v) =>
                    setState(() => _department = v),
                onTimeChanged: (String? v) => setState(() => _time = v),
              ),

              SizedBox(height: 20.h),
              Row(
                children: <Widget>[
                  // Reset CLEARS and closes, rather than clearing the draft
                  // and waiting for Apply: "Reset" on a filter sheet is read
                  // as "show me everything", and a second tap to confirm it
                  // is a step nobody expects.
                  Expanded(
                    child: customButton(
                      title: s.reset,
                      fullWidth: true,
                      color: AppColors.darkGrey,
                      textColor: AppColors.white,
                      function: () => Navigator.of(context).pop(
                        const NotificationFilterSelection.cleared(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: customButton(
                      title: s.apply,
                      fullWidth: true,
                      color: AppColors.primary,
                      textColor: AppColors.textButton,
                      function: () => Navigator.of(context).pop(
                        NotificationFilterSelection(
                          // null back to the "All" sentinel: the dialog shows
                          // an untouched field as its hint, the pages store
                          // NotificationFilters.all.
                          senderType: _senderType ?? NotificationFilters.all,
                          byType: _byType ?? NotificationFilters.all,
                          department: _department ?? NotificationFilters.all,
                          time: _time ?? NotificationFilters.all,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The button that replaces Sort on mobile.
class NotificationFilterButton extends StatelessWidget {
  const NotificationFilterButton({
    super.key,
    required this.onTap,
    this.isActive = false,
  });

  final VoidCallback onTap;

  /// Whether any filter is currently narrowing the list — the button picks up
  /// the primary colour so it is obvious the list is not showing everything.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: CustomSvgImage(
            assetPath: AppAssets.filter,
            width: 20.w,
            height: 20.h,
            fit: BoxFit.scaleDown,
            color: isActive ? AppColors.textButton : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
