/// Module: roles / r2_user_management / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: employee_details_methods2.dart
/// Purpose: Declares `EmployeeDetailsMethods2`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Localized the remaining hardcoded English messages.

part of '../pages/employee_details.dart';

extension EmployeeDetailsMethods2 on _RoleEmployeeDetailsPageState {
  Widget _buildContent() {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isTablet = ContextExtension(context).isTablet;
    final isMobile = ContextExtension(context).isPhone;
    final isLandscape = ContextExtension(context).isLandscape;

    // FIXED 8/9/2026: the black band across the top of this page. The tree was
    // `SafeArea > SideFrameMasterServices` with no Scaffold, so the status-bar
    // inset SafeArea reserves sat OUTSIDE the Scaffold the frame builds on its
    // phone branch — nothing painted a background behind that strip and it came
    // out black. A Scaffold on the outside paints the whole screen, which is the
    // order every other framed page in the module uses.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
      child: SideFrameMasterServices(
        titleText: S.current.platformControlsAndManagement,
        onFirstTap: () => Navigator.pop(context),
        secondTitle: S.of(context).employeeDetails,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ── Edit / Delete buttons ────────────────────────────────────
              Row(
                children: [
                  const Spacer(),
                  if (AppControllers.employee.isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.editAccess,
                  ))
                    customButtonWithSvg(
                      title: ContextExtension(context).isPhone ? '' : S.of(context).edit,
                      function: () async {
                        final result = await showEditUserAccessDialog(
                          context: context,
                          userPermission: widget.userPermission,
                        );

                        if (result == null || result is! Map<String, dynamic>)
                          return;
                        if (!mounted) return;

                        final nav = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        final userMgmtCubit =
                        context.read<UserManagementAccessCubit>();
                        final currentUserEmail =
                        AppControllers.employee
                            .employeeEntity!
                            .email!;
                        final String failedText =
                            S.of(context).failedToUpdateAccess;
                        String? failure;

                        // Role QA p.9 / p.14: Save went straight to the write
                        // with no confirmation. It is now the shared flow:
                        // confirm → loading → "Access Updated" message.
                        await CustomDialogManager.showDialogFlow(
                          context: context,
                          confirmLottie:
                              'assets/lottie_assets/roles_lottie_assets/Edit Document.json',
                          confirmTitle: S.of(context).editAccess,
                          confirmSubtitle:
                              S.of(context).areYouSureYouWantToSaveTheseChanges,
                          confirmYesText: S.of(context).yes,
                          confirmNoText: S.of(context).no,
                          onConfirm: () async {
                            try {
                              final String selectedRole = result['role'] ?? '';
                              final DateTime accessGranted =
                              result['accessGranted'];
                              final DateTime accessRevoked =
                              result['accessRevoked'];

                              // FIXED 13/8/2026: both of these omitted the locale.
                              // `DateFormat` with no locale uses the *ambient* one,
                              // so with the app in Arabic these wrote
                              // "١٣ أغسطس ٢٠٢٦" into `accessBegin` / `accessEnd`
                              // instead of the "Aug 13, 2026" storage format every
                              // reader expects — `employee_details._formatDate`
                              // parses those back with `DateFormat(fmt, 'en')`, and
                              // `EmployeeController.activateAccount` writes them
                              // with an explicit 'en'. An Arabic-written value fails
                              // every parse branch and falls through to
                              // "return rawDate", which is the mixed/raw dates on
                              // the access-details screens.
                              //
                              // 'en' here is the on-disk format, not a display
                              // choice — do not localize it. Rendering is the
                              // reader's job.
                              final String startDateStr = DateFormat(
                                  Constants.userAccessDateFormat, 'en')
                                  .format(accessGranted);
                              final String endDateStr =
                              DateFormat(Constants.userAccessDateFormat, 'en')
                                  .format(accessRevoked);

                              final updateResult = await userMgmtCubit.repository
                                  .updateUserPermission(
                                employeeId: widget.userPermission.employeeId,
                                currentUserEmail: currentUserEmail,
                                accessName: selectedRole,
                                accessBegin: startDateStr,
                                accessEnd: endDateStr,
                              );

                              if (updateResult.isLeft()) {
                                final errMsg = updateResult.fold(
                                        (l) => l.errMessage, (r) => 'Unknown error');
                                // 9/10/2026 — was `throw Exception(errMsg)`,
                                // which showed "Exception: …" in front of the
                                // user-limit message. Return it as-is.
                                failure = errMsg;
                                return false;
                              }

                              AppControllers.employee
                                  .getAllNewEmployees()
                                  .ignore();
                              try {
                                userMgmtCubit.getUserAccess();
                              } catch (_) {}
                              return true;
                            } catch (e) {
                              failure = e.toString();
                              return false;
                            }
                          },
                          successLottie:
                              'assets/lottie_assets/main_lottie_assets/approved.json',
                          successTitle: S.of(context).accessUpdated,
                          successSubtitle:
                              S.of(context).userAccessUpdatedSuccessfully,
                          onSuccessComplete: () {
                            if (nav.canPop()) nav.pop(true);
                          },
                        );

                        if (failure != null) {
                          messenger.showSnackBar(SnackBar(
                            content: Text('$failedText: $failure'),
                            backgroundColor: AppColors.red,
                            // 9/10/2026 — 3 s was too short to read a
                            // user-limit message.
                            duration: const Duration(seconds: 5),
                          ));
                        }
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      space: ContextExtension(context).isPhone ? 0 : 8.sp,
                      color: AppColors.primary,
                      image: 'assets/icons_assets/main_icons_assets/edit_pencil_square.svg',
                      svgColor: AppColors.textButton,
                      widthImage: 15.sp,
                      heightImage: 15.sp,
                      colorBorder: AppColors.transparent,),

                  if (AppControllers.employee.isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.removeAccess,
                  ))
                    SizedBox(width: 15.sp),

                  if (AppControllers.employee.isHasPermission(
                    module: Modules.roles,
                    section: RolePermissionsSections.userManagement,
                    permission: UserManagement.removeAccess,
                  ))
                    customButtonWithSvg(
                      title: ContextExtension(context).isPhone ? "" : S.of(context).delete,
                      function: () async {
                        await CustomDialogManager.showDialogFlow(
                          context: context,
                          confirmLottie:
                              'assets/lottie_assets/roles_lottie_assets/delete.json',
                          confirmTitle: S.of(context).remove_access,
                          confirmSubtitle:
                              S.of(context).remove_access_confirmation,
                          confirmYesText: S.of(context).yes,
                          confirmNoText: S.of(context).no,
                          onConfirm: () async {
                            if (!mounted) return false;

                            // Role QA p.33: the flow's own loading indicator
                            // covers this now (the extra local spinner is
                            // gone), and a successful removal always returns
                            // true so the "Access Removed" message shows —
                            // the employee list reload no longer runs first.
                            try {
                              final success = await _removeUserAccess(
                                  employeeId: widget.userPermission.employeeId);

                              if (success) {
                                employeeController
                                    .getAllNewEmployees()
                                    .ignore();
                                return true;
                              }

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    // LOCALIZED 25/8/2026: was an English
                                    // literal (and `const`, which a localized
                                    // lookup cannot be).
                                    content: Text(
                                        S.of(context)
                                            .failedToRemoveUserAccessPleaseTryAgain),
                                    backgroundColor: AppColors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                              return false;
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    // LOCALIZED 25/8/2026: was an English
                                    // literal; `e` stays raw.
                                    content: Text(
                                        '${S.of(context).errorOccurred}: ${e.toString()}'),
                                    backgroundColor: AppColors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                              return false;
                            }
                          },
                          successLottie:
                              'assets/lottie_assets/main_lottie_assets/approved.json',
                          successTitle: S.of(context).access_removed,
                          successSubtitle: S.of(context).access_removed_success,
                          onSuccessComplete: () {
                            if (!mounted) return;
                            try {
                              context
                                  .read<UserManagementAccessCubit>()
                                  .getUserAccess();
                            } catch (e, stackTrace) {
                              debugPrint(
                                  'refresh after access removal failed: $e\n$stackTrace');
                            }
                            Navigator.of(context).pop(true);
                          },
                        );
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.white,
                      ),
                      space: ContextExtension(context).isPhone ? 0 : 8.sp,
                      color: AppColors.red,
                      image: "assets/icons_assets/main_icons_assets/icon _trash.svg",
                      svgColor: AppColors.white,
                      widthImage: 15.sp,
                      heightImage: 15.sp,
                      colorBorder: AppColors.transparent,),
                ],
              ),

              // ── Employee Details title ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).employeeDetails,
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.sp),

              _buildEmployeeHeader(
                  lightMode, isArabic, isMobile, isTablet, isLandscape),

              SizedBox(height: 16.sp),

              // ── Info container ────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: AppColors.card,
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.sp),
                  child: Column(
                    children: [
                      // ── Role name + status (Figma 4717:35300) ─────────
                      // ADDED 21/9/2026 — bug report p.4: the card never said
                      // WHICH role these dates and modules belong to.
                      _buildRoleHeader(),
                      SizedBox(height: 15.sp),

                      // ── Access summary boxes ──────────────────────────
                      //
                      // LAYOUT 8/9/2026: all six boxes used to sit in ONE Row.
                      // Each is an `Expanded`, so on a phone that gave every box
                      // about a sixth of the width — roughly 48px — and the two
                      // person boxes (24px avatar + a name) could not fit theirs:
                      // "A RenderFlex overflowed by 11 pixels on the right", with
                      // every label chopped to "Acc es…".
                      //
                      // Phones now follow the design: the two PERSON boxes share
                      // one row, and the four date/count boxes share the row
                      // under it. Tablet and desktop keep the single row of six,
                      // which has the width for it.
                      if (isMobile) ...<Widget>[
                        // HEIGHT 8/9/2026: IntrinsicHeight + stretch so every
                        // box in a row is as tall as the tallest one. Without
                        // it each box hugged its own content, and a two-line
                        // title ("Access Granted") or a wrapped date made its
                        // neighbours look short.
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            // showAvatar: these two boxes name a PERSON, so they
                            // carry the avatar; the date/count boxes do not.
                            AccessGrantorWidget(
                              showAvatar: true,
                              title: S.of(context).access_grantor,
                              name: widget.userPermission
                                      .grantorName(context.isArabic)
                                      .isNotEmpty
                                  ? widget.userPermission
                                      .grantorName(context.isArabic)
                                  : '-',
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              showAvatar: true,
                              title: S.of(context).supervisor,
                              name: _getSupervisorName(),
                            ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.w),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            AccessGrantorWidget(
                              title: S.of(context).access_granted,
                              name: _formatDate(
                                widget.userPermission.startDate,
                                isArabic,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              title: S.of(context).access_revoked,
                              name: _formatDate(
                                widget.userPermission.endDate,
                                isArabic,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              title: S.of(context).last_login,
                              name: _formatDate(
                                currentEmployeeEntity?.lastLogin,
                                isArabic,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              title: S.of(context).total_modules,
                              name: _getTotalModules(),
                            ),
                            ],
                          ),
                        ),
                      ] else
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                            AccessGrantorWidget(
                              showAvatar: true,
                              title: S.of(context).access_grantor,
                              name: widget.userPermission
                                      .grantorName(context.isArabic)
                                      .isNotEmpty
                                  ? widget.userPermission
                                      .grantorName(context.isArabic)
                                  : '-',
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              showAvatar: true,
                              title: S.of(context).supervisor,
                              name: _getSupervisorName(),
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              title: S.of(context).access_granted,
                              name: _formatDate(
                                widget.userPermission.startDate,
                                isArabic,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              title: S.of(context).access_revoked,
                              name: _formatDate(
                                widget.userPermission.endDate,
                                isArabic,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              title: S.of(context).last_login,
                              name: _formatDate(
                                currentEmployeeEntity?.lastLogin,
                                isArabic,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            AccessGrantorWidget(
                              title: S.of(context).total_modules,
                              name: _getTotalModules(),
                            ),
                            ],
                          ),
                        ),

                      SizedBox(height: 16.h),

                      _buildPermissionsSection(lightMode),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
  // REMOVED 12/8/2026: dead code (analyzer: unused member, 0 call sites).
  Widget _buildPermissionsSection(bool lightMode) {
    if (!_permissionsLoaded) {
      return Container(
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: const CircleProgressMaster(),
          ),
        ),
      );
    }

    if (_modulePermissions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: lightMode
              ? AppColors.white
              : AppColors.chatBackground,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.sp),
            child: Text(
              S.current.noPermissionsFound,
              style: StyleText.fontSize14Weight400.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color:
        lightMode ? AppColors.white : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            spacing: 10.sp,
            children: [
              for (String moduleString in activeModuleStrings)
                _buildModulePermissionRow(
                  lightMode: lightMode,
                  moduleString: moduleString,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// The role this access is for and its status — the header of the access
  /// card, per Figma 4717:35300: role image (or the default roles glyph), the
  /// localized role name, and "Status: <status>" in the status colour the
  /// User Management grid already uses for the same user.
  ///
  /// ADDED 21/9/2026 (bug report p.4).
  Widget _buildRoleHeader() {
    final bool isArabic = context.isArabic;
    final UserPermissionEntity permission = widget.userPermission;
    final String? accessName = permission.accessName;

    final String roleImage = roleCubit.roles
            .firstWhereOrNull((role) =>
                role.roleId == accessName ||
                role.currentRoleName == accessName)
            ?.currentRoleImage ??
        '';

    final Widget fallbackIcon = CustomSvgImage(
      assetPath: 'assets/icons_assets/roles_assets/roles_people_gear.svg',
      width: 30.sp,
      height: 30.sp,
      color: AppColors.text,
      fit: BoxFit.scaleDown,
    );

    return Row(
      children: [
        Container(
          width: 50.sp,
          height: 50.sp,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: roleImage.isNotEmpty
              ? Image.network(
                  roleImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallbackIcon,
                )
              : fallbackIcon,
        ),
        SizedBox(width: 10.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FormatHelper.capitalize(
                    permission.getLocalizedRoleName(isArabic)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleText.fontSize16Weight500
                    .copyWith(color: AppColors.text),
              ),
              SizedBox(height: 4.sp),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${S.of(context).status}: ',
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: AppColors.secondaryText),
                  ),
                  Text(
                    permission.accessStatus.label(context),
                    style: StyleText.fontSize12Weight400
                        .copyWith(color: permission.accessStatus.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
