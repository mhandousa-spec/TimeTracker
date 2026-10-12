/// Module: services_management_module
/// Description: Approval-details page — shows the full request (service
///              info, provider, approval cycle, comments) and lets the
///              current approver approve/reject. All Firestore I/O lives in
///              ApprovalRequestDetailsCubit; this file and its part files
///              (approval_request_details_logic_a/b, body_actions,
///              body_helpers) only read cubit state and dispatch actions.
/// Author: Amr Mesbah / Knowticed Team
/// Date: 2026-07-02
/// Dependencies: flutter_bloc, ApprovalRequestDetailsCubit, ServicesManagerCubit
/// Revision History: 02/02/2026 (Amr Mesbah) — CreateServicesHelper + MainCore
///                    integration, comment-section expand/collapse.
///                    2026-07-02 (Knowticed Team) — audit fix item 1: moved
///                    every try/catch + direct Firestore call into
///                    ApprovalRequestDetailsCubit; renamed the multi-dot part
///                    files to snake_case (audit fix item 5d).
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';

import 'dart:io';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/controller/approval_request_details_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/controller/approval_request_details_state.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_data_model.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_services.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/services_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/services/approval_permission_work.dart';
import 'package:knowticed_plus/core/helper/role/services_module_access.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';



import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/helper/csv_helper.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';

import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';


import 'package:knowticed_plus/features/services_management_module/s9_admin_dashboard/presentation/ui/pages/dashboard_details_admin.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/pages/select_services_provider_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/approvals.dart'
   ;
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/chat.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/provider_details.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/controller/create_services_helper.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/responsive_text.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/widgets/show_request_details_shimmer.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/widgets/approval_details_shared_widgets.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part 'approval_request_details_logic_a.dart';
part 'approval_request_details_logic_b.dart';
part 'approval_request_details_body_helpers.dart';
part 'approval_request_details_body_actions.dart';

class ApprovalDetailsScreen extends StatelessWidget {
  const ApprovalDetailsScreen({
    Key? key,
    required this.index,
    required this.approvalModel,
    this.fromTable = false,
    this.createServicesModel,
  }) : super(key: key);

  final ServicesHistoryModel approvalModel;
  final int index;
  final bool fromTable;
  final ServicesHistoryModel? createServicesModel;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApprovalRequestDetailsCubit(
        departmentCubit: context.read<MainCoreDepartmentCubit>(),
        repository: ServicesManagerCubit.get(context).repository,
        approvalModel: approvalModel,
      )..initialize(),
      child: _ApprovalDetailsScreenBody(
        index: index,
        approvalModel: approvalModel,
        fromTable: fromTable,
        createServicesModel: createServicesModel,
      ),
    );
  }
}

class _ApprovalDetailsScreenBody extends StatefulWidget {
  const _ApprovalDetailsScreenBody({
    required this.index,
    required this.approvalModel,
    this.fromTable = false,
    this.createServicesModel,
  });

  final ServicesHistoryModel approvalModel;
  final int index;
  final bool fromTable;
  final ServicesHistoryModel? createServicesModel;

  @override
  State<_ApprovalDetailsScreenBody> createState() => _ApprovalDetailsScreenState();
}

class _ApprovalDetailsScreenState extends State<_ApprovalDetailsScreenBody> {
  final TextEditingController rejectController = TextEditingController();
  final TextEditingController approveController = TextEditingController();
  late final MainCoreDepartmentCubit departmentController;
  late final MainCoreEmployeeController employeeController;
  final NotificationTemplateService _templateService = NotificationTemplateService();
  late ServicesHistoryModel _currentModel;

  // ✅ NEW: Track comment section expansion state
  bool isCommentSectionExpanded = false;

  // ✅ NEW: Service data from CreateServices
  String? serviceNameEnglish;
  String? serviceNameArabic;
  String? serviceDescriptionEnglish;
  String? serviceDescriptionArabic;
  String? serviceDuration;
  String? serviceDurationUnit;
  String? owningDepartment;


  final TextEditingController _controller = TextEditingController();
  bool isVisible = false;








  String saveIdUser = "";
  String stateLabel = 'Pending';
  String? cancelReason;



  String? currentState;
  bool isLoadingCommentReson = true;
  String rejectCommentText = '';
  String approveCommentText = '';

  @override
  void initState() {
    super.initState();
    this.loadRequesterData();
    _currentModel = widget.approvalModel;
    // Firestore-derived fields (comments, doc state, requester info, service
    // details) now come from ApprovalRequestDetailsCubit via
    // _applyCubitState(), wired below in didChangeDependencies. The cubit is
    // created (and initialize() kicked off) by the ApprovalDetailsScreen
    // BlocProvider above this widget.
    departmentController = context.read<MainCoreDepartmentCubit>();
    employeeController = AppControllers.employee;
    _refreshModelFromFirestore();
  }

  bool _cubitListenerAttached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_cubitListenerAttached) return;
    _cubitListenerAttached = true;

    final cubit = context.read<ApprovalRequestDetailsCubit>();
    _applyCubitState(cubit.state);
    cubit.stream.listen((s) {
      if (!mounted) return;
      _applyCubitState(s);
    });
  }

  void _applyCubitState(ApprovalRequestDetailsState s) {
    ApprovalRequestDetailsData? data;
    if (s is ApprovalRequestDetailsLoaded) data = s.data;
    if (s is ApprovalRequestDetailsSubmitting) data = s.data;
    if (s is ApprovalRequestDetailsActionError) data = s.data;

    setState(() {
      isLoadingCommentReson = s is ApprovalRequestDetailsLoading;
      if (data != null) {
        currentState = data.currentState;
        cancelReason = data.cancelReason;
        rejectCommentText = data.rejectCommentText;
        approveCommentText = data.approveCommentText;
        saveIdUser = data.saveIdUser;
        serviceNameEnglish = data.serviceNameEnglish;
        serviceNameArabic = data.serviceNameArabic;
        serviceDescriptionEnglish = data.serviceDescriptionEnglish;
        serviceDescriptionArabic = data.serviceDescriptionArabic;
        serviceDuration = data.serviceDuration;
        serviceDurationUnit = data.serviceDurationUnit;
        owningDepartment = data.owningDepartment;
        requesterFirstNameEn = data.requesterFirstNameEn;
        requesterLastNameEn = data.requesterLastNameEn;
        requesterJobTitleEn = data.requesterJobTitleEn;
        requesterDepartment = data.requesterDepartment;
        requesterFirstNameAr = data.requesterFirstNameAr;
        requesterLastNameAr = data.requesterLastNameAr;
        requesterJobTitleAr = data.requesterJobTitleAr;
      }
    });

    if (s is ApprovalRequestDetailsActionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.message), duration: const Duration(seconds: 2)),
      );
    }
  }

  // ✅ NEW: Load service data from CreateServices collection
  // Find this section in the _loadServiceDataFromCreateServices() method:




  String? globalEmailRequester;
  String? globalFirstNameRequester;
  String? globalLastNameRequester;
  String? globalGenderRequester;
  String? globalPhoneRequester;
  String? globalJobTitleRequester;
  String? globalDepartmentRequester;


  String? requesterFirstNameEn;
  String? requesterLastNameEn;
  String? requesterJobTitleEn;
  String? requesterDepartment;
  String? requesterFirstNameAr;
  String? requesterLastNameAr;
  String? requesterJobTitleAr;






  TextEditingController searchController = TextEditingController();
  String? selectedStatus;
  List<String> selectedDepartmentKeys = [];
  bool showFilter = false;
  String selectStatus = "All";
  List<ServicesHistoryModel> filteredModel = [];
  List<ServicesHistoryModel> unsortedCurrent = [];
  List<ServicesHistoryModel> visibleApprovals = [];



  var employeeEntity = AppControllers.employee.employeeEntity!;




  @override
  Widget build(BuildContext context) {
    var isTablet = ContextExtension(context).isTablet;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final isDocStateFinalized =
    (currentState?.toLowerCase().trim().isNotEmpty ?? false);

    final hasPendingInApprovalCycle =
    widget.approvalModel.currentApprovalCycle.any(
          (e) => e.state?.toLowerCase() == 'pending',
    );

    if (isLoadingCommentReson) {
      return Container(
        color: AppColors.background,
        child: Center(
          child: CircleProgressMaster(),
        ),
      );
    }

    final approvalCycle = widget.approvalModel.currentApprovalCycle;
    List<EmployeeEntityModell> displayCycle = _adjustCycleStates(approvalCycle);

    final docState = this.getOverallStatus();
    stateLabel = _getLabel(docState);
    Color borderColor = _getBorderColor(docState);
    String iconAsset = _getIconAsset(docState);

    final bool hasRejection = displayCycle.any(
          (e) =>
      e.state != null &&
          (e.state!.toLowerCase() == 'rejected' ||
              e.state!.toLowerCase() == 'cancel'),
    );

    if (docState == 'cancel') {
      stateLabel = _getLabel('cancel');
      borderColor = _getBorderColor('cancel');
      iconAsset = _getIconAsset('cancel');
    } else if (hasRejection) {
      final rejected = displayCycle.firstWhere(
            (e) =>
        e.state!.toLowerCase() == 'rejected' ||
            e.state!.toLowerCase() == 'cancel',
      );
      final s = rejected.state!.toLowerCase();
      stateLabel = _getLabel(s);
      borderColor = _getBorderColor(s);
      iconAsset = _getIconAsset(s);
    } else if (docState != 'inprogress' &&
        docState != 'done' &&
        docState != 'breached sla' &&
        displayCycle.every((e) => e.state?.toLowerCase() == 'approved')) {
      stateLabel = 'Approved';
      borderColor = AppColors.lightGreen;
      iconAsset = "assets/icons_assets/main_icons_assets/status_approved_check_green.svg";
    } else {
      final currentPending = displayCycle.indexWhere(
            (e) => e.state?.toLowerCase() == 'pending',
      );
      if (currentPending != -1) {
        stateLabel = 'Pending';
        borderColor = _getBorderColor('pending');
        iconAsset = _getIconAsset('pending');
      }
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final userEmail = employeeFunctionHelper.email?.toLowerCase();

    final myState = widget.approvalModel.currentApprovalCycle
        .firstWhere(
          (e) => e.email?.toLowerCase() == userEmail,
      orElse: () => EmployeeEntityModell(),
    )
        .state
        ?.toLowerCase();

    final isMobile = ContextExtension(context).isPhone;
    final isLandscape = ContextExtension(context).isLandscape;

    // ✅ Get display values (CreateServices data takes priority)
    final displayServiceNameEn = serviceNameEnglish ?? widget.approvalModel.currentServiceNameEnglish ?? '';
    final displayServiceNameAr = serviceNameArabic ?? widget.approvalModel.currentServiceNameArabic ?? '';
    final displayServiceDescEn = serviceDescriptionEnglish ?? widget.approvalModel.currentServiceDescriptionEnglish ?? '';
    final displayServiceDescAr = serviceDescriptionArabic ?? widget.approvalModel.currentServiceDescriptionArabic ?? '';

    final displayServiceName = isArabic ? displayServiceNameAr : displayServiceNameEn;
    final displayServiceDesc = isArabic ? displayServiceDescAr : displayServiceDescEn;

    // ✅ Get requester data from MainCore
    final requesterEmail = widget.approvalModel.currentEmailRequester ?? '';
    String requesterFullName = '-';
    String requesterJobTitle = '-';
    String requesterDepartmentName = '-';

    if (requesterEmail.isNotEmpty) {
      requesterFullName = employeeController.getEmployeeNameEnglishArabic(requesterEmail, !isArabic);

      final employee = employeeController.getLocaleEmployee(requesterEmail);
      if (employee != null) {
        requesterJobTitle = isArabic
            ? (employee.titleInArabic ?? employee.title ?? '-')
            : (employee.title ?? '-');

        if (employee.departmentId != null && employee.departmentId!.isNotEmpty) {
          requesterDepartmentName = isArabic
              ? (departmentController.getArabicDepartmentNameFromDepartmentId(departmentId: employee.departmentId!) ?? '-')
              : (departmentController.getEnglishDepartmentNameFromDepartmentId(departmentId: employee.departmentId!) ?? '-');
        }
      }
    }

    // ✅ Duration from CreateServices or fallback
    final displayDuration = serviceDuration ?? widget.approvalModel.currentDurationOfServices ?? '';
    final displayUnit = serviceDurationUnit ?? widget.approvalModel.currentSelectedDurationUnit ?? '';
    final localizedUnit = this.getLocalizedDurationUnit(displayUnit, isArabic, quantity: int.tryParse(displayDuration));
    final formattedDuration = '$displayDuration $localizedUnit';

    return SlideInContent(from: SlideFrom.bottom, child: Scaffold(
      body: SafeArea(
        child: SideFrameMasterServices(
          titleText: S.of(context).services,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: widget.fromTable
              ? FormatHelper.capitalize(displayServiceName)
              : S.of(context).approvals,
          onSecondTap: () {
            navigateTo(context, ApprovalToggle());
          },
          thirdTitle: widget.fromTable
              ? S.of(context).RequestedServicesDetails
              : FormatHelper.capitalize(displayServiceName),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                // ✅ CONDITIONAL: Show this section ONLY when comment section is NOT expanded
                if (!isCommentSectionExpanded) ...[
                  Row(
                    children: [
                      SizedBox(width: 3.sp),
                      Text(
                        S.of(context).approval_request_details,
                        style: StyleText.fontSize16Weight600
                            .copyWith(color: AppColors.text),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.sp),

                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            color: AppColors.card),
                        child: Column(
                          children: [
                            // First section photo & details
                            _buildServiceHeaderRow(
                              context,
                              isMobile: isMobile,
                              isArabic: isArabic,
                              displayServiceNameAr: displayServiceNameAr,
                              displayServiceNameEn: displayServiceNameEn,
                              displayServiceDesc: displayServiceDesc,
                            ),

                            SizedBox(height: 20.h),

                            isMobile ? this.descriptionWidget(displayServiceDesc) : SizedBox(),
                            isMobile ? SizedBox(height: 20.sp) : SizedBox(),

                            // Provider Section
                            _buildProviderSection(context),

                            SizedBox(height: 29.sp),

                            // Requester Details title
                            Row(
                              children: [
                                Text(
                                  S.of(context).RequesterDetails,
                                  style: StyleText.fontSize16Weight500.copyWith(
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10.sp),

                            // Requester services info
                            this.buildRequesterDetailsSection(
                              context,
                              firstName: requesterFullName.split(' ').first,
                              lastName: requesterFullName.split(' ').skip(1).join(' '),
                              jobTitle: requesterJobTitle,
                              department: requesterDepartmentName,
                            ),

                            SizedBox(height: 20.h),

                            // Approval Cycle Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "${S.of(context).approvalCycle}: ",
                                  style: StyleText.fontSize14Weight400.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),

                            isMobile ? SizedBox() : SizedBox(height: 15.h),

                            // Approval Cycle item
                            widget.approvalModel.currentApprovalCycle.isEmpty
                                ? SizedBox()
                                : isMobile
                                ? buildApprovalCycleMyRequest(
                              context,
                              false,
                              [],
                              _adjustCycleStates(widget
                                  .approvalModel.currentApprovalCycle),
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                approvalCycleViewLogic(
                                  context,
                                  _adjustCycleStates(widget
                                      .approvalModel.currentApprovalCycle),
                                ),
                              ],
                            ),

                            ..._buildCommentReasons(context),

                            SizedBox(height: 20.h),

                            _buildApprovalActions(context, myState, displayServiceName),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${S.of(context).requestDate}: ",
                              style: isMobile
                                  ? StyleText.fontSize10Weight400.copyWith(
                                color: AppColors.secondaryText,
                              )
                                  : StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(
                                DateTime.now(),
                              ),
                              style: isMobile
                                  ? StyleText.fontSize10Weight400.copyWith(
                                color: AppColors.text,
                              )
                                  : StyleText.fontSize12Weight400.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 20.sp),
                ],

                // ✅ COMMENT SECTION - Always visible
                UniversalCommentSection(
                  isExpandable: true,
                  collectionPath: getBaseUrl(FirestoreCollections.commentsRoot),
                  filterFields: {
                    'Request_Id': widget.approvalModel.currentId,
                  },
                  currentUserId: AppControllers.employee
                      .employeeEntity!
                      .email!,
                  fixedHeight: isCommentSectionExpanded ? null : 400.h,
                  onExpandChanged: (bool expanded) {
                    // ✅ Update state when expansion changes
                    setState(() {
                      isCommentSectionExpanded = expanded;
                    });
                  },
                  style: CommentSectionStyle(
                    hintStyle: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.secondaryText.withOpacity(.5)),
                    commentTextStyle: StyleText.fontSize18Weight500
                        .copyWith(color: AppColors.text),
                    fileChipDecoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    fileIconColor: AppColors.text,
                    fileNameStyle: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.text),
                    avatarColor: AppColors.background,
                    inputFillColor: AppColors.card,
                    containerDecoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    commentItemDecoration: BoxDecoration(
                        color: AppColors.transparent,
                        borderRadius: BorderRadius.circular(8.r)),
                    userNameStyle: StyleText.fontSize16Weight400.copyWith(
                      color: AppColors.text,
                    ),
                    sendButtonDecoration: BoxDecoration(
                      color: AppColors.secondaryPrimary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    sendIconColor: AppColors.secondaryPrimaryText,
                  ),
                ),

                SizedBox(height: 20.sp),
              ],
            ),
          ),
        ),
      ),
    ));
  }




}
