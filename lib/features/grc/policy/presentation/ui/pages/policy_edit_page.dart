/// Module: GRC Policy Management
/// Description: Full-page form for editing an existing Policy, opened from
///              the Policy Details page's Edit action. Its own route, but it
///              shares the Policy Details page's [PolicyCubit] instance
///              (handed down via `BlocProvider.value`) instead of resolving a
///              second one, so the two pages never diverge. Pops `true` on a
///              successful save so the Details page can refresh.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: flutter_bloc, PolicyCubit, PolicyEntity,
///               PolicyEditModeWidget
/// Revision History: 2026-07-18 - Split out of policy_details_page.dart's
///                                in-place edit mode into its own page.
library;

/// ************************* FILE INFO *************************** ///
/// File Name: policy_edit_page.dart
/// Purpose: Contains PolicyEditPage, the full-page edit form for a single
///          Policy.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 18/7/2026

import 'package:knowticed_plus/features/grc/shared/helpers/grc_document_picker.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'dart:io';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart'
    hide showUploadDialog;
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_form_fields.dart'
    show containsEnglishLetters, containsArabicLetters;
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_status.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/controller/policy_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/policy_details_widget/policy_edit_mode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../../../../../core/custom/52-custom_upload_document.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';

/// Stable signature of a document slot for change detection: nothing, the
/// stored URL, or a newly picked file (by identity).
String _docSignature(PolicyDocumentInfo? doc) {
  if (doc == null) return '-';
  if (doc.file != null) return 'file:${identityHashCode(doc.file)}';
  return 'url:${doc.url}';
}

String _daySignature(DateTime? d) =>
    d == null ? '-' : '${d.year}-${d.month}-${d.day}';

/// class name: [PolicyEditPage]
///
/// purpose: full-page form to edit an existing Policy's fields and its
///          Active/Inactive status. Prefills every field from [policy] on
///          open; pops `true` after a successful save so the caller can
///          refresh its own copy of the policy.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
class PolicyEditPage extends StatefulWidget {
  final String moduleId;
  final PolicyEntity policy;

  final GRCModuleEntity module;
  const PolicyEditPage({
    super.key,
    required this.moduleId,
    required this.policy,
    required this.module,
  });

  @override
  State<PolicyEditPage> createState() => _PolicyEditPageState();
}

class _PolicyEditPageState extends State<PolicyEditPage> {
  bool _submitted = false;

  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _numberController = TextEditingController();
  final _numberArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  PolicyDocumentInfo? _documentEn;
  PolicyDocumentInfo? _documentAr;
  File? _imageFile;
  String? _imageUrl;
  bool _statusInactive = false;
  bool _initialStatusInactive = false;
  bool _isArabicEnabled = true;

  @override
  void initState() {
    super.initState();
    final policy = widget.policy;
    _nameController.text = policy.policyNameEn;
    _nameArController.text = policy.policyNameAr;
    _numberController.text = policy.policyNumberEn;
    _numberArController.text = policy.policyNumberAr;
    _descriptionController.text = policy.policyDescriptionEn;
    _descriptionArController.text = policy.policyDescriptionAr;
    _weightController.text = policy.policyWeight.toStringAsFixed(0);
    _startDate = policy.startDate;
    _endDate = policy.endDate;
    _documentEn = policy.policyDocumentEn != null
        ? PolicyDocumentInfo.fromUrl(policy.policyDocumentEn!)
        : null;
    _documentAr = policy.policyDocumentAr != null
        ? PolicyDocumentInfo.fromUrl(policy.policyDocumentAr!)
        : null;
    _imageUrl = policy.policyImage;
    _statusInactive = policy.status == PolicyStatus.inactive;
    _initialStatusInactive = _statusInactive;
    // No stored toggle for this policy — infer it the same way the create
    // wizard does: on if any Arabic field was ever filled in.
    _isArabicEnabled = policy.policyNameAr.trim().isNotEmpty ||
        policy.policyNumberAr.trim().isNotEmpty ||
        policy.policyDescriptionAr.trim().isNotEmpty;
    _initialSignature = _formSignature();
  }

  /// Snapshot of every editable value, taken once the form is prefilled.
  late final String _initialSignature;

  /// function name: [_formSignature]
  ///
  /// purpose: one string describing every value Save would send, so "has
  ///          anything changed" is a single comparison with the snapshot.
  String _formSignature() => [
        _nameController.text.trim(),
        _nameArController.text.trim(),
        _numberController.text.trim(),
        _numberArController.text.trim(),
        _descriptionController.text.trim(),
        _descriptionArController.text.trim(),
        _weightController.text.trim(),
        _daySignature(_startDate),
        _daySignature(_endDate),
        _docSignature(_documentEn),
        _docSignature(_documentAr),
        _imageFile == null ? '-' : 'img:${_imageFile!.path}',
        '$_statusInactive',
      ].join('\u0001');

  /// Save stays disabled until the user changes something.
  bool get _hasChanges => _formSignature() != _initialSignature;

  /// True once the user has entered something into any Arabic field —
  /// mirrors CreateNewPolicyPage's _arabicTouched so Save's own validation
  /// stays consistent with what PolicyInfoFormWidget visually requires.
  bool get _arabicTouched =>
      _nameArController.text.trim().isNotEmpty ||
      _numberArController.text.trim().isNotEmpty ||
      _descriptionArController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _numberController.dispose();
    _numberArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() => _submitted = true);
    final endBeforeStart = _endDate != null &&
        _startDate != null &&
        _endDate!.isBefore(_startDate!);
    return _nameController.text.trim().isNotEmpty &&
        _numberController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        (!_isArabicEnabled ||
            !_arabicTouched ||
            (_nameArController.text.trim().isNotEmpty &&
                _numberArController.text.trim().isNotEmpty &&
                _descriptionArController.text.trim().isNotEmpty)) &&
        !containsArabicLetters(_nameController.text) &&
        !containsArabicLetters(_numberController.text) &&
        !containsArabicLetters(_descriptionController.text) &&
        (!_isArabicEnabled ||
            (!containsEnglishLetters(_nameArController.text) &&
                !containsEnglishLetters(_numberArController.text) &&
                !containsEnglishLetters(_descriptionArController.text))) &&
        _startDate != null &&
        _endDate != null &&
        !endBeforeStart &&
        double.tryParse(_weightController.text.trim()) != null;
  }

  void _onUploadDocumentEn() {
    // GRC bug report p16: straight to the file picker — the old
    // upload dialog's Document Title was never used.
    pickGrcDocument(context, (file) {
        setState(() => _documentEn = PolicyDocumentInfo.fromPlatformFile(file));
    });
  }

  void _onUploadDocumentAr() {
    // GRC bug report p16: straight to the file picker — the old
    // upload dialog's Document Title was never used.
    pickGrcDocument(context, (file) {
        setState(() => _documentAr = PolicyDocumentInfo.fromPlatformFile(file));
    });
  }

  // Removing only clears the pending replacement shown on screen — the
  // update API has no explicit "clear stored document" signal, so if the
  // user removes without picking a replacement, Save keeps the original.
  void _onRemoveDocumentEn() => setState(() => _documentEn = null);
  void _onRemoveDocumentAr() => setState(() => _documentAr = null);

  /// function name: [_statusOverride]
  ///
  /// purpose: only the "Inactive" toggle can change a Policy's status from
  ///          this page, and only when the user actually flips it — a plain
  ///          field edit must never silently overwrite Draft/Scheduled/
  ///          Expired/Active with a stale literal status. Returns null
  ///          (leave status untouched) unless the toggle moved since load.
  PolicyStatus? _statusOverride() {
    if (_statusInactive == _initialStatusInactive) return null;
    return _statusInactive ? PolicyStatus.inactive : PolicyStatus.active;
  }

  void _onSave(PolicyCubit cubit) {
    cubit.updatePolicy(
      // The audience, and the before-snapshot the date/weight notifications
      // diff against.
      moduleOwners: widget.module.moduleOwners,
      previous: widget.policy,
      id: widget.policy.id,
      moduleId: widget.moduleId,
      status: _statusOverride(),
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      policyWeight: double.tryParse(_weightController.text.trim()),
      imageFile: _imageFile,
      imageUrl: _imageFile == null ? _imageUrl : null,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentUrlEn: _documentEn?.file == null ? _documentEn?.url : null,
      policyDocumentFileAr: _documentAr?.file,
      policyDocumentUrlAr: _documentAr?.file == null ? _documentAr?.url : null,
    );
  }

  void _onStateChange(BuildContext context, PolicyState state) {
    if (state is PolicyLoading) {
      showLoadingIndicator();
      return;
    }
    hideLoadingIndicator();

    if (state is PolicyActionSuccess) {
      showSuccessDialog(
        context: context,
        title: S.of(context).policyUpdated,
        subtitle: S.of(context).youSuccessfullyUpdatedThisPolicy,
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (state is PolicyFailure) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: state.message,
      );
    }
  }

  Widget _buildBottomButtons(PolicyCubit cubit) {
    // Text edits don't call setState, so listen to the controllers directly;
    // every other value (dates, documents, image, status) already rebuilds
    // the page through setState.
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        _nameController,
        _nameArController,
        _numberController,
        _numberArController,
        _descriptionController,
        _descriptionArController,
        _weightController,
      ]),
      builder: (context, _) => _bottomButtonsRow(cubit, _hasChanges),
    );
  }

  Widget _bottomButtonsRow(PolicyCubit cubit, bool canSave) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customButton(
          title: S.of(context).discardChange,
          function: () => Navigator.of(context).pop(),
          height: 38.h,
          width: 150.w,
          color: AppColors.darkGrey,
          textColor: AppColors.white,
          borderColor: AppColors.border,
        ),
        customButton(
          title: S.of(context).Save,
          // Disabled (grey, no-op) until something has changed.
          function: () {
            if (!canSave) return;
            if (!_validate()) return;
            showConfirmDialog(
              context: context,
              title: S.of(context).editingPolicy,
              cancelLabel: S.of(context).no,
              confirmLabel: S.of(context).yes,
              subtitle: S.of(context).areYouSureYouWantToEditThisPolicy,
              onConfirm: () => _onSave(cubit),
            );
          },
          height: 38.h,
          width: 150.w,
          color: canSave ? AppColors.primary : AppColors.darkGrey,
          textColor: canSave
              ? AppColors.textButton
              : AppColors.textButton.withOpacity(.45),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // The PolicyCubit is provided by the Policy Details page that pushed this
    // route (it hands its own instance down via BlocProvider.value) so the
    // Details page and this edit form share ONE cubit instance and never
    // diverge. Only read that shared instance here — never resolve a second
    // one from GetIt.
    return Builder(
      builder: (ctx) {
        final cubit = ctx.read<PolicyCubit>();
        return BlocListener<PolicyCubit, PolicyState>(
          listener: _onStateChange,
          // The frame owns the Scaffold, SafeArea, breadcrumb and padding.
          child: SideFrameMasterServices(
            titleText: S.of(ctx).grc,
            onFirstTap: () => popFrameRoutes(ctx, 2),
            secondTitle: context.isArabic
                ? widget.module.moduleNameAr
                : widget.module.moduleNameEn,
            onSecondTap: () => popFrameRoutes(ctx, 1),
            thirdTitle: context.isArabic
                ? "Edit ${widget.policy.policyNameAr}"
                : "Edit ${widget.policy.policyNameEn}",
            child: SideFrameBoundedBody(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Change_Status_Of_Policy. The whole label+switch
                        // pair goes, not just the switch: a Status row you
                        // cannot move reads as a broken control.
                        if (GrcPermission.canChangePolicyStatus) ...[
                        SvgPicture.asset(
                            'assets/icons_assets/data_grc_assets/icons_status.svg'),
                        SizedBox(width: 10.w),
                        Text(S.of(ctx).status,style: context.isPhone ? StyleText.fontSize12Weight500.copyWith(
                            color: AppColors.secondaryText
                        ): StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.secondaryText
                        ),),
                        SizedBox(width: 10.w),
                        FlutterSwitch(
                          width: context.isPhone ? 30.sp : 38.sp,
                          height: context.isPhone ? 18.sp : 22.sp,
                          padding: context.isPhone ? 2.sp : 3.sp,
                          borderRadius: 20.sp,
                          toggleSize: 16.sp,
                          activeColor: AppColors.secondaryPrimary,
                          inactiveColor: Colors.grey.withOpacity(.16),
                          value: !_statusInactive,
                          onToggle: (v) => setState(() => _statusInactive = !v),
                        ),
                        ],
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15.sp),
                        decoration: BoxDecoration(
                          color: AppColors.field,
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            child: PolicyEditModeWidget(
                              isArabicEnabled: _isArabicEnabled,
                              onArabicToggle: (v) =>
                                  setState(() => _isArabicEnabled = v),
                              imageFile: _imageFile,
                              imageUrl: _imageUrl,
                              onImagePicked: (file) =>
                                  setState(() => _imageFile = file),
                              submitted: _submitted,
                              nameController: _nameController,
                              nameArController: _nameArController,
                              numberController: _numberController,
                              numberArController: _numberArController,
                              descriptionController: _descriptionController,
                              descriptionArController: _descriptionArController,
                              weightController: _weightController,
                              startDate: _startDate,
                              endDate: _endDate,
                              onStartDateChanged: (d) =>
                                  setState(() => _startDate = d),
                              onEndDateChanged: (d) =>
                                  setState(() => _endDate = d),
                              documentEn: _documentEn,
                              documentAr: _documentAr,
                              onUploadDocumentEn: _onUploadDocumentEn,
                              onUploadDocumentAr: _onUploadDocumentAr,
                              onRemoveDocumentEn: _onRemoveDocumentEn,
                              onRemoveDocumentAr: _onRemoveDocumentAr,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildBottomButtons(cubit),
                    SizedBox(height: 16.h),
                  ],
                ),
            ),
          ),
        );
      },
    );
  }
}
