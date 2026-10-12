/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: user_management_details_request.dart
/// Purpose: Declares `UserManagementDetailsRequestSettings`.
/// Author: Knowticed Plus team
/// Updated: 29/8/2026 - Expanding the inquiries-and-comments thread now hides
///          the rest of the page, so the expanded thread is the whole screen
///          instead of sitting below everything else.
/// Updated: 23/8/2026 - Inquiries and comments block added under the request
///          note card. Same thread as the employee's own request details
///          screen (settings/se6_requests), so a reply written here is the
///          reply the submitter reads there.
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
// ADDED 25/8/2026: the "Message" button in `umdr_methods2.dart` opens a chat
// with the request's creator through the messaging module's app-facing wrapper.
import 'package:knowticed_plus/core/helper/message_module/main_helper/messaging_interface_implementation.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/models/change_request_mapper.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
// ADDED 9/10/2026 — Approve / Reject hidden on the reviewer's own request.
import 'package:knowticed_plus/features/settings/se6_requests/domain/rules/self_approval_rule.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/controller/user_management_controller.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/mobile_phone_model.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:knowticed_plus/generated/l10n.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../../external/knowledge_hub_module/core/custom_dialog_manager.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/data/models/employees_model/new_employee_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';

import '../../../../../../core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
part '../widgets/umdr_methods1.dart';
part '../widgets/umdr_methods2.dart';
part '../widgets/umdr_methods3.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';


class UserManagementDetailsRequestSettings extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String? requestId;

  const UserManagementDetailsRequestSettings({
    super.key,
    required this.requestData,
    this.requestId,
  });

  @override
  State<UserManagementDetailsRequestSettings> createState() =>
      _UserManagementDetailsRequestSettingsState();
}

class _UserManagementDetailsRequestSettingsState
    extends State<UserManagementDetailsRequestSettings> {
  late TextEditingController requestNoteController;

  /// Why the reviewer rejected the request.
  ///
  /// ADDED 24/8/2026. Both rejected templates in `settings_events.dart` carry a
  /// `{{rejectionReason}}` placeholder and nothing ever filled it — the only
  /// caller passed a literal `'-'`, so the employee was told their request was
  /// rejected for the reason "-". The reject flow now collects this through
  /// `CustomDialogManager`'s comment step, which runs before `onConfirm`, so
  /// the text is in hand by the time the decision is written.
  late TextEditingController rejectionReasonController;

  /// The one path a decision takes.
  ///
  /// ADDED 24/8/2026. This screen used to write `status` straight to Firestore
  /// and apply the employee profile itself, bypassing `RequestsCubit`
  /// entirely — which is why approving or rejecting from User Management
  /// notified nobody, while the same decision taken from the settings-side
  /// screen did. Both screens now go through the cubit, so there is one place
  /// that decides and one place that notifies.
  final RequestsCubit _requestsCubit = RequestsCubit();

  bool submitted = false;
  bool isProcessing = false;
  bool isLoading = true;

  /// Whether the inquiries-and-comments thread is expanded to full screen.
  ///
  /// ADDED 29/8/2026. `UniversalCommentSection` owns the expanded/collapsed
  /// state itself and reports each change through `onExpandChanged`; this
  /// mirror exists so the PAGE can react — while it is true `_buildContent`
  /// drops the submitter card, the changes card and the note and renders the
  /// thread alone. See the note in `_buildContent` (umdr_methods2.dart).
  bool commentsExpanded = false;

  String status = 'pending';
  int requestTime = 0;
  String createdByID = '';
  String createdByEmail = '';
  String section = '';

  List<Map<String, String>> changes = [];
  Map<String, dynamic>? completeRequestData;

  @override
  void initState() {
    super.initState();
    requestNoteController = TextEditingController();
    rejectionReasonController = TextEditingController();
    _fetchCompleteRequestData();
  }




  @override
  void dispose() {
    requestNoteController.dispose();
    rejectionReasonController.dispose();
    _requestsCubit.close();
    super.dispose();
  }






















  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final employeeController = AppControllers.employee;
    final creatorEmployee =
    employeeController.getLocaleEmployee(createdByEmail);

    final String creatorName = creatorEmployee != null
        ? employeeController.getEmployeeName(createdByEmail)
        : 'Unknown User';

    final String creatorTitle = creatorEmployee != null
        ? employeeController.getEmployeeJobTitle(createdByEmail)
        : '-';

    final String creatorDepartment = creatorEmployee != null
        ? employeeController.getEmployeeDepartmentName(createdByEmail)
        : '-';

    final String creatorPhone = () {
      if (creatorEmployee?.mobilePhone == null) return '-';
      final phone = isArabic
          ? "${creatorEmployee?.mobilePhone?.phone} ${creatorEmployee?.mobilePhone?.countryCode}"
          : "${creatorEmployee?.mobilePhone?.countryCode} ${creatorEmployee?.mobilePhone?.phone}";
      if (phone.trim().isEmpty || phone == ' ') return '-';
      return phone.replaceAll(RegExp(r'[\[\]]'), '');
    }();

    final String creatorEmail = creatorEmployee?.email ?? createdByEmail;

    final String creatorPhoto = creatorEmployee != null
        ? employeeController.getEmployeePhoto(createdByEmail)
        : "assets/icons_assets/main_icons_assets/male_avatar.svg";

    final bool isNetworkPhoto = creatorPhoto.startsWith('http');

    final contentWidget = _buildContent(
      lightMode,
      isMobile,
      isArabic,
      creatorName,
      creatorTitle,
      creatorDepartment,
      creatorPhone,
      creatorEmail,
      creatorPhoto,
      isNetworkPhoto,
    );

    if (isMobile) {
      return Scaffold(
        body: SideFrameMasterServices(
          titleText: S.of(context).userManagement,
          onFirstTap: () => Navigator.of(context).pop(),
          secondTitle: S.of(context).requests,
          onSecondTap: () => Navigator.pop(context),
          thirdTitle: S.of(context).requestDetails,
          child: SingleChildScrollView(child: contentWidget),
        ),
      );
    }

    return SideFrameMasterServices(
      titleText: S.of(context).userManagement,
      onFirstTap: () => Navigator.of(context).pop(),
      secondTitle: S.of(context).requests,
      onSecondTap: () => Navigator.pop(context),
      thirdTitle: S.of(context).requestDetails,
      child: SingleChildScrollView(child: contentWidget),
    );
  }
}
