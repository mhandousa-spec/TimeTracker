part of 'sla_screen_mobile.dart';

// Split from sla_screen_mobile.dart to keep files <700 LOC.

class _SlaScreenMobileState extends State<SlaScreenMobile> {
  final SlaCubit _slaCubit = SlaCubit();
  final TextEditingController _providerPercentageController =
      TextEditingController();
  final TextEditingController _managerPercentageController =
      TextEditingController();

  bool _showProviderPercentageError = false;
  bool _showManagerPercentageError = false;

  Map<String, bool> _providerSwitches = {
    'When Service Requested And Approved': false,
    'When Service Status Changes': false,
  };

  Map<String, bool> _sectionCheckboxes = {
    SlaNotificationKeys.serviceRequester: true,
    SlaNotificationKeys.serviceProvider: true,
    SlaNotificationKeys.providerManager: true,
  };

  String? formatDate;

  @override
  void initState() {
    super.initState();

    final rawJson = ServicesManagerCubit.get(context).docServiceRawJson;
    _slaCubit.seedFromDocRawJson(rawJson);

    final dateTime = Timestamp.now().toDate();
    formatDate = DateFormat("MMMdd_yyyy").format(dateTime);

    _loadFromModel();
  }

  bool _isInteger(String value) {
    return int.tryParse(value) != null;
  }

  @override
  void dispose() {
    _providerPercentageController.dispose();
    _managerPercentageController.dispose();
    _slaCubit.close();
    super.dispose();
  }

  Future<void> _loadFromModel() async {
    final model = ServicesManagerCubit.get(context).docService;
    setState(() {
      // ✅ UPDATED: Access .current from FieldHistory
      _providerPercentageController.text =
          model?.currentSlaOneControllerEnglish ?? '';
      _managerPercentageController.text =
          model?.currentSlaTwoControllerEnglish ?? '';
      _sectionCheckboxes[SlaNotificationKeys.serviceRequester] =
          model?.currentNotifyRequesterChecked ?? true;
      _sectionCheckboxes[SlaNotificationKeys.serviceProvider] =
          model?.currentNotifyProviderChecked ?? true;
      _sectionCheckboxes[SlaNotificationKeys.providerManager] =
          model?.currentNotifyManagerChecked ?? true;
      _providerSwitches['When Service Requested And Approved'] =
          model?.currentNotifyRequesterSwitch0 ?? false;
      _providerSwitches['When Service Status Changes'] =
          model?.currentNotifyManagerSwitch1 ?? false;
    });
  }

  Future<ServicesHistoryModel> createModelFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('service_status') ?? true;
    // ✅ UPDATED: Use ServicesModel.createNew()
    return ServicesHistoryModel.createNew(
      id: '',
      state: 'draft',
      status: isActive ? 'active' : 'inactive',  // ✅ FIX
      //      serviceNameEnglish: prefs.getString('service_name_en') ?? '',
      serviceNameArabic: prefs.getString('service_name_ar') ?? '',
      serviceDescriptionEnglish:
          prefs.getString('service_description_en') ?? '',
      serviceDescriptionArabic: prefs.getString('service_description_ar') ?? '',
      durationOfServices: prefs.getString('duration_value') ?? '',
      selectedDurationUnit: prefs.getString('duration_unit') ?? '',
      providerServices: await SharedPrefsEmployeeHelper.getSelectedEmployees(),
    );
  }

  Future<void> _submitAllToSharedPrefs() async {
    await _slaCubit.submitPercentagesAndSwitches(
      providerPercentage: _providerPercentageController.text,
      managerPercentage: _managerPercentageController.text,
      sectionCheckboxes: _sectionCheckboxes,
      providerSwitches: _providerSwitches,
    );

    final modelServicesModel = await createModelFromSharedPrefs();

    // ✅ UPDATED: Access .current from FieldHistory
    final docId = widget.editingModel?.currentId ??
        "User${Random().nextInt(100)}${DateFormat("MMMdd_yyyy").format(Timestamp.now().toDate())}";

    final isEdit = widget.editingModel != null;

    if (isEdit) {
      await ServicesManagerCubit.get(context)
          .updateService(docId, modelServicesModel);
    } else {
      await ServicesManagerCubit.get(context)
          .saveService(docId, modelServicesModel);
    }
  }

  Future<bool> _createService() async {
    final prefs = await SharedPreferences.getInstance();
    final isEdit = widget.editingModel != null;

    // ✅ UPDATED: Access .current from FieldHistory
    final oldDocId = widget.editingModel?.currentId ?? '';
    final formattedDate =
        DateFormat("MMMdd_yyyy").format(Timestamp.now().toDate());
    final randomId = Random().nextInt(100);
    final hasUserPrefix = oldDocId.startsWith('User');
    final docId =
        isEdit && hasUserPrefix ? oldDocId : "User${randomId}${formattedDate}";
    final isActive = prefs.getBool('service_status') ?? true;
    // ✅ UPDATED: Use ServicesModel.createNew()
    final model = ServicesHistoryModel.createNew(
      id: docId,
      state: isActive ? 'active' : 'inactive',    // ✅ FIX
      status: isActive ? 'active' : 'inactive',   // ✅ FIX
      serviceNameEnglish:
          await SharedPrefsHelper.getString("service_name_en") ?? '',
      serviceNameArabic:
          await SharedPrefsHelper.getString("service_name_ar") ?? '',
      serviceDescriptionEnglish:
          await SharedPrefsHelper.getString("service_description_en") ?? '',
      serviceDescriptionArabic:
          await SharedPrefsHelper.getString("service_description_ar") ?? '',
      durationOfServices:
          await SharedPrefsHelper.getString("duration_value") ?? '',
      selectedDurationUnit:
          await SharedPrefsHelper.getString("duration_unit") ?? '',
      selectDepartment: await SharedPrefsDepartmentsHelper.getDepartments(),
      limitAvailability:
          await SharedPrefsHelper.getBool("limit_availability") ?? false,
      requireApproval:
          await SharedPrefsHelper.getBool("require_approval") ?? false,
      providerServices: await SharedPrefsEmployeeHelper.getSelectedEmployees(),
      approvalCycle: await SharedPrefsApprovalHelper.getApprovalCycle(),
      notifyManagerChecked:
          prefs.getBool('${SlaNotificationKeys.providerManager}_checked') ?? true,
      notifyProviderChecked:
          prefs.getBool('${SlaNotificationKeys.serviceProvider}_checked') ?? true,
      notifyRequesterChecked:
          prefs.getBool('${SlaNotificationKeys.serviceRequester}_checked') ?? true,
      notifyRequesterSwitch0:
          prefs.getBool('${SlaNotificationKeys.serviceRequester}_switch_0') ?? false,
      notifyManagerSwitch1:
          prefs.getBool('${SlaNotificationKeys.providerManager}_switch_1') ?? false,
      slaOneControllerEnglish: prefs.getString('sla_one') ?? '',
      imageUrl: await SharedPrefsHelper.getString("service_image_url") ?? '',
      slaTwoControllerEnglish: prefs.getString('sla_two') ?? '',
      departmentRequester: prefs.getString("departmentRequester") ?? '',
      emailRequester: prefs.getString("emailRequester") ?? '',
      firstNameRequester: prefs.getString("firstNameRequester") ?? '',
      lastNameRequester: prefs.getString("lastNameRequester") ?? '',
      genderRequester: prefs.getString("genderRequester") ?? '',
      phoneRequester: prefs.getString("phoneRequester") ?? '',
      jobTitleRequester: prefs.getString("jobTitleRequester") ?? '',
      firstNameRequesterArabic:
          prefs.getString("firstNameRequesterArabic") ?? '',
      lastNameRequesterArabic: prefs.getString("lastNameRequesterArabic") ?? '',
      jobTitleRequesterArabic: prefs.getString("jobTitleRequesterArabic") ?? '',
    );

    // ✅ UPDATED: Access .current from FieldHistory
    // B3 FIX: gate draft deletion + success on the write actually succeeding.
    final bool ok =
        isEdit && widget.editingModel!.currentState == "submitted"
            ? await ServicesManagerCubit.get(context).updateService(docId, model)
            : await ServicesManagerCubit.get(context).saveService(docId, model);

    if (!ok) return false;

    // ✅ UPDATED: Access .current from FieldHistory
    if (widget.editingModel?.currentId != null) {
      await SharedPrefsServiceMaster.removeDraftById(
          widget.editingModel!.currentId);
    }

    ServicesManagerCubit.get(context).getAllServices();
    return true;
  }

  void _handleSubmit() async {
    final navCtxStable = context;

    final bool ok = await _createService();
    if (!ok) {
      if (!mounted) return;
      await showDialog(
        context: navCtxStable,
        builder: (dctx) => AlertDialog(
          title: Text(S.of(dctx).error),
          content: Text(S.of(dctx).errorOccurred),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: Text(S.of(dctx).ok),
            ),
          ],
        ),
      );
      return;
    }

    await _showSuccessDialog(navCtxStable);
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    final navCtxStable = context;
    final isEditMode = widget.editingModel != null;

    // Services mobile QA p.18 — black screen after editing a service.
    //
    // The old auto-close ran `Navigator.of(root).pop()` 2s after the dialog
    // opened, whatever was on top by then. The dialog is barrier-dismissible,
    // so a tap outside closed it first and the timer then popped the PAGE
    // under it; with nothing left on the root navigator the app showed a
    // black screen (and `navigateAndFinish` then ran on a dead context).
    //
    // Now the timer only pops when this dialog's own route is still the top
    // one, and the navigation home happens once, after the dialog has gone —
    // whichever way it was closed.
    Route<dynamic>? dialogRoute;
    Future<void>.delayed(const Duration(seconds: 2), () {
      final Route<dynamic>? route = dialogRoute;
      if (route != null && route.isCurrent) {
        route.navigator?.pop();
      }
    });

    await showDialog(
      context: navCtxStable,
      barrierDismissible: true,
      builder: (successDialogContext) {
        dialogRoute ??= ModalRoute.of(successDialogContext);

        return Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: SizedBox(
              width: 410.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                    width: 70.w,
                    height: 70.h,
                    fit: BoxFit.scaleDown,
                    repeat: true,
                    animate: true,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    isEditMode
                        ? S.of(successDialogContext).editSuccess
                        : S.of(successDialogContext).createSuccess,

                    style: StyleText.fontSize20Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    isEditMode
                        ? S.of(successDialogContext).YouSuccessfullyEditedThisService
                        : S.of(successDialogContext).YouSuccessfullyCreatedThisService,
                    textAlign: TextAlign.center,
                    style: StyleText.fontSize14Weight500.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    navigateAndFinish(navCtxStable, LayoutScreenServices());
  }

  void _showConfirmDialog() {
    final navCtxStable = context;
    final isEditMode = widget.editingModel != null;

    showDialog(
      context: navCtxStable,
      barrierDismissible: false,
      builder: (confirmDialogContext) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Container(
          width: 300.sp,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                isEditMode
                    ? 'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json'  // Use different animation for edit mode if available
                    : 'assets/lottie_assets/main_lottie_assets/lottie_confirmation.json',
                width: 70.w,
                height: 70.h,
                fit: BoxFit.scaleDown,
                repeat: true,
                animate: true,
              ),
              SizedBox(height: 20.sp),
              Text(
                isEditMode
                    ? S.of(confirmDialogContext).editingService  // You'll need to add this to your localization
                    : S.of(confirmDialogContext).creatingService,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                isEditMode
                    ? S.of(confirmDialogContext).areYouSureEditService  // You'll need to add this to your localization
                    : S.of(confirmDialogContext).areYouSureCreateService,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              SizedBox(height: 15.sp),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.of(navCtxStable, rootNavigator: true).pop(),
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryAction,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(confirmDialogContext).no,
                          style: StyleText.fontSize16Weight500
                              .copyWith(color: AppColors.onSecondaryAction),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 28.sp),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          ServicesManagerCubit.get(navCtxStable)
                              .getAllServices();

                          Navigator.of(navCtxStable, rootNavigator: true).pop();

                          _handleSubmit();
                        } catch (e, st) {
                          if (Navigator.of(navCtxStable, rootNavigator: true)
                              .canPop()) {
                            Navigator.of(navCtxStable, rootNavigator: true)
                                .pop();
                          }
                        }
                      },
                      child: Container(
                        height: 38.sp,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          S.of(confirmDialogContext).yes,
                          style: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextEditingController controller1 = TextEditingController();

  final Map<int, bool> _providerSwitchStates = {};
  bool _hasTyped = false;

  bool isNumericOnly(String text) {
    final numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(text);
  }

  Map<int, bool> switchStates = {};

  List<TextEditingController> notifyProviderControllers = [];
  List<TextEditingController> notifyManagerControllers = [];
  final Map<String, List<TextEditingController>> notificationControllers = {};

  List<TextEditingController> dynamicSlaControllers = [TextEditingController()];
  List<TextEditingController> dynamicSlaTwoControllers = [
    TextEditingController()
  ];

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return SlideInContent(from: SlideFrom.bottom, child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor:
        AppColors.background,
        statusBarIconBrightness: lightMode ? Brightness.dark : Brightness.light,
        statusBarBrightness: lightMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? Matrix4.rotationY(3.1416)
                                  : Matrix4.identity(),
                          child: SvgPicture.asset(
                            "assets/icons_assets/main_icons_assets/chevron_left.svg",
                            width: 18.sp,
                            height: 18.sp,
                            fit: BoxFit.cover,
                            color: AppColors.text,
                            semanticsLabel: 'Back Arrow',
                          ),
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      Text(
                        // ✅ UPDATED: Access .current from FieldHistory
                        widget.editingModel != null
                            ? "${S.of(context).Editing} ${Localizations.localeOf(context).languageCode == 'ar' ? widget.editingModel!.currentServiceNameArabic : widget.editingModel!.currentServiceNameEnglish}"
                            : S.of(context).creatingNewService,
                        style: StyleText.fontSize20Weight600.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.sp),
                  Container(
                    padding: EdgeInsets.only(left: 15.sp, right: 15.sp),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.sp),
                        Text(
                          FormatHelper.capitalize(
                              S.of(context).ServiceFulfillment),
                          style: StyleText.fontSize18Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 20.sp),
                        Text(
                          FormatHelper.capitalize(
                              S.of(context).SendNotifications),
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.text,
                          ),
                        ),
                        SizedBox(height: 29.sp),
                        this._buildSection(
                          title: S.of(context).notifyServiceRequester,
                          items: [
                            S.of(context).WhenTheirManagerApprovesTheService,
                            S.of(context).whenServiceStatusChanges,
                            S
                                .of(context)
                                .whenTheyReceiveCommentFromServiceProvider,
                            S.of(context).whenSlaIsBreached,
                          ],
                        ),
                        this._buildSection(
                          title: S.of(context).notifyServiceProvider,
                          items: [
                            S
                                .of(context)
                                .WhenServiceIsRequestedAndApprovedByTheRequester,
                            S.of(context).whenTheyReceiveCommentFromRequester,
                            S.of(context).whenSlaIsBreached,
                          ],
                          showSLA: true,
                          controller: _providerPercentageController,
                          showError: _showProviderPercentageError,
                          onChanged: (value) {
                            setState(() {
                              _showProviderPercentageError = !_isInteger(value);
                            });
                          },
                        ),
                        this._buildSectionTwo(
                          title: S.of(context).notifyProviderManager,
                          items: [S.of(context).whenProviderBreachedSla],
                          showSLA: true,
                          switchStates: _providerSwitchStates,
                          onToggleIndexSwitch: (index, value) {
                            setState(() {
                              _providerSwitchStates[index] = value;
                            });
                          },
                          switches: _providerSwitches,
                          onToggleSwitch: (key, value) {
                            setState(() {
                              _providerSwitches[key] = value;
                            });
                          },
                          controller: _managerPercentageController,
                          showError: _showManagerPercentageError,
                          onChanged: (value) {
                            setState(() {
                              _showManagerPercentageError = !_isInteger(value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.sp),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (widget.editingModel != null) {
                              // ✅ Edit mode: Discard = just go back
                              Navigator.pop(context);
                            } else {
                              // ✅ Create mode: Save for later
                              saveDraft();
                            }
                          },
                          child: Container(
                            height: 38.sp,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryAction,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.editingModel != null
                                  ? S.of(context).discard
                                  : S.of(context).saveForLater,
                              style: StyleText.fontSize16Weight500
                                  .copyWith(color: AppColors.onSecondaryAction),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 75.sp),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showConfirmDialog(),
                          child: Container(
                            height: 38.sp,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            alignment: Alignment.center,
                            // Services mobile QA p.16: the last step of an
                            // edit read "Update"; it is "Submit" in both
                            // create and edit, as in Figma.
                            child: Text(
                              S.of(context).submit,
                              style: StyleText.fontSize16Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  Future<void> saveDraft() async {
    await _submitAllToSharedPrefs();

    final nameEn = await SharedPrefsHelper.getString('service_name_en');
    final nameAr = await SharedPrefsHelper.getString('service_name_ar');
    final descEn = await SharedPrefsHelper.getString('service_description_en');
    final descAr = await SharedPrefsHelper.getString('service_description_ar');
    final durationVal = await SharedPrefsHelper.getString('duration_value');
    final durationUnit = await SharedPrefsHelper.getString('duration_unit');
    final slaOne = await SharedPrefsHelper.getString('sla_one');
    final slaTwo = await SharedPrefsHelper.getString('sla_two');
    final selectedProviders =
        await SharedPrefsEmployeeHelper.getSelectedEmployees();
    final selectedDepartments =
        await SharedPrefsDepartmentsHelper.getDepartments();
    final selectedEmployees =
        await SharedPrefsApprovalHelper.getApprovalCycle();

    // ✅ UPDATED: Use ServicesModel.createNew()
    final model = ServicesHistoryModel.createNew(
      id: '',
      state: "draft",
      status: "draft",
      serviceNameEnglish: nameEn ?? '',
      serviceNameArabic: nameAr ?? '',
      serviceDescriptionEnglish: descEn ?? '',
      serviceDescriptionArabic: descAr ?? '',
      durationOfServices: durationVal ?? '',
      selectedDurationUnit: durationUnit ?? '',
      providerServices: selectedProviders,
      selectDepartment: selectedDepartments,
      approvalCycle: selectedEmployees
          .cast<EmployeeEntityModell>()
          .map((e) => EmployeeEntityModell(
                id: e.id ?? '',
                state: "pending",
                firstName: e.firstName,
                middleName: e.middleName,
                lastName: e.lastName,
                email: e.email,
                gender: e.gender,
                title: e.title,
              ))
          .toList(),
      slaOneControllerEnglish: slaOne ?? '',
      slaTwoControllerEnglish: slaTwo ?? '',
      notifyRequesterChecked:
          _sectionCheckboxes[SlaNotificationKeys.serviceRequester] ?? true,
      notifyProviderChecked:
          _sectionCheckboxes[SlaNotificationKeys.serviceProvider] ?? true,
      notifyManagerChecked:
          _sectionCheckboxes[SlaNotificationKeys.providerManager] ?? true,
      notifyRequesterSwitch0:
          _providerSwitches['When Service Requested And Approved'] ?? false,
      notifyManagerSwitch1:
          _providerSwitches['When Service Status Changes'] ?? false,
    );

    // ✅ UPDATED: Access .current from FieldHistory
    if (widget.editingModel != null && widget.editingModel!.currentId != null) {
      final updatedDraft = model.copyWith(id: widget.editingModel!.currentId);
      await SharedPrefsServiceMaster.updateDraft(updatedDraft, updatedDraft);
    } else {
      await SharedPrefsServiceMaster.saveDraft(model);
    }

    await _showSuccessDialog(context);
  }

}
