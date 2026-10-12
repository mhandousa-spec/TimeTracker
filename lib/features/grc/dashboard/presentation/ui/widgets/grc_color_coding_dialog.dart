/// Module: GRC — Dashboard
///
///*************************** FILE INFO ****************************///
/// File Name: grc_color_coding_dialog.dart
/// Purpose: The "Color Coding" dialog (Figma: Choose Category, Choose Policy,
///          Choose Colors, Increment, Color Coding, Save) — CustomDropdown +
///          customButton inside the app's Dialog shell.
/// Author: Amr Mesbah
/// Created: 16/9/2026
///
/// Figma frame "Edit Color Coding": yellow edit badge + title, labelled
/// dropdowns on AppColors.background with the design's placeholders
/// (Policy / List Of Policies / Choose Colors / Choose Increment /
/// Color Coding), Save trailing. Labels without ARB keys are translated
/// inline with [_tr] until keys are added.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_color_coding.dart';
import 'package:knowticed_plus/features/grc/dashboard/domain/entities/grc_dashboard_stats.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// "All policies" row; stored as null on the rule.
const String _allPolicies = '__all__';

String _tr(BuildContext context, String en, String ar) =>
    context.isArabic ? ar : en;

/// Opens the dialog; returns the saved rule, or null when dismissed.
Future<GrcColorRule?> showGrcColorCodingDialog(
  BuildContext context, {
  required GrcDashboardData data,
  required Map<GrcColorCategory, GrcColorRule> current,
}) {
  return showDialog<GrcColorRule>(
    context: context,
    builder: (_) => _GrcColorCodingDialog(data: data, current: current),
  );
}

class _GrcColorCodingDialog extends StatefulWidget {
  final GrcDashboardData data;
  final Map<GrcColorCategory, GrcColorRule> current;

  const _GrcColorCodingDialog({required this.data, required this.current});

  @override
  State<_GrcColorCodingDialog> createState() => _GrcColorCodingDialogState();
}

class _GrcColorCodingDialogState extends State<_GrcColorCodingDialog> {
  late GrcColorCategory _category;
  String? _policyId;
  GrcColorPalette? _palette;
  int? _increment;
  GrcColorOrder? _order;

  @override
  void initState() {
    super.initState();
    _loadFor(GrcColorCategory.policy);
  }

  void _loadFor(GrcColorCategory category) {
    final rule = widget.current[category];
    _category = category;
    _policyId = rule?.policyId;
    _palette = rule?.palette;
    _increment = rule?.increment;
    _order = rule?.order;
  }

  String _paletteLabel(GrcColorPalette p) {
    switch (p) {
      case GrcColorPalette.trafficLight:
        return _tr(context, 'Red / Orange / Green', 'أحمر / برتقالي / أخضر');
      case GrcColorPalette.warm:
        return _tr(context, 'Dark Red / Orange / Gold', 'أحمر داكن / برتقالي / ذهبي');
      case GrcColorPalette.primary:
        return _tr(context, 'Primary Shades', 'درجات اللون الأساسي');
    }
  }

  Widget _swatches(GrcColorPalette p) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final c in p.colors)
            Container(
              width: 10.sp,
              height: 10.sp,
              margin: EdgeInsetsDirectional.only(end: 3.sp),
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
        ],
      );

  Widget _field(String label, Widget dropdown) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            // 12.sp on a phone, like the dialog title.
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.text,
              fontSize: screenSizeOf(context) == ScreenSize.mobile
                  ? 12.sp
                  : null,
            ),
          ),
          SizedBox(height: 6.h),
          dropdown,
        ],
      );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isPhone = screenSizeOf(context) == ScreenSize.mobile;

    final category = _field(
      _tr(context, 'Choose Category', 'اختر الفئة'),
      CustomDropdown<GrcColorCategory>(
        value: _category,
        hint: s.policy,
        fillColor: AppColors.background,
        items: [
          DropdownItem(value: GrcColorCategory.policy, label: s.policy),
          DropdownItem(value: GrcColorCategory.control, label: s.control),
        ],
        onChanged: (v) => setState(() => _loadFor(v)),
      ),
    );

    final policy = _field(
      s.choosePolicy,
      CustomDropdown<String?>(
        value: _policyId,
        hint: _tr(context, 'List Of Policies', 'قائمة السياسات'),
        fillColor: AppColors.background,
        items: [
          DropdownItem<String?>(value: _allPolicies, label: s.all),
          for (final p in widget.data.policies)
            DropdownItem<String?>(
              value: p.id,
              label: p.localizedName(isArabic: context.isArabic),
            ),
        ],
        onChanged: (v) =>
            setState(() => _policyId = v == _allPolicies ? null : v),
      ),
    );

    final colors = _field(
      _tr(context, 'Choose Colors', 'اختر الألوان'),
      CustomDropdown<GrcColorPalette>(
        value: _palette,
        hint: _tr(context, 'Choose Colors', 'اختر الألوان'),
        fillColor: AppColors.background,
        items: [
          for (final p in GrcColorPalette.values)
            DropdownItem(
              value: p,
              label: _paletteLabel(p),
              leading: _swatches(p),
            ),
        ],
        onChanged: (v) => setState(() => _palette = v),
      ),
    );

    final increment = _field(
      _tr(context, 'Increment', 'الزيادة'),
      CustomDropdown<int>(
        value: _increment,
        hint: _tr(context, 'Choose Increment', 'اختر الزيادة'),
        fillColor: AppColors.background,
        items: [
          for (final i in GrcColorRule.increments)
            DropdownItem(
              value: i,
              label: '${LocalizedNumber.digits(context, '$i')}%',
            ),
        ],
        onChanged: (v) => setState(() => _increment = v),
      ),
    );

    final order = _field(
      s.colorCoding,
      CustomDropdown<GrcColorOrder>(
        value: _order,
        hint: s.colorCoding,
        fillColor: AppColors.background,
        items: [
          DropdownItem(
            value: GrcColorOrder.lowToHigh,
            label: _tr(context, 'Low score → first color',
                'الدرجة المنخفضة ← اللون الأول'),
          ),
          DropdownItem(
            value: GrcColorOrder.highToLow,
            label: _tr(context, 'High score → first color',
                'الدرجة المرتفعة ← اللون الأول'),
          ),
        ],
        onChanged: (v) => setState(() => _order = v),
      ),
    );

    Widget row(Widget a, Widget b) => isPhone
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [a, SizedBox(height: 12.h), b],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              SizedBox(width: 15.w),
              Expanded(child: b),
            ],
          );

    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 600.w),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isPhone ? 12.sp : 18.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.sp,
                    height: 36.sp,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomSvgImage(
                        assetPath: AppAssets.edit,
                        width: 20.sp,
                        height: 20.sp,
                        fit: BoxFit.contain,
                        color: AppColors.textButton,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _tr(context, 'Edit Color Coding', 'تعديل ترميز الألوان'),
                      // 12.sp on a phone, 20 on tablet / desktop.
                      style: StyleText.fontSize20Weight500.copyWith(
                        color: AppColors.text,
                        fontSize: isPhone ? 12.sp : null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              row(category, policy),
              SizedBox(height: 12.h),
              row(colors, increment),
              SizedBox(height: 12.h),
              row(order, const SizedBox.shrink()),
              SizedBox(height: 20.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                // customButton's own 38.sp height on every size.
                child: SizedBox(
                  child: customButton(
                  title: s.save,
                  width: isPhone ? 150.w : 180.w,
                  color: AppColors.primary,
                  textStyle: StyleText.fontSize20Weight500.copyWith(
                    color: AppColors.textButton,
                    fontSize: isPhone ? 12.sp : null,
                  ),
                  function: () => Navigator.of(context).pop(
                    GrcColorRule(
                      category: _category,
                      policyId: _policyId,
                      palette: _palette ?? GrcColorPalette.trafficLight,
                      increment: _increment ?? 25,
                      order: _order ?? GrcColorOrder.lowToHigh,
                    ),
                  ),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
