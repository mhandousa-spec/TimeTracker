import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/custom/46-custom_image_picker.dart';
import 'package:knowticed_plus/features/org_chart_module/presentation/employees_views/employee_views_mobile/employee_personal_info.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/data/models/role_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';




class EmployeeInfoWidget extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String profession;
  final String email;
  final String? bio;
  final String? image;
  final String? phone;
  final double reviewRating;
  final  NewEmployeeModelHistory? employeeModel;

  EmployeeInfoWidget({
    required this.firstName,
    required this.lastName,
    required this.profession,
    required this.email,
    required this.bio,
    required this.reviewRating,
    required this.image,
    required this.phone,
    required this.employeeModel,
  });

  @override
  State<EmployeeInfoWidget> createState() => _EmployeeInfoWidgetState();
}

class _EmployeeInfoWidgetState extends State<EmployeeInfoWidget> {
  Future<void> _sendEmail(String email) async {
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunch(_emailLaunchUri.toString())) {
      await launch(_emailLaunchUri.toString());
    } else {
      throw 'Could not launch $_emailLaunchUri';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri _phoneCallUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunch(_phoneCallUri.toString())) {
      await launch(_phoneCallUri.toString());
    } else {
      throw 'Could not launch $_phoneCallUri';
    }
  }

  // NOTE: this used to hold `RoleController` + `UsersAccessController` (GetX)
  // and call `usersAccessController.getUserAcess(email)` from initState.
  //
  // Neither was doing anything: `addRoleController` and `accessTypeEmployee`
  // were declared but never read, and `getUserAcess()` in the source app has
  // its body commented out — it returns an unassigned field, so the awaited
  // call plus setState() was a no-op rebuild.
  //
  // skeleton_app's equivalents are cubits:
  //   roles/r1_role_management/presentation/controller/role_cubit.dart  (RoleCubit)
  //   roles/r3_user_access/presentation/controller/user_access_cubit.dart (UserAccessCubit)
  // UserAccessCubit has no per-employee lookup — it loads the full list via
  // getAccountsStatusEntities(). Wire that in here if you need the real
  // access type for this employee.

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Center(
      child: Container(
        color: AppColors.card,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(width: 2, color: AppColors.lightPrimary),
              ),
              padding: EdgeInsets.all(0.007.h),
              child:CircleAvatar(
                radius: isVertical ? 40 : 40,
                backgroundColor: Colors.transparent,
                backgroundImage:
                appImageProvider('assets/icons_assets/main_icons_assets/assets_male.svg'),
              )
                  //widget.image == null
                  // ? CircleAvatar(
                  //     radius: isVertical ? 80 : 80.0,
                  //     backgroundColor: Colors.transparent,
                  //     backgroundImage:
                  //         appImageProvider('assets/icons_assets/main_icons_assets/assets_male.svg'),
                  //   )
                  // : CircleAvatar(
                  //     radius: isVertical ? 50 : 80.0,
                  //     backgroundImage: NetworkImage(widget.image!),
                  //   ),
            ),
            // Bug report p.10 ("increase padding"): these gaps were 0.02.h /
            // 0.01.h — ScreenUtil scales the NUMBER, so 0.01.h is a fraction
            // of a pixel and the avatar, name, title and bio touched.
            SizedBox(height: 12.sp),
            Text(
              '${widget.firstName} ${widget.lastName}'.capitalize as String,
              textAlign: TextAlign.center,
              // Bug report #8: app type scale (StyleText) instead of the
              // old cairo + FontConstants.h sizes.
              style: StyleText.fontSize20Weight600
                  .copyWith(color: AppColors.text, height: 1.2),
            ),
            SizedBox(height: 8.sp),
            Text(
              (capitalize(widget.profession) as String),
              textAlign: TextAlign.center,
              style: StyleText.fontSize16Weight400
                  .copyWith(color: AppColors.text, height: 1.2),
            ),
            SizedBox(height: 12.sp),
            Container(
              height: 320.h, // your fixed height
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(), // optional
                child: Text(
                  widget.bio != null && widget.bio!.isNotEmpty
                      ? (capitalize(widget.bio!) as String)
                      : "",
                  textAlign: TextAlign.center,
                  style: StyleText.fontSize14Weight400
                      .copyWith(color: AppColors.text, height: 1.2),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
