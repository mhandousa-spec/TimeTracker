import 'package:get/get.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/access_management.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/orientation.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/form_builder/app_dialogs.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdwon_calander.dart';
import 'package:knowticed_plus/core/helper/form_builder/edit_permission_info_hint.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/users_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';

import '../../../../f1_home/presentation/controller/home_controller.dart';



class PublishSummaryRow extends StatelessWidget {
  const PublishSummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.card,
          radius: 15,
          child: SvgPicture.asset(AppAssets.summary),
        ),
        horizontalSpace(8),
        Text(
          S.of(context).summary,
          style: StyleText.fontSize14Weight500,
        ),
      ],
    );
  }
}

class PublishCardsRow extends StatelessWidget {
  const PublishCardsRow({
    super.key,
    required this.model,
    required this.accessManagement,
  });

  final FormEntity model;
  final String accessManagement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 70.h,
          width: 160.w,
          padding: EdgeInsets.only(top: 14.h, bottom: 13.h),
          decoration: ShapeDecoration(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${S.of(context).orientation}\n',
                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack),
                  ),
                  TextSpan(
                    // stored value -> localized label; see OrientationExtension
                    text: OrientationExtension.labelFor(
                        model.formHeadModel.orientation),
                    style: StyleText.fontSize16Weight500,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 70.h,
          width: 160.w,
          padding: EdgeInsets.only(top: 14.h, bottom: 13.h),
          decoration: ShapeDecoration(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${S.of(context).accessManagement}\n',
                    style: StyleText.fontSize16Weight500.copyWith(color: AppColors.secondaryBlack),
                  ),
                  TextSpan(
                    text: AccessManagementExtension.labelFor(accessManagement),
                    style: StyleText.fontSize16Weight500,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class PublishEditPermissionRow extends StatelessWidget {
  const PublishEditPermissionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EditPermissionInfoHint(),
              horizontalSpace(10),
              Text(
                S.of(context).editPermission,
                style: StyleText.fontSize14Weight400,
              ),
              const Spacer(),
              AdvancedSwitch(
                onChanged: (value) {},
                initialValue: false,
                activeColor: AppColors.primary,
                width: 30.w,
                height: 18.h,
              ),
            ],
          ),
        ),
        horizontalSpace(15),
        const Expanded(child: SizedBox.shrink()),
      ],
    );
  }
}

class PublishDateRow extends StatefulWidget {
  const PublishDateRow({super.key});

  @override
  State<PublishDateRow> createState() => _PublishDateRowState();
}

class _PublishDateRowState extends State<PublishDateRow> {
  DateTime? _accessBegins;
  DateTime? _accessEnds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).accessBegins, style: StyleText.fontSize14Weight400),
            verticalSpace(8),
            CustomDropdownCalendar(
              fillColor: AppColors.card,
              value: _accessBegins,
              hint: S.of(context).chooseTheDate,
              onChanged: (value) => setState(() => _accessBegins = value),
            )
          ],
        ),
        verticalSpace(15),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).accessEnds, style: StyleText.fontSize14Weight400),
            verticalSpace(8),
            CustomDropdownCalendar(
              fillColor: AppColors.card,
              value: _accessEnds,
              hint: S.of(context).chooseTheDate,
              onChanged: (value) => setState(() => _accessEnds = value),
            )
          ],
        )
      ],
    );
  }
}

class PublishActionRow extends StatelessWidget {
  const PublishActionRow({super.key, required this.model});

  final FormEntity model;

  @override
  Widget build(BuildContext context) {
    final homeController = context.read<HomeCubit>();

    return Row(
      children: [
        customButtonWithSvg(
          title: 'Back',
          function: () {
            Navigator.pop(context);
          },
          textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.black),
          color: AppColors.grey,
          image: '',
          widthImage: 0,
          heightImage: 0,
          colorBorder: AppColors.transparent,
        ),
        const Spacer(),
        customButtonWithSvg(
          title: 'Send',
          function: () async {
            FormPrivacyModel formPrivacyModel = FormPrivacyModel(
              timestamps: [Timestamp.now()],
              usersModel: UsersModel(
                accessBegin: model.restrictedAccessModel?.timeBegin != null
                    ? [Timestamp.fromDate(model.restrictedAccessModel!.timeBegin!)]
                    : null,
                accessEnd: model.restrictedAccessModel?.timeEnd != null
                    ? [Timestamp.fromDate(model.restrictedAccessModel!.timeEnd!)]
                    : null,
                editPermission: [model.restrictedAccessModel?.isEdit ?? false],
                emails: model.restrictedAccessModel?.selectedPersons
                    ?.map((e) => e.id)
                    .toList(),
                status: model.restrictedAccessModel?.selectedPersons
                    ?.map((e) => 'active')
                    .toList(),
              ),
            );

            Navigator.pop(context);
            homeController.createForm(model);
            homeController.addFormPrivcy(formPrivacyModel, model.id, model);

            await AppDialogs.creatingFormSuccessfully(context);
            Timer(const Duration(seconds: 2), () {
              Navigator.popUntil(context, (route) => route.isFirst);
            });
          },
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
          color: AppColors.primary,
          image: '',
          widthImage: 0,
          heightImage: 0,
          colorBorder: AppColors.transparent,
        ),
      ],
    );
  }
}
