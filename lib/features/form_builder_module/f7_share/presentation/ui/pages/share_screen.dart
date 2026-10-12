import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/helper/form_builder/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_state.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/search_bar_share_widget.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class FormShareScreen extends StatefulWidget {
  const FormShareScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<FormShareScreen> createState() => _FormShareScreenState();
}

class _FormShareScreenState extends State<FormShareScreen> with TickerProviderStateMixin {
  late AnimationController _gridAnimationController;
  late AnimationController _previousGridAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _gridAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _previousGridAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    // ✅ Initialize the ShareCubit with the form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShareCubit>().selectForm(widget.form);
      // Start animations after loading
      Future.delayed(const Duration(milliseconds: 100), () {
        _gridAnimationController.forward();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        _previousGridAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _gridAnimationController.dispose();
    _previousGridAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context)
            .detailsOfTitle(_getTitle(widget.form.formHeadModel, context)),
        thirdTitle: S.of(context).share,
        onFirstTap: breadcrumbPop(context, 2),
        onSecondTap: breadcrumbPop(context, 1),
        child: BlocBuilder<ShareCubit, ShareState>(
        builder: (context, state) {
          // ✅ Show loading indicator while initializing
          if (state is ShareInitial || state is! ShareLoaded) {
            return const CircleProgressMaster();
          }

          final loadedState = state;

          // The frame scrolls the content itself on mobile; on tablet it hands
          // the child a bounded height, so the scroll view stays here.
          final Widget content = Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).employeeInformation,
                    style: StyleText.fontSize18Weight500,
                  ),
                  verticalSpace(8),
                  SearchBarShareWidget(form: widget.form),
                  verticalSpace(15),
                  _buildDataWidget(context, loadedState),
                  verticalSpace(15),
                  _buildPreviousSelected(context, loadedState),
                  verticalSpace(15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      customButton(
                        title: S.of(context).review,
                        function: () {
                          context.read<ShareCubit>().newSelectedSearch("");
                          AppDialogs.shareAccessDialog(context, () {
                            context.read<ShareCubit>().grantAccess();
                          });
                        },
                      )
                    ],
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

  Widget _buildSelectedPersonsAvatars(
      BuildContext context,
      ShareLoaded state,
      ) {
    return Wrap(
      children: [
        for (int i = 0; i < state.newSelectedPersons.length; i++)
          if (state.newSelectedPersons[i].isSelected)
            Container(
              margin: const EdgeInsetsDirectional.only(end: 8),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: state.newSelectedPersons[i].image.contains('http')
                        ? NetworkImage(state.newSelectedPersons[i].image)
                        : appImageProvider(state.newSelectedPersons[i].image) as ImageProvider,
                  ),
                  Transform.scale(
                    scale: 1.2,
                    child: Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        splashColor: AppColors.transparent,
                        onTap: () {
                          context
                              .read<ShareCubit>()
                              .togglePersonSelection(i, false);
                        },
                        child: ClipOval(
                          child: SizedBox(
                            height: 14,
                            width: 14,
                            child: SvgPicture.asset(
                              AppAssets.close,
                              width: 12,
                              height: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 3600) {
      return 5;
    } else if (screenWidth > 2400) {
      return 4;
    } else if (screenWidth <= 2400 && screenWidth > 1200) {
      return 3;
    } else if (screenWidth > 600 && screenWidth < 1200) {
      return 2;
    }
    return 1;
  }

  Widget _buildDataWidget(BuildContext context, ShareLoaded state) {

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 75.h,
      ),
      itemCount: state.filteredPersons.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          controller: _gridAnimationController,
          child: FormPersonStateView(
            person: state.filteredPersons[index],
            onTap: () {
              context.read<ShareCubit>().togglePersonSelection(index, false);
            },
          ),
        );
      },
    );
  }

  Widget _buildPreviousSelected(BuildContext context, ShareLoaded state) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 75.h,
      ),
      itemCount: state.filteredPreviousSelectedPersons.length,
      itemBuilder: (context, index) {
        return _buildAnimatedGridItem(
          index: index,
          controller: _previousGridAnimationController,
          child: FormPersonStateView(
            person: state.filteredPreviousSelectedPersons[index],
            onTap: () {
              // Previous selections can't be toggled
            },
          ),
        );
      },
    );
  }

  /// Builds an animated grid item with slide-in animation
  Widget _buildAnimatedGridItem({
    required int index,
    required AnimationController controller,
    required Widget child,
  }) {
    // Stagger the animation based on index
    final delay = index * 0.05; // 50ms delay between items

    final animation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Slide from left
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
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
        parent: controller,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeIn,
        ),
      ),
    );

    return SlideTransition(
      position: animation,
      child: FadeTransition(
        opacity: opacityAnimation,
        child: child,
      ),
    );
  }

  String _getTitle(FormHeadData formHeadModel, BuildContext context) {
    if (context.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }
    return formHeadModel.title ?? '';
  }
}