/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: role_information.dart
/// Purpose: Declares `RoleInformation`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/data_grc_module/core/extensions/extensions.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_date.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/messaging_interface_implementation.dart';
import 'package:knowticed_plus/core/custom/75-custom_title_value_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';

class RoleInformation extends StatefulWidget {
  const RoleInformation({super.key});

  @override
  State<RoleInformation> createState() => _RoleInformationState();
}

/// Shown when a creator has no photo and no gendered avatar of their own.
/// [EmployeeHelper.getEmployeeImage] already returns the female variant where
/// it applies, so this is only the fallback of last resort.
const String _defaultAvatarAsset =
    'assets/icons_assets/main_icons_assets/male_avatar.svg';

class _RoleInformationState extends State<RoleInformation> {
  late bool isTablet;
  late RoleCubit controller;
  bool isHide = false;

  @override
  Widget build(BuildContext context) {
    controller = context.read<RoleCubit>();
    isTablet = MediaQuery.of(context).size.width > 600;
    return roleInformation();
  }

  roleInformation() {
    return Column(
      spacing: 8.sp,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              S.of(context).roleInformation,
              style: StyleText.fontSize16Weight600,
            ),
            Spacer(),
            InkWell(
              splashColor: AppColors.transparent,
              hoverColor: AppColors.transparent,
              onTap: () {
                setState(() {
                  isHide = !isHide;
                });
              },
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isHide ? S.of(context).expand : S.of(context).hide,
                      style: StyleText.fontSize10Weight400.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      height: 1,
                      color: AppColors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!isHide)
          Container(
            padding: EdgeInsets.all(15.sp),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(8.sp),
            ),
            child: isTablet ? tabletInformation() : mobileInformation(),
          )
      ],
    );
  }

  Widget tabletInformation() {
    // ✅ FIXED: Use firstWhereOrNull to handle missing employees gracefully
    // Lookup moved to RoleCubit.employeeByEmail — `firstWhereOrNull` came from
    // `package:get`, which is banned and no longer imported here.
    var creatorEmployee =
        controller.employeeByEmail(controller.selectedRole!.currentCreatedBy);

    // ✅ FIXED: Provide fallback values if employee not found
    String image = creatorEmployee != null
        ? EmployeeHelper.getEmployeeImage(employee: creatorEmployee)
        : _defaultAvatarAsset; // Default avatar

    String name = creatorEmployee != null
        ? EmployeeHelper.getEmployeeLocalizedName(
        employee: creatorEmployee, context: context)
        : controller.selectedRole!.currentCreatedBy; // Show email as fallback
    final isArabic = context.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10.sp,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            roleImage(75.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                      isArabic ?  FormatHelper.capitalize(controller.selectedRole!.currentRoleNameAr) :
                      FormatHelper.capitalize(controller.selectedRole!.currentRoleName),

                        style: StyleText.fontSize16Weight600,
                      ),
                      CustomTitleValueWidget(
                        title: "${S.of(context).creationDate}: ",
                        value: _creationDate(),
                      )
                    ],
                  ),
                  SizedBox(height: 10.sp),
                  CustomTitleValueWidget(
                      value: controller.selectedRole!.currentRoleDescription.isNotEmpty
                          ? isArabic ? FormatHelper.capitalize(controller.selectedRole!.currentRoleDescriptionAr) :FormatHelper.capitalize(controller.selectedRole!.currentRoleDescription)
                          : "",
                      title: "${S.of(context).role_description}: "),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10.sp),
        Text(
          S.of(context).createdBy,
          style: StyleText.fontSize14Weight600.copyWith(height: 1.3),
        ),
        SizedBox(height: 5.sp),
        Row(
          children: [
            Container(
              width: 410.sp,
              padding: EdgeInsets.all(4.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.sp),
              ),
              child: Row(
                children: [
                  _creatorAvatar(image),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Text(
                      FormatHelper.capitalize(name),
                      style: StyleText.fontSize12Weight400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ..._messageCreator(410.sp),
      ],
    );
  }

  mobileInformation() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // ✅ FIXED: Use firstWhereOrNull to handle missing employees gracefully
    // Lookup moved to RoleCubit.employeeByEmail — `firstWhereOrNull` came from
    // `package:get`, which is banned and no longer imported here.
    var creatorEmployee =
        controller.employeeByEmail(controller.selectedRole!.currentCreatedBy);

    // ✅ FIXED: Provide fallback values if employee not found
    String image = creatorEmployee != null
        ? EmployeeHelper.getEmployeeImage(employee: creatorEmployee)
        : _defaultAvatarAsset;

    String name = creatorEmployee != null
        ? EmployeeHelper.getEmployeeLocalizedName(
        employee: creatorEmployee, context: context)
        : controller.selectedRole!.currentCreatedBy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            roleImage(50.sp),
            SizedBox(width: 10.sp),
            Container(
              height: 50.sp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    !isArabic ?
                    FormatHelper.capitalize(controller.selectedRole!.currentRoleName) :
                    FormatHelper.capitalize(controller.selectedRole!.currentRoleNameAr),
                    style: StyleText.fontSize16Weight600,
                  ),
                  CustomTitleValueWidget(
                    title: "${S.of(context).creationDate}: ",
                    value: _creationDate(),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10.sp),
        CustomTitleValueWidget(
            value:      ! isArabic ?  controller.selectedRole!.currentRoleDescription:
            controller.selectedRole!.currentRoleDescriptionAr,
            title: "${S.of(context).role_description}: "),

        SizedBox(height: 10.sp),
        Text(
          S.of(context).createdBy,
          style: StyleText.fontSize10Weight400.copyWith(
              color: Theme.of(context).brightness == Brightness.light ? AppColors.blackButton:AppColors.white
          ),
        ),
        SizedBox(height: 10.sp),
        SizedBox(height: 5.sp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.sp),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(4.sp),
          ),
          child: Row(
            children: [
              _creatorAvatar(image),
              SizedBox(width: 10.sp),
              Expanded(
                child: Text(
                  // Role QA p.8 (same rule): names are shown capitalised.
                  FormatHelper.capitalize(name),
                  style: StyleText.fontSize12Weight400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        ..._messageCreator(double.infinity),
      ],
    );
  }

  /// "Message" button under Created By — opens the one-to-one chat with the
  /// role's creator. ADDED 30/9/2026 (Role QA p.26). Hidden when the creator is
  /// the signed-in user (you cannot message yourself).
  List<Widget> _messageCreator(double width) {
    final String creatorEmail = controller.selectedRole!.currentCreatedBy;
    final String? me = AppControllers.employee.employeeEntity?.email;
    if (creatorEmail.isEmpty ||
        !creatorEmail.contains('@') ||
        (me != null && me.toLowerCase() == creatorEmail.toLowerCase())) {
      return const <Widget>[];
    }
    return [
      SizedBox(height: 10.sp),
      SizedBox(
        width: width,
        child: customButtonWithSvg(
          title: S.of(context).message,
          function: () => _openChatWithCreator(creatorEmail),
          color: AppColors.primary,
          space: 8.sp,
          heightImage: 20.sp,
          widthImage: 20.sp,
          colorBorder: AppColors.transparent,
          image: 'assets/icons_assets/roles_assets/chat_messages_bubbles.svg',
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.textButton),
        ),
      ),
    ];
  }

  Future<void> _openChatWithCreator(String creatorEmail) async {
    // Same pattern as the request page's Message button: the spinner closes
    // right before the chat is pushed, not when the chat is closed again.
    showLoadingIndicator();
    bool loading = true;
    void stopLoading() {
      if (!loading) return;
      loading = false;
      hideLoadingIndicator();
    }

    final OpenChatResult result =
        await MessagingInterfaceImplementation().tryOpenChatWithUser(
      context: context,
      userEmail: creatorEmail,
      beforeNavigate: stopLoading,
    );
    stopLoading();
    if (mounted) await showOpenChatFailure(context, result);
  }

  /// The role's creation date, with the locale's own month names and numerals.
  ///
  /// FIXED 29/8/2026 — `DateFormat('dd MMM yyyy', 'ar')` gives Arabic MONTH
  /// names but Latin digits ("29 أغسطس 2026"), so an Arabic screen mixed the
  /// two numbering systems. [LocalizedDate] owns that fix for every screen; see
  /// its file for why the digits are mapped rather than trusted from intl.
  String _creationDate() => LocalizedDate.of(
        context,
        controller.selectedRole!.currentCreatedAt.toDate(),
      );

  /// The creator's avatar, in a plain circle.
  ///
  /// FIXED 29/8/2026 — this was a [CircleAvatar] wrapping [Image.asset], and
  /// [EmployeeHelper.getEmployeeImage] returns `male_avatar.svg` /
  /// `female_avatar.svg` for an employee with no photo. `Image.asset` cannot
  /// decode SVG, so every photo-less creator threw straight into the
  /// errorBuilder and rendered a person glyph on CircleAvatar's default yellow
  /// disc. SVG paths now go through [CustomSvgImage], and the circle carries no
  /// background of its own.
  Widget _creatorAvatar(String image) {
    final double diameter = 30.sp; // was CircleAvatar(radius: 15.sp)

    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: image.contains('http')
            ? Image.network(
                image,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _avatarFallback(diameter),
              )
            : (image.toLowerCase().endsWith('.svg')
                ? CustomSvgImage(
                    assetPath: image,
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    image,
                    width: diameter,
                    height: diameter,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _avatarFallback(diameter),
                  )),
      ),
    );
  }

  /// The last resort when no image of any kind loads.
  Widget _avatarFallback(double diameter) => CustomSvgImage(
        assetPath: _defaultAvatarAsset,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
      );

  Widget roleImage(double imageSize) {
    if (controller.selectedRole!.currentRoleImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.sp),
        child: Image.network(
          controller.selectedRole!.currentRoleImage,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // ✅ FIXED: Handle image loading errors
            return Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              width: imageSize,
              height: imageSize,
              child: CustomSvgImage(assetPath: 
                'assets/icons_assets/roles_assets/roles_people_gear.svg',
                width: imageSize - 20.sp,
                height: imageSize - 20.sp,
                color: AppColors.text,
              ),
            );
          },
        ),
      );
    }
    return Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        width: imageSize,
        height: imageSize,
        child: CustomSvgImage(assetPath: 
          'assets/icons_assets/roles_assets/roles_people_gear.svg',
          width: imageSize - 20.sp,
          height: imageSize - 20.sp,
          color: AppColors.text,
        ));
  }
}