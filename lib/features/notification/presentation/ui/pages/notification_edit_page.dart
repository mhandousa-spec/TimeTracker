/// Module: notification
///
///*************************** FILE INFO ****************************///
/// File Name: notification_edit_page.dart
/// Purpose: Edits one notification template.
/// Author: Knowticed Plus team
/// Created at: 2026
/// Updated: 12/8/2026 - CR-SKEL-NOTIF-N13: the two dead private methods are deleted.
/// Updated: 2/9/2026 - This screen is where the five Notification Control role
///          permissions land (Figma: ROLE MANAGEMENT → Adding New Role →
///          Notification Control). Nothing here is hidden behind a permission
///          except the two write ACTIONS (Save, Reset Default); the status
///          switch, the channel checkboxes and the copy fields are shown to
///          everyone and made inert without the matching right, because
///          reading a notification's configuration and changing it are
///          different things and only the second is gated.
/// Updated: 9/10/2026 - Time Tracker QA KP-TT-018 (shared module → Amr's
///          handover): the status row and the Preview / Save row always fit
///          (`NotificationStatusHeader` / `NotificationEditActions`) — Reset
///          Default (190.w) overflowed the status row on a phone.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/svg_custom.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
import 'package:knowticed_plus/features/notification/data/repository/notification_template_service.dart';

import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/qiyas/core/widgets/multi_select_dropdown_widget.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/grc/core/widgets/custom_botton.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/external/todo_module/core/components/other_components/flutter_switch.dart';
import 'package:knowticed_plus/features/notification/data/models/notification_model.dart';
import 'package:knowticed_plus/features/notification/domain/enums/notification_catalog.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/pages/notification_control.dart';
import 'package:knowticed_plus/features/notification/presentation/ui/widgets/notification_edit_layout.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
// ADDED 2/9/2026 — the Notification Control role permissions. This screen is
// where all five of them actually bite; see the header note above.
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/notification/notification_permissions_enum.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/domain/enums/notification/notification_sections_enum.dart';

class NotificationEditPage extends StatefulWidget {
  final NotificationItem notificationItem;
  final String moduleName;
  final NotificationTab currentTab;

  const NotificationEditPage({
    super.key,
    required this.notificationItem,
    required this.moduleName,
    required this.currentTab,
  });

  @override
  State<NotificationEditPage> createState() => _NotificationEditPageState();
}

class _NotificationEditPageState extends State<NotificationEditPage> {
  bool isSaving = false;
  bool isLoadingTemplate = true;
  bool isNotificationEnabled = true;

  List<String> selectedNotificationTypes = [];

  TextEditingController subjectEn = TextEditingController();
  TextEditingController subjectAr = TextEditingController();
  TextEditingController bodyArController = TextEditingController();
  TextEditingController bodyEnController = TextEditingController();

  NotificationTemplateModel? currentTemplate;
  final NotificationTemplateService _templateService = NotificationTemplateService();

  // ADDED 2/9/2026 — Notification Control role permissions.
  //
  // Read ONCE in initState, not per build. `isHasPermission` walks the role
  // document, and this screen rebuilds on every keystroke in four text fields
  // (each one calls `setState` from `onChanged`). A role cannot change while
  // one template is open, so re-reading it 500 times while someone types a
  // body is pure waste.
  bool _canEditNotification = false;
  bool _canEditPushMessages = false;
  bool _canEditEmailMessages = false;
  bool _canChangeStatus = false;
  bool _canChangeChannel = false;

  /// May the member rewrite the subject and body of THIS notification?
  ///
  /// The template holds one subject/body pair, and the checkboxes below decide
  /// which channels it is sent on — so "may edit the copy" is not a single
  /// right, it depends on which channels this notification currently uses. A
  /// role with push copy rights only may edit a push-only notification and
  /// must not edit an email-only one.
  ///
  /// [NotificationPermissions.editNotification] is the umbrella: without it
  /// the copy is read-only whatever the two channel rights say. When no
  /// channel is selected yet there is nothing to protect, so either channel
  /// right is enough.
  bool get _canEditMessages {
    if (!_canEditNotification) return false;

    final bool push = selectedNotificationTypes.contains('push');
    final bool email = selectedNotificationTypes.contains('email');

    if (!push && !email) {
      return _canEditPushMessages || _canEditEmailMessages;
    }

    return (push && _canEditPushMessages) || (email && _canEditEmailMessages);
  }

  /// Save writes status, channels and copy in one go, so it is offered when
  /// the member may change ANY of the three — not only the copy.
  bool get _canSave => _canEditMessages || _canChangeStatus || _canChangeChannel;

  @override
  void initState() {
    super.initState();
    _readPermissions();
    _loadTemplate();
  }

  /// Function Name: [_readPermissions]
  ///
  /// Purpose: Resolve the five Notification Control permissions for the signed
  ///          in employee, once, when the screen opens.
  ///
  /// Returns: [void] — the five `_can…` fields are set directly.
  void _readPermissions() {
    final MainCoreEmployeeController controller = Get.find();

    bool has(NotificationPermissions permission) {
      return controller.isHasPermission(
        module: Modules.notification,
        section: NotificationPermissionsSections.notificationControl,
        permission: permission,
      );
    }

    _canEditNotification = has(NotificationPermissions.editNotification);
    _canEditPushMessages = has(NotificationPermissions.editPushNotificationMessages);
    _canEditEmailMessages = has(NotificationPermissions.editEmailNotificationMessages);
    _canChangeStatus = has(NotificationPermissions.changeNotificationStatus);
    _canChangeChannel = has(NotificationPermissions.changeNotificationChannel);
  }

  @override
  void dispose() {
    subjectEn.dispose();
    subjectAr.dispose();
    bodyArController.dispose();
    bodyEnController.dispose();
    super.dispose();
  }

  // ✅ Load template from Firebase
  Future<void> _loadTemplate() async {
    setState(() {
      isLoadingTemplate = true;
    });


    NotificationTemplateModel? template = await _templateService.getTemplate(
      module: widget.moduleName,
      eventType: widget.notificationItem.eventType,
    );

    if (template != null) {

      setState(() {
        currentTemplate = template;
        isNotificationEnabled = template.isEnabled;
        selectedNotificationTypes = List.from(template.selectedNotificationTypes);

        subjectEn.text = template.subjectEnglish;
        subjectAr.text = template.subjectArabic;
        bodyEnController.text = template.bodyEnglish;
        bodyArController.text = template.bodyArabic;

        isLoadingTemplate = false;
      });
    } else {
      setState(() {
        isNotificationEnabled = widget.notificationItem.isEnabled;
        if (widget.notificationItem.hasEmail) {
          selectedNotificationTypes.add('email');
        }
        if (widget.notificationItem.hasPush) {
          selectedNotificationTypes.add('push');
        }
        isLoadingTemplate = false;
      });
    }

  }

  // ✅ Save template to Firestore
  Future<void> _saveTemplate() async {
    if (subjectEn.text.trim().isEmpty ||
        subjectAr.text.trim().isEmpty ||
        bodyEnController.text.trim().isEmpty ||
        bodyArController.text.trim().isEmpty) {
      // Snackbar removed: the guard now just aborts the save.
      return;
    }

    setState(() {
      isSaving = true;
    });

    final templateToSave = currentTemplate?.copyWith(
      subjectEnglish: subjectEn.text.trim(),
      subjectArabic: subjectAr.text.trim(),
      bodyEnglish: bodyEnController.text.trim(),
      bodyArabic: bodyArController.text.trim(),
      isEnabled: isNotificationEnabled,
      selectedNotificationTypes: selectedNotificationTypes,
      updatedAt: DateTime.now(),
    ) ?? NotificationTemplateModel(
      id: '${widget.moduleName}_${widget.notificationItem.eventType}',
      module: widget.moduleName,
      eventType: widget.notificationItem.eventType,
      subjectEnglish: subjectEn.text.trim(),
      subjectArabic: subjectAr.text.trim(),
      bodyEnglish: bodyEnController.text.trim(),
      bodyArabic: bodyArController.text.trim(),
      isEnabled: isNotificationEnabled,
      selectedNotificationTypes: selectedNotificationTypes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await _templateService.saveTemplate(templateToSave);

    setState(() {
      isSaving = false;
    });

    // Snackbars removed. On success the page closes, which is the feedback;
    // a failure now leaves the user on the editor with their input intact.
    if (success) {
      Navigator.pop(context);
    }
  }

  // ✅ Reset to default
  Future<void> _resetToDefault() async {
    final success = await _templateService.resetToDefault(
      module: widget.moduleName,
      eventType: widget.notificationItem.eventType,
    );

    // Snackbars removed: a successful reset repaints the fields from the
    // reloaded template, which is the visible confirmation.
    if (success) {
      await _loadTemplate();
    }
  }

  // ✅ Show preview dialog
  void _showPreviewDialog(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? "معاينة الإشعار" : "Notification Preview"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? "العنوان:" : "Subject:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? subjectAr.text : subjectEn.text),
            SizedBox(height: 16),
            Text(
              isArabic ? "النص:" : "Body:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(isArabic ? bodyArController.text : bodyEnController.text),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.moreLightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isArabic
                    ? "ملاحظة: سيتم استبدال المتغيرات مثل {{serviceName}} بالقيم الفعلية عند إرسال الإشعار"
                    : "Note: Variables like {{serviceName}} will be replaced with actual values when sending notifications",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isArabic ? "إغلاق" : "Close"),
          ),
        ],
      ),
    );
  }

  /// Available-placeholder hint, derived from the selected catalog event.
  /// Replaces a ~140-line switch that had to be updated by hand for every
  /// new module and drifted from the actual template text.
  String _getVariablesHintText(bool isRTL) {
    final module = widget.currentTab.module;
    final event = module == null
        ? null
        : NotificationCatalog.find(
            module: module,
            key: widget.notificationItem.eventType,
          );

    final tokens = event?.variables.map((v) => v.token).join(', ') ?? '';
    if (tokens.isEmpty) {
      return isRTL
          ? "لا توجد متغيرات لهذا الإشعار"
          : "This notification has no variables";
    }
    return isRTL ? "المتغيرات المتاحة: $tokens" : "Available variables: $tokens";
  }

  // ✅ Helper method to get display text for selected items

  // ✅ Helper to convert display name to key

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final lightMode = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(S.of(context).notificationControl,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(widget.notificationItem.title,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.secondaryText)),
                ],
              ),
            ),
            Expanded(
              child: isLoadingTemplate
              ? Center(child: CircleProgressMaster())
              : ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                children: [
                  // Status & Notification Type Container
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Row — QA KP-TT-018 (9/10/2026): Reset
                        // Default moves to its own line when it does not fit
                        // beside the title (it overflowed on a phone).
                        NotificationStatusHeader(
                          icon:
                            SvgPicture.asset(
                              "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                              width: 16.w,
                              height: 16.h,
                              fit: BoxFit.fill,
                              colorFilter: ColorFilter.mode(AppColors.secondaryText, BlendMode.srcIn),
                            ),
                          title:
                            Text(
                              isRTL ? "حالة الإشعار" : "Notification Status",
                              style: StyleText.fontSize18Weight500.copyWith(
                                color: AppColors.text,
                              ),
                            ),
                          toggle:
                            // GATED 2/9/2026 — NotificationPermissions
                            // .changeNotificationStatus.
                            //
                            // Shown but inert without the right, not hidden:
                            // whether a notification is on or off is
                            // information a reader needs even when they may
                            // not change it. AbsorbPointer rather than
                            // FlutterSwitch's own disabled flag so the
                            // behaviour does not depend on the package
                            // version.
                            AbsorbPointer(
                              absorbing: !_canChangeStatus,
                              child: Opacity(
                                opacity: _canChangeStatus ? 1.0 : 0.5,
                                child: FlutterSwitch(
                                  activeColor: AppColors.secondaryPrimary,
                                  height: 22.sp,
                                  width: 38.sp,
                                  padding: 3.sp,
                                  borderRadius: 20.sp,
                                  toggleSize: 16.sp,
                                  toggleColor: AppColors.white,
                                  inactiveColor: AppColors.switchTrackOff.withOpacity(0.16),
                                  value: isNotificationEnabled,
                                  onToggle: (newValue) {
                                    setState(() {
                                      isNotificationEnabled = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                            // GATED 2/9/2026 — Reset Default overwrites the
                            // whole template (status, channels and copy), so
                            // it needs every right Save needs. Hidden rather
                            // than disabled: a button that cannot be pressed
                            // is worse than no button.
                          trailing: !_canSave
                              ? null
                              : customButton(
                                title: isRTL ? "إعادة تعيين الافتراضي" : "Reset Default",
                                function: _resetToDefault,
                                color: AppColors.primary,
                                radius: 4.r,
                                width: 190.w,
                                height: 30.h,
                                textStyle: StyleText.fontSize14Weight500.copyWith(
                                  color: AppColors.textButton,
                                ),
                              ),
                        ),

                        SizedBox(height: 15.h),

                        // Notification Type Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                isRTL ? "نوع الإشعار" : "Notification Type",
                                style: StyleText.fontSize12Weight400.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                            // Multi-select: Email and Push
                            Column(
                              children: ['email', 'push'].map((key) {
                                final label = key == 'email'
                                    ? (isRTL ? 'البريد الإلكتروني' : 'Email')
                                    : (isRTL ? 'إشعار الهاتف' : 'Push Notification');
                                // GATED 2/9/2026 — NotificationPermissions
                                // .changeNotificationChannel. A null
                                // `onChanged` is how Flutter renders a
                                // checkbox as disabled, so the member still
                                // sees WHICH channels this notification goes
                                // out on without being able to move it.
                                return CheckboxListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(label, style: StyleText.fontSize12Weight400.copyWith(color: AppColors.text)),
                                  value: selectedNotificationTypes.contains(key),
                                  activeColor: AppColors.secondaryPrimary,
                                  onChanged: !_canChangeChannel
                                      ? null
                                      : (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              selectedNotificationTypes.add(key);
                                            } else {
                                              selectedNotificationTypes.remove(key);
                                            }
                                          });
                                        },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15.h),

                  // Form Fields Container
                  Container(
                    padding: EdgeInsets.all(15.r),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GATED 2/9/2026 — the four copy fields below are
                        // read-only unless `_canEditMessages`, which folds
                        // `editNotification` together with the push/email
                        // rights for the channels THIS notification uses. See
                        // the getter for why the channel matters.
                        //
                        // `readOnly` rather than `enabled: false`: the text
                        // stays selectable and legible, which is the point —
                        // someone who may not rewrite the copy usually still
                        // needs to read it.
                        // Subject Fields
                        CustomTextField(
        label: "Subject",
        hint: "Text Here",
        maxLines: 1,
        height: 36,
        readOnly: !_canEditMessages,
        textDirection: TextDirection.ltr,
        controller: subjectEn,
        onChanged: (_) => setState(() {}),
      ),

                        SizedBox(height: 15.h),

                        CustomTextField(
        label: "عنوان",
        hint: "اكتب هنا",
        maxLines: 1,
        height: 36,
        readOnly: !_canEditMessages,
        textDirection: TextDirection.rtl,
        controller: subjectAr,
        onChanged: (_) => setState(() {}),
      ),

                        SizedBox(height: 15.h),

                        // Helper text for variables
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16.sp,
                                color: AppColors.blue,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _getVariablesHintText(isRTL),
                                  style: StyleText.fontSize12Weight400.copyWith(
                                    color: AppColors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.h),

                        // Body Field EN
                        CustomTextField(
        label: "Body",
        hint: "Text Here",
        maxLines: 7,
        minLines: 7,
        height: 150.h,
        maxLength: 500,
        showCharCount: true,
        readOnly: !_canEditMessages,
        textDirection: TextDirection.ltr,
        controller: bodyEnController,
        onChanged: (_) => setState(() {}),
      ),

                        SizedBox(height: 15.h),

                        // Body Field AR
                        CustomTextField(
        label: "نص الرسالة",
        hint: "اكتب هنا",
        maxLines: 7,
        minLines: 7,
        height: 150.h,
        maxLength: 500,
        showCharCount: true,
        readOnly: !_canEditMessages,
        textDirection: TextDirection.rtl,
        controller: bodyArController,
        onChanged: (_) => setState(() {}),
      ),

                        SizedBox(height: 15.h),

                        // Bottom Buttons Row — QA KP-TT-018 (9/10/2026):
                        // always fits (spread → shared → stacked).
                        NotificationEditActions(
                          start: <NotificationEditAction>[
                            NotificationEditAction(
                              key: const ValueKey<String>('notificationEditPagePreview'),
                              title: S.of(context).preview,
                              textStyle: StyleText.fontSize16Weight500.copyWith(
                                color: lightMode ? AppColors.colorBlack : AppColors.white,
                              ),
                              onTap: () {
                                _showPreviewDialog(context);
                              },
                              color: lightMode ? AppColors.grey : AppColors.darkGrey,
                            ),
                          ],
                          // GATED 2/9/2026 — Save writes status, channels
                          // and copy together, so it is offered whenever the
                          // member may change any one of the three. Preview
                          // above stays ungated: it only renders what is
                          // already on screen.
                          end: !_canSave
                              ? null
                              : NotificationEditAction(
                                  key: const ValueKey<String>('notificationEditPageSave'),
                                  title: isSaving
                                      ? (isRTL ? "جاري الحفظ..." : "Saving...")
                                      : S.of(context).save,
                                  textStyle: StyleText.fontSize16Weight500.copyWith(
                                    color: AppColors.textButton,
                                  ),
                                  onTap: () {
                                    if (!isSaving) {
                                      _saveTemplate();
                                    }
                                  },
                                  color: AppColors.primary,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}