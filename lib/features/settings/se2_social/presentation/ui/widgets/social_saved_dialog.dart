/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_saved_dialog.dart
/// Purpose: The "your data has been updated" confirmation shown after a
///          successful save.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N08 / N10. This dialog used to be built inside
/// `SocialController` with `Get.dialog`, reading its theme from `Get.context!`,
/// and closed by a bare `Future.delayed(3s)` that called `Get.back()` — which
/// pops whatever route happens to be on top three seconds later, dialog or not.
/// The timer lives with the dialog now and is cancelled on dispose, and the pop
/// is guarded by `mounted`.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class SocialSavedDialog extends StatefulWidget {
  const SocialSavedDialog({super.key});

  /// How long the confirmation stays up before closing itself.
  static const Duration visibleFor = Duration(seconds: 3);

  /// Function Name: [show]
  ///
  /// Purpose: Present the confirmation over [context].
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SocialSavedDialog(),
    );
  }

  @override
  State<SocialSavedDialog> createState() => _SocialSavedDialogState();
}

class _SocialSavedDialogState extends State<SocialSavedDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SocialSavedDialog.visibleFor, () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 411.w,
        decoration: BoxDecoration(
          color: lightMode ? AppColors.white : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(24.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/approved.json',
              width: 100.w,
              height: 100.h,
              repeat: false,
            ),
            SizedBox(height: 16.h),
            Text(
              S.of(context).successMessage,
              style:
                  StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
