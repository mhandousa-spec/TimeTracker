import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/forms_group_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/filter_row.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/group_info.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/helper/form_builder/person_state_view.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/widgets/add_image_widget.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key, required this.form});
  final FormEntity form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context).detailsOfTitle(form.getTitle),
        thirdTitle: S.of(context).group,
        fourthTitle: S.of(context).createGroup,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: BlocBuilder<FormsGroupCubit, FormsGroupState>(
          builder: (context, state) {
            if (state is! FormsGroupLoaded) {
              return const CircleProgressMaster();
            }

            // The frame scrolls the content itself on mobile; on tablet it
            // hands the child a bounded height, so the scroll view stays here.
            final Widget content = Form(
              key: state.createFormKey,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    verticalSpace(30),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                        const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             AddImageWidget(),
                            verticalSpace(15),
                             GroupInfo(),
                            if (ContextExtension(context).isTablett) ...[
                              verticalSpace(15),
                              Text(
                                'Employee Information',
                                style: StyleText.fontSize18Weight500,
                              ),
                            ],
                            verticalSpace(8),
                             FilterRow(),
                            verticalSpace(15),
                            _buildDataWidget(context, state),
                            verticalSpace(15),
                          ],
                        ),
                      ),
                    ),
                    verticalSpace(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customButton(
                          title: 'Create Group',
                          function: () async {
                            if (state.createFormKey.currentState!.validate()) {
                              final result = await context
                                  .read<FormsGroupCubit>()
                                  .createGroup();
                              if (result.isRight()) {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    verticalSpace(30),
                  ],
                ),
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
      FormsGroupLoaded state,
      ) {
    return Wrap(
      children: List.generate(
        state.filteredSelectedPersons.length,
            (index) {
          return Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: state.filteredSelectedPersons[index].image
                      .contains('http')
                      ? NetworkImage(
                    state.filteredSelectedPersons[index].image,
                  )
                      : appImageProvider(
                    state.filteredSelectedPersons[index].image,
                  ) as ImageProvider,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Transform.scale(
                    scale: 1.2,
                    child: ClipOval(
                      child: SizedBox(
                        height: 14,
                        width: 14,
                        child: InkWell(
                          splashColor: AppColors.transparent,
                          onTap: () {
                            // Find the person in filteredPersons to get correct index
                            final personIndex = state.filteredPersons.indexOf(
                              state.filteredSelectedPersons[index],
                            );
                            if (personIndex != -1) {
                              context
                                  .read<FormsGroupCubit>()
                                  .togglePersonSelection(personIndex);
                            }
                          },
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
          );
        },
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
        mainAxisSpacing: 16.sp,
        crossAxisSpacing: 16.sp,
        mainAxisExtent: 73.h,
      ),
      itemCount: state.filteredPersons.length,
      itemBuilder: (context, index) {
        return FormPersonStateView(
          color: AppColors.background,
          person: state.filteredPersons[index],
          onTap: () {
            context.read<FormsGroupCubit>().togglePersonSelection(index);
          },
        );
      },
    );
  }
}