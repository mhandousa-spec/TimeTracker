/// ************************* FILE INFO ********************************
/// File Name: home_grid_item_view.dart
/// Purpose: This file contains the HomeGridItemView widget, which is used to display a grid item in the home screen of the form builder module.
/// Author: Mohamed Mohy
/// Modified: Mohamed Elrashidy
/// Last Modification Data: 10/1/2026
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/menu.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/ui/widgets/menu_button.dart';

/// ── Figma spec: MESBAH / node 7444-37279 (a home grid card) ─────────────────
///
/// The card is 282 × 80 with 10 padding all round, so the content box is
/// 262 × 60. Inside it:
///
///   thumbnail          x 10,  y 10, 60 × 60   → exactly fills the content height
///   text column        x 75                   → 5 clear of the thumbnail
///   title              y 15
///   "Used by:"         y 31
///   "Access:"          y 46
///   "Published Date:"  y 61
///   ⋯ menu             x 254, y 10, 18 × 4    → 10 in from the right edge
///
/// FIXED 19/8/2026: the thumbnail was 80 on tablet — 20 taller than the whole
/// 60 content box — which pushed the card past its 80 height. That is why the
/// card rows in the bug report do not line up with the design.
const double _kThumbSize = 60;

/// Bug report #11: the cover is as tall as the card's content box (100.sp
/// card − 2 × 10.sp padding), and square.
const double _kThumbFill = 80;

/// The placeholder document glyph inside the thumbnail — Figma node
/// 7444-37289 ("g4024"), 30 × 38, centred in the 60 × 60 tile.
///
/// This replaces a `Transform.scale(scale: isTablett ? 1.5 : 1)`, which sized
/// the glyph off the SVG's own intrinsic box rather than off the design, and
/// would have overflowed the tile now that it is 60 rather than 80.
const double _kThumbGlyphWidth = 30;
const double _kThumbGlyphHeight = 38;

/// Side of the square box the ⋯ menu glyph is drawn in. Figma's dots span
/// 18 × 4 (node 7444-37332); 20 keeps a little breathing room around them and
/// matches the size `MenuDropdown` uses for its own default icon.
const double _kMoreIconSize = 20;

class HomeGridItemView extends StatelessWidget {
  const HomeGridItemView({
    required this.model,
    required this.index,
    this.gridAnimationController,
    this.slideAnimations,
    super.key,
  });

  final FormEntity model;
  final int index;
  final AnimationController? gridAnimationController;
  final List<Animation<Offset>>? slideAnimations;

  @override
  Widget build(BuildContext context) {

    final widget = _getGridViewWidget(model: model, context: context);

    // ✅ Apply animations if available
    if (slideAnimations != null &&
        index < slideAnimations!.length &&
        gridAnimationController != null) {

      return SlideTransition(
        position: slideAnimations![index],
        child: FadeTransition(
          opacity: gridAnimationController!,
          child: widget,
        ),
      );
    }

    return widget;
  }

  Widget _getGridViewWidget({
    required FormEntity model,
    required BuildContext context,
  }) {
    final cubit = context.read<HomeCubit>();

    if (cubit.tabController.index == 2 || cubit.tabController.index == 3) {
      return _getGridViewRequestedItem(model: model, context: context);
    }
    return _getGridViewPublishItem(model: model, context: context);
  }

  // ... rest of the code remains the same
  Widget _getGridViewRequestedItem({
    required FormEntity model,
    required BuildContext context,
  }) {
    final cubit = context.read<HomeCubit>();
    bool isPhone = MediaQuery.of(context).size.shortestSide < 600;

    return GestureDetector(
      onTap: () {
        cubit.onGridViewItemClicked(model, context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          child: Row(
            // Bug report #11: the cover fills the card's full content height
            // (all the text rows), square.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                                width: _kThumbFill.sp,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: model.formHeadModel.cover != null && model.formHeadModel.cover!.isNotEmpty
                    ? ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: Image.network(
                    model.formHeadModel.cover!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: SvgPicture.asset(
                          AppAssets.defaultIcon,
                          width: _kThumbGlyphWidth.w,
                          height: _kThumbGlyphHeight.h,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(AppColors.icon, BlendMode.srcIn),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                )
                    : Center(
                  child: SvgPicture.asset(
                    AppAssets.defaultIcon,
                    width: _kThumbGlyphWidth.w,
                    height: _kThumbGlyphHeight.h,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(AppColors.icon, BlendMode.srcIn),
                  ),
                ),
              ),
              horizontalSpace(isPhone ? 8 : 5),
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(end: 5, top: 5),
                  // FIXED 1/9/2026 — this Column overflowed by ~10px on the
                  // Submissions tab (index 3), where a fourth row (Submission
                  // Date) joins the other three inside the fixed 100.sp card.
                  // The two `SizedBox(height: 10.sp)` gaps plus `Spacer` were
                  // 20px of gap the card could not spare once that row
                  // appeared. `spaceBetween` distributes whatever is left
                  // instead of demanding a fixed amount — the same thing
                  // `_getGridViewPublishItem`'s column already does, which is
                  // why the publish card never overflowed.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getTitleForItem(model.formHeadModel, context),
                              style: StyleText.fontSize14Weight400.copyWith(color: AppColors.fullBlack),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      FittedBox(
                        child: Row(
                          children: [
                            Text(
                              '${S.of(context).requestedBy}: ',
                              style: StyleText.fontSize11Weight400.copyWith(color: AppColors.spanText),
                            ),
                            Text(
                              ' ${model.requestedBy}',
                              style: StyleText.fontSize11Weight400.copyWith(color: AppColors.fullBlack),
                            ),
                          ],
                        ),
                      ),
                      if (cubit.tabController.index == 3)
                        Row(
                          children: [
                            Text(
                              '${S.of(context).submissionDate}: ',
                              style: StyleText.fontSize10Weight400.copyWith(color: AppColors.spanText),
                            ),
                            Text(
                              ' ${FormDateTimeHelper.formatDate(model.submissionDate!)}',
                              style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack),
                            ),
                          ],
                        ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${S.of(context).receivedDate}: ',
                              style: StyleText.fontSize10Weight400.copyWith(color: AppColors.spanText),
                            ),
                            Text(
                              ' ${FormDateTimeHelper.formatDate(model.createDate)}',
                              style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getGridViewPublishItem({
    required FormEntity model,
    required BuildContext context,
  }) {
    final cubit = context.read<HomeCubit>();
    bool isPhone = MediaQuery.of(context).size.shortestSide < 600;

    return GestureDetector(
      onTap: () {
        cubit.onGridViewItemClicked(model, context);
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.sp, horizontal: 10.sp),
              child: Row(
            // Bug report #11: the cover fills the card's full content height
            // (all the text rows), square.
            crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                                        width: _kThumbFill.sp,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    child: model.formHeadModel.cover != null && model.formHeadModel.cover!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      child: Image.network(
                        model.formHeadModel.cover!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: SvgPicture.asset(
                              "assets/icons_assets/form_builder_assets/create_form.svg",
                              width: _kThumbGlyphWidth.w,
                              height: _kThumbGlyphHeight.h,
                              fit: BoxFit.contain,
                              colorFilter: ColorFilter.mode(AppColors.icon, BlendMode.srcIn),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                        : Center(
                      child: SvgPicture.asset(
                        "assets/icons_assets/form_builder_assets/create_form.svg",

                        width: _kThumbGlyphWidth.w,
                        height: _kThumbGlyphHeight.h,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(AppColors.icon, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  horizontalSpace(isPhone ? 8 : 5),
                  Expanded(
                    child: Padding(
                        padding:  EdgeInsets.symmetric(vertical: 6.sp),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getTitleForItem(model.formHeadModel, context),
                                  style: StyleText.fontSize14Weight400.copyWith(color: AppColors.fullBlack),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "${'Used By:'} ",
                                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.spanText)
                                      .copyWith(fontSize: 11.sp),
                                ),
                                Text(
                                  model.numberUsed == 0
                                      ? '-'
                                      : FormDateTimeHelper.formatInt(model.numberUsed),
                                  style: StyleText.fontSize12Weight400.copyWith(color: AppColors.fullBlack)
                                      .copyWith(fontSize: 11.sp),
                                )
                              ],
                            ),
                            _buildRowPrivacyAndDate(isPhone, model, context),
                          ],
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ),
          // The Deleted tab gets a menu too, holding only Restore — see
          // _menuItemsForTab. Publish (0) and Deleted (4) are the two tabs this
          // card is built for that have any card action at all; Draft (1) has
          // none, so _menuItemsForTab returns empty and nothing is placed.
          if (_menuItemsForTab(cubit.tabController.index).isNotEmpty)
            Positioned(
              top: 10.sp,
              right: 10.sp,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MenuDropdown(
                    customIcon: _buildMoreIcon(),
                    currentEnumValue: null,
                    items: _menuItemsForTab(cubit.tabController.index),
                    onChanged: (value) {
                      cubit.onMenuSelect(
                        value,
                        formModel: model,
                        context: context,
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRowPrivacyAndDate(
      bool isPhone,
      FormEntity model,
      BuildContext context,
      ) {
    final cubit = context.read<HomeCubit>();
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (isPhone) {
      return Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${'Access'}:',
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.spanText)
                    .copyWith(fontSize: 11.sp),
              ),
              Text(
                (cubit.selectedTab.index == 1)
                    ? ': -     '
                    : ' ${model.formHeadModel.accessManagement}',
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.fullBlack)
                    .copyWith(fontSize: 11.sp),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (cubit.selectedTab.index == 4)
                    ? 'Deleted'
                    : 'Publish',
                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.spanText),
              ),
              Text(
                (cubit.selectedTab.index == 1)
                    ? ': -     '
                    : (cubit.selectedTab.index != 4)
                    ? ' ${FormDateTimeHelper.formatDate(model.createDate).trim()}'
                    : ' ${FormDateTimeHelper.formatDate(model.deleteDate!).trim()}',
                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Text(
              '${isPortrait ? S.of(context).access : S.of(context).accessManagement}: ',
              style: StyleText.fontSize11Weight400.copyWith(color: AppColors.spanText),
            ),
            Text(
              // FIXED 19/8/2026 — `accessManagement` is the raw value stored on
              // the form ('Open Access'), so the card printed English on the
              // Arabic card. `labelFor` maps it to the localized label without
              // touching what is persisted.
              (cubit.selectedTab.index == 1)
                  ? ': -     '
                  : ' ${AccessManagementExtension.labelFor(model.formHeadModel.accessManagement)}',
              style: StyleText.fontSize11Weight400.copyWith(color: AppColors.fullBlack),
            ),
          ],
        ),
        SizedBox(height: 4.sp),
        // Bug report #11: the published date was missing from the tablet
        // card (only the phone layout had it). Deleted forms show their
        // delete date; drafts have none.
        if (cubit.selectedTab.index != 1)
          Row(
            children: [
              Text(
                cubit.selectedTab.index == 4
                    ? (context.isArabic ? 'تاريخ الحذف: ' : 'Deleted Date: ')
                    : '${S.of(context).published_date}: ',
                style: StyleText.fontSize11Weight400
                    .copyWith(color: AppColors.spanText),
              ),
              Text(
                cubit.selectedTab.index == 4 && model.deleteDate != null
                    ? FormDateTimeHelper.formatDate(model.deleteDate!).trim()
                    : FormDateTimeHelper.formatDate(model.createDate).trim(),
                style: StyleText.fontSize11Weight400
                    .copyWith(color: AppColors.fullBlack),
              ),
            ],
          ),
      ],
    );
  }

  /// Which card-menu entries a given home tab offers.
  ///
  /// ADDED 19/8/2026 together with `MenuEnum.restore`. The menu used to be
  /// `items: MenuEnum.values` behind `if (tabController.index == 0)` — every
  /// action on the Publish tab, no menu anywhere else. That has two problems
  /// once Restore exists: a deleted form has no way to be restored from the
  /// grid, and `values` would have silently added "Restore" to the Publish
  /// card's menu.
  ///
  /// Listing the entries per tab fixes both and makes the next addition a
  /// decision rather than an accident.
  ///
  /// Tab indices follow `HomeCubit.onTabChange`: 0 Publish, 1 Draft,
  /// 2 Requested, 3 Submissions, 4 Deleted. 2 and 3 never reach here — they
  /// render `_getGridViewRequestedItem`, which has no menu.
  List<MenuEnum> _menuItemsForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const [
          MenuEnum.duplicate,
          MenuEnum.edit,
          MenuEnum.convertToPDF,
          MenuEnum.delete,
        ];
      case 4:
        return const [MenuEnum.restore];
      default:
        return const [];
    }
  }

  /// The horizontal ⋯ that opens the card's menu.
  ///
  /// CHANGED 19/8/2026. `MenuDropdown` falls back to `AppAssets.menu` when no
  /// `customIcon` is given, and that asset is `menu_lines_bold.svg` — a
  /// hamburger, not three dots. Figma (node 7444-37332) shows an 18 × 4
  /// horizontal ⋯ in the card's top-right corner, so the card passes its own
  /// icon rather than changing `AppAssets.menu`, which other screens use as an
  /// actual hamburger.
  ///
  /// `vectors_more.svg` draws the dots VERTICALLY, so it is turned a quarter
  /// turn. `RotatedBox` rather than `Transform.rotate`: it rotates during
  /// layout, so the tap target rotates with the artwork instead of staying
  /// axis-aligned behind a visually rotated child. The 24 × 24 viewBox is
  /// square, so the turn neither clips the glyph nor changes its footprint.
  Widget _buildMoreIcon() {
    return RotatedBox(
      quarterTurns: 1,
      child: SvgPicture.asset(
        AppAssets.more,
        width: _kMoreIconSize.sp,
        height: _kMoreIconSize.sp,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(AppColors.fullBlack, BlendMode.srcIn),
      ),
    );
  }

  String _getTitleForItem(FormHeadData formHeadModel, BuildContext context) {
    if (context.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }

    return formHeadModel.title;
  }
}