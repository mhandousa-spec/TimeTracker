/// Module: roles / r1_role_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: dialog.dart
/// Purpose: Declares `RoleDialogs`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Rebuilt "save for later" on top of CustomDialogManager
///          (core/custom/dialogs) and fixed the post-save navigation so the
///          roles home lands on a loaded list instead of a stuck spinner.
/// Updated: 25/8/2026 - Added `showSaveRoleDialog`: the create / save flow from
///          SettingsSwitchesPage, which used to navigate straight out of the
///          confirm dialog and never showed a success dialog at all.

import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/role_status.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/controller/role_cubit.dart';

class RoleDialogs {
  /// Show the "save for later" (save as draft) confirm → success flow.
  ///
  /// Rebuilt on [CustomDialogManager.showDialogFlow] so this matches every
  /// other confirm/success dialog in the app — the hand-rolled `AlertDialog`
  /// pair that used to live here drifted from the shared look and carried its
  /// own auto-close/pop timer.
  ///
  /// Parameters:
  ///   - pagesToPop: how many pages to pop once the draft is saved
  ///     * 2 from RolePermissionSwitches
  ///     * 3 from SettingsSwitchesPage
  ///     Both land back on the roles home.
  static Future<void> showSaveForLaterDialog({
    required BuildContext context,
    required RoleCubit controller,
    int pagesToPop = 2,
  }) async {
    // Captured so the failure message is shown after the flow's own dialogs
    // have closed, instead of stacking a second dialog on top of them.
    bool saved = true;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
      confirmTitle: S.of(context).saveDraft,
      confirmSubtitle: S.of(context).doYouWantToSaveThisRoleAsDraft,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        // The flow shows its own loading indicator while this runs.

        // saveDraft() reports failure through its return value and a RoleError
        // state instead of throwing, so this page needs no try/catch (§11.2).
        // It also refreshes the roles list before returning, so the home page
        // we pop back to already holds the new draft.
        saved = await controller.saveDraft();

        return saved;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/approved.json',
      successTitle: S.of(context).success,
      successSubtitle: S.of(context).roleSavedAsDraftSuccessfully,
      // Runs only after the success dialog has closed, so the pops can never
      // race the dialog's own dismissal (the old timer-driven version popped
      // page routes while the success dialog was still animating out, which is
      // what left the roles home showing a spinner it never rebuilt out of).
      onSuccessComplete: () {
        if (!context.mounted) return;
        final NavigatorState navigator = Navigator.of(context);
        for (int i = 0; i < pagesToPop; i++) {
          if (!navigator.canPop()) break;
          navigator.pop();
        }
      },
    );

    if (!saved && context.mounted) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
        title: S.of(context).failedToSaveDraftPleaseTryAgain,
      );
    }
  }

  /// Show the create / complete-draft / save-edit confirm → success flow for a
  /// role, then leave the wizard.
  ///
  /// ADDED 25/8/2026. SettingsSwitchesPage used to call `ConfirmDialog` and do
  /// the work inside `onConfirm`, which popped three or four page routes the
  /// instant the write returned. That had two faults:
  ///
  ///   * NO SUCCESS DIALOG. Every other write in the app confirms itself; this
  ///     one dropped the user back on the roles home with nothing to say the
  ///     role had been created — and nothing to say it had NOT been, either.
  ///   * IT POPPED ON FAILURE TOO. `addNewRole` / `updateRole` report a problem
  ///     by emitting [RoleError] rather than throwing, and that state was never
  ///     read, so a permission violation or a Firestore error navigated away
  ///     exactly like a success and the user's work looked saved.
  ///
  /// The flow is now the shared [CustomDialogManager.showDialogFlow]: confirm →
  /// run → success dialog → and only then navigate, from `onSuccessComplete`,
  /// which fires after the success dialog has closed. A failure shows the error
  /// and stays on the page so the user can fix it and press save again.
  ///
  /// Parameters:
  ///   - pagesToPop: how many pages to leave once the role is saved. Defaults
  ///     to the wizard's own depth: 3 while creating (settings → permissions →
  ///     adding-new-role) and 4 while editing, which also clears role details.
  ///     Every pop is guarded by `canPop`, so a shorter stack is harmless.
  static Future<void> showSaveRoleDialog({
    required BuildContext context,
    required RoleCubit controller,
    int? pagesToPop,
  }) async {
    // Read BEFORE the write: a successful `addNewRole` calls
    // `initAddingRoleController`, which resets `isEditing`. Deciding the
    // wording or the pop count afterwards would read the cleared state.
    final bool isEditing = controller.isEditing;
    final bool isDraft =
        controller.selectedRole?.currentStatus == RoleStatus.draft;
    final int popCount = pagesToPop ?? (isEditing ? 4 : 3);

    // `attempted` separates "the user pressed No" from "the save failed" —
    // without it, cancelling the confirm dialog would raise a failure message.
    bool attempted = false;
    bool saved = false;
    String failureMessage = '';

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie:
          'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
      confirmTitle: isEditing
          ? S.of(context).editingRole
          : (isDraft
              ? S.of(context).completingDraftRole
              : S.of(context).creatingRole),
      confirmSubtitle: isEditing
          ? S.of(context).areYouSureEditRole
          : (isDraft
              ? S.of(context).areYouSureCompleteDraftRole
              : S.of(context).areYouSureCreateRole),
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        attempted = true;
        // The flow shows its own loading indicator while this runs.

        if (isEditing) {
          await controller.updateRole();
        } else if (isDraft) {
          await controller.activateDraftRole();
        } else {
          await controller.addNewRole();
        }


        // The three cubit methods return void and report the outcome through
        // the state they leave behind — success states are emitted last, after
        // the list refresh, so reading `state` here is safe. Anything else
        // (RoleError, or a state left over because the write bailed out early)
        // counts as a failure and stops the flow before the success dialog.
        final RoleState outcome = controller.state;
        saved = outcome is RoleAdded ||
            outcome is RoleUpdated ||
            outcome is RoleActivated;
        failureMessage = outcome is RoleError ? outcome.message : '';

        return saved;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/approved.json',
      successTitle: S.of(context).success,
      successSubtitle: isEditing
          ? S.of(context).roleUpdatedSuccessfully
          : (isDraft
              ? S.of(context).draftRoleCompletedSuccessfully
              : S.of(context).roleCreatedSuccessfully),
      // Runs after the success dialog has closed — see the note on
      // [showSaveForLaterDialog] for why the pops must not race it.
      onSuccessComplete: () {
        if (!context.mounted) return;
        final NavigatorState navigator = Navigator.of(context);
        for (int i = 0; i < popCount; i++) {
          if (!navigator.canPop()) break;
          navigator.pop();
        }
      },
    );

    if (attempted && !saved && context.mounted) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
        title: S.of(context).failedToSaveRolePleaseTryAgain,
        // The cubit's message carries the useful part on the common failure —
        // the list of permissions an administrator has restricted.
        subtitle: failureMessage,
      );
    }
  }

  /// Show the delete confirm → success flow for a DRAFT role, then leave the
  /// wizard for the roles home.
  ///
  /// ADDED 28/8/2026. A draft role opens straight into `AddingNewRole` (see
  /// role_overview.dart's onTap), and until now the only way off that screen
  /// was Discard, which leaves the draft sitting on the list. This is the
  /// destructive counterpart the design asks for: confirm → delete → success →
  /// pop back to the module home.
  ///
  /// Mirrors [showSaveRoleDialog] exactly: `deleteRole` returns void and
  /// reports its outcome through the state it leaves behind — [RoleDeleted] on
  /// success, [RoleError] otherwise — so success is read from `controller.state`
  /// after the await, and the navigation runs from `onSuccessComplete`, which
  /// fires only after the success dialog has closed (so the pops can never race
  /// its dismissal). A failure shows the error and stays on the page.
  ///
  /// The pop target is the roles navigator's first route (the tab home). A
  /// draft is pushed directly onto that navigator from role_overview, so
  /// `popUntil((route) => route.isFirst)` lands on the home regardless of how
  /// the user reached the draft.
  static Future<void> showDeleteRoleDialog({
    required BuildContext context,
    required RoleCubit controller,
  }) async {
    // `attempted` separates "the user pressed No" from "the delete failed" —
    // without it, cancelling the confirm dialog would raise a failure message.
    bool attempted = false;
    bool deleted = false;
    String failureMessage = '';

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/roles_lottie_assets/delete.json',
      confirmTitle: S.of(context).deleteRole,
      confirmSubtitle: S.of(context).areYouSureYouWantToDeleteThisRole,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        attempted = true;
        // The flow shows its own loading indicator while this runs.

        // deleteRole() reports failure through a RoleError state instead of
        // throwing, so this page needs no try/catch (§11.2). It also refreshes
        // the roles list before returning, so the home we pop back to already
        // reflects the deletion.
        await controller.deleteRole();


        final RoleState outcome = controller.state;
        deleted = outcome is RoleDeleted;
        failureMessage = outcome is RoleError ? outcome.message : '';

        return deleted;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/approved.json',
      successTitle: S.of(context).success,
      successSubtitle: S.of(context).roleDeletedSuccessfully,
      onSuccessComplete: () {
        if (!context.mounted) return;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );

    if (attempted && !deleted && context.mounted) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/warning.json',
        title: S.of(context).errorOccurred,
        // The cubit's message carries the useful part on the common failure —
        // e.g. the delete permission an administrator has restricted.
        subtitle: failureMessage,
      );
    }
  }
}
