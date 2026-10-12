part of './approvals_screen.dart';
/// Module: knowledge_hub / presentation / s6_approvals/approvals_screen.sections.dart

/// Fields + helper/builder methods for the screen, split out to keep
/// each file under 800 LOC (§7).
mixin _ApprovalsScreenSections on State<ApprovalsScreen> {
  int selectedIndex = 0;

  final TextEditingController searchApprovalsController = TextEditingController();

  bool _isInitialized = false;

  String? _currentSelectedDepartment;

  // ✅ ADDED: Animation Controllers
  late AnimationController _gridAnimationController;

  List<Animation<Offset>> _slideAnimations = [];

  List<Animation<double>> _fadeAnimations = [];

  bool _animationsCreated = false;

  // ✅ ADDED: CREATE HORIZONTAL STAGGERED ANIMATIONS
  void _createSlideAnimations(int itemCount) {
    _slideAnimations.clear();
    _fadeAnimations.clear();

    for (int i = 0; i < itemCount; i++) {
      // Stagger delay: 40ms between each item
      final delay = i * 0.04;

      // ✅ HORIZONTAL Slide animation from LEFT
      final slideAnimation = Tween<Offset>(
        begin: const Offset(-0.3, 0.0), // Horizontal from left
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay.clamp(0.0, 0.6),
            (delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );

      // Fade animation
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _gridAnimationController,
          curve: Interval(
            delay.clamp(0.0, 0.6),
            (delay + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ),
      );

      _slideAnimations.add(slideAnimation);
      _fadeAnimations.add(fadeAnimation);
    }

    _animationsCreated = true;
  }

  // ✅ ADDED: PLAY ANIMATION
  void _playGridAnimation() {
    if (_gridAnimationController.isAnimating) return;
    _gridAnimationController.forward(from: 0.0);
  }

  // At the top of your build method or as a helper method:
  String _getLocalizedName(CreateKnowledgeModel knowledge) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') {
      return knowledge.currentNameArabic.isNotEmpty
          ? knowledge.currentNameArabic
          : knowledge.currentNameEnglish;
    }
    return knowledge.currentNameEnglish;
  }

  void _debugEmployeeData(EmployeeData? employee) {
    if (employee == null) {
      return;
    }

  }

  String _getLocalizedDescription(CreateKnowledgeModel knowledge) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') {
      return knowledge.currentDescriptionArabic.isNotEmpty
          ? knowledge.currentDescriptionArabic
          : knowledge.currentDescriptionArabic;
    }
    return knowledge.currentDescriptionEnglish;
  }

// In approvals_screen.dart

// CHANGE THIS METHOD:
  Future<void> _initializeApprovals() async {
    if (_isInitialized) return;

    try {
      final employeeController = Get.find<MainCoreEmployeeController>();

      final employee = employeeController.employeeEntity;

      if (employee != null && employee.email != null && employee.email!.isNotEmpty) {
        final userEmail = employee.email!;

        final cubit = context.read<ApprovalsCubit>();
        cubit.setCurrentUserEmail(userEmail);

        await Future.delayed(Duration(milliseconds: 100));

        await cubit.fetchAllSubmissions();

        // ✅ CHANGED: Default filter to "All" instead of "Pending"
        await cubit.filterByStatusKey('all', 0);

        _isInitialized = true;
      } else {

        final fallbackEmail = "ahmed_sami_1901@bayanatz.com";

        final cubit = context.read<ApprovalsCubit>();
        cubit.setCurrentUserEmail(fallbackEmail);
        await Future.delayed(Duration(milliseconds: 100));
        await cubit.fetchAllSubmissions();

        // ✅ CHANGED: Default filter to "All" instead of "Pending"
        await cubit.filterByStatusKey('all', 0);

        _isInitialized = true;
      }
    } catch (e) {

      try {
        final cubit = context.read<ApprovalsCubit>();
        cubit.setCurrentUserEmail("ahmed_sami_1901@bayanatz.com");
        await cubit.fetchAllSubmissions();

        // ✅ CHANGED: Default filter to "All" instead of "Pending"
        await cubit.filterByStatusKey('all', 0);

        _isInitialized = true;
      } catch (e2) {
      }
    }
  }

  void _retryInitialization() {
    _initializeApprovals();
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(child: CircleProgressMaster()),
    );
  }

  // ✅ UPDATED: buildApprovalsGrid with Animation
  Widget buildApprovalsGrid(BuildContext conGrtext, bool isMobile) {
    final cubit = context.read<ApprovalsCubit>();
    final approvals = cubit.filteredKnowledge;

    if (approvals.isEmpty) {
      return buildNoFilterResultsState(context);
    }

    // Pre-fetch department names and user data for all submissions
    cubit.fetchDepartmentsForKnowledge(approvals);
    _prefetchUsersForApprovals(cubit, approvals);

    // ✅ CREATE ANIMATIONS IF NOT CREATED
    if (!_animationsCreated || _slideAnimations.length != approvals.length) {
      _createSlideAnimations(approvals.length);
      // Play animation after creation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playGridAnimation();
      });
    }

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        mainAxisExtent: 257.sp,
        crossAxisSpacing: 15.sp,
        mainAxisSpacing: 15.sp,
      ),
      shrinkWrap: true,
      itemCount: approvals.length,
      itemBuilder: (context, index) {
        final approval = approvals[index];

        // ✅ WRAP WITH ANIMATED TRANSITIONS
        return SlideTransition(
          position: _slideAnimations.length > index
              ? _slideAnimations[index]
              : AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity: _fadeAnimations.length > index
                ? _fadeAnimations[index]
                : AlwaysStoppedAnimation(1.0),
            child: buildDocumentCard(context, approval, cubit),
          ),
        );
      },
    );
  }

  /// ✅ Prefetch user data for all creators in the list
  Future<void> _prefetchUsersForApprovals(
      ApprovalsCubit cubit,
      List<CreateKnowledgeModel> approvals,
      ) async {
    // Extract unique creator emails
    final creatorEmails = approvals
        .map((k) => k.currentCreatedByEmail)
        .where((email) => email.isNotEmpty)
        .toSet()
        .toList();

    // Fetch user data for each email (will use cache if already fetched)
    for (final email in creatorEmails) {
      cubit.getUserDataByEmail(email);
    }
  }

  String _getLocalizedEmployeeNameExplicit(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = Get.find<MainCoreEmployeeController>();
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale != 'ar';

    String name = employeeController.getEmployeeNameEnglishArabic(
      employee.currentemployeeEmail,
      isEnglish,
    );

    return name.isNotEmpty ? name : employee.currentemployeeName;
  }

  String _getLocalizedDepartmentName(String departmentName) {
    final departmentController = Get.find<MainCoreDepartmentCubit>();

    String? departmentId = departmentController.getDepartmentIdFromDepartmentName(
      departmentName: departmentName.toLowerCase(),
    );

    if (departmentId != null && departmentId != 'none') {
      String localizedName = departmentController.getDepartmentName(departmentId, null);
      return localizedName;
    }

    return departmentName;
  }

  String _getLocalizedJobTitle(EmployeeData? employee) {
    if (employee == null) return '-';

    final employeeController = Get.find<MainCoreEmployeeController>();

    String jobTitle = employeeController.getEmployeeJobTitle(employee.currentemployeeEmail);

    return jobTitle == "no job" ? employee.currentemployeeRole : jobTitle;
  }

  Widget buildDocumentCard(
      BuildContext context,
      CreateKnowledgeModel approvals,
      ApprovalsCubit cubit,
      ) {
    final isMobile = ResponsivePage.isMobile(context);
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final locale = Localizations.localeOf(context).languageCode;

    return GestureDetector(
      onTap: () async {
        final localizedName = _getLocalizedName(approvals);
        final localizedDesc = _getLocalizedDescription(approvals);

        final data = await _fetchCardData(cubit, approvals);
        final departmentName = data['departmentName'] as String? ?? 'Unknown Department';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<ApprovalsCubit>(),
              child: ApprovalsDetailsScreen(
                documentName: localizedName,
                knowledgeId: approvals.currentKnowledgeId,
                fileName: approvals.currentDocumentFileName,
                fileType: approvals.currentKnowledgeDocumentType,
                fileUrl: approvals.currentDocumentUrl,
                department: approvals.currentOwningDepartment,
                documentDesc: localizedDesc,
                createdByEmail: approvals.currentCreatedByEmail,
                createdTimestamp: approvals.currentTimestamp,
                status: approvals.currentStatus,
                fileExtension: approvals.currentDocumentExtension,
                // ✅ ADDED: Pass start/end date and time
                startDate: approvals.currentStartDateTime,
                endDate: approvals.currentEndDateTime,
                startTime: approvals.currentStartTime,
                endTime: approvals.currentEndTime,
              ),
            ),
          ),
        );
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCardData(cubit, approvals),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard(context);
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorCard(context, approvals);
          }

          final data = snapshot.data!;
          final departmentName = data['departmentName'] as String? ?? 'Unknown Department';
          final creatorData = data['creatorData'] as EmployeeData?;

          _debugEmployeeData(creatorData);

          return approvalsDocumentCard(
            context,
            status: approvals.currentStatus,
            statusColor: _getStatusColor(approvals.currentStatus),
            fileExtension: approvals.currentDocumentExtension,
            fileImage: approvals.currentImageUrl.isNotEmpty
                ? approvals.currentImageUrl
                : null,
            fileName: FormatHelper.capitalize(_getLocalizedName(approvals)),
            department: _getLocalizedDepartmentName(departmentName),
            requestedBy: FormatHelper.capitalize(_getLocalizedEmployeeNameExplicit(creatorData)),
            jobTitle: _getLocalizedJobTitle(creatorData),
            uploadDate: _getTimestampDate(approvals.currentTimestamp),
            lastEditDate: _getTimestampDate(approvals.currentTimestamp),
            onApprove: () {
              _showApproveConfirmationDialog(
                context,
                approvals.currentKnowledgeId,
                isMobile,
                lightMode,
              );
            },
            onReject: () {
              _showRejectConfirmationDialog(
                context,
                approvals.currentKnowledgeId,
                isMobile,
                lightMode,
              );
            },
          );
        },
      ),
    );
  }

  /// Show approval confirmation dialog
  void _showApproveConfirmationDialog(
      BuildContext context,
      String knowledgeId,
      bool isMobile,
      bool lightMode,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: lightMode
                  ? AppColors.white
                  : AppColors.background,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                  height: 70.h,
                  width: 70.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context)!.approveRequest,
                  style: StyleText.fontSize20Weight500,
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context)!.areYouSureYouWantToApproveRequest,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: customButton(
                        title: S.of(context).no,
                        height: 38.h,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                            color:  lightMode ? AppColors.colorBlack:AppColors.colorWhite
                        ),
                        width: 135.w,
                        color: lightMode ? AppColors.colorGrey : AppColors.colorGreyDark,
                        function: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 45.w),
                    Expanded(
                      child: customButton(
                        height: 38.h,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton),
                        width: 135.w,
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(ctx);
                          showDialog(
                            barrierDismissible: true,
                            builder: (dialogContext) => BlocProvider.value(
                              value: context.read<ApprovalsCubit>(),
                              child: ReasonForJustificationsDialog(
                                knowledgeId: knowledgeId,
                              ),
                            ), context: ctx,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Show rejection confirmation dialog
  void _showRejectConfirmationDialog(
      BuildContext context,
      String knowledgeId,
      bool isMobile,
      bool lightMode,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Material(
          color: AppColors.transparent,
          child: Container(
            width: isMobile ? double.infinity : 411.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: lightMode
                  ? AppColors.white
                  : AppColors.background,
            ),
            padding: EdgeInsets.all(20.r),
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_assets/main_lottie_assets/lottie_rejected.json',
                  height: 70.h,
                  width: 70.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  S.of(context)!.rejectRequest,
                  style: StyleText.fontSize20Weight500,
                ),
                SizedBox(height: 18.h),
                Text(
                  S.of(context)!.areYouSureYouWantToRejectRequest,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: customButton(
                        title: S.of(context).no,
                        height: 38.h,
                        width: 135.w,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                            color:lightMode ? AppColors.colorBlack:AppColors.colorWhite),
                        color: lightMode ? AppColors.colorGrey : AppColors.colorGreyDark,
                        function: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 45.w),
                    Expanded(
                      child: customButton(
                        height: 38.h,
                        width: 135.w,
                        textStyle: StyleText.fontSize16Weight500.copyWith(
                            color: AppColors.textButton),
                        title: S.of(context).yes,
                        function: () {
                          Navigator.pop(ctx);
                          showDialog(
                            barrierDismissible: true,
                            builder: (dialogContext) => BlocProvider.value(
                              value: context.read<ApprovalsCubit>(),
                              child: ResonForApprovalRemovingDialog(
                                knowledgeId: knowledgeId,
                              ),
                            ), context: ctx,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fetch all necessary data for the card
  Future<Map<String, dynamic>> _fetchCardData(
      ApprovalsCubit cubit,
      CreateKnowledgeModel approvals,
      ) async {
    final Map<String, dynamic> result = {};

    try {
      log('🏢 Fetching department: ${approvals.currentOwningDepartment}');
      final departmentName = await cubit.getDepartmentName(
        approvals.currentOwningDepartment,
      );
      result['departmentName'] = departmentName;
      log('✅ Department fetched: $departmentName');

      final creatorEmail = approvals.currentCreatedByEmail;
      if (creatorEmail.isNotEmpty) {
        log('👤 Fetching user by email: $creatorEmail');
        final creatorData = await cubit.getUserDataByEmail(creatorEmail);
        result['creatorData'] = creatorData;

        if (creatorData != null) {
          log('✅ User fetched: ${creatorData.currentemployeeName}');
          log('   Job Title: ${creatorData.currentemployeeRole}');
          log('   Department ID: ${creatorData.currentemployeeDepartment}');
        } else {
          log('⚠️ User not found for email: $creatorEmail');
        }
      } else {
        log('⚠️ Empty creator email in knowledge document');
      }
    } catch (e, stack) {
      log('❌ Error in _fetchCardData: $e');
      log('🧱 Stack: $stack');
    }

    return result;
  }

  Widget _buildLoadingCard(BuildContext context) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    return Container(
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: lightMode ? AppColors.white : AppColors.background,
      ),
      padding: EdgeInsets.all(10.w),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build error state for card - shows submission data as fallback
  Widget _buildErrorCard(BuildContext context, CreateKnowledgeModel submission) {
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Container(
      width: ScreenUtil().screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: lightMode ? AppColors.white : AppColors.background,
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  submission.currentNameEnglish,
                  style: StyleText.fontSize14Weight500.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Error loading some details',
            style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.orange,
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _getTimestampDate(int? timestamp) {
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Helper function to get display name for status
  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return 'Published';
      case 'pending_approval':
        return 'Pending';
      case 'scheduled':
        return 'Scheduled';
      case 'rejected':
        return 'Rejected';
      case 'removed':
        return 'Removed';
      case 'archived':
        return 'Archive';
      default:
        return status;
    }
  }

  /// Helper function to get color for status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'published':
        return AppColors.green;
      case 'pending_approval':
        return AppColors.orange;
      case 'scheduled':
        return AppColors.blue;
      case 'rejected':
        return AppColors.red;
      case 'removed':
        return AppColors.colorGrey;
      case 'archived':
        return AppColors.secondaryText;
      default:
        return AppColors.black;
    }
  }

  // ✅ Error State Widget
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 50, color: AppColors.red),
            SizedBox(height: 10),
            Text(
              'Error Loading Approvals',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.colorGrey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeApprovals,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

// ✅ Empty State Widget — centered on screen
  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Lottie.asset(
          'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
          width: 300.sp,
          height: 300.sp,
          fit: BoxFit.fill,
          repeat: true,
        ),
      ),
    );
  }

  Widget buildNoFilterResultsState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_empty.json'),
      ),
    );
  }

  // ✅ UPDATED: _handleIndexChanges method
  void _handleIndexChanges(BuildContext context, ApprovalsStates state) {
    if (state is ChangeIndexSuccessState) {
      setState(() {
        selectedIndex = state.index;
        _currentSelectedDepartment = null;
        _animationsCreated = false; // ✅ ADDED: Reset animations on filter change
      });
    }
  }

}
