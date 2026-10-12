import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/pagination_app_bar.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/create_data_screen_body.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/head_screen_body.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/widgets/tablet/card_form_preview.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/ui/pages/create_head_form_screen.dart';
class CreatingFormTabletScreen extends StatefulWidget {
  const CreatingFormTabletScreen({super.key, this.formModel});
  final FormEntity? formModel;

  @override
  State<CreatingFormTabletScreen> createState() =>
      _CreatingFormTabletScreenState();
}

class _CreatingFormTabletScreenState extends State<CreatingFormTabletScreen> {

  late bool isEditing; // ✅ Track if editing

  @override
  void initState() {
    super.initState();
    isEditing = widget.formModel != null;
    // Initialize both Cubits
    final headCubit = context.read<CreateFormHeadCubit>();
    final dataCubit = context.read<CreateFormDataCubit>();

    headCubit.resetController();
    dataCubit.resetController();

    headCubit.init(editFormModel: widget.formModel);
    dataCubit.init(editFormModel: widget.formModel);
  }

  @override
  Widget build(BuildContext context) {
    return ContextExtension(context).isTablett
        ? Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CreateFormHeadCubit, CreateFormHeadState>(
        builder: (context, headState) {
          if (headState is! CreateFormHeadLoaded) {
            return const CircleProgressMaster();
          }

          return Form(
            key: context.read<CreateFormHeadCubit>().formKey,
            child: ListView(
              // Bug report #6: 20.sp horizontal, same as every other form
              // builder page (formBuilderTitlePadding).
              padding: EdgeInsetsDirectional.only(
                  start: 20.sp, end: 20.sp, top: 0.h),
              children: [
                _buildAppBar(context),
                //head Section
                HeadScreenBody(formModel: widget.formModel),
                verticalSpace(20),
                //hide page Section
                BlocBuilder<CreateFormDataCubit, CreateFormDataState>(
                  builder: (context, dataState) {
                    if (dataState is! CreateFormDataLoaded) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        for (int pageIndex = 0;
                        pageIndex < dataState.pages.length;
                        pageIndex++) ...[
                          if (!dataState.pages[pageIndex].isPageExpanded) ...[
                            Row(
                              children: [
                                Text(
                                    '${'Page'} ${pageIndex + 1}',
                                    style: StyleText.fontSize14Weight500),
                                const Spacer(),
                                InkWell(
                                  onTap: () {
                                    context
                                        .read<CreateFormDataCubit>()
                                        .expandedPage(pageIndex);
                                  },
                                  child: Text(
                                    'Expand',
                                    style: StyleText.fontSize14Weight500
                                        .copyWith(
                                        color: AppColors.blue,
                                        decoration:
                                        TextDecoration.underline,
                                        decorationColor:
                                        AppColors.blue),
                                  ),
                                )
                              ],
                            ),
                            verticalSpace(20),
                          ]
                        ],
                      ],
                    );
                  },
                ),
                Row (
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 284.w,
                        child: CreateDataScreenBody(
                            formModel: widget.formModel)),
                    horizontalSpace(15),
                    Expanded( child: Container(

                        child: CardFormPreview(formModel: widget.formModel)))

                  ],
                )
              ],
            ),
          );
        },
      ),
    )
        : const CreateHeadFormScreen();
  }

  _buildAppBar(BuildContext context) {
    return PaginationAppBar(
      screensTitles: ['Form Builder', _getTextAppBar()],
      // 20.sp from the top, flush with the content's start edge (#6).
      padding: EdgeInsetsDirectional.only(top: 20.sp, bottom: 20.sp),
    );
  }

  String _getTextAppBar() {
    if (widget.formModel == null) {
      return 'Creating Form';
    }
    if (widget.formModel!.status == FormStatus.deleted) {
      return 'Deleting Form Details';
    }
    return 'Editing Form Details';
  }
}