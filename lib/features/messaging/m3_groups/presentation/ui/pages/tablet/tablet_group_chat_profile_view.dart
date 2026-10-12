/// Module: messaging / groups / presentation/ui/pages/tablet/tablet_group_chat_profile_view.dart
/// ************************* FILE INFO *************************** ///
/// File Name: tablet_group_chat_profile_view.dart
/// Purpose: Tablet group chat profile view — messaging Groups sub-feature.
/// Author: Knowticed Team
/// Created At: 11/10/2025

// Date: 22/9/2024
// By: Mohamed Ashraf
// Last update: 01/5/2026
// Objectives: This file is responsible for providing a chat profile view used in the message feature to show the group chat profile.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/84-messaging_custom_button.dart';
import 'package:knowticed_plus/core/helper/main_helper/pagination_app_bar.dart';

import 'package:knowticed_plus/features/messaging/m2_connections/presentation/controller/connections_controller.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/presentation/controller/groups_controller.dart';
import 'package:knowticed_plus/features/messaging/m4_messaging_home/presentation/controller/messaging_home_controller.dart';

import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/constants/message_module/app_assets.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/localized_text_helper.dart';
import 'package:knowticed_plus/core/helper/main_helper/spacing_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


import '../../widgets/switch_button/switch_button_title.dart';
import '../../widgets/switch_button/switch_button_title_subTitle.dart';
import '../../widgets/list_view/group_members_list_view.dart';
import '../../widgets/department_dropdown.dart';
import '../../widgets/group_image_editor.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';

part './tablet_group_chat_profile_view.sections.dart';


/// Regex: matches Arabic letters, Arabic digits, spaces, and common punctuation
final _arabicRegex = RegExp(
  r'^[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF'
  r'0-9\u0660-\u0669'
  r'\s'
  r'.,!?؟،؛:()\-'
  r']*$',
);

/// Returns true if [text] contains any Arabic character
bool _containsArabic(String text) {
  return RegExp(
    r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
  ).hasMatch(text);
}

/// Returns true if [text] contains any English/Latin character
bool _containsEnglish(String text) {
  return RegExp(r'[a-zA-Z]').hasMatch(text);
}

/// Allows only Arabic letters, Arabic numbers, spaces, and common punctuation
class ArabicOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
    ) {
    if (_arabicRegex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

class TabletGroupChatProfileView extends StatefulWidget {
  const TabletGroupChatProfileView({super.key});

  @override
  State<TabletGroupChatProfileView> createState() =>
      _TabletGroupChatProfileViewState();
}

class _TabletGroupChatProfileViewState
    extends State<TabletGroupChatProfileView> with _TabletGroupChatProfileSections {
  // ---- fields & helpers moved to _TabletGroupChatProfileSections (tablet_group_chat_profile_view.sections.dart) ----


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsCubit>().initGroupProfileController();
      _validateForm(context.read<GroupsCubit>());
    });
  }




  Widget build(BuildContext context) {
    final isTablet = ContextExtension(context).isTablet;
    final isAr = context.isArabic;
    final isPhone = ContextExtension(context).isPhone;

    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: isTablet ? 24.w : 16.w),
            child: BlocBuilder<GroupsCubit, GroupsState>(
              builder: (context, state) {
                final controller = context.read<GroupsCubit>();

                if (controller.selectedGroup == null) {
                  return Center(
                    child: Text(
                      isAr ? 'لم يتم اختيار مجموعة' : 'No group selected'),
                  );
                }

                // Re-check validity on every rebuild
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _validateForm(controller);
                });

                bool isCurrentUserAdmin = controller
                    .selectedGroup!.members
                    .where((element) {
                  if (element.memberId == controller.currentUser.userId) {
                    return element.isAdmin;
                  }
                  return false;
                })
                    .toList()
                    .isNotEmpty;

                final groupDisplayName =
                _buildAppBarGroupName(controller, isAr);

                final pageTitlePrefix = isCurrentUserAdmin
                    // Bug report p.18: "Editing", like "Editing Role" in Roles.
                    ? (isAr ? 'تعديل' : 'Editing')
                    : (isAr ? 'تفاصيل المجموعة' : 'Group Details');

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaginationAppBar(
                      screensTitles: [
                        isAr ? 'الرسائل' : 'Messages',
                        '$pageTitlePrefix $groupDisplayName',
                      ],
                    ),
                    if (isCurrentUserAdmin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          customButtonWithSvg(
                            color: AppColors.red,
                            image: AppAssets.trash,
                            svgColor: AppColors.white,
                            textStyle: StyleText.fontSize14Weight600
                                .copyWith(color: AppColors.white),
                            title: isAr ? 'حذف' : 'Delete',
                            function: () {
                              CustomDialogManager.showDialogFlow(
                                context: context,
                                confirmWidth: 411, // narrower confirm dialog (bug report #7)
                                confirmLottie: 'assets/lottie_assets/main_lottie_assets/assets_lottie_trash.json',
                                confirmTitle:
                                isAr ? 'حذف المجموعة' : 'Deleting Group',
                                confirmSubtitle: isAr
                                    ? 'هل أنت متأكد من حذف هذه المجموعة؟'
                                    : 'Are You Sure You Want To Delete This Group?',
                                confirmYesText: isAr ? 'نعم' : 'Yes',
                                confirmNoText: isAr ? 'لا' : 'No',
                                onConfirm: () async {
                                  controller.deleteGroup();
                                  return true;
                                },
                                successLottie:
                                'assets/lottie_assets/main_lottie_assets/assets_lottie_successful.json',
                                successTitle: isAr
                                    ? 'تم الحذف بنجاح'
                                    : 'Deleted Successfully',
                                successSubtitle: isAr
                                    ? 'تم حذف المجموعة بنجاح'
                                    : 'The Group Has Been Deleted Successfully',
                                onSuccessDismissed: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                            colorBorder: AppColors.red,
                            widthImage: 20.sp,
                            heightImage: 20.sp,
                            space: 10.sp,
                          )
                        ],
                      ),
                    if (isCurrentUserAdmin) verticalSpace(16),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GroupImageEditor(),
                                verticalSpace(16),

                                // ── Group Name EN + AR ──────────────────────
                                if (isPhone) ...[
                                  // Mobile: each field on its own row
                                  if (isAr) ...[
                                    _buildArField(
                                      label: 'اسم المجموعة',
                                      controller:
                                      controller.groupNameArController,
                                      hintText: 'أدخل هنا',
                                      maxLength: 100,
                                      validationLabel: 'اسم المجموعة',
                                      cubit: controller,
                                      langError: _nameArLangError,
                                      height: 36,
                                    ),
                                    verticalSpace(8),
                                    _buildEnField(
                                      label: 'Group Name',
                                      controller:
                                      controller.groupNameController,
                                      hintText: 'Text Here',
                                      maxLength: 100,
                                      validationLabel: 'Group Name',
                                      cubit: controller,
                                      langError: _nameEnLangError,
                                      height: 36,
                                    ),
                                  ] else ...[
                                    _buildEnField(
                                      label: 'Group Name',
                                      controller:
                                      controller.groupNameController,
                                      hintText: 'Text Here',
                                      maxLength: 100,
                                      validationLabel: 'Group Name',
                                      cubit: controller,
                                      langError: _nameEnLangError,
                                      height: 36,
                                    ),
                                    verticalSpace(8),
                                    _buildArField(
                                      label: 'اسم المجموعة',
                                      controller:
                                      controller.groupNameArController,
                                      hintText: 'أدخل هنا',
                                      maxLength: 100,
                                      validationLabel: 'اسم المجموعة',
                                      cubit: controller,
                                      langError: _nameArLangError,
                                      height: 36,
                                    ),
                                  ],
                                ] else ...[
                                  // Tablet: side by side in a Row
                                  isAr
                                      ? Row(
                                    // Top-aligned so an error under one field can't push its
                                    // neighbour down — both boxes stay on one line.
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 12.w,
                                    children: [
                                      Expanded(
                                        child: _buildArField(
                                          label: 'اسم المجموعة',
                                          controller: controller
                                              .groupNameArController,
                                          hintText: 'أدخل هنا',
                                          maxLength: 100,
                                          validationLabel:
                                          'اسم المجموعة',
                                          cubit: controller,
                                          langError: _nameArLangError,
                                          height: 36,
                                          isInRow: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildEnField(
                                          label: 'Group Name',
                                          controller: controller
                                              .groupNameController,
                                          hintText: 'Text Here',
                                          maxLength: 100,
                                          validationLabel: 'Group Name',
                                          cubit: controller,
                                          langError: _nameEnLangError,
                                          height: 36,
                                          isInRow: true,
                                        ),
                                      ),
                                    ],
                                  )
                                      : Row(
                                    // Top-aligned so an error under one field can't push its
                                    // neighbour down — both boxes stay on one line.
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 12.w,
                                    children: [
                                      Expanded(
                                        child: _buildEnField(
                                          label: 'Group Name',
                                          controller: controller
                                              .groupNameController,
                                          hintText: 'Text Here',
                                          maxLength: 100,
                                          validationLabel: 'Group Name',
                                          cubit: controller,
                                          langError: _nameEnLangError,
                                          height: 36,
                                          isInRow: true,
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildArField(
                                          label: 'اسم المجموعة',
                                          controller: controller
                                              .groupNameArController,
                                          hintText: 'أدخل هنا',
                                          maxLength: 100,
                                          validationLabel:
                                          'اسم المجموعة',
                                          cubit: controller,
                                          langError: _nameArLangError,
                                          height: 36,
                                          isInRow: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                verticalSpace(8),

                                // ── Description (order respects locale) ──
                                if (isAr) ...[
                                  _buildArField(
                                    label: 'الوصف',
                                    controller:
                                    controller.groupDescriptionArController,
                                    hintText: 'اكتب هنا',
                                    maxLength: 500,
                                    validationLabel: 'الوصف',
                                    cubit: controller,
                                    langError: _descArLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                  verticalSpace(8),
                                  _buildEnField(
                                    label: 'Description',
                                    controller:
                                    controller.groupDescriptionController,
                                    hintText: 'Text Here',
                                    maxLength: 500,
                                    validationLabel: 'Description',
                                    cubit: controller,
                                    langError: _descEnLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                ] else ...[
                                  _buildEnField(
                                    label: 'Description',
                                    controller:
                                    controller.groupDescriptionController,
                                    hintText: 'Text Here',
                                    maxLength: 500,
                                    validationLabel: 'Description',
                                    cubit: controller,
                                    langError: _descEnLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                  verticalSpace(8),
                                  _buildArField(
                                    label: 'الوصف',
                                    controller:
                                    controller.groupDescriptionArController,
                                    hintText: 'اكتب هنا',
                                    maxLength: 500,
                                    validationLabel: 'الوصف',
                                    cubit: controller,
                                    langError: _descArLangError,
                                    maxLines: 3,
                                    showCounter: true,
                                  ),
                                ],

                                verticalSpace(16),

                                // ── Toggles (matching CreateGroupPageTablet style) ──
                                if (isCurrentUserAdmin)
                                  isPhone
                                      ? Column(
                                    children: [
                                      SwitchButtonTitleSubTitle(
                                        title:
                                        isAr ? 'خاص' : 'Private',
                                        subTitle: isAr
                                            ? 'يسمح للمستخدمين بالعرض أو المشاركة بدعوة'
                                            : 'Allows Users To Either View Or Participate By Joining With An Invitation',
                                        value: controller
                                            .isMakePrivateEnabled,
                                        onChanged: controller
                                            .onChangedMakePrivate,
                                      ),
                                      verticalSpace(8),
                                      SwitchButtonTitleSubTitle(
                                        title: isAr
                                            ? 'المشرفين فقط'
                                            : 'Admin Only',
                                        subTitle: isAr
                                            ? 'فقط المشرفون يمكنهم مشاركة المحتوى'
                                            : 'Only Admins Can Share Content',
                                        value:
                                        controller.isAdminEnabled,
                                        onChanged:
                                        controller.onChangedAdmin,
                                      ),
                                      verticalSpace(8),
                                      SwitchButtonTitle(
                                        title: isAr
                                            ? 'الرسائل المختفية'
                                            : 'Disappearing messages',
                                        value: controller
                                            .isDisappearingMessagesEnabled,
                                        onChanged: controller
                                            .onChangedDisappearingMessages,
                                      ),
                                      verticalSpace(8),
                                      SwitchButtonTitle(
                                        title: isAr
                                            ? 'كتم الإشعارات'
                                            : 'Mute notifications',
                                        value:
                                        controller.isMuteEnabled,
                                        onChanged: controller
                                            .onChangMuteMessages,
                                      ),
                                    ],
                                  )
                                      : Column(
                                    children: [
                                      Row(
                                        spacing: 20.sp,
                                        children: [
                                          Expanded(
                                            child:
                                            SwitchButtonTitleSubTitle(
                                              title: isAr
                                                  ? 'خاص'
                                                  : 'Private',
                                              subTitle: isAr
                                                  ? 'يسمح للمستخدمين بالعرض أو المشاركة بدعوة'
                                                  : 'Allows Users To Either View Or Participate By Joining With An Invitation',
                                              value: controller
                                                  .isMakePrivateEnabled,
                                              onChanged: controller
                                                  .onChangedMakePrivate,
                                            ),
                                          ),
                                          Expanded(
                                            child: SwitchButtonTitle(
                                              title: isAr
                                                  ? 'الرسائل المختفية'
                                                  : 'Disappearing messages',
                                              value: controller
                                                  .isDisappearingMessagesEnabled,
                                              onChanged: controller
                                                  .onChangedDisappearingMessages,
                                            ),
                                          ),
                                        ],
                                      ),
                                      verticalSpace(8),
                                      Row(
                                        spacing: 20.sp,
                                        children: [
                                          Expanded(
                                            child:
                                            SwitchButtonTitleSubTitle(
                                              title: isAr
                                                  ? 'المشرفين فقط'
                                                  : 'Admin Only',
                                              subTitle: isAr
                                                  ? 'فقط المشرفون يمكنهم مشاركة المحتوى'
                                                  : 'Only Admins Can Share Content',
                                              value: controller
                                                  .isAdminEnabled,
                                              onChanged: controller
                                                  .onChangedAdmin,
                                            ),
                                          ),
                                          Expanded(
                                            child: SwitchButtonTitle(
                                              title: isAr
                                                  ? 'كتم الإشعارات'
                                                  : 'Mute notifications',
                                              value: controller
                                                  .isMuteEnabled,
                                              onChanged: controller
                                                  .onChangMuteMessages,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                verticalSpace(16),

                                // ── Add Member / Members ────────────────────────
                                Text(
                                  (isCurrentUserAdmin)
                                      ? (isAr ? 'إضافة عضو' : 'Add Member')
                                      : (isAr ? 'الأعضاء' : 'Members'),
                                  style: ContextExtension(context).isTablett
                                      ? StyleText.fontSize16Weight500
                                      : StyleText.fontSize14Weight600,
                                ),
                                verticalSpace(8),
                                Row(
                                  children: [
                                    Flexible(
                                      child: AppSearchTextField(
                                        onChanged: (value) {
                                          final connectionsCubit =
                                          context.read<ConnectionsCubit>();
                                          final homeCubit =
                                          context.read<MessagingHomeCubit>();
                                          controller.searchMembersToAddToGroup(
                                            value.trim(),
                                            connectionsCubit,
                                            homeCubit,
                                          );
                                        },
                                        fillColor: AppColors.background,
                                        controller: controller.membersSearchTextField,
                                      ),
                                    ),
                                    horizontalSpace(8),
                                    DepartmentDropdown(),
                                  ],
                                ),
                                verticalSpace(6),
                                GroupMembersListView(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    verticalSpace(8),
                    if (isCurrentUserAdmin)
                      Row(
                        children: [
                          customButton(
                            color:
                            Theme.of(context).brightness == Brightness.light
                                ? AppColors.colorGrey
                                : AppColors.colorGreyDark,
                            title: isAr ? 'تجاهل التغييرات' : 'Discard Changes',
                            textStyle: StyleText.fontSize14Weight500
                                .copyWith(
                              color: Theme.of(context).brightness ==
                                  Brightness.light
                                  ? AppColors.colorBlack
                                  : AppColors.colorWhite,
                            ),
                            function: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          Opacity(
                            opacity: _isFormValid ? 1.0 : 0.5,
                            child: IgnorePointer(
                              ignoring: !_isFormValid,
                              child: customButton(
                                title: isAr ? 'حفظ' : 'Save',
                                function: () {
                                  setState(() {
                                    _submitted = true;
                                  });
                                  if (_isFormValid) {
                                    CustomDialogManager.showDialogFlow(
                                      context: context,
                                      confirmWidth: 411, // narrower confirm dialog (bug report #7)
                                      confirmLottie:
                                      'assets/lottie_assets/main_lottie_assets/assets_lottie_successful.json',
                                      confirmTitle: isAr
                                          ? 'حفظ التعديلات'
                                          : 'Saving Changes',
                                      confirmSubtitle: isAr
                                          ? 'هل أنت متأكد من حفظ التعديلات على هذه المجموعة؟'
                                          : 'Are You Sure You Want To Save Changes To This Group?',
                                      confirmYesText: isAr ? 'نعم' : 'Yes',
                                      confirmNoText: isAr ? 'لا' : 'No',
                                      onConfirm: () async {
                                        controller.updateGroupData();
                                        return true;
                                      },
                                      successLottie:
                                      'assets/lottie_assets/main_lottie_assets/assets_lottie_successful.json',
                                      successTitle: isAr
                                          ? 'تم الحفظ بنجاح'
                                          : 'Saved Successfully',
                                      successSubtitle: isAr
                                          ? 'تم تحديث بيانات المجموعة بنجاح'
                                          : 'The Group Data Has Been Updated Successfully',
                                      onSuccessDismissed: () {
                                        Navigator.of(context).pop();
                                      },
                                    );
                                  }
                                },
                                     ),
                            ),
                          ),
                        ],
                      ),
                    verticalSpace(16),
                  ],
                );
              },
            ),
          ),
      ),
    );
  }
}
