import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_components_subwidgets.dart/assets_container.dart';
import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_hr_components/employee_hr_profile_components/custom_expandable_container.dart';
import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_hr_components/employee_hr_profile_components/custom_health_table.dart';
import 'package:knowticed_plus/features/org_chart_module/employees_components/employees_hr_components/employee_hr_profile_components/info_with_bullet_list.dart';
import 'package:knowticed_plus/features/settings/main_controller/presentation/ui/widgets/custom_icon_container.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';

import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/social_permissions.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/generated/l10n.dart';

class CustomPersonalInfoContainer extends StatefulWidget {
  final String primaryText;
  final List<String>? secondaryTexts;
  final List<String>? personalInfoTexts;
  final List<String>? customIcons;
  final bool? isPersonalInformation;
  final bool? isPositionDetailes;
  final bool? isWorkingHours;
  final bool? isGeneralInfo;
  final bool? isAdditionalInfo;
  final bool? isAssets;
  final bool? isHealth;
  final bool? isSkills;
  final int? numberOfElementsInColumn;

  const CustomPersonalInfoContainer({
    super.key,
    required this.primaryText,
    this.secondaryTexts,
    this.personalInfoTexts,
    this.customIcons,
    this.isPersonalInformation = false,
    this.isPositionDetailes = false,
    this.isWorkingHours = false,
    this.isGeneralInfo = false,
    this.isAdditionalInfo = false,
    this.isAssets = false,
    this.isHealth = false,
    this.isSkills = false,
    this.numberOfElementsInColumn,
  });

  @override
  _CustomPersonalInfoContainerState createState() =>
      _CustomPersonalInfoContainerState();
}

final CustomTableWidget emergencyTableWidget = CustomTableWidget(
  initialData: [
    ['Bassem Mohamed', '987-654-3210', S.current.friend],
    ['Bassem Mohamed', '987-654-3210', S.current.friend],
    ['Bassem Mohamed', '987-654-3210', S.current.family],
  ],
  columnName1: 'Contact Name',
  columnName2: 'Contact Number',
  columnName3: 'Relationship',
  tableName: 'Emergncy Contact Information',
);

const CustomTableWidget healthTableWidget = CustomTableWidget(
  initialData: [
    ['Mazen Shaaban', '987-654-3210', '012113124255'],
    ['Mazen Shaaban', '987-654-3210', '012113124255'],
    ['Mazen Shaaban', '987-654-3210', '012113124255'],
  ],
  isHealth: true,
  columnName1: 'Insurance Provider',
  columnName2: 'Policy Number',
  columnName3: 'Contact Number',
  tableName: 'Health Insurance Details',
);

class _CustomPersonalInfoContainerState
    extends State<CustomPersonalInfoContainer> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.only(top: isVertical ? 0.02.h : 0.03.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              hapticController.triggerHapticFeedback(
                  vibration: VibrateType.lightImpact,
                  hapticFeedback: HapticFeedback.lightImpact);
              setState(() {
                expanded = !expanded;
              });
            },
            child: ExpandableContainer(
              expanded: expanded,
              color: Colors.grey[700],
              title: widget.primaryText,
            ),
          ),
          if (expanded && (widget.isPersonalInformation == true || widget.isSkills == true))
            SizedBox(height: 0.01.h),

          if (expanded && widget.isPersonalInformation == true)
            SingleChildScrollView(
              child: (isVertical && widget.isPositionDetailes != true && widget.isWorkingHours != true
                  && widget.isGeneralInfo != true
              )
                  ? buildSingleColumn()
                  : buildMultiColumn(),
            ),

          if (expanded && widget.isSkills == true && widget.isSkills != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isVertical ? 0.02.w : 0.02.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: widget.secondaryTexts?.map((skill) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: themeController.currentTheme == AppColors.lightTheme
                              ? Colors.grey[300]
                              : Colors.grey[700],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          skill.capitalize ?? skill,
                          style: AppFontStyle.cairoRegularStyle.copyWith(
                            fontSize: FontConstants.fontSize015.h,
                            color: themeController.currentTheme == AppColors.lightTheme
                                ? AppColors.colorBlack
                                : AppColors.colorWhiteDark,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList() ?? [],
                  ),
                ),
              ),
            ),

          if (expanded && widget.isAdditionalInfo == true && widget.isAdditionalInfo != null)
            Padding(
              padding: EdgeInsets.only(right: 0.02.h, left: 0.02.h, top: 0.025.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: Get.locale.toString().contains('en') ? 0.02.h : 0,
                          left: Get.locale.toString().contains('ar') ? 0.02.h : 0),
                      child: CustomIconContainer(
                        text: S.of(context).educationCertificate,
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomIconContainer(
                      text: S.of(context).iDPhoto,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

          if (expanded && widget.isAssets == true)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.02.h),
              child: Column(
                children: [
                  AssetsContainer(isEmployeeProfile: true),
                  AssetsContainer(isEmployeeProfile: true),
                ],
              ),
            ),

          if (expanded && widget.isHealth == true)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.02.h),
              child: Column(
                children: [
                  emergencyTableWidget,
                  healthTableWidget,
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Function Name: [_canSee]
  ///
  /// Purpose: Whether the signed-in employee's role grants [permission] under
  ///          Settings > Social Permissions.
  ///
  /// Added 23/8/2026: [buildMultiColumn] already gated every social section
  /// this way, but [buildSingleColumn] — the phone layout — did not, so a role
  /// with Academic History or Skills Hobbies switched off still saw them on a
  /// phone. Same checks, one helper, both layouts.
  ///
  /// Parameters:
  /// - [permission]: The social permission to test.
  ///
  /// Returns: [bool] true when the switch is on for this role.
  bool _canSee(SocialPermissions permission) =>
      Get.find<MainCoreEmployeeController>().isHasPermission(
        module: Modules.settings,
        section: SettingsPermissionsSections.socialPermissions,
        permission: permission,
      );

  Widget buildSingleColumn() {
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    if (widget.isGeneralInfo == true) {

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.02.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First item - Institution Name (normal display)
            if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 0)
              buildRowContent(0),

            SizedBox(height: 0.01.h),

            // Second and Third items in a row - Degree and Graduation Year
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_canSee(SocialPermissions.academicHistory))
                  if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 1)
                    Expanded(child: buildRowContent(1)),
                if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 2)
                  SizedBox(width: 0.02.w),
                if (_canSee(SocialPermissions.certificates))
                  if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 2)
                    Expanded(child: buildRowContent(2)),
              ],
            ),

            // Skills with mobile-specific wrapped containers (index 3)
            if (_canSee(SocialPermissions.skillsHobbies))
              if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 3) ...[
                SizedBox(height: 0.015.h),
                _buildMobileSkillsHobbiesItem(3),
              ],

            // Hobbies with mobile-specific wrapped containers (index 4)
            if (_canSee(SocialPermissions.skillsHobbies))
              if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 4) ...[
                SizedBox(height: 0.015.h),
                _buildMobileSkillsHobbiesItem(4),
              ],
          ],
        ),
      );
    }

    // Default single column for other sections
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.02.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(
          widget.secondaryTexts!.length,
              (index) => buildRowContent(index),
        ),
      ),
    );
  }

  Widget _buildMobileSkillsHobbiesItem(int index) {

    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Get the raw data
    String rawData = widget.secondaryTexts![index];

    // ✅ FIXED: Check if data is null, empty, or just "-"
    if (rawData == '-' || rawData.trim().isEmpty || rawData.trim() == '-') {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h, horizontal: 0.02.h),
        child: Row(
          children: [
            if (widget.customIcons != null && index < widget.customIcons!.length)
              SvgPicture.asset(
                widget.customIcons![index],
                height: 0.02.h,
              ),
            SizedBox(width: 0.01.h),
            if (widget.personalInfoTexts != null && index < widget.personalInfoTexts!.length)
              Text(
                widget.personalInfoTexts![index].capitalize as String,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize015.h,
                  color: themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorDarkGrey
                      : AppColors.colorGreydark,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: 0.01.w),
            Text(
              '-',
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize015.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Parse the data into items
    List<String> items = [];
    if (rawData.contains('[[') || rawData.contains('[')) {
      String cleaned = rawData
          .replaceAll('[', '')
          .replaceAll(']', '')
          .trim();

      items = cleaned
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != '-')
          .toList();
    } else if (rawData.contains(',')) {
      items = rawData
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != '-')
          .toList();
    } else {
      items = [rawData.trim()];
    }

    // ✅ FIXED: If no valid items after parsing, show dash
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h, horizontal: 0.02.h),
        child: Row(
          children: [
            if (widget.customIcons != null && index < widget.customIcons!.length)
              SvgPicture.asset(
                widget.customIcons![index],
                height: 0.02.h,
              ),
            SizedBox(width: 0.01.h),
            if (widget.personalInfoTexts != null && index < widget.personalInfoTexts!.length)
              Text(
                widget.personalInfoTexts![index].capitalize as String,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize015.h,
                  color: themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorDarkGrey
                      : AppColors.colorGreydark,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: 0.01.w),
            Text(
              '-',
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize015.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }


    // Show label + wrapped containers together (for valid data)
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h, horizontal: 0.02.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row (icon + text)
          Row(
            children: [
              if (widget.customIcons != null && index < widget.customIcons!.length)
                SvgPicture.asset(
                  widget.customIcons![index],
                  height: 0.02.h,
                ),
              SizedBox(width: 0.01.h),
              if (widget.personalInfoTexts != null && index < widget.personalInfoTexts!.length)
                Text(
                  widget.personalInfoTexts![index].capitalize as String,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize015.h,
                    color: themeController.currentTheme == AppColors.lightTheme
                        ? AppColors.colorDarkGrey
                        : AppColors.colorGreydark,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          SizedBox(height: 0.008.h),
          // Wrapped containers with 4.w spacing
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: items.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: lightMode ? Colors.grey[300] : Colors.grey[700],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.capitalize ?? item,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize015.h,
                    color: themeController.currentTheme == AppColors.lightTheme
                        ? AppColors.colorBlack
                        : AppColors.colorWhiteDark,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildMultiColumn() {
    // Position Details with 2x2 grid layout
    if (widget.isPositionDetailes == true && widget.secondaryTexts!.length >= 4) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: Department + Supervisor
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: _buildPositionDetailItem(0)),
                SizedBox(width: 0.02.w),
                Expanded(child: _buildPositionDetailItem(1)),
              ],
            ),
            SizedBox(height: 0.01.h),
            // Second Row: Email + Phone
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if(Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.settings,
                  section: SettingsPermissionsSections.socialPermissions,
                  permission: SocialPermissions.shareEmailsAndSocialDataInBio,
                ) )
                  Expanded(child: _buildPositionDetailItem(2)),
                SizedBox(width: 0.02.w),
                if(Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.settings,
                  section: SettingsPermissionsSections.socialPermissions,
                  permission: SocialPermissions.shareCellphonesInSocialDataInBio,
                ) )
                  Expanded(child: _buildPositionDetailItem(3)),
              ],
            ),
          ],
        ),
      );
    }

    if (widget.isWorkingHours == true && widget.secondaryTexts!.length >= 5) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: _buildWorkingHoursItem(0)),
              SizedBox(width: 0.02.w),
              Expanded(child: _buildWorkingHoursItem(1)),
              SizedBox(width: 0.02.w),
              Expanded(child: _buildWorkingHoursItem(2)),
            ],
          ),
          SizedBox(height: 0.01.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(child: _buildWorkingHoursItem(3)),
              SizedBox(width: 0.02.w),
              Expanded(child: SizedBox()),
            ],
          ),
        ],
      );
    }

    // General Information layout
    if (widget.isGeneralInfo == true) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 0)
              _buildGeneralInfoItem(0, false),
            if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 0)
              SizedBox(height: 0.01.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if(Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.settings,
                  section: SettingsPermissionsSections.socialPermissions,
                  permission: SocialPermissions.academicHistory,
                ) )
                  if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 1)
                    Expanded(child: _buildGeneralInfoItem(1, false)),

                if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 1)
                  SizedBox(width: 0.02.w),
                if(Get.find<MainCoreEmployeeController>().isHasPermission(
                  module: Modules.settings,
                  section: SettingsPermissionsSections.socialPermissions,
                  permission: SocialPermissions.certificates,
                ) )
                  if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 2)
                    Expanded(child: _buildGeneralInfoItem(2, false))
                  else
                    Expanded(child: SizedBox()),
              ],
            ),

            if(Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.settings,
              section: SettingsPermissionsSections.socialPermissions,
              permission: SocialPermissions.skillsHobbies,
            ) )
              if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 3)
                _buildGeneralInfoWrappedItem(3),
            if(Get.find<MainCoreEmployeeController>().isHasPermission(
              module: Modules.settings,
              section: SettingsPermissionsSections.socialPermissions,
              permission: SocialPermissions.skillsHobbies,
            ) )
              if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 4)
                _buildGeneralInfoWrappedItem(4),
          ],
        ),
      );
    }

    // Default multi-column layout
    int numberOfColumns = 0;
    if (widget.secondaryTexts != null && widget.secondaryTexts!.length > 0) {
      numberOfColumns = (widget.secondaryTexts!.length / 4).ceil();
    }

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: List<Widget>.generate(
          numberOfColumns,
              (columnIndex) {
            var lightMode = Theme.of(context).brightness == Brightness.light;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: List<Widget>.generate(
                widget.isPositionDetailes == true
                    ? 3
                    : widget.numberOfElementsInColumn ?? 4,
                    (rowIndex) {
                  final index = columnIndex *
                      (widget.isPositionDetailes == true
                          ? 3
                          : widget.numberOfElementsInColumn ?? 4) +
                      rowIndex;
                  if (index < widget.secondaryTexts!.length) {
                    Widget rowContent = Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.015.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.customIcons != null &&
                              index < widget.customIcons!.length)
                            SvgPicture.asset(
                              widget.customIcons![index],
                              height: 0.03.h,
                            ),
                          SizedBox(width: 0.004.h),
                          if (widget.personalInfoTexts != null &&
                              index < widget.personalInfoTexts!.length)
                            Text(
                              widget.personalInfoTexts![index].capitalize as String,
                              style: AppFontStyle.cairoRegularStyle.copyWith(
                                fontSize: FontConstants.fontSize020.h,
                                color: themeController.currentTheme == AppColors.lightTheme
                                    ? AppColors.colorDarkGrey
                                    : AppColors.colorGreydark,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          SizedBox(width: 0.002.w),
                          SizedBox(width: 0.015.w),
                        ],
                      ),
                    );
                    if (columnIndex == 0) {
                      return Container(width: 0.25.w, child: rowContent);
                    } else {
                      return Container(width: 0.25.w, child: rowContent);
                    }
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPositionDetailItem(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            SvgPicture.asset(
              widget.customIcons![index],
              height: 20.h,
              width: 20.w,
              fit: BoxFit.fill,
            ),
          SizedBox(width: 0.004.h),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            Text(
              widget.personalInfoTexts![index].capitalize as String,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize017.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorDarkGrey
                    : AppColors.colorGreydark,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(width: 0.002.w),
          Flexible(
            child: Text(
              widget.secondaryTexts![index].contains('AM') ||
                  widget.secondaryTexts![index].contains('PM')
                  ? widget.secondaryTexts![index].toUpperCase()
                  : widget.secondaryTexts![index].contains('@')
                  ? widget.secondaryTexts![index]
                  : widget.secondaryTexts![index].capitalize as String,
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize017.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursItem(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            Center(
              child: SvgPicture.asset(
                widget.customIcons![index],
                height: 20.h,
                width: 20.w,
                fit: BoxFit.fill,
              ),
            ),
          SizedBox(width: 0.004.h),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            Text(
              widget.personalInfoTexts![index].capitalize as String,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize017.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorDarkGrey
                    : AppColors.colorGreydark,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(width: 0.002.w),
          Flexible(
            child: Text(
              widget.secondaryTexts![index].contains('AM') ||
                  widget.secondaryTexts![index].contains('PM')
                  ? widget.secondaryTexts![index].toUpperCase()
                  : widget.secondaryTexts![index].contains('@')
                  ? widget.secondaryTexts![index]
                  : widget.secondaryTexts![index].capitalize as String,
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize017.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoItem(int index, bool isSpec) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            Center(
              child: SvgPicture.asset(
                widget.customIcons![index],
                height: 20.h,
                width: 20.w,
                fit: BoxFit.fill,
              ),
            ),
          SizedBox(width: 0.004.h),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            Text(
              widget.personalInfoTexts![index].capitalize as String,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize017.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorDarkGrey
                    : AppColors.colorGreydark,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(width: 0.002.w),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                  color: isSpec
                      ? lightMode
                      ? Colors.grey[400]
                      : Colors.grey[700]
                      : Colors.transparent),
              child: Text(
                widget.secondaryTexts![index].contains('AM') ||
                    widget.secondaryTexts![index].contains('PM')
                    ? widget.secondaryTexts![index].toUpperCase()
                    : widget.secondaryTexts![index].contains('@')
                    ? widget.secondaryTexts![index]
                    : widget.secondaryTexts![index].capitalize as String,
                maxLines: 14,
                overflow: TextOverflow.ellipsis,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize017.h,
                  color: themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorBlack
                      : AppColors.colorWhiteDark,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoWrappedItem(int index) {
    var lightMode = Theme.of(context).brightness == Brightness.light;

    // Get raw data
    String rawData = widget.secondaryTexts![index];

    // ✅ FIXED: Check if data is null, empty, or just "-"
    if (rawData == '-' || rawData.trim().isEmpty || rawData.trim() == '-') {
      // Show inline dash instead of wrapped containers
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.customIcons != null && index < widget.customIcons!.length)
              Center(
                child: SvgPicture.asset(
                  widget.customIcons![index],
                  height: 20.h,
                  width: 20.w,
                  fit: BoxFit.fill,
                ),
              ),
            SizedBox(width: 0.004.h),
            if (widget.personalInfoTexts != null &&
                index < widget.personalInfoTexts!.length)
              Text(
                widget.personalInfoTexts![index].capitalize as String,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize017.h,
                  color: themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorDarkGrey
                      : AppColors.colorGreydark,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: 0.002.w),
            Text(
              '-',
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize017.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Split the comma-separated string into individual items
    List<String> items = rawData.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty && e != '-').toList();

    // ✅ FIXED: If no valid items after filtering, show dash
    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 0.01.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.customIcons != null && index < widget.customIcons!.length)
              Center(
                child: SvgPicture.asset(
                  widget.customIcons![index],
                  height: 20.h,
                  width: 20.w,
                  fit: BoxFit.fill,
                ),
              ),
            SizedBox(width: 0.004.h),
            if (widget.personalInfoTexts != null &&
                index < widget.personalInfoTexts!.length)
              Text(
                widget.personalInfoTexts![index].capitalize as String,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: FontConstants.fontSize017.h,
                  color: themeController.currentTheme == AppColors.lightTheme
                      ? AppColors.colorDarkGrey
                      : AppColors.colorGreydark,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            SizedBox(width: 0.002.w),
            Text(
              '-',
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize017.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    // Show wrapped containers for valid data
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.01.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label (icon + text)
          Row(
            children: [
              if (widget.customIcons != null && index < widget.customIcons!.length)
                Center(
                  child: SvgPicture.asset(
                    widget.customIcons![index],
                    height: 20.h,
                    width: 20.w,
                    fit: BoxFit.fill,
                  ),
                ),
              SizedBox(width: 0.004.h),
              if (widget.personalInfoTexts != null &&
                  index < widget.personalInfoTexts!.length)
                Text(
                  widget.personalInfoTexts![index].capitalize as String,
                  style: AppFontStyle.cairoRegularStyle.copyWith(
                    fontSize: FontConstants.fontSize017.h,
                    color: themeController.currentTheme == AppColors.lightTheme
                        ? AppColors.colorDarkGrey
                        : AppColors.colorGreydark,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          SizedBox(width: 0.002.w),
          // Wrapped containers with horizontal scroll
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: items.map((item) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: lightMode ? Colors.grey[300] : Colors.grey[700],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      item.capitalize ?? item,
                      style: AppFontStyle.cairoRegularStyle.copyWith(
                        fontSize: FontConstants.fontSize017.h,
                        color: themeController.currentTheme == AppColors.lightTheme
                            ? AppColors.colorBlack
                            : AppColors.colorWhiteDark,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowContent(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.005.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (widget.customIcons != null && index < widget.customIcons!.length)
            SvgPicture.asset(
              widget.customIcons![index],
              height: 0.02.h,
            ),
          SizedBox(width: 0.01.h),
          if (widget.personalInfoTexts != null &&
              index < widget.personalInfoTexts!.length)
            Text(
              widget.personalInfoTexts![index].capitalize as String,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize015.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorDarkGrey
                    : AppColors.colorGreydark,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
          SizedBox(width: 0.01.w),
          Flexible(
            child: Text(
              widget.secondaryTexts![index].contains('AM') ||
                  widget.secondaryTexts![index].contains('PM')
                  ? widget.secondaryTexts![index].toUpperCase()
                  : widget.secondaryTexts![index].contains('@')
                  ? widget.secondaryTexts![index]
                  : widget.secondaryTexts![index].capitalize as String,
              maxLines: 14,
              overflow: TextOverflow.ellipsis,
              style: AppFontStyle.cairoRegularStyle.copyWith(
                fontSize: FontConstants.fontSize015.h,
                color: themeController.currentTheme == AppColors.lightTheme
                    ? AppColors.colorBlack
                    : AppColors.colorWhiteDark,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}