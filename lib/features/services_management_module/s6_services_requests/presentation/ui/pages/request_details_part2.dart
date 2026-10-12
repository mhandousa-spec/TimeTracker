part of 'request_details.dart';

// Split from request_details.dart to keep files <700 LOC.

class _RequestServicesDetailsState extends State<RequestServicesDetails> {
  // ✅ Helper function to get user's language preference
  Future<bool> _getUserLanguagePreference(String userEmail) async {
    // I/O goes through the repository, never Firestore directly from the UI.
    final data = await ServicesManagerCubit.get(context)
        .repository
        .getUserByEmail(userEmail);
    if (data != null) {
      final languageCode = data['languageCode'] ?? 'en';
      return languageCode == 'ar';
    }
    return false;
  }

  // ✅ Send notification to first approver
  Future<void> _sendNotificationToFirstApprover({
    required String firstApproverEmail,
    required String serviceName,
    required String requesterName,
  }) async {
    if (firstApproverEmail.isEmpty) return;

    final employeeEntity =
        AppControllers.employee.employeeEntity!;
    final isArabic = await _getUserLanguagePreference(firstApproverEmail);

    await ServicesNotificationService.notifyApproverOfNewRequest(
      senderEmail: employeeEntity.email ?? '',
      approverEmail: firstApproverEmail,
      serviceName: serviceName,
      requesterName: requesterName,
      isArabic: isArabic,
    );
  }

  // ✅ Send notification to requester (confirmation)
  Future<void> sendNotificationToRequester({
    required String requesterEmail,
    required String serviceName,
    required bool isArabic,
  }) async {
    if (requesterEmail.isEmpty) return;

    final employeeEntity =
        AppControllers.employee.employeeEntity!;

    await ServicesNotificationService.notifyRequesterOfSubmission(
      senderEmail: employeeEntity.email ?? '',
      requesterEmail: requesterEmail,
      serviceName: serviceName,
      isArabic: isArabic,
    );
  }

  // ✅ Helper function to format duration units with proper plural handling
  String getLocalizedDurationUnit(BuildContext context, String? unit,
      String duration) {
    try {
      final durationValue = int.tryParse(duration) ?? 0;
      final isArabic = Localizations
          .localeOf(context)
          .languageCode == 'ar';

      if (isArabic) {
        // Arabic plural rules
        switch (unit?.toLowerCase()) {
          case 'day':
          case 'days':
          case 'يوم':
          case 'أيام':
            if (durationValue == 1) return 'يوم';
            if (durationValue == 2) return 'يومين';
            return 'أيام';
          case 'week':
          case 'weeks':
          case 'أسبوع':
          case 'أسابيع':
            if (durationValue == 1) return 'أسبوع';
            if (durationValue == 2) return 'أسبوعين';
            return 'أسابيع';
          case 'month':
          case 'months':
          case 'شهر':
          case 'أشهر':
            if (durationValue == 1) return 'شهر';
            if (durationValue == 2) return 'شهرين';
            return 'أشهر';
          case 'year':
          case 'years':
          case 'سنة':
          case 'سنوات':
            if (durationValue == 1) return 'سنة';
            if (durationValue == 2) return 'سنتين';
            return 'سنوات';
          case 'hours':
            return S
                .of(context)
                .duration_unit_hours;
          case 'minutes':
            return S
                .of(context)
                .duration_unit_minutes;
          case 'seconds':
            return S
                .of(context)
                .duration_unit_seconds;
          default:
            return unit ?? '';
        }
      } else {
        // English plural rules
        switch (unit?.toLowerCase()) {
          case 'day':
          case 'days':
          case 'يوم':
          case 'أيام':
            return durationValue == 1 ? 'day' : 'days';
          case 'week':
          case 'weeks':
          case 'أسبوع':
          case 'أسابيع':
            return durationValue == 1 ? 'week' : 'weeks';
          case 'month':
          case 'months':
          case 'شهر':
          case 'أشهر':
            return durationValue == 1 ? 'month' : 'months';
          case 'year':
          case 'years':
          case 'سنة':
          case 'سنوات':
            return durationValue == 1 ? 'year' : 'years';
          case 'hours':
            return S
                .of(context)
                .duration_unit_hours;
          case 'minutes':
            return S
                .of(context)
                .duration_unit_minutes;
          case 'seconds':
            return S
                .of(context)
                .duration_unit_seconds;
          default:
            return unit ?? '';
        }
      }
    } catch (e) {
      return unit ?? '';
    }
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    final isLandscape = MediaQuery
        .of(context)
        .orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations
        .localeOf(context)
        .languageCode == 'ar';
    final lightMode = Theme
        .of(context)
        .brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;

    final formattedDurationUnit = getLocalizedDurationUnit(
      context,
      widget.requestModel.currentSelectedDurationUnit,
      widget.requestModel.currentDurationOfServices,
    );

    var disappearHome = true;

    return SlideInContent(from: SlideFrom.bottom, child: Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: FormatHelper.capitalize(S
              .of(context)
              .services),
          onFirstTap: () {
            navigateTo(context, LayoutScreenServices());
          },
          secondTitle: !disappearHome
              ? FormatHelper.capitalize(
            isArabic
                ? (widget.requestModel.currentServiceNameArabic.isNotEmpty
                ? widget.requestModel.currentServiceNameArabic
                : widget.requestModel.currentServiceNameEnglish)
                : widget.requestModel.currentServiceNameEnglish,
          )
              : FormatHelper.capitalize(S
              .of(context)
              .serviceRequests),
          onSecondTap: () {
            Navigator.pop(context);
          },
          thirdTitle: !disappearHome
              ? null
              : FormatHelper.capitalize(
            isArabic
                ? (widget.requestModel.currentServiceNameArabic.isNotEmpty
                ? widget.requestModel.currentServiceNameArabic
                : widget.requestModel.currentServiceNameEnglish)
                : widget.requestModel.currentServiceNameEnglish,
          ),
          // Not a bare scroll view — see `SideFrameScrollableBody`. The frame
          // already scrolls this child on the phone branch, so a second
          // viewport here is unbounded and throws during layout.
          child: SideFrameScrollableBody(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(S
                          .of(context)
                          .serviceDetails),
                      style: StyleText.fontSize16Weight600.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white),
                    )
                  ],
                ),
                SizedBox(height: 4.sp),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: lightMode
                        ? AppColors.white
                        : AppColors.chatBackground,
                  ),
                  child: Column(
                    children: [
                      ServiceHeaderWidget(requestModel: widget.requestModel),
                      SizedBox(height: 18.sp),

                      FutureBuilder<Map<String, dynamic>?>(
                        future: selectServiceProvider(
                            widget.requestModel.currentId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState
                              .waiting) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    masterShimmerPlaceholder(context: context,
                                        width: 200,
                                        height: 20),
                                    SizedBox(height: 10.h),
                                    masterShimmerPlaceholder(context: context,
                                        width: 150,
                                        height: 20),
                                    SizedBox(height: 10.h),
                                    masterShimmerPlaceholder(context: context,
                                        width: 180,
                                        height: 20),
                                  ],
                                ),
                                isMobile
                                    ? SizedBox()
                                    : SizedBox(width: MediaQuery
                                    .sizeOf(context)
                                    .width * .05),
                                isMobile
                                    ? SizedBox()
                                    : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    masterShimmerPlaceholder(context: context,
                                        width: 160,
                                        height: 20),
                                    SizedBox(height: 10.h),
                                    masterShimmerPlaceholder(context: context,
                                        width: 140,
                                        height: 20),
                                    SizedBox(height: 10.h),
                                    masterShimmerPlaceholder(context: context,
                                        width: 180,
                                        height: 20),
                                  ],
                                ),
                              ],
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            final provider = snapshot.data!;
                            return buildProviderServiceDetailsServices(
                              context: context,
                              owningDepartment: widget.requestModel
                                  .currentDepartmentRequester,
                              durationUnit: FormatHelper.capitalize(
                                  formattedDurationUnit),
                              provider: provider,
                              requestModel: widget.requestModel,
                            );
                          } else {
                            return Center(
                              child: Text(
                                'No provider data found.',
                                style: StyleText.fontSize14Weight400.copyWith(
                                  color: lightMode
                                      ? AppColors.secondaryText
                                      : AppColors.grey,
                                ),
                              ),
                            );
                          }
                        },
                      ),

                      SizedBox(height: 20.h),
                      if (widget.requestModel.currentApprovalCycle
                          .isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${S
                                  .of(context)
                                  .approvalCycle}: ",
                              style: StyleText.fontSize14Weight400.copyWith(
                                  color: lightMode
                                      ? AppColors.secondaryText
                                      : AppColors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        ApprovalCycleWidgetServices(
                          approvalCycle: widget.requestModel
                              .currentApprovalCycle,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.sp),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ── BACK BUTTON ──────────────────────────────────────────
                    customButton(
                      title: FormatHelper.capitalize(S
                          .of(context)
                          .back),
                      function: () {
                        Navigator.pop(context);
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                          color: AppColors.onSecondaryAction),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.secondaryAction,
                    ),
                    Spacer(),
                    // ── REQUEST SERVICE BUTTON ───────────────────────────────
                    customButton(
                      title: FormatHelper.capitalize(S
                          .of(context)
                          .requestService),
                      function: () async {
                        // ── Step 1: Confirmation ──────────────────────────────
                        final confirmed =
                        await RequestServiceDialogs.showConfirmationDialog(
                            context);

                        if (confirmed != true) {
                          return;
                        }

                        // ── Step 2: Show loading dialog ───────────────────────
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          useRootNavigator: true,
                          builder: (loadingContext) =>
                              WillPopScope(
                                onWillPop: () async => false,
                                child: Dialog(
                                  backgroundColor:
                                  Theme
                                      .of(loadingContext)
                                      .brightness == Brightness.light
                                      ? AppColors.white
                                      : AppColors.chatBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 30.h, horizontal: 20.w),
                                    width: !isMobile ? 500.w : 350.w,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleProgressMaster(),
                                        SizedBox(height: 20.h),
                                        Text(
                                          FormatHelper.capitalize(
                                              S
                                                  .of(loadingContext)
                                                  .pleaseWait),
                                          style: StyleText.fontSize16Weight500
                                              .copyWith(
                                            color: Theme
                                                .of(loadingContext)
                                                .brightness ==
                                                Brightness.light
                                                ? AppColors.blackButton
                                                : AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        );

                        try {

                          final employeeController =
                          AppControllers.employee;

                          if (employeeController.employeeEntity == null) {
                            throw Exception("Please log in first");
                          }

                          final loggedInEmployee =
                          employeeController.employeeEntity!;
                          final requesterEmail = loggedInEmployee.email ?? '';

                          if (requesterEmail.isEmpty) {
                            throw Exception("Employee email is required");
                          }

                          final random = Random().nextInt(100);
                          final dateTime = Timestamp.now().toDate();
                          final formatted =
                          DateFormat("MMMdd_yyyy").format(dateTime);
                          final docId = "Request$random$formatted";

                          final approvalList =
                              widget.requestModel.currentApprovalCycle;
                          final initialState =
                          approvalList.isEmpty ? 'approved' : 'pending';

                          final updatedRequest =
                          ServicesHistoryModel.createMinimalRequest(
                            parentServiceId: widget.requestModel.currentId,
                            id: widget.requestModel.currentId,
                            providerServices:
                            widget.requestModel.currentProviderServices,
                            emailRequester: requesterEmail,
                            approvalCycle: approvalList,
                            state: initialState,
                            status: 'active',
                          );

                          final requesterFullName =
                          "${loggedInEmployee.firstName ??
                              ''} ${loggedInEmployee.lastName ?? ''}"
                              .trim();

                          final servicesRequestedModel = RequestedServices(
                            id: updatedRequest.currentId,
                            requestDate: formatted,
                            serviceProvider: updatedRequest
                                .currentProviderServices,
                            serviceRequester: requesterFullName,
                            status: "Active",
                            state: initialState,
                          );

                          // B1 FIX: check the write actually succeeded before
                          // showing "success". Both methods now return a bool.
                          final bool okAdd = await ServicesManagerCubit
                              .get(context)
                              .addRequestedService(
                            docId: updatedRequest.currentId,
                            requestModel: servicesRequestedModel,
                            uidUser: updatedRequest.currentId,
                          );

                          final bool okUpload = await ServicesManagerCubit.get(context)
                              .uploadRequestServices(docId, updatedRequest);

                          if (!okAdd || !okUpload) {
                            // Close the loading dialog and surface the failure
                            // instead of a false success + navigation.
                            if (Navigator.of(context, rootNavigator: true).canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                            if (!mounted) return;
                            await showDialog(
                              context: context,
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

                          await ServicesManagerCubit.get(context)
                              .getMyRequestServices();
                          await ServicesManagerCubit.get(context)
                              .getMyApprovalServices(requesterEmail);

                          // ── Prepare notification data ─────────────────────
                          final requesterFirstName = isArabic
                              ? (loggedInEmployee.firstNameInArabic ??
                              loggedInEmployee.firstName ?? '')
                              : (loggedInEmployee.firstName ?? '');
                          final requesterLastName = isArabic
                              ? (loggedInEmployee.lastNameInArabic ??
                              loggedInEmployee.lastName ?? '')
                              : (loggedInEmployee.lastName ?? '');
                          final requesterFullNameForNotification =
                          "$requesterFirstName $requesterLastName".trim();

                          final serviceNameForNotification = isArabic
                              ? widget.requestModel.currentServiceNameArabic
                              : widget.requestModel.currentServiceNameEnglish;

                          // ── Fire & forget notifications ───────────────────
                          Future.microtask(() async {
                            try {
                              if (requesterEmail.isNotEmpty) {
                                await sendNotificationToRequester(
                                  requesterEmail: requesterEmail,
                                  serviceName: serviceNameForNotification,
                                  isArabic: isArabic,
                                );
                              }
                            } catch (e) {
                            }
                          });

                          Future.microtask(() async {
                            try {
                              if (approvalList.isNotEmpty) {
                                final firstApprover = approvalList.first;
                                final firstApproverEmail =
                                    firstApprover.email ?? '';
                                if (firstApproverEmail.isNotEmpty) {
                                  await _sendNotificationToFirstApprover(
                                    firstApproverEmail: firstApproverEmail,
                                    serviceName: serviceNameForNotification,
                                    requesterName:
                                    requesterFullNameForNotification,
                                  );
                                }
                              }
                            } catch (e) {
                            }
                          });

                          // ── Step 3: Close loading dialog ──────────────────
                          Navigator.of(context, rootNavigator: true).pop();

                          await Future.delayed(Duration(milliseconds: 300));

                          if (!mounted) return;

                          // ── Step 4: Timer fires → close dialog → navigate ─
                          // ✅ CRITICAL: Use Timer + Get.offAll (no context/mounted needed)
                          Future.delayed(Duration(seconds: 2), () {
                            Get.back(); // closes success dialog
                            navigateTo(context, MyRequestServicesToggle());
                          });

                          // ── Step 5: Show success dialog ───────────────────
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            useRootNavigator: true,
                            builder: (successContext) {
                              return WillPopScope(
                                onWillPop: () async => false,
                                child: Dialog(
                                  backgroundColor: Theme
                                      .of(successContext)
                                      .brightness ==
                                      Brightness.light
                                      ? AppColors.white
                                      : AppColors.chatBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8.r)),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 30.h, horizontal: 20.w),
                                    width: !isMobile ? 500.w : 350.w,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Lottie.asset(
                                          'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                                          width: 80.w,
                                          height: 80.h,
                                          fit: BoxFit.scaleDown,
                                          repeat: false,
                                        ),
                                        SizedBox(height: 15.h),
                                        Text(
                                          FormatHelper.capitalize(S
                                              .of(successContext)
                                              .serviceRequested),
                                          style: StyleText.fontSize20Weight500
                                              .copyWith(
                                            color: Theme
                                                .of(successContext)
                                                .brightness ==
                                                Brightness.light
                                                ? AppColors.blackButton
                                                : AppColors.white,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          FormatHelper.capitalize(S
                                              .of(successContext)
                                              .YouSuccessfullyRequestedThisService),
                                          textAlign: TextAlign.center,
                                          style: StyleText.fontSize14Weight500
                                              .copyWith(
                                            color: Theme
                                                .of(successContext)
                                                .brightness ==
                                                Brightness.light
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
                          );

                        } catch (e, stackTrace) {

                          // Close loading dialog on error
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }

                          if (!mounted) return;

                          showDialog(
                            context: context,
                            builder: (errorContext) =>
                                AlertDialog(
                                  backgroundColor:
                                  Theme
                                      .of(errorContext)
                                      .brightness ==
                                      Brightness.light
                                      ? AppColors.white
                                      : AppColors.chatBackground,
                                  title: Text(
                                    FormatHelper.capitalize(
                                        S
                                            .of(errorContext)
                                            .error),
                                    style: StyleText.fontSize16Weight600
                                        .copyWith(
                                      color: Theme
                                          .of(errorContext)
                                          .brightness ==
                                          Brightness.light
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                  ),
                                  content: Text(
                                    "Failed to create service request. Please try again.",
                                    style: StyleText.fontSize14Weight400
                                        .copyWith(
                                      color: Theme
                                          .of(errorContext)
                                          .brightness ==
                                          Brightness.light
                                          ? AppColors.secondaryText
                                          : AppColors.grey,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(errorContext).pop(),
                                      child: Text(
                                        FormatHelper.capitalize(
                                            S
                                                .of(errorContext)
                                                .ok),
                                        style: StyleText.fontSize16Weight500
                                            .copyWith(color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        }
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
