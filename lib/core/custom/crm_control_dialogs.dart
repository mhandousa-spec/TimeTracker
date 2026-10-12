// ****************** FILE INFO ******************
// File Name: crm_control_dialogs.dart
// Purpose: Reusable custom dialogs for CRM Controls (Remove, Save, and Success)
// Author: Mohand Adel
// Created At: 04/08/2026

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/helper/role/validator.dart';
import 'package:knowticed_plus/generated/l10n.dart';

abstract class CrmControlDialogs {
  static Future<bool> showBlacklistConfirmationDialog({
    required BuildContext context,
    required bool isRemoval,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.sp),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.sp),
          child: SizedBox(
            width: 380.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomSvgImage(
                      assetPath: AppAssets.crmBlacklist,
                      width: 36.sp,
                      height: 36.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.sp),
                    Text(
                      isRemoval ? 'Remove from Blacklist' : 'Add to Blacklist',
                      style: StyleText.fontSize18Weight600.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.sp),
                Text(
                  isRemoval
                      ? 'Are you sure to remove this client from blacklist?'
                      : 'Are you sure to add this client to blacklist?',
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 28.sp),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: customButton(
                        title: 'Cancel',
                        function: () => Navigator.of(dialogContext).pop(false),
                        color: AppColors.background,
                        textColor: AppColors.black,
                        textStyle: StyleText.fontSize16Weight600,
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: customButton(
                        title: isRemoval ? 'Remove' : 'Add',
                        function: () => Navigator.of(dialogContext).pop(true),
                        color: AppColors.primary,
                        textColor: AppColors.black,
                        textStyle: StyleText.fontSize16Weight600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }

  static Future<String?> showBlacklistReasonDialog({
    required BuildContext context,
    required bool isRemoval,
  }) async {
    final TextEditingController controller = TextEditingController();
    String? errorText;
    final String? reason = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomSvgImage(
                        assetPath: AppAssets.crmBlacklist,
                        width: 36.sp,
                        height: 36.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        isRemoval
                            ? 'Remove from Blacklist'
                            : 'Add to Blacklist',
                        style: StyleText.fontSize18Weight600.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.sp),
                  Text('Reason', style: StyleText.fontSize14Weight500),
                  SizedBox(height: 8.sp),
                  CustomTextField(
                    controller: controller,
                    hint: 'Text here',
                    maxLines: 4,
                    maxLength: 500,
                    errorText: errorText,
                  ),
                  SizedBox(height: 24.sp),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: customButton(
                          title: 'Cancel',
                          function: () => Navigator.of(dialogContext).pop(),
                          color: AppColors.background,
                          textColor: AppColors.black,
                          textStyle: StyleText.fontSize16Weight600,
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: customButton(
                          title: 'Send Request',
                          function: () {
                            final String value = controller.text.trim();
                            if (value.isEmpty) {
                              setDialogState(
                                  () => errorText = 'Reason is required');
                              return;
                            }
                            Navigator.of(dialogContext).pop(value);
                          },
                          color: AppColors.primary,
                          textColor: AppColors.black,
                          textStyle: StyleText.fontSize16Weight600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    return reason;
  }

  /// Shows Success Dialog with illustration (Screenshot 3 & 4)
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    VoidCallback? onComplete,
  }) async {
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        dialogContext = ctx;
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CustomSvgImage(
                    assetPath: AppAssets.crmSuccessfulSvgDialog,
                    width: 220.sp,
                    height: 160.sp,
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    if (dialogContext != null &&
        dialogContext!.mounted &&
        Navigator.canPop(dialogContext!)) {
      Navigator.pop(dialogContext!);
    }
    onComplete?.call();
  }

  /// Shows Custom Error / Alert Dialog (No SnackBar)
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CustomSvgImage(
                    assetPath: AppAssets.minusCircle,
                    width: 48.sp,
                    height: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  customButton(
                    title: Localizations.localeOf(context).languageCode == 'ar'
                        ? 'حسناً'
                        : 'OK',
                    function: () => Navigator.of(ctx).pop(),
                    color: AppColors.primary,
                    textColor: AppColors.black,
                    width: 110.sp,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows Remove Field / Type Confirmation Dialog (Screenshot 1)
  static Future<void> showRemoveDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 380.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath: AppAssets.crmTrush,
                        width: 24.sp,
                        height: 24.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        title,
                        style: StyleText.fontSize18Weight600.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmDiscard,
                          function: () => Navigator.pop(ctx),
                          textStyle:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          color: AppColors.grey,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmRemove,
                          function: () {
                            Navigator.pop(ctx);
                            onConfirm();
                          },
                          textStyle:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows Save Changes Confirmation Dialog (Screenshot 2)
  static Future<void> showSaveDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required FutureOr<void> Function() onConfirm,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 400.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize18Weight600.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomSvgImage(
                    assetPath: AppAssets.crmSaveSvgDialog,
                    width: 220.sp,
                    height: 160.sp,
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmDiscard,
                          function: () => Navigator.pop(ctx),
                          textStyle:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          color: AppColors.grey,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: customButtonWithSvg(
                          title: S.current.crmSave,
                          function: () async {
                            Navigator.pop(ctx);
                            await onConfirm();
                          },
                          textStyle:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> showChangeStatusDialog({
    required BuildContext context,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: SizedBox(
              width: 400.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSvgImage(
                        assetPath: AppAssets.crmStatus,
                        width: 28.sp,
                        height: 28.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.sp),
                      Text(
                        'Change Status',
                        style: StyleText.fontSize18Weight600.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.sp),
                  Text(
                    'Are you sure to change this status?',
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 24.sp),
                  Row(
                    children: [
                      Expanded(
                        child: customButtonWithSvg(
                          title: 'Cancel',
                          function: () => Navigator.pop(ctx),
                          textStyle:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          color: AppColors.grey,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Expanded(
                        child: customButtonWithSvg(
                          title: 'Change',
                          function: () {
                            Navigator.pop(ctx);
                            onConfirm();
                          },
                          textStyle:
                              StyleText.fontSize14Weight600.copyWith(
                            color: AppColors.black,
                          ),
                          color: AppColors.primary,
                          colorBorder: AppColors.transparent,
                          image: '',
                          widthImage: 0,
                          heightImage: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows Add/Create Template Dialog
  static Future<void> showAddTemplateDialog({
    required BuildContext context,
    required void Function(String nameEn, String nameAr) onConfirm,
  }) async {
    final TextEditingController nameEnController = TextEditingController();
    final TextEditingController nameArController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String? nameEnError;
        String? nameArError;

        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final String enCurrent = nameEnController.text.trim();
              final String arCurrent = nameArController.text.trim();
              final bool canAdd = enCurrent.isNotEmpty &&
                  arCurrent.isNotEmpty &&
                  nameEnError == null &&
                  nameArError == null;

              return Container(
                constraints: BoxConstraints(maxWidth: 440.sp),
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.crmTemplate,
                          width: 24.sp,
                          height: 24.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add Template',
                          style:
                              StyleText.fontSize18Weight600.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Template Name',
                      style: StyleText.fontSize12Weight500.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: nameEnController,
                      hint: 'Text Here',
                      errorText: nameEnError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          final dynamic res = Validator.isEnglish(text);
                          if (res is String) err = res;
                        }
                        setState(() => nameEnError = err);
                      },
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اسم القالب',
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CustomTextField(
                      controller: nameArController,
                      hint: 'اكتب هنا',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      errorText: nameArError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          err = Validator.isArabic(
                            text,
                            'الحقل مطلوب',
                            'يرجى إدخال النص باللغة العربية',
                          );
                        }
                        setState(() => nameArError = err);
                      },
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmDiscard,
                              function: () => Navigator.pop(ctx),
                              color: AppColors.grey,
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmAdd,
                              function: canAdd
                                  ? () {
                                      final String enText =
                                          nameEnController.text.trim();
                                      final String arText =
                                          nameArController.text.trim();

                                      String? enErr;
                                      if (enText.isEmpty) {
                                        enErr = 'Field Required';
                                      } else {
                                        final dynamic res =
                                            Validator.isEnglish(enText);
                                        if (res is String) enErr = res;
                                      }

                                      final String? arErr = Validator.isArabic(
                                        arText,
                                        'الحقل مطلوب',
                                        'يرجى إدخال النص باللغة العربية',
                                      );

                                      if (enErr != null || arErr != null) {
                                        setState(() {
                                          nameEnError = enErr;
                                          nameArError = arErr;
                                        });
                                      } else {
                                        Navigator.pop(ctx);
                                        onConfirm(enText, arText);
                                      }
                                    }
                                  : () {},
                              color: canAdd
                                  ? AppColors.primary
                                  : AppColors.disabledGrey,
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: canAdd
                                    ? AppColors.black
                                    : AppColors.darkGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameEnController.dispose();
    nameArController.dispose();
  }

  static Future<void> showEditTemplateDialog({
    required BuildContext context,
    required String nameEn,
    required String nameAr,
    required void Function(String nameEn, String nameAr) onConfirm,
  }) async {
    final TextEditingController nameEnController =
        TextEditingController(text: nameEn);
    final TextEditingController nameArController =
        TextEditingController(text: nameAr);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        String? nameEnError;
        String? nameArError;
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final String enCurrent = nameEnController.text.trim();
              final String arCurrent = nameArController.text.trim();
              final bool hasChanged =
                  enCurrent != nameEn.trim() || arCurrent != nameAr.trim();
              final bool canSave = enCurrent.isNotEmpty &&
                  arCurrent.isNotEmpty &&
                  hasChanged &&
                  nameEnError == null &&
                  nameArError == null;

              return Container(
                constraints: BoxConstraints(maxWidth: 440.sp),
                padding: EdgeInsets.all(20.sp),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomSvgImage(
                          assetPath: AppAssets.crmTemplate,
                          width: 28.sp,
                          height: 28.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.sp),
                        Text(
                          'Edit Template',
                          style:
                              StyleText.fontSize18Weight600.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.sp),
                    Text(
                      'Template Name',
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    CustomTextField(
                      controller: nameEnController,
                      hint: 'Text Here',
                      errorText: nameEnError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          final dynamic res = Validator.isEnglish(text);
                          if (res is String) err = res;
                        }
                        setState(() => nameEnError = err);
                      },
                    ),
                    SizedBox(height: 16.sp),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اسم القالب',
                        style: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    CustomTextField(
                      controller: nameArController,
                      hint: 'اكتب هنا',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      errorText: nameArError,
                      onChanged: (val) {
                        final String text = val.trim();
                        String? err;
                        if (text.isNotEmpty) {
                          err = Validator.isArabic(
                            text,
                            'الحقل مطلوب',
                            'يرجى إدخال النص باللغة العربية',
                          );
                        }
                        setState(() => nameArError = err);
                      },
                    ),
                    SizedBox(height: 28.sp),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmDiscard,
                              function: () => Navigator.pop(ctx),
                              color: AppColors.grey,
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(color: AppColors.black),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: SizedBox(
                            height: 38.sp,
                            child: customButton(
                              title: S.current.crmSave,
                              function: canSave
                                  ? () {
                                      final String enText =
                                          nameEnController.text.trim();
                                      final String arText =
                                          nameArController.text.trim();
                                      String? enErr;
                                      if (enText.isEmpty) {
                                        enErr = 'Field Required';
                                      } else {
                                        final dynamic res =
                                            Validator.isEnglish(enText);
                                        if (res is String) enErr = res;
                                      }

                                      final String? arErr = Validator.isArabic(
                                        arText,
                                        'الحقل مطلوب',
                                        'يرجى إدخال النص باللغة العربية',
                                      );

                                      if (enErr != null || arErr != null) {
                                        setState(() {
                                          nameEnError = enErr;
                                          nameArError = arErr;
                                        });
                                        return;
                                      }
                                      Navigator.pop(ctx);
                                      onConfirm(enText, arText);
                                    }
                                  : () {},
                              color: canSave
                                  ? AppColors.primary
                                  : AppColors.disabledGrey,
                              textStyle: StyleText.fontSize14Weight600
                                  .copyWith(
                                color: canSave
                                    ? AppColors.black
                                    : AppColors.darkGrey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    nameEnController.dispose();
    nameArController.dispose();
  }
}
