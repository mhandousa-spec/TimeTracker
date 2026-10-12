import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/upload_media_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/upload_media_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/pending_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/submissions_result_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/uploaded_media_page.dart';
import 'package:knowticed_plus/core/helper/form_builder/category_filter_card.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize UploadMediaCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UploadMediaCubit>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return BlocBuilder<ResultCubit, ResultState>(
      builder: (context, resultState) {
        if (resultState is! ResultLoaded) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<UploadMediaCubit, UploadMediaState>(
          builder: (context, mediaState) {
            final isHasMedia = mediaState is UploadMediaLoaded
                ? mediaState.isHasMedia
                : false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(20),
                Row(
                  children: [
                    // TABS ARE NOT PERMISSION-GATED — AND MUST NOT BE (19/8/2026).
                    //
                    // This is what threw
                    // "RangeError (length): Invalid value: Valid value range is
                    // empty: 0" in _TabBarState.build and then painted the whole
                    // Result page red.
                    //
                    // `ResultCubit.initialize` builds `TabController(length: 2)`
                    // unconditionally, but the two `TabletCategoryFilterCard`s
                    // here were each behind their own `isHasPermission` check.
                    // TabBar requires tabs.length == controller.length: a role
                    // missing pendingSubmissions/viewSubmissions produced a
                    // controller expecting 2 tabs and a list holding 0 or 1, and
                    // TabBar indexed straight off the end. The 98531px Row
                    // overflow underneath was just the ErrorWidget that replaced
                    // the failed TabBar sizing itself to infinity.
                    //
                    // So a permission check on a tab can never stand alone —
                    // it has to change the controller's length too. Gate the tab
                    // list and the `length:` from one shared list, or not at all.
                    //
                    // FLEXIBLE, NOT A BARE TabBar: a Row hands its children
                    // unbounded width, so a scrollable TabBar sizes to its full
                    // intrinsic width and overflows once the labels outgrow the
                    // window. Flexible (loose) lets it keep its natural width
                    // when there is room and scroll internally when there is not.
                    Flexible(
                      child: TabBar(
                        controller: resultState.tabController,
                        overlayColor:
                            WidgetStateProperty.all(AppColors.transparent),
                        tabAlignment: TabAlignment.start,
                        onTap: (value) =>
                            context.read<ResultCubit>().onChangeTab(value),
                        labelPadding: const EdgeInsetsDirectional.only(end: 30),
                        isScrollable: true,
                        splashFactory: NoSplash.splashFactory,
                        indicatorColor: AppColors.transparent,
                        indicatorPadding: EdgeInsets.zero,
                        dividerHeight: 0,
                        dividerColor: AppColors.transparent,
                        tabs: [
                          TabletCategoryFilterCard(
                            name: 'Pending',
                            count: resultState.pendingUsers.length,
                            selected: resultState.tabController.index == 0,
                          ),
                          TabletCategoryFilterCard(
                            name: 'Submissions',
                            count: resultState.submittedUsers.length,
                            selected: resultState.tabController.index == 1,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (isTablet &&
                        resultState.tabController.index == 1 &&
                        isHasMedia)
                      customButtonWithSvg(
                        title: 'Uploaded Documents',
                        image: AppAssets.downloadPdf,
                        function: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_){
                            return UploadedMediaPage();
                          }));
                        },
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.textButton),
                        color: AppColors.primary,
                        colorBorder: AppColors.primary,
                        svgColor: AppColors.textButton,
                        widthImage: 16,
                        heightImage: 16,
                      )
                  ],
                ),
                verticalSpace(0.h),
                if (!isTablet &&
                    resultState.tabController.index == 1 &&
                    isHasMedia)
                  Row(
                    children: [
                      const Spacer(),
                      customButtonWithSvg(
                        title: 'Uploaded Documents',
                        image: AppAssets.downloadPdf,
                        function: () {
                          context.FormNavigateTo(Routes.uploadedMediaPage);
                        },
                        textStyle: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.textButton),
                        color: AppColors.primary,
                        colorBorder: AppColors.primary,
                        svgColor: AppColors.textButton,
                        widthImage: 16,
                        heightImage: 16,
                      )
                    ],
                  ),
                verticalSpace(20),
                _getScreen(resultState),
              ],
            );
          },
        );
      },
    );
  }

  Widget _getScreen(ResultLoaded state) {
    if (state.isPendingScreen) {
      return const PendingScreen();
    }
    return SubmissionsResultScreen(form: widget.form);
  }
}