///******************* FILE INFO *******************///
/// File Name: employees_hierarchy.dart
/// Purpose: Contains the ui for the employees hierarchy page using dfs algorithm to draw the hierarchy
/// Author: Mohamed Elrashidy
/// Created at: 25/12/2024
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/src/services/haptic_feedback.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/org_chart_module/domain/entities/organization_hierarchy_node.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employees_hierarchy_drawer.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';




import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/ui/widgets/employee_card.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/ui/widgets/employees_hierarchy_filter_by_department.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class TabletEmployeesHierarchy extends StatefulWidget {
  TabletEmployeesHierarchy({super.key});

  @override
  State<TabletEmployeesHierarchy> createState() =>
      _TabletEmployeesHierarchyState();
}

class _TabletEmployeesHierarchyState extends State<TabletEmployeesHierarchy> {
  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());
  TextEditingController searchEmployee = TextEditingController();
  List<OrganizationHierarchyNode> filteredNodes = [];
  final ScrollController _horizontalScrollController = ScrollController();

  /// Guarded lookup — may not be registered yet when this widget builds.
  AddDepartmentController get _departments =>
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());

  @override
  initState() {
    super.initState();

    // The department filter chips are built from `controller.getDepartment(id)`,
    // which reads AddDepartmentController's id -> name maps. Nothing on the
    // tablet path was ever populating those maps (only the mobile screen and
    // the unused FilterSelector called getDepartments()), so every lookup
    // returned "" and only the "All" chip rendered. Load them here.
    _loadDepartments();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      addEmployeeController.filterEmployeesByDepartmentId("All");
    });
  }

  Future<void> _loadDepartments() async {
    await _departments.getDepartments();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    searchEmployee.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _searchEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNodes = [];
      } else {
        filteredNodes = [];
        String lowerQuery = query.toLowerCase();

        for (var node in addEmployeeController.organizationHierarchyNodesRoots.values) {
          _searchInNode(node, lowerQuery);
        }
      }
    });
  }

  void _searchInNode(OrganizationHierarchyNode node, String query) {
    String firstName = node.employee.firstName.isNotEmpty
        ? node.employee.firstName.last.toLowerCase()
        : '';
    String lastName = node.employee.lastName.isNotEmpty
        ? node.employee.lastName.last.toLowerCase()
        : '';
    String fullName = '$firstName $lastName';

    if (fullName.contains(query) ||
        firstName.contains(query) ||
        lastName.contains(query)) {
      filteredNodes.add(node);
    }

    for (var child in node.children) {
      _searchInNode(child, query);
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;

    return isMobile ? Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.sp, vertical: isMobile ? 0 : 0.sp),
      child: Column(
        children: [
          isMobile ? SizedBox(height: 0) : SizedBox(height: 20.h),

          Row(
            children: [
              Text(
                S.of(context).organizationChart,
                style: StyleText.fontSize22Weight600.copyWith(
                    color: lightMode ? AppColors.blackButton : AppColors.white
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 30.h : 30.h),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GetBuilder<OrgChartEmployeeController>(
                  builder: (controller) {
                    bool isArabic = Get.locale?.languageCode == 'ar';
                    String allLabel = isArabic ? 'الكل' : 'All';

                    Map<String, int> departmentCounts = {};
                    int totalCount = 0;

                    if (controller.allEmployees != null) {
                      for (var employee in controller.allEmployees!) {
                        totalCount++;
                        String deptId = employee.departmentId.isNotEmpty
                            ? employee.departmentId.last
                            : '';

                        if (deptId.isNotEmpty) {
                          String deptName = controller.getDepartment(deptId);
                          if (deptName.isNotEmpty) {
                            departmentCounts[deptName] = (departmentCounts[deptName] ?? 0) + 1;
                          }
                        }
                      }
                    }

                    return StatusChipFilter(
                      selectedKey: controller.selectedDepartment ?? allLabel,
                      onSelected: (selectedLabel) {
                        String? deptId;
                        if (selectedLabel != allLabel) {
                          for (var employee in controller.allEmployees ?? []) {
                            if (employee.departmentId.isNotEmpty) {
                              String testDeptId = employee.departmentId.last;
                              String testDeptName = controller.getDepartment(testDeptId);
                              if (testDeptName == selectedLabel) {
                                deptId = testDeptId;
                                break;
                              }
                            }
                          }
                        }

                        addEmployeeController.filterEmployeesByDepartmentId(
                            selectedLabel == allLabel ? 'All' : deptId
                        );

                        searchEmployee.clear();
                        filteredNodes = [];

                        setState(() {});
                      },
                      items: departmentChipItems(
                        totalCount: totalCount,
                        departmentCounts: departmentCounts,
                        isArabic: isArabic,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          SizedBox(height: 15.h),

          Expanded(
            child: GetBuilder<OrgChartEmployeeController>(
              init: addEmployeeController,
              builder: (controller) {
                if (addEmployeeController.organizationHierarchyNodesRoots.isEmpty) {
                  return Center(
                    child: CircleProgressMaster(),
                  );
                } else {
                  var nodesToDisplay = filteredNodes.isNotEmpty
                      ? filteredNodes
                      : addEmployeeController.organizationHierarchyNodesRoots.values;

                  if (searchEmployee.text.isNotEmpty && filteredNodes.isEmpty) {
                    return Center(
                      child: Text(
                        "No employees found",
                        style: StyleText.fontSize22Weight600,
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_horizontalScrollController.hasClients && isArabic) {
                      _horizontalScrollController.jumpTo(0);
                    }
                  });

                  return SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var node in nodesToDisplay)
                            buildOrganizationHierarchyGraph(node, 0)
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    ) :

    Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: isMobile ? 0 : 15.sp),
      child: Column(
        children: [
          isMobile ? SizedBox(height: 0) : SizedBox(height: 20.h),

          Row(
            children: [
              Text(
                S.of(context).organizationChart,
                style: StyleText.fontSize22Weight600.copyWith(
                    color: AppColors.text
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 30.h : 30.h),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GetBuilder<OrgChartEmployeeController>(
                  builder: (controller) {
                    bool isArabic = Get.locale?.languageCode == 'ar';
                    String allLabel = isArabic ? 'الكل' : 'All';

                    Map<String, int> departmentCounts = {};
                    int totalCount = 0;

                    if (controller.allEmployees != null) {
                      for (var employee in controller.allEmployees!) {
                        totalCount++;
                        String deptId = employee.departmentId.isNotEmpty
                            ? employee.departmentId.last
                            : '';

                        if (deptId.isNotEmpty) {
                          String deptName = controller.getDepartment(deptId);
                          if (deptName.isNotEmpty) {
                            departmentCounts[deptName] = (departmentCounts[deptName] ?? 0) + 1;
                          }
                        }
                      }
                    }

                    return StatusChipFilter(
                      selectedKey: controller.selectedDepartment ?? allLabel,
                      onSelected: (selectedLabel) {
                        String? deptId;
                        if (selectedLabel != allLabel) {
                          for (var employee in controller.allEmployees ?? []) {
                            if (employee.departmentId.isNotEmpty) {
                              String testDeptId = employee.departmentId.last;
                              String testDeptName = controller.getDepartment(testDeptId);
                              if (testDeptName == selectedLabel) {
                                deptId = testDeptId;
                                break;
                              }
                            }
                          }
                        }

                        addEmployeeController.filterEmployeesByDepartmentId(
                            selectedLabel == allLabel ? 'All' : deptId
                        );

                        searchEmployee.clear();
                        filteredNodes = [];

                        setState(() {});
                      },
                      items: departmentChipItems(
                        totalCount: totalCount,
                        departmentCounts: departmentCounts,
                        isArabic: isArabic,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 15.h),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     customButtonWithSvg(
          //       title: isMobile ? "" : S.of(context).department,
          //       function: () async {
          //         await Get.dialog(
          //           AddDepartmentDialogNew(),
          //           barrierDismissible: true,
          //         );
          //
          //         setState(() {
          //           addEmployeeController.filterEmployeesByDepartmentId("All");
          //         });
          //       },
          //       textStyle: StyleText.fontSize15Weight400.copyWith(
          //         color: AppColors.textButton,
          //       ),
          //       height: 38.h,
          //       width: isMobile ? 38.w : 135.w,
          //       space: isMobile ? 0 : 8,
          //       radius: 8.r,
          //       color: AppColors.primary,
          //       image: "assets/icons_assets/organization_chart_assets/new_department.svg",
          //       widthImage: 23,
          //       heightImage: 23,
          //       svgColor: AppColors.textButton,
          //       colorBorder: Colors.transparent,
          //     ),
          //   ],
          // ),

          GetBuilder<OrgChartEmployeeController>(
            init: addEmployeeController,
            builder: (controller) {
              if (addEmployeeController.organizationHierarchyNodesRoots.isEmpty) {
                return Column(
                  children: [
                    SizedBox(height: isPortrait ? 300.h : 190.h),
                    CircleProgressMaster(),
                  ],
                );
              } else {
                var nodesToDisplay = filteredNodes.isNotEmpty
                    ? filteredNodes
                    : addEmployeeController.organizationHierarchyNodesRoots.values;

                if (searchEmployee.text.isNotEmpty && filteredNodes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100.h),
                      child: Text(
                        "No employees found",
                        style: StyleText.fontSize22Weight600,
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_horizontalScrollController.hasClients && isArabic) {
                    _horizontalScrollController.jumpTo(0);
                  }
                });

                return SizedBox(
                  height: isTablet ? null : 598.h,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var node in nodesToDisplay)
                          buildOrganizationHierarchyGraph(node, 0)
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildOrganizationHierarchyGraph(
      OrganizationHierarchyNode node, int level) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    double opacityStep = addEmployeeController.getOpacityStep();
    double opacity = (level) * opacityStep;
    bool isLeader = node.children.isNotEmpty;

    // Skip rendering if employee data is invalid
    if (node.employee.firstName.isEmpty && node.employee.lastName.isEmpty) {
      return SizedBox.shrink();
    }

    if (node.employee.id!.isEmpty) {
      return SizedBox.shrink();
    }

    if (node.employee.email.isEmpty) {
      return SizedBox.shrink();
    }

    return isMobile
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 10.h),
        EmployeeCard(
          textColor: (level == 0)
              ? AppColors.textButton
              : isLeader
              ? AppColors.white
              : AppColors.black,
          isLeader: isLeader,
          cardColor: (level == 0)
              ? AppColors.primary
              : isLeader
              ? (AppTheme.isDark ? AppColors.darkGrey : AppColors.darkGrey)
              .withOpacity(AppTheme.isDark
              ? (1 - (1 - opacity))
              : (1 - opacity))
              : lightMode
              ? Colors.white
              : Colors.white.withOpacity(.5),
          employee: node.employee,
        ),
        if (node.children.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < node.children.length; i++)
                  if (node.children[i].children.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: buildOrganizationHierarchyGraph(
                          node.children[i], level + 1),
                    ),

                Column(
                  children: [
                    for (int i = 0; i < node.children.length; i++)
                      if (node.children[i].children.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 4.h),
                          child: buildOrganizationHierarchyGraph(
                              node.children[i], level + 1),
                        )
                  ],
                )
              ],
            ),
          ),
      ],
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ FIX: Only add top spacing for root level
        if (level == 0) SizedBox(height: 10.h),

        EmployeeCard(
          textColor: (level == 0)
              ? AppColors.textButton
              : isLeader
              ? AppColors.white
              : AppColors.black,
          isLeader: isLeader,
          cardColor: (level == 0)
              ? AppColors.primary
              : isLeader
              ? (AppTheme.isDark ? AppColors.darkGrey : AppColors.darkGrey)
              .withOpacity(AppTheme.isDark
              ? (1 - (1 - opacity))
              : (1 - opacity))
              : lightMode
              ? Colors.white
              : Colors.white.withOpacity(.5),
          employee: node.employee,
        ),

        if (node.children.isNotEmpty)
          Padding(
            // ✅ FIX: Consistent vertical spacing
            padding: EdgeInsets.only(top: 10.h,right: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Leaders (nodes with children)
                ...node.children
                    .where((c) => c.children.isNotEmpty)
                    .map((child) => Padding(
                  // ✅ FIX: Equal horizontal spacing for leaders
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: buildOrganizationHierarchyGraph(child, level + 1),
                )),

                // Regular employees (nodes without children)
                if (node.children.any((c) => c.children.isEmpty))
                  Column(
                    children: node.children
                        .where((c) => c.children.isEmpty)
                        .map((child) => Padding(
                      // ✅ FIX: Equal spacing - horizontal and vertical
                      padding: EdgeInsets.only(
                        // left: 50.w,
                        // right: .w,
                        bottom: 10.h,
                      ),
                      child: buildOrganizationHierarchyGraph(child, level + 1),
                    ))
                        .toList()
                      ..removeLast() // Remove bottom padding from last item
                      ..add(
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.w),
                          child: buildOrganizationHierarchyGraph(
                            node.children.lastWhere((c) => c.children.isEmpty),
                            level + 1,
                          ),
                        ),
                      ),
                  )
              ],
            ),
          ),
      ],
    );
  }
}
