/// Module: services_management_module
/// Description: Cancel-request button + confirmation/comment dialog flow for
///              the "my request" details page. Dispatches to
///              MyRequestDetailsCubit.cancelRequest — no Firestore access
///              here. Extracted from MyRequestDetails (audit fix #1/#3).
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, MyRequestDetailsCubit, CustomDialogManager
/// Revision History: Initial version.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/my_request_details_cubit.dart';

class MyRequestCancelButton extends StatelessWidget {
  const MyRequestCancelButton({
    super.key,
    required this.isMobile,
    required this.cancelController,
    required this.providerEmail,
    required this.serviceName,
    required this.requesterName,
    required this.onCancelled,
  });

  final bool isMobile;
  final TextEditingController cancelController;
  final String? providerEmail;
  final String serviceName;
  final String requesterName;

  /// Called after a successful cancel so the page can refresh derived
  /// approval-related lists on the module-level cubit.
  final VoidCallback onCancelled;

  @override
  Widget build(BuildContext context) {
    // "Cancel Service" off → the whole affordance goes, not just the handler.
    if (!ServicesModuleAccess.canCancelService) {
      return const SizedBox.shrink();
    }

    final cubit = context.read<MyRequestDetailsCubit>();

    return GestureDetector(
      onTap: () {
        CustomDialogManager.showDialogFlow(
          confirmWidth: 411,
          context: context,
          customReasonTitle: S.of(context).reasonsOfCancellation,
          confirmLottie: 'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
          confirmTitle: S.of(context).cancelRequest,
          confirmSubtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
          confirmYesText: S.of(context).yes,
          confirmNoText: S.of(context).no,
          onConfirm: () async => true,
          comment: true,
          commentRequired: true,
          commentController: cancelController,
          commentSubmitText: S.of(context).submit,
          commentDiscardText: S.of(context).discard,
          onCommentSubmit: () async {
            // B2 FIX: only report success (and refresh) if the cancel write worked.
            final ok = await cubit.cancelRequest(
              cancellationReason: cancelController.text,
              providerEmail: providerEmail,
              serviceName: serviceName,
              requesterName: requesterName,
            );
            if (!ok) return false;
            onCancelled();
            return true;
          },
          successLottie: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
          successTitle: S.of(context).CancelRequest,
          successSubtitle: S.of(context).cancelSuccessMessage,
          onSuccessComplete: () {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) Navigator.pop(context);
            });
          },
        );
      },
      child: Container(
        width: isMobile ? 135.sp : 150.sp,
        // ✅ FIX (bug report p34): 30.sp made this shorter than every other
        // action control on the same screen — Send Reminder and the status pill
        // in my_request_status_footer are both 36.sp — so the Cancel button
        // looked undersized next to them.
        height: 36.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.red,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons_assets/main_icons_assets/minus_circle_red.svg",
              height: 20.sp,
              color: Colors.white,
              width: 20.sp,
              fit: BoxFit.fill,
              semanticsLabel: 'Dart Logo',
            ),
            SizedBox(width: 8.sp),
            Text(
              S.of(context).Cancel,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
