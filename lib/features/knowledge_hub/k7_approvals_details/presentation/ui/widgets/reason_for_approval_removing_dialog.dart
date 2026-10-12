/// Module: knowledge_hub / presentation / s7_approvals_details / widgets/reason_for_approval_removing_dialog.dart
/// ************************* FILE INFO *************************** ///
/// File Name: reason_for_approval_removing_dialog.dart
/// Purpose: Reason for approval removing dialog — Approvals Details (S7) screen UI.
/// Author: Knowticed Team
/// Created At: 11/10/2025

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:lottie/lottie.dart';


import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../k6_approvals/presentation/controller/approvals_cubit.dart';
import '../../../../k6_approvals/presentation/controller/approvals_states.dart';
import '../../../../main_controller/presentation/ui/widgets/customed_text_field.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';

class ResonForApprovalRemovingDialog extends StatefulWidget {
  final String knowledgeId;
  const ResonForApprovalRemovingDialog({super.key, required this.knowledgeId});

  @override
  State<ResonForApprovalRemovingDialog> createState() =>
      _ResonForApprovalRemovingDialogState();
}

class _ResonForApprovalRemovingDialogState
    extends State<ResonForApprovalRemovingDialog> {
  final TextEditingController _justificationController =
      TextEditingController();

  @override
  void dispose() {
    _justificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return BlocListener<ApprovalsCubit, ApprovalsStates>(
      listener: (context, state) {
        if (state is RejectingKnowledgeSuccessState) {
          _showSuccessDialog(context);
        } else if (state is RejectingKnowledgeErrorState) {
          _showErrorDialog(context, state.error);
        }
      },
      child: Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
            ),
           padding: EdgeInsets.all(15.r),
          //  margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and title
                Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        child: CustomSvgImage(
                          assetPath: "assets/icons_assets/knowledge_hub_assets/reson_reject.svg",
                           width: 18.w,
                          height: 18.h,
                          color: AppColors.textButton,
                          fit: BoxFit.scaleDown,
                        ),
                      )
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      S.of(context).reasonOfRejection,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.text
                      )
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Text field
                CustomValidatedTextField(
                  label: S.of(context).Justifications ,

                  hint: S.of(context).textHere,
                  controller: _justificationController,
                  height: 72,
                  showCharCount: true,
                  maxLines: 3,
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 20.h),

                // Submit button with BlocBuilder for loading state
                Align(
                  alignment: Alignment.centerRight,
                  child: BlocBuilder<ApprovalsCubit, ApprovalsStates>(
                    builder: (context, state) {
                      final isLoading = state is RejectingKnowledgeLoadingState;

                      return customButton(
                        title: S.of(context)!.submit,
                        width: 150.w,
                        color: AppColors.primary,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.textButton
                        ),
                        height: 38.h,
                        function: isLoading
                            ? () {}
                            : () {
                                final reason = _justificationController.text
                                    .trim();

                                // Call the reject method
                                context.read<ApprovalsCubit>().rejectKnowledge(
                                  knowledgeId: widget.knowledgeId,
                                  rejectionReason: reason,
                                );
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card
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
                  repeat: true,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context).documentFileRejected,
                  style: StyleText.fontSize20Weight500,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context).documentRemoveSuccess,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    final isMobile = ResponsiveHelper.isMobile(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColors.card,
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
                  'Rejection Failed',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
