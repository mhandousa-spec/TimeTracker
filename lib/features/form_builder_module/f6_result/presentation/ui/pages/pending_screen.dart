import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/search_bar_pending_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/department.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
class PendingScreen extends StatefulWidget {
  const PendingScreen({super.key});

  @override
  State<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends State<PendingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gridAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Start animation after a brief delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _gridAnimationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    super.dispose();
  }

  // Restart animation when filtered list changes
  void _restartAnimation() {
    _gridAnimationController.reset();
    _gridAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResultCubit, ResultState>(
      listener: (context, state) {
        // Restart animation when filtered list changes
        if (state is ResultLoaded) {
          _restartAnimation();
        }
      },
      builder: (context, state) {
        if (state is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<ResultCubit>();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SearchBarPendingWidget(),
            verticalSpace(15),
            Row(
              children: [
                const Spacer(),
                customButtonWithSvg(
                  title: 'Remind All',
                  image: AppAssets.ring,
                  function: () async {
                    final sent = await cubit.remindAllClicked();
                    if (sent > 0 && context.mounted) _showReminderSent(context);
                  },
                  textStyle: StyleText.fontSize14Weight500
                      .copyWith(color: AppColors.textButton),
                  color: AppColors.primary,
                  colorBorder: AppColors.primary,
                  svgColor: AppColors.textButton,
                  widthImage: 16,
                  heightImage: 16,
                  // form bug report #20: same width as the Department
                  // dropdown in SearchBarPendingWidget (150.sp).
                  width: 150.sp,
                  fixedWidth: 150.sp,
                ),
              ],
            ),
            verticalSpace(15),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                mainAxisSpacing: 15.w,
                crossAxisSpacing: 15.h,
                // FIXED: was 110.h, which is where the "RenderFlex overflowed
                // by 7.8 pixels" came from. The tile's own content — 8+8
                // padding, the name/job/department column (three lines and two
                // 7.h gaps, ~76 tall, taller than the 60.r avatar beside it),
                // and the 24.h reminder row — needs ~118, so a fixed 110 was
                // always ~8 short. 132 clears it with room left for Arabic,
                // whose line boxes run taller than the Latin ones this was
                // presumably eyeballed against.
                //
                // The `Spacer()` in the tile absorbs the extra height, so the
                // reminder row stays pinned to the bottom of the card.
                mainAxisExtent: 132.h,
              ),
              itemCount: state.filteredPendingUsers.length,
              itemBuilder: (context, index) {
                var width = MediaQuery.of(context).size.width;
                var isPhone = width <= 600;
                return _buildAnimatedGridItem(
                  index: index,
                  child: _getGridViewItem(
                    context: context,
                    isPhone: isPhone,
                    model: state.filteredPendingUsers[index],
                    cubit: cubit,
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }

  /// Builds an animated grid item with slide-in animation
  Widget _buildAnimatedGridItem({
    required int index,
    required Widget child,
  }) {
    // Stagger the animation based on index
    final delay = index * 0.05; // 50ms delay between items

    final slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Slide from left
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _gridAnimationController,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ),
    );

    final opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _gridAnimationController,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeIn,
        ),
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: child,
      ),
    );
  }

  /// Form bug report #20: lottie confirmation after a reminder goes out.
  void _showReminderSent(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
      title: Get.locale?.languageCode == 'ar'
          ? 'تم إرسال التذكير بنجاح'
          : 'Reminder Sent Successfully',
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 3600) return 5;
    if (screenWidth > 2400) return 4;
    if (screenWidth <= 2400 && screenWidth > 1200) return 3;
    if (screenWidth > 600 && screenWidth < 1200) return 2;
    return 1;
  }

  Widget _getGridViewItem({
    required bool isPhone,
    required BuildContext context,
    required UserGridItem model,
    required ResultCubit cubit,
  }) {
    return MouseRegion(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // CHANGED: the yellow ring was `CircleAvatar`'s own
                  // background showing through. The avatar was 60.r across
                  // (radius 30.r) but its child was only 30 wide, so half the
                  // circle was never covered and the theme's default avatar
                  // fill — the app's primary yellow — was what you saw around
                  // the glyph. A `ClipRRect(16.r)` inside a circle did not help
                  // either: it rounded the corners of an image that was already
                  // smaller than the hole it sat in.
                  //
                  // No CircleAvatar at all now, so there is no background left
                  // to show. `ClipOval` makes the circle and the image fills it.
                  //
                  // Both axes use `.r`: the old code mixed `30.w` and `30.h`,
                  // which are different scale factors, so the "circle" was
                  // quietly an ellipse on any window whose aspect ratio was not
                  // the design's.
                  ClipOval(
                    child: CustomSvgImage(
                      assetPath:
                          "assets/icons_assets/main_icons_assets/male_avatar.svg",
                      width: 60.r,
                      height: 60.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                  horizontalSpace(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                FormatHelper.capitalize(model.person.name),
                                style: StyleText.fontSize16Weight500.copyWith(color: AppColors.fullBlack),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7.h),
                        Row(
                          children: [
                            Text(
                              'Job Title:',
                              style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                            ),
                            Expanded(
                              child: Text(
                                ' ${FormatHelper.capitalize(model.person.title)}',
                                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 7.h),
                        Row(
                          children: [
                            Text(
                              '${'Department'}: ',
                              style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                            ),
                            Expanded(
                              child: Text(
                                ' ${FormatHelper.capitalize(model.person.departmentName)}',
                                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Reminders Sent:',
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                        ),
                        TextSpan(
                          text: ' ${FormDateTimeHelper.formatInt(model.reminderCounter)}',
                          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  _getButton(model, cubit)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The per-card reminder control: the action while a reminder is allowed,
  /// the remaining-cooldown chip while it is not.
  ///
  /// CHANGED: both states were hand-rolled — a `GestureDetector` wrapping a
  /// `Container` for the action, a bare `Container` for the chip — and they did
  /// not even agree with each other: `24.h` against `24`, radius `4.r` against
  /// `6.r`. They are both `customButton` (core/custom/5) now, so they take
  /// their height and radius from ButtonSizing, they are the same size as each
  /// other, and the action gets the app's haptic feedback for free.
  ///
  /// WIDTH — `wrapContent: true`. customButton's default width is a fixed
  /// 135/170.sp, far wider than either of these short labels, and this button
  /// shares a Row with the "Reminders Sent" text inside a 110-wide card.
  /// `wrapContent` makes it hug its text with [contentHorizontalPadding], which
  /// is what the old `Padding(horizontal: 8)` did.
  ///
  /// HEIGHT — the `SizedBox` is load-bearing, not decoration. customButton
  /// hardcodes `height: 38.sp` and its own docs mark the `height` parameter
  /// "ignored: sizing is enforced by ButtonSizing", so passing 24 there does
  /// nothing. 38.sp is ~14 taller than these buttons were, which would have
  /// re-broken the card overflow that `mainAxisExtent` was just raised to fix.
  /// A tight outer constraint wins over a Container's preferred height, so the
  /// SizedBox pins it back to the 24.h it has always been.
  ///
  /// The real fix is to make customButton honour `height`, but its source
  /// carries an explicit note that wiring up its ignored sizing parameters
  /// "would resize call sites all over the app" and should be done deliberately
  /// with those screens in view — so that is left alone here.
  Widget _getButton(UserGridItem model, ResultCubit cubit) {
    final bool canRemind = cubit.isMoreThan24Hours(model.lastReminderTime);

    return SizedBox(
      height: 24.h,
      child: customButton(
        title: canRemind
            ? 'Send Reminder'
            : cubit.getRemainingTimeText(model.lastReminderTime!),
        // The cooldown chip stays non-interactive, exactly as before — it was a
        // bare Container with no gesture detector.
        function: canRemind
            ? () async {
                final ok = await cubit.remindClicked(model);
                if (ok && mounted) _showReminderSent(context);
              }
            : () {},
        // CHANGED: the chip was AppColors.grey. darkGrey is what this app
        // already uses for a neutral, non-primary button — the "No" in
        // CustomDialogManager.showDialogFlow — so the two now agree.
        color: canRemind ? AppColors.primary : AppColors.darkGrey,
        wrapContent: true,
        contentHorizontalPadding: 8,
        textStyle: StyleText.fontSize12Weight500.copyWith(
          // Per state, because the two backgrounds are nothing alike.
          // `AppColors.textButton` is the contrast colour for PRIMARY (it
          // resolves against AppColors.primary, not against whatever colour the
          // button is given), so on the grey chip it would be the wrong end of
          // the scale. The chip keeps the black it always had.
          color: canRemind ? AppColors.textButton : AppColors.black,
        ),
      ),
    );
  }
}