/// ************************* FILE INFO *************************** ///
/// File Name: grc_module_owners_tab.dart
/// Purpose: Control Owners tab body for GrcModuleDetailsPage. Renders the owner
///          request buttons, search, department filter, add/bulk-upload action,
///          and the owner list for a single GRC Module.
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 27/7/2026
library;

import 'package:knowticed_plus/features/grc/control/domain/entities/assigning_control.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notification_service.dart';
import 'package:knowticed_plus/features/grc/shared/services/grc_assignee_notifier.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/1-custom_dropdown.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/employee_helper.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/assignee_bulk_upload/assignee_bulk_upload_page.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/domain/entities/owner_entity.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/ui/pages/add_owner_page.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/ui/pages/control_owner_details_page.dart';
import 'package:knowticed_plus/features/grc/grc_request/domain/entities/grc_request_type.dart';
import 'package:knowticed_plus/features/grc/grc_request/presentation/ui/pages/grc_requests_list_page.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_module_person_card.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/51-custom_pop_up.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_department_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [GrcModuleOwnersTab]
///
/// purpose: Control Owners tab for a single [GRCModuleEntity]. Reads the
///          provided [OwnerCubit] from the widget tree and owns its own search
///          and department-filter state.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 27/7/2026
class GrcModuleOwnersTab extends StatefulWidget {
  final GRCModuleEntity module;

  const GrcModuleOwnersTab({super.key, required this.module});

  @override
  State<GrcModuleOwnersTab> createState() => _GrcModuleOwnersTabState();
}

class _GrcModuleOwnersTabState extends State<GrcModuleOwnersTab> {
  final _ownerSearchController = TextEditingController();
  final GlobalKey _addOwnerButtonKey = GlobalKey();
  String _ownerSearchQuery = '';
  String? _ownerDepartmentFilter;

  /// Policy / Control names for the chips on each owner row. Loaded once
  /// per module visit; the rows fall back to raw ids until they arrive.
  final Map<String, String> _policyNames = {};
  final Map<String, String> _controlNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNames());
  }

  Future<void> _loadNames() async {
    final OwnerCubit cubit = context.read<OwnerCubit>();
    final bool isArabic = context.isArabic;
    final policies =
        await cubit.getAllPolicies(moduleId: widget.module.moduleId);
    for (final policy in policies.fold((_) => <PolicyEntity>[], (p) => p)) {
      _policyNames[policy.id] =
          isArabic ? policy.policyNameAr : policy.policyNameEn;
      final controls = await cubit.getAllControlsForPolicy(
          moduleId: widget.module.moduleId, policyId: policy.id);
      for (final control in controls.fold((_) => <ControlEntity>[], (c) => c)) {
        _controlNames['${policy.id}/${control.id}'] =
            isArabic ? control.controlsNameAr : control.controlsNameEn;
      }
    }
    if (mounted) setState(() {});
  }

  List<String> _ownerPolicyNames(OwnerEntity owner) => [
        for (final id in owner.assigningControls.map((a) => a.policyId).toSet())
          _policyNames[id] ?? id,
      ];

  List<String> _ownerControlNames(OwnerEntity owner) => [
        for (final a in owner.assigningControls)
          _controlNames['${a.policyId}/${a.controlId}'] ?? a.controlId,
      ];

  @override
  void dispose() {
    _ownerSearchController.dispose();
    super.dispose();
  }

  Future<void> _showOwnerCreationMenu(BuildContext context) async {
    final buttonBox =
        _addOwnerButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(Offset(0, buttonBox.size.height),
            ancestor: overlayBox),
        buttonBox.localToGlobal(buttonBox.size.bottomRight(Offset.zero),
            ancestor: overlayBox),
      ),
      Offset.zero & overlayBox.size,
    );

    final choice = await showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      color: AppColors.card,
      items: [
        HoverablePopupMenuItem(value: 'add', label: S.of(context).addOwner),
        HoverablePopupMenuItem(
            value: 'bulk', label: S.of(context).bulkUpload),
      ],
    );

    if (!context.mounted) return;
    if (choice == 'add') {
      final result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AddOwnerPage(
            moduleId: widget.module.moduleId,
            moduleNameEn: widget.module.moduleNameEn,
            moduleNameAr: widget.module.moduleNameAr,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      if (result == true && context.mounted) {
        context
            .read<OwnerCubit>()
            .getAllOwners(moduleId: widget.module.moduleId);
      }
    } else if (choice == 'bulk') {
      final ownerCubit = context.read<OwnerCubit>();
      final Set<String> bulkAssignees = <String>{};
      AssigningControlEntity? bulkFirstPair;
      final result = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => AssigneeBulkUploadPage(
            moduleId: widget.module.moduleId,
            assigneeLabel: S.of(context).controlOwner,
            createAssignee: ({
              required moduleId,
              required email,
              required assigningControls,
              required editorId,
            }) async {
              // notify: false — the batch is announced once, after the page
              // closes (GrcAssigneeNotifier.bulkUploaded below).
              final created = await ownerCubit.createOwner(
                moduleId: moduleId,
                ownerEmail: email,
                assigningControls: assigningControls,
                notify: false,
              );
              if (created.isRight()) {
                bulkAssignees.add(email);
                bulkFirstPair ??= assigningControls.isEmpty
                    ? null
                    : assigningControls.first;
              }
              return created;
            },
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
      if (bulkAssignees.isNotEmpty) {
        GrcAssigneeNotifier.bulkUploaded(
          role: GrcAssigneeRole.owner,
          moduleId: widget.module.moduleId,
          assigneeEmails: bulkAssignees,
          first: bulkFirstPair,
        );
      }
      if (result == true && context.mounted) {
        context
            .read<OwnerCubit>()
            .getAllOwners(moduleId: widget.module.moduleId);
      }
    }
  }

  List<OwnerEntity> _applyOwnerFilters(
      BuildContext context, List<OwnerEntity> owners) {
    var result = owners;
    if (_ownerDepartmentFilter != null && _ownerDepartmentFilter!.isNotEmpty) {
      result = result.where((o) {
        final employee = findEmployeeByEmail(o.ownerEmail);
        if (employee == null) return false;
        final department = EmployeeHelper.getEmployeeLocalizeDepartment(
            employee: employee, context: context);
        return department == _ownerDepartmentFilter;
      }).toList();
    }
    if (_ownerSearchQuery.isNotEmpty) {
      final q = _ownerSearchQuery.toLowerCase();
      result = result
          .where((o) =>
              employeeDisplayName(context, o.ownerEmail)
                  .toLowerCase()
                  .contains(q) ||
              o.ownerEmail.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  void _openRequests(BuildContext context, {required bool mine}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrcRequestsListPage(
          module: widget.module,
          onlyRequestedBy: mine ? currentGrcUserEmail() : null,
          typeFilter: GrcRequestType.reassignOwner,
        ),
      ),
    );
  }

  /// Phone height of the Requests buttons and the search / filter / add
  /// row.
  double get _phoneHeight => 36.sp;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    return BlocBuilder<OwnerCubit, OwnerState>(
      builder: (context, state) {
        final owners =
            state is OwnerListLoaded ? state.owners : <OwnerEntity>[];
        final filtered = _applyOwnerFilters(context, owners);

        final TextStyle buttonText =
            StyleText.fontSize16Weight400.copyWith(color: AppColors.textButton);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone: 36.sp tall (customButton draws 38.sp; the box wins).
            SizedBox(
              height: isMobile ? _phoneHeight : null,
              child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                customButton(
                  title: S.of(context).myRequests,
                  function: () => _openRequests(context, mine: true),
                  width: 135.w,
                  color: AppColors.primary,
                  textStyle: buttonText,
                ),
                SizedBox(width: 10.w),
                customButton(
                  title: S.of(context).requests,
                  function: () => _openRequests(context, mine: false),
                  width: 135.w,
                  color: AppColors.primary,
                  textStyle: buttonText,
                ),
              ],
            ),
            ),
            SizedBox(height: 15.h),
            SizedBox(
              height: isMobile ? _phoneHeight : null,
              child: Row(
              spacing: 10.w,
              children: [
                AppSearchTextField(
                  // Raw value — the field applies .sp. 36 on a phone.
                  height: isMobile ? 36.0 : null,
                  onChanged: (v) => setState(() => _ownerSearchQuery = v),
                  hintText: S.of(context).search,
                  controller: _ownerSearchController,
                ),
                // 768 / 1024: a labelled Department dropdown.
                // 375: the sliders button in the same slot.
                if (isMobile)
                  GrcDepartmentFilterButton(
                        size: _phoneHeight,
                    value: _ownerDepartmentFilter,
                    onChanged: (v) =>
                        setState(() => _ownerDepartmentFilter = v),
                  )
                else
                  SizedBox(
                    width: 106.w,
                    child: CustomDropdown<String>(
                      hint: S.of(context).department,
                      items: [
                        DropdownItem<String>(
                            value: '', label: S.of(context).all),
                        for (final label in grcDepartmentLabels(context))
                          DropdownItem<String>(value: label, label: label),
                      ],
                      value: _ownerDepartmentFilter ?? '',
                      onChanged: (v) => setState(() =>
                          _ownerDepartmentFilter = v.isEmpty ? null : v),
                      fillColor: AppColors.card,
                      required: false,
                      // GRC bug report p30: same height (38) and radius (8)
                      // as the Add Owner button next to it.
                      height: 38,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                Container(
                  key: _addOwnerButtonKey,
                  child: customButtonWithSvg(
                    colorBorder: AppColors.transparent,
                    space: 10.w,
                    widthImage: 18.sp,
                    heightImage: 18.sp,
                    function: () => _showOwnerCreationMenu(context),
                    fixedWidth: isMobile ? _phoneHeight : null,
                    fixedHeight: isMobile ? _phoneHeight : null,
                    title: isMobile ? '' : S.of(context).addOwner,
                    textStyle: buttonText,
                    image: AppAssets.add,
                    color: AppColors.primary,
                    svgColor: AppColors.textButton,
                  ),
                ),
              ],
            ),
            ),
            SizedBox(height: 15.h),
            Expanded(child: _buildOwnerList(context, state, filtered)),
          ],
        );
      },
    );
  }

  Widget _buildOwnerList(
    BuildContext context,
    OwnerState state,
    List<OwnerEntity> owners,
  ) {
    if (state is OwnerLoading) {
      return Center(child: const CircleProgressMaster());
    }
    if (state is OwnerFailure) {
      return Center(
        child: Text(
          state.message,
          style: StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
          textAlign: TextAlign.center,
        ),
      );
    }
    // The app's one empty state (see 89-custom_empty_state.dart).
    if (owners.isEmpty) {
      return const Center(child: CustomEmptyState());
    }
    // One wide row per owner at every width, as MAGDY draws it.
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.separated(
        itemCount: owners.length,
        separatorBuilder: (_, __) => SizedBox(height: 15.h),
        itemBuilder: (_, index) {
          final owner = owners[index];
          return GrcModulePersonCard(
            email: owner.ownerEmail,
            policyNames: _ownerPolicyNames(owner),
            controlNames: _ownerControlNames(owner),
            onTap: () async {
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ControlOwnerDetailsPage(
                    owner: owner,
                    module: widget.module,
                  ),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
              if (context.mounted) {
                context
                    .read<OwnerCubit>()
                    .getAllOwners(moduleId: widget.module.moduleId);
              }
            },
          );
        },
      ),
    );
  }
}
