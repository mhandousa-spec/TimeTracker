// ****************** FILE INFO ******************
// File Name: crm_section_card.dart
// Purpose: Reusable CRM form section container with external header title, collapsible toggle, and flat card body.
// Author: Mohand Adel
// Created At: 23/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CrmSectionCard extends StatefulWidget {
  /// The section title displayed outside and above the white card.
  final String? title;

  /// Optional custom title widget if not using standard string title.
  final Widget? titleWidget;

  /// Optional trailing widget in the header row (replaces hide/show toggle if provided).
  final Widget? trailing;

  /// The form fields or widgets displayed inside the white container card.
  final Widget child;

  /// Whether to show the Hide / Show toggle button on the top right.
  final bool showHideToggle;

  /// Initial expanded state of the section (defaults to true).
  final bool isInitiallyExpanded;

  /// Callback fired when expanded/collapsed state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Inner padding of the white container card (defaults to 16.sp all).
  final EdgeInsetsGeometry? padding;

  /// Margin around the entire section component (defaults to EdgeInsets.zero).
  final EdgeInsetsGeometry? margin;

  /// Background color of the container card (defaults to AppColors.card / white).
  final Color? cardColor;

  /// Border radius of the container card (defaults to 10.sp).
  final BorderRadiusGeometry? borderRadius;

  /// Spacing between the external header row and the container card (defaults to 10.sp).
  final double? headerSpacing;

  const CrmSectionCard({
    super.key,
    this.title,
    this.titleWidget,
    this.trailing,
    required this.child,
    this.showHideToggle = true,
    this.isInitiallyExpanded = true,
    this.onExpansionChanged,
    this.padding,
    this.margin,
    this.cardColor,
    this.borderRadius,
    this.headerSpacing,
  });

  @override
  State<CrmSectionCard> createState() => _CrmSectionCardState();
}

class _CrmSectionCardState extends State<CrmSectionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHeaderRow(),
          if (_isExpanded) ...[
            SizedBox(height: widget.headerSpacing ?? 10.sp),
            Container(
              width: double.infinity,
              padding: widget.padding ?? EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: widget.cardColor ?? AppColors.card,
                borderRadius:
                    widget.borderRadius ?? BorderRadius.circular(10.sp),
              ),
              child: widget.child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (widget.titleWidget != null)
          widget.titleWidget!
        else if (widget.title != null)
          Text(
            widget.title!,
            style: StyleText.fontSize14Weight600.copyWith(
              color: AppColors.text,
            ),
          )
        else
          const SizedBox.shrink(),
        if (widget.trailing != null)
          widget.trailing!
        else if (widget.showHideToggle)
          GestureDetector(
            onTap: _toggle,
            child: Text(
              _isExpanded ? S.current.crmHide : S.current.crmShow,
              style: StyleText.fontSize14Weight500.copyWith(
                color: AppColors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
