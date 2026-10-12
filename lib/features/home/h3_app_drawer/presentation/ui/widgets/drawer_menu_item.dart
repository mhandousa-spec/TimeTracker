/// Module: home/h3_app_drawer
///
///*************************** FILE INFO ****************************///
/// File Name: drawer_menu_item.dart
/// Purpose: A single icon + label entry in the app drawer rail.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Extracted from the 586-line `custom_drawer.dart`. Reordering state is read
/// from [AppDrawerCubit] rather than the module-global `RxBool` this used to
/// depend on.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';

class DrawerMenuItem extends StatelessWidget {
  const DrawerMenuItem({
    super.key,
    required this.cubit,
    required this.compact,
    required this.index,
    required this.iconPath,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  /// Drawer cubit, passed explicitly because it is registered through GetX
  /// rather than provided in the widget tree.
  final AppDrawerCubit cubit;

  /// `true` for the narrow rail (icon only), `false` for icon + label.
  final bool compact;

  final int index;
  final String iconPath;
  final String title;

  /// Invoked with [index] when the item is tapped and reordering is off.
  final ValueChanged<int> onTap;

  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppDrawerCubit, AppDrawerState>(
      bloc: cubit,
      builder: (BuildContext context, AppDrawerState state) {
        final bool isReorderingActive = cubit.isReorderingActive;

        // SELECTION 24/8/2026: no selected highlight while reordering.
        //
        // Reorder mode already marks every item with its own outline, and the
        // filled yellow block on top of that read as "this row is the one being
        // dragged" — which it is not, it is just the page you came from. It
        // also fought the drag proxy's elevation.
        //
        // Computed inside the builder now: it used to be read before
        // `isReorderingActive` was known, one line above this BlocBuilder.
        final bool isSelected =
            cubit.selectedIndex == index && !isLogout && !isReorderingActive;

        // While reordering is active the item must not be tappable. This passes
        // `null` rather than relying solely on the guard inside the page's
        // handler: an onTap callback installs a tap recogniser that competes
        // with the reorder list's long-press drag, so removing it outright both
        // blocks navigation and makes dragging start cleanly. The cursor drops
        // back to the default arrow so the rail doesn't look clickable on
        // desktop.
        final bool tapDisabled = isReorderingActive;

        return MouseRegion(
          cursor: tapDisabled
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: tapDisabled ? null : () => onTap(index),
            child: Container(
              width: compact ? 40.w : 70.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isReorderingActive && !isLogout
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.5), width: 1)
                    : null,
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 5.w, vertical: compact ? 0 : 2.h),
              child: Container(
                decoration: isSelected
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: AppColors.secondaryPrimary,
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: SvgPicture.asset(
                        iconPath,
                        width: 26.w,
                        fit: BoxFit.fill,
                        height: 26.h,
                        color: isSelected
                            ? AppColors.secondaryPrimaryText
                            : AppColors.secondaryText,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 8.h, bottom: compact ? 1.h : 5.h),
                      child: compact
                          ? const SizedBox.shrink()
                          : FittedBox(
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: StyleText.fontSize10Weight500.copyWith(color: Color(0xff797979))
                                    .copyWith(
                                  color: isSelected
                                      ? AppColors.secondaryPrimaryText
                                      : AppColors.secondaryText,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
