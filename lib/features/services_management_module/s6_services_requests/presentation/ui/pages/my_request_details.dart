/// Module: services_management_module
/// Description: "My request" details page — shows request status, approval
///              cycle, provider info and comments for a single request the
///              current user submitted, with a cancel-request action.
/// Author: Amr Mesbah
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, MyRequestDetailsCubit, ServicesManagerCubit,
///               RequestProviderSection, RequestReasonComments
/// Revision History: Split from a single 1694-LOC file into
///                    MyRequestDetailsCubit (all Firestore I/O) +
///                    ui/widgets/my_request_cancel_button.dart +
///                    ui/widgets/my_request_service_info_card.dart +
///                    ui/widgets/my_request_status_footer.dart (audit fix #1,
///                    #2 no direct picker/Firestore imports, #3 no try/catch
///                    or .collection( in the page).
import 'package:get/get.dart';


import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/request_provider_section.dart';

import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';



import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';


import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/my_request_details_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/my_request_details_state.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_provider_resolver.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/request_status_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/my_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/approval.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/approvals.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/show_request_details_shimmer.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/my_request_cancel_button.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/my_request_service_info_card.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/my_request_status_footer.dart';

import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/request_reason_comments.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import 'package:knowticed_plus/core/network/get_base_url.dart';
class MyRequestDetails extends StatelessWidget {
  const MyRequestDetails({
    required this.myRequestDetailsModel,
    super.key,
  });

  final ServicesHistoryModel myRequestDetailsModel;

  @override
  Widget build(BuildContext context) {
    final employeeEmail =
        AppControllers.employee.employeeEntity?.email ?? '';

    return BlocProvider(
      create: (context) => MyRequestDetailsCubit(
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
        repository: ServicesManagerCubit.get(context).repository,
        model: myRequestDetailsModel,
        requesterEmail: employeeEmail,
      )..initialize(),
      child: _MyRequestDetailsView(myRequestDetailsModel: myRequestDetailsModel),
    );
  }
}

class _MyRequestDetailsView extends StatefulWidget {
  const _MyRequestDetailsView({required this.myRequestDetailsModel});

  final ServicesHistoryModel myRequestDetailsModel;

  @override
  State<_MyRequestDetailsView> createState() => _MyRequestDetailsViewState();
}

class _MyRequestDetailsViewState extends State<_MyRequestDetailsView> {
  bool _isCommentExpanded = false;
  final TextEditingController _cancelController = TextEditingController();

  @override
  void dispose() {
    _cancelController.dispose();
    super.dispose();
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  String getOverallStatus(MyRequestDetailsData data) {
    final approvalCycle = widget.myRequestDetailsModel.currentApprovalCycle;
    String? docState = data.currentState?.toLowerCase();

    if (approvalCycle.isEmpty) {
      if (docState == 'cancel' ||
          docState == 'inprogress' ||
          docState == 'breached sla' ||
          docState == 'done' ||
          docState == 'rejected') {
        return docState!;
      }
      return 'approved';
    }

    if (docState == 'cancel') return 'cancel';
    if (docState == 'inprogress' || docState == 'breached sla' || docState == 'done') {
      return docState!;
    }

    for (final approver in approvalCycle) {
      final state = approver.state?.toLowerCase();
      if (state == 'rejected' || state == 'cancel') return state!;
    }

    for (final approver in approvalCycle) {
      if (approver.state?.toLowerCase() == 'pending') return 'pending';
    }

    if (approvalCycle.isNotEmpty) {
      final allApproved = approvalCycle.every((a) => a.state?.toLowerCase() == 'approved');
      if (allApproved) return 'approved';
    }

    return 'pending';
  }

  String _getLocalizedLabel(BuildContext context, String state) {
    switch (state.toLowerCase()) {
      case 'done':
        return S.of(context).Done;
      case 'approved':
        return S.of(context).Approved;
      case 'rejected':
        return S.of(context).Reject;
      case 'cancel':
        return S.of(context).Canceled;
      case 'pending':
        return S.of(context).Pending;
      case 'inprogress':
        return S.of(context).Inprogress;
      case 'breached sla':
        return S.of(context).BreachedSLA;
      default:
        return FormatHelper.capitalize(state);
    }
  }

  RequestProviderResolver get _providerResolver => RequestProviderResolver(
        model: widget.myRequestDetailsModel,
        requesterEmail: AppControllers.employee.employeeEntity?.email ?? '',
      );

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return BlocConsumer<MyRequestDetailsCubit, MyRequestDetailsState>(
      listener: (context, state) {
        if (state is MyRequestDetailsCancelError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is MyRequestDetailsLoading) {
          return Center(child: CircleProgressMaster());
        }

        final data = state is MyRequestDetailsLoaded
            ? state.data
            : state is MyRequestDetailsCancelling
                ? state.data
                : (state as MyRequestDetailsCancelError).data;

        final approvalCycle = widget.myRequestDetailsModel.currentApprovalCycle;
        List<EmployeeEntityModell> displayCycle = adjustCycleStates(approvalCycle);

        final docState = getOverallStatus(data);

        String stateLabel = getRequestStateLabel(docState);
        Color borderColor = getRequestBorderColor(docState);
        String iconAsset = getRequestIconAsset(docState);

        final bool hasRejection = hasRejectionInApprovalCycle(displayCycle);

        if (docState == 'cancel') {
          stateLabel = getRequestStateLabel('cancel');
          borderColor = getRequestBorderColor('cancel');
          iconAsset = getRequestIconAsset('cancel');
        } else if (hasRejection) {
          EmployeeEntityModell? rejected;
          for (var approver in displayCycle) {
            final s = approver.state?.toLowerCase();
            if (s == 'rejected' || s == 'cancel') {
              rejected = approver;
              break;
            }
          }
          if (rejected != null) {
            final s = rejected.state!.toLowerCase();
            stateLabel = getRequestStateLabel(s);
            borderColor = getRequestBorderColor(s);
            iconAsset = getRequestIconAsset(s);
          }
        } else if (docState != 'inprogress' &&
            docState != 'done' &&
            docState != 'breached sla' &&
            areAllApproversApproved(displayCycle)) {
          stateLabel = 'Approved';
          borderColor = AppColors.lightGreen;
          iconAsset = "assets/icons_assets/main_icons_assets/status_approved_check_green.svg";
        } else {
          int currentPending = displayCycle.indexWhere((e) => e.state?.toLowerCase() == 'pending');
          if (currentPending != -1) {
            stateLabel = 'Pending';
            borderColor = getRequestBorderColor('pending');
            iconAsset = getRequestIconAsset('pending');
          }
        }

        final hasPending = hasSpecificStateInApprovalCycle(approvalCycle, 'pending');
        final isCanceled = (data.currentState?.toLowerCase() ?? '') == 'cancel';
        final shouldShowReminder = hasPending && !hasRejection && !isCanceled;

        var isMobile = ContextExtensionss(context).isPhone;
        var isTablet = ContextExtension(context).isTablet;

        var disappearHome = true;

        final canCancel = (data.cancelReason?.isEmpty ?? true) &&
            !hasRejection &&
            (data.currentState?.toLowerCase() != 'cancel' &&
                data.currentState?.toLowerCase() != 'done');

        String? currentApproverEmail;
        for (final approver in displayCycle) {
          if (approver.state?.toLowerCase() == 'pending') {
            currentApproverEmail = approver.email;
            break;
          }
        }

        final isArabic = Localizations.localeOf(context).languageCode == 'ar';
        final reminderServiceName = isArabic
            ? widget.myRequestDetailsModel.currentServiceNameArabic
            : widget.myRequestDetailsModel.currentServiceNameEnglish;

        final hasBreachedSlaAt3 = widget.myRequestDetailsModel.currentApprovalCycle.length > 3 &&
            widget.myRequestDetailsModel.currentApprovalCycle[3].state == "Breached SLA";

        return SlideInContent(
          from: SlideFrom.bottom,
          child: Scaffold(
            body: SafeArea(
              child: SideFrameMasterServices(
                titleText: FormatHelper.capitalize(S.of(context).services),
                onFirstTap: () => navigateTo(context, LayoutScreenServices()),
                secondTitle: disappearHome
                    ? FormatHelper.capitalize(S.of(context).serviceRequests)
                    : FormatHelper.capitalize(S.of(context).myRequests),
                onSecondTap: () {
                  disappearHome
                      ? navigateTo(context, RequestServicesToggle())
                      : navigateTo(context, MyRequestServicesToggle());
                },
                thirdTitle: disappearHome
                    ? FormatHelper.capitalize(S.of(context).myRequests)
                    : data.isLoadingServiceDetails
                        ? '...'
                        : FormatHelper.capitalize(data.serviceNameToDisplay),
                onThirdTap: () => Navigator.pop(context),
                fourthTitle: disappearHome
                    ? (data.isLoadingServiceDetails ? '...' : FormatHelper.capitalize(data.serviceNameToDisplay))
                    : null,
                // FIXED 9/9/2026, REFIXED 10/9/2026 — this page rendered BLANK on
                // a phone below the frame's title row.
                //
                // `SideFrameMasterServices` lays its child out two different
                // ways: on tablet and desktop the child goes into an `Expanded`,
                // so the scroll view below is what makes the page scroll; on a
                // PHONE the frame puts the child inside a
                // `SingleChildScrollView` of its own — so this one was a
                // vertical viewport nested directly inside another vertical
                // viewport, handed an unbounded height, and layout threw
                // "Vertical viewport was given unbounded height" before
                // anything painted. The console then filled with
                // `'!semantics.parentDataDirty': is not true`, once per frame:
                // that assertion is what an unlaid-out subtree produces in
                // `flushSemantics`, not a second bug.
                //
                // The 9/9 fix wrapped the scroll view in `SideFrameBoundedBody`.
                // That silenced the throw by giving the inner viewport a height,
                // but left two nested scroll areas fighting for the drag and
                // pinned the page to one screen inside a frame that was already
                // scrolling — this page was the only one in the app using that
                // wrapper around a scroll view rather than around an `Expanded`,
                // which is what it is for.
                //
                // `SideFrameScrollableBody` is the right half of that pair: it
                // adds the scroll view on the bounded branch, where the page
                // needs one, and gets out of the way on the phone branch, where
                // the frame is already scrolling.
                child: SideFrameScrollableBody(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        if (!_isCommentExpanded) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                S.of(context).requestDetails,
                                style: StyleText.fontSize16Weight600.copyWith(
                                  color: lightMode ? AppColors.blackButton : AppColors.white,
                                ),
                              ),
                              Spacer(),
                              canCancel
                                  ? FutureBuilder<Map<String, dynamic>?>(
                                      future: _providerResolver.getRequestSpecificProvider(),
                                      builder: (context, snapshot) {
                                        final providerEmail =
                                            snapshot.data?['email']?.toString() ?? '';
                                        final requesterName = isArabic
                                            ? "${widget.myRequestDetailsModel.currentFirstNameRequesterArabic ?? ''} ${widget.myRequestDetailsModel.currentLastNameRequesterArabic ?? ''}"
                                                .trim()
                                            : "${widget.myRequestDetailsModel.currentFirstNameRequester} ${widget.myRequestDetailsModel.currentLastNameRequester}"
                                                .trim();

                                        return MyRequestCancelButton(
                                          isMobile: isMobile,
                                          cancelController: _cancelController,
                                          providerEmail: providerEmail.isEmpty ? null : providerEmail,
                                          serviceName: reminderServiceName,
                                          requesterName: requesterName,
                                          onCancelled: () async {
                                            await ServicesManagerCubit.get(context).getMyRequestServices();
                                            final email =
                                                AppControllers.employee.employeeEntity?.email;
                                            if (email != null) {
                                              await ServicesManagerCubit.get(context)
                                                  .getRequestedServices(email);
                                            }
                                          },
                                        );
                                      },
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          SizedBox(height: 8.sp),
                          Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(15.sp),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: lightMode ? AppColors.white : AppColors.chatBackground,
                                  border: hasBreachedSlaAt3
                                      ? Border.all(color: AppColors.red)
                                      : Border.all(color: Colors.transparent),
                                ),
                                child: Column(
                                  children: [
                                    MyRequestServiceInfoCard(
                                      imageUrl: widget.myRequestDetailsModel.currentImageUrl,
                                      isMobile: isMobile,
                                      isTablet: isTablet,
                                      isTabletLandscape: isTabletLandscape(context),
                                      serviceNameToDisplay: data.serviceNameToDisplay,
                                      serviceDescriptionToDisplay: data.serviceDescriptionToDisplay,
                                      isLoadingServiceDetails: data.isLoadingServiceDetails,
                                    ),
                                    SizedBox(height: 20.h),
                                    if (isMobile)
                                      MyRequestDescriptionWidget(
                                        serviceDescriptionToDisplay: data.serviceDescriptionToDisplay,
                                        isLoadingServiceDetails: data.isLoadingServiceDetails,
                                      ),
                                    if (isMobile) SizedBox(height: 20.sp),
                                    RequestProviderSection(
                                      model: widget.myRequestDetailsModel,
                                      requesterEmail: AppControllers.employee.employeeEntity?.email ?? '',
                                      isMobile: isMobile,
                                      isLoadingServiceDetails: data.isLoadingServiceDetails,
                                      durationToDisplay: data.durationToDisplay,
                                    ),
                                    SizedBox(height: 20.h),
                                    if (approvalCycle.isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                S.of(context).approvalCycle,
                                                style: StyleText.fontSize14Weight400.copyWith(
                                                  color: lightMode ? AppColors.secondaryText : AppColors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          isMobile ? SizedBox() : SizedBox(height: 15.h),
                                          isMobile
                                              ? buildApprovalCycleMyRequest(context, false, [], displayCycle)
                                              : approvalCycleViewLogic(context, displayCycle),
                                        ],
                                      ),
                                    RequestReasonComments(
                                      cancelReason: data.cancelReason,
                                      rejectCommentText: data.rejectCommentText,
                                      approveCommentText: data.approveCommentText,
                                      isMobile: isMobile,
                                    ),
                                    SizedBox(height: 20.h),
                                    MyRequestStatusFooter(
                                      isMobile: isMobile,
                                      shouldShowReminder: shouldShowReminder,
                                      reminderServiceName: reminderServiceName,
                                      currentApproverEmail: currentApproverEmail,
                                      hasApprovalCycle: approvalCycle.isNotEmpty,
                                      hasRejectionOrCancel: widget.myRequestDetailsModel.currentState == "cancel" ||
                                          (approvalCycle.isNotEmpty && hasRejection),
                                      borderColor: borderColor,
                                      iconAsset: iconAsset,
                                      stateLabel: _getLocalizedLabel(context, docState),
                                    ),
                                  ],
                                ),
                              ),
                              MyRequestDateRibbon(
                                isMobile: isMobile,
                                requestedTimestamp: widget.myRequestDetailsModel.currentTimestamp,
                                showBreachedSlaRibbon: hasBreachedSlaAt3,
                              ),
                            ],
                          ),
                          SizedBox(height: 19.sp),
                        ],
                        UniversalCommentSection(
                          collectionPath: getBaseUrl(FirestoreCollections.commentsRoot),
                          filterFields: {
                            'Request_Id': widget.myRequestDetailsModel.currentId,
                          },
                          currentUserId: AppControllers.employee.employeeEntity!.email!,
                          isExpandable: true,
                          fixedHeight: MediaQuery.of(context).size.height,
                          onExpandChanged: (expanded) {
                            setState(() {
                              _isCommentExpanded = expanded;
                            });
                          },
                          style: CommentSectionStyle(
                            hintStyle: StyleText.fontSize16Weight400
                                .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
                            commentTextStyle:
                                StyleText.fontSize18Weight500.copyWith(color: AppColors.text),
                            fileChipDecoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            fileIconColor: AppColors.text,
                            fileNameStyle:
                                StyleText.fontSize12Weight400.copyWith(color: AppColors.text),
                            avatarColor: AppColors.background,
                            inputFillColor: AppColors.card,
                            containerDecoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            commentItemDecoration: BoxDecoration(
                                color: Colors.transparent, borderRadius: BorderRadius.circular(8.r)),
                            userNameStyle:
                                StyleText.fontSize16Weight400.copyWith(color: AppColors.text),
                            sendButtonDecoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            sendIconColor: AppColors.textButton,
                          ),
                        ),
                      if (!_isCommentExpanded) SizedBox(height: 19.sp),
                      ],
                    ),
                  ),
              ),
            ),
          ),
        );
      },
    );
  }
}
