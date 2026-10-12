/// Module: roles / r5_system_logs / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: filter_dialog.dart
/// Purpose: Declares `FilterDialog`.
/// Author: Knowticed Plus team
/// Created At: 12/8/2026

import 'package:knowticed_plus/core/custom/80-filters_appbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';

import 'package:knowticed_plus/core/custom/76-date_time_in_arabic.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';

import 'package:knowticed_plus/core/custom/53-custom_date_pic.dart';
import 'package:knowticed_plus/core/custom/67-column_request_data.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/helper/main_helper/extensions.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

/// Was marked `// ignore: must_be_immutable` and carried mutable public fields
/// that `build` reassigned. The incoming values are now `final` constructor
/// inputs and the two that change (`roleValue`, `delayValue`) live in the State
/// (§17). The unused `dateValueState` field was removed.
class FilterDialog extends StatefulWidget {
  const FilterDialog(
      {super.key,
      required this.roleValue,
      this.delayValue,
      this.employessScreen = false,
      required this.dropDownItems});

  final String? roleValue;
  final String? delayValue;
  final List<String> dropDownItems;
  final bool employessScreen;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  /// Local, mutable copies of the two values this dialog clears.
  late String? roleValue = widget.roleValue;
  late String? delayValue = widget.delayValue;

  SystemLogsController systemLogsController = AppControllers.systemLogs;
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final List<DateTime?>? picked = await DatePicker().showDatePicker(
        context,
        systemLogsController.rangeDatePickerValueWithDefaultValue,
        DateTime.now(),
        CalendarDatePicker2Type.single);
    if (picked != null &&
        picked.lastOrNull != systemLogsController.selectedDate) {
      setState(() {
        systemLogsController.rangeDatePickerValueWithDefaultValue = picked;
        systemLogsController.selectedDate = picked[0];
        if (isStartDate) {
          systemLogsController.fromDate = picked[0];
          systemLogsController.startDate.text =
              "${S.of(context).from} ${context.isArabic ? ArabicDigits(picked[0]!.day.toString()).toArabicNumbers() : picked[0]!.day} ${DateFormat.MMM().format(picked[0]!)} ${context.isArabic ? ArabicDigits(picked[0]!.year.toString()).toArabicNumbers() : picked[0]!.year}";
        } else {
          systemLogsController.toDate = picked[0];
          systemLogsController.endDate.text =
              "${S.of(context).to} ${context.isArabic ? ArabicDigits(picked.last!.day.toString()).toArabicNumbers() : picked.last!.day} ${DateFormat.MMM().format(picked.last!)} ${context.isArabic ? ArabicDigits(picked.last!.year.toString()).toArabicNumbers() : picked.last!.year}";
        }
      });
    }
  }

  final HapticController hapticController = AppControllers.haptic;

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerEndStart = TextEditingController(
        text: systemLogsController.endTime?.format(context));

    TextEditingController controllerStartStart = TextEditingController(
        text: systemLogsController.startTime?.format(context));
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return BlocBuilder<SystemLogsController, SystemLogsState>(
        bloc: AppControllers.systemLogs,
        builder: (context, state) {
      final controller = AppControllers.systemLogs;
      return Dialog(
        insetPadding:
            EdgeInsets.symmetric(horizontal: isTablet ? 0.2.w : 0.1.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 0.015.w, vertical: isPortrait ? 0.02.h : 0.015.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FiltersAppBar(
                    imageUrl: "assets/icons_assets/main_icons_assets/filter_sliders.svg",
                    title: "Filter"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _selectDate(context, true);
                            },
                            child: ColumnRequestData(
                              fillColor: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.colorLightGrey
                                  : AppColors.colorBlack,
                              title: "Start Date",
                              textController: controller.startDate,
                              isTextField: true,
                              hint: "Start Date",
                              enabled: false,
                              isOptional: false,
                              hideTitle: true,
                              isExpanded: true,
                              hasPrefix: true,
                              hasSuffix: true,
                              suffixUrl: "assets/icons_assets/roles_assets/calendar.svg",
                            ),
                          ),
                        ),
                        SizedBox(width: 0.02.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _selectDate(context, false);
                            },
                            child: ColumnRequestData(
                              fillColor: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.colorLightGrey
                                  : AppColors.colorBlack,
                              title: "End Date",
                              textController: controller.endDate,
                              hideTitle: true,
                              isTextField: true,
                              hint: "End Date",
                              isOptional: false,
                              isExpanded: true,
                              enabled: false,
                              hasPrefix: true,
                              hasSuffix: true,
                              suffixUrl: "assets/icons_assets/roles_assets/calendar.svg",
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.025.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final TimeOfDay? picked =
                                    await showTimePicker(
                                  context: context,
                                  initialTime:
                                      controller.startTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    controller.startTime = picked;
                                  });
                                }
                              },
                              child: ColumnRequestData(
                                fillColor: AppColors.transparent,
                                title: "From",
                                textController:
                                    !context.isArabic
                                        ? controllerStartStart
                                        : TextEditingController(
                                            text: ArabicDigits(
                                                controllerStartStart.text).toArabicNumbers()),
                                isTextField: true,
                                hint: "From",
                                enabled: false,
                                isOptional: false,
                                hideTitle: true,
                                isExpanded: true,
                                hasPrefix: true,
                                hasSuffix: true,
                                suffixUrl: "assets/icons_assets/form_builder_assets/radio_circle_empty.svg",
                              ),
                            ),
                          ),
                          SizedBox(width: 0.02.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final TimeOfDay? picked =
                                    await showTimePicker(
                                  context: context,
                                  initialTime:
                                      controller.endTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    controller.endTime = picked;
                                  });
                                }
                              },
                              child: ColumnRequestData(
                                fillColor: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.colorLightGrey
                                    : AppColors.colorBlack,
                                title: "To",
                                textController:
                                    !context.isArabic
                                        ? controllerEndStart
                                        : TextEditingController(
                                            text: ArabicDigits(
                                                controllerEndStart.text).toArabicNumbers()),
                                hideTitle: true,
                                isTextField: true,
                                hint: "To",
                                isOptional: false,
                                isExpanded: true,
                                enabled: false,
                                hasPrefix: true,
                                hasSuffix: true,
                                suffixUrl: "assets/icons_assets/form_builder_assets/radio_circle_empty.svg",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.025.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomDropdown<String>(
                              hint: S.of(context).role,
                              value: controller.roleValue,
                              itemHeight: isPortrait ? 0.05.h : 0.065.h,
                              items: controller.accessNames
                                  .map((e) =>
                                      FormatHelper.capitalize(e.toLowerCase()))
                                  .map((e) => DropdownItem<String>(
                                        value: e,
                                        label: e,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  List<String> arabicRoles = controller
                                      .accessNames
                                      .map((e) => e)
                                      .toList();
                                  controller.updateRoleValue(
                                      !context.isArabic
                                          ? value
                                          : controller.accessNames[
                                              arabicRoles.indexOf(value)]);
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 0.02.w,
                          ),
                          Expanded(
                            child: CustomDropdown<String>(
                              hint: S.of(context).action,
                              value: controller.actionValue,
                              itemHeight: isPortrait ? 0.05.h : 0.065.h,
                              items: controller.actions
                                  .map((e) => e)
                                  .map((e) => DropdownItem<String>(
                                        value: e,
                                        label: e,
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  List<String> arabicActions = controller
                                      .actions
                                      .map((e) => e)
                                      .toList();
                                  controller.updateActionValue(
                                      !context.isArabic
                                          ? value
                                          : controller.actions[
                                              arabicActions.indexOf(value)]);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.025.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomDropdown<String>(
                          hint: S.of(context).country,
                          value: controller.countryValue,
                          itemHeight: isPortrait ? 0.05.h : 0.065.h,
                          items: controller.countries
                              .map((e) => DropdownItem<String>(
                                    value: e,
                                    label: e,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              controller.updateCountryValue(value);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 0.02.w,
                      ),
                      Expanded(
                        child: CustomDropdown<String>(
                          hint: "City",
                          value: controller.cityValue,
                          itemHeight: isPortrait ? 0.05.h : 0.065.h,
                          items: controller.cities
                              .map((e) => DropdownItem<String>(
                                    value: e,
                                    label: e,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              controller.updateCityValue(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 0.02.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: widget.employessScreen ? 0.00 : 0.015.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      customButton(
                        function: () {
                          hapticController.triggerHapticFeedback(
                              vibration: VibrateType.mediumImpact,
                              hapticFeedback: HapticFeedback.mediumImpact);
                          setState(() {
                            roleValue = null;
                            delayValue = null;
                            // resetFilter() emits SystemLogsUpdated itself, so
                            // the old explicit GetX update() is redundant.
                            controller.resetFilter();
                          });
                        },
                        title: S.of(context).Reset,
                        color: AppColors.colorGreydark,
                      ),
                      BlocBuilder<SystemLogsController, SystemLogsState>(
                        bloc: AppControllers.systemLogs,
                        builder: (context, state) {
                        return customButton(
                          function: () {
                            hapticController.triggerHapticFeedback(
                                vibration: VibrateType.heavyImpact,
                                hapticFeedback: HapticFeedback.heavyImpact);
                            controller.isFilter = true;
                            controller.searchAndFilterLogs();
                            // searchAndFilterLogs() above already emits
                            // SystemLogsUpdated via searchLogs/filterLogs.
                            // REMOVED 12/8/2026: a `setState(() { widget.roleValue; })`
                            // whose body was a bare expression with no effect.
                            Navigator.pop(context);
                          },
                          title: S.of(context).Apply,
                          color: !systemLogsController.isThereFilter()
                              ? AppColors.greyDark
                              : AppColors.signOut,
                        );
                      })
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
