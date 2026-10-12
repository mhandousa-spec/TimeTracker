import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_sort_option.dart';
class SortDropdownMenu extends StatefulWidget {
  final Function(String) onSortSelected;
  final String selectedOption;
  final bool isMobile;
  final bool isTabletLandscape;

  /// ADDED 19/8/2026 for the "make filter and sort button equal in size" bug.
  ///
  /// Sort used to hard-code its own 100 / 36 / 20 while Filter got its numbers
  /// from the action row, which is how the two drifted apart. The row now
  /// hands Sort the same values it gives Filter, so there is one place to
  /// change and the pair cannot disagree.
  ///
  /// These are ALREADY-SCALED pixel values — pass `100.w`, not `100`. Leaving
  /// one null falls back to the Figma number (MESBAH / node 7444-37220)
  /// scaled here, so existing callers that pass nothing are unaffected.
  final double? expandedWidth;
  final double? buttonHeight;
  final double? iconSize;
  final double? iconTextGap;

  const SortDropdownMenu({
    Key? key,
    required this.onSortSelected,
    required this.selectedOption,
    required this.isMobile,
    required this.isTabletLandscape,
    this.expandedWidth,
    this.buttonHeight,
    this.iconSize,
    this.iconTextGap,
  }) : super(key: key);

  @override
  State<SortDropdownMenu> createState() => _SortDropdownMenuState();
}

class _SortDropdownMenuState extends State<SortDropdownMenu> {
  bool _isHovered = false;
  String _selectedSort = "";
  bool _userInteracted = false;

  /// The option keys are DELIBERATELY language-independent — they travel up to
  /// `home_controller.updateSortOption` and are branched on there. Only
  /// [FormSortOption.labelOf] turns one into on-screen text.
  static const String publishedDateKey = FormSortOption.publishedDate;
  static const String lastUpdateKey = FormSortOption.lastUpdate;

  final List<String> optionsEn = FormSortOption.values;

  String _localizedSortLabel(String key) => FormSortOption.labelOf(key);

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

  bool _isSameAsCurrent(String option) => option == _selectedSort && _selectedSort.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.card;
    final idleIconColor = AppColors.secondaryText;

    final bool isActive = _userInteracted && _selectedSort.isNotEmpty;

    final containerColor = isActive ? AppColors.primary : bgColor;
    final iconColor = isActive ? AppColors.textButton : idleIconColor;
    final textColor = isActive ? AppColors.textButton : AppColors.secondaryText;

    // Figma spec (MESBAH / node 7444-37220): Sort is 100 × 38 — the identical
    // box to Filter. Both numbers now arrive from the action row.
    //
    // FIXED 19/8/2026 — the collapsed state was 36 wide, but Filter collapses
    // to ButtonSizing.iconButtonSize, which is the button height (38). That
    // 2px was the other half of the "make filter and sort button equal in
    // size" report item, and it showed on every narrow layout even once the
    // wide widths agreed.
    final buttonHeight = widget.buttonHeight ?? 38.h;
    final expandedWidth = widget.expandedWidth ?? 100.w;
    final iconSize = widget.iconSize ?? 23.sp;
    final iconTextGap = widget.iconTextGap ?? 8.sp;

    final buttonWidth = widget.isTabletLandscape && !widget.isMobile
        ? expandedWidth
        : buttonHeight;

    final dropdownItemWidth = expandedWidth;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: PopupMenuButton<String>(
        tooltip: "",
        onSelected: (optionEn) {
          final next = _isSameAsCurrent(optionEn) ? "" : optionEn;
          setState(() {
            _selectedSort = next;
            _userInteracted = next.isNotEmpty;
          });
          widget.onSortSelected(next);
        },
        offset: const Offset(0, 45),
        color: bgColor,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: dropdownItemWidth,
          maxWidth: dropdownItemWidth,
        ),
        itemBuilder: (context) {
          return optionsEn.map((optionEn) {
            bool isItemHovered = false;
            return PopupMenuItem<String>(
              value: optionEn,
              height: 40.h,
              padding: EdgeInsets.zero,
              child: StatefulBuilder(
                builder: (context, setItemState) {
                  final bool isSelected = optionEn == _selectedSort && _selectedSort.isNotEmpty;

                  final Color rowBg = isSelected
                      ? AppColors.primary
                      : (isItemHovered ? AppColors.primary : AppColors.transparent);

                  final Color rowText = isSelected
                      ? AppColors.textButton
                      : (isItemHovered
                      ? AppColors.textButton
                      : AppColors.secondaryText);

                  final label = _localizedSortLabel(optionEn);

                  return MouseRegion(
                    onEnter: (_) => setItemState(() => isItemHovered = true),
                    onExit: (_) => setItemState(() => isItemHovered = false),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15.sp, horizontal: 6.sp),
                      decoration: BoxDecoration(
                        color: rowBg,
                        borderRadius: BorderRadius.circular(0.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style:StyleText.fontSize12Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                                color: AppColors.secondaryText
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList();
        },
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Figma: 23 × 23 icon, 8 gap, then the label — same as Filter.
              // The icon was 20 and the label was SemiBold while Filter's is
              // Medium, so the two buttons read as different sizes/weights
              // even when their boxes matched.
              SvgPicture.asset(
                'assets/icons_assets/main_icons_assets/filter_sliders.svg',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.scaleDown,
                color: iconColor,
              ),
              if (widget.isTabletLandscape) SizedBox(width: iconTextGap),
              if (widget.isTabletLandscape)
                Text(
                  S.of(context).sort,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: textColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}