// by : Mohamed Ashraf

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/services/media_picker_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../controller/groups_controller.dart';
import './switch_button/switch_button_title.dart';
import './switch_button/switch_button_title_subTitle.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

class AboutGroupProfile extends StatelessWidget {
  const AboutGroupProfile({
    super.key,
    required this.groupDescription,
    required this.groupName,
  });

  final TextEditingController groupDescription;
  final TextEditingController groupName;

  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablett;

    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is! GroupsLoaded) {
          return const SizedBox();
        }

        final controller = context.read<GroupsCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            verticalSpace(isTablet ? 40 : 32),
            Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppColors.grey,
                  backgroundImage: state.groupImage != null
                      ? FileImage(state.groupImage!.absolute)
                      : appImageProvider(
                    AppAssets.blackGallery,
                  ) as ImageProvider,
                ),
                GestureDetector(
                  onTap: () async {
                    // Picker lives in the page/service now — cubit only stores
                    // the result (§16/§20). Old pickGroupImage() was removed.
                    final picked =
                        await MediaPickerService().pickImage(fromCamera: false);
                    if (picked?.path != null) {
                      controller.setGroupImage(File(picked!.path!));
                    }
                  },
                  child: CircleAvatar(
                    radius: 12.r,
                    backgroundColor: AppColors.primary,
                    child: SvgPicture.asset(
                      AppAssets.camera,
                      width: 16.w,
                      height: 16.h,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            verticalSpace(24),
            Text(
              S.of(context).groupName,
              style: ContextExtension(context).isTablett
                  ? StyleText.fontSize16Weight500
                  : StyleText.fontSize14Weight600,
            ),
            verticalSpace(8),
            CustomTextField(
              hint: S.of(context).Texthere,
              maxLength: 100,
              controller: groupName,
            ),
            verticalSpace(23),
            Text(
              S.of(context).description,
              style: ContextExtension(context).isTablett
                  ? StyleText.fontSize16Weight500
                  : StyleText.fontSize14Weight600,
            ),
            verticalSpace(8),
            CustomTextField(
              hint: S.of(context).Texthere,
              maxLength: 300,
              maxLines: 4,
              controller: groupDescription,
            ),
            verticalSpace(28),
            SwitchButtonTitleSubTitle(
              title: S.of(context).makePrivate,
              subTitle: S.of(context).itCanViewOrJoinWithInvite,
              value: state.isMakePrivateEnabled,
              onChanged: controller.onChangedMakePrivate,
            ),
            verticalSpace(17),
            SwitchButtonTitleSubTitle(
              title: S.of(context).adminOnly,
              subTitle: S.of(context).onlyAdminsCanShareContent,
              value: state.isAdminEnabled,
              onChanged: controller.onChangedAdmin,
            ),
            verticalSpace(17),
            SwitchButtonTitle(
              title: S.of(context).disappearingMessages,
              value: state.isDisappearingMessagesEnabled,
              onChanged: controller.onChangedDisappearingMessages,
            ),
            verticalSpace(17),
            SwitchButtonTitle(
              title: S.of(context).muteNotifications,
              value: state.isMuteEnabled,
              onChanged: controller.onChangMuteMessages,
            ),
            verticalSpace(24),
            Align(
              alignment: isTablet ? Alignment.bottomRight : Alignment.bottomCenter,
              child: customButton(
                width: isTablet ? 105.w : double.infinity,
                textColor: AppColors.base,
                color: AppColors.primary,
                title: S.of(context).Save,
                textStyle: isTablet
                    ? StyleText.fontSize18Weight500.copyWith(color: AppColors.textButton)
                    : StyleText.fontSize16Weight500.copyWith(color: AppColors.textButton),
                function: () async {
                  await controller.updateGroupData();
                },),
            ),
            verticalSpace(24),
          ],
        );
      },
    );
  }
}