/// Module: roles / r2_user_management / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: request_page_approval.dart
/// Purpose: Declares `RequestPageApproval`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.
/// Updated: 25/8/2026 - Search now uses the shared AppSearchTextField.

import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_section_label.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// REMOVED 25/8/2026: `2-custom_textfield.dart` — the only CustomTextField on
// this page was the search box, now AppSearchTextField (which wraps it).
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/core/helper/inventory_module/core/navigate.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s2_details_service/details_service/widget/info_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/features/roles/r2_user_management/presentation/ui/pages/user_management_details_request.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/network/get_base_url.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/roles/r4_active_directory/domain/entities/employee_entity.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/Category/presentation/ui/services_admin/Widget/W3_Frame_Screen_tablet.dart';
// REMOVED_MODULE: import '../../../../../../external/services_mangment_module/core/new_theme.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/details_request.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/data/role_log_service.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/constants/firebase_collections.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
part '../widgets/request_page_approval_methods1.dart';

/// Canonical status keys — `selectStatus` holds one of these, never a
/// localized display label.
///
/// Library-level rather than static members of the State class: the methods
/// live in an extension (see the part file above), and Dart requires statics
/// of the extended type to be qualified by the type name. Top-level constants
/// are visible unqualified to both the class and the extension.
const String kAll = 'All';
const String kApproved = 'approved';
const String kPending = 'pending';
const String kRejected = 'rejected';
const String kCancelled = 'cancelled';


class RequestPageApproval extends StatefulWidget {
  const RequestPageApproval({super.key});

  @override
  State<RequestPageApproval> createState() => _RequestPageApprovalState();
}

class _RequestPageApprovalState extends State<RequestPageApproval> {
  String selectStatus = kAll;

  /// true = newest first, false = earliest submitted first.
  bool sortMostRecentFirst = true;

  /// Whether the user has picked a sort option from the menu. Drives the sort
  /// button's active look (primary fill + textButton foreground). The button
  /// always shows the "Sort" hint — never the chosen value.
  bool sortSelected = false;

  /// Anchor for the sort dropdown.
  ///
  /// The menu opens directly under this button and matches its width, so it
  /// reads as part of the control instead of sliding up from the bottom of the
  /// window. `_showSortMenu` measures this key's RenderBox to place it. It
  /// lives on the State because `RequestPageApprovalMethods1` is an extension,
  /// and Dart extensions cannot declare fields.
  final GlobalKey _sortButtonKey = GlobalKey();

  // Derived from allRequests rather than cached in fields: cached copies go
  // stale whenever the list changes without a re-fetch (or on hot reload,
  // which keeps the State object), leaving the chips disagreeing with the
  // cards below them.
  int get totalRequests => allRequests.length;
  int get pendingCount => _countOf(kPending);
  int get approvedCount => _countOf(kApproved);
  int get rejectedCount => _countOf(kRejected);
  int get cancelledCount => _countOf(kCancelled);

  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];

  TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  // Track which cards are being actioned (to show loading per card)
  Set<String> _actioningIds = {};

  @override
  void initState() {
    super.initState();
    RoleLogService.log(RoleLogService.pageRequestApproval);
    _fetchRequestsFromFirebase();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterRequests();
  }

  /// Function Name: [_fetchRequestsFromFirebase]
  ///
  /// Purpose: Load the review queue — every employee's change requests.
  ///
  /// FIXED 24/8/2026. This filtered on `.where('employeeId', isEqualTo:
  /// employeeId)` using the SIGNED-IN reviewer's own id, so the User Management
  /// Requests screen showed the reviewer their own requests and nobody else's.
  /// A reviewer who had never raised a request saw an empty queue no matter how
  /// many were waiting, which is why submitted requests appeared to vanish.
  ///
  /// This screen is only reachable behind the `Users_Requests` permission (see
  /// the Requests button in `user_management_home.dart`), so the whole
  /// collection is the right scope: it is the queue, not a personal list. The
  /// employee's own view of their requests lives in
  /// `settings/se6_requests/request_page.dart` and still filters by id.
  Future<void> _fetchRequestsFromFirebase() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String basePath = getBaseUrl('Modules');

      final querySnapshot = await FirebaseFirestore.instance
          .doc('$basePath/roles')
          .collection(FirebaseCollections.employeesRequest)
          .orderBy('requestDate', descending: true)
          .get();

      List<Map<String, dynamic>> requests = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        requests.add({
          'id': doc.id,
          'title': data['section'] ?? 'Personal Information',
          'dateRequested': data['requestDate']?.millisecondsSinceEpoch ?? 0,
          'status': data['status'] ?? 'pending',
          'requestNote': data['requestNote'] ?? '',
          'employeeId': data['employeeId'] ?? '',
          'employeeEmail': data['employeeEmail'] ?? '',
          // Written by the preview screens when the request is submitted.
          'employeeName': data['employeeName'] ?? '',
          'section': data['section'] ?? '',
          'whatChanged': data['whatChanged'] ?? '',
          'oldValue': data['oldValue'] ?? '',
          'newValue': data['newValue'] ?? '',
        });
      }

      setState(() {
        allRequests = requests;
        _filterRequests();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      _showMessage(
        context,
        title: S.of(context).error,
        message: 'Failed to load requests: ${e.toString()}',
        background: AppColors.red,
      );
    }
  }

  /// Shows a transient message via the framework's Scaffold messenger.
  ///
  /// Replaces `Get.snackbar` (GetX is banned): the snack bar is now scoped to
  /// this route instead of a global overlay.
  void _showMessage(
    BuildContext context, {
    required String title,
    required String message,
    required Color background,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(message, style: TextStyle(color: AppColors.white)),
            ],
          ),
        ),
      );
  }









  @override
  Widget build(BuildContext context) {
    var isMobile = ContextExtension(context).isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;

    return isLoading
        ? Center(child: CircleProgressMaster())
        : RefreshIndicator(
      onRefresh: _fetchRequestsFromFirebase,
      child: SideFrameMasterServices(
        titleText: S.of(context).userManagement,
        onFirstTap: () {
          Navigator.of(context).pop();
        },
        secondTitle: S.of(context).requests,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: filterSection()),
              SizedBox(height: 20.h),
              Row(
                children: [
                  // REPLACED 25/8/2026: a search box hand-rolled out of
                  // CustomTextField. [AppSearchTextField] is the app's search
                  // field — it owns the magnifier, the hint, the 38 height and
                  // the vertical-centring fix documented in that file, so
                  // screens stop re-deriving them and drifting apart.
                  //
                  // It supplies its OWN `Expanded`, so it goes straight into
                  // this Row with no wrapper. The hint goes too: the widget
                  // already defaults to `S.of(context).search`, the same key
                  // this was passing.
                  AppSearchTextField(
                    controller: searchController,
                    fillColor: AppColors.card,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) {
                      _onSearchChanged();
                    },
                  ),
                  SizedBox(width: 15.w),
                  GestureDetector(
                    onTap: _showSortMenu,
                    child: Container(
                    key: _sortButtonKey,
                    width: isMobile ? 38.w : 100.w,
                    height: 35.sp,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: sortSelected ? AppColors.primary : AppColors.card,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isMobile
                            ? Center(
                            child: CustomSvgImage(
                              assetPath:
                              "assets/icons_assets/main_icons_assets/sort_lines.svg",
                              width: 20.w,
                              height: 20.h,
                              fit: BoxFit.scaleDown,
                              color: sortSelected
                                  ? AppColors.textButton
                                  : AppColors.secondaryText,
                            ))
                            : Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Center(
                              child: CustomSvgImage(
                                assetPath:
                                "assets/icons_assets/main_icons_assets/sort_lines.svg",
                                width: 20.w,
                                height: 20.h,
                                fit: BoxFit.scaleDown,
                                color: sortSelected
                                    ? AppColors.textButton
                                    : AppColors.secondaryText,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              S.of(context).sort,
                              style: StyleText.fontSize16Weight500
                                  .copyWith(
                                  color: sortSelected
                                      ? AppColors.textButton
                                      : AppColors.secondaryText),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  )
                ],
              ),
              SizedBox(height: 20.h),
              filteredRequests.isEmpty
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 150.h),
                  Center(
                    child: Lottie.asset(
                      "assets/lottie_assets/notification_lottie_assets/empty.json",
                      width: 300.w,
                      height: 300.h,
                      repeat: true,
                    ),
                  ),
                ],
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: CrossAxisCountHelper
                      .getCrossAxisCountForDefaultTablet2(context),
                  mainAxisSpacing: 15.sp,
                  crossAxisSpacing: 15.sp,
                  // Taller than before: the card gained a "Requested By" row
                  // on top of the date, job title, department and status.
                  mainAxisExtent: 210.sp,
                ),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  final status = request['status'] ?? 'pending';
                  final statusColor = _getStatusColor(status);
                  final requestId = request['id'] as String;
                  final isPending = status == 'pending';
                  final isActioning =
                  _actioningIds.contains(requestId);

                  final MainCoreEmployeeController employeeController =
                  AppControllers.employee;
                  final employeeEmail =
                      request['employeeEmail'] ?? '';

                  final jobTitle = employeeEmail.isNotEmpty
                      ? employeeController
                      .getEmployeeJobTitle(employeeEmail)
                      : '-';
                  final department = employeeEmail.isNotEmpty
                      ? employeeController
                      .getEmployeeDepartmentName(employeeEmail)
                      : '-';

                  // Prefer the name stored on the request; fall back to a
                  // directory lookup for records written before that field
                  // existed.
                  final storedName =
                      (request['employeeName'] ?? '').toString().trim();
                  final requestedBy = storedName.isNotEmpty
                      ? storedName
                      : (employeeEmail.isNotEmpty
                          ? employeeController.getEmployeeName(employeeEmail)
                          : '-');

                  return GestureDetector(
                    onTap: () async {
                      // Awaited: the details screen can approve / reject /
                      // cancel the request, which changes the status this list
                      // groups and counts by. Without re-fetching on return the
                      // page keeps showing what initState loaded, so the tabs
                      // only updated after the widget was rebuilt from scratch
                      // (i.e. an app restart).
                      await navigateToAsync(
                        context,
                        UserManagementDetailsRequestSettings(
                          requestId: requestId,
                          requestData: {
                            'employeeId': request['employeeId'],
                            'employeeEmail':
                            request['employeeEmail'],
                            'section': request['section'],
                            'whatChanged': request['whatChanged'],
                            'oldValue': request['oldValue'],
                            'newValue': request['newValue'],
                            'status': request['status'],
                            'requestDate': request['dateRequested'],
                            'requestNote': request['requestNote'],
                          },
                        ),
                      );

                      if (!mounted) return;
                      await _fetchRequestsFromFirebase();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: AppColors.card,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.sp),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ── Header row ──────────────────────
                            Row(
                              children: [
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(4.r),
                                    color: AppColors.background,
                                  ),
                                  child: Center(
                                    child: CustomSvgImage(
                                      assetPath: request["section"] ==
                                          "Personal Information"
                                          ? "assets/icons_assets/settings_assets/employee_id_card.svg"
                                          : "assets/icons_assets/main_icons_assets/health_insurance_card.svg",
                                      width: 30.w,
                                      height: 30.h,
                                      fit: BoxFit.fill,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: Text(
                                    // FIXED 13/8/2026: rendered the raw
                                    // English `section` from Firestore.
                                    RequestSectionLabel.of(
                                        context, request['title'] as String?),
                                    style: StyleText
                                        .fontSize14Weight500
                                        .copyWith(
                                        color: AppColors.text),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),

                            // ── Requested By (person, not the date) ─────
                            _infoRow(
                              icon: "assets/icons_assets/main_icons_assets/person_outline.svg",
                              label: "${S.of(context).requestedBy}: ",
                              value: FormatHelper.capitalize(requestedBy),
                              lightMode: lightMode,
                              ellipsis: true,
                            ),
                            SizedBox(height: 8.h),

                            // ── Request Date ────────────────────────────
                            _infoRow(
                              icon: "assets/icons_assets/roles_assets/calendar.svg",
                              label: "${S.of(context).requestDate}: ",
                              value: _formatDate(
                                  request['dateRequested']),
                              lightMode: lightMode,
                            ),
                            SizedBox(height: 8.h),

                            // ── Job Title ───────────────────────
                            _infoRow(
                              icon: "assets/icons_assets/main_icons_assets/Case.svg",
                              label:
                              "${S.of(context).jobTitle}: ",
                              value: FormatHelper.capitalize(
                                  jobTitle),
                              lightMode: lightMode,
                              ellipsis: true,
                            ),
                            SizedBox(height: 8.h),

                            // ── Department ──────────────────────
                            _infoRow(
                              icon: "assets/icons_assets/roles_assets/department_hierarchy_people.svg",
                              label:
                              "${S.of(context).department}: ",
                              value: FormatHelper.capitalize(
                                  department),
                              lightMode: lightMode,
                              ellipsis: true,
                            ),
                            SizedBox(height: 8.h),

                            // ── Status ──────────────────────────
                            Row(
                              children: [
                                CustomSvgImage(
                                  assetPath: "assets/icons_assets/main_icons_assets/status_pulse_line.svg",
                                  width: 14.w,
                                  height: 14.h,
                                  fit: BoxFit.scaleDown,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${S.of(context).status}: ",
                                  style: StyleText
                                      .fontSize12Weight400
                                      .copyWith(
                                      color: AppColors.text),
                                ),
                                Text(
                                  _getStatusLabel(status),
                                  style: StyleText
                                      .fontSize12Weight400
                                      .copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



}
