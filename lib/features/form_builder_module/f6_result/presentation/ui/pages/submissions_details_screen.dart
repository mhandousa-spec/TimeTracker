import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart'; // Keep for .tr
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/results_permissions.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/core/helper/form_builder/submitted_page_viewer.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_head_data.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/ui/pages/submission_new.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/email_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/department.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
class SubmissionsDetailsScreen extends StatefulWidget {
  const SubmissionsDetailsScreen({super.key, required this.form});
  final FormEntity form;

  @override
  State<SubmissionsDetailsScreen> createState() =>
      _SubmissionsDetailsScreenState();
}

class _SubmissionsDetailsScreenState extends State<SubmissionsDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize pdf cubit with the number of services_management_module
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PdfCubit>().initialize(widget.form.pages.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    // CHANGED 19/8/2026 — header is SideFrameMasterServices now, not
    // PaginationAppBar. The crumbs also move out of the ResultLoaded branch,
    // so the page has a header (and a way back) while it is still loading.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        secondTitle: S.of(context)
            .detailsOfTitle(_getTitle(widget.form.formHeadModel, context)),
        thirdTitle: S.of(context).result,
        fourthTitle: S.of(context).submissions,
        onFirstTap: breadcrumbPop(context, 3),
        onSecondTap: breadcrumbPop(context, 2),
        onThirdTap: breadcrumbPop(context, 1),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: BlocBuilder<ResultCubit, ResultState>(
            builder: (context, state) {
              if (state is! ResultLoaded || state.selectedUser == null) {
                return const CircleProgressMaster();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(30),
                  Container(
                    height: ContextExtension(context).isTablett ? 110 : null,
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: isTablet
                        ? _tabletUserOverview(context, state)
                        : _mobileUserOverview(context, state),
                  ),
                  verticalSpace(20),
                  if(Get.find<MainCoreEmployeeController>().isHasPermission(
                    module: Modules.formBuilder,
                    section: FormPermissionsSections.resultsPermissions,
                    permission: ResultsPermissions.downloadFormDigitalAssets,
                  ) )
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      customButtonWithSvg(
                        title: 'Download',
                        image: AppAssets.downloadPdf,
                        function: () {
                          context.read<PdfCubit>().onDownloadClicked(
                            widget.form,
                            context,
                          );
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
                  Text(
                    'Submission Form',
                    style: StyleText.fontSize16Weight600,
                  ),
                  verticalSpace(8),
                  Align(
                    alignment: AlignmentDirectional.center,
                    child: SubmittedPageDetailsViewer(
                      model: state.formEntity!,
                      pages: state.pages,
                      isReadOnly: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  Row _tabletUserOverview(BuildContext context, ResultLoaded state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          foregroundColor: AppColors.primary,
          radius: 60.r,
          child: ClipRRect

            (

              borderRadius: BorderRadius.circular(50.r),
              child: SizedBox(child: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg",width: 80.w,height: 70.h,fit: BoxFit.fill,))),
        ),
        horizontalSpace(15),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FormatHelper.capitalize(state.selectedUser!.person.name),
                style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
              ),
              _buildTitleAndDepartment(context, state),
              _buildEmailAndPhone(context, state),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${'Submission Date'}: ',
                    style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                  ),
                  TextSpan(
                    text: DateFormat('dd MMM yyyy')
                        .format(state.selectedUser!.submissionTime!),
                    style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
                  )
                ],
              ),
            ),
            const Spacer(),
            customButtonWithSvg(
              title: 'Message',
              function: () {},
              textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.black,
                      ),
              color: AppColors.primary,
              image: AppAssets.chat,
              widthImage: 20,
              heightImage: 20,
              colorBorder: AppColors.transparent,
              svgColor: AppColors.black,
            )
          ],
        )
      ],
    );
  }

  Widget _buildEmailAndPhone(BuildContext context, ResultLoaded state) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return isTablet
        ? Row(
      children: [
        _rowItem(
          context: context,
          icon: AppAssets.email,
          title: '${'Email'}: ',
          value: state.selectedUser!.person.id,
        ),
        _rowItem(
          context: context,
          icon: AppAssets.phone,
          title: '${'Phone'}: ',
          value: state.selectedUser!.person.phone,
        )
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowItem(
          context: context,
          icon: AppAssets.email,
          title: '${'Email'}: ',
          value: state.selectedUser!.person.id,
        ),
        _rowItem(
          context: context,
          icon: AppAssets.phone,
          title: '${'Phone'}: ',
          value: state.selectedUser!.person.phone,
        )
      ],
    );
  }

  Widget _buildTitleAndDepartment(BuildContext context, ResultLoaded state) {
    bool isTablet = MediaQuery.of(context).size.width > 600;
    return isTablet
        ? Row(
      children: [
        _rowItem(
          context: context,
          icon: AppAssets.title,
          title: '${'Title'}: ',
          value: state.selectedUser!.person.title,
        ),
        _rowItem(
          context: context,
          icon: AppAssets.department,
          title: '${'Department'}: ',
          value: state.selectedUser!.person.departmentName,
        ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _rowItem(
          context: context,
          icon: AppAssets.title,
          title: '${'Title'}: ',
          value: state.selectedUser!.person.title,
        ),
        _rowItem(
          context: context,
          icon: AppAssets.department,
          title: '${'Department'}: ',
          value: state.selectedUser!.person.departmentName,
        ),
      ],
    );
  }

  Widget _rowItem({
    required BuildContext context,
    required String icon,
    required String title,
    required String value,
  }) {
    Widget row = Row(
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: SvgPicture.asset(
            icon,
            colorFilter:
            ColorFilter.mode(AppColors.spanText, BlendMode.srcIn),
          ),
        ),
        horizontalSpace(3),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: title,
                  style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                ),
                TextSpan(
                  text: FormatHelper.capitalize(value),
                  style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    bool isTablet = MediaQuery.of(context).size.width > 600;
    return isTablet ? Expanded(child: row) : row;
  }

  String _getTitle(FormHeadData formHeadModel, BuildContext context) {
    if (context.isArabic) {
      if (formHeadModel.arTitle != null && formHeadModel.arTitle!.isNotEmpty) {
        return formHeadModel.arTitle ?? '';
      }
    }
    return formHeadModel.title ?? '';
  }

  Widget _mobileUserOverview(BuildContext context, ResultLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          foregroundColor: AppColors.primary,
          radius: 30.r,
      child: ClipRRect

        (

          borderRadius: BorderRadius.circular(30.r),
          child: SizedBox(child: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/male_avatar.svg",width: 40.w,height: 40.h,fit: BoxFit.fill,))),
        ),
        horizontalSpace(15),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        FormatHelper.capitalize(
                            state.selectedUser!.person.name),
                        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      AppAssets.chat,
                      width: 19.sp,
                      height: 19.sp,
                    ),
                  )
                ],
              ),
              _buildTitleAndDepartment(context, state),
              _buildEmailAndPhone(context, state),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${'Submission Date'}: ',
                          style: StyleText.fontSize12Weight500.copyWith(color: AppColors.spanText),
                        ),
                        TextSpan(
                          text: DateFormat('dd MMM yyyy')
                              .format(state.selectedUser!.submissionTime!),
                          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.fullBlack),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}