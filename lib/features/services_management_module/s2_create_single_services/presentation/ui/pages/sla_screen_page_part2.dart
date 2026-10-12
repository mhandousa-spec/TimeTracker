part of 'sla_screen_page.dart';

// Split from sla_screen_page.dart to keep files <700 LOC.

class _SlaScreenPageTabletState extends State<SlaScreenPageTablet> {
  late SlaNotificationCubit cubit;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    final rawJson = ServicesManagerCubit.get(context).docServiceRawJson;
    if (rawJson != null) {
      SharedPrefsHelper.setBool('sla_switch', rawJson['branchSLA'] ?? false);
      SharedPrefsHelper.setBool('inquiry_switch', rawJson['allowInquiries'] ?? false);
      SharedPrefsHelper.setBool('comments_switch', rawJson['allowComments'] ?? false);
      SharedPrefsHelper.setString('percentage', rawJson['percentage'] ?? '');
      SharedPrefsHelper.setStringList(
        'notifications',
        (rawJson['notifications'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );
    }

    final servicesManager = ServicesManagerCubit.get(context);

    cubit = SlaNotificationCubit(
      submitSlaData: servicesManager.submitSlaData,
      repository: servicesManager.repository,
      // ✅ FIX 26/8/2026 — this used to be ONLY
      //
      //     await SharedPrefsServiceMaster.saveDraft(model);
      //
      // with the comment "Implement save draft logic or call your existing
      // method" still above it. A placeholder that shipped.
      //
      // SharedPrefs is device-local, so a draft saved from this screen never
      // existed in Firestore. The home page reads its drafts from Firestore, so
      // it could not list one, and the draft did not survive a reinstall or
      // follow the user to another device. It all looked fine because the cubit
      // reported success either way.
      //
      // Firebase first — that is the storage the rest of the app reads — with
      // the prefs write kept underneath as a local cache, matching what
      // `CreateServiceCubit.saveDraftFromPage1` does on page 1.
      //
      // `pageSlaNotification` is this screen, so resuming the draft knows how
      // far the user got. Failures are deliberately NOT swallowed here:
      // `_saveDraftData` catches them and reports the save as failed, instead
      // of a success dialog over a draft that is not there.
      saveDraft: (model) async {
        debugPrint('[SFL] page.saveDraft: modelId=${model.currentId} '
            'state=${model.currentState}');

        // ⚠️ 26/8/2026 — do NOT seed the draft session with `model.currentId`
        // here. That was tried and it is wrong twice over:
        //
        //   • `model.currentId` is a `services/` document id
        //     (`User<random><MMMdd_yyyy>`), and the draft repository looks its
        //     "existing draft" up in a DIFFERENT collection
        //     (`FirestoreCollections.createServicesRoot`). The lookup misses,
        //     so it mints a fresh `draft_…` id anyway.
        //   • Worse, it overwrites the real draft id that
        //     `saveDraftToFirebase` records after a successful save — so the
        //     NEXT Save For Later would miss again and mint yet another
        //     document. Repeated saves would pile up duplicate drafts.
        //
        // Left to itself, `ServiceDraftManager` reuses the id it stored last
        // time, and a resumed draft is tracked by `getDraftWithPage`. Both
        // give the update-in-place behaviour this was reaching for.
        final draftId = await servicesManager.saveDraftToFirebase(
          model: model,
          currentPage: FirebaseDraftRepository.pageSlaNotification,
        );
        debugPrint('[SFL] page.saveDraft: Firebase draftId=$draftId');

        await SharedPrefsServiceMaster.saveDraft(model);
        debugPrint('[SFL] page.saveDraft: prefs cache written');
      },
    );

    cubit.initialize(widget.editingModel);
    _setupControllerListeners();
  }

  /// Function Name: [_confirmThenSaveForLater]
  ///
  /// Purpose: Ask before saving a draft, then save it.
  ///
  /// ADDED 26/8/2026. This screen's Save For Later called
  /// `cubit.handleSaveForLater(...)` straight from the button's `function:`,
  /// with no confirmation at all — press it by accident and the draft was
  /// written and the success dialog was already on screen.
  ///
  /// The confirmation existed, but only on the OTHER save-for-later entry
  /// point: `SaveForLaterButton` (the provider-selection screen) wraps the same
  /// action in a [ConfirmationDialog] with the Edit Document lottie, and a note
  /// there says both paths were meant to "render identically". This one was
  /// never brought across. Same component, same lottie, same wording — so the
  /// two now match, which is what that note intended.
  ///
  /// The "Discard change" case is deliberately NOT wrapped: it saves nothing,
  /// it just navigates back to the details screen, so there is nothing to
  /// confirm. `handleSaveForLater` still makes that decision itself from the
  /// model's state; this only decides whether to ask first.
  ///
  /// Parameters:
  /// - [isEditingSubmittedService]: true when the button is acting as
  ///   "Discard change" rather than "Save for later".
  void _confirmThenSaveForLater({required bool isEditingSubmittedService}) {
    void run() {
      debugPrint('[SFL] confirmation accepted — running save');
      cubit.handleSaveForLater(
        context,
        widget.editingModel,
        () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DetailsToggleScreen(
                editingModel: widget.editingModel!,
                docId: widget.editingModel!.currentId ?? '',
              ),
            ),
          );
        },
      );
    }

    debugPrint('[SFL] button tapped — isEditingSubmittedService='
        '$isEditingSubmittedService');

    if (isEditingSubmittedService) {
      run();
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ConfirmationDialog(
        lottiePath:
            "assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json",
        title: S.of(dialogContext).saveForLater,
        message: S.of(dialogContext).areYouSureYouWantToSaveAsDraft,
        noText: S.of(dialogContext).no,
        yesText: S.of(dialogContext).yes,
        onConfirm: run,
      ),
    );
  }

  void _setupControllerListeners() {
    cubit.model.slaOneController.addListener(() {
      final v = cubit.model.slaOneController.text.trim();

      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        cubit.updateAndSaveModel();
        SharedPrefsHelper.setString('sla_one', v);
        setState(() {});
      });
    });

    cubit.model.slaTwoController.addListener(() {
      final v = cubit.model.slaTwoController.text.trim();

      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        cubit.updateAndSaveModel();
        SharedPrefsHelper.setString('sla_two', v);
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final isDraft = widget.editingModel != null &&
        (widget.editingModel!.currentState == "draft" ||
            widget.editingModel!.currentDurationOfServices.isEmpty ||
            widget.editingModel!.currentDurationOfServices == "-");

    final isEditingSubmittedService = widget.editingModel != null &&
        widget.editingModel!.currentState != "submitted";
    final shouldShowSaveForLaterButton = !isEditingSubmittedService || isDraft;

    return SlideInContent(from: SlideFrom.bottom, child: BlocProvider.value(
      value: cubit,
      child: BlocListener<SlaNotificationCubit, SlaNotificationState>(
        listener: (context, state) {
          if (state is SlaNotificationValidationError) {
            SlaNotificationWidgets.showValidationError(context, state.message);
          } else if (state is SlaNotificationDraftSaved) {
            // ✅ Only shows for Save For Later
            showDraftSavedSuccessDialog(context);
          } else if (state is SlaNotificationSaved) {
            // ✅ Only shows for Submit
            showCreateServiceDialog(
              context,
              cubit.currentModel,
              cubit.model.notificationSwitches,
              cubit.model.notifyRequesterSwitch0,
              cubit.model.notifyManagerSwitch1,
            );
          }
        },
        child: BlocBuilder<SlaNotificationCubit, SlaNotificationState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: SideFrameMasterServices(
                  titleText: S.of(context).service,
                  onFirstTap: () {
                    navigateTo(context, LayoutScreenServices());
                  },
                  secondTitle: widget.editingModel != null
                      ? isDraft
                      ? "${S.of(context).draft} ${Localizations.localeOf(context).languageCode == 'ar' ? widget.editingModel!.currentServiceNameArabic : widget.editingModel!.currentServiceNameEnglish}"
                      : "${S.of(context).Editing} ${Localizations.localeOf(context).languageCode == 'ar' ? widget.editingModel!.currentServiceNameArabic : widget.editingModel!.currentServiceNameEnglish}"
                      : S.of(context).creatingNewService,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              S.of(context).ServiceFulfillment,
                              style: StyleText.fontSize18Weight500.copyWith(
                                color: lightMode
                                    ? AppColors.blackButton
                                    : AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.sp),
                        SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.sp),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10.sp),
                                  Text(
                                    S.of(context).SendNotifications,
                                    style: StyleText.fontSize14Weight500.copyWith(
                                      color: lightMode
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                  ),
                                  SizedBox(height: 28.sp),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      NotificationTile(
                                        title: S.of(context).notifyServiceRequester,
                                        isChecked: cubit.model.notifyRequesterChecked,
                                        onCheckboxChanged: (value) {
                                          setState(() {
                                            cubit.updateCheckbox('requester', value);
                                          });
                                          cubit.updateAndSaveModel();
                                          SharedPrefsHelper.setBool('Notify Service Requester_checked', value);
                                        },
                                        children: [
                                          S.of(context).whenManagerApprovesServiceIfRequired,
                                          S.of(context).whenServiceStattusChanges,
                                          S.of(context).whenTheyReceiveCommentFromServiceProvider,
                                          S.of(context).whenSlaIsBreached,
                                        ],
                                        onSwitchChanged: (map) {
                                          setState(() {
                                            cubit.updateNotificationSwitches(S.of(context).notifyServiceRequester, map);
                                          });
                                        },
                                        onSingleSwitchChanged: ({required index, required value, required title}) {
                                          final key = cubit.slug('${title}_switch_$index');
                                          cubit.updateAndSaveModel();
                                        },
                                      ),

                                      SizedBox(height: 15.h),
                                      NotificationTile(
                                        title: S.of(context).notifyServiceProvider,
                                        isChecked: cubit.model.notifyProviderChecked,
                                        onCheckboxChanged: (value) {
                                          setState(() {
                                            cubit.updateCheckbox('provider', value);
                                          });
                                          cubit.updateAndSaveModel();
                                          SharedPrefsHelper.setBool('Notify Service Provider_checked', value);
                                        },
                                        onCheckSlaData: () {
                                          if (cubit.hasProviderSlaData()) {
                                            SlaNotificationWidgets.showSlaValidationError(context, S.of(context).notifyServiceProvider);
                                          } else {
                                            setState(() {
                                              cubit.updateCheckbox('provider', false);
                                            });
                                            cubit.updateAndSaveModel();
                                            SharedPrefsHelper.setBool('Notify Service Provider_checked', false);
                                          }
                                        },
                                        children: [
                                          S.of(context).whenServicesRequestedAndApprovedIfRequired,
                                          S.of(context).whenTheyReceiveCommentFromRequester,
                                          S.of(context).whenServiceSlaIsBreached,
                                        ],
                                        onSwitchChanged: (map) {
                                          setState(() {
                                            cubit.updateNotificationSwitches(S.of(context).notifyServiceProvider, map);
                                          });
                                        },
                                        onSingleSwitchChanged: ({required index, required value, required title}) {
                                          final key = cubit.slug('${title}_switch_$index');
                                          cubit.updateAndSaveModel();
                                        },
                                      ),

                                      SizedBox(height: 15.sp),
                                      // ✅ One shared row builder for the label,
                                      // the CustomTextField, the "%" and the
                                      // remove icon — all centred on the field.
                                      Padding(
                                        padding: EdgeInsets.only(left: isArabic ? 0 : 30.w, right: isArabic ? 30.w : 0),
                                        child: SlaNotificationWidgets.slaRow(
                                          context: context,
                                          label: S.of(context).whenServiceSlaIsAboutToBeBreached,
                                          labelStyle: _slaLabelStyle(lightMode),
                                          controller: cubit.model.slaOneController,
                                          isInvalid: cubit.model.isInvalidNumber,
                                          onChanged: (val) {
                                            setState(() {
                                              cubit.updateSlaOne(val);
                                            });
                                          },
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ...cubit.model.extraSlaControllers.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final controller = entry.value;

                                            return Padding(
                                              padding: EdgeInsets.only(left: isArabic ? 0 : 30.w, right: isArabic ? 30.w : 0),
                                              child: SlaNotificationWidgets.slaRow(
                                                context: context,
                                                label: S.of(context).whenServiceSlaIsAboutToBeBreached,
                                                labelStyle: _slaLabelStyle(lightMode),
                                                controller: controller,
                                                isInvalid: _isInvalidPercentage(controller),
                                                onChanged: (_) {
                                                  setState(() {});
                                                  _scheduleSlaSave();
                                                },
                                                onRemove: () {
                                                  setState(() {
                                                    cubit.removeExtraSlaController(index);
                                                  });
                                                  cubit.updateAndSaveModel();
                                                },
                                              ),
                                            );
                                          }),

                                          SlaNotificationWidgets.addSlaButton(
                                            context: context,
                                            onTap: () {
                                              setState(() {
                                                cubit.addExtraSlaController();
                                              });
                                            },
                                            onSave: () {
                                              cubit.updateAndSaveModel();
                                            },
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20.sp),
                                    ],
                                  ),

                                  NotificationTile(
                                    title: S.of(context).notifyProviderManager,
                                    isChecked: cubit.model.notifyManagerChecked,
                                    onCheckboxChanged: (value) {
                                      setState(() {
                                        cubit.updateCheckbox('manager', value);
                                      });
                                      cubit.updateAndSaveModel();
                                      SharedPrefsHelper.setBool('Notify Provider Manager_checked', value);
                                    },
                                    onCheckSlaData: () {
                                      if (cubit.hasManagerSlaData()) {
                                        SlaNotificationWidgets.showSlaValidationError(context, S.of(context).notifyProviderManager);
                                      } else {
                                        setState(() {
                                          cubit.updateCheckbox('manager', false);
                                        });
                                        cubit.updateAndSaveModel();
                                        SharedPrefsHelper.setBool('Notify Provider Manager_checked', false);
                                      }
                                    },
                                    children: [
                                      S.of(context).whenProviderBreachedSla,
                                      S.of(context).whenServiceRequestedAndApprovedIfRequired,
                                      S.of(context).whenServiceStatusChanges,
                                    ],
                                    onSwitchChanged: (map) {
                                      setState(() {
                                        cubit.updateNotificationSwitches(S.of(context).notifyProviderManager, map);
                                      });
                                    },
                                    onSingleSwitchChanged: ({required index, required value, required title}) {
                                      final key = cubit.slug('${title}_switch_$index');
                                      cubit.updateAndSaveModel();
                                      _saveNotificationSwitchesToSharedPrefs();
                                    },
                                  ),

                                  SizedBox(height: 15.sp),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: isArabic ? 0 : 30.w, right: isArabic ? 30.w : 0),
                                        child: SlaNotificationWidgets.slaRow(
                                          context: context,
                                          label: S.of(context).whenServiceSlaIsAboutToBeBreached,
                                          labelStyle: _slaLabelStyle(lightMode),
                                          controller: cubit.model.slaTwoController,
                                          isInvalid: cubit.model.isInvalidNumberTwo,
                                          onChanged: (val) {
                                            setState(() {
                                              cubit.updateSlaTwo(val);
                                            });
                                          },
                                        ),
                                      ),

                                      ...cubit.model.extraSlaTwoControllers.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final controller = entry.value;

                                        return Padding(
                                          padding: EdgeInsets.only(left: isArabic ? 0 : 30.w, right: isArabic ? 30.w : 0),
                                          child: SlaNotificationWidgets.slaRow(
                                            context: context,
                                            label: S.of(context).whenServiceSlaIsAboutToBeBreached,
                                            labelStyle: _slaLabelStyle(lightMode),
                                            controller: controller,
                                            isInvalid: _isInvalidPercentage(controller),
                                            onChanged: (_) {
                                              setState(() {});
                                              _scheduleSlaSave();
                                            },
                                            onRemove: () {
                                              setState(() {
                                                cubit.removeExtraSlaTwoController(index);
                                              });
                                              cubit.updateAndSaveModel();
                                            },
                                          ),
                                        );
                                      }),

                                      SlaNotificationWidgets.addSlaButtonAlt(
                                        context: context,
                                        onTap: () {
                                          setState(() {
                                            cubit.addExtraSlaTwoController();
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15.sp),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12.sp),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            customButton(
                                title: S.of(context).back,
                                function: () {
                                  Navigator.pop(context);
                                },
                                textStyle: StyleText.fontSize16Weight500.copyWith(
                                    color: AppColors.white),
                                width: 150.sp,
                                height: 38.sp,
                                radius: 8.r,
                                color: AppColors.darkGrey),

                            Spacer(),

                            customButton(
                              title: cubit.getSaveForLaterText(context, widget.editingModel, S.of(context).submit, S.of(context).Save),
                              function: () {
                                cubit.handleSubmit(
                                  context,
                                  S.of(context).notifyServiceRequester,
                                  S.of(context).notifyServiceProvider,
                                  S.of(context).notifyProviderManager,
                                );
                              },
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                  color: AppColors.textButton
                              ),
                              width: 150.sp,
                              height: 38.sp,
                              radius: 8.r,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.sp),

                        if (shouldShowSaveForLaterButton)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              customButton(
                                  title: isEditingSubmittedService ? S.of(context).discardChange : S.of(context).saveForLater,
                                  function: () => _confirmThenSaveForLater(
                                    isEditingSubmittedService: isEditingSubmittedService,
                                  ),
                                  textStyle: StyleText.fontSize16Weight500.copyWith(
                                      color: AppColors.white),
                                  width: 150.sp,
                                  height: 38.sp,
                                  radius: 8.r,
                                  color: AppColors.darkGrey)
                            ],
                          ),
                        SizedBox(height: 20.sp),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ));
  }

  /// Shared style for the "When service SLA is about to be breached" label so
  /// the first row and every added row render identically.
  TextStyle _slaLabelStyle(bool lightMode) =>
      StyleText.fontSize12Weight500.copyWith(
        color: lightMode ? AppColors.blackButton : AppColors.white,
        letterSpacing: .34,
      );

  /// A percentage is invalid when it is non-empty and not a whole number.
  bool _isInvalidPercentage(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return false;
    return text.contains('.') ||
        text.contains(',') ||
        !RegExp(r'^\d+$').hasMatch(text);
  }

  /// Debounced save for the extra SLA fields.
  ///
  /// ✅ FIX: each `onChanged` used to declare its own local
  /// `Timer? debounceTimer` and immediately cancel it — a fresh null every
  /// keystroke, so nothing was ever debounced and every character triggered a
  /// write 500 ms later. The page-level [_debounceTimer] is reused instead.
  void _scheduleSlaSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      cubit.updateAndSaveModel();
    });
  }

  Future<void> _saveNotificationSwitchesToSharedPrefs() async {
    final reqMap = cubit.model.notificationSwitches[S.of(context).notifyServiceRequester] ?? {};
    final mgrMap = cubit.model.notificationSwitches[S.of(context).notifyProviderManager] ?? {};
    cubit.model.notifyRequesterSwitch0 = reqMap[0] ?? false;
    cubit.model.notifyManagerSwitch1 = mgrMap[0] ?? false;

    await SharedPrefsHelper.setBool('notifyRequesterSwitch0', cubit.model.notifyRequesterSwitch0);
    await SharedPrefsHelper.setBool('notifyManagerSwitch1', cubit.model.notifyManagerSwitch1);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    cubit.close();
    super.dispose();
  }
}
