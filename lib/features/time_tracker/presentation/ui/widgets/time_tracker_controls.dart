/// Module: time_tracker / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: time_tracker_controls.dart
/// Purpose: Declares the module's shared toolbar / form controls, one look
///          on every Time Tracker screen: `TtAssets` (the Figma icons),
///          `TtSearchField`, `TtFilterButton`, `TtExportButton`,
///          `TtSegmentedToggle` and `TtUploadButton`.
/// Author: Knowticed Plus team
/// Created at: 9/10/2026 (UI fix round 1 — owner review on iPad)
///
/// All built on core widgets (`AppSearchTextField` 35, `customButtonWithSvg`
/// 6, `CustomSegmentedTabs` 9, `CustomSvgImage` 32, `ButtonSizing` 41).
/// Figma `QVFDXSnFPExQVOIycX9ECb`, iPad VERTICAL frames:
/// - Toolbar (`661:19747` Attendance, same on Requests / Request Types /
///   Locations / Approvals): Search 38 high · Filter = white 38×38 square
///   with the "Tuning 2" icon (23, #797979) · Export = yellow 38×38 square
///   with the "solar:download-linear" tray-arrow icon (24) · then the yellow
///   "+ …" text button. Filter and Export are ICON-ONLY on every device.
/// - Two-option toggle: "Counts / Minutes" (`661:10741`, inside a white
///   card) = a 145×35 page-colour container, padding 5, active tab 25 high,
///   radius 8, text 12 Medium; "Employees | Locations" (`661:93542`, on the
///   page) = a 203×41 card-colour container, padding 7, radius 4, text 16
///   Medium. The container always takes the OTHER surface colour, so it
///   shows on both (owner finding 1).
/// - Upload (`661:16900` / `661:17016` "Upload", `661:80120` "Upload
///   Attachment"): yellow 36 high, radius 4, upload icon 16 + 14 Medium.
/// Haptics: Filter / toggles LOW, Export / Upload MEDIUM (core button).
/// Yellow buttons shrink on tap. Colours are `AppColors` getters (dark mode).
/// Updated: 9/10/2026 - phase 5: `TtSegmentedToggle.compact` (the Overview
/// "My Dashboard | HR" toggle on the page, Figma `661:43164`).
/// Updated: 9/10/2026 - code review (playbook §4 "SVG: CustomSvgImage
/// only"): `TtAssets` gains the app's existing line icons that match the
/// Material ones the module used (calendar, e-mail, phone, edit, reminder
/// bell, clock, person, department, group, description, attachment, send,
/// camera, image, location, status pulse, minus); `TtGlyph` + `TtIcon`
/// draw a leading icon from an SVG asset, falling back to a Material icon
/// ONLY where the app has no equivalent asset (listed in STATUS.md).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The Figma icons exported for this module (read-only `exportAsync` SVG,
/// 9/10/2026), registered through `assets/icons_assets/time_tracker_assets/`.
abstract class TtAssets {
  static const String _dir = 'assets/icons_assets/time_tracker_assets';

  /// "Linear / Settings, Fine Tuning / Tuning 2" (`661:19870`).
  static const String filter = '$_dir/ic_filter.svg';

  /// "solar:download-linear" — the tray with an up arrow (`661:19872`).
  static const String export = '$_dir/ic_export.svg';

  /// "Linear / Arrows Action / Upload" (`661:17006`).
  static const String upload = '$_dir/ic_upload.svg';

  /// ADDED 12/10/2026 (owner R7): toolbar "+" and Import with the SAME
  /// drawn stroke as Filter / Export at `TtToolbar.iconSize` (the house
  /// plus.svg was a 1-unit hairline; upload_arrow a 3-unit bold line).
  static const String add = '$_dir/ic_add.svg';
  static const String import = '$_dir/ic_import.svg';

  // ── Existing app line icons (9/10/2026, code review) ──────────────────────
  static const String _main = 'assets/icons_assets/main_icons_assets';
  static const String _form = 'assets/icons_assets/form_builder_assets';

  static const String calendar = 'assets/icons_assets/roles_assets/calendar.svg';
  static const String email = '$_main/email_envelope.svg';
  static const String phone = 'assets/icons_assets/services_assets/phone_handset.svg';
  static const String edit = '$_main/edit_pencil_square.svg';
  static const String reminder = 'assets/icons_assets/knowledge_hub_assets/send_reminder_icon.svg';
  static const String clock = '$_main/clock_circle.svg';
  static const String person = '$_main/person_outline.svg';
  static const String department = 'assets/icons_assets/services_assets/department_hierarchy_people.svg';
  static const String group = '$_main/users_group_three.svg';
  static const String description = '$_form/description_text_lines.svg';
  static const String attachment = '$_form/attachment_paperclip.svg';
  static const String send = '$_main/send_paper_plane_white.svg';

  /// ADDED 12/10/2026 (owner I5): the house comment-send icon (Knowledge Hub
  /// comments) for the square Send of "Inquiries And Comments".
  static const String commentSend = 'assets/icons_assets/knowledge_hub_assets/svg_send_icon.svg';
  static const String camera = 'assets/icons_assets/messaging_assets/camera.svg';
  static const String image = '$_form/image_add.svg';
  static const String location = '$_form/location_pin.svg';
  static const String status = '$_main/status_pulse_line.svg';
  static const String logout = '$_main/logout_door_arrow.svg';

  /// Red filled circle with a white minus (drawn in its own colours).
  static const String minusCircle = '$_main/minus_circle_red.svg';

  // ── UI quality pass (9/10/2026) ───────────────────────────────────────────
  static const String chevronRight = '$_main/chevron_right.svg';
  static const String chevronLeft = '$_main/chevron_left.svg';

  /// The house trash (tinted white on the red destructive buttons).
  static const String trash = 'assets/icons_assets/form_builder_assets/delete_trash_red.svg';

  /// "⋯" (card overflow menu).
  static const String more = '$_main/dots_horizontal.svg';

  /// Chat bubble of the Message buttons.
  static const String message = '$_main/chat_bubble_dots.svg';
}

/// ADDED 9/10/2026 (code review): a leading icon — an SVG asset (preferred,
/// [TtGlyph.svg]) or a Material icon where the app has no equivalent asset
/// ([TtGlyph.icon]).
class TtGlyph {
  const TtGlyph.svg(String this.asset, {this.tinted = true}) : icon = null;
  const TtGlyph.icon(IconData this.icon)
      : asset = null,
        tinted = true;

  final String? asset;
  final IconData? icon;

  /// Draw the SVG in the caller's colour (false = its own colours).
  final bool tinted;
}

/// ADDED 9/10/2026 (code review): draws a [TtGlyph] at [size] in [color]
/// (`CustomSvgImage` for an asset).
class TtIcon extends StatelessWidget {
  const TtIcon(this.glyph, {super.key, required this.size, this.color});

  final TtGlyph glyph;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final String? asset = glyph.asset;
    if (asset != null) {
      // 9/10/2026 (UI pass): `contain`, not the core default `scaleDown` —
      // an icon asked for at 48 drew at its natural ~20 (the tiny pen in the
      // request details' icon box).
      return CustomSvgImage(
        assetPath: asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: glyph.tinted ? color : null,
      );
    }
    return Icon(glyph.icon, size: size, color: color);
  }
}

/// ADDED 9/10/2026 (owner review): a card's Edit as a small ICON-only yellow
/// square (the house pencil) — placed in a slot the card's text reserves, so
/// it can never cut a name ("Bayanatz Transf…" on the Vacation Balance
/// card). MEDIUM haptic, shrinks on tap, read as "Edit" by screen readers.
class TtIconEditButton extends StatelessWidget {
  const TtIconEditButton({super.key, required this.onTap, this.size});

  final VoidCallback onTap;

  /// Side of the square (default 30.r).
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double side = size ?? 30.r;
    return Semantics(
      button: true,
      label: S.of(context).edit,
      child: ShrinkOnTap(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticController.medium();
            onTap();
          },
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(ButtonSizing.radius),
            ),
            child: Center(
              child: CustomSvgImage(
                assetPath: TtAssets.edit,
                width: side * 0.55,
                height: side * 0.55,
                color: AppColors.textButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ADDED 12/10/2026 (owner rule R9): the module's one text link ("Expand",
/// "Hide", "View All", comment "Edit" / "Delete"). The underline is a 1 px
/// line drawn [gap] BELOW the text box instead of `TextDecoration.underline`
/// (which sits on the baseline and touches the Cairo descenders). Tap area
/// padded so the link is easy to hit. LOW haptic.
class TtLink extends StatelessWidget {
  const TtLink({
    super.key,
    required this.label,
    required this.onTap,
    this.style,
    this.color,
    this.padding,
  });

  final String label;
  final VoidCallback onTap;

  /// Size / weight (colour comes from [color]); default 14 Medium.
  final TextStyle? style;

  /// Text + underline colour; default `AppColors.blue`.
  final Color? color;

  /// Tap padding around the link; default 4 vertical.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.blue;
    return Semantics(
      link: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticController.low();
          onTap();
        },
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(vertical: 4.h),
          child: Container(
            padding: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c))),
            child: Text(
              label,
              style: (style ?? StyleText.fontSize14Weight500).copyWith(color: c, height: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

/// ADDED 9/10/2026 (owner review): ONE height and corner radius for every
/// toolbar control — Search (`AppSearchTextField` 38 / 8), the Department /
/// filter dropdowns, Export and Import (core `ButtonSizing` 38 / 8).
abstract class TtToolbar {
  /// Raw height for `CustomDropdown.height` / `AppSearchTextField.height`
  /// (they scale it themselves).
  static const double height = 38;

  /// The corner radius of every toolbar control.
  static BorderRadius get radius => BorderRadius.circular(ButtonSizing.radius);

  /// ADDED 12/10/2026 (owner R7): ONE icon size for Filter, Export, Import
  /// and "+" (they were 23 / 24 / 16 / 16).
  static double get iconSize => 20.r;
}

/// The module's search box: core `AppSearchTextField` (self-Expanded — put
/// it straight into a `Row`) with its text CENTRED in the 38-high box
/// (owner finding 4): no vertical padding, so the field centres the line
/// itself, and an even line height, so the Cairo cap height sits on the
/// middle instead of ~2 px low (measured on a rendered field: 16 above /
/// 12 below before, 14 / 14 after).
class TtSearchField extends StatelessWidget {
  const TtSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.fillColor,
    this.hint,
    this.onSubmitted,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// ADDED 13/10/2026 (location address search): the keyboard "Search" key
  /// (core `AppSearchTextField.onSubmitted`); null = a plain filter field.
  final ValueChanged<String>? onSubmitted;

  /// ADDED 13/10/2026: e.g. a spinner while a search runs.
  final Widget? suffixIcon;

  /// Defaults to the card colour (the field sits on the page background).
  final Color? fillColor;

  /// ADDED 9/10/2026 (KP-TT-006): the hint ("Search country…"); null =
  /// "Search".
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return AppSearchTextField(
      controller: controller,
      hintText: hint ?? S.of(context).search,
      fillColor: fillColor ?? AppColors.card,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: onSubmitted == null ? null : TextInputAction.search,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.sp),
      valueStyle: StyleText.fontSize14Weight400.copyWith(
        color: AppColors.text,
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );
  }
}

/// Icon-only Filter: a white 38×38 square with the Figma "Tuning" icon;
/// yellow while a filter is applied. LOW haptic (filter / sort standard).
class TtFilterButton extends StatelessWidget {
  const TtFilterButton({super.key, required this.onTap, this.active = false});

  final VoidCallback onTap;

  /// A filter is applied → yellow fill.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.of(context).filter,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticController.low();
          onTap();
        },
        child: Container(
          width: ButtonSizing.iconButtonSize,
          height: ButtonSizing.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(ButtonSizing.radius),
          ),
          child: CustomSvgImage(
            assetPath: TtAssets.filter,
            width: TtToolbar.iconSize,
            height: TtToolbar.iconSize,
            fit: BoxFit.contain,
            color: active ? AppColors.textButton : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}

/// Icon-only Export: the yellow 38×38 core icon button with the Figma
/// tray-arrow icon (MEDIUM haptic from the core button; shrinks on tap).
class TtExportButton extends StatelessWidget {
  const TtExportButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: S.of(context).export,
      child: ShrinkOnTap(
        child: customButtonWithSvg(
          title: '',
          function: onTap,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: TtAssets.export,
          widthImage: TtToolbar.iconSize,
          heightImage: TtToolbar.iconSize,
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}

/// A two-option toggle in its own rounded container (owner finding 1).
///
/// [onCard] = it sits inside a white card (Late History "Counts / Minutes")
/// → page-colour container, compact; otherwise it sits on the page
/// ("Employees | Locations") → card-colour container. The container is
/// never the same colour as the surface under it, in light and dark mode.
class TtSegmentedToggle extends StatelessWidget {
  const TtSegmentedToggle({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.onCard = false,
    this.compact = false,
    this.tabKeys,
  });

  /// ADDED 12/10/2026: one key per tab (core `CustomSegmentedTabs.tabKeys`).
  final List<Key>? tabKeys;

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool onCard;

  /// ADDED 9/10/2026 (phase 5): the compact metrics (padding 5, radius 8,
  /// 12 Medium) on the PAGE — the Overview "My Dashboard | HR" toggle
  /// (Figma `661:43164`: a 200×40 white container, active tab 30 high).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color surface = onCard ? AppColors.background : AppColors.card;
    if (compact && !onCard) {
      return CustomSegmentedTabs(
        tabKeys: tabKeys,
        tabs: tabs,
        selectedIndex: selectedIndex,
        onTabSelected: (int i) {
          if (i == selectedIndex) return;
          HapticController.low();
          onChanged(i);
        },
        containerColor: surface,
        unselectedColor: surface,
        selectedColor: AppColors.primary,
        selectedTextColor: AppColors.textButton,
        unselectedTextColor: AppColors.secondaryText,
        containerPadding: EdgeInsets.all(5.r),
        borderRadius: 8.r,
        tabBorderRadius: 8.r,
        spacing: 5.w,
        tabHorizontalPadding: 16.w,
        tabVerticalPadding: 7.r,
        textStyle: StyleText.fontSize12Weight500,
      );
    }
    return CustomSegmentedTabs(
      tabKeys: tabKeys,
      tabs: tabs,
      selectedIndex: selectedIndex,
      onTabSelected: (int i) {
        if (i == selectedIndex) return;
        HapticController.low();
        onChanged(i);
      },
      containerColor: surface,
      unselectedColor: surface,
      selectedColor: AppColors.primary,
      selectedTextColor: AppColors.textButton,
      unselectedTextColor: AppColors.secondaryText,
      containerPadding: EdgeInsets.all(onCard ? 5.r : 7.r),
      borderRadius: onCard ? 8.r : 4.r,
      tabBorderRadius: onCard ? 8.r : 4.r,
      spacing: onCard ? 5.w : 10.w,
      tabHorizontalPadding: onCard ? 14.w : 8.w,
      tabVerticalPadding: onCard ? 6.5.r : 5.5.r,
      textStyle: onCard ? StyleText.fontSize12Weight500 : StyleText.fontSize16Weight500,
    );
  }
}

/// The yellow Upload button of the attachment fields (owner finding 6):
/// 36 high, radius 4, upload icon + label; 135 wide on tablet / 175 on a
/// phone (Figma), wider when the label needs it. A missing required file
/// draws a red border (owner rule: validation = red border + message).
class TtUploadButton extends StatelessWidget {
  const TtUploadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.hasError = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ShrinkOnTap(
        child: customButtonWithSvg(
          title: label,
          function: onTap,
          color: AppColors.primary,
          colorBorder: hasError ? AppColors.red : AppColors.transparent,
          image: TtAssets.upload,
          widthImage: 16.r,
          heightImage: 16.r,
          svgColor: AppColors.textButton,
          fixedWidth: context.isPhone ? 175.sp : 135.sp,
          fixedHeight: 36.sp,
          fixedRadius: 4.r,
          textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
        ),
      ),
    );
  }
}
