// Objectives: Implement responsive SearchFormPublishTablet with filter and sort options.
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/create_form_data_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/create_head_form_screen.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_state.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_sort_option.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';

class SearchFormPublishTablet extends StatefulWidget {
  const SearchFormPublishTablet({super.key});

  @override
  State<SearchFormPublishTablet> createState() =>
      _SearchFormPublishTabletState();
}

class _SearchFormPublishTabletState extends State<SearchFormPublishTablet> {
  // ── Figma spec: MESBAH / node 7444-37189, action row node 7444-37220 ──────
  // The row is 876 × 38 and lays out as
  //   search 481 | 15 | Filter 100 | 15 | Sort 100 | 15 | Create Form 150
  // (481 + 15 + 100 + 15 + 100 + 15 + 150 = 876). The search field is the
  // Expanded child, so only the three buttons and the three gaps are pinned.
  /// Filter and Sort share ONE number on purpose — the bug report asked for
  /// them to be equal, so the design values are not allowed to drift apart in
  /// two files. `kActionButtonWidth` is passed to both.
  static const double kActionButtonWidth = 100;
  static const double kCreateFormWidth = 150;
  static const double kButtonHeight = 38;
  static const double kGap = 15;

  // Icon boxes inside the buttons: Filter and Sort are both 23 × 23, Create
  // Form is 19 × 24, and each is followed by an 8 gap before its label.
  static const double kActionIconSize = 23;
  static const double kCreateIconWidth = 19;
  static const double kCreateIconHeight = 24;
  static const double kIconTextGap = 8;

  /// ONE predicate for the whole row.
  ///
  /// FIXED 19/8/2026 — this is the "make filter and sort button equal in size"
  /// item from the bug report. Filter tested `isTablett && isLandscape` while
  /// Sort tested its own `size.width >= 600 && isLandscape`, and the two
  /// disagree whenever the window is wide but short: at 800 × 500 the
  /// shortestSide (500) is under the tablet cut-off, so Filter collapsed to
  /// the 36-wide icon button while Sort's width-only test still saw 600+ and
  /// stayed 100 wide. Both buttons now read this single value, so they can
  /// only ever change together.
  bool isWideLayout(BuildContext context) =>
      ContextExtension(context).isTablett &&
      ContextExtension(context).isLandscape;

  @override
  Widget build(BuildContext context) {
    final bool isWide = isWideLayout(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();

        return Container(

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              AppSearchTextField(
                controller: cubit.searchController,
                onChanged: (value) {
                  cubit.onSearch(value);
                },
              ),

              SizedBox(width: kGap.w),
              // Bug report #24: no Filter on the Submissions tab.
              if (cubit.tabController.index != 3) ...[
              // Filter button — Figma 100 × 38, icon 23 × 23, 8 before label.
              isWide
                  ? customButtonWithSvg(
                space: kIconTextGap.sp,
                colorBorder: AppColors.transparent,
                title:'Filter',
                function: (){
                  AppDialogs.filterDialog(context);
                },
                color: AppColors.card,
                fixedWidth: kActionButtonWidth.w,
                height: kButtonHeight.h,
                textStyle: StyleText.fontSize16Weight500.copyWith(
                    color:AppColors.secondaryText,
                ),
                image: AppAssets.filter,
                radius: 8.r,
                svgColor: AppColors.secondaryText,
                widthImage: kActionIconSize,
                heightImage: kActionIconSize,
              )
                  : _buildIconWidget(
                asset: AppAssets.filter,
                text: 'Filter',
                onTap: () {
                  AppDialogs.filterDialog(context);
                },
                showText: false,
                context: context,
              ),

              SizedBox(width: kGap.w),
              ],

              // Sort dropdown menu — same box as Filter, from the SAME width
              // constant and the SAME `isWide` value, so the pair cannot
              // diverge again the way the bug report caught them doing.
              CustomSortButton<String>(
                // Bug report #11/#24: the Knowticed Admin sort button —
                // neutral until a pick, primary while one is active, tap the
                // active row again to clear it. The Submissions tab sorts by
                // Submission / Received date.
                value: cubit.activeSortOption,
                items: cubit.tabController.index == 3
                    ? FormSortOption.submissionValues
                    : FormSortOption.values,
                labelBuilder: FormSortOption.labelOf,
                showTitle: ContextExtension(context).isTablett,
                width: ContextExtension(context).isTablett
                    ? kActionButtonWidth.w
                    : kButtonHeight.h,
                height: kButtonHeight.h,
                onChanged: cubit.updateSortOption,
              ),

              SizedBox(width: kGap.w),

              // if(Get.find<MainCoreEmployeeController>().isHasPermission(
              //   module: Modules.formBuilder,
              //   section: FormPermissionsSections.formPermissions,
              //   permission: FormPermissions.createNewForm,
              // ) )
              // Create button

              // Create Form — Figma 150 × 38 (was 130, and the 130 was being
              // ignored anyway: customButtonWithSvg drops `width:` and used
              // the app-wide 135.sp). Icon is 19 × 24 with an 8 gap.
              customButtonWithSvg(
                fixedWidth: kCreateFormWidth.w,
                height: kButtonHeight.h,
                title:  S.of(context).createForm,
                function: (){
                  _navigateToCreateForm(context);
                },
                svgColor: AppColors.textButton,
                color: AppColors.primary,
                radius: 8.r,

                textStyle: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.textButton,
                ),
                image:  "assets/icons_assets/form_builder_assets/create_form.svg",
                widthImage: kCreateIconWidth,
                heightImage: kCreateIconHeight,
                colorBorder: AppColors.transparent,
                space: kIconTextGap.w,
              )

            ],
          ),
        );
      },
    );
  }

  void _navigateToCreateForm(BuildContext context) {
    // Initialize CreateFormHeadCubit if needed
    // Note: CreateFormHeadCubit should be provided via BlocProvider
    // in the widget tree where CreateForm screen is shown
    context.FormNavigateTo(
      ContextExtension(context).isPhone ? Routes.create : Routes.creatingFormTablet,
    );
  }

  Widget _buildSortOrderButton(BuildContext context, HomeCubit cubit) {
    return GestureDetector(
      onTap: () {
        cubit.toggleSortOrder();
      },
      child: Container(
        height: 36,
        width: 36.h,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Icon(
            cubit.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            color: AppColors.secondaryText,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildIconWidget({
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    required BuildContext context,
    bool isPrime = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.h,
        width: showText ? (isPrime ? 150.w : 100.w) : 36.h,
        decoration: BoxDecoration(
          color: isPrime ? AppColors.primary : AppColors.card,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: SvgPicture.asset(
                  asset,
                  colorFilter: ColorFilter.mode(
                    isPrime ? AppColors.textButton : AppColors.secondaryText,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (showText) ...[
                horizontalSpace(8),
                Text(
                  text,
                  style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryText)
                      .copyWith(color: isPrime ? AppColors.textButton : null),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}