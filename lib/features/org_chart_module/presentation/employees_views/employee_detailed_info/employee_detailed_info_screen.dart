import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_font_size.dart';
import 'package:knowticed_plus/core/theme/theme_controller.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/settings_permissions_sections.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/settings/social_permissions.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employee_detailed_info/employee_info_widget.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employee_detailed_info/employee_work_info_widget.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';


import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/controller/employee_helper.dart';
import 'package:knowticed_plus/core/custom/33-custom_haptic.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/org_chart_module/data/repository/employees_repository.dart';
import 'package:knowticed_plus/core/helper/message_module/main_helper/messaging_interface_implementation.dart';

/// Date Created :3/Dec/2023
/// Developer Name : Bassem Mohamed
/// App Version : Version 2
/// Date of Last Edit :14/Dec/2023
/// Objectives: this screen is responsible for showing the each employee profile, and in this screen, the hr can view his
/// personal info, performance, attendance rate, and the permissions

class EmployeeDetailedInfo extends StatefulWidget {
  final int? index;
  final double reviewRating;
  final NewEmployeeModelHistory employee;

  EmployeeDetailedInfo(
      {this.index, this.reviewRating = 5, required this.employee, Key? key})
      : super(key: key);

  @override
  EmployeeDetailedInfoState createState() => EmployeeDetailedInfoState();
}

class EmployeeDetailedInfoState extends State<EmployeeDetailedInfo> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  int selectedContainerIndexEmployee = 0;

  /// The record this screen renders.
  ///
  /// Seeded from the list the org chart already had, then replaced by a fresh
  /// server read — see [_refreshEmployee].
  late NewEmployeeModelHistory _employee = widget.employee;

  final EmployeesRepository _employeesRepository = EmployeesRepository();

  @override
  void initState() {
    selectedContainerIndexEmployee = widget.index ?? 0;
    super.initState();
    _refreshEmployee();
  }

  /// Function Name: [_refreshEmployee]
  ///
  /// Purpose: Re-read this employee from the server when the screen opens.
  ///
  /// Added 22/8/2026 for "when I add info it doesn't show here". The employee
  /// handed to this screen comes out of the org chart's cached list, which is
  /// loaded once and never invalidated — so education, skills and hobbies
  /// saved from the Social settings screen were not in it. The cached copy is
  /// still rendered immediately (no spinner, no regression in perceived
  /// speed); the fresh one simply replaces it a moment later.
  ///
  /// A failed refresh is logged and otherwise ignored: the cached record is
  /// still a usable profile, and an error banner over a screen that looks
  /// fine would be worse than slightly old data.
  Future<void> _refreshEmployee() async {
    final String employeeId = widget.employee.id ?? '';
    if (employeeId.isEmpty) return;

    final result = await _employeesRepository.getEmployeeById(employeeId);

    if (!mounted) return;

    result.fold(
      (failure) => debugPrint(
          'EmployeeDetailedInfo: could not refresh $employeeId — '
          '${failure.errMessage}'),
      (fresh) => setState(() => _employee = fresh),
    );
  }

  /// Bug report #8: the Chat button was an empty TODO. Opens the one-to-one
  /// chat with this employee (email = messaging user id) and prints every
  /// step to the terminal so a failure says WHY.
  Future<void> _openChat() async {
    final String email = _employee.email?.lastOrNull?.trim() ?? '';
    debugPrint('[EmployeeInfo Chat] tapped — employeeId=${_employee.id}, '
        'email="$email"');
    if (email.isEmpty) {
      debugPrint('[EmployeeInfo Chat] ✗ employee has no email, cannot open chat');
      return;
    }
    try {
      final OpenChatResult result = await MessagingInterfaceImplementation()
          .tryOpenChatWithUser(context: context, userEmail: email);
      debugPrint('[EmployeeInfo Chat] result = ${result.name}');
      if (mounted) await showOpenChatFailure(context, result);
    } catch (e, st) {
      debugPrint('[EmployeeInfo Chat] ✗ exception: $e\n$st');
    }
  }

  void setSelectedContainerIndexEmployee(int index) {
    setState(() {
      selectedContainerIndexEmployee = index;
    });
  }

  bool notificationEnabled = false;
  bool switchValue = false;

  /// Function Name: [_canSee]
  ///
  /// Purpose: Whether the signed-in employee's role grants [permission] under
  ///          Settings > Social Permissions.
  ///
  /// This is the VIEWER's role, not the viewed employee's — it answers "may I
  /// see this about a colleague", which is what the Social Permissions card on
  /// Edit Role Settings Permissions controls.
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

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    final orientation = MediaQuery.of(context).orientation;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: _buildTabletLayout(orientation, themeController),
      ),
    );
  }

  Widget _buildTabletLayout(
      Orientation orientation, ThemeController themeController)
  {
    final bool isArabic = Directionality.of(context) == TextDirection.rtl;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;
    bool isLargeTablet = MediaQuery.of(context).size.shortestSide >= 1024;

    TextStyle breadCrumbsTextStyle = AppFontStyle.cairoRegularStyle.copyWith(
      fontSize: isVertical
          ? Get.locale.toString().contains("en")
          ? FontConstants.fontSize015.h
          : FontConstants.fontSize011.h
          : FontConstants.fontSize020.h,
      fontWeight: FontWeight.w600,
      overflow: TextOverflow.ellipsis,
      color: Theme.of(context).colorScheme.inverseSurface,
      height: isVertical
          ? Get.locale.toString().contains("en")
          ? 1.3
          : 1
          : 1.4,
    );

    return Column(
      children: [

        Row(
          children: [
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).organizationChart,
                style: StyleText.fontSize22Weight600.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white),
              ),
            ),
            Transform.rotate(
              angle: isArabic ? 3.1416 : 0,
              child: Padding(
                padding: isArabic
                    ? EdgeInsets.only(bottom: 7.sp)
                    : EdgeInsets.only(top: 3.sp),
                child: SvgPicture.asset(
                  'assets/icons_assets/main_icons_assets/images_arrow.svg',
                  width: 30.sp,
                  height: 30.sp,
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.blackButton
                      : AppColors.whiteShadow,
                ),
              ),
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Text(
                S.of(context).employeeInfo,
                style: StyleText.fontSize22Weight600.copyWith(
                    color: lightMode
                        ? AppColors.blackButton
                        : AppColors.white),
              ),
            )
          ],
        ),
        SizedBox(height: 30.sp),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: isVertical ? 2 : 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 0.01.h),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 0.02.h),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.015.w),
                              child: EmployeeInfoWidget(
                                employeeModel: _employee,
                                image: _employee.photo?.lastOrNull,
                                firstName:
                                Get.locale.toString().contains('en')
                                    ? _employee.firstName!.last!
                                    : _employee.firstNameInArabic!.last!,
                                lastName: Get.locale.toString().contains('en')
                                    ? _employee.lastName!.last!
                                    : _employee.lastNameInArabic!.last!,
                                profession: EmployeeHelper.getEmployeeJobTitle(
                                    employee: _employee),
                                reviewRating: widget.reviewRating,
                                // Blanked rather than hidden: EmployeeInfoWidget
                                // takes these as plain values, so withholding
                                // them is how the permission is enforced here.
                                email: _canSee(SocialPermissions
                                        .shareEmailsAndSocialDataInBio)
                                    ? _employee.email!.last!
                                    : '',
                                bio: _canSee(SocialPermissions
                                        .shareSocialInformation)
                                    ? _employee.bio?.lastOrNull
                                    : null,
                                phone: _canSee(SocialPermissions
                                        .shareCellphonesInSocialDataInBio)
                                    ? "${_employee.mobilePhone?.lastOrNull ?? ""}"
                                    : '',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 0.01.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              customButtonWithSvg(
                                space: ContextExtension(context).isPhone ? 0.sp : 8.sp,
                                colorBorder: Colors.transparent,
                                heightImage: 20.h,
                                widthImage: 20.w,
                                textStyle: StyleText.fontSize16Weight500.copyWith(
                                  color: AppColors.textButton
                                ),
                                  title: S.current.chat,
                                  function: () {
                                    hapticController.triggerHapticFeedback(
                                        vibration: VibrateType.mediumImpact,
                                        hapticFeedback:
                                        HapticFeedback.mediumImpact);
                                    _openChat();
                                  },
                                  color: AppColors.primary,
                                  width: 150.w,
                                  height: 38.h,
                                  radius: 4.r,
                                  image: 'assets/icons_assets/main_icons_assets/roles_icons_Messages.svg')
                            ],
                          ),
                        ),
                        SizedBox(height: 9.sp),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                  width: 15.w),
              Expanded(
                flex: 3,
                child: Container(

                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 0.0.h,
                      right: 0.02.w,
                      left: 0.02.w,
                  //    bottom: 0.09.h,
                    ),
                    child: EmployeeWorkInfoScreen(employee: _employee),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
