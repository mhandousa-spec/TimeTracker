/// Module: form_builder_module/core
///
/// FILE INFO
/// File Name   : app_dialogs.dart
/// Objective   : Public entry point for the form-builder dialogs. Holds the
///               small confirm/success dialogs directly and delegates the
///               large summary/share/filter dialogs to their own files
///               (one file per dialog, §7). Contains NO try/catch — error
///               handling lives in the cubits the dialogs render (§11.2).
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_head_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/presentation/controller/create_form_data_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/presentation/controller/share_cubit.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/helper/main_helper/get_dialog_helper.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/77-default_dialog.dart';
import 'package:knowticed_plus/core/helper/form_builder/share_access_dialog.dart';
import 'package:knowticed_plus/core/helper/form_builder/summary_open_access_dialog.dart';
import 'package:knowticed_plus/core/helper/form_builder/summary_restricted_access_dialog.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/form_builder/form_filter_dialog.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
class AppDialogs {
  // Private constructor to prevent instantiation
  AppDialogs._();

  /// Method to show a dialog for creating a form
  static creatingForm(BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).creatingForm,
        subTitle: S.of(context).areYouSureCreateForm,
        autoClose: false,
        // Bug report #10: approved lottie instead of the static check svg.
        lottieAsset: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static void duplicateFormDialog(
    BuildContext context,
    String originalFormName,
    String originalArabicFormName,
    int duplicateVersion,
    dynamic Function(String newName, String newArabicName) onDuplicateClicked,
  ) {
    TextEditingController englishNameController = TextEditingController(
      text: '$originalFormName _$duplicateVersion',
    );

    TextEditingController arabicNameController = TextEditingController(
      text: '$originalArabicFormName _$duplicateVersion',
    );

    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        width: 615,
        customWidget: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 15,
                    child: SvgPicture.asset(AppAssets.add),
                  ),
                  horizontalSpace(8),
                  Text(
                    S.of(context).duplicateForm,
                    style: StyleText.fontSize16Weight500,
                  ),
                ],
              ),
              verticalSpace(20),
              Text(
                S.of(context).formName,
                style: StyleText.fontSize14Weight600,
              ),
              verticalSpace(8),
              CustomTextField(
        controller: englishNameController,
        label: S.of(context).englishName,
      ),
              verticalSpace(15),
              CustomTextField(
        controller: arabicNameController,
        label: S.of(context).arabicName,
      ),
              verticalSpace(25),
              // CHANGED: both buttons were `AppTextButton`. They are
              // `customButton` (core/custom/5) now, the same component every
              // other primary action in the app is built from, so this dialog
              // picks up ButtonSizing's height and radius and the app's own
              // haptic feedback instead of carrying its own 38/150/8.
              //
              // `width: 150` is kept — customButton honours an explicit width,
              // and the two buttons need to match each other across the row.
              // The text colour is NOT passed: customButton defaults to
              // AppColors.textButton, which is the contrast colour for the
              // theme, where the old `AppColors.black` was fixed and vanished
              // against a dark surface.
              Row(
                children: [
                  customButton(
                    title: S.of(context).cancel,
                    width: 150,
                    color: AppColors.grey,
                    function: () {
                      Get.back();
                    },
                  ),
                  const Spacer(),
                  customButton(
                    title: S.of(context).menuDuplicate,
                    width: 150,
                    color: AppColors.primary,
                    function: () {
                      String newEnglishName = englishNameController.text.trim();
                      String newArabicName = arabicNameController.text.trim();

                      if (newEnglishName.isEmpty) {
                        return;
                      }

                      Get.back();
                      onDuplicateClicked(newEnglishName, newArabicName);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        autoClose: false,
      ),
    );
  }

  static creatingFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).formCreated,
      subtitle: S.of(context).youSuccessfullyCreatedThisForm,
    );
  }

  static grantFormAccessSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).grantAccessSuccessfully,
      subtitle: S.of(context).youGrantAccessSuccessfully,
    );
  }

  static groupCreatedSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).groupCreatedSuccessfully,
      subtitle: S.of(context).youSuccessfullyCreatedGroup,
    );
  }

  /// Submit confirmation AND the success dialog, in one flow — the same shape
  /// as [deleteForm].
  ///
  /// ADDED 1/9/2026. [submittingForm] + [submittingFormSuccessfully] left the
  /// caller to pop the confirm dialog by hand and to decide for itself when the
  /// success dialog was due, which is how a submission that failed at the
  /// repository could still report success.
  /// `CustomDialogManager.showDialogFlow` owns both steps: it closes the
  /// confirm dialog, awaits [onConfirm], and shows the success dialog ONLY when
  /// that returns true. [onConfirm] must NOT pop anything itself — the confirm
  /// dialog is already gone by the time it runs. [onSuccessComplete] runs after
  /// the success dialog has auto-closed, which is where navigation belongs.
  static Future<void> submitForm(
    BuildContext context,
    Future<bool> Function() onConfirm, {
    VoidCallback? onSuccessComplete,
  }) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      // Bug report #17/#26: narrower submission dialog.
      confirmWidth: 411,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: S.of(context).submissionForm,
      confirmSubtitle: S.of(context).areYouSureSubmitForm,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: onConfirm,
      successLottie: AppAssets.successful,
      successTitle: S.of(context).submitForm,
      successSubtitle: S.of(context).youSuccessfullySubmittedThisForm,
      onSuccessComplete: onSuccessComplete,
    );
  }

  /// Failure counterpart of [submitForm]. Persistent (not auto-closing), so the
  /// reason the submission was rejected stays on screen until dismissed.
  static Future<void> submitFormFailed(BuildContext context, String message) {
    return CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.lottieWarning,
      title: S.of(context).errorOccurred,
      subtitle: message,
    );
  }

  /// DEPRECATED in favour of [submitForm], which pairs the confirm and success
  /// steps so they cannot disagree. Left in place for any caller still on it.
  static submittingForm(BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).submissionForm,
        subTitle: S.of(context).areYouSureSubmitForm,
        autoClose: false,
        svgAsset: AppAssets.success,
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static submittingFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).submitForm,
      subtitle: S.of(context).youSuccessfullySubmittedThisForm,
    );
  }

  static draftForm(BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).draftForm,
        subTitle: S.of(context).areYouSureDraftForm,
        autoClose: false,
        svgAsset: AppAssets.save,
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static draftingFormSuccessfully(BuildContext context) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).draftForm,
      subtitle: S.of(context).youSuccessfullyDraftedThisForm,
    );
  }

  /// Delete confirmation, and the success dialog that follows it.
  ///
  /// CHANGED: this was a `DefaultDialog` behind `GetDialogHelper.generalDialog`
  /// with five hardcoded English strings, and the success step was a SEPARATE
  /// method (`deletingFormSuccessfully`) that the cubit had to remember to call
  /// from inside its own success branch.
  ///
  /// `CustomDialogManager.showDialogFlow` owns both steps: it closes the
  /// confirm dialog, awaits [onConfirm], and shows the success dialog ONLY when
  /// that returns true — so a delete that fails at the repository can no longer
  /// report success. [onConfirm] must therefore return whether the delete
  /// actually happened, and must NOT pop anything itself; the flow has already
  /// closed the confirm dialog by the time it runs.
  ///
  /// Every string now comes from `S.of(context)`, so the dialog follows the app
  /// language instead of always being English.
  static Future<void> deleteForm(
    BuildContext context,
    Future<bool> Function() onConfirm,
  ) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: AppAssets.trash,
      confirmTitle: S.of(context).deleteForm,
      confirmSubtitle: S.of(context).areYouSureDeleteForm,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: onConfirm,
      successLottie: AppAssets.successful,
      successTitle: S.of(context).deletingForm,
      successSubtitle: S.of(context).youSuccessfullyDeletedThisForm,
    );
  }

  static editForm(BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).editingForm,
        subTitle: S.of(context).areYouSureEditForm,
        autoClose: false,
        lottieAsset:
            "assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json",
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static editingFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).editingForm,
      subtitle: S.of(context).youSuccessfullyEditedThisForm,
    );
  }

  static editingFormNotAllowed(BuildContext context) {
    CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).editingForm,
      subtitle: S.of(context).cantEditFormBecauseSubmitted,
    );
  }

  static editingGroupSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).editedGroup,
      subtitle: S.of(context).youSuccessfullyEditedGroup,
    );
  }

  static restoreForm(BuildContext context, dynamic Function() onYesClicked) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).restoreForm,
        subTitle: S.of(context).areYouSureRestoreForm,
        autoClose: false,
        customIconWidget: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.yellowColor,
          child: SvgPicture.asset(AppAssets.edit),
        ),
        showButtons: true,
        onConfirm: onYesClicked,
      ),
    );
  }

  static restoringFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).restoreForm,
      subtitle: S.of(context).youSuccessfullyRestoredThisForm,
    );
  }

  static duplicateFormSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).duplicatingForm,
      subtitle: S.of(context).youSuccessfullyDuplicatedThisForm,
    );
  }

  /// Filename prompt for the "download as PDF/Excel" flow.
  ///
  /// Delegates to [CustomDialogManager.showInput] (core/custom) rather than
  /// hand-rolling the field and button. The leading circular download icon is
  /// preserved and passed through as [leadingIcon].
  static downloadFile(
    TextEditingController controller,
    BuildContext context,
    dynamic Function() onDownloadClicked,
  ) {
    CustomDialogManager.showInput(
      context: context,
      controller: controller,
      // 360 rather than showInput's 500 default: a single filename field does
      // not need half the screen. Raw design number — showInput scales it in
      // .sp, so do not pass 360.sp here.
      width: 360,
      title: S.of(context).downloadForm,
      fieldLabel: S.of(context).fileName,
      confirmText: S.of(context).download,
      onConfirm: () => onDownloadClicked(),
      leadingIcon: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
        child: SvgPicture.asset(
          AppAssets.downloadPdf,
          color: AppColors.textButton,
        ),
      ),
    );
  }

  /// Form bug report #39: confirm before the PDF is written, then the success
  /// dialog once the file is actually on disk ([onConfirm] returns whether
  /// the download succeeded).
  static Future<void> confirmDownloadPdf(
    BuildContext context,
    Future<bool> Function() onConfirm,
  ) {
    return CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: S.of(context).downloadForm,
      confirmSubtitle: Directionality.of(context) == TextDirection.rtl
          ? 'هل أنت متأكد أنك تريد تنزيل هذا النموذج بصيغة PDF؟'
          : 'Are you sure you want to download this form as PDF?',
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: onConfirm,
      successLottie: AppAssets.successful,
      successTitle: S.of(context).formDownloadAsPdf,
      successSubtitle: S.of(context).youSuccessfullyDownloadedThisFormAsPdf,
    );
  }

  static downloadingPdfSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).formDownloadAsPdf,
      subtitle: S.of(context).youSuccessfullyDownloadedThisFormAsPdf,
    );
  }

  static downloadingExcelSuccessfully(BuildContext context) {
    CustomDialogManager.showSuccess(
      context: context,
      lottiePath: AppAssets.successful,
      title: S.of(context).downloadAsExcel,
      subtitle: S.of(context).youSuccessfullyDownloadedThisFormAsExcel,
    );
  }

  // ===== Large dialogs: one file per dialog (see widgets/dialog/*) =====

  /// Home-list filter dialog (Access Management + Published Date).
  /// Bug report #11: this used to be an empty stub, so Filter did nothing.
  static void filterDialog(BuildContext context) {
    FormFilterDialog.show(context, context.read<HomeCubit>());
  }

  /// Open-access publish summary. See summary_open_access_dialog.dart.
  static summaryOpenAccessDialog(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    CreateFormHeadCubit? headCubit,
    CreateFormDataCubit? dataCubit,
  }) =>
      SummaryOpenAccessDialog.show(
        context,
        onPublishClicked,
        headCubit: headCubit,
        dataCubit: dataCubit,
      );

  /// Restricted-access publish summary. See summary_restricted_access_dialog.dart.
  static summaryRestrictedAccessDialog(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    CreateFormHeadCubit? headCubit,
    CreateFormDataCubit? dataCubit,
  }) =>
      SummaryRestrictedAccessDialog.show(
        context,
        onPublishClicked,
        headCubit: headCubit,
        dataCubit: dataCubit,
      );

  /// Share-access summary. See share_access_dialog.dart.
  static shareAccessDialog(
    BuildContext context,
    dynamic Function() onPublishClicked, {
    ShareCubit? shareCubit,
  }) =>
      ShareAccessDialog.show(
        context,
        onPublishClicked,
        shareCubit: shareCubit,
      );

  static void editGroupWarningDialog(
    BuildContext context,
    Function() onYesClicked,
  ) {
    GetDialogHelper.generalDialog(
      context: context,
      child: DefaultDialog(
        title: S.of(context).editingGroupDetails,
        subTitle: S.of(context).areYouSureEditGroup,
        autoClose: false,
        svgAsset: AppAssets.edit,
        showButtons: true,
        onConfirm: () {
          onYesClicked();
          Get.back();
        },
      ),
    );
  }
}
