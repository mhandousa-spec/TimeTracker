import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_routing.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart'; // Keep for .tr translations
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/custom/62-custom_date_time_helper.dart';
import 'package:knowticed_plus/features/form_builder_module/f8_convert_pdf/presentation/controller/pdf_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/enums/form_state.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/constants/space_helper.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_breadcrumb_nav.dart';
import 'package:knowticed_plus/core/helper/form_builder/submitted_page_viewer.dart'
    show SubmittedPageViewer;
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/presentation/controller/fill_out_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/presentation/controller/home_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/controller/submission_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f5_submissions/presentation/controller/submission_state.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/form_builder_module/form_builder_title_padding.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/messaging_interface_implementation.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
class FormSubmissionsScreen extends StatefulWidget {
  const FormSubmissionsScreen({super.key, required this.model, required this.name});

  final FormEntity model;
  final String name;

  @override
  State<FormSubmissionsScreen> createState() => _FormSubmissionsScreenState();
}

class _FormSubmissionsScreenState extends State<FormSubmissionsScreen> {
  // Form validation state lives in the page, not the cubit (§16).
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const double a4PortraitWidth = 794.0;
  static const double a4PortraitHeight = 1123.0;
  static const double a4LandscapeWidth = 1123.0;
  static const double a4LandscapeHeight = 794.0;

  /// Bug report #16/#22: Submit stays locked until every required field is
  /// answered. Answers live on the field controllers (several fields write
  /// them without telling anyone), so the page re-checks on every change it
  /// hears about AND on a light 400ms tick.
  bool _canSubmit = false;
  Timer? _canSubmitTicker;

  void _recheckCanSubmit() {
    if (!mounted) return;
    final bool now =
        context.read<FormSubmissionsCubit>().allRequiredAnswered;
    if (now != _canSubmit) setState(() => _canSubmit = now);
  }

  @override
  void dispose() {
    _canSubmitTicker?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _canSubmitTicker = Timer.periodic(
        const Duration(milliseconds: 400), (_) => _recheckCanSubmit());
    // Initialize the cubit with the model
    context.read<FormSubmissionsCubit>().init(model: widget.model);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PdfCubit>().initialize(widget.model.pages.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED 19/8/2026 — one header for both form factors, drawn by
    // SideFrameMasterServices, replacing the CustomAppBar / PaginationAppBar
    // pair. The crumbs also move OUT of the SubmissionsLoaded branch, so the
    // header is present while the submission is still loading.
    return Scaffold(
      body: SideFrameMasterServices(
        titlePadding: formBuilderTitlePadding,
        titleText: S.of(context).services_app,
        // Bug report #18: Form Builder > Submissions > <form name>.
        secondTitle: S.of(context).submissions,
        thirdTitle: widget.model.getTitle,
        onFirstTap: breadcrumbPop(context, 1),
        onSecondTap: breadcrumbPop(context, 1),
      // ✅ EXACTLY LIKE ConvertPdfScreen - SingleChildScrollView with Container margin
      child: SingleChildScrollView(
        child: Container(
          // ✅ CRITICAL: Use MARGIN like ConvertPdfScreen, NOT padding
          margin: EdgeInsetsDirectional.only(
            start: 15.w,
            end: ContextExtension(context).isPhone ? 15.w : 121.w,  // ✅ Same as ConvertPdfScreen
          ),
          child: BlocBuilder<FillOutCubit, FillOutState>(
            builder: (context, fillOutState) {
              return BlocBuilder<FormSubmissionsCubit, SubmissionsState>(
                builder: (context, submissionsState) {
                  if (submissionsState is! SubmissionsLoaded) {
                    return const CircleProgressMaster();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(30),

                      // ✅ Form content - NO Center, NO width constraints on outer container
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Upper section
                            if (widget.name != "no")
                              _upperSection(context, submissionsState),

                            const SizedBox(height: 10),

                            // ✅ SubmittedPageViewer with proper A4 width based on orientation
                            SubmittedPageViewer(
                              model: widget.model,
                              pages: submissionsState.pages,
                              isReadOnly: submissionsState.isReadOnly,
                              isSubmitted: submissionsState.isSubmitted,
                              // ✅ Pass A4 width based on orientation
                              width: _getA4Width(),
                              onAnyChanged: _recheckCanSubmit,
                            ),

                            verticalSpace(15),

                            // Action buttons
                            if (_showActionsButtons(submissionsState))
                              Row(
                                children: [
                                  if (_showDiscardButton(submissionsState))
                                    _buildDiscardButton(context, submissionsState),
                                  const Spacer(),
                                  _buildSubmitButton(context, submissionsState),
                                ],
                              ),
                            verticalSpace(15),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      ),
    );
  }

  // ✅ NEW: Get A4 width based on form orientation
  double _getA4Width() {
    final orientation = widget.model.formHeadModel.orientation?.toLowerCase() ?? 'portrait';
    final isLandscape = orientation.contains('landscape');
    return isLandscape ? a4LandscapeWidth : a4PortraitWidth;
  }

  Widget _buildDiscardButton(BuildContext context, SubmissionsLoaded state) {
    return customButtonWithSvg(
      title: S.of(context).discard,
      function: state.isSubmitting ? () {} : () => context.pop(),
      textStyle: StyleText.fontSize16Weight500.copyWith(color: AppColors.black),
      color: AppColors.darkerGrey,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  Widget _buildSubmitButton(BuildContext context, SubmissionsLoaded state) {
    // Locked (dimmed, not tappable) until every required field is answered.
    return Opacity(
      opacity: _canSubmit ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !_canSubmit,
        child: _submitButtonCore(context, state),
      ),
    );
  }

  Widget _submitButtonCore(BuildContext context, SubmissionsLoaded state) {
    return customButtonWithSvg(
      // RESTORED 1/9/2026 — the label and the handler were both blanked out,
      // so the button rendered as an empty yellow box that did nothing.
      title: state.isSubmitting
          ? S.of(context).submitting
          : S.of(context).submit,
      function: state.isSubmitting
          ? () {}
          : () {
              final cubit = context.read<FormSubmissionsCubit>();

              // Custom (non-Form) validation lives in the cubit; the Form
              // widget's own validation stays here in the page (§16).
              final bool isCustomValid = cubit.prepareSubmit();
              if (_formKey.currentState!.validate() && isCustomValid) {
                cubit.submit(
                  context,
                  widget.model,
                  // An existing submission being re-sent is an edit; anything
                  // else is a first response. Only the notification copy
                  // differs.
                  widget.model.status == FormStatus.submissions,
                  context.read<HomeCubit>(),
                );
              }
            },
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.black),
      color: AppColors.primary,
      image: '',
      widthImage: 0,
      heightImage: 0,
      colorBorder: AppColors.transparent,
    );
  }

  bool _showDiscardButton(SubmissionsLoaded state) {
    if (widget.model.status == FormStatus.submissions && !state.isReadOnly) {
      return true;
    }
    return false;
  }

  Widget _upperSection(BuildContext context, SubmissionsLoaded state) {

    if (widget.model.status != FormStatus.submissions) {
      return Row(
        children: [
          if (widget.model.isEdit)
            customButtonWithSvg(
              title: S.of(context).editable,
              function: () {},
              textStyle: StyleText.fontSize14Weight500.copyWith(color: AppColors.secondaryBlack),
              color: AppColors.card,
              image: '',
              widthImage: 0,
              heightImage: 0,
              colorBorder: AppColors.transparent,
            ),
          const Spacer(),
          if (!_isOwnForm) _messageFormOwnerButton(),
        ],
      );
    } else if (widget.model.status == FormStatus.submissions) {
      return Row(
        children: [
          if (state.isReadOnly && widget.model.isEdit)
            _editButton(context, state),
          const Spacer(),
          Row(
            children: [
              Text(
                '${S.of(context).submissionDate}:',
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.spanText),
              ),
              Text(
                ' ${FormDateTimeHelper.formatDate(widget.model.submissionDate ?? DateTime.now())}',
                style: StyleText.fontSize12Weight400.copyWith(color: AppColors.fullBlack),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  /// True when the signed-in employee IS the form's owner.
  ///
  /// ADDED 1/9/2026. Messaging yourself is not a thing, and the messaging
  /// module agrees — its connection list is built from every OTHER app user,
  /// so your own email is never in it. Without this the button was shown and
  /// then failed with "Could not open the chat", which reads as a bug rather
  /// than as "that is you".
  bool get _isOwnForm {
    final String owner = (widget.model.requestedBy ?? '').trim().toLowerCase();
    final String me = (AppControllers.employee.employeeEntity?.email ?? '')
        .trim()
        .toLowerCase();
    return owner.isNotEmpty && owner == me;
  }

  Widget _messageFormOwnerButton() {
    return customButtonWithSvg(
      title: S.of(context).messageFormOwner,
      function: () => _openOwnerChat(context),
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: AppAssets.chat,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  /// Opens the one-to-one chat with the form's owner.
  ///
  /// FIXED 1/9/2026 — the button was wired to an empty `() {}`, so it drew
  /// itself and did nothing. The flow it needs already exists:
  /// `MessagingInterfaceImplementation.openChatWithUser` was added for exactly
  /// this case, a Message button on a screen OUTSIDE the messaging subtree.
  /// The obvious call, `ConnectionsCubit.selectConnection`, cannot be used
  /// from here — it does `context.read<SingleChatCubit>()`, and nothing above
  /// the form-builder module provides that cubit — so `openChatWithUser`
  /// resolves the messaging cubits from GetX (where `Dependency().init()`
  /// registered them at login) and pushes the chat on the ROOT navigator,
  /// clear of the module's own nested one.
  ///
  /// `model.requestedBy` is the owner's email, and email IS the messaging user
  /// id, so it goes straight in. `openChatWithUser` returns false when
  /// messaging never initialised this session or no employee record matches
  /// that email; the dialog is there so the tap says something instead of
  /// dead-ending.
  Future<void> _openOwnerChat(BuildContext context) async {
    final String ownerEmail = widget.model.requestedBy ?? '';
    // The reason a tap fails is always one of openChatWithUser's five guards;
    // it logs each under [openChatWithUser]. This line is the form side of it.
    log('[messageFormOwner] form "${widget.model.formHeadModel.title}" '
        'requestedBy="$ownerEmail" (id=${widget.model.id})');
    if (ownerEmail.isEmpty) {
      log('[messageFormOwner] ✗ this form has no requestedBy email');
      return;
    }

    // Bug report #19: on the desktop / tablet shell, go to the Messages
    // module (sidebar kept) with the owner's chat selected — the same route
    // the notification Message button takes. If the chat cannot be selected
    // (e.g. "no messaging profile"), still land on Messages rather than
    // stopping on an error dialog.
    final MessagingInterfaceImplementation messaging =
        MessagingInterfaceImplementation();
    final int messagesIndex = MediaQuery.of(context).size.width >= 600
        ? NotificationRouting.drawerCubit()
            .allowedDrawerModules
            .indexOf(Modules.messages)
        : -1;
    if (messagesIndex != -1) {
      final OpenChatResult result =
          await messaging.selectChatWithUser(userEmail: ownerEmail);
      log('[messageFormOwner] select chat → ${result.name}; opening Messages');
      NotificationRouting.drawerCubit().updateSelectedIndex(messagesIndex);
      return;
    }

    // Phone: push the chat. CHANGED 21/9/2026 — says WHY (e.g. you are the
    // form owner), localized, and closes itself after 3 s.
    final OpenChatResult result = await messaging.tryOpenChatWithUser(
        context: context, userEmail: ownerEmail);
    if (context.mounted) await showOpenChatFailure(context, result);
  }

  Widget _editButton(BuildContext context, SubmissionsLoaded state) {
    return customButtonWithSvg(
      title: S.of(context).edit,
      // ✅ Use empty function when submitting instead of null
      function: state.isSubmitting
          ? () {}
          : () {
              context.read<FormSubmissionsCubit>().editClicked();
            },
      textStyle: StyleText.fontSize16Weight500
          .copyWith(color: AppColors.textButton),
      color: AppColors.primary,
      image: AppAssets.edit,
      widthImage: 20,
      heightImage: 20,
      colorBorder: AppColors.transparent,
      svgColor: AppColors.textButton,
    );
  }

  bool _showActionsButtons(SubmissionsLoaded state) {
    if (widget.model.status != FormStatus.submissions ||
        (widget.model.status == FormStatus.submissions && !state.isReadOnly)) {
      return true;
    }
    return false;
  }
}