/// Module: services_management_module
/// Description: Sort dropdown menu widget (Date Requested / Duration / Last
///              Update) used on the requests/approvals list screens.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_screenutil, flutter_svg, core/theme/app_colors.dart,
///               generated/l10n.dart, core/theme/app_theme.dart
/// Revision History: Initial version — moved from data/utils/sort.dart to
///                    presentation/ui/widgets/ (audit fix #3: data layer must be UI-free).

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class SortDropdownMenu extends StatefulWidget {
  final Function(String) onSortSelected;
  final String selectedOption;
  final bool isMobile;
  final bool isTabletLandscape;

  const SortDropdownMenu({
    Key? key,
    required this.onSortSelected,
    required this.selectedOption,
    required this.isMobile,
    required this.isTabletLandscape,
  }) : super(key: key);

  @override
  State<SortDropdownMenu> createState() => _SortDropdownMenuState();
}

class _SortDropdownMenuState extends State<SortDropdownMenu> {
  bool _isHovered = false;
  String _selectedSort = "";
  bool _userInteracted = false;

  final LayerLink _layerLink = LayerLink();

  final List<String> optionsEn = const [
    'Date Requested',
    'Duration',
    'Last Update',
  ];

  String _localizedSortLabel(BuildContext context, String key) {
    final s = S.of(context);
    switch (key) {
      case 'Date Requested':
        return s.dateRequested;
      case 'Duration':
        return s.duration;
      case 'Last Update':
        return s.lastUpdate;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedSort = "";
    _userInteracted = false;
  }

  @override
  void didUpdateWidget(covariant SortDropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOption.isEmpty) {
      if (_selectedSort.isNotEmpty || _userInteracted) {
        setState(() {
          _selectedSort = "";
          _userInteracted = false;
        });
      }
      return;
    }
    if (widget.selectedOption != _selectedSort &&
        optionsEn.contains(widget.selectedOption) &&
        _userInteracted) {
      setState(() => _selectedSort = widget.selectedOption);
    }
  }

  bool _isSameAsCurrent(String option) =>
      option == _selectedSort && _selectedSort.isNotEmpty;

  void _showDropdown(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final bgColor =
    lightMode ? AppColors.white : AppColors.chatBackground;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final double triggerWidth = renderBox.size.width;
    final double triggerHeight = renderBox.size.height;

    final double dropdownWidth = triggerWidth < 160 ? 160 : triggerWidth;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (overlayContext) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => overlayEntry.remove(),
        child: Stack(
          children: [
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(triggerWidth - dropdownWidth, triggerHeight + 6),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: dropdownWidth,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: lightMode
                          ? Colors.grey.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: optionsEn.map((optionEn) {
                        final bool isSelected =
                            optionEn == _selectedSort &&
                                _selectedSort.isNotEmpty;
                        final label = _localizedSortLabel(context, optionEn);

                        return StatefulBuilder(
                          builder: (context, setItemState) {
                            bool isItemHovered = false;

                            return MouseRegion(
                              onEnter: (_) =>
                                  setItemState(() => isItemHovered = true),
                              onExit: (_) =>
                                  setItemState(() => isItemHovered = false),
                              child: GestureDetector(
                                onTap: () {
                                  final next =
                                  _isSameAsCurrent(optionEn) ? "" : optionEn;
                                  setState(() {
                                    _selectedSort = next;
                                    _userInteracted = next.isNotEmpty;
                                  });
                                  widget.onSortSelected(next);
                                  overlayEntry.remove();
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  color: isSelected
                                      ? AppColors.primary
                                      : isItemHovered
                                      ? AppColors.primary
                                      .withOpacity(0.1)
                                      : Colors.transparent,
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.textButton
                                          : lightMode
                                          ? AppColors.secondaryText
                                          : AppColors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    final bgColor =
    lightMode ? AppColors.white : AppColors.chatBackground;
    final idleIconColor =
    lightMode ? AppColors.secondaryText : AppColors.grey;

    final bool isActive = _userInteracted && _selectedSort.isNotEmpty;

    final containerColor = isActive ? AppColors.primary : bgColor;

    // ✅ When a sort is selected: icon + text use AppColors.textButton
    // ✅ When idle: icon + text use the theme-aware idle color
    final Color contentColor =
    isActive ? AppColors.textButton : idleIconColor;

    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => _showDropdown(context),
          child: Container(
            width: widget.isMobile
                ? 38.sp
                : (widget.isTabletLandscape ? 100.sp : 38.sp),
            height: 38.sp,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/sort_lines.svg',
                  width: 20.sp,
                  height: 20.sp,
                  fit: BoxFit.scaleDown,
                  // ✅ Icon color: AppColors.textButton when selected, idle color otherwise
                  color: contentColor,
                ),
                if (widget.isTabletLandscape) SizedBox(width: 8.sp),
                if (widget.isTabletLandscape)
                  Text(
                    S.of(context).Sort,
                    style: StyleText.fontSize16Weight500.copyWith(
                      // ✅ Text color: AppColors.textButton when selected, idle color otherwise
                      color: contentColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
