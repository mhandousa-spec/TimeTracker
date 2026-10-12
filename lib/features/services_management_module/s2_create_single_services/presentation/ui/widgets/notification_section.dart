/// Module: services_management_module
/// Description: Notification tile widget (checkbox + per-line switches) used
///              on the SLA notification screen.
/// Author: Knowticed Team
/// Date: 02/07/2026
/// Dependencies: flutter_switch, ServicesManagerCubit, ServicesHistoryModel
/// Revision History:
///   - Initial version.
///   - 02/07/2026 (Knowticed Team): Removed try/catch in
///     _getCheckboxStateFromModel — now typed against ServicesHistoryModel
///     instead of dynamic field access.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';

class NotificationTile extends StatefulWidget {
  final String title;
  final List<String> children;
  final Function(Map<int, bool>)? onSwitchChanged;
  final void Function({required int index, required bool value, required String title})? onSingleSwitchChanged;
  final bool? isChecked;
  final Function(bool)? onCheckboxChanged;
  final Function()? onCheckSlaData;

  const NotificationTile({
    super.key,
    required this.title,
    required this.children,
    this.onSwitchChanged,
    this.onSingleSwitchChanged,
    this.isChecked,
    this.onCheckboxChanged,
    this.onCheckSlaData,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool isChecked = false;
  Map<int, bool> switchStates = {};

  bool _isSpecialText(String text) {
    final englishTexts = [
      "When Service Is Requested And Approved By The Requester's Manager If It Requires Approval",
      "When Service Status Changes"
    ];

    final localizedTexts = [
      S.of(context).whenServiceRequestedAndApprovedIfRequired,
      S.of(context).whenServiceStatusChanges
    ];

    final trimmedText = text.trim();

    return englishTexts.any((englishText) => trimmedText == englishText.trim()) ||
        localizedTexts.any((localizedText) => trimmedText == localizedText.trim());
  }

  @override
  void initState() {
    super.initState();

    // Initialize checkbox state from parent or default to false
    isChecked = widget.isChecked ?? false;

    // Initialize all switches to false
    for (int i = 0; i < widget.children.length; i++) {
      switchStates[i] = false;
    }

    _loadFromModel();
  }

  @override
  @override
  void didUpdateWidget(NotificationTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update checkbox state when parent changes it
    if (widget.isChecked != null && widget.isChecked != isChecked) {
      // Defer setState to after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            isChecked = widget.isChecked!;

            // If checkbox is unchecked, turn off all switches
            if (!isChecked) {
              for (int i = 0; i < widget.children.length; i++) {
                switchStates[i] = false;
              }
              widget.onSwitchChanged?.call(switchStates);
            }
          });
        }
      });
    }
  }

  void _loadFromModel() async {
    // FIXED: Load from ServicesModel with FieldHistory
    final model = ServicesManagerCubit.get(context).docService;
    final prefs = await SharedPreferences.getInstance();
    final checkboxKey = "${widget.title}_checked";

    bool savedCheckboxState;
    if (widget.isChecked != null) {
      savedCheckboxState = widget.isChecked!;
    } else {
      // FIXED: Access current value from FieldHistory
      final modelCheckboxState = model != null ? _getCheckboxStateFromModel(model) : null;
      savedCheckboxState = prefs.getBool(checkboxKey) ?? modelCheckboxState ?? false;
    }

    // Load switch states from SharedPreferences
    Map<int, bool> restoredSwitchStates = {};
    for (int i = 0; i < widget.children.length; i++) {
      final key = "${widget.title}_switch_$i";
      restoredSwitchStates[i] = prefs.getBool(key) ?? false;
    }

    setState(() {
      isChecked = savedCheckboxState;
      switchStates = restoredSwitchStates;
    });

    widget.onSwitchChanged?.call(switchStates);
  }

  // FIXED: Helper method to get checkbox state from ServicesModel
  // W-item6: no try/catch — typed against ServicesHistoryModel directly
  // instead of guessing a dynamic shape and swallowing failures.
  bool? _getCheckboxStateFromModel(ServicesHistoryModel? model) {
    if (model == null) return null;

    // Access the appropriate field based on the title
    if (widget.title.contains("Requester") || widget.title.contains("الطالب")) {
      return model.currentNotifyRequesterChecked;
    } else if (widget.title.contains("Provider") && !widget.title.contains("Manager")) {
      return model.currentNotifyProviderChecked;
    } else if (widget.title.contains("Manager") || widget.title.contains("المدير")) {
      return model.currentNotifyManagerChecked;
    }
    return null;
  }

  Future<void> _saveCheckboxState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final checkboxKey = "${widget.title}_checked";
    await prefs.setBool(checkboxKey, value);
  }

  Future<void> _saveSwitchState(int index, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = "${widget.title}_switch_$index";
    await prefs.setBool(key, value);
  }

  void _handleCheckboxTap() {
    // If trying to check the checkbox, allow it
    if (!isChecked) {
      setState(() {
        isChecked = true;
      });
      _saveCheckboxState(true);
      widget.onCheckboxChanged?.call(true);
      return;
    }

    // If trying to uncheck, first check if any switches are enabled
    bool hasAnySwitchEnabled = false;

    for (int i = 0; i < widget.children.length; i++) {
      final text = widget.children[i];
      final isSpecial = _isSpecialText(text);

      if (isSpecial && (switchStates[i] ?? false)) {
        hasAnySwitchEnabled = true;
        break;
      }
    }

    if (hasAnySwitchEnabled) {
      // Show warning when trying to uncheck with active switches
      _showWarningDialog();
    } else {
      // FIXED: Check for SLA data before allowing uncheck
      if (widget.onCheckSlaData != null) {
        // This will handle the SLA validation and show error if needed
        widget.onCheckSlaData!();
      } else {
        // No SLA check needed, allow unchecking
        _uncheckAndClearSwitches();
      }
    }
  }

  void _uncheckAndClearSwitches() {
    setState(() {
      isChecked = false;
      // Turn off all switches when unchecking
      for (int i = 0; i < widget.children.length; i++) {
        switchStates[i] = false;
      }
    });
    _saveCheckboxState(false);
    widget.onCheckboxChanged?.call(false);
    widget.onSwitchChanged?.call(switchStates);
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          content: SizedBox(
            width: 411.sp,
        //    height: 182.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lottie_attension.json',
                  width: 70.sp,
                  height: 70.sp,
                ),
                SizedBox(height: 10.sp),
                Text(
                  S.of(context).warning,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize20Weight500.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
                SizedBox(height: 18.sp),
                Text(
                  S.of(context).TurnOffAllNotificationSwitches,
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize15Weight400.copyWith(
                    height: 1.6,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _handleCheckboxTap,
              child: CustomCheckBox(
                isSelected: isChecked,
                size: 22.sp,
                borderColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.grey
                    : AppColors.whiteShadow,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              widget.title,
              style: StyleText.fontSize14Weight500.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
          ],
        ),

        ...widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final text = entry.value;
          final isSpecial = _isSpecialText(text);

          return Padding(
            padding: EdgeInsets.only(
                left: isArabic ? 0 : 30.w,
                bottom: 4.h,
                right: isArabic ? 30.w : 0.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    text,
                    style: StyleText.fontSize12Weight400.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSpecial)
                  Padding(
                    padding: EdgeInsets.only(
                        left: isArabic ? 0 : 10.sp,
                        right: isArabic ? 10.sp : 0.sp),
                    child: Transform.rotate(
                      angle: Localizations.localeOf(context).languageCode == 'ar'
                          ? pi
                          : 0,
                      child: FlutterSwitch(
                        activeColor: AppColors.secondaryPrimary,
                        height: 22.sp,
                        padding: 3.sp,
                        width: 38.sp,
                        borderRadius: 20.sp,
                        toggleSize: 16.sp,
                        inactiveColor: AppColors.inverseBase.withOpacity(0.16),
                        value: switchStates[index] ?? false,
                        onToggle: (val) {
                          // Only allow toggle if checkbox is checked
                          if (isChecked) {
                            setState(() {
                              switchStates[index] = val;
                            });

                            _saveSwitchState(index, val);
                            widget.onSwitchChanged?.call(switchStates);
                            widget.onSingleSwitchChanged?.call(
                                index: index, value: val, title: widget.title);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
