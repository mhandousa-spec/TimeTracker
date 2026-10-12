/// Module: GRC Policy Management
/// Description: Cubit-action and entity-mapping methods for
///              [CreateNewPolicyPage], extracted from
///              create_new_policy.dart to keep that file under the
///              800-line cap. Kept as a `part of` extension (not a
///              widget) so it retains access to the State's private
///              fields, per the extension-on-State precedent used
///              across the roles feature.
/// Author: Mohamed Magdy Abdelkhalek
part of '../../pages/create_new_policy.dart';

extension _CreateNewPolicyActions on _CreateNewPolicyPageState {
  // ----------------------------------------------------------------
  // Cubit actions
  // ----------------------------------------------------------------

  /// function name: [_onSaveForLater]
  ///
  /// purpose: persist the policy as a Draft regardless of the current step.
  ///          Controls are included if any have been filled in; an empty
  ///          list is valid for a draft.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: void
  List<PendingControlInput> _buildPendingControls(ControlStatus status) {
    return _controls
        .where(controlIsTouched)
        .map((c) => PendingControlInput(
              controlsNameEn: c.nameController.text.trim(),
              controlsNameAr: c.nameArController.text.trim(),
              controlsNumberEn: c.numberController.text.trim(),
              controlsNumberAr: c.numberArController.text.trim(),
              controlsDescriptionEn: c.descriptionController.text.trim(),
              controlsDescriptionAr: c.descriptionArController.text.trim(),
              controlsWeight:
                  double.tryParse(c.weightController.text.trim()) ?? 0,
              frequency: c.frequency ?? '',
              startDate: c.startDate ?? _startDate ?? DateTime.now(),
              endDate: c.endDate ?? _endDate ?? DateTime.now(),
              // equalWeights: true (not false) — this wizard never lets the
              // user assign per-department weights, so departments is
              // always []. ControlModel.create asserts that
              // departmentWeights is non-null whenever equalWeights is
              // false; equalWeights: true skips that requirement and
              // DepartmentWeight.equalSplit([]) safely returns [].
              departments: const [],
              equalWeights: true,
              score: 0,
              status: status,
              controlsDocumentFileEn: c.documentEn?.file,
              controlsDocumentFileAr: c.documentAr?.file,
              existingControlId: c.existingControlId,
            ))
        .toList();
  }

  /// function name: [_controlModelFromEntity]
  ///
  /// purpose: build an editable [PolicyControlModel] prefilled from an
  ///          already-saved [ControlEntity], tagging it with
  ///          [PolicyControlModel.existingControlId] so a later Save For
  ///          Later/Publish updates this same Control instead of creating
  ///          a duplicate.
  ///
  /// parameters:
  ///            [ControlEntity] c: the saved control to prefill from
  ///
  /// return type: [PolicyControlModel]
  PolicyControlModel _controlModelFromEntity(ControlEntity c) =>
      PolicyControlModel(
        existingControlId: c.id,
        nameController: TextEditingController(text: c.controlsNameEn),
        nameArController: TextEditingController(text: c.controlsNameAr),
        numberController: TextEditingController(text: c.controlsNumberEn),
        numberArController: TextEditingController(text: c.controlsNumberAr),
        descriptionController:
            TextEditingController(text: c.controlsDescriptionEn),
        descriptionArController:
            TextEditingController(text: c.controlsDescriptionAr),
        weightController:
            TextEditingController(text: c.controlsWeight.toStringAsFixed(0)),
        frequency: c.frequency,
        startDate: c.startDate,
        endDate: c.endDate,
        documentEn: c.controlsDocumentEn != null
            ? PolicyDocumentInfo.fromUrl(c.controlsDocumentEn!)
            : null,
        documentAr: c.controlsDocumentAr != null
            ? PolicyDocumentInfo.fromUrl(c.controlsDocumentAr!)
            : null,
      );

  void _onSaveForLater(PolicyCubit cubit) {
    if (widget.existingPolicy != null) {
      _updateExisting(cubit, status: PolicyStatus.draft);
      return;
    }
    cubit.saveAsDraft(
      // Addressed to, and received by, the module's owners.
      moduleName: widget.moduleNameEn,
      moduleOwners: widget.moduleOwners,
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      controls: _buildPendingControls(ControlStatus.draft),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }

  /// function name: [_onPublish]
  ///
  /// purpose: validate that the total control weight equals 100 then
  ///          persist the policy with [PolicyStatus.active].
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///
  /// return type: void
  void _onPublish(PolicyCubit cubit) {
    if (!_isWeightValid) {
      CustomDialogManager.showMessage(
        context: context,
        lottiePath: "assets/lottie_assets/main_lottie_assets/error.json",
        title: S.of(context).unsuccessful,
        subtitle: S.of(context).totalWeightShouldBe100,
      );
      return;
    }
    if (widget.existingPolicy != null) {
      _updateExisting(cubit, status: PolicyStatus.active);
      return;
    }
    cubit.createPolicy(
      // Addressed to, and received by, the module's owners.
      moduleName: widget.moduleNameEn,
      moduleOwners: widget.moduleOwners,
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      moduleId: widget.moduleId,
      // Controls added inline here have no Champion/Owner assignment UI at
      // all in this wizard, so a freshly published one must start
      // Unassigned — never Active — matching the same "no assignee = can't
      // be Active" rule the single Add/Edit Control page enforces (see
      // ControlStatus doc and add_edit_control_page.dart's _resolvedStatus).
      controls: _buildPendingControls(ControlStatus.unassigned),
      imageFile: _imageFile,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentFileAr: _documentAr?.file,
    );
  }

  /// function name: [_updateExisting]
  ///
  /// purpose: Save For Later/Publish path when resuming a Draft — updates
  ///          [widget.existingPolicy] and its Controls in place via
  ///          [PolicyCubit.updatePolicyWithControls] instead of creating a
  ///          new Policy. [status] decides whether the Policy (and every
  ///          touched control) ends up Draft again or Unassigned — never
  ///          Active, since this wizard has no Champion/Owner assignment UI.
  ///
  /// parameters:
  ///            [PolicyCubit] cubit: the cubit instance from the BlocProvider
  ///            [PolicyStatus] status: the status to persist
  ///
  /// return type: [void]
  void _updateExisting(PolicyCubit cubit, {required PolicyStatus status}) {
    final controlStatus =
        status == PolicyStatus.active ? ControlStatus.unassigned : ControlStatus.draft;
    final currentIds = _touchedControls
        .map((c) => c.existingControlId)
        .whereType<String>()
        .toSet();
    cubit.updatePolicyWithControls(
      id: widget.existingPolicy!.id,
      moduleId: widget.moduleId,
      // Publishing the draft is announced to the module's owners as
      // Policy Created (PolicyCubit._notifyPolicyUpdated).
      moduleOwners: widget.moduleOwners,
      previous: widget.existingPolicy,
      status: status,
      policyNameEn: _nameController.text.trim(),
      policyNameAr: _nameArController.text.trim(),
      policyNumberEn: _numberController.text.trim(),
      policyNumberAr: _numberArController.text.trim(),
      policyDescriptionEn: _descriptionController.text.trim(),
      policyDescriptionAr: _descriptionArController.text.trim(),
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate ?? DateTime.now(),
      policyWeight: double.tryParse(_weightController.text.trim()) ?? 0,
      controls: _buildPendingControls(controlStatus),
      removedControlIds: _originalControlIds.difference(currentIds).toList(),
      imageFile: _imageFile,
      imageUrl: _imageFile == null ? _imageUrl : null,
      policyDocumentFileEn: _documentEn?.file,
      policyDocumentUrlEn: _documentEn?.file == null ? _documentEn?.url : null,
      policyDocumentFileAr: _documentAr?.file,
      policyDocumentUrlAr: _documentAr?.file == null ? _documentAr?.url : null,
    );
  }
}
