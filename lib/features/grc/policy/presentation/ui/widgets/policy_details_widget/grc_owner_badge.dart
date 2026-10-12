/// Module: GRC Module Management
/// Description: Compact "Module Owner" badge that shows ONLY the first
///              assigned owner (avatar + name) alongside a "Message"
///              action button. Use this next to GrcOwnerSection when a
///              single-line summary is needed instead of the full grid.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: GrcOwnerCubit
/// Revision History: 2026-07-18 - Initial creation
library;

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_messaging.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_owner_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [GrcOwnerBadge]
///
/// purpose: shows only the first owner assigned to a GRC Module as a
///          small badge: "Module Owner:" label + avatar + name, plus a
///          "Message" pill button. This is a separate widget from
///          [GrcOwnerSection] (which is left untouched) and is meant for
///          compact places (module header / list row) where the full
///          owner grid is not needed.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class GrcOwnerBadge extends StatefulWidget {
  /// Emails of owners already assigned to the module (or Control — see
  /// [label]). Only the first matched owner is displayed.
  final List<String> ownerEmails;

  /// Leading label text, e.g. "Module Owner:" or "Control Owner:".
  final String label;

  /// Called with the displayed owner when the "Message" button is tapped.
  final void Function(OwnerData owner)? onMessageTap;

  const GrcOwnerBadge({
    super.key,
    this.ownerEmails = const [],
    this.label = 'Module Owner:',
    this.onMessageTap,
  });

  @override
  State<GrcOwnerBadge> createState() => _GrcOwnerBadgeState();
}

class _GrcOwnerBadgeState extends State<GrcOwnerBadge> {
  late final GrcOwnerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = GrcOwnerCubit();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cubit.loadOwners(
        context,
        initialOwnerEmails: widget.ownerEmails,
      ),
    );
  }

  /// Re-resolves owners whenever [widget.ownerEmails] changes after the
  /// first build. Needed because Flutter reuses this State across rebuilds
  /// (no key), so a caller whose email list starts empty and arrives later
  /// (e.g. built inside a BlocBuilder before its cubit has loaded) would
  /// otherwise be stuck showing nothing forever, since `initState` only
  /// runs once.
  @override
  void didUpdateWidget(covariant GrcOwnerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameEmails(oldWidget.ownerEmails, widget.ownerEmails)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _cubit.loadOwners(
          context,
          initialOwnerEmails: widget.ownerEmails,
        ),
      );
    }
  }

  bool _sameEmails(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<GrcOwnerCubit, GrcOwnerState>(
        builder: (context, state) {
          // Only the selected/assigned owners matter here, we just take
          // the first one.
          final owners =
              _cubit.filteredOwners.where((o) => o.isSelected).toList();

          if (owners.isEmpty) return const SizedBox.shrink();

          final owner = owners.first;

          // Phone: when the parent gives a bounded width, the row fills it
          // and the icon-only Message button sits on the trailing edge, so
          // the name gets all the space in between instead of being cut off
          // next to the button. Tablet / desktop keep the compact row.
          return LayoutBuilder(
            builder: (context, constraints) {
          final bool spread = constraints.hasBoundedWidth &&
              screenSizeOf(context) == ScreenSize.mobile;
          return Row(
            mainAxisSize: spread ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Flexible(
                // Spread: the short label keeps its width and the name
                // takes the rest (a second flex child would only get half).
                flex: spread ? 0 : 1,
                child: Text(grcTr(context, widget.label),
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _ownerAvatar(owner),
              SizedBox(width: 8.w),
              Flexible(
                fit: spread ? FlexFit.tight : FlexFit.loose,
                child: Text(
                  // Capitalized (GRC bug report p25/p28/p34 — "demo company").
                  FormatHelper.capitalize(owner.name),
                  overflow: TextOverflow.ellipsis,
                  style: StyleText.fontSize14Weight400.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: spread ? 8.w : 16.w),
              _MessageButton(
                // A caller-supplied handler wins; otherwise open the chat
                // with this owner (the callers used to pass a no-op).
                onTap: () => widget.onMessageTap != null
                    ? widget.onMessageTap!(owner)
                    : openGrcChat(context, owner.email),
              ),
            ],
          );
            },
          );
        },
      ),
    );
  }
}

/// The owner avatar: the employee's own photo when there is one, and the
/// app's default SVG silhouette (assets_male.svg, via
/// [AppAssets.defaultEmployeeAvatar]) otherwise.
///
/// THE BUG THIS REPLACES: the avatar was `Image.network(owner.photo)` inside
/// CircleAvatar's `child`. `owner.photo` comes from
/// `EmployeeHelper.getEmployeeImage`, which returns an ASSET path (and the
/// default is an `.svg`) as often as it returns a URL -- so every
/// asset-backed owner fell straight through to the `errorBuilder`'s grey
/// `Icons.person`. As a `child` it was not clipped to the circle either.
///
/// `foregroundImage` over an SVG child, NOT `backgroundImage` -- the same
/// arrangement GrcPreviousModuleOwnersPage, ControlPreviousOwnersPage and
/// PersonChipCard use. A foreground image draws OVER the child, so the
/// silhouette shows while a photo loads and stays put if the URL 404s, and
/// [appImageProvider] picks NetworkImage / SvgImageProvider / AssetImage by
/// the path itself.
Widget _ownerAvatar(OwnerData owner) {
  final String photo = owner.photo;
  final bool hasPhoto =
      photo.isNotEmpty && photo != AppAssets.defaultEmployeeAvatar;

  return CircleAvatar(
    radius: 14.r,
    backgroundColor: AppColors.moreLightGrey,
    foregroundImage: hasPhoto ? appImageProvider(photo) : null,
    child: ClipOval(
      child: CustomSvgImage(
        assetPath: AppAssets.defaultEmployeeAvatar,
        width: 28.r,
        height: 28.r,
        fit: BoxFit.cover,
      ),
    ),
  );
}

/// class name: [_MessageButton]
///
/// purpose: pill-shaped yellow button with a chat-bubble icon + "Message"
///          label, matching the action button shown next to the owner
///          badge in the design.
class _MessageButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MessageButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    // Same shape as the Edit button: icon-only 38.w square on mobile,
    // 135.w with the label on tablet / desktop.
    final bool isCompact = screenSizeOf(context) == ScreenSize.mobile;
    final double buttonWidth = isCompact ? 38.w : 135.w;
    return customButtonWithSvg(
      colorBorder: AppColors.primary,
      space: 10.w,
      radius: 8.r,
      widthImage: 16.w,
      heightImage: 16.h,
      image: "assets/icons_assets/roles_assets/chat_messages_bubbles.svg",
      title: isCompact ? "" : S.of(context).msg,
      function: onTap ?? () {},
      width: buttonWidth,
      fixedWidth: buttonWidth,
      color: AppColors.primary,
      svgColor: AppColors.textButton,
      textStyle:
          StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
    );
  }
}
