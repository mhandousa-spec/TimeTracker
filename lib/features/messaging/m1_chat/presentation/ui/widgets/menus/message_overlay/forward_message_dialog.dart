/// Module: messaging / chat / presentation/ui/widgets/menus/message_overlay/forward_message_dialog.dart
/// ************************* FILE INFO *************************** ///
/// File Name: forward_message_dialog.dart
/// Purpose: Pick people to forward a message to — messaging Chat sub-feature.
/// Author: Knowticed Team
/// Created At: 2/9/2026
///
/// Opened from the long-press menu's "Forward" item. Shows the messaging
/// CONNECTIONS (`ConnectionsCubit.connections`), not the form-builder person
/// list `f7_share/share_screen.dart` uses: forwarding has to end in
/// `BaseChatRepository.sendNewMessage`, which takes a `ChatTypeEntity` as the
/// other side, and a `SingleConnectionEntity` already is one. Going through
/// `PersonEntity` would mean importing form_builder_module into messaging AND
/// creating a connection before anything could be sent.
///
/// Deliberately dumb: it owns only the search text and the tick marks, and
/// hands the chosen connections back through [onSend]. The actual send lives on
/// MasterChatCubit.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/domain/entities/single_connection_entity.dart';
import 'package:knowticed_plus/generated/l10n.dart';


class ForwardMessageDialog extends StatefulWidget {
  const ForwardMessageDialog({
    super.key,
    required this.connections,
    required this.onSend,
  });

  final List<SingleConnectionEntity> connections;

  /// Called with the ticked connections once the user confirms. The dialog has
  /// already closed by then, so this is free to be slow.
  final Future<void> Function(List<SingleConnectionEntity> targets) onSend;

  /// Convenience opener — same dialog chrome as every other dialog in the app.
  static Future<void> show({
    required BuildContext context,
    required List<SingleConnectionEntity> connections,
    required Future<void> Function(List<SingleConnectionEntity> targets) onSend,
  }) {
    return CustomDialogManager.showContent<void>(
      context: context,
      width: 420.sp,
      child: ForwardMessageDialog(
        connections: connections,
        onSend: onSend,
      ),
    );
  }

  @override
  State<ForwardMessageDialog> createState() => _ForwardMessageDialogState();
}

class _ForwardMessageDialogState extends State<ForwardMessageDialog> {
  final TextEditingController _searchController = TextEditingController();

  /// Ticked people, by `userId` — an id set rather than a list of entities, so
  /// filtering the list cannot silently drop a selection the user already made.
  final Set<String> _selectedIds = <String>{};

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SingleConnectionEntity> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.connections;
    return widget.connections
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            (c.primaryLanguageSubInfo ?? '').toLowerCase().contains(q))
        .toList();
  }

  void _toggle(SingleConnectionEntity connection) {
    setState(() {
      if (!_selectedIds.remove(connection.userId)) {
        _selectedIds.add(connection.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final bool hasSelection = _selectedIds.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 30.sp,
              height: 30.sp,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomSvgImage(
                  // The forward glyph, per the design. Raw path rather than
                  // an AppAssets constant because neither AppAssets class
                  // declares it yet.
                  assetPath: 'assets/icons_assets/main_icons_assets/arrow_back_curved.svg',
                  width: 16.sp,
                  height: 16.sp,
                  color: AppColors.textButton,
                ),
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: Text(
                S.of(context).forwardMessage,
                style: StyleText.fontSize20Weight500,
              ),
            ),
          ],
        ),

        verticalSpace(16),

        // ── Search ────────────────────────────────────────────────────
        // expanded: false — AppSearchTextField wraps itself in an Expanded by
        // default and this parent is a Column, not a Row.
        AppSearchTextField(
          controller: _searchController,
          expanded: false,
          hintText: S.of(context).search,
          // AppColors.background, matching the person cards below — the
          // dialog's own surface is already AppColors.field, so a field-
          // coloured search box disappeared into it.
          fillColor: AppColors.background,
          onChanged: (value) => setState(() => _query = value),
        ),

        verticalSpace(12),

        // ── Count ─────────────────────────────────────────────────────
        Text(
          hasSelection
              ? '${S.of(context).selected}: ${LocalizedNumber.of(context, _selectedIds.length)}'
              : S.of(context).employees,
          style: StyleText.fontSize12Weight500
              .copyWith(color: AppColors.secondaryText),
        ),

        verticalSpace(8),

        // ── People ────────────────────────────────────────────────────
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 320.h),
          child: visible.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Center(
                    child: Text(
                      S.of(context).noResults,
                      style: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final connection = visible[index];
                    return _ConnectionPickCard(
                      connection: connection,
                      isSelected: _selectedIds.contains(connection.userId),
                      onTap: () => _toggle(connection),
                    );
                  },
                ),
        ),

        verticalSpace(20),

        // ── Actions ───────────────────────────────────────────────────
        Row(
          children: [
            customButton(
              title: S.of(context).Cancel,
              function: () =>
                  Navigator.of(context, rootNavigator: true).maybePop(),
              color: AppColors.darkGrey,
              textStyle: StyleText.fontSize15Weight400
                  .copyWith(color: AppColors.white),
            ),
            const Spacer(),
            customButton(
              title: S.of(context).send,
              // Disabled look via colour, and the callback is a no-op with an
              // empty selection — customButton has no `enabled` flag.
              color: hasSelection
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.4),
              textStyle: StyleText.fontSize15Weight400
                  .copyWith(color: AppColors.textButton),
              function: () {
                if (!hasSelection) return;
                final targets = widget.connections
                    .where((c) => _selectedIds.contains(c.userId))
                    .toList();
                // Close first: the send is awaited by the caller and can take
                // a moment per recipient.
                Navigator.of(context, rootNavigator: true).maybePop();
                widget.onSend(targets);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ConnectionPickCard — one tickable person row.
//
// Same shape as FormPersonStateView in the form-builder share screen (avatar,
// name, sub-line, CustomCheckBox), rebuilt here against SingleConnectionEntity
// so messaging does not import form_builder_module.
// ─────────────────────────────────────────────────────────────────────────────

class _ConnectionPickCard extends StatelessWidget {
  const _ConnectionPickCard({
    required this.connection,
    required this.isSelected,
    required this.onTap,
  });

  final SingleConnectionEntity connection;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String image = connection.imageUri;
    final bool isNetwork = image.startsWith('http');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsetsDirectional.all(10.sp),
        decoration: BoxDecoration(
          // AppColors.background — every card in this app sits on background,
          // and AppColors.card was too close to the dialog surface behind it.
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.sp)
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.sp,
              // Not AppColors.background — that is now the CARD colour, so the
              // avatar circle would vanish into it for anyone without a photo.
              backgroundColor: AppColors.field,
              backgroundImage: isNetwork ? NetworkImage(image) : null,
              child: isNetwork
                  ? null
                  : CustomSvgImage(
                      assetPath:
                          'assets/icons_assets/main_icons_assets/assets_male.svg',
                      width: 24.sp,
                      height: 24.sp,
                    ),
            ),
            horizontalSpace(10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // `name` already picks the Arabic name in Arabic mode
                    // (LocalizedTextHelper, on the entity).
                    connection.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: StyleText.fontSize14Weight500,
                  ),
                  if ((connection.primaryLanguageSubInfo ?? '').isNotEmpty)
                    Text(
                      connection.subInfo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StyleText.fontSize12Weight500
                          .copyWith(color: AppColors.spanText),
                    ),
                ],
              ),
            ),
            horizontalSpace(8),
            CustomCheckBox(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}
