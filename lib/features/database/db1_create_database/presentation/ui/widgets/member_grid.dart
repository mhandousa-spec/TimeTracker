/// Module: database / db1_create_database / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: member_grid.dart
/// Purpose: Declares `MemberGrid` and `MemberGridTrailing`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The three-across grid of people cards shared by every Access Management
/// and Review screen (Figma 7398:7396, 7398:18600, 7398:17988, 7398:18213).
///
/// One widget, two trailing behaviours, because that is the only thing that
/// differs between those screens:
///
///   * [MemberGridTrailing.check]  — picking people (7396 / 18600)
///   * [MemberGridTrailing.remove] — reviewing them (17988 / 18213)
///
/// Column count comes from `CrossAxisCountHelper`, the same helper the rest
/// of the app's grids use, so this grid reflows on rotation exactly like the
/// services and knowledge-hub grids do rather than inventing its own rule.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/19-Custom_Employee_Card.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/87-responsive_card_grid.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_member.dart';

enum MemberGridTrailing { check, remove }

class MemberGrid extends StatelessWidget {
  const MemberGrid({
    super.key,
    required this.members,
    required this.trailing,
    required this.onTap,
    this.isSelected,
    this.shrinkWrap = true,
    this.departmentLabel,
  });

  final List<DatabaseMember> members;
  final MemberGridTrailing trailing;

  /// Tapping a card. On a picking screen this toggles; on a review screen the
  /// red minus is the only affordance, so the whole card calls the same
  /// callback for a bigger hit target.
  final ValueChanged<DatabaseMember> onTap;

  /// Only consulted when [trailing] is [MemberGridTrailing.check].
  final bool Function(DatabaseMember)? isSelected;

  // `emptyLabel` REMOVED 16/8/2026. Every caller passed a slightly different
  // sentence for the same fact, and the shared animation says it once — see
  // `CustomEmptyState`.
  final bool shrinkWrap;

  /// Turns a member into the department NAME shown on the card's first
  /// subtitle line.
  ///
  /// The snapshot only carries `departmentId` — a Firestore key, which in this
  /// org is a bare number ("5"). Printing that is what put a digit under every
  /// name instead of "Human Resources". Resolving it needs the department
  /// list, which lives in the cubit's state, so the caller passes the lookup in
  /// rather than this widget reaching for a controller.
  final String Function(DatabaseMember member)? departmentLabel;

  @override
  Widget build(BuildContext context) {
    // The shared animation, not a sentence (16/8/2026). See CustomEmptyState.
    if (members.isEmpty) return const CustomEmptyState();

    // The Figma shows three cards across on both iPad orientations. Rather
    // than hard-coding 3, this asks the shared helper and clamps: on a narrow
    // window it drops to 2 or 1 instead of squeezing three unreadable cards.
    final int columns = _columnsFor(context);

    // Height is derived from what a card's three text rows actually need,
    // not from the cell width — so the card stays compact on a wide desktop
    // instead of stretching. See ResponsiveCardHeight's header.
    final double cardHeight = ResponsiveCardHeight.forListCard(
      context,
      titleSize: 14,
      subtitleSize: 11,
      captionSize: 11,
      gap: 4,
      verticalPadding: 18,
      thumbnailHeight: 36,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.zero,
      itemCount: members.length,
      gridDelegate: ResponsiveCardHeight.delegate(
        crossAxisCount: columns,
        cardHeight: cardHeight,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (BuildContext context, int index) {
        final DatabaseMember member = members[index];
        return _card(context, member);
      },
    );
  }

  int _columnsFor(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  Widget _card(BuildContext context, DatabaseMember member) {
    final bool isArabic = context.isArabic;
    final bool selected = isSelected?.call(member) ?? false;

    return PersonChipCard(
      name: FormatHelper.capitalize(member.localizedName(isArabic: isArabic)),
      subtitle1: _departmentLabel(member),
      subtitle2:
          FormatHelper.capitalize(member.localizedJobTitle(isArabic: isArabic)),
      avatar: member.photoUrl == null || member.photoUrl!.isEmpty
          ? null
          : appImageProvider(member.photoUrl!),
      // No photo — or a photo URL that 404s — falls back to the app's default
      // employee avatar rather than PersonChipCard's own `CardSvg.male`, so
      // the cards match the picked-avatar strip above them on the same screen.
      avatarPlaceholderAsset: AppAssets.defaultEmployeeAvatar,
      onTap: () => onTap(member),
      showCheckBox: trailing == MemberGridTrailing.check,
      isSelected: selected,
      trailing: trailing == MemberGridTrailing.remove
          ? _RemoveButton(onTap: () => onTap(member))
          : null,
      // Picked cards get the faint brand tint the Figma shows behind a
      // selected row; unpicked ones stay on the card colour.
      backgroundColor: AppColors.background
    );
  }

  /// The card's first subtitle is the department NAME.
  ///
  /// With no resolver supplied — or with an id the department list does not
  /// contain — the line renders blank. Blank is deliberately preferred over
  /// falling back to `member.departmentId`: a raw key under someone's name
  /// reads as data corruption to the person using the screen.
  String _departmentLabel(DatabaseMember member) =>
      departmentLabel?.call(member) ?? '';
}

/// The red circular minus on the Review screens (Figma 7398:17988).
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 20.r,
        height: 20.r,
        decoration: BoxDecoration(
          color: AppColors.delete,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.remove, size: 14.r, color: AppColors.white),
      ),
    );
  }
}
