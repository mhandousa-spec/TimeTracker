part of 'employee_services.dart';

// Split from employee_services.dart to keep files <700 LOC.

class ServiceCard extends StatelessWidget {
  const ServiceCard({
    required this.title,
    required this.serviceRequestor,
    required this.requestedDate,
    required this.durationServices,
    required this.status,
    required this.localizedStatus,
    required this.department,
    required this.jobTitle,
    super.key,
  });

  final String title;
  final String serviceRequestor;
  final String requestedDate;
  final String durationServices;
  final String status;
  final String localizedStatus;
  final String department;
  final String jobTitle;

  Color _getBorderColor(String state) {
    switch (state.toLowerCase()) {
      case 'pending':       return AppColors.pending;
      case 'done':
      case 'approved':      return AppColors.lightGreen;
      case 'rejected':      return AppColors.red!;
      case 'cancel':        return AppColors.darkRed!;
      case 'inprogress':    return AppColors.secondaryPrimary;
      case 'breached sla':  return AppColors.block;
      default:              return AppColors.lightGrey!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 313.sp,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppColors.white
            : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.sp, vertical: 15.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50.sp, height: 50.sp,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.secondaryButton
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons_assets/services_assets/headset_support.svg",
                      width: 24.sp, height: 24.sp, fit: BoxFit.scaleDown,
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                      semanticsLabel: 'Service Icon',
                    ),
                  ),
                ),
                SizedBox(width: 8.sp),
                // ✅ FIX: Expanded prevents overflow on any screen size
                Expanded(
                  child: Text(
                    FormatHelper.capitalize(title),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            textCorner(image: "assets/icons_assets/roles_assets/calendar.svg",
                label: "${S.of(context).requestDate}: ",
                content: requestedDate, context: context),
            SizedBox(height: 11.sp),
            textCorner(image: "assets/icons_assets/main_icons_assets/person_outline.svg",
                label: "${S.of(context).serviceRequester}: ",
                content: serviceRequestor, context: context),
            SizedBox(height: 11.sp),
            textCorner(image: "assets/icons_assets/main_icons_assets/Case.svg",
                label: "${S.of(context).department}: ",
                content: department, context: context),
            SizedBox(height: 11.sp),
            textCorner(image: "assets/icons_assets/main_icons_assets/Case.svg",
                label: "${S.of(context).jobTitle}: ",
                content: jobTitle, context: context),
            SizedBox(height: 11.sp),
            textCorner(image: "assets/icons_assets/services_assets/clock_dashed.svg",
                label: "${S.of(context).durationOfService}: ",
                content: durationServices, context: context),
            SizedBox(height: 11.sp),
            Row(
              children: [
                SvgPicture.asset("assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                    width: 12.sp, height: 12.sp, fit: BoxFit.fill,
                    semanticsLabel: 'Status Icon'),
                SizedBox(width: 8.sp),
                Text(
                  FormatHelper.capitalize("${S.of(context).Status}: "),
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.secondaryText
                        : AppColors.grey,
                  ),
                ),
                SizedBox(width: 4.sp),
                Text(
                  FormatHelper.capitalize(localizedStatus),
                  style: StyleText.fontSize14Weight400.copyWith(
                      color: _getBorderColor(status)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CustomItemCard
// ═══════════════════════════════════════════════════════════════════════════════
class CustomItemCard extends StatelessWidget {
  const CustomItemCard({
    super.key,
    required this.iconLabel,
    required this.textLabel,
    this.imagePerson,
    required this.data,
  });

  final String iconLabel;
  final String textLabel;
  final String? imagePerson;
  final String data;

  @override
  Widget build(BuildContext context) {
    // CHANGED 31/8/2026 — entry animation removed (see the note on the
    // details page). This row is a label inside an already-visible section;
    // sliding it in bought nothing and could leave it off-screen.
    return Row(
      children: [
        SvgPicture.asset(iconLabel, semanticsLabel: 'Icon'),
        SizedBox(width: 6.w),
        Text(textLabel,
            style: StyleText.fontSize14Weight500.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.secondaryText
                  : AppColors.grey,
            )),
        if (imagePerson != null) ...[
          SizedBox(width: 6.w),
          Image(image: appImageProvider(imagePerson!)),
          SizedBox(width: 4.w),
        ],
        SizedBox(width: 3.w),
        Text(data,
            style: StyleText.fontSize14Weight400.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.blackButton
                  : AppColors.white,
            )),
      ],
    );
  }
}
