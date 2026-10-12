/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: details_request.dart
/// Purpose: One request: what changed, by whom, and the approve/cancel actions.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 23/8/2026 - Inquiries and comments block added under the request
///          note card, backed by `UniversalCommentSection` and the new
///          `Employees_Request_Comments` collection.
/// Updated: 11/8/2026 - CR-SKEL-SE6-N01/N02/N06/N12/N14: the four Firestore chains and the four
///          try/catch blocks moved into RequestsCubit/RequestsRepository, the
///          field-name table into RequestFieldMapping; raw colours and the two
///          hex literals route through AppColors; `Get.locale` replaced with
///          `Localizations.localeOf(context)`.

import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
// REMOVED 8/9/2026: `6-custom_button_with_svg.dart` — its only caller was the
// old Cancel button, now built inline to match the services module's.
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_section_label.dart';
import 'package:knowticed_plus/core/helper/main_helper/arabic_number_format.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/custom/2-custom_textfield.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/core/new_theme.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/flexible_date_parser.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/custom_button_widget.dart';
// REMOVED_MODULE: import '../../../../../external/inventory_module/core/text_field.dart';
// REMOVED_MODULE: import '../../../../../external/knowledge_hub_module/knowledge_hub/presentation/ui/widgets/customed_text_field.dart';

import 'package:knowticed_plus/core/custom/12-custom_delete_icon.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/36-custom_comment_widget.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/utils/request_collection_paths.dart';
import 'package:knowticed_plus/core/custom/57-custom_dialog_manager.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/service_department_manager/mobile/dashBoard_master_mobile/widget/dialog.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import '../../../../../external/services_mangment_module/core/custom_textformfield.dart';

class DetailsRequestSettings extends StatefulWidget {
  final Map<String, dynamic> requestData;
  final String? requestId;

  const DetailsRequestSettings({
    super.key,
    required this.requestData,
    this.requestId,
  });

  @override
  State<DetailsRequestSettings> createState() => _DetailsRequestSettingsState();
}

class _DetailsRequestSettingsState extends State<DetailsRequestSettings> {
  late TextEditingController requestNoteController;
  bool submitted = false;
  bool isProcessing = false;
  bool isLoading = true;

  String status = 'pending';
  int requestTime = 0;
  String createdByID = '';
  String createdByEmail = '';
  String section = '';

  List<Map<String, String>> changes = [];

  /// The loaded request. Replaces the raw `completeRequestData` map the page
  /// used to hold and re-parse.
  ChangeRequest? _request;

  /// Owned by this page.
  final RequestsCubit _requestsCubit = RequestsCubit();

  @override
  void initState() {
    super.initState();

    // Created here rather than in [_loadRequest]: a request that never loads
    // (no id, or a deleted document) used to leave this `late` field unset,
    // and `dispose` then threw a LateInitializationError on the way out.
    requestNoteController = TextEditingController();

    _loadRequest();
  }

  /// Function Name: [_loadRequest]
  ///
  /// Purpose: Load the request through the cubit and mirror it into the local
  ///          fields this page renders.
  ///
  /// The Firestore read, the two document shapes and the three `try` blocks
  /// moved into `RequestsRepository` / `ChangeRequestMapper`
  /// (CR-SKEL-SE6-N01, N02). The legacy single-field fallback lives there now.
  Future<void> _loadRequest() async {
    final String requestId = widget.requestId ?? '';
    if (requestId.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    await _requestsCubit.loadRequest(requestId);
    if (!mounted) return;

    final ChangeRequest? loaded = _requestsCubit.state.selected;
    if (loaded == null) {
      _requestsCubit.clearMessages();
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      _request = loaded;
      createdByEmail = loaded.employeeEmail;
      createdByID = loaded.employeeId;
      status = loaded.status.wireValue;
      section = loaded.section;
      requestTime = loaded.requestDate?.millisecondsSinceEpoch ?? 0;
      requestNoteController.text = loaded.requestNote;
      changes = _mergeCountryCodeIntoPhone(
        loaded.changes
            .map((FieldChange c) => <String, String>{
                  'fieldName': c.fieldName,
                  'oldValue': c.oldValue,
                  'newValue': c.newValue,
                })
            .toList(),
      );
      isLoading = false;
    });
  }

  /// Key carrying the country code that belongs with a phone change. Present
  /// only on the row [_mergeCountryCodeIntoPhone] merged, which is what tells
  /// [_buildFieldCell] to draw the split code + number pair.
  static const String _oldCountryCodeKey = 'oldCountryCode';
  static const String _newCountryCodeKey = 'newCountryCode';

  /// Width of the country-code box in the split phone row. Matches
  /// `_dialCodeWidth` on the edit screen so the request reads at the same
  /// proportions the employee filled it in at.
  double get _dialCodeWidth => 60.sp;

  /// Function Name: [_mergeCountryCodeIntoPhone]
  ///
  /// Purpose: Fold the Country Code change into the Phone Number change so the
  ///          reviewer sees one row instead of two to cross-reference.
  ///
  /// Asked for in the Settings and Org Chart bug report, p.14: the standalone
  /// Country Code row is struck out and the code belongs with the number.
  ///
  /// UPDATED 23/8/2026: the two values used to be joined into one string
  /// ("+20 1012345678") and rendered in a single box. They are kept SEPARATE
  /// now — code under [_oldCountryCodeKey] / [_newCountryCodeKey], number in
  /// the usual `oldValue` / `newValue` — so the row can be drawn as the same
  /// narrow-code + wide-number pair the edit screen uses. Joining them also
  /// meant the Arabic-digit pass in `_displayValue` ran over the dial code,
  /// which is not a number to read but a prefix to dial.
  ///
  /// Only the top-level `country_code` / `phone` pair is touched. An emergency
  /// contact's `firstContact_phone` keeps its own row, and a country-code
  /// change that arrives WITHOUT a phone change keeps its row too — otherwise
  /// that edit would silently vanish from the request.
  ///
  /// Parameters:
  /// - [raw]: The changes exactly as they came off the request.
  ///
  /// Returns: [List<Map<String, String>>] the rows to render.
  static List<Map<String, String>> _mergeCountryCodeIntoPhone(
    List<Map<String, String>> raw,
  ) {
    int indexOf(Set<String> names) => raw.indexWhere(
          (Map<String, String> c) =>
              names.contains((c['fieldName'] ?? '').toLowerCase()),
        );

    final int codeIndex = indexOf(<String>{'country_code', 'countrycode'});
    final int phoneIndex = indexOf(<String>{'phone'});
    if (codeIndex == -1 || phoneIndex == -1) return raw;

    final Map<String, String> code = raw[codeIndex];
    final Map<String, String> phone = raw[phoneIndex];

    final List<Map<String, String>> merged =
        List<Map<String, String>>.from(raw);
    merged[phoneIndex] = <String, String>{
      'fieldName': phone['fieldName'] ?? 'phone',
      'oldValue': (phone['oldValue'] ?? '').trim(),
      'newValue': (phone['newValue'] ?? '').trim(),
      _oldCountryCodeKey: (code['oldValue'] ?? '').trim(),
      _newCountryCodeKey: (code['newValue'] ?? '').trim(),
    };
    merged.removeAt(codeIndex);
    return merged;
  }

  @override
  void dispose() {
    requestNoteController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  /// Function Name: [_decide]
  ///
  /// Purpose: Approve or reject the open request.
  ///
  /// The employee-profile write, the field-name table and the Firestore status
  /// update moved into `RequestsRepository` / `RequestFieldMapping`
  /// (CR-SKEL-SE6-N01, N02). Approving still writes the profile first and the
  /// status second, so a failed profile write leaves the request pending
  /// instead of reading as approved with nothing applied.
  Future<void> _decide(RequestStatus decision) async {
    final ChangeRequest? request = _request;
    if (request == null) return;

    setState(() => isProcessing = true);

    // Read before the first await — `context` must not be touched afterwards.
    final bool isArabic = _isArabic;
    final MainCoreEmployeeController employeeController =
        Get.find<MainCoreEmployeeController>();

    // Who is acting. The cubit needs it as the notification's sender; with no
    // email it skips the notification rather than sending from nobody.
    final String approverEmail =
        employeeController.employeeEntity?.email ?? '';
    // 9/10/2026 — also checked by the repository's self-approval rule for an
    // approve / reject (cancel is the requester's own action, not checked).
    final String approverEmployeeId =
        employeeController.employeeEntity?.id ?? '';

    final bool ok;
    if (decision == RequestStatus.approved) {
      final String employeeId =
          employeeController.getLocaleEmployee(createdByEmail)?.id ?? '';
      ok = await _requestsCubit.approve(
        request: request,
        employeeId: employeeId,
        approverEmail: approverEmail,
        approverEmployeeId: approverEmployeeId,
        isArabic: isArabic,
      );
    } else {
      // Reject and cancel are the same operation on the document: a status
      // change with the employee profile left untouched. Only reject notifies
      // — a cancel is the employee's own doing.
      ok = await _requestsCubit.setStatus(
        request,
        decision,
        approverEmail: approverEmail,
        approverEmployeeId: approverEmployeeId,
        isArabic: isArabic,
        // No rejection-reason field exists on this screen yet; the template's
        // {{rejectionReason}} renders as this until one is added.
        rejectionReason: '-',
      );
    }

    if (ok && decision == RequestStatus.approved) {
      // The approval wrote the employee document, but the profile screens read
      // MainCoreEmployeeController's in-memory cache — without this refresh
      // they keep showing the old values until the app restarts.
      await employeeController.getAllNewEmployees();
      employeeController.update(<String>['employee_profile']);
    }

    if (!mounted) return;

    setState(() {
      isProcessing = false;
      if (ok) status = decision.wireValue;
    });

    if (!ok) {
      // 9/10/2026 — a blocked self-approval shows its own EN/AR reason.
      final String? blockedMessage = _requestsCubit.state.userMessage;
      _requestsCubit.clearMessages();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(blockedMessage ?? S.of(context).errorOccurred),
            backgroundColor: AppColors.signOut,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    _requestsCubit.clearMessages();
  }

  String _translateSectionTitle(String englishTitle) {
    // FIXED 13/8/2026: hardcoded Arabic replaced by the existing l10n keys,
    // shared with request_page.dart so the two cannot drift again.
    return RequestSectionLabel.of(context, englishTitle);
  }

  bool get _isArabic => Localizations.localeOf(context).languageCode == 'ar';

  /// Function Name: [_localizeDigits]
  ///
  /// Purpose: Render Western digits as Arabic-Indic ones while the app is in
  ///          Arabic, so a request never mixes ٠١٢ labels with 012 values.
  ///
  /// Reads the locale from the tree rather than `Get.locale` — the same reason
  /// this page already avoids the global in [_buildRequestNoteSection]. That
  /// rules out `localizeNumber()` from core/custom/76, which uses `Get.locale`.
  ///
  /// Parameters:
  /// - [value]: Any display string.
  ///
  /// Returns: [String] the value with its digits localized.
  String _localizeDigits(String value) =>
      _isArabic ? value.toArabicNumbers() : value;

  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return _localizeDigits(
      DateFormat('dd MMM yyyy', _isArabic ? 'ar' : 'en').format(date),
    );
  }

  /// True for a field whose value is a date, whatever spelling the key uses.
  bool _isDateField(String bareKey) =>
      bareKey.contains('date') || bareKey.contains('birth');

  /// Function Name: [_displayValue]
  ///
  /// Purpose: Turn a stored value into what the reviewer should read.
  ///
  /// Two problems this fixes, both from the bug report p.14: a date of birth
  /// arrived as a raw ISO timestamp on the "New Details" side
  /// (`2000-11-08T00:00:00.000`) while the current side showed `12/11/1977`,
  /// and every number stayed in Western digits under an Arabic UI.
  ///
  /// Email is deliberately exempt: an address is not prose, and Arabic-Indic
  /// digits inside one would make it wrong to read back or copy.
  ///
  /// Parameters:
  /// - [fieldName]: The change's field key.
  /// - [value]: The stored value.
  ///
  /// Returns: [String] the display string, or '-' when there is nothing.
  String _displayValue(String fieldName, String value) {
    if (value.trim().isEmpty) return '-';

    final String bareKey = _toSnakeCase(_stripContactPrefix(fieldName));
    if (bareKey == 'email') return value;

    if (_isDateField(bareKey)) {
      final DateTime? parsed = FlexibleDateParser.parse(value);
      // Numeric dd/MM/yyyy, matching how the current-details side already
      // reads, and needing no month-name locale data.
      if (parsed != null) {
        return _localizeDigits(DateFormat('dd/MM/yyyy').format(parsed));
      }
    }

    return _localizeDigits(value);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      // Kept in step with request_page.dart's _getStatusColor — the badge here
      // and the filter chip there describe the same status and must match.
      case 'approved':
        return AppColors.lightGreen;
      case 'pending':
        return AppColors.statusPending;
      case 'rejected':
        return AppColors.red;
      case 'cancelled':
      case 'canceled':
        return AppColors.darkRed;
      default:
        return AppColors.secondaryText;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'assets/icons_assets/main_icons_assets/status_approved_check_green.svg';
      case 'pending':
        return 'assets/icons_assets/main_icons_assets/status_pending_hourglass_orange.svg';
      case 'rejected':
        return 'assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg';
      case 'cancelled':
      case 'canceled':
        return 'assets/icons_assets/main_icons_assets/status_cancelled_stamp_red.svg';
      default:
        return 'assets/icons_assets/main_icons_assets/status_rejected_stamp_red.svg';
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return S.of(context).Approved;
      case 'pending':
        return S.of(context).Pending;
      case 'rejected':
        return S.of(context).Rejected;
      case 'cancelled':
      case 'canceled':
        return S.of(context).Canceled;
      default:
        return status;
    }
  }

  /// ✅ Get human-readable field labels with translations
  String _getFieldLabel(String fieldKey) {
    final labelMap = {
      // Basic fields
      'first_name': S.of(context).firstName,
      'middle_name': S.of(context).middleName,
      'last_name': S.of(context).lastName,
      'street': S.of(context).streetName,
      'city': S.of(context).city,
      'province': S.of(context).stateOrProvince,
      'country': S.of(context).country,
      'email': S.of(context).email,
      'phone': S.of(context).phoneNumber,
      'gender': S.of(context).gender,
      'date_of_birth': S.of(context).birthday,
      'marital_status': S.of(context).maritalStatus,

      // ✅ Emergency Contact — the firstContact/secondContact prefix is
      // stripped below, so these are keyed on the bare field name.
      'name': 'Name',
      'relationship': S.of(context).relationship,
      'language': S.of(context).language,

      // ✅ Health Insurance
      'insurance_name': 'Insurance Name',
      'insurance_policy_number': 'Insurance Policy Number',
    };

    // The contact these fields belong to is already clear from the section
    // header, so the prefix is dropped for EVERY field rather than spelled out
    // in the label ("Secondcontact Street" → "Street").
    final String bareKey = _toSnakeCase(_stripContactPrefix(fieldKey));

    return labelMap[bareKey] ?? _formatFieldName(bareKey);
  }

  /// Removes a leading firstContact / secondContact marker in any of the
  /// spellings the data uses: `secondContact_street`, `secondContactStreet`,
  /// `second_contact_street`.
  String _stripContactPrefix(String fieldKey) {
    final match = RegExp(
      r'^(first|second)_?contact_?',
      caseSensitive: false,
    ).firstMatch(fieldKey);

    if (match == null) return fieldKey;

    final stripped = fieldKey.substring(match.end);
    // Guard against a key that is nothing but the prefix.
    return stripped.isEmpty ? fieldKey : stripped;
  }

  /// `InsurancePolicyNumber` / `insurancePolicyNumber` → `insurance_policy_number`
  /// so camelCase and snake_case keys hit the same map entry.
  String _toSnakeCase(String value) => value
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (m) => '${m[1]}_${m[2]}',
      )
      .toLowerCase();

  /// ✅ Format field name as fallback (converts "secondContact_email" → "Second Contact Email")
  String _formatFieldName(String fieldKey) {
    return fieldKey
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  Widget _buildContent(bool lightMode, bool isMobile) {
    if (isLoading) {
      // CircleProgressMaster, not a bare CircularProgressIndicator: it is the
      // app's spinner — AppColors.lightPrimary on a 60% white track, sized off
      // the breakpoint.
      //
      // The SizedBox is what actually centres it. This return value is placed
      // inside a SingleChildScrollView (and on phone inside
      // SideFrameMasterServices' scroll view as well), so it is handed
      // UNBOUNDED height — a Center there has nothing to centre against and
      // shrink-wraps to the spinner, parking it at the top of the page. Giving
      // it a viewport-height box first is what puts it in the middle.
      //
      // The height is MEASURED, not guessed. A fraction of the screen (this
      // was 0.7) centres the spinner in the fraction, not in the page — 0.7
      // put it about a third of the way down. What is actually left for the
      // content is the viewport minus the system insets minus the frame's own
      // header, so that is what gets computed.
      final MediaQueryData mq = MediaQuery.of(context);

      // SideFrameMasterServices' breadcrumb on phone: a 15.sp top pad, one
      // line of fontSize24Weight600, and the 20.sp gap it puts above the
      // child.
      final double frameHeader = 15.sp + 34.sp + 20.sp;

      final double available =
          mq.size.height - mq.padding.top - mq.padding.bottom - frameHeader;

      return SizedBox(
        // Guard the subtraction: a short viewport (a split-screen tablet, a
        // large text scale) could drive it to zero or below, and a negative
        // height throws.
        height: available > 0 ? available : mq.size.height * 0.6,
        child: const Center(child: CircleProgressMaster()),
      );
    }

    // An empty request still gets the note card and the comment thread — the
    // reviewer may well be asking the submitter what happened to it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(lightMode),
        SizedBox(height: 8.h),

        // 21/9/2026 — review follow-up to report p.13: on tablet/desktop
        // Cancel sits on its own row under the header, aligned under the
        // requested date. Phones keep it in the status row at the bottom (see
        // _buildRequestNoteSection).
        if (_canCancel && !isMobile) ...[
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: _buildCancelButton(false),
          ),
          SizedBox(height: 8.h),
        ],

        if (changes.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(50.sp),
              child: Text(
                'No changes found in this request',
                style: StyleText.fontSize16Weight500.copyWith(
                    color: AppColors.secondaryText
                ),
              ),
            ),
          )
        else
          // MOVED 21/9/2026 — Cancel now sits at the end of the status row
          // (see _buildRequestNoteSection), where Settings bug report p.13
          // marked the empty slot.
          const SizedBox.shrink(),

          // One card for the whole request. Every changed field is a row inside
          // it, rather than each change getting its own container with the
          // section header repeated.
          _buildChangesCard(lightMode: lightMode, isMobile: isMobile),
        SizedBox(height: 16.h),

        _buildRequestNoteSection(lightMode),
        SizedBox(height: 16.h),

        _buildCommentsSection(isMobile),
        SizedBox(height: 16.h),
      ],
    );
  }

  /// Function Name: [_buildCommentsSection]
  ///
  /// Purpose: The inquiries-and-comments thread for this request, sitting under
  ///          the request note card.
  ///
  /// Reuses `UniversalCommentSection` (core/custom/36) rather than growing a
  /// second comment implementation: it already carries the Firestore stream,
  /// the attachment upload, the RTL handling and the expand/collapse header.
  ///
  /// The thread is keyed by the request id, so it is hidden entirely when the
  /// page was opened without one — there would be nothing to attach a comment
  /// to, and every request without an id would otherwise share one thread.
  ///
  /// Parameters:
  /// - [isMobile]: Phone layout, which gets a shorter collapsed thread.
  ///
  /// Returns: [Widget] the card, or an empty box when there is no request id.
  Widget _buildCommentsSection(bool isMobile) {
    final String requestId = widget.requestId ?? '';
    if (requestId.isEmpty) return const SizedBox.shrink();

    return Container(

      child: UniversalCommentSection(
        collectionPath: RequestCollectionPaths.requestCommentsCollection,
        // Written onto every new comment as well as filtering the stream —
        // `UniversalCommentSection` spreads these fields into the document.
        filterFields: <String, dynamic>{
          RequestCollectionPaths.commentRequestIdField: requestId,
        },
        currentUserId: _currentUserEmail,
        collapsedHeight: isMobile ? 320.h : 400.h,
      ),
    );
  }

  /// Who is writing. Comments are attributed by email — the same identifier
  /// [_decide] sends as the notification's sender, and the one
  /// `MainCoreEmployeeController` resolves names and departments from.
  String get _currentUserEmail {
    try {
      return Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '';
    } catch (_) {
      // The controller is not registered on every entry into this page.
      return '';
    }
  }

  Widget _buildHeader(bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).requestDetails,
          style: StyleText.fontSize16Weight600.copyWith(
              color: AppColors.text
          ),
        ),
        Spacer(),
        Text(
          "${S.of(context).requestedDate}: ",
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.secondaryText
          ),
        ),
        Text(
          _formatDate(requestTime),
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text
          ),
        ),
      ],
    );
  }

  /// The single card holding every change in the request.
  ///
  /// Landscape: two columns — "Current Details" and "New Details" — each
  /// listing all changed fields in the same order, so the two sides line up
  /// row for row. Portrait: the pair is stacked per field, separated by a
  /// divider, because two columns are too narrow to read on a phone.
  Widget _buildChangesCard({
    required bool lightMode,
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        // RADIUS 24/8/2026: containers are 8.r on this page, fields are 4.r.
        // This card was 4.r, which made it read like an oversized input.
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.card,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [


          // Drawn once for the whole request, not once per change. Cancel sits
          // at the end of this row rather than beside the status badge at the
          // bottom — it acts on the request as a whole, so it belongs with the
          // request's title.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child:
                    _buildSectionHeader(lightMode, _translateSectionTitle(section)),
              ),

            ],
          ),
          SizedBox(height: 20.h),
          if (isMobile)
            ..._buildStackedChanges(lightMode)
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildValueColumn(
                    lightMode: lightMode,
                    title: S.of(context).current_details,
                    titleColor:
                        lightMode ? AppColors.blackButton : AppColors.white,
                    isNew: false,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildValueColumn(
                    lightMode: lightMode,
                    title: S.of(context).new_details,
                    titleColor: AppColors.statusApproved,
                    isNew: true,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// One side of the comparison: a title plus every changed field's value.
  Widget _buildValueColumn({
    required bool lightMode,
    required String title,
    required Color titleColor,
    required bool isNew,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: StyleText.fontSize16Weight600.copyWith(color: titleColor),
        ),
        SizedBox(height: 15.h),
        for (int i = 0; i < changes.length; i++) ...[
          _buildFieldCell(
            lightMode: lightMode,
            change: changes[i],
            isNew: isNew,
          ),
          if (i != changes.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  /// Phone layout: current/new stacked per field, all still inside one card.
  List<Widget> _buildStackedChanges(bool lightMode) {
    final widgets = <Widget>[];

    for (int i = 0; i < changes.length; i++) {
      final change = changes[i];

      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).current_details,
              style:
                  StyleText.fontSize16Weight600.copyWith(color: AppColors.text),
            ),
            SizedBox(height: 8.h),
            _buildFieldCell(
              lightMode: lightMode,
              change: change,
              isNew: false,
            ),
            SizedBox(height: 12.h),
            Text(
              S.of(context).new_details,
              style: StyleText.fontSize16Weight600.copyWith(color: AppColors.statusApproved),
            ),
            SizedBox(height: 8.h),
            _buildFieldCell(
              lightMode: lightMode,
              change: change,
              isNew: true,
            ),
          ],
        ),
      );

      if (i != changes.length - 1) {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            // Bug report (Settings mobile p.9): at 8% opacity this line was
            // invisible, so two changed fields ran together. Same visible
            // divider as the Social Information card.
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.background,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  /// One changed field, on one side of the comparison.
  ///
  /// Takes the whole change rather than a bare value: a phone row carries its
  /// country code alongside the number (see [_mergeCountryCodeIntoPhone]) and
  /// is drawn as two boxes, so the cell has to see both.
  ///
  /// Keyed by its contents so the internal controller refreshes when the
  /// request data reloads — this used to build a TextEditingController on
  /// every paint, which was never disposed.
  Widget _buildFieldCell({
    required bool lightMode,
    required Map<String, String> change,
    required bool isNew,
  }) {
    final String fieldName = change['fieldName'] ?? '';
    final String value = (isNew ? change['newValue'] : change['oldValue']) ?? '';

    final String? countryCode =
        change[isNew ? _newCountryCodeKey : _oldCountryCodeKey];
    if (countryCode != null) {
      return _buildPhoneFieldCell(
        fieldName: fieldName,
        countryCode: countryCode,
        number: value,
        isNew: isNew,
      );
    }

    return _buildValueBox(
      fieldName: fieldName,
      value: value,
      isNew: isNew,
    );
  }

  /// Function Name: [_buildPhoneFieldCell]
  ///
  /// Purpose: A phone change as the reviewer edits it — a narrow read-only
  ///          country-code box beside a wide number box, under one label.
  ///
  /// Mirrors `_buildPhoneField` on the edit screen (same [_dialCodeWidth], same
  /// label-above-the-row layout), so the request reads the way the employee
  /// filled it in. The `Row` is direction-aware: under an Arabic UI the code
  /// box lands on the right, which is the leading edge there.
  ///
  /// The dial code is NOT put through `_displayValue`: it is a prefix to dial,
  /// not a quantity to read, so it stays in Latin digits like the email does.
  ///
  /// Parameters:
  /// - [fieldName]: The change's field key, used for the label.
  /// - [countryCode]: The dial code for this side of the comparison.
  /// - [number]: The phone number for this side.
  /// - [isNew]: Which side is being drawn; the current side is greyed.
  ///
  /// Returns: [Widget] the label plus the two boxes.
  Widget _buildPhoneFieldCell({
    required String fieldName,
    required String countryCode,
    required String number,
    required bool isNew,
  }) {
    final String label = _getFieldLabel(fieldName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Same style and gap CustomTextField draws its own label with (14.sp,
        // 6.sp below it), so this row's boxes line up with the boxes of every
        // other field in the column.
        Text(
          label,
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.text, fontSize: 14.sp),
        ),
        SizedBox(height: 6.sp),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: _dialCodeWidth,
              child: CustomTextField(
                key: ValueKey('$fieldName-code-$isNew-$countryCode'),
                initialValue: countryCode.isEmpty ? '-' : countryCode,
                textDirection: ui.TextDirection.ltr,
                textAlign: TextAlign.center,
                enabled: false,
                fillColor: isNew ? null : AppColors.background,
              ),
            ),
            SizedBox(width: 12.sp),
            // Expanded, not a second fixed width: the number is the long half
            // and takes whatever the column has left.
            Expanded(
              child: _buildValueBox(
                fieldName: fieldName,
                value: number,
                isNew: isNew,
                // The label is drawn once above the row, so neither box
                // repeats it.
                showLabel: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// One read-only box. The default rendering for every field that is not the
  /// split phone row, and the number half of the row that is.
  Widget _buildValueBox({
    required String fieldName,
    required String value,
    required bool isNew,
    bool showLabel = true,
  }) {
    final String display = _displayValue(fieldName, value);
    final String label = _getFieldLabel(fieldName);

    return CustomTextField(
      key: ValueKey('$fieldName-$isNew-$display-$showLabel'),
      label: showLabel ? label : null,
      hint: label,
      initialValue: display,
      enabled: false,
      fillColor: isNew ? null : AppColors.background,
    );
  }

  Widget _buildSectionHeader(bool lightMode, String sectionTitle) {
    bool isInsuranceSection =
        sectionTitle.contains('Insurance') || sectionTitle.contains('التأمين');

    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            // Container, not a field — 8.r like the cards around it.
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.primary.withOpacity(.15),
          ),
          child: Center(
            child: CustomSvgImage(
              assetPath: isInsuranceSection
                  ? "assets/icons_assets/main_icons_assets/insurance_document_shield.svg"
                  : "assets/icons_assets/main_icons_assets/emergency_contact_person.svg",
              width: 16.w,
              height: 16.h,
              fit: BoxFit.fill,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          sectionTitle,
          style: StyleText.fontSize18Weight500.copyWith(
              color: AppColors.text
          ),
        )
      ],
    );
  }


  Widget _buildRequestNoteSection(bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
          // Container -> 8.r. The note INPUT inside it keeps 4.r, which is
          // CustomTextField's own default, so it needs nothing passed here.
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.card
      ),
      child: Padding(
        padding: EdgeInsets.only( left:  10.sp, right: 10.sp,bottom: 10.sp),
        child: Column(
          children: [
            CustomTextField(
              hint: S.of(context).requestNote,
              controller: requestNoteController,
              enabled: false,
              label: S.of(context).requestNote,
              maxLines: 3,
              // ADDED 8/9/2026 — the n/500 counter was missing here.
              // CustomTextField only draws one when a limit is asked for
              // (`maxLength`, or `showCharCount` which implies 500); this call
              // passed neither. 500 matches the cap the note is written under
              // on the preview page, so the count reads against the same limit.
              maxLength: 500,
              textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            ),
            SizedBox(height: 20.h),

            // CHANGED 21/9/2026 — Settings bug report p.13: the status pill no
            // longer runs the full width with an empty slot at its end; while
            // the request can still be withdrawn, Cancel fills that slot.
            // Tablet/desktop: the status pill is a fixed 150.sp on the trailing
            // edge (Cancel moved to the header). Phone: the pill fills the row
            // and Cancel sits at its end.
            if (ContextExtension(context).isPhone)
              Row(
                children: [
                  Expanded(child: _buildStatusButton()),
                  if (_canCancel) ...[
                    SizedBox(width: 12.w),
                    _buildCancelButton(true),
                  ],
                ],
              )
            else
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SizedBox(width: 150.sp, child: _buildStatusButton()),
              ),
          ],
        ),
      ),
    );
  }

  /// Cancels the request. Only offered while it is still pending — an already
  /// approved or rejected request has been acted on and must not be withdrawn.
  Future<void> _cancelRequest() async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: 'assets/lottie_assets/main_lottie_assets/lottie_warning.json',
      confirmTitle: S.of(context).CancelRequest,
      confirmSubtitle: S.of(context).AreYousureYouWanttoCancelThisRequest,
      confirmYesText: S.of(context).yes,
      confirmNoText: S.of(context).no,
      onConfirm: () async {
        await _decide(RequestStatus.cancelled);
        // _decide surfaces its own error snackbar; report success to the dialog
        // only when the status actually changed.
        return status == RequestStatus.cancelled.wireValue;
      },
      successLottie: 'assets/lottie_assets/main_lottie_assets/correct.json',
      successTitle: S.of(context).Successful,
      successSubtitle: S.of(context).YouSuccessfullyCanceledThisRequest,
    );
  }

  /// Only a request still awaiting a decision can be withdrawn. Hidden while a
  /// write is in flight so it can't be submitted twice.
  bool get _canCancel =>
      RequestStatus.fromWire(status).isPending && !isProcessing;

  /// Cancel, built to match `MyRequestCancelButton` in the services module
  /// (`s6_services_requests/presentation/ui/widgets/my_request_cancel_button.dart`),
  /// so the two "cancel my request" actions look the same wherever the user
  /// meets them.
  ///
  /// CHANGED 8/9/2026 — was `customButtonWithSvg(width: 120.sp, height: 30.sp,
  /// image: '')`, which had two faults the services button had already fixed:
  ///
  ///   • `image: ''` asked for an icon and supplied no asset, so the button
  ///     rendered as a bare label while its services twin shows a minus-circle;
  ///   • 30.sp made it shorter than every other control on this page — the
  ///     status pill in `_buildStatusButton` is 36.sp — so it read as
  ///     undersized beside them. That is the same miss the services button
  ///     records in its own comment, at the same 30.sp.
  ///
  /// The icon goes through `CustomSvgImage` rather than `SvgPicture` directly:
  /// it is what the rest of this file already uses, so no new import.
  Widget _buildCancelButton(bool isMobile) {
    return GestureDetector(
      onTap: _cancelRequest,
      child: Container(
        // Same pair of widths the services button uses, by form factor.
        width: isMobile ? 135.sp : 150.sp,
        height: 36.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          color: AppColors.red,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomSvgImage(
              assetPath:
                  'assets/icons_assets/main_icons_assets/minus_circle_red.svg',
              width: 20.sp,
              height: 20.sp,
              fit: BoxFit.fill,
              // The asset is drawn red; on a red button it has to be white.
              color: AppColors.white,
            ),
            SizedBox(width: 8.sp),
            Text(
              S.of(context).Cancel,
              style: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton() {
    // CHANGED 8/9/2026 — the status pill spans the full width of its card
    // instead of a fixed 200.w parked on the trailing edge.
    //
    // The outer `Row(mainAxisAlignment: end)` only existed to push a
    // fixed-width box to one side; with the box full width it had nothing left
    // to align, so it is gone. The INNER Row still centres the icon and label,
    // which is what keeps the pill's contents in the middle now that the box is
    // wider than they are.
    //
    // `double.infinity` is safe here: the caller places this in a Column inside
    // a Padding (_buildRequestNoteSection), so the incoming width is bounded.
    // It would assert if this were ever moved into an unbounded-width parent
    // such as a Row or a horizontal ListView.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _getStatusColor(status)),
      ),
      width: double.infinity,
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomSvgImage(
            assetPath: _getStatusIcon(status),
            width: 24.w,
            height: 24.h,
            fit: BoxFit.scaleDown,
          ),
          SizedBox(width: 8.w),
          Text(
            _getStatusLabel(status),
            style: StyleText.fontSize16Weight500.copyWith(
              color: _getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    final contentWidget = _buildContent(lightMode, isMobile);

    if (isMobile) {
      return Scaffold(
        body: SideFrameMasterServices(
          titleText: S.of(context).settings,
          onFirstTap: () {},
          secondTitle: S.of(context).requestDetails,
          child: SingleChildScrollView(
            child: contentWidget,
          ),
        ),
      );
    }

    return SideFrameMasterServices(
      titleText: S.of(context).settings,
      onFirstTap: () {
        Navigator.pop(context);
      },
      secondTitle: S.of(context).requestDetails,
      onSecondTap: () {},
      child: SingleChildScrollView(
        child: contentWidget,
      ),
    );
  }
}