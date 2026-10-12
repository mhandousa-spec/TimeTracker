/// Module: roles / r3_user_access / presentation / ui / widgets
///
///*************************** FILE INFO ****************************///
/// File Name: user_access_dialogs.dart
/// Purpose: Declares `UserAccessStrings` and the user-access dialog flows.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - GetX removed; the string bag now resolves the
///          locale from the ambient Localizations instead of Get.locale.
/// Updated: 29/8/2026 - Dialog shell padding 24 → 12; the schedule date field
///          fills with `background` like the other inputs; the disabled confirm
///          button is `darkGrey` rather than a faded primary; and the Reminder
///          stepper and unit dropdown share one height constant.
/// Updated: 30/8/2026 - That shared height reaches `CustomDropdown` unscaled,
///          so the unit box and the stepper beside it are finally the same
///          height (it was being scaled twice).

///************************* FILE INFO ****************************///
/// File: user_access_dialogs.dart
/// Purpose: The dialog flows behind the User Access card's "..." menu, built
///          to match the Figma:
///            • Editing Access Details  → Expiration Time + Default Password
///            • Schedule / Editing Schedule → date + reminder
///          Confirmation + success steps go through [CustomDialogManager] so
///          they look identical to the rest of the app.
/// Author: Amr Mesbah
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:knowticed_plus/core/custom/1-custom_dropdwon.dart';
import 'package:knowticed_plus/core/custom/3-custom_dropdown_calander.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/role/constants.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/domain/entities/user_access_entity.dart';
import 'package:knowticed_plus/features/roles/r3_user_access/presentation/controller/user_access_cubit.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// Copy used by the User Access flows that has no generated l10n key yet.
///
/// Every entry used to be a `static String get` resolving the locale through
/// `Get.locale`. GetX is banned, and reading the locale from a service locator
/// bypasses the widget tree, so each entry is now a method taking the ambient
/// [BuildContext] and reading [Localizations] (§13). When these strings get ARB
/// keys, the call sites already pass a context and become `S.of(context).x`.
class UserAccessStrings {
  static String _t(BuildContext context, String en, String ar) =>
      context.isArabic ? ar : en;

  // Menu
  static String deactivate(BuildContext context) => _t(context, 'Deactivate', 'إلغاء التنشيط');
  static String editSchedule(BuildContext context) => _t(context, 'Edit Schedule', 'تعديل الجدولة');
  static String cancelDeactivate(BuildContext context) => _t(context, 'Cancel Deactivate', 'إلغاء جدولة الإيقاف');
  static String cancelActivate(BuildContext context) => _t(context, 'Cancel Activate', 'إلغاء جدولة التنشيط');
  static String lastLogin(BuildContext context) => _t(context, 'Last Login', 'آخر تسجيل دخول');

  // Buttons
  static String schedule(BuildContext context) => _t(context, 'Schedule', 'جدولة');
  static String continueText(BuildContext context) => _t(context, 'Continue', 'متابعة');
  static String discard(BuildContext context) => _t(context, 'Discard', 'تجاهل');
  static String create(BuildContext context) => _t(context, 'Create', 'إنشاء');

  // Dialog titles
  static String editingAccessDetails(BuildContext context) => _t(context, 'Editing Access Details', 'تعديل تفاصيل الوصول');
  static String editingSchedule(BuildContext context) => _t(context, 'Editing Schedule', 'تعديل الجدولة');
  static String reminder(BuildContext context) => _t(context, 'Reminder', 'تذكير');
  static String scheduledForActivate(BuildContext context) => _t(context, 'Scheduled for Activate', 'مجدول للتنشيط');
  static String scheduledForReactivate(BuildContext context) => _t(context, 'Scheduled for Reactivate', 'مجدول لإعادة التنشيط');
  static String scheduledForDeactivate(BuildContext context) => _t(context, 'Scheduled for Deactivate', 'مجدول لإلغاء التنشيط');

  // Success copy
  static String accessEdited(BuildContext context) => _t(context, 'Access Edited', 'تم تعديل الوصول');
  static String accessEditedBody(BuildContext context) => _t(context, 
      'You Successfully Edited Access Details', 'تم تعديل تفاصيل الوصول بنجاح');
  static String scheduleCreated(BuildContext context) => _t(context, 'Schedule Created', 'تم إنشاء الجدولة');
  static String scheduleCreatedBody(BuildContext context) => _t(context, 'You Successfully Created Schedule', 'تم إنشاء الجدولة بنجاح');
  static String scheduleEdited(BuildContext context) => _t(context, 'Schedule Edited', 'تم تعديل الجدولة');
  static String scheduleEditedBody(BuildContext context) => _t(context, 'You Successfully Edited Schedule', 'تم تعديل الجدولة بنجاح');

  static String accountDeactivated(BuildContext context) => _t(context, 'Account Deactivated', 'تم إلغاء تنشيط الحساب');
  static String accountDeactivatedBody(BuildContext context) => _t(context, 
      'You Successfully Deactivated This Account', 'تم إلغاء تنشيط الحساب بنجاح');
  static String accountActivated(BuildContext context) => _t(context, 'Account Activated', 'تم تنشيط الحساب');
  static String accountActivatedBody(BuildContext context) => _t(context, 'You Successfully Activated This Account', 'تم تنشيط الحساب بنجاح');

  static String unlockingAccount(BuildContext context) => _t(context, 'Unlocking Account', 'إلغاء قفل الحساب');
  static String unlockingAccountBody(BuildContext context) => _t(context, 'Are You Sure You Want To Unlock This Account?',
          'هل أنت متأكد أنك تريد إلغاء قفل هذا الحساب؟');
  static String accountUnlocked(BuildContext context) => _t(context, 'Account Unlocked', 'تم إلغاء قفل الحساب');
  static String accountUnlockedBody(BuildContext context) => _t(context, 'You Successfully Unlocked Account', 'تم إلغاء قفل الحساب بنجاح');

  static String cancelDeactivatingSchedule(BuildContext context) => _t(context, 'Cancel Deactivating Schedule', 'إلغاء جدولة الإيقاف');
  static String cancelDeactivatingScheduleBody(BuildContext context) => _t(context, 'Are You Sure You Want To Cancel This Deactivating Schedule?',
          'هل أنت متأكد أنك تريد إلغاء جدولة الإيقاف؟');
  static String deactivatingScheduleCanceled(BuildContext context) => _t(context, 'Deactivating Schedule Canceled', 'تم إلغاء جدولة الإيقاف');

  static String cancelActivatingSchedule(BuildContext context) => _t(context, 'Cancel Activating Schedule', 'إلغاء جدولة التنشيط');
  static String cancelActivatingScheduleBody(BuildContext context) => _t(context, 'Are You Sure You Want To Cancel This Reactivating Schedule?',
          'هل أنت متأكد أنك تريد إلغاء جدولة إعادة التنشيط؟');
  static String activatingScheduleCanceled(BuildContext context) => _t(context, 'Activating Schedule Canceled', 'تم إلغاء جدولة التنشيط');
  static String scheduleCanceledBody(BuildContext context) => _t(context, 'You Successfully Canceled Schedule', 'تم إلغاء الجدولة بنجاح');
}

class UserAccessDialogs {
  static const String _confirmLottie =
      'assets/lottie_assets/roles_lottie_assets/Edit Document.json';
  static const String _successLottie =
      'assets/lottie_assets/main_lottie_assets/check.json';

  // Header badge icons for the form dialogs.
  static const String _editAccessIcon =
      'assets/icons_assets/roles_assets/edit_access.svg';
  static const String _calendarIcon =
      'assets/icons_assets/watermark/Schedule.svg';

  // ── Editing Access Details ────────────────────────────────────────────────

  /// "Edit" in the "..." menu. Expiration Time (stepper + unit) and Default
  /// Password, then Discard / Save, then the "Access Edited" success dialog.
  static Future<void> showEditAccessDetails({
    required BuildContext context,
    required UserAccessEntity entity,
    required UserAccessCubit controller,
  }) async {
    final TextEditingController passwordController =
        TextEditingController(text: entity.tempPassword);
    int amount = int.tryParse(entity.expirationTimeOfPassword) ?? 1;
    String unit = entity.expirationTimeUnit;

    final bool saved = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          useRootNavigator: true,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                return _DialogShell(
                  iconPath: _editAccessIcon,
                  title: UserAccessStrings.editingAccessDetails(context),
                  confirmText: S.of(context).save,
                  onConfirm: () => Navigator.of(dialogContext).pop(true),
                  onDiscard: () => Navigator.of(dialogContext).pop(false),
                  children: [
                    _FieldLabel(S.of(context).expirationTime),
                    Row(
                      children: [
                        _Stepper(
                          value: amount,
                          onChanged: (value) =>
                              setDialogState(() => amount = value),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: _UnitDropdown(
                            value: unit,
                            units: const ['Day', 'Week', 'Month', 'Year'],
                            labelOf: (u) => _durationLabel(context, u),
                            onChanged: (value) =>
                                setDialogState(() => unit = value),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.sp),
                    _FieldLabel(S.of(context).defaultPassword),
                    CustomTextField(
                      controller: passwordController,
                      fillColor: AppColors.background,
                      borderRadius: BorderRadius.circular(4.r),
                      valueStyle: StyleText.fontSize14Weight500
                          .copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    if (!saved) {
      passwordController.dispose();
      return;
    }

    // UserAccessEntity is immutable (§10/§20), so the edits produce a new
    // instance rather than mutating the one the list is holding.
    final UserAccessEntity edited = entity.copyWith(
      expirationTimeOfPassword: amount.toString(),
      expirationTimeUnit: unit,
      tempPassword: passwordController.text.trim(),
    );
    passwordController.dispose();

    if (!context.mounted) return;
    await CustomDialogManager.runWithLoading(
        context, () => controller.updateAccessDetails(edited));

    if (!context.mounted) return;
    await CustomDialogManager.showSuccess(
      context: context,
      lottiePath: _successLottie,
      title: UserAccessStrings.accessEdited(context),
      subtitle: UserAccessStrings.accessEditedBody(context),
    );
  }

  // ── Schedule / Editing Schedule ───────────────────────────────────────────

  /// Date + reminder dialog. [isEditing] switches the Figma's "Schedule /
  /// Create" variant to the "Editing Schedule / Save" one.
  static Future<void> showSchedule({
    required BuildContext context,
    required UserAccessEntity entity,
    required UserAccessCubit controller,
    required bool isEditing,
  }) async {
    // Active accounts schedule a deactivation; inactive ones schedule a
    // (re)activation.
    final bool schedulingDeactivation = entity.isActive;

    DateTime? selectedDate = schedulingDeactivation
        ? entity.deactivationDate
        : entity.reactivationDate;
    int reminderAmount = 30;
    String reminderUnit = 'Minutes';

    final String dateLabel = schedulingDeactivation
        ? UserAccessStrings.scheduledForDeactivate(context)
        : (isEditing
            ? UserAccessStrings.scheduledForReactivate(context)
            : UserAccessStrings.scheduledForActivate(context));

    final bool saved = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          useRootNavigator: true,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                return _DialogShell(
                  iconPath: _calendarIcon,
                  title: isEditing
                      ? UserAccessStrings.editingSchedule(context)
                      : UserAccessStrings.schedule(context),
                  confirmText: isEditing
                      ? S.of(context).save
                      : UserAccessStrings.create(context),
                  onConfirm: selectedDate == null
                      ? null
                      : () => Navigator.of(dialogContext).pop(true),
                  onDiscard: () => Navigator.of(dialogContext).pop(false),
                  children: [
                    _FieldLabel(dateLabel),
                    CustomDropdownCalendar(
                      value: selectedDate,
                      hint: S.of(context).pleaseSelectADate,
                      // EDIT 29/8/2026: `card` → `background`. Every other
                      // input in this dialog — the stepper and the unit
                      // dropdown below — fills with `background`; the date
                      // field was the one odd one out, and against the dialog's
                      // own surface it barely read as a field at all.
                      fillColor: AppColors.background,
                      borderRadius: BorderRadius.circular(8.r),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 5),
                      dateFormatter: (d) =>
                          DateFormat('dd MMM yyyy').format(d),
                      onChanged: (picked) {
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),
                    SizedBox(height: 16.sp),
                    _FieldLabel(UserAccessStrings.reminder(context)),
                    Row(
                      children: [
                        _Stepper(
                          value: reminderAmount,
                          step: 5,
                          onChanged: (value) =>
                              setDialogState(() => reminderAmount = value),
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: _UnitDropdown(
                            value: reminderUnit,
                            units: const [
                              'Minutes',
                              'Hours',
                              'Day',
                              'Week',
                              'Month'
                            ],
                            labelOf: (u) => _durationLabel(context, u),
                            onChanged: (value) =>
                                setDialogState(() => reminderUnit = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;

    if (!saved || selectedDate == null) return;

    // FIXED 25/8/2026 — this omitted the locale, and `DateFormat` with no
    // locale uses the AMBIENT one. With the app in Arabic it wrote
    // "أغسطس ٣١, ٢٠٢٦" into the schedule field instead of "Aug 31, 2026",
    // which is what every reader of that field expects:
    //
    //   * `UserAccessRepository._parseDateFlexible` matched none of its
    //     patterns and returned null — the logged
    //     `unrecognised date format "أغسطس ٢٢, ٢٠٢٦"` — so the schedule
    //     silently vanished from the card;
    //   * `dateforamtToArabic` threw a FormatException building the Arabic
    //     notification body, which took down the whole `fold`.
    //
    // 'en' here is the ON-DISK format, not a display choice — do not localize
    // it. Rendering the date for a human is the reader's job. Identical to the
    // note in `employee_details_methods2.dart` (FIXED 13/8/2026), which is the
    // same bug in the user-management module.
    final String formatted = DateFormat(Constants.userAccessDateFormat, 'en')
        .format(selectedDate!);

    // ADDED 28/9/2026 (Role bug report p.9 — "show the loading indicator"):
    // after Create the dialog closed and nothing moved until the success
    // dialog appeared. The app's modal loading overlay now covers the write.
    // 30/9/2026 (Role QA p.19): the shared overlay loader appears on the
    // same frame; the old GetX dialog faded in over 700 ms, so a quick write
    // finished before it was visible.
    await CustomDialogManager.runWithLoading(context, () async {
      if (schedulingDeactivation) {
        await controller.scheduleDeactivation(entity, formatted);
      } else {
        await controller.scheduleReactivation(entity, formatted);
      }
    });

    if (!context.mounted) return;
    await CustomDialogManager.showSuccess(
      context: context,
      lottiePath: _successLottie,
      title: isEditing
          ? UserAccessStrings.scheduleEdited(context)
          : UserAccessStrings.scheduleCreated(context),
      subtitle: isEditing
          ? UserAccessStrings.scheduleEditedBody(context)
          : UserAccessStrings.scheduleCreatedBody(context),
    );
  }

  // ── Status confirmations (built on CustomDialogManager) ───────────────────

  /// Deactivate / Activate. Per the Figma the two buttons are "Schedule" and
  /// "Continue" — "Schedule" reuses the No slot and opens the schedule dialog
  /// instead of changing the status now.
  static Future<void> showStatusChange({
    required BuildContext context,
    required UserAccessEntity entity,
    required UserAccessCubit controller,
  }) async {
    final bool deactivating = entity.isActive;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: _confirmLottie,
      confirmTitle: deactivating
          ? S.of(context).deactivatingUserAccount
          : S.of(context).activatingUserAccount,
      confirmSubtitle: deactivating
          ? S.of(context).areYouSureYouWantToDeactivateThisAccount
          : S.of(context).areYouSureYouWantToActivateThisAccount,
      confirmNoText: UserAccessStrings.schedule(context),
      confirmYesText: UserAccessStrings.continueText(context),
      // 21/9/2026 — narrower, per Figma (411 wide); it was the shared 500.
      confirmWidth: 411,
      onNoPressed: () {
        // Deferred so the confirm dialog is fully dismissed first.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          showSchedule(
            context: context,
            entity: entity,
            controller: controller,
            isEditing: false,
          );
        });
      },
      onConfirm: () async {
        await controller.updateAccountStatus(entity);
        return true;
      },
      successLottie: _successLottie,
      successTitle: deactivating
          ? UserAccessStrings.accountDeactivated(context)
          : UserAccessStrings.accountActivated(context),
      successSubtitle: deactivating
          ? UserAccessStrings.accountDeactivatedBody(context)
          : UserAccessStrings.accountActivatedBody(context),
    );
  }

  /// Unlock a locked account — plain No / Yes confirmation.
  static Future<void> showUnlock({
    required BuildContext context,
    required UserAccessEntity entity,
    required UserAccessCubit controller,
  }) async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: _confirmLottie,
      confirmTitle: UserAccessStrings.unlockingAccount(context),
      confirmSubtitle: UserAccessStrings.unlockingAccountBody(context),
      confirmNoText: S.of(context).no,
      confirmYesText: S.of(context).yes,
      // 21/9/2026 — narrower, per Figma (411 wide); it was the shared 500.
      confirmWidth: 411,
      onConfirm: () async {
        await controller.updateAccountStatus(entity);
        return true;
      },
      successLottie: _successLottie,
      successTitle: UserAccessStrings.accountUnlocked(context),
      successSubtitle: UserAccessStrings.accountUnlockedBody(context),
    );
  }

  /// Cancel a pending schedule. An empty date is how the repository clears it.
  static Future<void> showCancelSchedule({
    required BuildContext context,
    required UserAccessEntity entity,
    required UserAccessCubit controller,
  }) async {
    final bool cancellingDeactivation = entity.isActive;

    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: _confirmLottie,
      confirmTitle: cancellingDeactivation
          ? UserAccessStrings.cancelDeactivatingSchedule(context)
          : UserAccessStrings.cancelActivatingSchedule(context),
      confirmSubtitle: cancellingDeactivation
          ? UserAccessStrings.cancelDeactivatingScheduleBody(context)
          : UserAccessStrings.cancelActivatingScheduleBody(context),
      confirmNoText: S.of(context).no,
      confirmYesText: S.of(context).yes,
      // 21/9/2026 — narrower, per Figma (411 wide); it was the shared 500.
      confirmWidth: 411,
      onConfirm: () async {
        if (cancellingDeactivation) {
          await controller.scheduleDeactivation(entity, '');
        } else {
          await controller.scheduleReactivation(entity, '');
        }
        return true;
      },
      successLottie: _successLottie,
      successTitle: cancellingDeactivation
          ? UserAccessStrings.deactivatingScheduleCanceled(context)
          : UserAccessStrings.activatingScheduleCanceled(context),
      successSubtitle: UserAccessStrings.scheduleCanceledBody(context),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  static String _durationLabel(BuildContext context, String unit) {
    switch (unit.toLowerCase()) {
      case 'minutes':
        return UserAccessStrings._t(context, 'Minutes', 'دقائق');
      case 'hours':
        return S.of(context).hour;
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
}

// ══════════════════════════════════════════════════════════════════════════
// Dialog building blocks — styled to match CustomDialogManager's dialogs.
// ══════════════════════════════════════════════════════════════════════════

class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.iconPath,
    required this.title,
    required this.confirmText,
    required this.onConfirm,
    required this.onDiscard,
    required this.children,
  });

  /// SVG asset path for the header badge.
  final String iconPath;
  final String title;
  final String confirmText;

  /// A null [onConfirm] renders the primary button disabled — used while the
  /// schedule dialog has no date picked yet.
  final VoidCallback? onConfirm;
  final VoidCallback onDiscard;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;

    return Dialog(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.white
          : AppColors.chatBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        // EDIT 29/8/2026: 24 → 12. The shell is a fixed 420 wide, so the old
        // padding spent 48 of that on margin and squeezed the date field and
        // the reminder row for no gain.
        padding: EdgeInsets.all(12.r),
        child: SizedBox(
          width: 420.sp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: AppColors.primary,
                    child: CustomSvgImage(
                      assetPath: iconPath,
                      width: 16.sp,
                      height: 16.sp,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  ),
                  SizedBox(width: 10.sp),
                  Expanded(
                    child: Text(
                      title,
                      style: StyleText.fontSize16Weight400,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.sp),
              ...children,
              SizedBox(height: 24.sp),
              Row(
                children: [
                  customButton(

                    title: UserAccessStrings.discard(context),
                    color: AppColors.secondaryButton,
                    textStyle: StyleText.fontSize15Weight400
                        .copyWith(color: AppColors.blackButton),
                    width: isMobile ? 115.sp : 160.sp,
                    function: onDiscard,
                  ),
                  Spacer(),
                  customButton(
                    title: confirmText,
                    // EDIT 29/8/2026: the disabled state is `darkGrey`, not a
                    // 40%-opacity primary. Faded primary still read as the
                    // brand colour — a dimmed live button rather than a dead
                    // one — and it sat next to Discard, which is already
                    // `darkGrey`, so "disabled" and "secondary" now share one
                    // colour and only the primary state stands out.
                    color: onConfirm == null
                        ? AppColors.darkGrey
                        : AppColors.primary,
                    width: isMobile ? 115.sp : 160.sp,
                    function: onConfirm ?? () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.sp),
      child: Text(text, style: StyleText.fontSize14Weight400),
    );
  }
}

/// The height both halves of a stepper + unit row are pinned to.
///
/// ADDED 29/8/2026. The stepper hardcoded 35 while `_UnitDropdown` passed no
/// height at all and sized itself from its own content, so the two controls
/// standing side by side in one Row came out different heights. One constant,
/// used by both, is what keeps them level.
///
/// ⚠️ RAW, never pre-scaled. `_Stepper` builds a plain `Container`, so it
/// applies `.sp` itself; `CustomDropdown.height` documents that it takes the
/// raw design number and scales it internally, so it must be handed this
/// constant AS IS.
///
/// FIXED 30/8/2026: `_UnitDropdown` was passing `_reminderControlHeight.sp`,
/// which `CustomDropdown` then scaled a second time. At any screen where
/// ScreenUtil's factor is not exactly 1 — i.e. everywhere but the design
/// device — that made the dropdown 36 × factor² tall against the stepper's
/// 36 × factor, so the two boxes in the Expiration Time row never lined up and
/// the stepper read as the short one. The doc comment above already said not
/// to do this; the call site did it anyway.
const double _reminderControlHeight = 36;

/// "− 30 +" control from the Figma.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min = 1,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int step;
  final int min;

  @override
  Widget build(BuildContext context) {
    return Container(
      // FIXED 9/9/2026: was a hardcoded 35 against the dropdown's 36, so the
      // two controls in the Reminder and Expiration Time rows were a pixel
      // (times the ScreenUtil factor) out of level — visible on phone and
      // desktop alike. Both sides read the one constant now, which is the
      // whole point of `_reminderControlHeight`; `.sp` here because this is a
      // plain Container, while `CustomDropdown` scales the raw value itself.
      height: _reminderControlHeight.sp,
      padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepButton(Icons.remove, () {
            final int next = value - step;
            onChanged(next < min ? min : next);
          }),
          Text(
            '$value',
            style: StyleText.fontSize14Weight500
                .copyWith(color: AppColors.secondaryText),
          ),
          _stepButton(Icons.add, () => onChanged(value + step)),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.all(4.sp),
        child: Icon(icon, size: 18.sp, color: AppColors.secondaryText),
      ),
    );
  }
}

class _UnitDropdown extends StatelessWidget {
  const _UnitDropdown({
    required this.value,
    required this.units,
    required this.labelOf,
    required this.onChanged,
  });

  final String value;
  final List<String> units;
  final String Function(String) labelOf;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      value: units.contains(value) ? value : units.first,
      fillColor: AppColors.background,
      // Matches `_Stepper` beside it — see `_reminderControlHeight`. RAW, not
      // `.sp`: CustomDropdown scales this itself.
      height: _reminderControlHeight,
      borderRadius: BorderRadius.circular(4.r),
      valueStyle: StyleText.fontSize14Weight500
          .copyWith(color: AppColors.secondaryText),
      items: [
        for (final String unit in units)
          DropdownItem<String>(value: unit, label: labelOf(unit)),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}
