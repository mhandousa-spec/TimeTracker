/// Module: knowledge_hub_module / core/custom_dialog_manager.dart
/// ******************* FILE INFO *******************
/// File Name: custom_dialog.dart
/// Description: this is custom success or comment or select dialog for reuse
/// Created by: Amr Mesbah
/// Last Update: 30/8/2025

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/44-custom_validated_textfield.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CustomDialogManager {
  static Future<void> showDialogFlow({
    required BuildContext context,
    required String confirmLottie,
    required String confirmTitle,
    required String confirmSubtitle,
    required String confirmYesText,
    required String confirmNoText,
    required VoidCallback onConfirm,
    VoidCallback? onNoPressed,
    bool commentRequired = false,
    required String successLottie,
    required String successTitle,
    required String successSubtitle,
    bool comment = false,
    TextEditingController? commentController,
    String commentSubmitText = '',
    String commentDiscardText = '',
    String customReasonTitle = '', // <-- new
    Future<void> Function()? onCommentSubmit,
    VoidCallback? onCommentDiscard,
    VoidCallback? onSuccessDismissed,
  }) async {
    debugPrint(
      '[CDM] showDialogFlow: START '
      '(comment=$comment, required=$commentRequired, '
      'confirm="$confirmTitle", success="$successTitle")',
    );
    final outerContext = context;
    await showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (dlgCtx) {
        final isMobile = ContextExtension(dlgCtx).isPhone;
        debugPrint('[CDM] Confirm dialog BUILDER');
        return Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 411.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    confirmLottie,
                    width: 70.sp,
                    height: 70.sp,
                    fit: BoxFit.scaleDown,
                    repeat: true,
                    animate: true,
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmTitle,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Text(
                    confirmSubtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 15.sp),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customButton(
                        title: confirmNoText,
                        function: () {
                          debugPrint('[CDM] Confirm NO pressed');
                          Navigator.of(context, rootNavigator: true).pop();
                          onNoPressed?.call();
                          debugPrint('[CDM] Confirm dialog closed via NO');
                        },
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: const Color(0xff2D2D2D),
                        ),
                        width: isMobile ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.secondaryButton,
                      ),
                      SizedBox(height: 0, width: 15.sp),
                      customButton(
                        title: confirmYesText,
                        function: () async {
                          debugPrint('[CDM] Confirm YES pressed');

                          // 1) Close the confirm dialog FIRST (use the dialog's own context)
                          final nav = Navigator.of(dlgCtx, rootNavigator: true);
                          if (nav.canPop()) {
                            nav.pop();
                            debugPrint('[CDM] Confirm dialog closed via YES');
                          } else {
                            debugPrint(
                              '[CDM][WARN] Confirm dialog could not pop (already closed?)',
                            );
                          }

                          // 2) Give the framework a brief moment to dispose the first dialog
                          await Future.delayed(
                            const Duration(milliseconds: 120),
                          );

                          // 3) If a comment is required, open it using the OUTER page context
                          bool proceed = true;
                          if (comment && commentController != null) {
                            debugPrint(
                              '[CDM] Opening COMMENT dialog (required=$commentRequired)',
                            );
                            proceed = await _showCommentDialog(
                              context: outerContext, // <-- outer (page) context
                              controller: commentController,
                              submitText: commentSubmitText,
                              discardText: commentDiscardText,
                              reasonTitle: customReasonTitle,
                              onSubmit: onCommentSubmit,
                              onDiscard: onCommentDiscard,
                              isRequired: commentRequired,
                            );
                            debugPrint(
                              '[CDM] COMMENT dialog result: proceed=$proceed',
                            );

                            if (!proceed) {
                              debugPrint(
                                '[CDM] Aborting after comment dialog (not submitted)',
                              );
                              return;
                            }
                          } else {
                            debugPrint(
                              '[CDM] No comment required — skipping comment dialog',
                            );
                          }

                          // 4) Run the confirm logic
                          try {
                            debugPrint('[CDM] Calling onConfirm()');
                            onConfirm();
                            debugPrint('[CDM] onConfirm() DONE');
                          } catch (e, st) {
                            debugPrint('[CDM][ERROR] onConfirm threw: $e\n$st');
                          }

                          // 5) Show success dialog (non-dismissable, auto-closes)
                          await _showSuccessDialog(
                            context: outerContext, // <-- outer (page) context
                            lottiePath: successLottie,
                            title: successTitle,
                            subtitle: successSubtitle,
                          );

                          debugPrint('[CDM] Success dialog dismissed');
                          onSuccessDismissed?.call();
                        },
                        textStyle: StyleText.fontSize15Weight400.copyWith(
                          color: AppColors.textButton,
                        ),
                        width: isMobile ? 120.sp : 135.sp,
                        height: 38.sp,
                        radius: 4.r,
                        color: AppColors.primary,
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

    debugPrint('[CDM] showDialogFlow: END');
  }

  static Future<bool> _showCommentDialog({
    required BuildContext context,
    required TextEditingController controller,
    required String submitText,
    required String discardText,
    required String reasonTitle,
    Future<void> Function()? onSubmit,
    VoidCallback? onDiscard,
    bool isRequired = false,
  }) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    // 1) add this helper near the top of the file (outside the widget/class)
    String _toWesternDigits(String s) {
      const east = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      const west = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      for (var i = 0; i < east.length; i++) {
        s = s.replaceAll(east[i], west[i]);
      }
      return s;
    }

    String _toEasternDigits(String s) {
      const east = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
      const west = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
      for (var i = 0; i < west.length; i++) {
        s = s.replaceAll(west[i], east[i]);
      }
      return s;
    }

    debugPrint('[CDM] _showCommentDialog: OPEN (required=$isRequired)');
    final isMobile = ContextExtension(context).isPhone;
    String? errorText;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: !isRequired,
      useRootNavigator: true,
      builder: (context) {
        debugPrint('[CDM] Comment dialog BUILDER');
        return Dialog(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(15.sp),
            child: SizedBox(
              width: 411.sp,
              child: StatefulBuilder(
                builder: (context, setState) {
                  void validate() {
                    if (isRequired && controller.text.trim().isEmpty) {
                      setState(
                        () => errorText = S.of(context)!.pleaseEnterCancelReason,
                      );
                      debugPrint('[CDM] Comment validate: EMPTY (required)');
                    } else {
                      setState(() => errorText = null);
                      debugPrint('[CDM] Comment validate: OK');
                    }
                  }

                  const int kMaxChars = 500;
                  final int len = controller.text.characters.length;
                  final String counterText = isArabic
                      ? '${_toEasternDigits(kMaxChars.toString())}/${_toEasternDigits(len.toString())}' // AR: ٥٠٠/٠
                      : '${_toWesternDigits(len.toString())}/${_toWesternDigits(kMaxChars.toString())}'; // EN: 0/500

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30.sp,
                            height: 30.sp,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColors.textButton,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 5.sp),
                          Text(
                            reasonTitle,
                            style: StyleText.fontSize16Weight500.copyWith(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? AppColors.blackButton
                                  : AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.sp),

                      CustomValidatedTextFieldMaster(
                        label: S.of(context)!.justifications,
                        hint: S.of(context)!.textHere,
                        controller: controller,
                        height: 72.sp,
                        maxLines: 3,
                        // We’ll draw our own counter for full control:
                        showCharCount: false, // <— changed
                        // Make the field direction follow the locale:
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr, // <— changed
                        onChanged: (_) =>
                            setState(() {}), // keep the counter live

                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),

                      // 2) our custom counter: alignment depends on locale, digits forced to Western
                      // Single-line slot that shows EITHER the counter OR the error (same row)
                      SizedBox(
                        height: 18.sp, // one line height to avoid layout shift
                        child: Align(
                          alignment: isArabic
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: (isRequired && (errorText ?? '').isNotEmpty)
                                // ---- ERROR (replaces counter, same line) ----
                                ? Text(
                                    errorText!,
                                    key: const ValueKey('error'),
                                    style: StyleText.fontSize12Weight500
                                        .copyWith(
                                          color: const Color(0xFFD32F2F),
                                        ),
                                  )
                                // ---- COUNTER (default) ----
                                : Directionality(
                                    key: const ValueKey('counter'),
                                    textDirection: isArabic
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: Text(
                                      counterText, // e.g., EN: 0/500, AR: ٥٠٠/٠
                                      style: StyleText.fontSize12Weight500
                                          .copyWith(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? const Color(0xFF6F6F6F)
                                                : AppColors.white,
                                          ),
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15.sp),
                      Row(
                        children: [
                          customButton(
                            title: discardText,
                            function: () {
                              debugPrint('[CDM] Comment DISCARD pressed');
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pop(false);
                              onDiscard?.call();
                              debugPrint(
                                '[CDM] Comment dialog closed via DISCARD',
                              );
                            },
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: const Color(0xff2D2D2D),
                            ),
                            width: isMobile ? 120.sp : 150.sp,
                            height: 38.sp,
                            radius: 8.r,
                            color: const Color(0xffcccccc),
                          ),
                          const Spacer(),
                          customButton(
                            title: submitText,
                            function: () async {
                              debugPrint('[CDM] Comment SUBMIT pressed');
                              if (isRequired &&
                                  controller.text.trim().isEmpty) {
                                debugPrint(
                                  '[CDM] Comment SUBMIT blocked (empty & required)',
                                );
                                validate();
                                return;
                              }
                              try {
                                debugPrint('[CDM] Calling onSubmit()');
                                await onSubmit?.call(); // <<< critical await
                                debugPrint('[CDM] onSubmit() DONE');
                              } catch (e, st) {
                                debugPrint(
                                  '[CDM][ERROR] onSubmit threw: $e\n$st',
                                );
                              }
                              if (Navigator.of(
                                context,
                                rootNavigator: true,
                              ).canPop()) {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop(true);
                                debugPrint(
                                  '[CDM] Comment dialog closed via SUBMIT',
                                );
                              }
                            },
                            textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton,
                            ),
                            width: isMobile ? 120.sp : 150.sp,
                            height: 38.sp,
                            radius: 8.r,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    debugPrint('[CDM] _showCommentDialog: CLOSE result=${result ?? false}');
    return result ?? false;
  }

  // REPLACE the whole method with this:
  static Future<void> _showSuccessDialog({
    required BuildContext context,
    required String lottiePath,
    required String title,
    required String subtitle,
  }) async {
    debugPrint('[CDM] _showSuccessDialog: OPEN');

    BuildContext? dialogCtx; // capture the dialog's own context

    // IMPORTANT: barrierDismissible=false so users can't dismiss before auto-close
    await showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx; // <-- capture
        debugPrint('[CDM] Success dialog BUILDER');
        return Dialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.light
              ? AppColors.white
              : AppColors.chatBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 411.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    lottiePath,
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    title,
                    style: StyleText.fontSize20Weight500.copyWith(
                      color: Theme.of(ctx).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Theme.of(ctx).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    // Schedule the auto-close tied to the captured dialog context
    await Future.delayed(const Duration(milliseconds: 1500));

    if (dialogCtx != null) {
      final nav = Navigator.of(dialogCtx!, rootNavigator: true);
      // Only pop if this dialog is still on top:
      if (nav.canPop()) {
        debugPrint('[CDM] _showSuccessDialog: CLOSE (auto after delay)');
        nav.pop();
      } else {
        debugPrint('[CDM][INFO] Dialog already closed; skipping pop');
      }
    } else {
      debugPrint('[CDM][WARN] dialogCtx was null; nothing to pop');
    }
  }
}
