import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr and Get.back()
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_table_builder.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/submissions_details_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/uploaded_media_page.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/results_permissions.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/table/default_data_table.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/widgets/search_bar_submissions_widget.dart';
class SubmissionsResultScreen extends StatefulWidget {
  const SubmissionsResultScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<SubmissionsResultScreen> createState() => _SubmissionsResultScreenState();
}

class _SubmissionsResultScreenState extends State<SubmissionsResultScreen>
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

  // Restart animation when filtered list changes or view switches
  void _restartAnimation() {
    _gridAnimationController.reset();
    _gridAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResultCubit, ResultState>(
      listener: (context, state) {
        // Restart animation when filtered list changes or view switches
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
            const SearchBarSubmissionsWidget(),
            verticalSpace(15),
            if (ContextExtension(context).isTablett) ...[
              Align(
                alignment: Alignment.centerRight,
                child: _actionButtons(context, cubit, state),
              ),
              verticalSpace(15),
            ],
            _buildDataWidget(context, cubit, state),
          ],
        );
      },
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
        onTap: () {
          cubit.selectUser(model);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubmissionsDetailsScreen(form: widget.form),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsetsDirectional.only(start: 13, end: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.r),
                  child: SizedBox(
                    child: CustomSvgImage(
                      assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg",
                      width: 45.w,
                      height: 45.h,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              horizontalSpace(10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(model.person.name),
                      style: StyleText.fontSize14Weight500,
                    ),
                    Text(
                      '${FormatHelper.capitalize(model.person.departmentName)} ',
                      style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                    ),
                    Row(
                      children: [
                        Text(
                          FormatHelper.capitalize(model.person.title),
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Date',
                                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.spanText),
                              ),
                              TextSpan(
                                text: ' ${FormDateTimeHelper.formatDate(model.submissionTime!)}',
                                style: StyleText.fontSize10Weight400.copyWith(color: AppColors.fullBlack),
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButtons(
      BuildContext context, ResultCubit cubit, ResultLoaded state) {
    final textEditingController = state.textEditingController;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (Get.find<MainCoreEmployeeController>().isHasPermission(
          module: Modules.formBuilder,
          section: FormPermissionsSections.resultsPermissions,
          permission: ResultsPermissions.exportSubmissionData,
        ))
          _buildIconWidget(
            onTap: () {
              AppDialogs.downloadFile(
                textEditingController,
                context,
                    () {
                  cubit.exportToCSV(textEditingController.text.trim());
                  Get.back();
                },
              );
            },
            asset: AppAssets.export,
            text: 'Export',
            showText: ContextExtension(context).isTablett,
            isPrime: true,
          ),
        _buildSpace(context),
        _buildIconWidget(
          onTap: () => cubit.changeDataView(false),
          asset: AppAssets.listView,
          text: '',
          isPrime: !state.isGridView,
          showText: false,
        ),
        _buildSpace(context),
        _buildIconWidget(
          onTap: () => cubit.changeDataView(true),
          asset: AppAssets.grid,
          text: '',
          showText: false,
          isPrime: state.isGridView,
        ),
      ],
    );
  }

  Widget _buildSpace(BuildContext context) {
    double space = ContextExtension(context).isPhone ? 10 : 15;
    return horizontalSpace(space);
  }

  Widget _buildIconWidget({
    required String asset,
    required String text,
    Function()? onTap,
    required bool showText,
    bool isPrime = false,
  })
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        width: showText ? 100 : 38,
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
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  asset,
                  color: (!isPrime) ? AppColors.text : AppColors.black,
                ),
              ),
              if (showText) ...[
                horizontalSpace(8),
                Text(
                  text,
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: isPrime ? AppColors.black : AppColors.inverseBase,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
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

  Widget _buildDataWidget(
      BuildContext context, ResultCubit cubit, ResultLoaded state) {
    if (state.isGridView || !ContextExtension(context).isTablett) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 66.h,
        ),
        itemCount: state.filteredSubmittedUsers.length,
        itemBuilder: (context, index) {
          var width = MediaQuery.of(context).size.width;
          var isPhone = width <= 600;
          return _buildAnimatedGridItem(
            index: index,
            child: _getGridViewItem(
              context: context,
              isPhone: isPhone,
              model: state.filteredSubmittedUsers[index],
              cubit: cubit,
            ),
          );
        },
      );
    } else {
      return DefaultDataTable(
        columns: buildResultTableColumns(state),
        rows: buildResultTableRows(state),
      );

    }
  }
}