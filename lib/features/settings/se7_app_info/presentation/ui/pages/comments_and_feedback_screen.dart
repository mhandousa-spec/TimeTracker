/// Module: settings/se7_app_info
///
///*************************** FILE INFO ****************************///
/// File Name: comments_and_feedback_screen.dart
/// Purpose: "Comments and Feedbacks" — the employee's own submissions above,
///          and the form that adds another below.
/// Author: Knowticed Plus team
/// Updated: 2/9/2026 - Rebuilt against Figma (MESBAH, node 4717:8596). Three
///          changes:
///
///   1. THE TWO HALVES ARE NOW TABS. The list and the form used to be stacked,
///      so reaching Submit meant scrolling past every request already filed.
///      [CustomSegmentedTabs] switches between "New Request" and "Requested
///      Feedback", and the Submit button only exists under the first.
///   2. EXPAND / HIDE PER BOX. Ticking a box opens its form; the link on the
///      right of the row folds it away again while keeping the tick. Three
///      open forms at once was most of the screen's height.
///   3. THE "MORE OPTIONS" PANEL. Seven triage dropdowns and a "Steps to
///      reproduce" box, collapsed by default, in
///      [FeedbackMoreOptionsPanel]. All of it optional and none of it gates
///      Submit — see [hasAnyData], which still only wants a ticked box with
///      text in it.
///
/// Updated: 1/9/2026 - Rebuilt against Figma (MESBAH, nodes 7628:8180 and
///          7628:7681). Four changes, in rough order of size:
///
///   1. THE LIST IS NEW. The screen was write-only: you submitted and never
///      saw it again. "Request Details" now sits above the form — All / Open /
///      Fixed / Closed chips, a search box, a sort menu and a card per
///      submission — fed by [CommentsFeedbackCubit].
///   2. MANY ATTACHMENTS PER BOX. Picking a second file used to REPLACE the
///      first. Files are now a growing 2-column grid with the "Attach
///      Document" button as its last cell, which is what the design draws.
///   3. A PRIORITY PER BOX. New field, written to the submission document.
///   4. The middle box is labelled "Improvements To Existing Feature", not
///      "Comments And Feedback". Presentation only — the stored `type` is
///      still `'comment'`, so existing documents keep counting.
///
/// FIXED in the same pass: the tablet branch used to `return Expanded(...)`
/// while `settings_layout.dart` ALREADY wraps this screen in an `Expanded`.
/// Two ParentDataWidgets writing the same Flex slot is an "Incorrect use of
/// ParentDataWidget" error, not a layout preference. The branch now returns a
/// plain Column and lets the caller own the Expanded.
///
/// ALSO FIXED: a successful submit called `Get.back()` unconditionally. On
/// tablet this screen is an embedded pane, not a pushed route, so that popped
/// the settings shell out from under the user. It now pops only on the phone
/// layout, where the screen really is a route.

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart' show showConfirmDialog;
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_request_details_view.dart';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/23-custom_check_box.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/9-filter_tab_with_container.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/controller/settings_controller.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/controller/comments_feedback_cubit.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/controller/comments_feedback_state.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_attachments_grid.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_display.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_more_options_panel.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_priority_dropdown.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/presentation/ui/widgets/feedback_request_card.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Chip keys. Strings because [StatusChipFilter] is keyed by string; the enum
/// is the source of truth and [_filterFromKey] is the only place they meet.
const String _kChipAll = 'All';

class CommentsAndFeedbackScreen extends StatelessWidget {
  const CommentsAndFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentsFeedbackCubit>(
      create: (_) => CommentsFeedbackCubit()..load(),
      child: const CommentsAndFeedbackView(),
    );
  }
}

class CommentsAndFeedbackView extends StatefulWidget {
  const CommentsAndFeedbackView({super.key});

  @override
  State<CommentsAndFeedbackView> createState() =>
      _CommentsAndFeedbackViewState();
}

class _CommentsAndFeedbackViewState extends State<CommentsAndFeedbackView> {
  /// One controller per box, keyed by kind so the three boxes stop being three
  /// near-identical blocks of copy-pasted code.
  final Map<FeedbackKind, TextEditingController> _controllers =
      <FeedbackKind, TextEditingController>{
    for (final FeedbackKind kind in FeedbackKind.values)
      kind: TextEditingController(),
  };

  /// One "Steps to reproduce" controller per box, same reasoning as
  /// [_controllers] — owned here so each is created and disposed exactly once.
  ///
  /// No listener on these. The Submit button's enabled state does not depend
  /// on the steps text (it is optional), so a keystroke here has nothing to
  /// rebuild — unlike [_controllers], which does drive [hasAnyData].
  final Map<FeedbackKind, TextEditingController> _stepsControllers =
      <FeedbackKind, TextEditingController>{
    for (final FeedbackKind kind in FeedbackKind.values)
      kind: TextEditingController(),
  };

  /// Which boxes are ticked. All start unticked.
  final Set<FeedbackKind> _selectedKinds = <FeedbackKind>{};

  /// Which ticked boxes are showing their form.
  ///
  /// SEPARATE from [_selectedKinds] on purpose: the design's "Hide" link folds
  /// a box away WITHOUT unticking it, so the text and files the user already
  /// entered survive. Ticking a box adds it to both sets; unticking removes it
  /// from both and discards its content.
  final Set<FeedbackKind> _expandedKinds = <FeedbackKind>{};

  /// Which boxes have their "More Options" panel open. Independent of
  /// [_expandedKinds] so folding a box away and reopening it does not also
  /// reset the panel the user had deliberately opened.
  final Set<FeedbackKind> _moreOptionsKinds = <FeedbackKind>{};

  /// The "More Options" answers per box. A box gets an entry the moment it is
  /// ticked, so [FeedbackMoreOptionsPanel] never has to handle a null.
  final Map<FeedbackKind, FeedbackDetails> _details =
      <FeedbackKind, FeedbackDetails>{};

  /// Which tab is showing: 0 = the form, 1 = the list of past submissions.
  ///
  /// Starts on the form. This screen is reached from a settings row called
  /// "Comments and Feedbacks", and the reason someone opens it is almost
  /// always to file something rather than to review what they already filed.
  int _tabIndex = 0;

  /// ADDED 21/9/2026 — a card opens Request Details as its OWN page with
  /// the "Settings › Comments And Feedbacks › Request Details" breadcrumb,
  /// the same way the Watermark row opens its page (a push on the settings
  /// pane's navigator), rather than swapping content under the tabs.
  void _openRequest(BuildContext context, FeedbackRequest request) =>
      openFeedbackRequestDetailsPage(context, request);

  /// Files already uploaded for each box, in the order they were added.
  ///
  /// CHANGED 1/9/2026 — was one attachment per kind, replaced on every pick.
  final Map<FeedbackKind, List<FeedbackAttachment>> _attachments =
      <FeedbackKind, List<FeedbackAttachment>>{};

  final Map<FeedbackKind, FeedbackPriority> _priorities =
      <FeedbackKind, FeedbackPriority>{};

  /// Which upload is in flight, or null. Only one at a time — Submit is
  /// blocked meanwhile so a document cannot be written without the file that
  /// was meant to be on it.
  FeedbackKind? _uploadingKind;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in _controllers.values) {
      controller.addListener(_onBodyChanged);
    }
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers.values) {
      controller.removeListener(_onBodyChanged);
      controller.dispose();
    }
    for (final TextEditingController controller in _stepsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// The Submit button's enabled state depends on the text, so every keystroke
  /// has to rebuild. Guarded against a rebuild after dispose.
  void _onBodyChanged() {
    if (mounted) setState(() {});
  }

  // ── Submit gating ─────────────────────────────────────────────────────────

  /// A box counts only when it is ticked AND has non-whitespace text — the
  /// same rule [AppFeedback.bodies] applies on the way to Firestore.
  bool _hasBody(FeedbackKind kind) =>
      _selectedKinds.contains(kind) &&
      (_controllers[kind]?.text.trim().isNotEmpty ?? false);

  bool get hasAnyData {
    // An upload in flight blocks submit: the write must not go out before the
    // file that belongs on it has a URL.
    if (_uploadingKind != null) return false;
    return FeedbackKind.values.any(_hasBody);
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  /// Function Name: [_submit]
  ///
  /// Purpose: Persist whatever the user filled in, then confirm.
  ///
  /// Parameters:
  /// - [cubit]: does the write and refreshes the list behind the dialog.
  /// - [popOnSuccess]: true on the phone layout only. See the FILE INFO note.
  Future<void> _submit({
    required CommentsFeedbackCubit cubit,
    required bool isSubmitting,
    required bool popOnSuccess,
  }) async {
    if (isSubmitting || !hasAnyData) return;

    // ADDED 21/9/2026 — Settings bug report p.6: "where is the confirmation
    // dialog after press submit?". Every other request in Settings asks first;
    // this one wrote straight away.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: S.of(context).commentsAndFeedbacks,
      subtitle: S.of(context).are_you_sure_submit_request,
      confirmLabel: S.of(context).yes,
      cancelLabel: S.of(context).no,
      lottieAsset:
          'assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json',
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    AppControllers.haptic.triggerHapticFeedback(
      vibration: VibrateType.mediumImpact,
      hapticFeedback: HapticFeedback.mediumImpact,
    );

    // Guarded rather than a bare `Get.find`: this screen is also reachable
    // through `Routes.settingsCommentsAndFeedback`, where the settings shell
    // may never have been built. Same pattern `settings_screen.dart` uses.
    final employee = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().employee
        : null;

    final AppFeedback feedback = AppFeedback(
      employeeId: employee?.id ?? '',
      employeeName:
          '${employee?.firstName?.lastOrNull ?? ''} ${employee?.lastName?.lastOrNull ?? ''}'
              .trim(),
      employeeEmail: employee?.email?.lastOrNull ?? '',
      bug: _bodyFor(FeedbackKind.bug),
      comment: _bodyFor(FeedbackKind.comment),
      featureRequest: _bodyFor(FeedbackKind.featureRequest),
      // AppFeedback drops anything belonging to a box that was left empty or
      // unticked, so these can be passed whole.
      attachments: _attachments,
      priorities: _priorities,
      details: _detailsForSubmit(),
    );

    final Failure? failure = await cubit.submit(feedback);

    if (!mounted) return;

    if (failure != null) {
      // The raw Firestore message is not shown — it is not something a user
      // can act on. showMessage (not showSuccess) because a failure must stay
      // on screen until dismissed.
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).anErrorOccurred,
      );
      return;
    }

    await CustomDialogManager.showSuccess(
      context: context,
      lottiePath:
          'assets/lottie_assets/main_lottie_assets/lottie_successful.json',
      title: S.of(context).thanksForSharingYourFeedback,
      subtitle: S.of(context).weValueOurCustomersAndStriveToExceedTheirExpecta,
    );

    if (!mounted) return;

    // Clear the form so a second submission does not resend the first.
    for (final TextEditingController controller in _controllers.values) {
      controller.clear();
    }
    for (final TextEditingController controller in _stepsControllers.values) {
      controller.clear();
    }
    setState(() {
      _selectedKinds.clear();
      _expandedKinds.clear();
      _moreOptionsKinds.clear();
      _attachments.clear();
      _priorities.clear();
      _details.clear();
    });

    if (popOnSuccess) Get.back();
  }

  String _bodyFor(FeedbackKind kind) =>
      _hasBody(kind) ? _controllers[kind]!.text : '';

  /// Function Name: [_detailsForSubmit]
  ///
  /// Purpose: Fold each box's live "Steps to reproduce" text into its
  ///          [FeedbackDetails] on the way out.
  ///
  /// The steps controllers are NOT mirrored into [_details] on every
  /// keystroke — see the note on [FeedbackMoreOptionsPanel.stepsController].
  /// This is the one place the two are joined, which is why it runs at submit
  /// time rather than in a listener.
  ///
  /// Returns: an entry per ticked box. [AppFeedback.detailsByKind] then drops
  ///          the ones whose body is empty or whose panel is untouched, so
  ///          nothing here needs to filter.
  Map<FeedbackKind, FeedbackDetails> _detailsForSubmit() {
    return <FeedbackKind, FeedbackDetails>{
      for (final MapEntry<FeedbackKind, FeedbackDetails> entry
          in _details.entries)
        entry.key: entry.value.copyWith(
          stepsToReproduce: _stepsControllers[entry.key]?.text ?? '',
        ),
    };
  }

  // ── Attachments ───────────────────────────────────────────────────────────

  /// Function Name: [_pickAndUpload]
  ///
  /// Purpose: Pick ONE file for [kind] and put it in Storage straight away,
  ///          APPENDING it to that box's list.
  ///
  /// The upload runs on tap, not on submit. That leaves an orphan in the
  /// bucket if the user picks a file and then walks away — accepted, because
  /// the alternative is a Submit that silently stalls for the length of an
  /// upload with no way to tell whether the file was accepted.
  ///
  /// `withData: true` is required: on desktop and web `PlatformFile.path` is
  /// not something the storage call can use (it is null on web outright), and
  /// the repository takes bytes precisely so this works everywhere.
  Future<void> _pickAndUpload(CommentsFeedbackCubit cubit, FeedbackKind kind) async {
    if (_uploadingKind != null) return;

    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return; // cancelled

    final PlatformFile file = picked.files.first;
    final Uint8List? bytes = file.bytes;

    if (!mounted) return;

    if (bytes == null) {
      await CustomDialogManager.showMessage(
        context: context,
        lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).anErrorOccurred,
      );
      return;
    }

    setState(() => _uploadingKind = kind);

    final result = await cubit.uploadAttachment(
      kind: kind,
      fileName: file.name,
      bytes: bytes,
      contentType: _contentTypeOf(file.extension),
    );

    if (!mounted) return;

    setState(() => _uploadingKind = null);

    await result.fold(
      (Failure failure) async {
        await CustomDialogManager.showMessage(
          context: context,
          lottiePath: 'assets/lottie_assets/main_lottie_assets/error.json',
          title: S.of(context).unsuccessful,
          // The failure message is shown here, unlike on submit: the size
          // ceiling is the common case and it IS something the user can act on.
          subtitle: failure.errMessage,
        );
      },
      (FeedbackAttachment attachment) async {
        setState(() {
          (_attachments[kind] ??= <FeedbackAttachment>[]).add(attachment);
        });
      },
    );
  }

  /// Drops one file from a box.
  ///
  /// Clears the local reference only. The uploaded object is left in the
  /// bucket: deleting it here would need a Storage delete the user may not be
  /// permitted, and an unreferenced file is harmless.
  void _removeAttachment(FeedbackKind kind, int index) {
    final List<FeedbackAttachment>? files = _attachments[kind];
    if (files == null || index < 0 || index >= files.length) return;
    setState(() {
      files.removeAt(index);
      if (files.isEmpty) _attachments.remove(kind);
    });
  }

  /// A best-effort MIME type from the picked extension. Storage defaults to
  /// `application/octet-stream` without one, which makes an image download
  /// instead of previewing.
  String? _contentTypeOf(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
      case 'log':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return null;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    // Kept as the original screen had it: the settings shell embeds this pane
    // on anything wider than a phone, and pushes it as a route on a phone.
    final bool isEmbedded = MediaQuery.of(context).size.shortestSide > 600;

    return BlocBuilder<CommentsFeedbackCubit, CommentsFeedbackState>(
      builder: (BuildContext context, CommentsFeedbackState state) {
        final CommentsFeedbackCubit cubit =
            context.read<CommentsFeedbackCubit>();
        final CommentsFeedbackLoaded? loaded =
            state is CommentsFeedbackLoaded ? state : null;
        final bool isSubmitting = loaded?.isSubmitting ?? false;

        final Widget submitButton = _buildSubmitButton(
          context,
          cubit: cubit,
          isSubmitting: isSubmitting,
          popOnSuccess: !isEmbedded,
          isMobile: isMobile,
        );

        final bool isNewRequestTab = _tabIndex == 0;

        final Widget body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTabs(context),
            SizedBox(height: 15.h),
            // Only one of the two is built. An IndexedStack would keep the
            // hidden half alive, which sounds like it would preserve the
            // form — but the form's state already lives in this State object
            // and survives either way, while the list would go on holding a
            // GridView of cards nobody is looking at.
            if (isNewRequestTab)
              _buildNewRequestSection(
                context,
                cubit: cubit,
                isMobile: isMobile,
              )
            else
              _buildRequestDetailsSection(
                context,
                cubit: cubit,
                state: state,
                isMobile: isMobile,
              ),
          ],
        );

        if (isEmbedded) {
          // NO Expanded here — settings_layout.dart already wraps this widget
          // in one. See the FILE INFO note.
          return Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: body,
                ),
              ),
              // Submit belongs to the form, so it goes away with it. Leaving
              // it pinned under the request list would offer to send a form
              // the user cannot currently see.
              if (isNewRequestTab) ...<Widget>[
                SizedBox(height: 15.h),
                submitButton,
                SizedBox(height: 15.h),
              ],
            ],
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SideFrameMasterServices(
            titleText: S.of(context).settings,
            secondTitle: S.of(context).commentsAndFeedbacks,
            onFirstTap: () => Navigator.pop(context),
            onSecondTap: () => Navigator.pop(context),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  body,
                  if (isNewRequestTab) ...<Widget>[
                    SizedBox(height: 15.h),
                    submitButton,
                    SizedBox(height: 15.h),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────

  /// The "New Request / Requested Feedback" switch above both halves.
  ///
  /// [CustomSegmentedTabs] with `equalWidth: false`, so the pill hugs its two
  /// labels instead of stretching the width of the settings pane — the design
  /// draws it left-aligned and only as wide as its content.
  Widget _buildTabs(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: CustomSegmentedTabs(
        tabs: <String>[
          S.of(context).newRequest,
          S.of(context).requestedFeedback,
        ],
        selectedIndex: _tabIndex,
        onTabSelected: (int index) {
          if (index == _tabIndex) return;
          // lightImpact, not mediumImpact: [VibrateType] has no selection
          // tier, and switching a tab should not feel as consequential as
          // pressing Submit, which is what medium is used for below.
          AppControllers.haptic.triggerHapticFeedback(
            vibration: VibrateType.lightImpact,
            hapticFeedback: HapticFeedback.selectionClick,
          );
          setState(() => _tabIndex = index);
        },
        containerColor: AppColors.card,
        unselectedColor: AppColors.transparent,
      ),
    );
  }

  // ── Request Details ───────────────────────────────────────────────────────

  Widget _buildRequestDetailsSection(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required CommentsFeedbackState state,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,

          decoration: BoxDecoration(

            borderRadius: BorderRadius.circular(8.r),
          ),
          child: _buildRequestDetailsBody(
            context,
            cubit: cubit,
            state: state,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestDetailsBody(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required CommentsFeedbackState state,
    required bool isMobile,
  }) {
    if (state is CommentsFeedbackLoading || state is CommentsFeedbackInitial) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(child: CircleProgressMaster()),
      );
    }

    // An error state is transient — the cubit re-emits the previous loaded
    // state straight after it — so anything that is not Loaded by now is a
    // frame in between and renders as nothing rather than as an error page.
    if (state is! CommentsFeedbackLoaded) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StatusChipFilter(
          selectedKey: _chipKey(state.selectedStatus),
          onSelected: (String key) => cubit.updateStatus(_filterFromKey(key)),
          items: <StatusChipItem>[
            StatusChipItem(
              key: _kChipAll,
              label: S.of(context).all,
              count: state.totalCount,
            ),
            for (final FeedbackStatus status in FeedbackStatus.values)
              StatusChipItem(
                key: status.wireValue,
                label: FeedbackDisplay.statusLabel(context, status),
                count: state.counts[status] ?? 0,
                labelColor: FeedbackDisplay.statusColor(status),
              ),
          ],
        ),
        SizedBox(height: 15.h),
        Row(
          children: <Widget>[
            // AppSearchTextField returns an Expanded of its own, so it must sit
            // directly in this Row and must not be wrapped again.
            AppSearchTextField(
              controller: cubit.searchController,
              onChanged: (_) {},
            ),
            SizedBox(width: 9.w),
            // CustomSortButton, the app's shared sort control, in place of
            // the local FeedbackSortMenu popup — same options, same two
            // labels, but the toolbar button now matches Requests and every
            // other sort in the app (it paints itself primary while a sort is
            // active and highlights the live row in its menu).
            CustomSortButton<FeedbackSortOption>(
              value: state.sortOption,
              items: FeedbackSortOption.values,
              labelBuilder: (FeedbackSortOption option) =>
                  option == FeedbackSortOption.ascending
                      ? S.of(context).ascending
                      : S.of(context).descending,
              title: S.of(context).sort,
              // Glyph only on phone, glyph + label above — what `compact` did.
              showTitle: !isMobile,
              width: isMobile ? 38.w : 100.w,
              height: 38.sp,
              onChanged: (FeedbackSortOption? option) {
                // CustomSortButton hands back null when the ACTIVE option is
                // tapped again (its toggle-off). The cubit has no "unsorted"
                // state — CommentsFeedbackLoaded.copyWith resolves a null
                // sortOption back to the current one — so that tap is a no-op
                // rather than something to forward.
                if (option != null) cubit.updateSort(option);
              },
            ),
          ],
        ),
        SizedBox(height: 15.h),
        if (state.displayedItems.isEmpty)
          _buildEmptyState(context)
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: state.displayedItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              // Fixed rather than an aspect ratio: the card's content is three
              // single-line rows, so its height does not scale with its width.
              mainAxisExtent: 104.h,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
            ),
            itemBuilder: (BuildContext context, int index) =>
                FeedbackRequestCard(
                  request: state.displayedItems[index],
                  // 21/9/2026 — cards open the Request Details page (in the
                  // pane on tablet / desktop, pushed on a phone).
                  onTap: () =>
                      _openRequest(context, state.displayedItems[index]),
                ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Center(
        child: Lottie.asset(
          'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
          width: 180.sp,
          height: 180.sp,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
        ),
      ),
    );
  }

  static String _chipKey(FeedbackStatusFilter filter) {
    switch (filter) {
      case FeedbackStatusFilter.all:
        return _kChipAll;
      case FeedbackStatusFilter.open:
        return FeedbackStatus.open.wireValue;
      case FeedbackStatusFilter.fixed:
        return FeedbackStatus.fixed.wireValue;
      case FeedbackStatusFilter.closed:
        return FeedbackStatus.closed.wireValue;
    }
  }

  static FeedbackStatusFilter _filterFromKey(String key) {
    if (key == FeedbackStatus.open.wireValue) return FeedbackStatusFilter.open;
    if (key == FeedbackStatus.fixed.wireValue) {
      return FeedbackStatusFilter.fixed;
    }
    if (key == FeedbackStatus.closed.wireValue) {
      return FeedbackStatusFilter.closed;
    }
    return FeedbackStatusFilter.all;
  }

  // ── New Request ───────────────────────────────────────────────────────────

  Widget _buildNewRequestSection(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required bool isMobile,
  }) {
    // No "New Request" caption here any more — the tab above the section
    // already says it, and the design does not draw it twice.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(15.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CustomSvgImage(
                    assetPath:
                        'assets/icons_assets/settings_assets/feedback_stamp.svg',
                    width: 25.w,
                    height: 25.h,
                    fit: BoxFit.fill,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      S.of(context).commentsAndFeedbacks,
                      style: StyleText.fontSize20Weight600
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              for (final FeedbackKind kind in FeedbackKind.values)
                _buildKindBox(context, cubit: cubit, kind: kind, isMobile: isMobile),
            ],
          ),
        ),
      ],
    );
  }

  /// One of the three boxes: the tick with its Expand / Hide link, and — while
  /// expanded — the text area, its attachments, its priority and the collapsed
  /// "More Options" panel.
  ///
  /// Note the two different flags. [isSelected] decides whether the box is
  /// SENT; [isExpanded] decides only whether it is DRAWN. A box that is ticked
  /// but folded away still submits, which is the point of the Hide link.
  Widget _buildKindBox(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required FeedbackKind kind,
    required bool isMobile,
  }) {
    final bool isSelected = _selectedKinds.contains(kind);
    final bool isExpanded = isSelected && _expandedKinds.contains(kind);
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final List<FeedbackAttachment> files =
        _attachments[kind] ?? const <FeedbackAttachment>[];
    final bool isUploading = _uploadingKind == kind;
    final bool isBlocked = _uploadingKind != null && _uploadingKind != kind;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildCheckboxRow(
          context,
          title: FeedbackDisplay.kindLabel(context, kind),
          isSelected: isSelected,
          // The Expand / Hide link only appears once the box is ticked —
          // there is nothing to expand before that, and the design does not
          // draw it on an unticked row.
          isExpanded: isExpanded,
          onToggleExpanded:
              isSelected ? () => _setExpanded(kind, !isExpanded) : null,
          onChanged: (bool value) {
            setState(() {
              if (value) {
                _selectedKinds.add(kind);
                // Ticking opens the box: the user ticked it in order to fill
                // it in, and making them press "Expand" as a second step to
                // reach a field they just asked for is a step for nothing.
                _expandedKinds.add(kind);
                _details.putIfAbsent(kind, () => const FeedbackDetails());
              } else {
                // Unticking discards the box entirely — text, files,
                // priority and the whole More Options panel. Leaving them
                // behind would let an invisible attachment or a stale module
                // ride along on the next submit.
                _selectedKinds.remove(kind);
                _expandedKinds.remove(kind);
                _moreOptionsKinds.remove(kind);
                _controllers[kind]?.clear();
                _stepsControllers[kind]?.clear();
                _attachments.remove(kind);
                _priorities.remove(kind);
                _details.remove(kind);
              }
            });
          },
        ),
        if (isExpanded) ...<Widget>[
          // CHANGED 8/9/2026: was 8.h. The row above already carries 8.h of
          // its own bottom padding, so the tick and the box it belongs to were
          // 16.h apart and read as two unrelated controls.
          SizedBox(height: 2.h),
          CustomTextField(
            hint: S.of(context).textHere,
            controller: _controllers[kind],
            maxLines: 3,
            // Figma draws a "0/500" counter under the box.
            maxLength: 500,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          SizedBox(height: 12.h),
          _buildAttachmentsAndPriority(
            context,
            cubit: cubit,
            kind: kind,
            files: files,
            isMobile: isMobile,
          ),
          SizedBox(height: 12.h),
          FeedbackMoreOptionsPanel(
            // Non-null because ticking the box seeds the map above, but
            // defaulted anyway: a box restored from some future draft state
            // must not crash the form on a missing entry.
            details: _details[kind] ?? const FeedbackDetails(),
            isExpanded: _moreOptionsKinds.contains(kind),
            enabled: !isUploading && !isBlocked,
            isMobile: isMobile,
            stepsController: _stepsControllers[kind]!,
            onToggle: () {
              setState(() {
                if (!_moreOptionsKinds.remove(kind)) {
                  _moreOptionsKinds.add(kind);
                }
              });
            },
            onChanged: (FeedbackDetails updated) {
              setState(() => _details[kind] = updated);
            },
          ),
        ],
        // CHANGED 28/9/2026 (Settings bug report p.2): the LAST box no longer
        // adds this gap. It sat on top of the card's own 15.sp padding, so the
        // space under "Request New Feature" was far larger than the space
        // beside it; now the card's padding is equal on every side.
        if (kind != FeedbackKind.values.last) SizedBox(height: 15.h),
      ],
    );
  }

  /// Function Name: [_setExpanded]
  ///
  /// Purpose: Fold a ticked box's form away, or bring it back.
  ///
  /// Keeps the tick, the text, the files, the priority and the More Options
  /// answers — this is a display toggle, not a reset. Only unticking discards
  /// anything, which is the one place a user has clearly said they no longer
  /// want that box.
  void _setExpanded(FeedbackKind kind, bool expanded) {
    setState(() {
      if (expanded) {
        _expandedKinds.add(kind);
      } else {
        _expandedKinds.remove(kind);
      }
    });
  }

  /// Figma draws two variants of this block, and both are here:
  ///
  ///  • nothing uploaded yet → the "Attach Document" button and the Priority
  ///    field share one row, one column each;
  ///  • one or more files → the attachments take the full two-column width and
  ///    Priority drops to its own row underneath.
  ///
  /// On a phone everything is one column, so the row never applies.
  Widget _buildAttachmentsAndPriority(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required FeedbackKind kind,
    required List<FeedbackAttachment> files,
    required bool isMobile,
  }) {
    final bool isUploading = _uploadingKind == kind;
    final bool isBlocked = _uploadingKind != null && _uploadingKind != kind;

    final Widget grid = FeedbackAttachmentsGrid(
      attachments: files,
      isUploading: isUploading,
      isBlocked: isBlocked,
      columns: isMobile ? 1 : 2,
      onAdd: () => _pickAndUpload(cubit, kind),
      onRemove: (int index) => _removeAttachment(kind, index),
    );

    final Widget priority = FeedbackPriorityDropdown(
      value: _priorities[kind],
      // Changing priority mid-upload is harmless, but keeping the whole block
      // inert while a file is in flight matches the attach button beside it.
      enabled: !isUploading && !isBlocked,
      // TAP-TO-CLEAR, added 8/9/2026. Choosing the priority that is already
      // selected clears it, matching the seven dropdowns in the More Options
      // panel below.
      //
      // FeedbackPriorityDropdown's own note explains why the comparison lives
      // here: CustomDropdown.onChanged is `ValueChanged<T>` and can only ever
      // report a CHOSEN item, so it cannot express "none" on its own.
      // Removing the key rather than storing null keeps `_priorities` meaning
      // exactly "boxes that have a priority", which is what _detailsForSubmit
      // reads. Unticking the box still drops it too, via _buildKindBox.
      onChanged: (FeedbackPriority value) {
        setState(() {
          if (_priorities[kind] == value) {
            _priorities.remove(kind);
          } else {
            _priorities[kind] = value;
          }
        });
      },
    );

    if (!isMobile && files.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: FeedbackAttachmentsGrid(
              attachments: files,
              isUploading: isUploading,
              isBlocked: isBlocked,
              // One column: this grid is already sharing the row with Priority.
              columns: 1,
              onAdd: () => _pickAndUpload(cubit, kind),
              onRemove: (int index) => _removeAttachment(kind, index),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(child: priority),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        grid,
        SizedBox(height: 12.h),
        // Half width on tablet so it lines up with the grid's first column
        // instead of stretching across both.
        if (isMobile)
          priority
        else
          FractionallySizedBox(
            widthFactor: 0.5,
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 7.5.w),
              child: priority,
            ),
          ),
      ],
    );
  }

  /// The tick, its label, and — once ticked — the Expand / Hide link.
  ///
  /// The link is a SEPARATE tap target inside the row rather than part of it:
  /// the row's own tap toggles the tick, and pressing "Hide" must not also
  /// untick the box it is hiding. That is why the label is wrapped in its own
  /// [GestureDetector] with the row's [InkWell] stopping short of it.
  Widget _buildCheckboxRow(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required bool isExpanded,
    required ValueChanged<bool> onChanged,
    VoidCallback? onToggleExpanded,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () => onChanged(!isSelected),
              child: Row(
                children: <Widget>[
                  CustomCheckBox(
                    borderColor: Colors.grey,
                    isSelected: isSelected,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize16Weight500
                          .copyWith(color: AppColors.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onToggleExpanded != null)
            GestureDetector(
              onTap: onToggleExpanded,
              // Opaque so the padding around the short word is tappable too —
              // "Hide" is four characters and would otherwise be a 24pt
              // target.
              behavior: HitTestBehavior.opaque,
              // CHANGED 8/9/2026 — blue, with a rule under it, so the link
              // reads as a link. It was grey body text, indistinguishable
              // from the label on the other side of the row.
              //
              // The rule is a Container, not TextDecoration.underline: the
              // decoration sits hard against the glyphs with no way to offset
              // it, and the ask was a 3 gap. IntrinsicWidth is what keeps the
              // rule the width of the WORD — inside a Row the Column would
              // otherwise be handed unbounded width and `stretch` would have
              // nothing to measure against.
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        isExpanded
                            ? S.of(context).hide
                            : S.of(context).expand,
                        style: StyleText.fontSize13Weight500
                            .copyWith(color: AppColors.blue),
                      ),
                      SizedBox(height: 3.h),
                      // Raw 1, not 1.h: a hairline rule that scales below one
                      // logical pixel can drop out entirely on some densities.
                      Container(height: 1, color: AppColors.blue),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Submit button ─────────────────────────────────────────────────────────

  Widget _buildSubmitButton(
    BuildContext context, {
    required CommentsFeedbackCubit cubit,
    required bool isSubmitting,
    required bool popOnSuccess,
    required bool isMobile,
  }) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final bool enabled = hasAnyData && !isSubmitting;

    // CHANGED 8/9/2026 — Submit spans the full width of the form.
    //
    // It used to be `wrapContent: true` inside a centring Row, so the button
    // hugged its label and sat as a short pill under a full-width form.
    //
    // The Row is gone rather than kept: a Row hands its non-flex children
    // UNBOUNDED width, so a `width: double.infinity` inside one resolves to
    // infinity and throws. Both call sites drop this straight into a Column
    // (see the isEmbedded branch and the Scaffold branch above), which does
    // pass a bounded width down, so the button can simply take it.
    //
    // `width:` and not `fullWidth:` — customButton honours the former directly
    // and discards the latter; its own SCOPE note in 5-custom_button.dart says
    // so. Passing `fullWidth` here would silently leave the fixed width in
    // place.
    return Center(child: customButton(
      title: S.of(context).submit,
      function: enabled
          ? () => _submit(
                cubit: cubit,
                isSubmitting: isSubmitting,
                popOnSuccess: popOnSuccess,
              )
          : () {}, // Empty function instead of null
      // CHANGED 21/9/2026 — Settings bug report p.17/p.18: the full-width bar
      // is narrowed to a centred button (see the Center wrapper below).
      width: isMobile ? double.infinity : 300.sp,
      height: 38.h,
      radius: 4.r,
      color: enabled
          ? AppColors.primary
          : lightMode
              ? Colors.grey[400]
              : Colors.grey[700],
      textStyle: StyleText.fontSize16Weight500.copyWith(
        color: enabled
            ? AppColors.textButton
            : AppColors.black,
      ),
    ));
  }
}
