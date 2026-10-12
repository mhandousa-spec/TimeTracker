part of 'details_switch_widgets.dart';

// Split from details_switch_widgets.dart to keep files <700 LOC.

class ApprovalSelectionSection extends StatelessWidget {
  final TextEditingController searchController;
  final List<EmployeeEntityPro> filteredEmployees;
  final List<EmployeeEntityPro> selectedEmployees;
  final bool Function(EmployeeEntityPro) isRegularEmployee;
  final bool Function(EmployeeEntityPro) isSelected;
  final Function(EmployeeEntityPro) onToggleSelection;
  final String Function(EmployeeEntityPro, bool) displayName;
  final bool isEnglish;
  final bool isMobile;
  final ScrollController scrollController;
  final Function(int) onRemoveEmployee;
  final VoidCallback onRemoveEmployeeFromSelection;
  // ✅ FIX: Added onSearchChanged callback instead of accessing _cubit directly
  final ValueChanged<String> onSearchChanged;

  // ✅ NEW (bug report p29): department dropdown filter beside the search box.
  /// Department ids that eligible approvers belong to.
  final List<String> departmentIds;

  /// Currently selected department id, or null for "all departments".
  final String? selectedDepartmentId;

  /// Resolves a department id to its display name in the active language.
  final String Function(String departmentId) departmentName;

  final ValueChanged<String?> onDepartmentChanged;

  const ApprovalSelectionSection({
    super.key,
    required this.searchController,
    required this.filteredEmployees,
    required this.selectedEmployees,
    required this.isRegularEmployee,
    required this.isSelected,
    required this.onToggleSelection,
    required this.displayName,
    required this.isEnglish,
    required this.isMobile,
    required this.scrollController,
    required this.onRemoveEmployee,
    required this.onRemoveEmployeeFromSelection,
    required this.onSearchChanged, // ✅ NEW required param
    this.departmentIds = const [],
    this.selectedDepartmentId,
    required this.departmentName,
    required this.onDepartmentChanged,
  });

  @override
  Widget build(BuildContext context) {
    // filteredEmployees already contains only eligible employees from the cubit,
    // so no need to filter again here — just use it directly.
    final eligibleEmployees = filteredEmployees;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 26.sp),
        Text(
          FormatHelper.capitalize(
            S.of(context).addApprovals,
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.sp),
        Row(
          children: [
            Expanded(
              flex: 9,
              child: SizedBox(
                child: Row(
                  children: [
                    // ✅ FIX: no Expanded here — AppSearchTextField already
                    // returns an Expanded internally
                    // (35-custom_search_widget_custom.dart). Wrapping it in a
                    // second one put two Expanded widgets on the same
                    // RenderObject, which throws:
                    //   "Incorrect use of ParentDataWidget. Competing
                    //    ParentDataWidgets are providing parent data to the
                    //    same RenderObject"
                    AppSearchTextField(
                      fillColor: AppColors.background,
                      controller: searchController,
                      // ✅ FIX: use the passed callback, not _cubit
                      onChanged: onSearchChanged,
                    ),
                  ],
                ),
              ),
            ),
            // ✅ NEW (bug report p29 "add department drop down filter"): this
            // slot was an empty placeholder Column. Only render the dropdown
            // when there is more than one department to choose between.
            if (!isMobile)
              Expanded(
                flex: 2,
                child: departmentIds.length < 2
                    ? const SizedBox()
                    : Padding(
                        padding: EdgeInsetsDirectional.only(start: 10.sp),
                        // ✅ Uses the shared CustomDropdown
                        // (core/custom/1-custom_dropdwon.dart) instead of
                        // AppDropdown, so this filter matches every other
                        // dropdown in the module.
                        //
                        // The fixed SizedBox(height: 38.h) is gone on purpose:
                        // CustomDropdown builds its trigger from the same
                        // InputDecorator as CustomTextField, so giving it the
                        // search field's contentPadding makes the two boxes
                        // pixel-identical in height. Forcing 38.h would have
                        // overflowed the trigger and left it 6px shorter than
                        // the search box beside it.
                        child: CustomDropdown<String?>(
                          fillColor: AppColors.background,
                          hint: S.of(context).department,
                          value: selectedDepartmentId,
                          onChanged: onDepartmentChanged,
                          // Match AppSearchTextField: radius 8 and — bug
                          // report p.21 "same height" — its exact 38 (both
                          // apply .sp). Padding alone never matched: the
                          // dropdown's 20.sp chevron made its content taller.
                          borderRadius: BorderRadius.circular(8.r),
                          height: 38,
                          triggerPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                          ),
                          itemStyle: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.text),
                          valueStyle: StyleText.fontSize14Weight400
                              .copyWith(color: AppColors.text),
                          items: [
                            // null == "all departments"; CustomDropdown matches
                            // the selected item by value, so a null-valued item
                            // resolves correctly instead of showing the hint.
                            DropdownItem<String?>(
                              value: null,
                              label: S.of(context).all,
                            ),
                            ...departmentIds.map(
                              (id) => DropdownItem<String?>(
                                value: id,
                                label: departmentName(id),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
          ],
        ),
        SizedBox(height: 10.sp),
        SizedBox(
          height: 300.sp,
          child: GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(0.sp),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: CrossAxisCountHelperResponsive
                  .getCrossAxisCountForDefaultTabletResponsive(context),
              crossAxisSpacing: 10.sp,
              mainAxisSpacing: 10.sp,
              mainAxisExtent: employeeCardExtent(context),
            ),
            itemCount: eligibleEmployees.length,
            itemBuilder: (context, index) {
              final employee = eligibleEmployees[index];
              return SizedBox(
                child: EmployeeCard(
                  employee: employee,
                  onTap: () => onToggleSelection(employee),
                  isSelected: isSelected(employee),
                  isLightMode: Theme.of(context).brightness == Brightness.light,
                  name: displayName(employee, isEnglish),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20.sp),
        Text(
          FormatHelper.capitalize(
            "${S.of(context).approvalCycle}: ",
          ),
          style: StyleText.fontSize14Weight400.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        SizedBox(height: 10.sp),
        _buildSelectedEmployees(context),
      ],
    );
  }

  Widget _buildSelectedEmployees(BuildContext context) {
    if (isMobile) {
      return Column(
        children: List.generate(selectedEmployees.length, (index) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index != 0)
                Padding(
                  padding: EdgeInsets.only(
                    left: isEnglish ? 30.sp : 10.sp,
                    right: isEnglish ? 10.sp : 30.sp,
                    bottom: 0.sp,
                  ),
                  child: CustomPaint(
                    size: Size(0, 80),
                    painter: CurvedArrowPainter(
                      color: AppColors.text,
                      isArabic: !isEnglish,
                    ),
                  ),
                )
              else
                SizedBox(width: 1.w),
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ApprovalPerson(
                      employee: selectedEmployees[index],
                      isEnglish: isEnglish,
                    ),
                    Positioned(
                      right: isEnglish
                          ? index == 0
                          ? 273.sp
                          : 235.sp
                          : index == 0
                          ? 23.sp
                          : 27.sp,
                      bottom: 6,
                      child: GestureDetector(
                        onTap: () => onRemoveEmployee(index),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.red,
                          ),
                          child: Icon(
                            Icons.remove,
                            color: AppColors.white,
                            size: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      );
    }

    return Wrap(
      spacing: 0.sp,
      children: List.generate(
        selectedEmployees.length,
            (index) {
          final employee = selectedEmployees[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index >= 3 ? 0.sp : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.sp,
                        vertical: 4.sp,
                      ),
                      child: CircleAvatar(
                        radius: 25.r,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: SvgPicture.asset(
                            employee.gender == "male"
                                ? 'assets/icons_assets/main_icons_assets/male_avatar.svg'
                                : 'assets/icons_assets/main_icons_assets/female_avatar.svg',
                            semanticsLabel: 'Gender Icon',
                            fit: BoxFit.cover,
                            width: 40.sp,
                            height: 40.sp,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6.sp,
                      right: isEnglish ? 6.sp : 35.sp,
                      child: Container(
                        width: 16.sp,
                        height: 16.sp,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.remove,
                            size: 12.sp,
                            color: AppColors.white,
                          ),
                          onPressed: onRemoveEmployeeFromSelection,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 6.sp),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FormatHelper.capitalize(
                        isEnglish
                            ? "${employee.firstName ?? ''} ${employee.lastName ?? ''}"
                            : "${employee.firstNameInArabic ?? ''} ${employee.lastNameInArabic ?? ''}",
                      ),
                      style: StyleText.fontSize13Weight500.copyWith(color: AppColors.secondaryBlack).copyWith(
                        color: AppColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.sp),
                    Text(
                      _getDisplayJobTitle(employee, isEnglish),
                      style: StyleText.fontSize10Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
                        color: AppColors.secondaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(width: 4.sp),
                if (index < selectedEmployees.length - 1)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.sp,
                    ),
                    child: Transform.rotate(
                      angle: isEnglish ? 0 : 3.1416,
                      child: SvgPicture.asset(
                        "assets/icons_assets/services_assets/arrow_right_solid.svg",
                        color: AppColors.text,
                        fit: BoxFit.scaleDown,
                        semanticsLabel: 'Arrow',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDisplayJobTitle(EmployeeEntityPro employee, bool isEnglish) {
    final titleEn = (employee.title ?? '').trim();
    final titleAr = (employee.titleInArabic ?? '').trim();

    String title = isEnglish
        ? (titleEn.isNotEmpty ? FormatHelper.capitalize(titleEn) : titleAr)
        : (titleAr.isNotEmpty ? titleAr : titleEn);

    final abbreviationRegex = RegExp(r'\(([^)]+)\)\s*$');
    final match = abbreviationRegex.firstMatch(title);

    if (match != null) {
      return match.group(1) ?? title;
    }

    return title;
  }
}

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), onDismiss);

    return WillPopScope(
      onWillPop: () async {
        onDismiss();
        return false;
      },
      child: AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        content: SizedBox(
          width: 411.sp,
          height: 170.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie_assets/main_lottie_assets/lottie_approved.json',
                width: 70.sp,
                height: 70.sp,
              ),
              SizedBox(height: 25.sp),
              Text(
                title,
                textAlign: TextAlign.center,
                style: StyleText.fontSize20Weight500.copyWith(
                  color: AppColors.text,
                ),
              ),
              SizedBox(height: 18.sp),
              Text(
                message,
                textAlign: TextAlign.center,
                style: StyleText.fontSize15Weight400.copyWith(
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
