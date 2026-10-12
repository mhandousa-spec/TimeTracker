
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/group_info.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';

import 'package:flutter/services.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/custom/77-default_dialog.dart';
import 'package:knowticed_plus/core/helper/form_builder/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/pages/edit_group_screen.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/add_image_widget.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';

import '../../../../../../core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
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

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(widget.form.getTitle),
        thirdTitle: S.of(context).group,
        fourthTitle: S.of(context).groupDetails,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: BlocBuilder<FormsGroupCubit, FormsGroupState>(
        builder: (context, state) {
          if (state is! FormsGroupLoaded) {
            return const CircleProgressMaster();
          }

          // The frame scrolls the content itself on mobile; on tablet it hands
          // the child a bounded height, so the scroll view stays here.
          final Widget content = Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(30),
                Row(
                  children: [
                    const Spacer(),
                    customButtonWithSvg(
                      title: 'Edit',
                      image: AppAssets.edit,
                      textStyle: StyleText.fontSize14Weight500,
                      color: AppColors.field,
                      colorBorder: AppColors.border,
                      widthImage: 16,
                      heightImage: 16,
                      width: 100,
                      function: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_){
                          return EditGroupScreen(form: widget.form,);
                        }));
                      },
                    ),
                    horizontalSpace(10),
                    customButtonWithSvg(
                      title: 'Delete',

                      image: AppAssets.delete,
                      textStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.white),
                      color: AppColors.red,
                      colorBorder: AppColors.red,
                      svgColor: AppColors.white,
                      widthImage: 16,
                      heightImage: 16,
                      width: 100,
                      function: () {
                        hapticController.triggerHapticFeedback(
                            vibration: VibrateType.heavyImpact,
                            hapticFeedback: HapticFeedback.heavyImpact
                        );
                        GetDialogHelper.generalDialog(
                          context: context,
                          child: DefaultDialog(
                            title: 'Delete Group',
                            subTitle: 'Are You Sure You Want To Delete This Group?',
                            autoClose: false,
                            lottieAsset: AppAssets.trash,
                            showButtons: true,
                            onConfirm: () async {
                              context.pop();
                              await context
                                  .read<FormsGroupCubit>()
                                  .deleteGroup();
                              if (context.mounted) {
                                context.pop();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                verticalSpace(15),
                // No Expanded: the frame scrolls this content on mobile, so
                // children have to size themselves.
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AddImageWidget(),
                        verticalSpace(15),
                        const GroupInfo(isReadOnly: true),
                        if (isTablet) ...[
                          verticalSpace(15),
                          Text(
                            'Employee Information',
                            style: StyleText.fontSize18Weight500,
                          ),
                        ],
                        verticalSpace(8),
                        _buildDataWidget(context, state),
                      ],
                    ),
                  ),
                ),
                verticalSpace(15),
              ],
            ),
          );

          return isTablet
              ? SingleChildScrollView(child: content)
              : content;
        },
        ),
      ),
    );
  }

  Widget _buildDataWidget(BuildContext context, FormsGroupLoaded state) {
    if (state.selectedGroup == null) {
      return const Center(child: Text('No group selected'));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
        CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisSpacing: 16.sp,
        crossAxisSpacing: 16.sp,
        mainAxisExtent: 73.h,
      ),
      itemCount: state.selectedGroup!.members.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          child: FormPersonStateView(
            color: AppColors.background,
            person: state.selectedGroup!.members[index],
            onTap: null,
          ),
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
}