// ****************** FILE INFO ******************
// File Name: crm_template_shared_widgets.dart
// Purpose: Shared widgets for CRM template control pages.
// Author: Mohand Adel
// Created At: 04/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/domain/helpers/crm_controls_dropdown_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmTemplateCountCard extends StatelessWidget {
  const CrmTemplateCountCard({
    required this.label,
    required this.count,
    this.isHighlighted = false,
    this.labelColor,
    super.key,
  });

  final String label;
  final String count;
  final bool isHighlighted;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64.sp,
          height: 64.sp,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isHighlighted ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Text(
            count,
            style: StyleText.fontSize28Weight500.copyWith(
              color: AppColors.secondaryBlack,
            ),
          ),
        ),
        SizedBox(width: 10.sp),
        Text(
          label,
          style: StyleText.fontSize20Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
            color: labelColor ?? AppColors.secondaryBlack,
          ),
        ),
      ],
    );
  }
}

class CrmTemplateStatusButton extends StatefulWidget {
  const CrmTemplateStatusButton({
    required this.initialStatus,
    required this.onChanged,
    super.key,
  });

  final String initialStatus;
  final Future<bool> Function(String status) onChanged;

  @override
  State<CrmTemplateStatusButton> createState() =>
      _CrmTemplateStatusButtonState();
}

class _CrmTemplateStatusButtonState extends State<CrmTemplateStatusButton> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
  }

  @override
  void didUpdateWidget(covariant CrmTemplateStatusButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always adopt the parent's latest status so the button reflects the
    // template status persisted in Firestore.
    if (oldWidget.initialStatus != widget.initialStatus) {
      _status = widget.initialStatus;
    }
  }

  Color get _statusColor {
    switch (_status.toLowerCase()) {
      case 'active':
        return AppColors.chartGreen;
      case 'inactive':
        return AppColors.orange;

      default:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.sp,
      child: CustomDropdown<String>(
        value: _status,
        hint: S.current.crmStatus,
        items: CrmControlsDropdownHelper.statusDropdownItems,
        onChanged: (String? val) async {
          if (val != null && val != _status) {
            final String previousStatus = _status;
            // Optimistically reflect the selection; revert only if the
            // parent reports the change was not persisted.
            setState(() => _status = val);
            final bool changed = await widget.onChanged(val);
            if (!mounted) return;
            if (!changed) setState(() => _status = previousStatus);
          }
        },
        fillColor: _statusColor,
        borderRadius: BorderRadius.circular(8.sp),
        valueStyle: StyleText.fontSize12Weight600.copyWith(
          color: AppColors.white,
        ),
        itemStyle: StyleText.fontSize14Weight600.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final bool showToggle;
  final VoidCallback onTap;
  final Widget? trailingActions;

  const _SectionHeader({
    required this.title,
    required this.isExpanded,
    this.showToggle = true,
    required this.onTap,
    this.trailingActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: StyleText.fontSize16Weight600.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showToggle || trailingActions != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (trailingActions != null) ...[
                trailingActions!,
                if (showToggle) SizedBox(width: 8.sp),
              ],
              if (showToggle)
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    isExpanded ? S.current.crmHide : S.current.crmShow,
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.mediumGrey).copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.blue,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class CrmTemplateSectionShell extends StatelessWidget {
  const CrmTemplateSectionShell({
    required this.title,
    required this.child,
    this.isExpanded = true,
    this.showToggle = true,
    this.onToggleExpand,
    this.trailingActions,
    this.headerBanner,
    super.key,
  });

  final String title;
  final bool isExpanded;
  final bool showToggle;
  final VoidCallback? onToggleExpand;
  final Widget? trailingActions;
  final Widget? headerBanner;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          isExpanded: isExpanded,
          showToggle: showToggle,
          onTap: onToggleExpand ?? () {},
          trailingActions: trailingActions,
        ),
        if (isExpanded) ...[
          if (headerBanner != null) ...[
            SizedBox(height: 4.sp),
            headerBanner!,
            SizedBox(height: 4.sp),
          ] else ...[
            SizedBox(height: 8.sp),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.sp),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10.sp),
            ),
            child: child,
          ),
        ],
      ],
    );
  }
}

class CrmTemplateDisplayField extends StatelessWidget {
  const CrmTemplateDisplayField({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: StyleText.fontSize18Weight500.copyWith(
            color: AppColors.secondaryBlack,
          ),
        ),
        SizedBox(height: 8.sp),
        Container(
          width: double.infinity,
          height: 56.sp,
          alignment: AlignmentDirectional.centerStart,
          padding: EdgeInsets.symmetric(horizontal: 14.sp),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Text(
            value,
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.secondaryBlack,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CrmTemplateEmptyState extends StatelessWidget {
  const CrmTemplateEmptyState({
    this.label,
    super.key,
  });

  final String? label;

  @override
  Widget build(BuildContext context) {
    final String textLabel = label ?? S.current.crmPressToAdd;
    return Column(
      children: [
        SizedBox(height: 18.sp),
        CustomSvgImage(
          assetPath: AppAssets.crmTemplateEmpty,
          width: 280.sp,
          height: 220.sp,
        ),
        SizedBox(height: 18.sp),
        Text(
          textLabel,
          style: StyleText.fontSize26Weight500.copyWith(
            color: AppColors.secondaryBlack,
          ),
        ),
      ],
    );
  }
}
