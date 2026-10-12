import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/ui/pages/result_screen.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/ui/pages/share_screen.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_routes.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/menu.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/ui/pages/submissions_screen.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/form_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/form/results_permissions.dart';

class FormDetailsActions extends StatelessWidget {
  const FormDetailsActions({
    super.key,
    required this.model,
    required this.vsync,
  });

  final FormEntity model;
  final TickerProvider vsync;

  // PERMISSION GATES RESTORED 26/9/2026 (form bug report #27): a role whose
  // Form Builder switches are OFF still saw every action. Each button is
  // gated in ONE place ([_can] / [_canSeeResults]) and the spacing is built
  // from the visible buttons only, so a hidden action never leaves a gap.
  bool _can(FormPermissions permission) =>
      Get.find<MainCoreEmployeeController>().isHasPermission(
        module: Modules.formBuilder,
        section: FormPermissionsSections.formPermissions,
        permission: permission,
      );

  /// Results is a hub for the Results switches; show it when ANY of its tabs
  /// is allowed.
  bool _canSeeResults() {
    final core = Get.find<MainCoreEmployeeController>();
    return <ResultsPermissions>[
      ResultsPermissions.users,
      ResultsPermissions.pendingSubmissions,
      ResultsPermissions.viewSubmissions,
      ResultsPermissions.analytics,
    ].any((p) => core.isHasPermission(
          module: Modules.formBuilder,
          section: FormPermissionsSections.resultsPermissions,
          permission: p,
        ));
  }

  /// Joins [items] with [gap] between them (no leading/trailing gap).
  List<Widget> _spaced(List<Widget> items, double gap) {
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) out.add(horizontalSpace(gap));
      out.add(items[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobileIcons = !ContextExtension(context).isTablett;
    final bool canFill = _can(FormPermissions.fillOutForm);
    final bool canResults = _canSeeResults();
    final bool canPdf = _can(FormPermissions.convertToPdf);
    final bool canShare = _can(FormPermissions.share);
    final bool canEdit = _can(FormPermissions.editForm);
    final bool canDelete = _can(FormPermissions.deleteForm);

    final Widget? fill = canFill ? _buildFillOutButton(context, "no") : null;
    final Widget? results = canResults ? _buildResultsButton(context) : null;
    final Widget? pdf = canPdf ? _buildConvertToPdfButton(context) : null;
    final List<Widget> manage = [
      if (canShare) _buildShareButton(isMobileIcons, context),
      if (canEdit) _buildEditButton(isMobileIcons, context),
      if (canDelete) _buildDeleteButton(isMobileIcons, context),
    ];

    if (ContextExtension(context).isPhone) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fill != null || results != null)
            Row(
              children: [
                if (fill != null) fill,
                const Spacer(),
                if (results != null) results,
              ],
            ),
          if ((fill != null || results != null) &&
              (pdf != null || manage.isNotEmpty))
            verticalSpace(15),
          if (pdf != null || manage.isNotEmpty)
            Row(
              children: [
                if (pdf != null) pdf,
                const Spacer(),
                ..._spaced(manage, 10),
              ],
            ),
        ],
      );
    }

    final List<Widget> topRight = [
      if (results != null) results,
      if (pdf != null) pdf,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (fill != null || topRight.isNotEmpty)
          Row(
            children: [
              if (fill != null) fill,
              const Spacer(),
              ..._spaced(topRight, 15),
            ],
          ),
        if ((fill != null || topRight.isNotEmpty) && manage.isNotEmpty)
          verticalSpace(15),
        if (manage.isNotEmpty)
          Row(
            children: [
              const Spacer(),
              ..._spaced(manage, 10),
            ],
          ),
      ],
    );
  }

  Widget _buildFillOutButton(BuildContext context, String Name) {
    return customButtonWithSvg(
      title: S.of(context).fillOutForm,
      function: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return FormSubmissionsScreen(model: model, name: "no");
        }));
      },
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: AppAssets.fillOut,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.black,
    );
  }

  Widget _buildResultsButton(BuildContext context) {
    return customButtonWithSvg(
      title: 'Results',
      function: () {
        context.read<ResultCubit>().initialize(model, vsync);

        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ResultScreen(form: model);
        }));
      },
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: AppAssets.results,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  Widget _buildShareButton(bool isMobile, BuildContext context) {
    if (isMobile) {
      return customButtonWithSvg(
        title: '',
        function: () {
          context.read<ShareCubit>().selectForm(model);

          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return FormShareScreen(form: model);
          }));
        },
        textStyle: StyleText.fontSize16Weight500,
        color: AppColors.primary,
        image: AppAssets.share,
        widthImage: 19,
        heightImage: 19,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      );
    }

    return customButtonWithSvg(
      title: 'Share',
      function: () {
        context.read<ShareCubit>().selectForm(model);
        context.FormNavigateTo(Routes.shareScreen, arguments: model);
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.textButton,
      ),
      color: AppColors.primary,
      image: AppAssets.share,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  Widget _buildConvertToPdfButton(BuildContext context) {
    return customButtonWithSvg(
      title: S.of(context).convertToPdf,
      function: () {
        context.read<HomeCubit>().popupConvertPdf(model, context);
      },
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildEditButton(bool isMobile, BuildContext context) {
    if (isMobile) {
      return customButtonWithSvg(
        title: '',
        function: () {
          context.read<HomeCubit>().popupEditFormModel(context, model);
        },
        textStyle: StyleText.fontSize16Weight500,
        color: AppColors.primary,
        image: AppAssets.edit,
        widthImage: 19,
        heightImage: 19,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.textButton,
      );
    }

    return customButtonWithSvg(
      title: 'Edit',
      function: () {
        context.read<HomeCubit>().popupEditFormModel(context, model);
      },
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: AppColors.black,
      ),
      color: AppColors.primary,
      image: AppAssets.edit,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.black,
    );
  }

  Widget _buildDeleteButton(bool isMobile, BuildContext context) {
    if (isMobile) {
      return customButtonWithSvg(
        title: '',
        function: () {
          context.read<HomeCubit>().onMenuSelect(
                MenuEnum.delete,
                formModel: model,
                context: context,
              );
        },
        textStyle: StyleText.fontSize14Weight500,
        color: AppColors.red,
        image: AppAssets.delete,
        widthImage: 19,
        heightImage: 19,
        colorBorder: AppColors.transparent,
        svgColor: AppColors.white,
      );
    }

    return customButtonWithSvg(
      title: 'Delete',
      function: () {
        context.read<HomeCubit>().onMenuSelect(
              MenuEnum.delete,
              formModel: model,
              context: context,
            );
      },
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.white,
      ),
      color: AppColors.red,
      image: AppAssets.delete,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.white,
    );
  }
}
