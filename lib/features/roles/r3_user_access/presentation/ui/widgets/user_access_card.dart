/// Module: roles / r3_user_access / presentation / ui / widgets
///
///************************* FILE INFO ****************************///
/// File: user_access_card.dart
/// Purpose: User Access list card, built to match the Figma "Role Management /
///          User Access" design: status-coloured card, avatar + identity, a
///          "..." action menu whose items depend on the account status, and a
///          read-only detail row (Expiration Time, Default Password, First
///          Login, Last Login).
///
///          Every action opens a dialog — see user_access_dialogs.dart, which
///          builds them on top of CustomDialogManager.
/// Author: Amr Mesbah
/// Updated: 29/8/2026 - The "..." menu button no longer paints a hover /
///          pressed overlay; the "—" placeholder in a value box is the only
///          text drawn in `secondaryText`, real values use `text`.
/// Updated: 25/8/2026 - Menu items gated on the User Access permissions.
///          Reported as "switches of user access not work": `UserAccess`
///          (r1_role_management/domain/enums/roles) declares seven permissions,
///          the role editor writes all seven, and this menu asked about none —
///          anyone who could open the page could deactivate, unlock and
///          reschedule every account. Each item now goes through
///          `RolesModuleAccess.userAccess`, which also honours the
///          "صلاحيات المستخدم" section master switch above the seven.
///
///          Denied actions are REMOVED from the menu rather than disabled: the
///          menu already varies by account status, so an absent item reads as
///          "not applicable here" and never as a dead control. A card whose
///          every action is denied shows no "..." at all.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';

import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/helper/role/roles_module_access.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/domain/enums/employee_status_enum.dart';
import 'package:knowticed_plus/features/onboarding/o3_authentication/presentation/ui/theme/employee_status_style.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/user_access_status_row.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/roles/user_access_permission.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/ui/widgets/user_access_dialogs.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/presentation/controller/main_core_department_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Actions offered by the "..." menu. Which ones are shown depends on the
/// account status — see [_UserAccessCardState._availableActions].
enum UserAccessAction {
  edit,
  deactivate,
  activate,
  unlock,
  editSchedule,
  cancelSchedule,
}

class UserAccessCard extends StatefulWidget {
  const UserAccessCard({
    required this.entity,
    required this.controller,
    required this.departments,
    super.key,
  });

  final UserAccessEntity entity;
  final UserAccessCubit controller;
  final MainCoreDepartmentCubit departments;

  @override
  State<UserAccessCard> createState() => _UserAccessCardState();
}

class _UserAccessCardState extends State<UserAccessCard> {
  UserAccessEntity get entity => widget.entity;

  // ── Status ────────────────────────────────────────────────────────────────

  /// The stored status alone can't tell "active" from "scheduled for
  /// deactivation" — that comes from the schedule dates. This collapses both
  /// into the single status the card should paint itself with.
  EmployeeStatusEnum get _displayStatus {
    if (_isLocked) return EmployeeStatusEnum.locked;
    if (entity.isActive && entity.willBeDeactivated) {
      return EmployeeStatusEnum.willBeDeactivated;
    }
    if (!entity.isActive && entity.willBeActivated) {
      return EmployeeStatusEnum.willBeActivated;
    }
    if (entity.isActive) return EmployeeStatusEnum.active;
    if (entity.isDeactivated || entity.isInactive) {
      return EmployeeStatusEnum.deactivated;
    }
    return entity.status;
  }

  Color get _statusColor {
    final Color color = userAccessStatusColor(_displayStatus);
    return color == AppColors.transparent ? AppColors.grey : color;
  }

  bool get _isLocked => entity.isLocked || entity.isLockedWithRequest;

  bool get _hasSchedule =>
      (entity.isActive && entity.willBeDeactivated) ||
      (!entity.isActive && entity.willBeActivated);

  /// Whether the account has never actually been logged into.
  ///
  /// A brand-new account is seeded with the account's creation time in BOTH
  /// First_Login and Last_Login, so a never-logged-in account shows the two as
  /// the same moment — which reads on the card as the company's creation date
  /// under "First Login" / "Last Login". A real login advances Last_Login past
  /// First_Login.
  ///
  /// The two seeded values are written a fraction apart, so a raw `DateTime ==`
  /// misses them (they differ by seconds/milliseconds even though the card only
  /// shows the minute). Compare down to the minute — the precision the card
  /// actually displays — so identical-looking rows are treated as no-login and
  /// the two login fields are shown empty.
  bool get _hasNeverLoggedIn {
    final DateTime? first = entity.firstLogin;
    final DateTime? last = entity.lastLogin;
    if (first == null || last == null) return false;
    return first.year == last.year &&
        first.month == last.month &&
        first.day == last.day &&
        first.hour == last.hour &&
        first.minute == last.minute;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isPhone = ContextExtension(context).isPhone;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _statusColor, width: 1.5),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  SizedBox(height: 16.sp),
                  _details(context, isPhone),
                ],
              ),
            ),

            // "Locked" corner ribbon, as in the Figma.
            if (_isLocked) _lockedRibbon(context),
          ],
        ),
      ),
    );
  }

  // ── Header: avatar, identity, "..." menu ──────────────────────────────────


  /// Resolves [UserAccessEntity.department] (a department **id**) to its
  /// display name in the active language.
  String _departmentName(bool isArabic) {
    final String id = widget.entity.department;
    if (id.isEmpty) return '';

    return (isArabic
            ? widget.departments
                .getArabicDepartmentNameFromDepartmentId(departmentId: id)
            : widget.departments
                .getEnglishDepartmentNameFromDepartmentId(departmentId: id)) ??
        '';
  }

  Widget _header(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String name = isArabic ? entity.arabicName : entity.englishName;

    // FIXED 25/8/2026 — the "..." menu looked like it had disappeared in
    // Arabic.
    //
    // It was the second child of a `Stack(alignment: Alignment.topRight)`, and
    // `Alignment.topRight` is GEOMETRIC, not directional: it means the physical
    // right edge in every locale. In RTL the Row lays out start-to-end
    // right-to-left, so the AVATAR is what sits on the right — and the menu was
    // being painted on top of it. A grey `more_horiz` over the avatar's
    // `AppColors.field` fill reads as nothing at all. In LTR the same overlay
    // landed on the tail of the identity text, where it was visible but was
    // quietly covering the last few characters of a long name.
    //
    // `AlignmentDirectional.topEnd` mirrors with the text direction — top-right
    // in English, top-left in Arabic — so it always lands in the free corner.
    // The trailing `SizedBox` then RESERVES that corner, so the identity column
    // ellipsises before it reaches the button instead of running underneath it.
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.field,
              backgroundImage: _avatar(entity.photoUrl),
            ),
            SizedBox(width: 12.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    FormatHelper.capitalize(
                        name.trim().isEmpty ? entity.email : name),
                    style: StyleText.fontSize16Weight400,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.sp),
                  Text(
                    // Was `entity.departmentName(isArabic, widget.departments)`.
                    // Resolving the id against a presentation cubit forced the
                    // domain entity to import one (§3); the widget already holds
                    // the cubit, so it does the lookup itself.
                    FormatHelper.capitalize(_departmentName(isArabic)),
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    FormatHelper.capitalize(entity.jobTitle(isArabic)),
                    style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Keeps the corner clear for the overlaid menu above. 24.sp of
            // button plus a little breathing room, since the menu no longer
            // carries an IconButton's 48×48 box (9/9/2026).
            SizedBox(width: 32.sp),
          ],
        ),
        _actionsMenu(context),
      ],
    );
  }

  ImageProvider? _avatar(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) return null;
    return photoUrl.startsWith('assets/')
        ? AssetImage(photoUrl)
        : NetworkImage(photoUrl) as ImageProvider;
  }

  // ── "..." menu ────────────────────────────────────────────────────────────

  /// Menu contents follow the Figma: the actions offered depend on where the
  /// account currently is in its lifecycle.
  List<UserAccessAction> get _availableActions =>
      _applicableActions.where(_isPermitted).toList();

  /// The actions this account's LIFECYCLE offers, before permissions.
  ///
  /// Split out 25/8/2026 so the status rules and the permission rules stay
  /// separate concerns: this answers "does this action make sense for this
  /// account", [_isPermitted] answers "may this employee do it".
  List<UserAccessAction> get _applicableActions {
    if (_isLocked) return [UserAccessAction.unlock];

    if (_hasSchedule) {
      return [
        UserAccessAction.edit,
        UserAccessAction.editSchedule,
        UserAccessAction.cancelSchedule,
      ];
    }

    return [
      UserAccessAction.edit,
      entity.isActive ? UserAccessAction.deactivate : UserAccessAction.activate,
    ];
  }

  /// Function Name: [_isPermitted]
  ///
  /// Purpose: Whether the signed-in employee's role allows [action].
  ///
  /// The two schedule actions are asymmetric on purpose. A schedule is either a
  /// pending DEACTIVATION or a pending ACTIVATION, and the enum has a separate
  /// permission for each; which one applies is decided by where the account is
  /// now, exactly as `_hasSchedule` decides it. Cancelling a schedule is the
  /// same authority as setting one — someone who may not schedule a
  /// deactivation may not call one off either.
  ///
  /// Parameters:
  /// - [action]: the menu item being considered.
  ///
  /// Returns: [bool]
  bool _isPermitted(UserAccessAction action) {
    switch (action) {
      // "Edit" opens the access-details dialog, which persists the password
      // expiry settings (`UserAccessCubit.updateAccessDetails`) — so it is
      // Change Expiration Date, not a generic edit right.
      case UserAccessAction.edit:
        return RolesModuleAccess.userAccess(UserAccess.changeExpirationDate);
      case UserAccessAction.deactivate:
        return RolesModuleAccess.userAccess(UserAccess.deactivateUser);
      case UserAccessAction.activate:
        return RolesModuleAccess.userAccess(UserAccess.reactiveUser);
      case UserAccessAction.unlock:
        return RolesModuleAccess.userAccess(UserAccess.unlockUserAccount);
      case UserAccessAction.editSchedule:
      case UserAccessAction.cancelSchedule:
        return RolesModuleAccess.userAccess(
          entity.isActive
              ? UserAccess.scheduleToDeactivate
              : UserAccess.scheduleToReactivate,
        );
    }
  }

  String _actionLabel(BuildContext context, UserAccessAction action) {
    switch (action) {
      case UserAccessAction.edit:
        return S.of(context).edit;
      case UserAccessAction.deactivate:
        return UserAccessStrings.deactivate(context);
      case UserAccessAction.activate:
        return S.of(context).active;
      case UserAccessAction.unlock:
        return S.of(context).unlockAccount;
      case UserAccessAction.editSchedule:
        return UserAccessStrings.editSchedule(context);
      case UserAccessAction.cancelSchedule:
        return entity.isActive
            ? UserAccessStrings.cancelDeactivate(context)
            : UserAccessStrings.cancelActivate(context);
    }
  }

  Widget _actionsMenu(BuildContext context) {
    // No permitted action means no affordance — a "..." that opens an empty
    // sheet is worse than no "..." at all.
    final List<UserAccessAction> actions = _availableActions;
    if (actions.isEmpty) return const SizedBox.shrink();

    // EDIT 9/9/2026 — the "..." now sits where the Figma puts it, and is the
    // Figma's glyph.
    //
    // Position: `PopupMenuButton` renders an `icon` through an `IconButton`,
    // and an IconButton keeps a 48×48 minimum tap box no matter how small its
    // padding is. `AlignmentDirectional.topEnd` was therefore placing that BOX
    // in the corner, leaving the glyph centred ~24px down and in from it — on
    // the card it read as floating beside the name rather than pinned to the
    // corner. Passing the glyph as `child` takes PopupMenuButton's InkWell
    // path, which is sized by the child, so the dots land flush against the
    // padded content corner exactly as in the design.
    //
    // Glyph: the Figma draws three OUTLINED circles — `dots_horizontal.svg`,
    // a 20×7 artwork — not `Icons.more_horiz`'s filled dots.
    //
    // Flatness: the `style`/`overlayColor` that suppressed the hover disc
    // (29/8/2026) only applies to the IconButton path, so the InkWell's
    // splash, hover and highlight are cleared through a local Theme instead —
    // same flat result in every state.
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        hoverColor: AppColors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: PopupMenuButton<UserAccessAction>(
        tooltip: '',
        padding: EdgeInsets.zero,
        color: AppColors.card,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        onSelected: (action) => _onAction(context, action),
        itemBuilder: (context) => [
          for (final UserAccessAction action in actions)
            PopupMenuItem<UserAccessAction>(
              value: action,
              height: 40.h,
              child: Text(
                _actionLabel(context, action),
                style: StyleText.fontSize14Weight400,
              ),
            ),
        ],
        child: SizedBox(
          width: 24.sp,
          height: 24.sp,
          child: Center(
            child: CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/dots_horizontal.svg',
              width: 18.sp,
              height: 6.sp,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  // ── Detail blocks (always read-only; editing happens in a dialog) ─────────

  Widget _details(BuildContext context, bool isPhone) {
    final List<Widget> blocks = [
      _blockShell(
        S.of(context).expirationTime,
        Row(
          children: [
            // Figma: a NARROW box for the number and a wide one for the unit.
            // That ratio only applies where the block owns the full card
            // width (phones, since 9/9/2026); in the four-column layout the
            // block is already narrow, so the two boxes split it evenly.
            Expanded(child: _valueBox(entity.expirationTimeOfPassword)),
            SizedBox(width: 8.sp),
            Expanded(
              flex: isPhone ? 6 : 1,
              child: _valueBox(_unitLabel(context, entity.expirationTimeUnit)),
            ),
          ],
        ),
      ),
      _blockShell(S.of(context).defaultPassword, _valueBox(entity.tempPassword)),
      _loginBlock(
        context,
        label: S.of(context).firstLogin,
        date: _hasNeverLoggedIn ? null : entity.firstLogin,
      ),
      _loginBlock(
        context,
        label: UserAccessStrings.lastLogin(context),
        date: _hasNeverLoggedIn ? null : entity.lastLogin,
      ),
    ];

    // Phones can't fit four blocks side by side, so they stack.
    //
    // EDIT 9/9/2026: ALL FOUR now stack, one per row, in the Figma's order —
    // Expiration Time, Default Password, First Login, Last Login. Expiration
    // Time and Default Password used to share the first row, which read as a
    // different field order than the design and squeezed both value boxes to
    // half a card each.
    if (isPhone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blocks[0],
          SizedBox(height: 12.sp),
          blocks[1],
          SizedBox(height: 12.sp),
          blocks[2],
          SizedBox(height: 12.sp),
          blocks[3],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: blocks[0]),
        SizedBox(width: 16.sp),
        Expanded(flex: 2, child: blocks[1]),
        SizedBox(width: 16.sp),
        Expanded(flex: 4, child: blocks[2]),
        SizedBox(width: 16.sp),
        Expanded(flex: 4, child: blocks[3]),
      ],
    );
  }

  Widget _blockShell(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: StyleText.fontSize14Weight400,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.sp),
        child,
      ],
    );
  }

  /// Read-only value box — the grey rounded field from the Figma.
  ///
  /// EDIT 29/8/2026: the em dash is the only thing in here that is muted now.
  ///
  /// Every box used to draw its text in `AppColors.secondaryText`, so a real
  /// value ("123456", "12", "أسابيع") and the "nothing here" placeholder came
  /// out the same #cccccc — the login rows, which are all placeholders until
  /// someone signs in, were indistinguishable from rows carrying data. A real
  /// value now uses `AppColors.text`; only the placeholder stays secondary.
  ///
  /// A caller that passes a dash straight through is treated as a placeholder
  /// too, not just an empty string: some entity fields carry "-" for "unknown"
  /// rather than "".
  Widget _valueBox(String value, {double? width, Widget? trailing}) {
    final String trimmed = value.trim();
    final bool isPlaceholder =
        trimmed.isEmpty || trimmed == '-' || trimmed == '—';

    return Container(
      width: width,
      height: 36.sp,
      padding: EdgeInsets.symmetric(horizontal: 10.sp),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              isPlaceholder ? '—' : value,
              style: StyleText.fontSize12Weight500.copyWith(
                color: isPlaceholder
                    ? AppColors.secondaryText.withOpacity(0.5)
                    : AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  String _unitLabel(BuildContext context, String unit) {
    switch (unit.toLowerCase()) {
      case 'day':
        return S.of(context).day;
      case 'month':
        return S.of(context).month;
      case 'year':
        return S.of(context).year;
      case 'week':
      default:
        return S.of(context).week;
    }
  }

  /// Date, time and meridiem — the three boxes from the Figma.
  Widget _loginBlock(
    BuildContext context, {
    required String label,
    required DateTime? date,
  }) {
    // FIXED 29/8/2026: no locale meant the month stayed English in Arabic mode.
    // Keep the "dd MMM yyyy" (25 Feb 2023) shape but localize the month.
    final bool isArabic =
        Localizations.localeOf(context).languageCode == 'ar';
    final String dateText = date == null
        ? ''
        : DateFormat('dd MMM yyyy', isArabic ? 'ar' : 'en').format(date);
    final String timeText =
        date == null ? '' : DateFormat('hh : mm').format(date);
    final String meridiem = date == null ? '' : DateFormat('a').format(date);

    return _blockShell(
      label,
      Row(
        children: [
          Expanded(
            child: _valueBox(
              dateText,
              trailing: CustomSvgImage(assetPath: "assets/icons_assets/main_icons_assets/images_Calendar.svg",width: 15.sp,height: 15.sp,fit: BoxFit.fill,)
            ),
          ),
          SizedBox(width: 8.sp),
          _valueBox(timeText, width: 70.w),
          SizedBox(width: 8.sp),
          _valueBox(meridiem, width: 48.w),
        ],
      ),
    );
  }

  // ── Action handling — everything routes through a dialog ──────────────────

  Future<void> _onAction(
      BuildContext context, UserAccessAction action) async {
    switch (action) {
      case UserAccessAction.edit:
        await UserAccessDialogs.showEditAccessDetails(
          context: context,
          entity: entity,
          controller: widget.controller,
        );
        break;

      // Deactivate and Activate share one dialog: its "Schedule" button opens
      // the schedule dialog, "Continue" applies the change now.
      case UserAccessAction.deactivate:
      case UserAccessAction.activate:
        await UserAccessDialogs.showStatusChange(
          context: context,
          entity: entity,
          controller: widget.controller,
        );
        break;

      case UserAccessAction.unlock:
        await UserAccessDialogs.showUnlock(
          context: context,
          entity: entity,
          controller: widget.controller,
        );
        break;

      case UserAccessAction.editSchedule:
        await UserAccessDialogs.showSchedule(
          context: context,
          entity: entity,
          controller: widget.controller,
          isEditing: true,
        );
        break;

      case UserAccessAction.cancelSchedule:
        await UserAccessDialogs.showCancelSchedule(
          context: context,
          entity: entity,
          controller: widget.controller,
        );
        break;
    }
  }

  // ── Locked ribbon ─────────────────────────────────────────────────────────

  Widget _lockedRibbon(BuildContext context) {
    return Positioned(
      top: 10.h,
      left: -22.w,
      child: Transform.rotate(
        angle: -0.785398, // -45°
        child: Container(
          width: 90.w,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          color: _statusColor,
          alignment: Alignment.center,
          child: Text(
            S.of(context).employeeStatusLocked,
            style: StyleText.fontSize12Weight400.copyWith(color: AppColors.secondaryBlack).copyWith(
              color: AppColors.white,
              fontSize: 9.sp,
            ),
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
