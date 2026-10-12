import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/settings_header.dart';
import 'package:knowticed_plus/features/settings/mode_changer.dart';
import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_hr_components/buttons_beside_title_row.dart';

import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/main_core_department_controller.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_controller.dart';


import 'package:knowticed_plus/features/home/h2_nav_bar/persistent_nav_bar.dart';

import 'package:knowticed_plus/core/custom/71-custom_appbar_mobile.dart';
import '../tablet/employees_hierarchy.dart';



class EmployeesScreenMobile extends StatefulWidget {
   EmployeesScreenMobile({super.key});

  @override
  State<EmployeesScreenMobile> createState() => _EmployeesScreenMobileState();
}

class _EmployeesScreenMobileState extends State<EmployeesScreenMobile> {
  Future<void> getDepartments() async {
    await addDepartmentController.getDepartments();

    setState(() {});
  }

  int selectedIndex = 0;
  String? orgDropDwon;
  AddDepartmentController addDepartmentController =
      Get.isRegistered<AddDepartmentController>()
          ? Get.find<AddDepartmentController>()
          : Get.put(AddDepartmentController());
  OrgChartEmployeeController addEmployeeController =
      Get.isRegistered<OrgChartEmployeeController>()
          ? Get.find<OrgChartEmployeeController>()
          : Get.put(OrgChartEmployeeController());

  @override
  void initState() {
    getDepartments();

    addEmployeeController.getAllEmployees();
    super.initState();
  }

  bool chartSelected = false;
  bool orgSelected = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Mode.hr || Mode.owner
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.04.w),
                  child: ButtonsBesideTitle(
                    chartSelected: chartSelected,
                    chartSelectedState: (value) {
                      setState(() {
                        chartSelected = value;
                      });
                    },
                    orgSelected: orgSelected,
                    orgSelectedState: (value) {
                      setState(() {
                        orgSelected = value;
                      });
                    },
                  ),
                )
              : const SizedBox.shrink(),
          Mode.hr || Mode.owner
              ? SizedBox(height: .014.h)
              : const SizedBox.shrink(),
          Expanded(
              child: Container(
            color: AppColors.background,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.04.w),
              child: GetBuilder<OrgChartEmployeeController>(
                builder: (_) {
                  if (addEmployeeController.allEmployees == null) {
                    return CircleProgressMaster();
                  } else {
                    // The chart view (ChartScreenMobile) was removed, so the
                    // hierarchy is the only body this page renders. The old
                    // `chartSelected == false` branch below it was unreachable
                    // anyway — it only ran inside the `chartSelected == true`
                    // path — so it went with it.
                    return TabletEmployeesHierarchy();
                  }
                },
              ),
            ),
          )),
        ],
      )),
    );
  }
}

enum StatusWant {
  // ignore: constant_identifier_names
  Employee,
  // ignore: constant_identifier_names
  department,
  // ignore: constant_identifier_names
}

void _showSortMenu(BuildContext context, Offset iconPosition) async {
  final List<StatusWant> sortOptions = [
    StatusWant.Employee,
    StatusWant.department,
  ];

  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final double menuOffsetX = iconPosition.dx - (-9.0);
  final double menuOffsetY = iconPosition.dy - (-7.0);

  final RelativeRect position = RelativeRect.fromLTRB(
    menuOffsetX,
    menuOffsetY,
    overlay.size.width - menuOffsetX,
    overlay.size.height,
  );

  selectedOption = await showMenu(
    elevation: 0,
    shadowColor: Colors.transparent,
    color: Theme.of(context).colorScheme.onPrimary,
    context: context,
    constraints: BoxConstraints(
      maxWidth: 0.43.w,
      minHeight: 0.0.h,
    ),
    position: position,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.signOut)),
    items: sortOptions.map((option) {
      return CustomPopupMenuItem<StatusWant>(
          first: option.index == 0,
          last: option.index == sortOptions.length - 1,
          color: Theme.of(context).colorScheme.onPrimary,
          value: option,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getSortOptionLabel(option, context),
            ],
          ));
    }).toList(),
  );

  if (selectedOption != null) {
    // Call the appropriate dialog function based on the selected option
    switch (selectedOption!) {
      case StatusWant.Employee:
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen:  Container(),
          withNavBar: true,
        );
        break;
      case StatusWant.department:
        showDialog(
            context: context,
            builder: (context) {
              return Container();
            });
        break;
    }
  }
}

StatusWant? selectedOption;
Widget _getSortOptionLabel(StatusWant option, BuildContext context) {
  switch (option) {
    case StatusWant.Employee:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/organization_chart_assets/employee_down.svg',
        text: "Add Employee",
      );
    case StatusWant.department:
      return const SortOptionWidget(
        iconAddress: 'assets/icons_assets/organization_chart_assets/case_down.svg',
        text: "Add Department",
      );
  }
}

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final Color color;
  final bool first;
  final bool last;

  const CustomPopupMenuItem({
    Key? key,
    required T value,
    bool enabled = true,
    required Widget child,
    required this.color,
    this.first = false,
    this.last = false,
  }) : super(key: key, value: value, enabled: enabled, child: child);

  @override
  // ignore: library_private_types_in_public_api
  _CustomPopupMenuItemState<T> createState() => _CustomPopupMenuItemState<T>();
}

class _CustomPopupMenuItemState<T>
    extends PopupMenuItemState<T, CustomPopupMenuItem<T>> {
  late BorderRadius borderRadius;
  double radius = 10;
  @override
  Widget build(BuildContext context) {
    if (widget.first) {
      borderRadius = BorderRadius.only(
          topLeft: Radius.circular(radius), topRight: Radius.circular(radius));
    } else if (widget.last) {
      borderRadius = BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius));
    } else {
      borderRadius = BorderRadius.zero;
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        color: widget.color,
        child: super.build(context),
      ),
    );
  }
}

String getCurrentDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('dd MMMM yyyy').format(now);
  return formattedDate;
}
