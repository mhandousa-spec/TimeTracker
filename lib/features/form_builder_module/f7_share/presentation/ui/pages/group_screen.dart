import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/pages/group_details_screen.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/helper/form_builder/enum.dart' as FormatHelper;
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/entities/group_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/avatar_stack_widget.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/search_bar_group_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/utils/helper_format.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gridAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _gridAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
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

  void _restartAnimation() {
    _gridAnimationController.reset();
    _gridAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(widget.form.getTitle),
        thirdTitle: S.of(context).share,
        fourthTitle: S.of(context).group,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: BlocConsumer<FormsGroupCubit, FormsGroupState>(
        listener: (context, state) {
          // Restart animation when groups are loaded or filtered
          if (state is FormsGroupLoaded && state.groups.isNotEmpty) {
            _restartAnimation();
          }
        },
        builder: (context, state) {
          if (state is FormsGroupLoading) {
            return const CircleProgressMaster();
          }

          if (state is! FormsGroupLoaded) {
            return const CircleProgressMaster();
          }

          // The frame scrolls the content itself on mobile; on tablet it hands
          // the child a bounded height, so the scroll view stays here.
          final Widget content = Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).groupInformation,
                  style: StyleText.fontSize18Weight500,
                ),
                verticalSpace(8),
                SearchFormGroupTablet(form: widget.form),
                verticalSpace(15),
                // No Expanded: the frame scrolls this content on mobile, so
                // children have to size themselves.
                state.groups.isNotEmpty
                    ? _buildDataWidget(context, state)
                    : Center(
                        child: Column(
                          children: [
                            Lottie.asset(
                              AppAssets.noData,
                              width: 400.sp,
                              height: 400.sp,
                            ),
                            Text(
                              S.of(context).noGroupFound,
                              style: StyleText.fontSize14Weight500,
                            )
                          ],
                        ),
                      ),
                verticalSpace(15),
                if (state.groups.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: customButtonWithSvg(
                      title: S.of(context).review,
                      function: () async {
                        final shareCubit = context.read<ShareCubit>();

                        // 1. FIRST: Add group members
                        context.read<FormsGroupCubit>().selectGroupMembers(shareCubit);

                        // 2. THEN: Refresh filtered list
                        shareCubit.newSelectedSearch("");

                        // 3. WAIT: Allow state to propagate
                        await Future.microtask(() {});

                        // 4. FINALLY: Show dialog WITH the cubit instance
                        if (context.mounted) {
                          AppDialogs.shareAccessDialog(
                            context,
                                () {
                              shareCubit.grantAccess();
                            },
                            shareCubit: shareCubit, // ✅ PASS THE CUBIT
                          );
                        }
                      },
                      textStyle: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.black),
                      color: AppColors.primary,
                      image: '',
                      widthImage: 0,
                      heightImage: 0,
                      colorBorder: AppColors.transparent,
                    ),
                  ),
                verticalSpace(15),
              ],
            ),
          );

          return ContextExtension(context).isTablett
              ? SingleChildScrollView(child: content)
              : content;
        },
        ),
      ),
    );
  }

  Widget _buildDataWidget(BuildContext context, FormsGroupLoaded state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
        CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 101,
      ),
      // #36: the searched/sorted view.
      itemCount: state.filteredGroups.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          child: _getGridViewItem(
            context: context,
            group: state.filteredGroups[index],
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

  Widget _getGridViewItem({
    required BuildContext context,
    required GroupEntity group,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<FormsGroupCubit>().initGroupDetails(group);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupDetailsScreen(form: widget.form),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsetsDirectional.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.disabledGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: group.groupImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(group.groupImage!),
                )
                    : SvgPicture.asset(
                  AppAssets.image,
                  height: 20,
                  width: 20,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            horizontalSpace(10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  FormatHelper.capitalize(group.groupName),
                  style: StyleText.fontSize16Weight500,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {

                    
                    context.read<FormsGroupCubit>().selectGroup(group);
                    
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: CustomCheckBox(
                      isSelected: group.isSelected,
                      borderColor: AppColors.borderGrey,
                    ),
                  ),
                ),
                const Spacer(),
                AvatarStack(
                  imageUrls: () {
                    
                    final urls = group.getUsersAvatar();
                    
                    return urls;
                  }(),
                  maxVisible: 3,
                  avatarSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}