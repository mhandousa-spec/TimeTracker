// ******************* FILE INFO *******************
// File Name: details_switch_screen.dart
// Description: Main screen for selecting approval and limit availability
// Created by: Amr Mesbah
// Last Update: 01/12/2025
/// Updated: Migrated from ServicesManagerCubit to MainCoreEmployeeController
/// FIX: Employee grid now always shows when approval cycle is enabled
/// FIX: Search now works via onSearchChanged callback

import 'package:knowticed_plus/core/constants/role_keywords.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/details_switch_cubit.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/controller/details_switch_state.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/button.dart';
import 'package:knowticed_plus/features/services_management_module/s2_create_single_services/presentation/ui/widgets/details_switch_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/utils/shared.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';

import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:knowticed_plus/features/services_management_module/main_controller/data/data_source/local_data_source/shared_preference.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class DetailsSwitchScreenTablet extends StatefulWidget {
  const DetailsSwitchScreenTablet({super.key, this.editingModel, this.docId});

  final ServicesHistoryModel? editingModel;
  final String? docId;

  @override
  State<DetailsSwitchScreenTablet> createState() =>
      _DetailsSwitchScreenTabletState();
}

class _DetailsSwitchScreenTabletState extends State<DetailsSwitchScreenTablet> {
  late final DetailsSwitchCubit _cubit;
  late final MainCoreDepartmentCubit departmentController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    departmentController = context.read<MainCoreDepartmentCubit>();

    _cubit = DetailsSwitchCubit(
      editingModel: widget.editingModel,
      docId: widget.docId,
    );

    // Keep the listener as a fallback (e.g. programmatic controller changes)
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.loadInitialData();
      _cubit.loadEmployees();
    });
  }

  void _onSearchChanged() {
    _cubit.updateSearch(_searchController.text);
  }

  String _determineScreenTitle(bool isEnglish) {
    if (widget.editingModel == null && widget.docId == null) {
      return S.of(context).creatingNewService;
    }

    if (widget.editingModel != null) {
      final isDraft = widget.editingModel!.currentState == "draft" ||
          widget.editingModel!.currentDurationOfServices == "-" ||
          widget.editingModel!.currentDurationOfServices.isEmpty;

      final serviceName = Localizations.localeOf(context).languageCode == 'ar'
          ? widget.editingModel!.currentServiceNameArabic
          : widget.editingModel!.currentServiceNameEnglish;

      if (isDraft) {
        return "${S.of(context).draft} $serviceName";
      } else {
        return "${S.of(context).Editing} $serviceName";
      }
    }

    if (widget.docId != null) {
      return S.of(context).creatingNewService;
    }

    return S.of(context).creatingNewService;
  }

  String _displayName(EmployeeEntityPro e, bool isEnglish) {
    final fnEn = (e.firstName ?? '').trim();
    final lnEn = (e.lastName ?? '').trim();
    final fnAr = (e.firstNameInArabic ?? '').trim();
    final lnAr = (e.lastNameInArabic ?? '').trim();

    if (isEnglish) {
      final en = [fnEn, lnEn].where((s) => s.isNotEmpty).join(' ');
      if (en.isNotEmpty) return FormatHelper.capitalize(en);
      final arFallback = [fnAr, lnAr].where((s) => s.isNotEmpty).join(' ');
      if (arFallback.isNotEmpty) return FormatHelper.capitalize(arFallback);
    } else {
      final ar = [fnAr, lnAr].where((s) => s.isNotEmpty).join(' ');
      if (ar.isNotEmpty) return FormatHelper.capitalize(ar);
      final enFallback = [fnEn, lnEn].where((s) => s.isNotEmpty).join(' ');
      if (enFallback.isNotEmpty) return FormatHelper.capitalize(enFallback);
    }
    return (e.email ?? '').trim();
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  Future<void> _handleDraftSave(ServicesHistoryModel model) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ConfirmationDialog(
        lottiePath: "assets/lottie_assets/main_lottie_assets/lottie_Edit Document.json",
        title: S.of(context).saveForLater,
        message: S.of(context).areYouSureYouWantToSaveAsDraft,
        noText: S.of(context).no,
        yesText: S.of(context).yes,
        onConfirm: () async {
          // 013: no try/catch in a page widget (§11.2) — the draft service
          // propagates errors instead of the UI swallowing them.
          final isExistingDraft =
              widget.editingModel?.currentId?.startsWith('draft_') == true;

          if (isExistingDraft) {
            final updatedDraft = widget.editingModel!.copyWith(
              id: widget.editingModel!.currentId,
              providerServices: model.currentProviderServices,
              approvalCycle: model.currentApprovalCycle,
              selectDepartment: model.currentSelectDepartment,
              limitAvailability: model.currentLimitAvailability,
              requireApproval: model.currentRequireApproval,
            );
            await SharedPrefsService.updateDraft(
                widget.editingModel!, updatedDraft);
          } else {
            await SharedPrefsService.saveDraft(model);
          }

          if (!mounted) return;

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext dialogContext) {
              return SuccessDialog(
                title: S.of(context).draftService,
                message: S.of(context).successfullyDraftedService,
                onDismiss: () {
                  if (!_cubit.model.navigated) {
                    _cubit.setNavigated(true);
                    Navigator.of(dialogContext).pop();
                    navigateTo(context, ServicesScreenTablet());
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditingSubmittedService = widget.editingModel != null &&
        widget.editingModel!.currentState != "submitted";

    final isDraft = widget.editingModel != null &&
        (widget.editingModel!.currentState == "draft" ||
            widget.editingModel!.currentDurationOfServices == "-" ||
            widget.editingModel!.currentDurationOfServices.isEmpty);

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    final isMobile = ContextExtension(context).isPhone;

    final en = departmentController.departmentsEnglishName;
    final ar = departmentController.departmentsArabicName;

    return SlideInContent(from: SlideFrom.bottom, child: BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<DetailsSwitchCubit, DetailsSwitchState>(
        listener: (context, state) {
          if (state is DetailsSwitchValidationError) {
            showDialog(
              context: context,
              builder: (_) => ValidationDialog(
                title: S.of(context).validationError,
                message: state.message == 'mustSelectDepartment'
                    ? S.of(context).mustSelectDepartment
                    : S.of(context).mustSelectApprovalEmployees,
                lottiePath: state.lottiePath,
              ),
            );
          }
        },
        builder: (context, state) {
          final model = _cubit.model;

          if (state is DetailsSwitchLoading ||
              model.isLoading ||
              model.allEmployees.isEmpty) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: SideFrameMasterServices(
                titleText: S.of(context).services,
                onFirstTap: () {
                  navigateTo(context, LayoutScreenServices());
                },
                secondTitle: _determineScreenTitle(isEnglish),
                child: Center(
                  child: CircleProgressMaster(),
                ),
              ),
            );
          }

          final selectedForUI = isEnglish
              ? model.selectedDepartments
              : model.selectedDepartments.map((nameEn) {
            final i = en.indexOf(nameEn);
            return i >= 0 ? ar[i] : nameEn;
          }).toList();

          final departmentsForUI = isEnglish ? en : ar;

          return GetBuilder<MainCoreEmployeeController>(
            id: 'employee_data',
            builder: (employeeCtrl) {
              _cubit.updateEmployeesFromController(
                  employeeCtrl.allEmployeesEntities);

              return Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(
                  child: SideFrameMasterServices(
                    titleText: S.of(context).service,
                    onFirstTap: () {
                      navigateTo(context, LayoutScreenServices());
                    },
                    secondTitle: _determineScreenTitle(isEnglish),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.sp,
                                vertical: 15.sp,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        // ✅ FIX (bug report p28): this step shows the
                                        // service's availability/approval switches and
                                        // is labelled "Service Details" in the design;
                                        // it read "Services Control And Cycle".
                                        S.of(context).serviceDetails,
                                        style: StyleText.fontSize18Weight500.copyWith(
                                          color: AppColors.text
                                        )
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15.sp),
                                  LimitAvailabilitySection(
                                    limitAvailability: model.limitAvailability,
                                    isArabic: isArabic,
                                    onToggle: (val) =>
                                        _cubit.toggleLimitAvailability(val),
                                    selectedDepartments: selectedForUI,
                                    departments: departmentsForUI,
                                    width: isMobile
                                        ? 320.sp
                                        : (!isTabletLandscape(context)
                                        ? 300.sp
                                        : 410.sp),
                                    onAdd: (val) => _cubit.addDepartment(
                                        val, isEnglish, en, ar),
                                    onRemove: (val) => _cubit.removeDepartment(
                                        val, isEnglish, en, ar),
                                  ),
                                  SizedBox(height: 26.sp),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: RequireApprovalSection(
                                          requireApproval: model.requireApproval,
                                          isArabic: isArabic,
                                          onToggle: (val) {
                                            _cubit.toggleRequireApproval(val);
                                            if (!val) {
                                              _searchController.clear();
                                            }
                                          },
                                        ),
                                      ),
                                      isMobile
                                          ? SizedBox()
                                          : Expanded(flex: 2, child: Column()),
                                    ],
                                  ),
                                  if (model.requireApproval)
                                    ApprovalSelectionSection(
                                      searchController: _searchController,
                                      filteredEmployees: model.filteredEmployees,
                                      selectedEmployees: model.selectedEmployees,
                                      isRegularEmployee: (e) =>
                                      _cubit.model.allEmployees.isEmpty
                                          ? false
                                          : _isRegularEmployee(e),
                                      isSelected: (e) => _cubit.isSelected(e),
                                      onToggleSelection: (e) =>
                                          _cubit.toggleEmployeeSelection(e),
                                      displayName: _displayName,
                                      isEnglish: isEnglish,
                                      isMobile: isMobile,
                                      scrollController: _scrollController,
                                      onRemoveEmployee: (index) =>
                                          _cubit.removeEmployeeAt(index),
                                      onRemoveEmployeeFromSelection: () {
                                        if (model.selectedEmployees.isNotEmpty) {
                                          _cubit.toggleEmployeeSelection(
                                              model.selectedEmployees.last);
                                        }
                                      },
                                      // ✅ FIX: pass search callback so the widget
                                      // can trigger cubit without needing _cubit ref
                                      onSearchChanged: (value) =>
                                          _cubit.updateSearch(value),
                                      // ✅ NEW (bug report p29): department
                                      // dropdown filter for the approver grid.
                                      departmentIds: _cubit.approverDepartmentIds,
                                      selectedDepartmentId:
                                          _cubit.departmentFilterId,
                                      departmentName: (id) => (isEnglish
                                              ? departmentController
                                                  .getEnglishDepartmentNameFromDepartmentId(
                                                      departmentId: id)
                                              : departmentController
                                                  .getArabicDepartmentNameFromDepartmentId(
                                                      departmentId: id)) ??
                                          id,
                                      onDepartmentChanged: (id) =>
                                          _cubit.updateDepartmentFilter(id),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          buttonFotter(
                            context: context,
                            isDraft: isDraft,
                            isEditingSubmittedService: isEditingSubmittedService,
                            selectedDepartments: model.selectedDepartments,
                            selectedEmployees: model.selectedEmployees,
                            requireApproval: model.requireApproval,
                            limitAvailability: model.limitAvailability,
                            editingModel: widget.editingModel,
                            docId: widget.docId,
                            navigated: model.navigated,
                            onValidation: () => _cubit.validateForm(),
                            onNavigateBack: () => Navigator.pop(context),
                            onDraftSaved: _handleDraftSave,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ));
  }

  bool _isRegularEmployee(EmployeeEntityPro employee) {
    final roleLower = (employee.role ?? '').toLowerCase().trim();
    final titleLower = (employee.title ?? '').toLowerCase().trim();
    final titleArLower = (employee.titleInArabic ?? '').toLowerCase().trim();

    final leadershipKeywords = RoleKeywords.leadership;

    bool hasLeadershipRole = leadershipKeywords.any((keyword) =>
    roleLower.contains(keyword) ||
        titleLower.contains(keyword) ||
        titleArLower.contains(keyword));

    if (hasLeadershipRole) return false;

    final englishEmployeeKeywords = RoleKeywords.englishEmployee;

    final arabicEmployeeKeywords = RoleKeywords.arabicEmployee;

    bool hasEnglishEmployeeKeyword = englishEmployeeKeywords.any(
            (keyword) => roleLower.contains(keyword) || titleLower.contains(keyword));

    bool hasArabicEmployeeKeyword = arabicEmployeeKeywords.any((keyword) =>
    roleLower.contains(keyword) ||
        titleLower.contains(keyword) ||
        titleArLower.contains(keyword));

    return hasEnglishEmployeeKeyword || hasArabicEmployeeKeyword;
  }
}
