/// Module: knowledge_hub / presentation / s7_approvals_details / widgets/reason_for_justifications_dialog.dart
/// ************************* FILE INFO *************************** ///
/// File Name: reason_for_justifications_dialog.dart
/// Purpose: Reason for justifications dialog — Approvals Details (S7) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k6_approvals/presentation/controller/approvals_cubit.dart';
import '../../../../k6_approvals/presentation/controller/approvals_states.dart';
import '../../../../main_controller/presentation/ui/widgets/customed_text_field.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/44-custom_validated_textfield.dart';

class ReasonForJustificationsDialog extends StatefulWidget {
  final String knowledgeId;

  const ReasonForJustificationsDialog({super.key, required this.knowledgeId});

  @override
  State<ReasonForJustificationsDialog> createState() =>
      _ReasonForJustificationsDialogState();
}

class _ReasonForJustificationsDialogState
    extends State<ReasonForJustificationsDialog> {
  final TextEditingController _justificationController =
  TextEditingController();

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext parentContext) {
    final isMobile = ResponsiveHelper.isMobile(parentContext);
    final lightMode = Theme.of(parentContext).brightness == Brightness.light;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Auto-close after 2 seconds using the dialogContext directly
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Center(
          child: Material(
            color: AppColors.transparent,
            child: Container(
              width: isMobile ? double.infinity : 411.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: lightMode
                    ? AppColors.white
                    : AppColors.background,
              ),
              padding: EdgeInsets.all(20.r),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                    height: 100.h,
                    width: 100.w,
                    repeat: false,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Document Approved Successfully',
                    style: StyleText.fontSize20Weight500,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'The document has been approved and is now published.',
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext parentContext, String error) {
    final isMobile = ResponsiveHelper.isMobile(parentContext);
    final lightMode = Theme.of(parentContext).brightness == Brightness.light;

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: lightMode
                  ? AppColors.white
                  : AppColors.background,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: AppColors.red, size: 64.sp),
                SizedBox(height: 20.h),
                Text(
                  'Approval Failed',
                  style: StyleText.fontSize20Weight500,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),
                Text(
                  error,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                customButton(
                  title: 'OK',
                  height: 38.h,
                  function: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<ApprovalsCubit, ApprovalsStates>(
      listener: (context, state) {
        if (state is ApprovingKnowledgeSuccessState) {
          // Close the justification dialog and wait for it to complete
          Navigator.of(context).pop();

          // Show success dialog after current dialog is fully closed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSuccessDialog(context);
          });
        } else if (state is ApprovingKnowledgeErrorState) {
          // Close the justification dialog
          Navigator.of(context).pop();

          // Show error dialog after current dialog is fully closed
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorDialog(context, state.error);
          });
        }
      },
      child: Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: lightMode ? AppColors.white : AppColors.chatBackground,
            ),
            padding: EdgeInsets.all(15.r),
            margin: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.textButton,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      S.of(context).approvalJustification,
                      style: StyleText.fontSize14Weight500.copyWith(
                        color: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15.h),

                // Text field
                CustomValidatedTextFieldMaster(
                  label: S.of(context)!.justifications,
                  hint: S.of(context)!.textHere,
                  controller: _justificationController,
                  height: 72,
                  showCharCount: true,
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: 3,
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 15.h),

                // Submit button with BlocBuilder for loading state
                BlocBuilder<ApprovalsCubit, ApprovalsStates>(
                  builder: (context, state) {
                    final isLoading = state is ApprovingKnowledgeLoadingState;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        customButton(
                          title: S.of(context)!.submit,
                          width: 150.w,
                          height: 38.h,
                          textStyle: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.textButton
                          ),
                          function: isLoading
                              ? () {}
                              : () {
                            final justification = _justificationController
                                .text
                                .trim();

                            // Call the approve method
                            context.read<ApprovalsCubit>().approveKnowledge(
                              knowledgeId: widget.knowledgeId,
                              approvalJustification: justification,
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}