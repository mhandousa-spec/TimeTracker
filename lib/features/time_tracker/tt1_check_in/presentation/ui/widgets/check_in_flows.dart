/// Module: time_tracker / tt1_check_in / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: check_in_flows.dart
/// Purpose: Declares `CheckInFlows` — the dialog sequences around the
///          check-in actions: sheet → (location confirmed) → "You
///          Successfully Checked In"; confirm → "You Successfully Checked
///          Out"; Pause / Resume; and the message for every refusal.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Figma dialogs: sheet `661:17263`, Wrong Location `661:17251`, location
/// Confirmed `661:17257`, checked in `661:17288`, checked out `661:17245`.
/// Dialog shells are core (`CustomDialogManager.showContent` / `showMessage`
/// / `showDialogFlow`, scale-in). Haptics: the yellow buttons fire Medium
/// themselves (customButton); the check-out confirm uses the core flow.
/// Updated: 9/10/2026 - code review: a mock-location reading is explained;
/// a second tap while an action runs is silent.
/// Updated: 9/10/2026 - QA KP-TT-015: an action on a stale screen (checked
/// out from another card / device) says "Attendance Updated — You have
/// already checked out…" instead of "Something went wrong".

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/helper/main_helper/app_toast.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/time_tracker/domain/rules/check_in_options.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/controller/check_in_cubit.dart';
import 'package:knowticed_plus/features/time_tracker/tt1_check_in/presentation/ui/widgets/check_in_sheet.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CheckInFlows {
  const CheckInFlows._();

  /// How long the "location matches" confirmation stays before the success.
  static const Duration matchNoticeDuration = Duration(milliseconds: 1600);

  /// Function Name: [checkIn]
  ///
  /// Purpose: Sheet → check in → result dialogs.
  ///
  /// Return type: [Future<void>]
  static Future<void> checkIn(BuildContext context) async {
    final CheckInCubit cubit = context.read<CheckInCubit>();
    final S s = S.of(context);
    if (cubit.state.setup == null || cubit.state.options.isEmpty) {
      await _message(context, s.timeTrackerNotAssigned);
      return;
    }
    final CheckInOption? option = await CustomDialogManager.showContent<CheckInOption>(
      context: context,
      width: 450,
      child: CheckInSheet(options: cubit.state.options),
    );
    if (option == null || !context.mounted) return;
    final CheckInResult result = await cubit.checkIn(option);
    if (!context.mounted) return;
    if (!result.isSuccess) {
      await showOutcome(context, result);
      return;
    }
    if (result.locationVerified) {
      await CustomDialogManager.showContent<void>(
        context: context,
        width: 450,
        child: _AutoClose(
          after: matchNoticeDuration,
          child: LocationResultDialog(
            isMatch: true,
            title: s.timeTrackerConfirmedTitle,
            body: s.timeTrackerLocationMatches,
          ),
        ),
      );
      if (!context.mounted) return;
    }
    await CustomDialogManager.showMessage(
      context: context,
      lottiePath: AppAssets.successful,
      title: s.timeTrackerConfirmedTitle,
      subtitle: s.timeTrackerCheckedInSuccess,
      closeAfter: const Duration(seconds: 3),
    );
  }

  /// Function Name: [checkOut]
  ///
  /// Purpose: "Are you sure" → check out → "You Successfully Checked Out".
  ///
  /// Return type: [Future<void>]
  static Future<void> checkOut(BuildContext context) async {
    final CheckInCubit cubit = context.read<CheckInCubit>();
    final S s = S.of(context);
    CheckInResult? result;
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmWidth: 411,
      scaleIn: true,
      confirmLottie: AppAssets.lottieConfirmation,
      confirmTitle: s.timeTrackerCheckOutConfirmTitle,
      confirmSubtitle: s.timeTrackerCheckOutConfirmBody,
      confirmYesText: s.yes,
      confirmNoText: s.no,
      onConfirm: () async {
        result = await cubit.checkOut();
        return result?.isSuccess ?? false;
      },
      successLottie: AppAssets.successful,
      successTitle: s.timeTrackerConfirmedTitle,
      successSubtitle: s.timeTrackerCheckedOutSuccess,
    );
    final CheckInResult? done = result;
    if (done != null && !done.isSuccess && context.mounted) {
      await showOutcome(context, done);
    }
  }

  /// Function Name: [pauseOrResume]
  ///
  /// Purpose: Pause (or Resume when paused); a failure shows a toast.
  ///
  /// Return type: [Future<void>]
  static Future<void> pauseOrResume(BuildContext context) async {
    final CheckInCubit cubit = context.read<CheckInCubit>();
    final S s = S.of(context);
    final CheckInResult result =
        cubit.state.isPaused ? await cubit.resume() : await cubit.pause();
    if (result.isSuccess || result.outcome == CheckInOutcome.busy) return;
    // QA KP-TT-015 (9/10/2026): a stale screen — explain, the control
    // already shows the stored day.
    if (_isStale(result.outcome)) {
      if (context.mounted) await showOutcome(context, result);
      return;
    }
    AppToast.show(
      result.outcome == CheckInOutcome.noPermission
          ? s.timeTrackerNoPermission
          : s.timeTrackerActionFailed,
      backgroundColor: AppColors.red,
      textColor: AppColors.white,
    );
  }

  /// Function Name: [showOutcome]
  ///
  /// Purpose: Explain a refused / failed action.
  ///
  /// Return type: [Future<void>]
  static Future<void> showOutcome(BuildContext context, CheckInResult result) {
    final S s = S.of(context);
    switch (result.outcome) {
      case CheckInOutcome.success:
        return Future<void>.value();
      case CheckInOutcome.wrongLocation:
        return CustomDialogManager.showContent<void>(
          context: context,
          width: 450,
          child: LocationResultDialog(
            isMatch: false,
            title: s.timeTrackerWrongLocationTitle,
            body: s.timeTrackerWrongLocationBody,
          ),
        );
      case CheckInOutcome.locationDenied:
        return _message(context, s.timeTrackerLocationDenied,
            title: s.timeTrackerLocationNeededTitle);
      case CheckInOutcome.locationServiceOff:
        return _message(context, s.timeTrackerLocationServiceOff,
            title: s.timeTrackerLocationNeededTitle);
      case CheckInOutcome.locationUnavailable:
        return _message(context, s.timeTrackerLocationUnavailable,
            title: s.timeTrackerLocationNeededTitle);
      case CheckInOutcome.notAssigned:
        return _message(context, s.timeTrackerNotAssigned);
      case CheckInOutcome.locationNotAllowed:
        return _message(context, s.timeTrackerLocationNotAllowed);
      case CheckInOutcome.differentLocationNotAllowed:
        return _message(context, s.timeTrackerDifferentLocationNotAllowed);
      case CheckInOutcome.noPermission:
        return _message(context, s.timeTrackerNoPermission);
      case CheckInOutcome.failed:
        return _message(context, s.timeTrackerActionFailed);
      // 9/10/2026 (code review).
      case CheckInOutcome.mockedLocation:
        return _message(context, s.timeTrackerMockedLocation, title: s.timeTrackerLocationNeededTitle);
      case CheckInOutcome.busy:
        return Future<void>.value();
      // QA KP-TT-015 (9/10/2026): the action was made on a stale screen.
      case CheckInOutcome.alreadyCheckedOut:
        return _message(context, s.timeTrackerAlreadyCheckedOut, title: s.timeTrackerAttendanceUpdatedTitle);
      case CheckInOutcome.stateChanged:
        return _message(context, s.timeTrackerAttendanceChanged, title: s.timeTrackerAttendanceUpdatedTitle);
    }
  }

  static bool _isStale(CheckInOutcome outcome) =>
      outcome == CheckInOutcome.alreadyCheckedOut || outcome == CheckInOutcome.stateChanged;

  static Future<void> _message(
    BuildContext context,
    String body, {
    String? title,
  }) =>
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: AppAssets.lottieWarning,
        title: title ?? S.of(context).errorOccurred,
        subtitle: body,
      );
}

/// Pops its dialog route by itself after [after].
class _AutoClose extends StatefulWidget {
  const _AutoClose({required this.after, required this.child});

  final Duration after;
  final Widget child;

  @override
  State<_AutoClose> createState() => _AutoCloseState();
}

class _AutoCloseState extends State<_AutoClose> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.after, () {
      if (!mounted) return;
      final NavigatorState navigator = Navigator.of(context);
      if (ModalRoute.of(context)?.isCurrent ?? false) navigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
