/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_methods4.dart
/// Purpose: Declares `EmployeeDetailsMethods4`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

part of '../pages/employee_details.dart';

extension EmployeeDetailsMethods4 on _RoleEmployeeDetailsPageState {
  /// Function Name: [_openMessages]
  ///
  /// Purpose: The header's Chat button — takes the admin to the Messages
  /// module.
  ///
  /// ADDED 28/8/2026.
  ///
  /// ⚠️ This opens the Messages MODULE, not this employee's thread. Opening one
  /// person's chat needs `ConnectionsCubit` + `SingleChatCubit`, and neither is
  /// in this screen's widget tree — they are provided only inside the messaging
  /// module itself, so `context.read` for either would throw
  /// ProviderNotFoundException here. (The org chart's equivalent button is
  /// still an unimplemented stub for the same reason — see
  /// `employee_detailed_info_screen.dart`.) Wiring the thread directly is a
  /// follow-up: provide those two cubits here, build a
  /// `SingleConnectionEntity` for the employee, then
  /// `createNewConnection` + `selectConnection`.
  ///
  /// Navigation goes through [NotificationRouting.openInShell], which is the
  /// hardened path the notification inbox already uses: on the desktop/tablet
  /// shell it selects the drawer index so the sidebar and app bar survive, and
  /// on mobile it pushes the page instead. `drawerCubit()` is used rather than
  /// `context.read<AppDrawerCubit>()` for the reason documented there — the
  /// drawer cubit is registered through Get, never placed in the widget tree.
  void _openMessages(BuildContext context) {
    final drawer = NotificationRouting.drawerCubit();
    final int messagesIndex =
        drawer.allowedDrawerModules.indexOf(Modules.messages);

    // Messages is not licensed for this company, or not granted to this user.
    if (messagesIndex < 0) return;

    NotificationRouting.openInShell(
      context,
      shellIndex: messagesIndex,
      pageBuilder: () => Modules.messages.widget,
    );
  }

  Widget _buildEmployeeHeader(
      bool lightMode,
      bool isArabic,
      bool isMobile,
      bool isTablet,
      bool isLandscape,
      ) {
    final fullName = isArabic
        ? "${currentEmployeeEntity?.firstNameInArabic ?? ''} ${currentEmployeeEntity?.middleNameInArabic ?? ''} ${currentEmployeeEntity?.lastNameInArabic ?? ''}"
        .trim()
        : "${currentEmployeeEntity?.firstName ?? ''} ${currentEmployeeEntity?.middleName ?? ''} ${currentEmployeeEntity?.lastName ?? ''}"
        .trim();

    final title = isArabic
        ? currentEmployeeEntity?.titleInArabic ?? '-'
        : currentEmployeeEntity?.title ?? '-';

    final departmentName = currentEmployeeEntity?.departmentId != null
        ? employeeController.departmentController
        .getDepartmentName(currentEmployeeEntity!.departmentId!, !isArabic)
        : '-';

    final email = currentEmployeeEntity?.email ?? '-';

    String phoneNumber = '-';
    if (currentEmployeeEntity?.mobilePhone != null) {
      final countryCode =
          currentEmployeeEntity!.mobilePhone!.countryCode ?? '';
      final phone = currentEmployeeEntity!.mobilePhone!.phone ?? '';
      final cleanCC = countryCode
          .toString()
          .replaceAll('[', '')
          .replaceAll(']', '')
          .trim();
      final cleanPhone =
      phone.toString().replaceAll('[', '').replaceAll(']', '').trim();
      if (cleanCC.isNotEmpty && cleanPhone.isNotEmpty) {
        phoneNumber = '+$cleanCC $cleanPhone';
      } else if (cleanPhone.isNotEmpty) {
        phoneNumber = cleanPhone;
      }
    }

    final gender = currentEmployeeEntity?.gender ?? 'male';

    if (isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22.5.sp,
                    backgroundColor: AppColors.transparent,
                    child: ClipOval(child: _buildEmployeeImage(gender)),
                  ),
                  SizedBox(width: 5.sp),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isEmpty
                              ? 'Unknown'
                              : FormatHelper.capitalize(fullName),
                          style: StyleText.fontSize14Weight500
                              .copyWith(color: AppColors.text),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.sp),
                        Text(
                          FormatHelper.capitalize(departmentName),
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.sp),
                        Text(
                          FormatHelper.capitalize(title),
                          style: StyleText.fontSize12Weight500
                              .copyWith(color: AppColors.secondaryText),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  customButtonWithSvg(
                    title: "",
                    // Was an empty callback — the icon was already here on
                    // mobile but did nothing. Same destination as the desktop
                    // button added 28/8/2026.
                    function: () => _openMessages(context),
                    color: AppColors.primary,
                    textStyle: StyleText.fontSize14Weight500
                        .copyWith(color: AppColors.textButton),
                    heightImage: 16.sp,
                    widthImage: 16.sp,
                    svgColor: AppColors.textButton,
                    image: "assets/icons_assets/main_icons_assets/chat_bubble_dots.svg",
                    space: isMobile ? 0.sp : 8.sp,
                    colorBorder: AppColors.transparent,),
                ],
              ),
              SizedBox(height: 10.sp),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      itemTextProduct(
                        value: phoneNumber,
                        label: "${S.of(context).phoneNumber}: ",
                        image: "assets/icons_assets/services_assets/phone_handset.svg",
                      ),
                      SizedBox(height: 10.sp),
                      itemTextProduct(
                        value: email,
                        label: "${S.of(context).email}: ",
                        image: "assets/icons_assets/main_icons_assets/email_envelope.svg",
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (isTablet && !isLandscape) {
      return Container(
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: 15.sp,
            bottom: 15.sp,
            left: isArabic ? 15.sp : 0,
            right: isArabic ? 0 : 15.sp,
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.sp,
                    backgroundColor: AppColors.transparent,
                    child: ClipOval(
                        child: _buildEmployeeImage(gender, size: 80.sp)),
                  ),
                  SizedBox(width: 10.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName.isEmpty ? 'Unknown' : fullName,
                        style: StyleText.fontSize16Weight500.copyWith(
                          color: lightMode
                              ? AppColors.blackButton
                              : AppColors.white,
                        ),
                      ),
                      SizedBox(height: 10.sp),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemTextProduct(
                                  value: title,
                                  label: "Title: ",
                                  image: "assets/icons_assets/main_icons_assets/doc_file_blue.svg"),
                              SizedBox(height: 10.sp),
                              itemTextProduct(
                                  value: email,
                                  label: "Email: ",
                                  image: "assets/icons_assets/main_icons_assets/email_envelope.svg"),
                            ],
                          ),
                          SizedBox(width: 38.sp),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemTextProduct(
                                  value: departmentName,
                                  label: "Department: ",
                                  image: "assets/icons_assets/services_assets/department_hierarchy_people.svg"),
                              SizedBox(height: 10.sp),
                              itemTextProduct(
                                  value: phoneNumber,
                                  label: "Phone Number: ",
                                  image: "assets/icons_assets/services_assets/phone_handset.svg"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.sp),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40.sp,
                backgroundColor: AppColors.transparent,
                child:
                ClipOval(child: _buildEmployeeImage(gender, size: 80.sp)),
              ),
              SizedBox(width: 10.sp),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FormatHelper.capitalize(
                        fullName.isEmpty ? 'Unknown' : fullName),
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: lightMode
                          ? AppColors.blackButton
                          : AppColors.white,
                    ),
                  ),
                  SizedBox(height: 10.sp),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          itemTextProduct(
                              value: title,
                              label: "${S.of(context).title}: ",
                              image: "assets/icons_assets/main_icons_assets/Case.svg"),
                          SizedBox(height: 10.sp),
                          itemTextProduct(
                              value: email,
                              label: "${S.of(context).email}: ",
                              image: "assets/icons_assets/main_icons_assets/email_envelope.svg"),
                        ],
                      ),
                      SizedBox(width: 38.sp),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          itemTextProduct(
                              value: departmentName,
                              label: "${S.of(context).department}: ",
                              image: "assets/icons_assets/main_icons_assets/hierarchy_nodes.svg"),
                          SizedBox(height: 10.sp),
                          itemTextProduct(
                              value: phoneNumber,
                              label: "${S.of(context).phoneNumber}: ",
                              image: "assets/icons_assets/services_assets/phone_handset.svg"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // ── Chat ──────────────────────────────────────────────────
              // Sits in the space the Spacer opens up — the empty side of the
              // header card. See [_openMessages] for what it can and cannot do.
              customButtonWithSvg(
                title: S.of(context).chat,
                function: () => _openMessages(context),
                color: AppColors.primary,
                textStyle: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.textButton),
                svgColor: AppColors.textButton,
                image:
                    "assets/icons_assets/main_icons_assets/chat_bubble_dots.svg",
                widthImage: 16.sp,
                heightImage: 16.sp,
                space: 8.sp,
                radius: 4.r,
                colorBorder: AppColors.transparent,
              ),
            ],
          ),
        ),
      );
    }
  }
  Widget _buildEmployeeImage(String gender, {double? size}) {
    final imageSize = size ?? 45.sp;

    if (currentEmployeeEntity?.photo != null &&
        currentEmployeeEntity!.photo!.isNotEmpty &&
        currentEmployeeEntity!.photo != '[]') {
      if (currentEmployeeEntity!.photo!.contains('http')) {
        return Image.network(
          currentEmployeeEntity!.photo!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAvatar(gender, imageSize),
        );
      } else {
        return Image.asset(
          currentEmployeeEntity!.photo!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultAvatar(gender, imageSize),
        );
      }
    }

    return _buildDefaultAvatar(gender, imageSize);
  }
  Widget _buildDefaultAvatar(String gender, double size) {
    return CustomSvgImage(assetPath: 
      gender.toLowerCase() == 'female'
          ? 'assets/icons_assets/main_icons_assets/female_avatar.svg'
          : 'assets/icons_assets/main_icons_assets/male_avatar.svg',
      semanticsLabel: 'Gender Icon',
      fit: BoxFit.cover,
      width: size,
      height: size,
    );
  }
}
