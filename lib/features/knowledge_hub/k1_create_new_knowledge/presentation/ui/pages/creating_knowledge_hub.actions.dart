part of './creating_knowledge_hub.dart';
/// Module: knowledge_hub / presentation / s1_create_new_knowledge/master_page/creating_knowledge_hub.actions.dart

/// Pickers, validation, submit + dialog/build helpers for
/// [CreatingKnowledgeHub]. Depends on _CreatingKnowledgeHubData for fields.
mixin _CreatingKnowledgeHubActions on State<CreatingKnowledgeHub>, _CreatingKnowledgeHubData {
  // Image Picker
  Future<void> _pickImage() async {
    log('Picking image from gallery');
    final picked = await _mediaPicker.pickImage(fromCamera: false);

    if (picked?.path != null) {
      setState(() {
        _selectedImage = File(picked!.path!);
        log(picked.name, name: 'Image name');
      });
    }
  }

  // Document Picker
  Future<void> _pickDocument() async {
    log('Picking document file');
    final picked = await _mediaPicker.pickDocument(
      extensions: const [
        'jpg',
        'jpeg',
        'png',
        'mp4',
        'mov',
        'pdf',
        'doc',
        'docx',
        'txt',
        'ppt',
        'pptx',
        'xls',
        'xlsx',
      ],
    );

    if (picked?.path != null) {
      setState(() {
        _selectedDocument = File(picked!.path!);
        _documentFileName = picked.name;
        _documentExtension = path
            .extension(picked.name)
            .replaceAll('.', '')
            .toUpperCase();
        _documentIcon = _getDocumentIconType(path.extension(picked.name));
        _documentSize = picked.bytes.length;
        _documentUploadedDate = DateTime.now();
        _logDocumentInfo();
      });
    }
  }

  String _getDocumentIconType(String extension) {
    final iconMap = {
      '.pdf': 'pdf',
      '.doc': 'word',
      '.docx': 'word',
      '.txt': 'text',
      '.ppt': 'powerpoint',
      '.pptx': 'powerpoint',
      '.xls': 'excel',
      '.xlsx': 'excel',
    };
    return iconMap[extension.toLowerCase()] ?? 'file';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _logDocumentInfo() {
    log('═══════════════════════════════════════');
    log('📄 Document Information:');
    log('═══════════════════════════════════════');
    log('documentExtension: $_documentExtension');
    log('documentIcon: $_documentIcon');
    log(
      'documentSize: ${_formatFileSize(_documentSize)} ($_documentSize bytes)',
    );
    log('documentUploadedDate: ${_documentUploadedDate?.toIso8601String()}');
    log('═══════════════════════════════════════');
  }

  DateTime? _combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return null;

    // If time is null, use start of day (00:00) for start date and end of day (23:59) for end date
    if (time == null) {
      // For start date, use beginning of day
      if (_startDate == date) {
        return DateTime(date.year, date.month, date.day, 0, 0);
      }
      // For end date, use end of day
      if (_endDate == date) {
        return DateTime(date.year, date.month, date.day, 23, 59);
      }
    }

    return DateTime(date.year, date.month, date.day, time!.hour, time.minute);
  }

  // Validation
  bool _validateForm() {
    if (!_documentNameFormKey.currentState!.validate() ||
        !_documentDescriptionKey.currentState!.validate()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(
          S.of(context)!.pleaseFillAllRequiredFieldsCorrectly,
        );
      });
      return false;
    }

    if (_dropDownMenuText == 'Choose Type') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(S.of(context).please_select_doc_type);
      });
      return false;
    }

    if (_selectedDocument == null &&
        submittedDocument?.currentDocumentFileName == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(S.of(context)!.pleaseAttachDocument);
      });
      return false;
    }

    if (_limitDepartmentAvailability && _selectedDepartments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(
          S.of(
            context,
          )!.addDepartmentsOrSwitchOffLimitAvailability,
        );
      });
      return false;
    }

    if (_schedulePublishing && _startDate == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessageDialog(
          S.of(
            context,
          )!.addStartDateOrSwitchOffSchedulePublishing,
        );
      });
      return false;
    }

    return true;
  }

  void _showMessageDialog(
      String message, {
        Color? backgroundColor,
        String? title,
        String? lottiePath = 'assets/lottie_assets/main_lottie_assets/lottie_attention.json',
        Duration autoCloseDuration = const Duration(seconds: 3),
      }) {
    BuildContext? dialogCtx;

    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (ctx) {
        dialogCtx = ctx;
        return Dialog(
          backgroundColor:
          backgroundColor ??
              (Theme.of(ctx).brightness == Brightness.light
                  ? AppColors.white
                  : AppColors.chatBackground),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 411.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lottiePath != null) ...[
                    Lottie.asset(
                      lottiePath,
                      width: 70.sp,
                      height: 70.sp,
                      fit: BoxFit.scaleDown,
                      repeat: false,
                    ),
                    SizedBox(height: 15.sp),
                  ],
                  if (title != null) ...[
                    Text(
                      title,
                      style: StyleText.fontSize20Weight500.copyWith(
                        color: Theme.of(ctx).brightness == Brightness.light
                            ? AppColors.secondaryText
                            : AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 15.sp),
                  ],
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: Theme.of(ctx).brightness == Brightness.light
                          ? AppColors.secondaryText
                          : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1), onTimeout: () {});

    Future.delayed(autoCloseDuration).then((_) {
      if (dialogCtx != null) {
        final nav = Navigator.of(dialogCtx!, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
      }
    });
  }

  /// The status a submission is saved with: `approved` (skips the queue) or
  /// `pending_approval` (goes to a supervisor).
  ///
  /// FIXED 22/9/2026 — "when make request must wait until approved from
  /// supervisor but he approved automatic".
  ///
  /// This method asked ONE question — `editDocumentWithoutApproval` — and used
  /// the answer for both branches of the caller: creating a brand-new document
  /// AND editing an existing one. There was no permission for creation, so it
  /// borrowed the edit one. The effect was that a role given the right to
  /// re-publish its own edits without review ALSO had every new document it
  /// created saved as `approved`; `createKnowledgeHubFromParams` then
  /// normalises `approved` + no scheduling to `published`, so the document went
  /// live, appeared in the supervisor's Approvals list already approved, and
  /// the supervisor was never notified (see the notification block below,
  /// which was gated on the same permission).
  ///
  /// The two cases are now separate rights:
  ///   • creating  -> `Create_Without_Need_Approval`
  ///   • editing   -> `Edit_Document_Without_Approval` (unchanged)
  ///
  /// A role holding neither gets `pending_approval`, which is the default for
  /// everyone until an administrator turns the matching switch on.
  String _getKnowledgeStatus({required bool isEditing}) {
    final bool skipsApproval = isEditing
        ? KnowledgeHubAccess.editAccess.publishesDirectly
        : KnowledgeHubAccess.createsWithoutApproval;

    if (skipsApproval) {
      log(isEditing
          ? '✅ Role may edit without approval - Status: approved'
          : '✅ Role may create without approval - Status: approved');
      return 'approved';
    }

    log(isEditing
        ? '⏳ Edit requires approval - Status: pending_approval'
        : '⏳ New document requires approval - Status: pending_approval');
    return 'pending_approval';
  }

  // ✅ UPDATED: Get owning department name for Firebase submission
  String _getOwningDepartmentForSubmission() {
    if (_selectedOwningDepartmentId == null) {
      return _employeeDepartmentEn ?? "Unknown Department";
    }

    for (var dept in _availableDepartments) {
      if (dept.departmentID == _selectedOwningDepartmentId) {
        return dept.departmentName ?? "Unknown Department";
      }
    }

    return _employeeDepartmentEn ?? "Unknown Department";
  }

  // Firebase Submission
  Future<void> _submitToFirebase({required bool isEditing}) async {
    if (!_validateForm()) return;

    setState(() => _isUploading = true);

    try {
      final cubit = context.read<CreateKnowledgeCubit>();
      final existingDocument = cubit.currentKnowledgeDocument;

      String? imageUrl;
      String? documentUrl;
      String? documentFileName;
      String? documentExtension;
      int documentSize;

      // Handle image upload
      if (_selectedImage != null) {
        imageUrl = await _knowledgeService.uploadImage(_selectedImage!);
        if (imageUrl == null) throw Exception('Failed to upload image');
      } else if (isEditing && existingDocument != null) {
        imageUrl = existingDocument.currentImageUrl;
      }

      // Handle document upload
      if (_selectedDocument != null) {
        documentUrl = await _knowledgeService.uploadDocument(
          _selectedDocument!,
          _documentFileName ?? 'document',
        );
        if (documentUrl == null) throw Exception('Failed to upload document');

        documentFileName = _documentFileName;
        documentExtension = _documentExtension;
        documentSize = _documentSize;
      } else if (isEditing && existingDocument != null) {
        documentUrl = existingDocument.currentDocumentUrl;
        documentFileName = existingDocument.currentDocumentFileName;
        documentExtension = existingDocument.currentDocumentExtension;
        documentSize = existingDocument.currentDocumentSize;
      } else {
        throw Exception('No document selected');
      }

      // Create DateTime values only when schedule publishing is ENABLED
      DateTime? startDateTimeValue = (_schedulePublishing && _startDate != null)
          ? _combineDateTime(_startDate, _startTime)
          : null;

      DateTime? endDateTimeValue = (_schedulePublishing && _endDate != null)
          ? _combineDateTime(_endDate, _endTime)
          : null;

      // Extract time as strings in "HH:mm" format
      String? startTimeString;
      String? endTimeString;

      if (_schedulePublishing && _startTime != null) {
        startTimeString = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      }

      if (_schedulePublishing && _endTime != null) {
        endTimeString = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';
      }

      // Log scheduling info
      log('🕐 Schedule Publishing: $_schedulePublishing');
      log('📅 Start Date: $_startDate');
      log('🕐 Start Time: $_startTime');
      log('✅ Start Time String: $startTimeString');
      log('✅ Final Start DateTime: $startDateTimeValue');
      log('📅 End Date: $_endDate');
      log('🕐 End Time: $_endTime');
      log('✅ End Time String: $endTimeString');
      log('✅ Final End DateTime: $endDateTimeValue');

      // ✅ Get owning department name
      String owningDepartment = _getOwningDepartmentForSubmission();
      log('🏢 Owning Department: $owningDepartment');

      bool success;

      if (isEditing) {
        success = await _knowledgeService.updateKnowledgeHub(
          knowledgeId: widget.knowledgeId!,
          knowledgeImage: imageUrl,
          nameEnglish: _englishController.text.trim(),
          nameArabic: _arabicController.text.trim(),
          descriptionEnglish: _englishDescController.text.trim(),
          descriptionArabic: _arabicDescController.text.trim(),
          knowledgeDocumentType: _dropDownMenuText,
          owningDepartment: owningDepartment,  // ✅ UPDATED
          limitedDepartments: _limitDepartmentAvailability ? _selectedDepartments : [],
          schedulePublishing: _schedulePublishing,
          startDateTime: startDateTimeValue,
          endDateTime: endDateTimeValue,
          startTime: startTimeString,
          endTime: endTimeString,
          imageUrl: imageUrl,
          documentUrl: documentUrl,
          documentFileName: documentFileName ?? 'document',
          documentExtension: documentExtension ?? 'unknown',
          documentSize: documentSize,
          createdByEmail: _employeeEmail ?? "unknown@email.com",
          timeStamp: DateTime.now().toIso8601String(),
          status: _getKnowledgeStatus(isEditing: true),
        );
      } else {
        success = await _knowledgeService.createKnowledgeHubFromParams(
          knowledgeImage: imageUrl ?? '',
          nameEnglish: _englishController.text.trim(),
          nameArabic: _arabicController.text.trim(),
          descriptionEnglish: _englishDescController.text.trim(),
          descriptionArabic: _arabicDescController.text.trim(),
          knowledgeDocumentType: _dropDownMenuText,
          owningDepartment: owningDepartment,  // ✅ UPDATED
          limitedDepartments: _limitDepartmentAvailability ? _selectedDepartments : [],
          schedulePublishing: _schedulePublishing,
          startDateTime: startDateTimeValue,
          endDateTime: endDateTimeValue,
          startTime: startTimeString,
          endTime: endTimeString,
          imageUrl: imageUrl ?? '',
          documentUrl: documentUrl,
          documentFileName: documentFileName ?? 'document',
          documentExtension: documentExtension ?? 'unknown',
          documentSize: documentSize,
          createdByEmail: _employeeEmail ?? "unknown@email.com",
          timeStamp: DateTime.now().toIso8601String(),
          status: _getKnowledgeStatus(isEditing: false),
        );
      }

      if (!success) {
        throw Exception(
          isEditing ? 'Failed to update knowledge hub' : 'Failed to create knowledge hub',
        );
      }

      // CHANGED 22/9/2026 — the notification now follows the STATUS that was
      // just saved, not a permission re-read on its own.
      //
      // This block asked `editDocumentWithoutApproval` a second time, so it
      // could disagree with `_getKnowledgeStatus` above and silently drop the
      // notification for a document that really was waiting for a supervisor
      // (or send one for a document that was already live). Deriving it from
      // the status makes the two impossible to separate: if it is pending, the
      // supervisor is told.
      final bool needsApproval =
          _getKnowledgeStatus(isEditing: isEditing) == 'pending_approval';

      // ✅ Only send notification to supervisor if approval is required
      if (needsApproval) {
        log('\n📧 Sending notification to supervisor...');

        final notificationSent = await cubit.sendNotificationToSupervisor(
          documentNameEn: _englishController.text.trim(),
          documentNameAr: _arabicController.text.trim(),
          employeeEmail: _employeeEmail ?? "unknown@email.com",
          employeeName: _employeeName ?? "Unknown Employee",
        );

        if (notificationSent) {
          log('✅ Supervisor notification sent successfully');
        } else {
          log('⚠️ Supervisor notification could not be sent (supervisor email not found)');
        }
      } else {
        log('⏭️ Skipping supervisor notification - this submission publishes directly');
      }

    } catch (e) {
      log('❌ Error: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: '${S.of(context)!.error}: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  /// Parse limited departments from JSON string
  List<String> _parseLimitedDepartments(List<dynamic> limitedDepartments) {
    try {
      if (limitedDepartments.isEmpty) return [];
      String jsonString = limitedDepartments.first.toString().trim();
      if (jsonString.isEmpty) return [];
      List<dynamic> parsed = jsonDecode(jsonString);
      return parsed.map((e) => e.toString()).toList();
    } catch (e) {
      log('⚠️ Error parsing limitedDepartments: $e');
      return [];
    }
  }

  /// Pre-fill form when editing
  void _preFillFormData(CreateKnowledgeModel knowledge) {
    log('═══════════════════════════════════════');
    log('📝 PRE-FILLING FORM DATA FOR EDIT');
    log('═══════════════════════════════════════');

    // Set text fields
    _englishController.text = knowledge.currentNameEnglish;
    _arabicController.text = knowledge.currentNameArabic;
    _englishDescController.text = knowledge.currentDescriptionEnglish;
    _arabicDescController.text = knowledge.currentDescriptionArabic;

    // Store the existing document info FIRST
    submittedDocument = knowledge;

    // Set document type
    _dropDownMenuText = knowledge.currentKnowledgeDocumentType;

    // ✅ Set owning department from knowledge data
    String owningDeptName = knowledge.currentOwningDepartment;
    String? deptId = _departmentController.getDepartmentIdFromDepartmentName(
      departmentName: owningDeptName.toLowerCase(),
    );
    if (deptId != null && deptId != "none") {
      _selectedOwningDepartmentId = deptId;
      log('✓ Owning Department ID set: $deptId');
    }

    log('✓ Text fields set:');
    log('   EN Name: ${knowledge.currentNameEnglish}');
    log('   AR Name: ${knowledge.currentNameArabic}');
    log('✓ Document Type: $_dropDownMenuText');

    // Set scheduling info - CHECK if dates exist, then enable toggle
    if (knowledge.currentStartDateTime != null || knowledge.currentEndDateTime != null) {
      _schedulePublishing = true;
      log('✓ Schedule Publishing: ENABLED');

      if (knowledge.currentStartDateTime != null) {
        final startDate = knowledge.currentStartDateTime!.toDate();
        _startDate = startDate;
        _startTime = TimeOfDay.fromDateTime(startDate);
        log('✓ Start Date: $startDate');
      }

      if (knowledge.currentEndDateTime != null) {
        final endDate = knowledge.currentEndDateTime!.toDate();
        _endDate = endDate;
        _endTime = TimeOfDay.fromDateTime(endDate);
        log('✓ End Date: $endDate');
      }
    } else {
      _schedulePublishing = false;
      log('✓ Schedule Publishing: DISABLED');
    }

    // Set department limitations - CHECK if departments exist, then enable toggle
    if (knowledge.limitedDepartments.isNotEmpty) {
      _limitDepartmentAvailability = true;
      log('✓ Limited Departments: ENABLED');

      // Parse and set selected departments
      List<String> limitedDepts = _parseLimitedDepartments(knowledge.limitedDepartments);

      log('   Found ${limitedDepts.length} limited departments:');
      for (String dept in limitedDepts) {
        _departmentSelections[dept] = true;
        log('   - $dept');
      }
    } else {
      _limitDepartmentAvailability = false;
      log('✓ Limited Departments: DISABLED (public access)');
    }

    log('═══════════════════════════════════════');
    log('✅ FORM PRE-FILL COMPLETE');
    log('   📋 Document Type: $_dropDownMenuText');
    log('   🔄 Schedule Publishing: $_schedulePublishing');
    log('   🏢 Limit Departments: $_limitDepartmentAvailability');
    log('═══════════════════════════════════════\n');

    // Force rebuild to show the data - ONLY ONE setState at the end
    if (mounted) setState(() {});
  }

  void _showSuccessAndNavigate() {
    if (!mounted) return;

    log('=== Knowledge Hub Data Submitted Successfully ===');

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(child: _buildSuccessDialog(context)),
    );

    // Wait 3 seconds, then close dialog and navigate
    Future.delayed(const Duration(seconds: 3)).then((_) {
      if (!mounted) return;

      // Close success dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Wait a bit then navigate back
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
  }

  Widget _buildSuccessDialog(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Material(
      color: AppColors.transparent,
      child: Container(
        width: isMobile ? double.infinity : 411.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: lightMode ? AppColors.white : AppColors.background,
        ),
        padding: EdgeInsets.all(20.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
              height: 80.h,
              width: 80.w,
            ),
            SizedBox(height: 33.h),
            Text(
              S.of(context).successful,
              style: StyleText.fontSize20Weight500.copyWith(
                color: lightMode
                    ? AppColors.blackButton
                    : AppColors.white,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              S.of(context).submit_success_message,
              style: StyleText.fontSize14Weight500.copyWith(
                color: lightMode
                    ? AppColors.secondaryText
                    : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeDocument() {
    setState(() {
      _selectedDocument = null;
      _documentFileName = null;
      _documentExtension = null;
      _documentIcon = null;
      _documentSize = 0;
      _documentUploadedDate = null;
      if (submittedDocument != null) {
        submittedDocument = null;
      }
    });
  }

  Widget _buildEmployeeDataWrapper({required Widget child}) {
    return BlocListener<CreateKnowledgeCubit, CreateKnowledgeState>(
      listener: (context, state) {
        // Handle department data loading
        if (state is FetchingDepartmentSuccessState) {
          _availableDepartments = state.departmentList;
          _isDepartmentDataLoaded = true;
          debugPrint("🎯 Departments loaded: ${_availableDepartments.length}");
          _updateDepartmentNames();
        }

        // Handle knowledge data loading for EDIT MODE
        if (state is FetchingKnowledgeByIdSuccessState) {
          log('✅ Knowledge data fetched for editing');
          _preFillFormData(state.knowledge);
        }

        // Handle errors
        if (state is FetchingKnowledgeByIdErrorState) {
          log('❌ Error fetching knowledge: ${state.error}');
          Fluttertoast.showToast(
            msg: 'Error loading document: ${state.error}',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      },
      child: GetBuilder<MainCoreEmployeeController>(
        id: 'employee_data',
        builder: (employeeController) {
          if (_employeeDepartmentId != null && _availableDepartments.isNotEmpty) {
            _updateDepartmentNames();
          }
          return child;
        },
      ),
    );
  }

  void _handleSubmitForApproval() {
    if (!_validateForm()) return;

    // CHANGED 22/9/2026 — EDITING NOW ASKS WHY.
    //
    // Reported as "add dialog of reason of editing then confirmation message"
    // against the Requesting Resubmit dialog. That dialog only ever asked
    // yes/no, so an edit that went to a supervisor arrived with no account of
    // what changed or why.
    //
    // The edit path runs through `CustomDialogManager.showDialogFlow`, which
    // is the app's existing confirm -> reason -> confirmation sequence (the
    // same one the Services approvals use), instead of a second hand-rolled
    // copy of it. Creating is unchanged: there is nothing to explain about a
    // document that did not exist a moment ago.
    if (widget.knowledgeId != null) {
      _handleResubmitWithReason();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (confirmationDialogContext) {
        bool localIsUploading = false;
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return Center(
              child: creatingKnowledgeConfirmation(
                context,
                isUploading: localIsUploading,
                submitForApproval: () async {
                  // CHANGED 28/9/2026 (Knowledge Hub p.19): the dialog closes
                  // FIRST and the upload runs under the page's full-page
                  // loading overlay (`_isUploading`, see build), instead of a
                  // small "Uploading..." spinner inside this dialog.
                  Navigator.of(confirmationDialogContext).pop();

                  await _submitToFirebase(isEditing: false);

                  await Future.delayed(Duration(milliseconds: 100));

                  if (mounted) {
                    _showSuccessAndNavigate();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  /// Resubmit: confirm -> reason for editing -> confirmation message.
  ///
  /// The reason is REQUIRED (`commentRequired: true`): an edit queued for a
  /// supervisor with a blank justification tells them nothing, which is the
  /// state this dialog was added to end.
  ///
  /// Ordering note — `showDialogFlow` runs the reason dialog BEFORE
  /// `onConfirm`, so the text is in hand by the time the edit is written. The
  /// reason is attached after the write, because it is pinned to the status
  /// entry that write appends.
  Future<void> _handleResubmitWithReason() async {
    final TextEditingController reasonController = TextEditingController();
    bool submitted = false;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json',
      confirmTitle: S.of(context)!.requestingResubmit,
      confirmSubtitle: S.of(context)!.areYouSureYouWantToResubmit,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,

      // Reason step
      comment: true,
      commentRequired: true,
      commentController: reasonController,
      customReasonTitle: S.of(context).reasonOfEditing,
      // Without this the shared dialog falls back to its red rejection icon,
      // which is the wrong signal on an edit.
      customReasonIconAsset:
          'assets/icons_assets/knowledge_hub_assets/svg_edit_icon.svg',
      commentSubmitText: S.of(context).submit,
      commentDiscardText: S.of(context).discard,
      onCommentSubmit: () async => true,

      // The edit itself. Returning false here stops the flow before the
      // success dialog, so a failed save cannot report success.
      onConfirm: () async {
        final String reason = reasonController.text.trim();

        await _submitToFirebase(isEditing: true);
        if (!mounted) return false;

        // Best-effort: the edit is already saved, so a failure to attach the
        // reason is logged rather than shown as a failed edit.
        await KnowledgeHubFirebaseServices().attachEditReason(
          documentId: widget.knowledgeId!,
          reason: reason,
        );

        submitted = true;
        return true;
      },

      successLottie: 'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
      // The same wording the create path's success dialog uses, so the two
      // outcomes read alike.
      successTitle: S.of(context).successful,
      successSubtitle: S.of(context).submit_success_message,
      onSuccessComplete: () {
        if (mounted && submitted) {
          Navigator.of(context).pop();
        }
      },
    );

    reasonController.dispose();
  }
}
