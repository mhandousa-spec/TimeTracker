/// Module: messaging / chat / presentation/ui/widgets/menus/state_drop_down.dart
/// Purpose: Overflow menu driven by an enum. Renders [customButton] as the
///          trigger and one row per enum value, highlighting [currentValue].
///
/// Built on PopupMenuButton rather than a dropdown widget because the trigger
/// here is an arbitrary widget (the "⋮" icon), which CustomDropdown — which
/// always renders its own field-style trigger — can't express.
///
/// Lives in the messaging feature rather than lib/core because it resolves
/// labels through ChatActionsEnum, a messaging domain type.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import '../../../../domain/enum/chat_actions.dart';

class StateDropDown extends StatelessWidget {
  const StateDropDown({
    required this.items,
    required this.currentValue,
    required this.customButton,
    this.yOffset = 0,
    required this.textButton,
    this.menuWidth,
    this.xOffset = 0,
    required this.onChanged,
    this.labelOf,
    super.key,
  });

  /// Optional per-item label override (e.g. "Pin" ↔ "Unpin"). Null or a null
  /// result falls back to the enum's own label.
  final String? Function(Enum value)? labelOf;

  final List<Enum> items;
  final Enum? currentValue;
  final Widget? customButton;

  /// Extra vertical nudge, measured from the BOTTOM of the trigger.
  ///
  /// CHANGED 2/9/2026. This used to be measured from the trigger's TOP-LEFT,
  /// because PopupMenuButton defaults to `PopupMenuPosition.over` — so the
  /// caller had to pass the trigger's own height just to get the menu below
  /// it, and the ⋮ menu passed 180.sp, which dropped it most of the way down
  /// the chat. `position: PopupMenuPosition.under` below makes "under the
  /// trigger" the baseline, so 0 is the right value and this is only a nudge.
  final double yOffset;

  /// Kept for source compatibility; the trigger is [customButton].
  final String textButton;

  final double? menuWidth;
  final double xOffset;
  final void Function(Enum) onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.isArabic;

    // One source of truth for the row height: PopupMenuItem.height and the
    // coloured Container inside it must agree, or the highlight under-fills.
    final double rowHeight = 35.sp;

    return PopupMenuButton<Enum>(
      // Anchor to the BOTTOM of the trigger rather than covering it.
      position: PopupMenuPosition.under,
      offset: Offset(xOffset, yOffset),
      color: AppColors.card,
      // No Material-3 tint over the card colour (#5 "why is it transparent").
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      constraints: menuWidth == null
          ? null
          : BoxConstraints(minWidth: menuWidth!, maxWidth: menuWidth!),
      onSelected: onChanged,
      itemBuilder: (_) => items.map((Enum value) {
        final bool isSelected = currentValue == value;
        final String label = labelOf?.call(value) ??
            (value is ChatActionsEnum ? value.getLabel(isAr) : value.name);

        return PopupMenuItem<Enum>(
          value: value,
          height: rowHeight,
          padding: EdgeInsets.zero,
          // Bug report #5: hovering a row paints it AppColors.primary with
          // AppColors.textButton text (same as CustomDropdown). Rows are
          // opaque AppColors.card so nothing shows through the menu.
          child: _HoverMenuRow(
            label: label,
            height: rowHeight,
            isSelected: isSelected,
          ),
        );
      }).toList(),
      child: customButton ??
          Container(
            width: 70.w,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(AppAssets.sort),
                Text(
                  isAr ? 'ترتيب' : 'Sort',
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
                ),
              ],
            ),
          ),
    );
  }
}


/// One row of [StateDropDown]: opaque, and primary / textButton when hovered
/// or selected.
class _HoverMenuRow extends StatefulWidget {
  const _HoverMenuRow({
    required this.label,
    required this.height,
    required this.isSelected,
  });

  final String label;
  final double height;
  final bool isSelected;

  @override
  State<_HoverMenuRow> createState() => _HoverMenuRowState();
}

class _HoverMenuRowState extends State<_HoverMenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isSelected || _hovered;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        width: double.infinity,
        // Fixed height, never double.infinity — PopupMenuButton lays items
        // out in an unbounded scroll view (see the 2/9/2026 note history).
        height: widget.height,
        color: active ? AppColors.primary : AppColors.card,
        child: Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // Figma 6799:8931 — 12px items, grey at rest, dark on the yellow
          // highlight.
          style: StyleText.fontSize12Weight400.copyWith(
            color: active ? AppColors.textButton : AppColors.secondaryBlack,
          ),
        ),
      ),
    );
  }
}
