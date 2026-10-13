/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: custom_multi_select_dropdown.dart
/// Purpose: Declares `MultiSelectDropdownItem`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

/// A multi-select dropdown item model
class MultiSelectDropdownItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final bool enabled;

  const MultiSelectDropdownItem({
    required this.value,
    required this.label,
    this.leading,
    this.enabled = true,
  });
}

/// Custom multi-select dropdown widget.
///
/// Mirrors [CustomDropdown] in look & behaviour, but lets the user pick
/// multiple values. Each row shows a [CustomCheckBox]. The overlay stays
/// open while selecting; tapping outside closes it.
class CustomMultiSelectDropdown<T> extends StatefulWidget {
  /// Currently selected values.
  final List<T> values;

  /// All selectable items.
  final List<MultiSelectDropdownItem<T>> items;

  /// Fires with the new full selection whenever an item is toggled.
  final ValueChanged<List<T>>? onChanged;

  final String? hint;
  final String? label;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool required;
  final Color? fillColor;
  final double? maxOverlayHeight;
  final EdgeInsetsGeometry? triggerPadding;

  /// Exact height of the trigger.
  ///
  /// ADDED 22/8/2026. The trigger grew out of its content padding, so a
  /// dropdown sitting in a row beside `CustomTextField` — which takes a
  /// `height:` directly — came out visibly taller than the fields next to it
  /// (Notification Control's "Notification Type" against Subject / Body).
  /// Deriving the same height by hand-tuning `triggerPadding` works but is
  /// arithmetic the caller should not have to do; passing the same number the
  /// text fields are given is exact.
  ///
  /// `null` keeps the original behaviour: the trigger sizes to its content.
  final double? height;

  /// Whether [height] sizes the WHOLE trigger box instead of its CONTENT.
  ///
  /// ADDED 10/9/2026. Sizing the content — the original behaviour, and still
  /// the default — hands `InputDecorator` a child that is [height] tall. A box
  /// that tall has no text in it to take a baseline from, so
  /// `RenderBox.getDistanceToBaseline` falls back to its bottom edge, and the
  /// decorator baseline-aligns `hintText` to exactly that: the placeholder is
  /// drawn sitting ON the bottom border of the field instead of centred in it.
  ///
  /// It was easy to miss while the hint disappeared on the first pick. It is
  /// not missable next to `alwaysShowHint`, where the hint is the field's
  /// permanent face.
  ///
  /// True instead wraps the finished decorator in a `SizedBox`, which is what
  /// `CustomDropdown._sized` has always done — the child stays its natural
  /// height, so the hint keeps its own baseline and the decorator centres it in
  /// the height it is given. Use it whenever this widget has to stand beside a
  /// `CustomDropdown` of the same [height], since only this mode makes the two
  /// measure and read alike.
  ///
  /// Defaults to false, so every existing caller is pixel-unchanged.
  final bool heightSizesWholeTrigger;
  final BorderRadius? borderRadius;

  /// ADDED 13/10/2026 (Time Tracker owner) — the trigger's corner radius.
  /// [borderRadius] has never reached the trigger (it stays 4), and callers
  /// rely on that look, so this is a separate opt-in. Null = 4.
  final BorderRadius? triggerBorderRadius;
  final TextStyle? valueStyle;
  /// Hint style. Its font SIZE is ignored — the hint is always 12.sp.
  final TextStyle? hintStyle;
  final TextStyle? itemStyle;
  /// Label style. Its font SIZE is ignored — the label is always 14.sp.
  final TextStyle? labelStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final double? itemHeight;
  final double overlayElevation;
  final double? overlayOffset;
  final bool showDivider;
  final Color? dividerColor;
  final Widget? emptyWidget;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  /// Builds the text shown on the trigger from the selected items.
  /// Defaults to comma-joined labels. Ignored when [alwaysShowHint] is true.
  final String Function(List<MultiSelectDropdownItem<T>> selected)?
      selectedTextBuilder;

  /// Keeps [hint] on the trigger at all times instead of replacing it with the
  /// selected labels. ADDED 16/8/2026. Mirrors `CustomDropdown.alwaysShowHint`.
  ///
  /// Use this when the field is PAIRED WITH ITS OWN LIST OF PICKS — the
  /// department chip row under the Department field, for instance. There the
  /// comma-joined preview says the same thing twice and says it worse: it
  /// ellipsises the moment there are three picks, and the field stops naming
  /// what it is for as soon as anything is chosen.
  ///
  /// Leave it false when the trigger is the ONLY place the selection appears —
  /// `viewable_fields_field` has no chip row, so blanking its preview would
  /// leave the user nothing to read back.
  final bool alwaysShowHint;

  const CustomMultiSelectDropdown({
    super.key,
    required this.items,
    this.values = const [],
    this.onChanged,
    this.hint,
    this.label,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.required = false,
    this.fillColor,
    this.maxOverlayHeight,
    this.triggerPadding,
    this.height,
    this.heightSizesWholeTrigger = false,
    this.borderRadius,
    this.triggerBorderRadius,
    this.valueStyle,
    this.hintStyle,
    this.itemStyle,
    this.labelStyle,
    this.errorStyle,
    this.helperStyle,
    this.itemHeight,
    this.overlayElevation = 4,
    this.overlayOffset,
    this.showDivider = false,
    this.dividerColor,
    this.emptyWidget,
    this.onOpen,
    this.onClose,
    this.alwaysShowHint = false,
    this.selectedTextBuilder,
  });

  @override
  State<CustomMultiSelectDropdown<T>> createState() =>
      _CustomMultiSelectDropdownState<T>();
}

class _CustomMultiSelectDropdownState<T>
    extends State<CustomMultiSelectDropdown<T>>
    with SingleTickerProviderStateMixin {
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _triggerKey = GlobalKey();

  // Local copy of selection so the overlay can rebuild instantly.
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.values);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant CustomMultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep local selection in sync if the parent pushes new values.
    if (!_listEquals(oldWidget.values, widget.values)) {
      _selected = List<T>.from(widget.values);
      // didUpdateWidget runs during the build phase, so rebuilding the overlay
      // synchronously here throws "markNeedsBuild() called during build".
      // Defer it to the next frame instead.
      if (_overlayEntry != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _overlayEntry?.markNeedsBuild();
        });
      }
    }
  }

  /// Clamps the whole trigger to [CustomMultiSelectDropdown.height], or leaves
  /// it alone. Mirrors `CustomDropdown._sized` exactly — see
  /// [CustomMultiSelectDropdown.heightSizesWholeTrigger].
  Widget _sizedTrigger(Widget trigger) {
    final double? h = widget.height;
    if (h == null || !widget.heightSizesWholeTrigger) return trigger;
    return SizedBox(height: h.sp, child: trigger);
  }

  bool _listEquals(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (final e in a) {
      if (!b.contains(e)) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _closeOverlay();
    _animController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    _isOpen ? _closeOverlay() : _openOverlay();
  }

  void _toggleItem(MultiSelectDropdownItem<T> item) {
    setState(() {
      if (_selected.contains(item.value)) {
        _selected.remove(item.value);
      } else {
        _selected.add(item.value);
      }
    });
    _overlayEntry?.markNeedsBuild();
    widget.onChanged?.call(List<T>.from(_selected));
  }

  void _openOverlay() {
    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerSize = renderBox.size;
    final verticalOffset = widget.overlayOffset ?? 2.h;

    final globalOffset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final spaceBelow = screenHeight - globalOffset.dy - triggerSize.height;
    final spaceAbove = globalOffset.dy;
    final openUpward = spaceBelow < 150.h && spaceAbove > spaceBelow;

    _overlayEntry = OverlayEntry(
      builder: (_) => _MultiSelectOverlay<T>(
        layerLink: _layerLink,
        triggerSize: triggerSize,
        verticalOffset: verticalOffset,
        openUpward: openUpward,
        items: widget.items,
        maxHeight: widget.maxOverlayHeight ?? 240.h,
        itemHeight: widget.itemHeight ?? 44.h,
        borderRadius: BorderRadius.circular(4.r),
        elevation: widget.overlayElevation,
        itemStyle: widget.itemStyle,
        showDivider: widget.showDivider,
        dividerColor: widget.dividerColor,
        emptyWidget: widget.emptyWidget,
        fadeAnimation: _fadeAnimation,
        scaleAnimation: _scaleAnimation,
        selectedValues: _selected,
        onToggle: _toggleItem,
        onDismiss: _closeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);
    setState(() => _isOpen = true);
    widget.onOpen?.call();
  }

  void _closeOverlay() {
    if (_overlayEntry == null) return;
    _animController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
    if (mounted) setState(() => _isOpen = false);
    widget.onClose?.call();
  }

  List<MultiSelectDropdownItem<T>> get _selectedItems =>
      widget.items.where((e) => _selected.contains(e.value)).toList();

  String get _selectedText {
    final selected = _selectedItems;
    if (selected.isEmpty) return '';
    if (widget.selectedTextBuilder != null) {
      return widget.selectedTextBuilder!(selected);
    }
    return selected.map((e) => e.label).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final radius = widget.triggerBorderRadius ?? BorderRadius.circular(4.r);

    // With [alwaysShowHint] the trigger renders as if nothing were selected —
    // InputDecorator only draws `hintText` while it believes it is empty, so
    // this one value drives `isEmpty`, `hintText` and the child together.
    // `_selected` is untouched, so the menu's checkboxes still tick.
    final isEmpty = widget.alwaysShowHint || _selectedItems.isEmpty;

    // ── Label 14.sp / hint 12.sp, ALWAYS (16/8/2026) ──────────────────────
    //
    // The last of the four form controls to be brought onto the rule that
    // `CustomTextField`, `CustomDropdown` and `CustomDropdownCalendar` already
    // follow. It matters most here: this widget sits in the SAME ROW as a
    // plain dropdown on both Department screens, so a hint one size larger
    // than its neighbour's was visible side by side.
    //
    // [labelStyle] / [hintStyle] keep control of colour, weight and the rest;
    // only the font size is reapplied on top of whatever comes in.
    final TextStyle labelStyle = (widget.labelStyle ??
            StyleText.fontSize14Weight500.copyWith(
              color: hasError
                  ? AppColors.red
                  : widget.enabled
                      ? AppColors.text
                      : AppColors.text.withOpacity(0.4),
            ))
        .copyWith(fontSize: 14.sp);

    final TextStyle hintStyle = (widget.hintStyle ??
            StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text.withOpacity(0.4),
            ))
        .copyWith(fontSize: 12.sp);

    // ── Trigger content ──────────────────────────────────────────────────
    //
    // Built here rather than inline so [height] can wrap it. The height is
    // carried by the DECORATOR'S CHILD, not by a SizedBox around the
    // InputDecorator: `InputDecorator` paints its filled background over the
    // height its content asks for and merely stretches its RenderBox to a
    // tighter constraint, so an outer SizedBox would leave a band of
    // transparent dead space under a visibly-too-short box. Sizing the child
    // makes the content height the box height, and the fill follows it.
    //
    // `.sp` matches `CustomTextField`, which interprets its own `height:` the
    // same way — the two share a row on Notification Control and must resolve
    // the same `36.h` to the same pixels.
    Widget triggerContent = !isEmpty
        ? Text(
            _selectedText,
            style: widget.valueStyle ??
                StyleText.fontSize14Weight400.copyWith(
                  color: widget.enabled
                      ? AppColors.text
                      : AppColors.text.withOpacity(0.4),
                ),
            overflow: TextOverflow.ellipsis,
          )
        : const SizedBox.shrink();

    // Only in the content-sizing mode. See [heightSizesWholeTrigger] for why
    // the other mode must leave the child at its natural height.
    final bool sizesContent =
        widget.height != null && !widget.heightSizesWholeTrigger;

    if (sizesContent) {
      triggerContent = SizedBox(
        height: widget.height!.sp,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: triggerContent,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──────────────────────────────────────────
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label,
              style: labelStyle,
              children: widget.required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.red,
                          fontSize: 14.sp,
                        ),
                      )
                    ]
                  : [],
            ),
          ),
          SizedBox(height: 6.h),
        ],

        // ── Trigger ────────────────────────────────────────
        //
        // `_sizedTrigger` applies [height] out here when
        // [heightSizesWholeTrigger] is on, and is a no-op otherwise. The
        // `_triggerKey` stays on the decorator either way, so the overlay goes
        // on measuring the same box it always did.
        _sizedTrigger(
          CompositedTransformTarget(
            link: _layerLink,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: InputDecorator(
                  key: _triggerKey,
                  isFocused: false,
                  isEmpty: isEmpty,
                  decoration: InputDecoration(
                    isDense: true,
                    // 10.h vertical (16/8/2026, was 12.h). The trigger carries a
                    // 20.sp chevron in its suffix, so its content is already taller
                    // than a text field's single line — equal padding made it stand
                    // proud of the fields beside it. `.h` rather than `.sp` so it
                    // matches `CustomDropdown` and `CustomDropdownCalendar`
                    // exactly; the three share a row and must resolve identically.
                    // With an explicit height the box, not the padding, sets the
                    // size — keeping the 10.h here as well would push the content
                    // past a 36.h trigger and overflow it.
                    // The horizontal-only default belongs to CONTENT sizing,
                    // where a vertical inset is added to the height rather than
                    // absorbed by it. When the box itself is sized the decorator
                    // clamps to what it is given, so the normal padding applies.
                    contentPadding: widget.triggerPadding ??
                        (sizesContent
                            ? EdgeInsets.symmetric(horizontal: 12.w)
                            : EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h)),
                    filled: true,
                    fillColor: widget.enabled
                        ? (widget.fillColor ?? AppColors.card)
                        : AppColors.card.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: hasError
                        ? OutlineInputBorder(
                            borderRadius: radius,
                            borderSide:
                                BorderSide(color: AppColors.red, width: 1.5.w),
                          )
                        : OutlineInputBorder(
                            borderRadius: radius,
                            borderSide: BorderSide.none,
                          ),
                    focusedBorder: hasError
                        ? OutlineInputBorder(
                            borderRadius: radius,
                            borderSide:
                                BorderSide(color: AppColors.red, width: 1.5.w),
                          )
                        : OutlineInputBorder(
                            borderRadius: radius,
                            borderSide: BorderSide.none,
                          ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: radius,
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Padding(
                            // FIXED 9/9/2026 — directional, so the leading
                            // gutter follows the text direction. See the note on
                            // `CustomDropdown`'s prefix; this widget carried the
                            // same non-flipping insets.
                            padding: EdgeInsetsDirectional.only(
                                start: 12.w, end: 8.w),
                            child: widget.prefixIcon,
                          )
                        : null,
                    prefixIconConstraints: const BoxConstraints(),
                    suffixIcon: Padding(
                      // FIXED 9/9/2026 — directional, so the chevron keeps
                      // its 12 against the trailing edge in Arabic too.
                      padding: EdgeInsetsDirectional.only(start: 8.w, end: 12.w),
                      child: widget.suffixIcon ??
                          AnimatedRotation(
                            turns: _isOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: CustomSvgImage(
       assetPath: 'assets/icons_assets/main_icons_assets/chevron_down.svg',
       width: 20.sp,
       height: 20.sp,
       fit: BoxFit.contain,
       colorFilter: ColorFilter.mode(
                                hasError
                                    ? AppColors.red
                                    : widget.enabled
                                        ? AppColors.text.withOpacity(0.6)
                                        : AppColors.text.withOpacity(0.3),
                                BlendMode.srcIn,
                              ),
     ),
                          ),
                    ),
                    suffixIconConstraints: const BoxConstraints(),
                    hintText: isEmpty ? (widget.hint ?? '') : null,
                    hintStyle: hintStyle,
                    errorText: null,
                  ),
                  child: triggerContent,
              ),
            ),
          ),
        ),

        // ── Error / Helper ─────────────────────────────────
        if (hasError) ...[
          SizedBox(height: 4.h),
          Text(
            widget.errorText!,
            style: widget.errorStyle ??
                StyleText.fontSize12Weight400.copyWith(color: AppColors.red),
          ),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: 4.h),
          Text(
            widget.helperText!,
            style: widget.helperStyle ??
                StyleText.fontSize12Weight400.copyWith(
                    color: AppColors.text.withOpacity(0.5)),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _MultiSelectOverlay<T> extends StatelessWidget {
  final LayerLink layerLink;
  final Size triggerSize;
  final double verticalOffset;
  final bool openUpward;
  final List<MultiSelectDropdownItem<T>> items;
  final double maxHeight;
  final double itemHeight;
  final BorderRadius borderRadius;
  final double elevation;
  final TextStyle? itemStyle;
  final bool showDivider;
  final Color? dividerColor;
  final Widget? emptyWidget;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final List<T> selectedValues;
  final ValueChanged<MultiSelectDropdownItem<T>> onToggle;
  final VoidCallback onDismiss;

  const _MultiSelectOverlay({
    required this.layerLink,
    required this.triggerSize,
    required this.verticalOffset,
    required this.openUpward,
    required this.items,
    required this.maxHeight,
    required this.itemHeight,
    required this.borderRadius,
    required this.elevation,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.selectedValues,
    required this.onToggle,
    required this.onDismiss,
    this.itemStyle,
    this.showDivider = false,
    this.dividerColor,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Full-screen dismiss layer
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onDismiss,
            ),
          ),

          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            targetAnchor:
                openUpward ? Alignment.topLeft : Alignment.bottomLeft,
            followerAnchor:
                openUpward ? Alignment.bottomLeft : Alignment.topLeft,
            offset: Offset(
              0,
              openUpward ? -verticalOffset : verticalOffset,
            ),
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                alignment:
                    openUpward ? Alignment.bottomCenter : Alignment.topCenter,
                child: Material(
                  elevation: elevation,
                  borderRadius: borderRadius,
                  color: AppColors.card,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight,
                      minWidth: triggerSize.width,
                      maxWidth: triggerSize.width,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: items.isEmpty
                          ? SizedBox(
                              height: itemHeight,
                              child: emptyWidget ??
                                  Center(
                                    child: Text(
                                      'No options',
                                      style: StyleText.fontSize13Weight400.copyWith(
                                        color: AppColors.text.withOpacity(0.4),
                                      ),
                                    ),
                                  ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: items.length,
                              separatorBuilder: (_, __) => showDivider
                                  ? Divider(
                                      height: 1.h,
                                      thickness: 1.h,
                                      color: dividerColor ??
                                          AppColors.text.withOpacity(0.08),
                                    )
                                  : const SizedBox.shrink(),
                              itemBuilder: (_, i) {
                                final item = items[i];
                                final isSelected =
                                    selectedValues.contains(item.value);
                                return _MultiSelectItemTile<T>(
                                  item: item,
                                  isSelected: isSelected,
                                  height: itemHeight,
                                  style: itemStyle,
                                  onTap: item.enabled
                                      ? () => onToggle(item)
                                      : null,
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item tile with checkbox + hover state
// ─────────────────────────────────────────────────────────────────────────────

class _MultiSelectItemTile<T> extends StatefulWidget {
  final MultiSelectDropdownItem<T> item;
  final bool isSelected;
  final double height;
  final TextStyle? style;
  final VoidCallback? onTap;

  const _MultiSelectItemTile({
    required this.item,
    required this.isSelected,
    required this.height,
    this.style,
    this.onTap,
  });

  @override
  State<_MultiSelectItemTile<T>> createState() =>
      _MultiSelectItemTileState<T>();
}

class _MultiSelectItemTileState<T> extends State<_MultiSelectItemTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    return MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          // Selection is indicated by the checkbox only — no primary
          // background tint for selected items.
          color: _hovered && !isDisabled
              ? AppColors.primary
              : AppColors.transparent,
          child: Row(
            children: [
              CustomCheckBox(
                isSelected: widget.isSelected,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              if (widget.item.leading != null) ...[
                widget.item.leading!,
                SizedBox(width: 8.w),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: (widget.style ??
                          (widget.isSelected
                              ? StyleText.fontSize14Weight500
                              : StyleText.fontSize14Weight400))
                      .copyWith(
                    color: isDisabled
                        ? AppColors.text.withOpacity(0.3)
                        : _hovered
                            ? AppColors.textButton
                            : AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
