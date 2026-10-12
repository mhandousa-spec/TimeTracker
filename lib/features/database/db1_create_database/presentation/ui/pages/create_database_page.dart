/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: create_database_page.dart
/// Purpose: Declares `CreateDatabasePage`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// MAIN PAGE : Creating A DataBase — one file, all three layouts.
///
///   iPad HORIZONTAL  1024 x 782   Figma 7398:6137
///   iPad VERTICAL     768 x 782   Figma 7398:6214
///   PHONE             375 x 912   Figma 7398:12919
///
/// The phone frame turned out to be the SAME card, not a different flow:
/// 15pt page margins, the EN/AR pairs stacked instead of side by side, and
/// 135pt buttons. `buildResponsiveFields` already stacks below 600px and
/// `SideFrameMasterServices` already swaps its breadcrumb for a back chevron
/// and title, so implementing mobile (15/8/2026) removed a guard rather than
/// adding a layout.
///
/// WHY ONE FILE AND NOT pages/tablet + pages/mobile
/// ------------------------------------------------
/// The three layouts differ by an outer inset, a button width and where the
/// two-column rows break — every other measurement in the Figma is identical.
/// A second file would be the same 200 lines with three numbers changed, and
/// the two would drift. The differences live in `CreateDatabaseMetrics`; this
/// file reads them.
///
/// Compare `EmployeesResponsivePage`, which does use `ResponsiveHelper` with
/// separate mobile/tablet trees — correct there, because those two screens
/// really are different screens (a drawer vs a nested Navigator).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/create_database_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_form_card.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';

class CreateDatabasePage extends StatefulWidget {
  const CreateDatabasePage({
    super.key,
    this.createdBy,
    this.isStepped = false,
    this.onNext,
    this.onCompleted,
    this.onExit,
    this.cubit,
  });

  /// Employee id stamped on the record. Passed in rather than resolved from a
  /// controller here so the page stays testable and the presentation layer
  /// keeps out of the employee module.
  final String? createdBy;

  /// When true the primary button reads "Next" instead of "Create" — the
  /// landscape Figma frame's multi-step variant, which continues into table
  /// creation. Default is the single-step "Create".
  final bool isStepped;

  /// Called once the details validate, so the flow host can push the Access
  /// Management screen. Left null until that screen exists — the cubit has
  /// already advanced its `step` either way, so nothing is lost.
  final void Function(CreateDatabaseCubit cubit)? onNext;

  /// Called when Personal Access creates the record straight from this screen —
  /// that branch never reaches the Review page, so this screen is where the
  /// flow ends. Same contract as the Review page's `onCompleted`.
  final ValueChanged<DatabaseEntity>? onCompleted;

  /// Leaves the wizard entirely and returns to the Database Builder list.
  ///
  /// THIS PAGE IS THE FIRST ROUTE OF THE FLOW'S INNER NAVIGATOR, which makes
  /// popping locally wrong in two different ways:
  ///
  ///   `Navigator.of(context).maybePop()` does NOTHING. A Navigator's first
  ///   route reports `RoutePopDisposition.bubble` — "not mine to pop, ask my
  ///   parent" — and maybePop honours that by declining.
  ///
  ///   `Navigator.of(context).pop()` FORCES it, so the inner Navigator drops
  ///   to zero routes and renders nothing. That is the blank screen.
  ///
  /// Leaving the wizard means popping the MODULE's navigator, one level up,
  /// which only the flow host can address. Hence a callback.
  ///
  /// Null when this page is used standalone; then it really is the top route
  /// and a local pop is correct.
  final VoidCallback? onExit;

  /// Supplied by [CreateDatabaseFlow] so all three steps share one draft.
  /// Null means this page is being used standalone and owns its own cubit —
  /// which is what makes it usable on its own for a quick layout check.
  final CreateDatabaseCubit? cubit;

  @override
  State<CreateDatabasePage> createState() => _CreateDatabasePageState();
}

class _CreateDatabasePageState extends State<CreateDatabasePage> {
  /// The flow's cubit when hosted, otherwise one of our own.
  late final CreateDatabaseCubit _cubit = widget.cubit ?? CreateDatabaseCubit();

  /// Only close what we created — closing the flow's cubit here would tear
  /// the draft down the moment the user advanced to step 2.
  bool get _ownsCubit => widget.cubit == null;

  // Controllers are a widget concern, so they live here rather than in the
  // cubit. The cubit holds the values; these hold the cursor.
  //
  // SEEDED FROM THE CUBIT, not left empty (16/8/2026). A wizard reopened on a
  // parked draft arrives with its titles and descriptions already in state,
  // and blank controllers over that state are the worst of both: the fields
  // look empty, so the user retypes a name the record already has — or presses
  // Next on what looks like an empty form and it passes validation, because
  // the cubit knows values the screen never showed.
  //
  // On a new database every one of these is '', which is what it always was.
  late final TextEditingController _titleEn =
      TextEditingController(text: _cubit.state.titleEn);
  late final TextEditingController _titleAr =
      TextEditingController(text: _cubit.state.titleAr);
  late final TextEditingController _descriptionEn =
      TextEditingController(text: _cubit.state.descriptionEn);
  late final TextEditingController _descriptionAr =
      TextEditingController(text: _cubit.state.descriptionAr);

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  // ── Intents ────────────────────────────────────────────────────────────────

  /// Validates the details card, then either creates the record or moves on.
  ///
  /// The three access types are three different flows in the Figma:
  ///
  ///   PERSONAL    create right here — the database is the creator's own, so
  ///               there is nobody to pick. Confirm -> success.
  ///   RESTRICTED  push Access Management / Add Members.
  ///   OPEN        push Access Management / By Department.
  ///
  /// Which one is decided by the cubit (`skipsAccessStep`), not here, so the
  /// rule lives next to the state it reads.
  Future<void> _onPrimaryPressed() async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    final bool advanced = _cubit.validateDetailsAndAdvance(
      requiredEnMessage: strings.titleEnRequired,
      requiredArMessage: strings.titleArRequired,
      tooShortMessage: strings.titleTooShort,
      accessRequiredMessage: strings.accessRequired,
    );
    if (!advanced) return;

    // ── Personal Access: create from here ────────────────────────────────
    if (_cubit.skipsAccessStep) {
      await showConfirmDialog(
        context: context,
        title: strings.confirmCreateTitle,
        subtitle: strings.confirmCreateSubtitle,
        confirmLabel: strings.yes,
        cancelLabel: strings.no,
        onConfirm: () {
          _cubit.submit(
            requiredEnMessage: strings.titleEnRequired,
            requiredArMessage: strings.titleArRequired,
            tooShortMessage: strings.titleTooShort,
            // The reason the write was refused, not the dialog's heading.
            duplicateMessage: strings.duplicateTitle,
            accessRequiredMessage: strings.accessRequired,
            createdBy: widget.createdBy,
          );
        },
      );
      return;
    }

    // ── Restricted / Open: on to Access Management ───────────────────────
    final void Function(CreateDatabaseCubit)? next = widget.onNext;
    if (next != null) {
      next(_cubit);
      return;
    }

    // No host wired yet: say so rather than appearing to do nothing.
    // Was a snackbar; a dialog holds until acknowledged, so the message
    // cannot vanish before the user has read why nothing happened.
    if (!mounted) return;
    await showWarningDialog(
      context: context,
      title: strings.nextStepPendingTitle,
      subtitle: strings.nextStepPending,
      closeLabel: strings.close,
    );
  }

  /// Leaves the wizard: the host's hook when there is one, a local pop when
  /// this page is standalone.
  void _leave() {
    final VoidCallback? exit = widget.onExit;
    if (exit != null) {
      exit();
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _onDiscardPressed() async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    // An untouched form does not need a confirmation — the dialog would just
    // be friction on a mis-tap.
    if (!_cubit.state.isDirty) {
      if (mounted) _leave();
      return;
    }

    await showConfirmDialog(
      context: context,
      title: strings.discardConfirmTitle,
      subtitle: strings.discardConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () {
        _cubit.reset();
        _titleEn.clear();
        _titleAr.clear();
        _descriptionEn.clear();
        _descriptionAr.clear();
        _leave();
      },
    );
  }

  /// Runs on every state change: shows the success dialog once, surfaces a
  /// failure once, then clears the flag so a rebuild cannot repeat either.
  Future<void> _onStateChanged(
    BuildContext context,
    CreateDatabaseState state,
  ) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);

    if (state.status == CreateDatabaseStatus.failure &&
        state.errorMessage != null) {
      // Was a red snackbar. The failure reason (duplicate title, validation)
      // is something the user has to act on, so it now holds the screen until
      // it is acknowledged.
      //
      // The message is read and the flag cleared BEFORE the dialog is awaited,
      // exactly as the snackbar did: clearing afterwards would leave the
      // failure state live for as long as the dialog is open, and the next
      // emission would re-open it.
      final String message = state.errorMessage!;
      _cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    if (state.status == CreateDatabaseStatus.success) {
      await showSuccessDialog(
        context: context,
        title: strings.successTitle,
        subtitle: strings.successSubtitle,
        closeLabel: strings.close,
      );
      if (!mounted) return;
      final DatabaseEntity? created = state.createdDatabase;
      final ValueChanged<DatabaseEntity>? done = widget.onCompleted;
      if (created == null) return;
      if (done != null) {
        done(created);
      } else {
        // Standalone use (no flow host): pop with the record.
        Navigator.of(context).maybePop<DatabaseEntity>(created);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // The phone gate that used to stand here is gone (15/8/2026): the mobile
    // band of the Figma section is implemented, and every piece of this
    // screen already reflows — `buildResponsiveFields` stacks the EN/AR pairs
    // below 600px and `SideFrameMasterServices` swaps its breadcrumb for the
    // back-chevron + title header. Nothing about this page is tablet-only any
    // more, so refusing to draw it on a phone would just be a stale rule.
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final CreateDatabaseMetrics metrics = CreateDatabaseMetrics.of(context);

    return BlocProvider<CreateDatabaseCubit>.value(
      value: _cubit,
      child: BlocConsumer<CreateDatabaseCubit, CreateDatabaseState>(
        bloc: _cubit,
        listener: _onStateChanged,
        builder: (BuildContext context, CreateDatabaseState state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            // The breadcrumb ("Database  >  Create New Database") and the
            // scroll behaviour both come from the shared page shell, so this
            // screen's chrome cannot drift from the rest of the app.
            body: SideFrameMasterServices(
              titleText: strings.database,
              secondTitle: strings.createNewDatabase,
              // NOT a local pop: see [onExit]. This page is the inner
              // Navigator's first route, so maybePop declines (bubble) and
              // pop() empties the navigator.
              onFirstTap: _leave,
              // SideFrameMasterServices hands its child a BOUNDED height
              // (`Expanded(child: child!)` in that widget), so a fixed-height
              // Column overflows the moment the content is one pixel taller
              // than the viewport — the "BOTTOM OVERFLOWED BY 1.3 PIXELS"
              // stripe. Scrolling is the fix rather than shaving a gap: the
              // card grows with the description boxes and the member list, so
              // no fixed height would hold for long.
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CreateDatabaseFormCard(
                      metrics: metrics,
                      state: state,
                      cubit: _cubit,
                      titleEnController: _titleEn,
                      titleArController: _titleAr,
                      descriptionEnController: _descriptionEn,
                      descriptionArController: _descriptionAr,
                    ),
                    SizedBox(height: metrics.cardToActions),
                    CreateDatabaseActions(
                      metrics: metrics,
                      discardLabel: strings.discard,
                      // Personal Access creates on press, so it reads
                      // "Create"; the other two continue to Access
                      // Management, so they read "Next". The label follows
                      // the branch rather than the orientation.
                      primaryLabel: _cubit.skipsAccessStep
                          ? strings.create
                          : (widget.isStepped ? strings.next : strings.create),
                      onDiscard: _onDiscardPressed,
                      onPrimary: _onPrimaryPressed,
                      isSubmitting: state.isSubmitting,
                      // Grey until both titles are long enough and an access
                      // type is chosen. Description and cover stay optional —
                      // neither is validated on submit either.
                      isPrimaryEnabled: state.canAdvanceDetails,
                    ),
                    SizedBox(height: metrics.blockGap),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
