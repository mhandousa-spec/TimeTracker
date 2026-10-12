/// Module: knowledge_hub / presentation / s2_view_knowledge_hub / view_knowledge_hub.dart
/// ************************* FILE INFO *************************** ///
/// File Name: view_knowledge_hub.dart
/// Purpose: Contains different sizes of displaying data of app.
/// Author: Youssef Khaled
/// Created At: 11/10/2025

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/preview.dart';
import 'package:knowticed_plus/core/custom/87-responsive_card_grid.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/knowledge/knowledge_hubssections_enum.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/department_model.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import '../../../../main_controller/helper/cross_axis_count_helper.dart';
import '../../../../main_controller/data/services/knowledge_hub_firebase_services.dart';
import '../../../../main_controller/helper/responsive_helper.dart';
// MIGRATED 12/9/2026 — the module's own copy of the frame
// (main_controller/.../core_widgets/responsive_side_frame.dart) is replaced by the
// app-wide one every other module already wears. Same constructor, so this is a
// name swap; on phones the title row is now FIXED above the scrolling content
// instead of scrolling away with it.
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/cons.dart';
import '../../../../k3_view_knowledge_details/presentation/controller/create_knowledge_state.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../k3_view_knowledge_details/presentation/ui/pages/view_knowledge_details.dart';
import '../../../../main_controller/presentation/ui/widgets/approvals_button.dart';
import '../../../../main_controller/presentation/ui/widgets/dashboard_button.dart';
import '../../../../main_controller/presentation/ui/widgets/departments_list_view.dart';
import '../../../../main_controller/presentation/ui/widgets/documents_view.dart';
import '../../../../main_controller/presentation/ui/widgets/file_card.dart';
import '../../../../main_controller/presentation/ui/widgets/submissions_button.dart';
import '../widgets/build_search_section.dart';
import '../widgets/departments_list.dart';
import '../widgets/inner_list_view.dart';
import 'dart:ui' as ui;
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

part './view_knowledge_hub.sections.dart';

class ViewKnowledgeHub extends StatefulWidget {
  const ViewKnowledgeHub({super.key});

  @override
  State<ViewKnowledgeHub> createState() => _ViewKnowledgeHubState();
}

class _ViewKnowledgeHubState extends State<ViewKnowledgeHub>
    with TickerProviderStateMixin, _ViewKnowledgeHubSections {
  @override
  void initState() {
    super.initState();

    // ✅ Initialize animation controller - 1 SECOND DURATION
    _gridAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // ✅ Changed to 1 second
      vsync: this,
    );

    // Initialize employee controller first
    _initializeEmployeeController();

    // IMPORTANT: Delay data initialization to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();

      // Add debug check after a delay
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          _debugCubitState();
        }
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _gridAnimationController.dispose(); // ✅ DISPOSE CONTROLLER
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isMobile = ContextExtension(context).isPhone;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final controller = Get.find<MainCoreEmployeeController>();
    final departmentController = Get.find<MainCoreDepartmentCubit>();

    var isHasPermission = controller.isHasPermission(
      module: Modules.knowledgeHub,
      section: KnowledgeHubPermissionsSections.knowledgeHubPermissions,
      permission: null,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: _buildEmployeeDataWrapper(
          child:
          SideFrameMasterServices(
        
            titleText: S.of(context).knowledge_hub,
        
            child: BlocListener<CreateKnowledgeCubit, CreateKnowledgeState>(
              listener: _handleStateChanges,
              child: SingleChildScrollView(
             //   physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (controller.isHasPermission(
                          module: Modules.knowledgeHub,
                          section: KnowledgeHubPermissionsSections.approval,
                          permission: null,
                        ))
                          approvalsButton(context),
                        if (controller.isHasPermission(
                          module: Modules.knowledgeHub,
                          section: KnowledgeHubPermissionsSections.dashboard,
                          permission: null,
                        ))
                          dashboardButton(context),
                          // ElevatedButton(onPressed: (){
                          //
                          //   navigateTo(context, PreviewAllCustomPage());
                          // }, child: Text('test')),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    if (controller.isHasPermission(
                      module: Modules.knowledgeHub,
                      section: KnowledgeHubPermissionsSections.submissions,
                      permission: null,
                    ))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [submissionsButton(context)],
                      ),
                    SizedBox(height: 20.h),
                    isHasPermission == false
                        ? Container(
                      width: 400,
                      height: 400,
                      child: Center(
                        child: Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_noData.json',
                            width: 400.w,
                            height: 400.h,
                            fit: BoxFit.fill,
                            repeat: true),
                      ),
                    )
                        : Column(
                      children: [
                        _buildDepartmentsWithCache(),
                        SizedBox(height: 20.h),
                        BlocBuilder<CreateKnowledgeCubit,
                            CreateKnowledgeState>(
                          builder: (context, state) {
                            final departments =
                            state is FetchingDepartmentSuccessState
                                ? state.departmentList
                                : _cachedDepartments;
        
                            try {
                              return Row(
                                children: [
                                  AppSearchTextField(
                                    controller: searchController,
                                    onChanged: (query) {
                                      context
                                          .read<CreateKnowledgeCubit>()
                                          .searchKnowledge(query);
                                    },
                                    fillColor: lightMode
                                        ? AppColors.white
                                        : AppColors.chatBackground,
                                  ),
                                  SizedBox(width: 10.w),
                                  FilterSection(
                                    context,
                                    searchController: searchController,
                                    departments: departments,
                                  ),
                                ],
                              );
                            } catch (e, stackTrace) {
                              log('Error in search section',
                                  name: 'BUILD',
                                  error: e,
                                  stackTrace: stackTrace);
                              rethrow;
                            }
                          },
                        ),
                        SizedBox(height: 10.h),
                        Builder(builder: (context) {
                          return innerListView(
                            context,
                            isMobile: isMobile,
                            isLightMode: isLightMode,
                            innerIndex: innerIndex,
                          );
                        }),
                         SizedBox(height: 10.sp),
        
                        // ✅ ANIMATED KNOWLEDGE ITEMS GRID
                        BlocBuilder<CreateKnowledgeCubit,
                            CreateKnowledgeState>(
                          buildWhen: (previous, current) =>
                          current is FetchingKnowledgeLoadingState ||
                              current is FetchingKnowledgeErrorState ||
                              current is FetchingKnowledgeEmptyState ||
                              current is FetchingKnowledgeSuccessState ||
                              current is ChangedIndexSuccessState ||
                              current is ChangedInnerIndexSuccessState,
                          builder: (context, state) {
                            log('📊 Current State: $state',
                                name: 'VIEW_KNOWLEDGE_HUB');
        
                            final cubit =
                            context.read<CreateKnowledgeCubit>();
        
                            bool isInitialState =
                            state is CreateKnowledgeInitial;
                            bool hasCompletedFetch =
                                state is FetchingKnowledgeSuccessState ||
                                    state is FetchingKnowledgeEmptyState ||
                                    state is FetchingKnowledgeErrorState;
        
                            if (state is FetchingKnowledgeLoadingState) {
                              return SizedBox(
                                height: 200.h,
                                child: Center(
                                  child: CircleProgressMaster()
                                ),
                              );
                            }
        
                            if (state is FetchingKnowledgeErrorState) {
                              log('❌ Error State: ${state.error}',
                                  name: 'VIEW_KNOWLEDGE_HUB');
                              return SizedBox(
                                height: 300.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 60.r, color: AppColors.red),
                                      SizedBox(height: 16.h),
                                      Text(
                                        '${S.of(context).error}: ${state.error}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      SizedBox(height: 16.h),
                                      customButton(
                                        function: () {
                                          log('🔄 Retrying fetch...',
                                              name: 'VIEW_KNOWLEDGE_HUB');
                                          context
                                              .read<CreateKnowledgeCubit>()
                                              .fetchAllKnowledge();
                                        },
                                        title: S.of(context).retry,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
        
                            if (state is FetchingKnowledgeEmptyState ||
                                (hasCompletedFetch &&
                                    cubit.filteredKnowledge.isEmpty)) {
                              log('📭 Empty State - No approved documents found',
                                  name: 'VIEW_KNOWLEDGE_HUB');
                              return SizedBox(
                                height: 300.h,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                          'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
                                          height: 200.h),
                                      SizedBox(height: 16.h),
                                    ],
                                  ),
                                ),
                              );
                            }
        
                            // ✅ BUILD ANIMATED GRID
                            if (state is FetchingKnowledgeSuccessState ||
                                cubit.filteredKnowledge.isNotEmpty) {
                              final knowledgeList =
                              state is FetchingKnowledgeSuccessState
                                  ? state.knowledgeList
                                  : cubit.filteredKnowledge;
        
                              log('✅ Success State: ${knowledgeList.length} items',
                                  name: 'VIEW_KNOWLEDGE_HUB');
        
                              if (knowledgeList.isEmpty) {
                                return SizedBox(
                                 // height: 600.h,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Lottie.asset(
                                            'assets/lottie_assets/main_lottie_assets/lottie_empty.json',
                                            height: 200.h),
                                        SizedBox(height: 16.h),
                                        Text(
                                          S.of(context).noDataAvailable,
                                          style: TextStyle(fontSize: 16.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
        
                              // ✅ CREATE ANIMATIONS IF NOT CREATED
                              if (!_animationsCreated ||
                                  _slideAnimations.length !=
                                      knowledgeList.length) {
                                _createSlideAnimations(
                                    knowledgeList.length);
                                // Play animation after creation
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _playGridAnimation();
                                });
                              }
        
                              final int crossAxisCount = CrossAxisCountHelper
                                  .getCrossAxisCountForDefaultTablet2(context);
                              final double crossAxisSpacing = 10.sp;
                              final double mainAxisSpacing = 10.sp;

                              // Cell height comes from what the card's content
                              // actually needs (its text rows, gaps, padding and
                              // thumbnail) — not from the cell width — so the
                              // card stays compact on desktop and on mobile.
                              final double cardHeight =
                              ResponsiveCardHeight.forListCard(
                                context,
                                thumbnailHeight: 45.h,
                              );

                              try {
                                return GridView.builder(
                                  physics:
                                  const NeverScrollableScrollPhysics(),
                                  gridDelegate: ResponsiveCardHeight.delegate(
                                    crossAxisCount: crossAxisCount,
                                    cardHeight: cardHeight,
                                    crossAxisSpacing: crossAxisSpacing,
                                    mainAxisSpacing: mainAxisSpacing,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: knowledgeList.length,
                                  itemBuilder: (context, index) {
                                    final knowledge = knowledgeList[index];
                                    final fileUrl =
                                        knowledge.currentDocumentUrl;
                                    final fileType =
                                        knowledge.currentDocumentExtension;
        
                                    String publishDate = '-';
                                    try {
                                      int? firstPublishedIndex;
                                      for (int i = 0;
                                      i < knowledge.status.length;
                                      i++) {
                                        if (knowledge.status[i]
                                            .toLowerCase() ==
                                            'published') {
                                          firstPublishedIndex = i;
                                          break;
                                        }
                                      }
        
                                      if (firstPublishedIndex != null && firstPublishedIndex < knowledge.timestamps.length) {
        
                                        final timestamp = knowledge
                                            .timestamps[firstPublishedIndex];
                                        final dateTime = DateTime
                                            .fromMillisecondsSinceEpoch(
                                            timestamp);
                                        publishDate =
                                            DateFormat('dd MMM yyyy')
                                                .format(dateTime);
                                      }
        
        
                                    } catch (e) {
                                      debugPrint(
                                          'Error getting publish date: $e');
                                      publishDate = '-';
                                    }
        
                                    String localizedDepartment =
                                        knowledge.currentOwningDepartment;
                                    try {
                                      String? departmentId =
                                      departmentController
                                          .getDepartmentIdFromDepartmentName(
                                        departmentName: knowledge
                                            .currentOwningDepartment
                                            .toLowerCase(),
                                      );
        
                                      if (departmentId != null) {
                                        if (isArabic) {
                                          localizedDepartment =
                                              departmentController
                                                  .getArabicDepartmentNameFromDepartmentId(
                                                departmentId:
                                                departmentId,
                                              ) ??
                                                  knowledge
                                                      .currentOwningDepartment;
                                        } else {
                                          localizedDepartment =
                                              departmentController
                                                  .getEnglishDepartmentNameFromDepartmentId(
                                                departmentId:
                                                departmentId,
                                              ) ??
                                                  knowledge
                                                      .currentOwningDepartment;
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint(
                                          'Error getting department name: $e');
                                    }
        
                                    // ✅ WRAP WITH ANIMATED TRANSITIONS
                                    return SlideTransition(
                                      position: _slideAnimations.length >
                                          index
                                          ? _slideAnimations[index]
                                          : AlwaysStoppedAnimation(
                                          Offset.zero),
                                      child: FadeTransition(
                                        opacity:
                                        _fadeAnimations.length > index
                                            ? _fadeAnimations[index]
                                            : AlwaysStoppedAnimation(
                                            1.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            log('👆 Tapped on: ${knowledge.currentNameEnglish}',
                                                name: 'NAVIGATION');
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewKnowledgeDetails(
                                                      emailUser: knowledge
                                                          .createdByEmail
                                                          .lastOrNull!,
                                                      knowledgeId: knowledge
                                                          .currentKnowledgeId,
                                                      documentName: knowledge
                                                          .currentNameEnglish,
                                                      documentNameAr: knowledge
                                                          .currentNameArabic,
                                                      publishDate: publishDate,
                                                      documentType: knowledge
                                                          .currentKnowledgeDocumentType,
                                                      owningDepartment: knowledge
                                                          .currentOwningDepartment,
                                                      documentEnglishDescription:
                                                      knowledge
                                                          .currentDescriptionEnglish,
                                                      documentEnglishDescriptionAr:
                                                      knowledge
                                                          .currentDescriptionArabic,
                                                      fileType: fileType,
                                                      fileUrl: fileUrl,
                                                      documentExtension:
                                                      knowledge
                                                          .currentDocumentExtension,
                                                    ),
                                              ),
                                            ).then((Object? removed) {
                                              // ADDED 28/9/2026 (Knowledge Hub
                                              // p.17): the details page pops
                                              // `true` after a removal; refetch
                                              // so the removed card leaves the
                                              // grid now, not after a re-login.
                                              if (removed == true && mounted) {
                                                context
                                                    .read<CreateKnowledgeCubit>()
                                                    .fetchAllKnowledge();
                                              }
                                            });
                                          },
                                          child: fileCard(
                                            context,
                                            knowledge: knowledge,
                                            currentUserEmail: controller
                                                .employeeEntity?.email,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } catch (e, stackTrace) {
                                log('Error building GridView',
                                    name: 'GRID',
                                    error: e,
                                    stackTrace: stackTrace);
                                rethrow;
                              }
                            }
        
                            log('📭 No state match and no data - showing empty',
                                name: 'VIEW_KNOWLEDGE_HUB');
                            return SizedBox(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset('assets/lottie_assets/main_lottie_assets/lottie_empty.json',
                                        fit: BoxFit.scaleDown),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
