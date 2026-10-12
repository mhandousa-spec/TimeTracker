// ******************* FILE INFO *******************
// Extracted from approval_request_details.dart to keep files under 600 lines.
// Contains standalone presentation widgets used by the approval details screen.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

class CustomRowDetails extends StatelessWidget {
  const CustomRowDetails({
    super.key,
    required this.image,
    required this.title,
    required this.data,
    this.imagePerson,
  });

  final String image;
  final String title;
  final String data;
  final String? imagePerson;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(image,
            semanticsLabel: 'Icon',
            width: 20.w,
            height: 20.h,
            color: AppColors.secondaryText.withOpacity(.5)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: StyleText.fontSize14Weight400
              .copyWith(color: AppColors.secondaryText.withOpacity(.5)),
        ),
        if (imagePerson != null)
          Row(
            children: [
              ClipOval(
                child: SvgPicture.asset(
                  imagePerson!,
                  semanticsLabel: 'Icon',
                  width: 32.w,
                  height: 32.h,
                ),
              ),
              SizedBox(width: 5.w),
            ],
          ),
        Text(
          data,
          style: StyleText.fontSize14Weight400.copyWith(color: AppColors.text),
        ),
      ],
    );
  }
}

extension ApprovalEmployeeCopyWith on EmployeeEntityModell {
  EmployeeEntityModell copyWith({
    String? state,
    String? firstNameInArabic,
    String? lastNameInArabic,
    String? titleInArabic,
  }) {
    return EmployeeEntityModell(
      id: id,
      email: email,
      title: title,
      titleInArabic: titleInArabic ?? this.titleInArabic,
      gender: gender,
      lastName: lastName,
      lastNameInArabic: lastNameInArabic ?? this.lastNameInArabic,
      firstName: firstName,
      firstNameInArabic: firstNameInArabic ?? this.firstNameInArabic,
      state: state ?? this.state,
    );
  }
}

class ApprovalButtons extends StatelessWidget {
  final String? myState;
  final String? documentState;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ApprovalButtons({
    Key? key,
    required this.myState,
    this.documentState,
    required this.onApprove,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final docState = documentState?.toLowerCase()?.trim() ?? '';

    if (docState == 'cancel' || docState.contains('cancel')) {
      return _statusContainer(
        context,
        S.of(context).Canceled,
        AppColors.red,
        'cansel',
      );
    }

    if (docState == 'rejected') {
      return _statusContainer(
        context,
        S.of(context).Rejected,
        AppColors.red,
        'reject',
      );
    }

    if (docState == 'approved') {
      return _statusContainer(
        context,
        S.of(context).Approved,
        AppColors.lightGreen,
        'approved',
      );
    }

    final isApproved = myState?.toLowerCase() == 'approved';
    final isRejected = myState?.toLowerCase() == 'rejected';
    final isPending = myState?.toLowerCase() == 'pending';

    if (isPending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _actionButton(
            img: "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
            context: context,
            color: AppColors.red,
            label: S.of(context).Reject,
            icon: Icons.block_flipped,
            onTap: () {
              HapticController.high(); // reject
              onReject();
            },
          ),
          SizedBox(width: 7.sp),
          _actionButton(
            img: "assets/icons_assets/main_icons_assets/status_approved_check_green.svg",
            context: context,
            color: AppColors.lightGreen,
            label: S.of(context).Approve,
            icon: Icons.check_circle,
            onTap: () {
              HapticController.medium(); // approve
              onApprove();
            },
          ),
        ],
      );
    } else if (isApproved) {
      return _statusContainer(
        context,
        S.of(context).Approved,
        AppColors.lightGreen,
        'approved',
      );
    } else if (isRejected) {
      return _statusContainer(
        context,
        S.of(context).Rejected,
        AppColors.red,
        'reject',
      );
    } else {
      return SizedBox();
    }
  }

  Widget _actionButton({
    required BuildContext context,
    required Color color,
    required String img,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    var isMobile = ContextExtension(context).isPhone;
    bool isTabletLandscape(BuildContext context) {
      final size = MediaQuery.of(context).size;
      final isLandscape =
          MediaQuery.of(context).orientation == Orientation.landscape;
      return size.width >= 600 && isLandscape;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMobile
            ? 150.sp
            : !isTabletLandscape(context)
            ? 155.sp
            : 200.sp,
        height: 38.sp,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              img,
              fit: BoxFit.scaleDown,
              height: 24.sp,
              width: 24.sp,
              semanticsLabel: 'Action Icon',
            ),
            SizedBox(width: 8.sp),
            Text(
              label,
              style: StyleText.fontSize16Weight600.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusContainer(
      BuildContext context,
      String label,
      Color color,
      String iconType,
      ) {
    final isMobile = ContextExtension(context).isPhone;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: isMobile ? 312.sp : 250.sp,
          height: 38.sp,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.white
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getStatusIcon(iconType),
                SizedBox(width: 8.sp),
                Text(
                  label,
                  style: StyleText.fontSize16Weight600.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _getStatusIcon(String iconType) {
    switch (iconType.toLowerCase()) {
      case 'approved':
        return SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/status_approved_check_green.svg",
          width: 24.sp,
          height: 24.sp,
          fit: BoxFit.scaleDown,
          semanticsLabel: 'Approved Icon',
        );
      case 'reject':
        return SvgPicture.asset(
          "assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg",
          width: 24.sp,
          height: 24.sp,
          fit: BoxFit.scaleDown,
          semanticsLabel: 'Rejected Icon',
        );
      case 'cansel':
        return SvgPicture.asset(
          "assets/icons_assets/services_assets/cancel_x_circle_red.svg",
          width: 24.sp,
          height: 24.sp,
          fit: BoxFit.scaleDown,
          semanticsLabel: 'Cancelled Icon',
        );
      default:
        return SizedBox();
    }
  }
}
