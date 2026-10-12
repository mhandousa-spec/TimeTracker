/// Module: GRC Policy Management
/// Description: Read-only "view mode" body of the Policy Details page —
///              info card, owner section, documents, and the Controls list
///              with its status filter bar, search box, and add/bulk-upload
///              menu.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-07-18
/// Dependencies: Flutter SDK, AppColors, AppTheme, CardStyles, ControlEntity,
///               GrcOwnerSection, ControlCardWidget, FilterBarItem
library;

import 'package:knowticed_plus/core/custom/22-custom_uploaded_document_card.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/39-custom_grid_button.dart';
import 'package:knowticed_plus/core/custom/40-custom_table_button.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/52-custom_upload_document.dart'
    show fileNameOf;
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_entity.dart';
import 'package:knowticed_plus/features/grc/control/domain/entities/control_status.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/add_edit_control_page.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_details_page.dart';
import 'package:knowticed_plus/features/grc/control/presentation/ui/pages/control_weight_issue/control_weight_issue_page.dart';
import 'package:knowticed_plus/features/grc/control_champion/presentation/controller/champion_cubit.dart';
import 'package:knowticed_plus/features/grc/control_owner/presentation/controller/owner_cubit.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/widgets/grc_details_widget/grc_owner_section.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_entity.dart';
import 'package:knowticed_plus/features/grc/control/presentation/controller/control_cubit.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/control_card_widget.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/grc_control_table_view.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';
import 'package:knowticed_plus/features/grc/policy/domain/entities/policy_document_info.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/grc_policy_widget/policy_document_preview_widget.dart';
import 'package:knowticed_plus/features/grc/policy/presentation/ui/widgets/policy_details_widget/grc_owner_badge.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:knowticed_plus/generated/l10n.dart';

/// class name: [PolicyViewModeWidget]
///
/// purpose: renders the "Policy Details" read-only view — info rows, owner
///          section, documents, and the filterable/searchable Controls
///          list. Owns the controls-toolbar UI state (status filter, search
///          text, add/bulk-upload dropdown) since none of it is needed
///          outside view mode.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 18/7/2026
/// The two actions on the "Control" button's menu.
enum _ControlMenuAction { addControl, bulkUpload }

class PolicyViewModeWidget extends StatefulWidget {
  final PolicyEntity policy;
  final GRCModuleEntity module;
  final List<ControlEntity> controls;
  final bool isArabic;
  final DateFormat dateFormat;
  final ValueChanged<ControlEntity?> onControlTap;
  final VoidCallback onBulkUpload;
  final VoidCallback onControlsChanged;

  const PolicyViewModeWidget({
    super.key,
    required this.policy,
    required this.module,
    required this.controls,
    required this.isArabic,
    required this.dateFormat,
    required this.onControlTap,
    required this.onBulkUpload,
    required this.onControlsChanged,
  });

  @override
  State<PolicyViewModeWidget> createState() => _PolicyViewModeWidgetState();
}

class _PolicyViewModeWidgetState extends State<PolicyViewModeWidget> {
  String _selectedControlStatusFilter = 'all';
  final _controlSearchController = TextEditingController();

  /// The typed query, held as state rather than read back off the controller.
  /// Assigning `controller.text` inside setState (what this used to do) both
  /// rebuilds AND resets the selection, so the caret jumped to position 0 on
  /// every keystroke. GrcModulePoliciesTab keeps the query in a field for the
  /// same reason; this is that field.
  String _controlSearchQuery = '';

  /// Card list (grid) vs. table, exactly as GrcModulePoliciesTab means it:
  /// cards first, table on request. Phones stay on cards -- the toggle is not
  /// rendered there, because an 11-column table has nowhere to go at 375.
  bool _isGridView = true;

  /// Anchor for the "Control" menu. The menu is positioned against this
  /// button's rect in the overlay, so it needs the button's RenderBox.
  final GlobalKey _controlButtonKey = GlobalKey();

  @override
  void dispose() {
    _controlSearchController.dispose();
    super.dispose();
  }

  Widget _infoRow(String label, String value, {double size = 14}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text.rich(
        TextSpan(
          text: '$label ',
          style: CardStyles.label(size),
          children: [TextSpan(text: value, style: CardStyles.value(size))],
        ),
      ),
    );
  }

  ControlStatus? _statusForControlKey(String key) {
    for (final status in ControlStatus.values) {
      if (status.value == key) return status;
    }
    return null;
  }

  /// Chip color per [ControlStatus], keyed by the enum itself rather than
  /// its display string so a renamed display label can't silently drop the
  /// color mapping.
  Color _colorForControlStatus(ControlStatus status) {
    switch (status) {
      case ControlStatus.active:
        return AppColors.green;
      case ControlStatus.inactive:
        return AppColors.orange;
      case ControlStatus.scheduled:
        return AppColors.primary;
      case ControlStatus.expired:
        return AppColors.red;
      case ControlStatus.unassigned:
        return AppColors.blue;
      case ControlStatus.draft:
        return AppColors.colorGrey;
    }
  }

  List<ControlEntity> _applyControlStatusFilter(List<ControlEntity> controls) {
    final status = _statusForControlKey(_selectedControlStatusFilter);
    if (status == null) return controls;
    return controls.where((c) => c.status == status).toList();
  }

  /// Applies both the status chip filter and the search box text on top of
  /// the raw controls list. Kept as a single entry point so the rest of the
  /// UI never has to call two filter functions in the right order.
  ///
  /// NOTE: this assumes [ControlEntity] exposes `controlNameEn` /
  /// `controlNameAr`, mirroring the `policyNameEn` / `policyNameAr` naming
  /// convention used everywhere else in this codebase. If the real field
  /// names differ, update the two references below.
  List<ControlEntity> _visibleControls() {
    final byStatus = _applyControlStatusFilter(widget.controls);
    final query = _controlSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return byStatus;
    return byStatus.where((c) {
      final nameEn = c.controlsNameEn.toLowerCase();
      final nameAr = c.controlsNameAr.toLowerCase();
      return nameEn.contains(query) || nameAr.contains(query);
    }).toList();
  }

  Map<String, int> _countControlsByStatus(List<ControlEntity> controls) {
    return {
      'all': controls.length,
      for (final status in ControlStatus.values)
        status.value: controls.where((c) => c.status == status).length,
    };
  }

  /// The order the chips appear in, fixed here rather than taken from
  /// `ControlStatus.values` (declaration order: Draft first). The Policies tab
  /// reads All / Active / Inactive / Scheduled / Expired / Draft, so the
  /// Controls bar one level down reads the same, with Unassigned -- which only
  /// controls have -- slotted in before Draft.
  static const List<ControlStatus> _statusBarOrder = <ControlStatus>[
    ControlStatus.active,
    ControlStatus.inactive,
    ControlStatus.scheduled,
    ControlStatus.expired,
    ControlStatus.unassigned,
    ControlStatus.draft,
  ];

  List<MapEntry<String, Map<String, dynamic>>> _controlStatusEntries(
      List<ControlEntity> controls) {
    final counts = _countControlsByStatus(controls);
    return [
      MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
      for (final status in _statusBarOrder)
        MapEntry(status.value, {
          'num': counts[status.value] ?? 0,
          'color': _colorForControlStatus(status),
        }),
    ];
  }

  /// Policy Number on the left, Last Edit date on the right — matches the
  /// top row of the "Policy Details" card in the design.
  Widget _buildNumberAndLastEditRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _infoRow(
            '${S.of(context).policyNumber}:',
            widget.isArabic
                ? widget.policy.policyNumberAr
                : widget.policy.policyNumberEn,
          ),
        ),
        _infoRow(
          '${S.of(context).lastEdit}:',
          widget.dateFormat.format(widget.policy.lastModifiedDate),
          // Last Edit is 12.sp (label and date).
          size: 12,
        ),
      ],
    );
  }

  /// Weight / Start Date / End Date. iPad (768) and desktop (1024) show the
  /// three on one row; the 375 design stacks them, one label/value per line.
  Widget _buildWeightAndDatesRow() {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;
    final List<Widget> cells = [
      _wrapCell(
          isMobile,
          _infoRow(
            '${S.of(context).policyWeight}:',
            widget.policy.policyWeight.toStringAsFixed(0),
          )),
      _wrapCell(
          isMobile,
          _infoRow(
            '${S.of(context).startDate}:',
            widget.dateFormat.format(widget.policy.startDate),
          )),
      _wrapCell(
          isMobile,
          _infoRow(
            '${S.of(context).endDate}:',
            // Falls back to "-" if the policy has no end date, matching
            // the design mock.
            widget.dateFormat.format(widget.policy.endDate),
          )),
    ];
    return isMobile
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: cells)
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells);
  }

  /// A cell in one of the responsive info rows: [Expanded] when the row is a
  /// real Row (768 / 1024), bare when the phone has stacked it into a Column
  /// -- Expanded inside a Column would try to take the remaining height.
  Widget _wrapCell(bool isMobile, Widget child) =>
      isMobile ? child : Expanded(child: child);

  /// English/Arabic policy documents. Side by side at 768 / 1024; the 375
  /// design stacks them full width, one card under the other.
  Widget _buildDocumentsRow() {
    final hasEn = widget.policy.policyDocumentEn != null;
    final hasAr = widget.policy.policyDocumentAr != null;
    if (!hasEn && !hasAr) return const SizedBox.shrink();
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    final List<Widget> cards = [
      if (hasEn)
        _wrapCell(
            isMobile,
            // ProductWarrantyCard already draws its own card; the
            // filled, bordered Container that used to wrap it framed the
            // title as well and double-framed the file row.
            ProductWarrantyCard(
              title: S.of(context).policyDocumentEng,
              // fileNameOf, not split('/').last: the stored value is a
              // download URL, so the naive split printed the whole
              // encoded storage key instead of the file's name.
              fileName: fileNameOf(widget.policy.policyDocumentEn!),
              date: '${S.of(context).uploadedOn}: '
                  '${widget.dateFormat.format(widget.policy.lastModifiedDate)}',
            )),
      if (hasEn && hasAr)
        isMobile ? SizedBox(height: 10.h) : SizedBox(width: 12.w),
      if (hasAr)
        _wrapCell(
            isMobile,
            // ProductWarrantyCard already draws its own card; the
            // filled, bordered Container that used to wrap it framed the
            // title as well and double-framed the file row.
            ProductWarrantyCard(
              title: S.of(context).policyDocumentAr,
              // fileNameOf, not split('/').last: the stored value is a
              // download URL, so the naive split printed the whole
              // encoded storage key instead of the file's name.
              fileName: fileNameOf(widget.policy.policyDocumentAr!),
              date: '${S.of(context).uploadedOn}: '
                  '${widget.dateFormat.format(widget.policy.lastModifiedDate)}',
            )),
    ];

    // stretch, not start: a stacked document card must still fill the card
    // width, and a Column with start would shrink-wrap it to its content.
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: cards)
        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: cards);
  }

  /// Search box + the "Control" button. On 768 / 1024 the button opens a small
  /// dropdown with "Add Control" and "Bulk Upload"; on 375 it goes straight to
  /// Add Control -- see [_onAddControlPressed].
  ///
  /// The button is gated on the Control_Permissions create switches and the
  /// banner on Control_Weight_Issue, the same way the Policies tab gates its
  /// own pair, so a role without them sees the list and nothing else.
  ///
  /// 768 / 1024 keep search and button on one row, with the Control Weight
  /// Issue banner on the line below. The 375 design gives search its own
  /// full-width row and pairs "Control" with "Control Weight Issue"
  /// underneath it, so on phones the banner is rendered from here.
  Widget _buildControlsToolbar(List<ControlEntity> controls) {
    final bool isMobile = screenSizeOf(context) == ScreenSize.mobile;

    final Widget search = AppSearchTextField(
      // expanded: false — AppSearchTextField supplies its own Expanded;
      // nesting it inside this one throws ParentDataWidget.
      expanded: false,
      // Only the query field is set. Writing back to the controller here reset
      // the caret to 0 on every keystroke.
      onChanged: (v) => setState(() => _controlSearchQuery = v),
      hintText: S.of(context).search,
      controller: _controlSearchController,
    );

    final bool canAdd = _canShowAddControl(context);

    if (!isMobile) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: search),
          if (canAdd) ...[
            SizedBox(width: 12.w),
            _buildControlAddButton(),
          ],
        ],
      );
    }

    final bool showWeightIssue = controls.hasControlWeightIssue &&
        GrcPermission.canOpenControlWeightIssue;
    // With neither the "+" button nor the banner to show, the whole second row
    // goes -- an empty 12.h gap under the search box is not a layout.
    if (!canAdd && !showWeightIssue) return search;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        search,
        SizedBox(height: 12.h),
        // Same layout as "+ Policy" on the module page: the add button
        // takes the full width, and Control Weight Issue sits on its own
        // row underneath, at its natural width.
        if (canAdd) _buildControlAddButton(),
        if (canAdd && showWeightIssue) SizedBox(height: 8.h),
        if (showWeightIssue)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _buildWeightIssueBanner(controls),
          ),
      ],
    );
  }

  /// Whether "+ Control" has anywhere to go on this screen.
  ///
  /// The same rule GrcModulePoliciesTab applies to "+ Policy": iPad/desktop
  /// show it when EITHER create switch is on, because the button opens a menu
  /// offering both routes. The phone has no bulk-upload design, so only
  /// Create_Single_Control can put a button there -- otherwise it would open a
  /// menu with nothing in it.
  bool _canShowAddControl(BuildContext context) =>
      screenSizeOf(context) == ScreenSize.mobile
          ? GrcPermission.canCreateSingleControl
          : GrcPermission.canCreateAnyControl;

  /// [stretch] is true on 375, where this button shares a full-width row
  /// with the Control Weight Issue banner and has to fill its half --
  /// CrossAxisAlignment.end would leave it at its ButtonSizing width,
  /// floating against the gutter.
  /// The "Control" button. Its menu is a real popup rendered in the app's
  /// Overlay -- see [_openControlMenu].
  ///
  /// It used to be a Column of [button, if (_showControlMenu) menu], so
  /// opening the menu INSERTED a 160-wide box into the layout and shoved the
  /// Control Weight Issue banner and every control card down the page.
  /// Nothing sizes to the menu now, so opening and closing it moves nothing.
  ///
  /// No `stretch` flag either: on 375 this sits inside an [Expanded], whose
  /// tight width constraint already makes the button fill its half of the
  /// row -- the Column that used to need CrossAxisAlignment.stretch is gone.
  Widget _buildControlAddButton() {
    return KeyedSubtree(
      key: _controlButtonKey,
      child: customButtonWithSvg(
        colorBorder: AppColors.primary,
        space: 10.w,
        radius: 8.r,
        widthImage: 16.w,
        heightImage: 16.h,
        function: () => _onAddControlPressed(context),
        title: S.of(context).control,
        textStyle: StyleText.fontSize14Weight500
            .copyWith(color: AppColors.textButton),
        image: 'assets/icons_assets/watermark/control_icon.svg',
        color: AppColors.primary,
        svgColor: AppColors.textButton,
      ),
    );
  }

  /// What the "+ Control" button does, which depends on the screen -- the
  /// same split "+ Policy" makes one level up.
  ///
  /// iPhone (375) goes STRAIGHT to Add Control. There is no control
  /// bulk-upload screen in the phone design, so a two-item menu there offered
  /// a route the phone does not have. iPad (768) and desktop (1024) keep the
  /// anchored popup with Add Control / Bulk Upload.
  Future<void> _onAddControlPressed(BuildContext context) async {
    if (screenSizeOf(context) == ScreenSize.mobile) {
      if (GrcPermission.canCreateSingleControl) widget.onControlTap(null);
      return;
    }
    await _openControlMenu();
  }

  /// Opens "Add Control" / "Bulk Upload" as an overlay popup anchored under
  /// the Control button.
  ///
  /// showMenu (already the pattern elsewhere in the app) puts the menu in
  /// the Overlay: it floats above the page instead of taking part in its
  /// layout, closes when you tap outside it, and picks its own edge from the
  /// ambient Directionality, so it hangs off the correct side in Arabic.
  Future<void> _openControlMenu() async {
    final RenderBox? button =
        _controlButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (button == null || overlay == null) return;

    // The button's own rect, in overlay coordinates. Handing showMenu the
    // full horizontal span (not just one corner) is what lets it align to
    // the leading edge in LTR and the trailing edge in RTL.
    final Offset topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Offset bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );

    final _ControlMenuAction? action = await showMenu<_ControlMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        topLeft.dx,
        bottomRight.dy + 4.h,
        overlay.size.width - bottomRight.dx,
        0,
      ),
      constraints: BoxConstraints(minWidth: 160.w),
      color: AppColors.field,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: AppColors.border),
      ),
      // Create_Single_Control / Create_Bulk_Upload_Control, independently --
      // the divider only exists when both items do.
      items: <PopupMenuEntry<_ControlMenuAction>>[
        if (GrcPermission.canCreateSingleControl)
          _controlMenuItem(
              _ControlMenuAction.addControl, S.of(context).addControl),
        if (GrcPermission.canCreateSingleControl &&
            GrcPermission.canBulkUploadControl)
          PopupMenuDivider(height: 1.h),
        if (GrcPermission.canBulkUploadControl)
          _controlMenuItem(
              _ControlMenuAction.bulkUpload, S.of(context).bulkUpload),
      ],
    );

    if (!mounted || action == null) return;
    switch (action) {
      case _ControlMenuAction.addControl:
        widget.onControlTap(null);
      case _ControlMenuAction.bulkUpload:
        widget.onBulkUpload();
    }
  }

  PopupMenuItem<_ControlMenuAction> _controlMenuItem(
    _ControlMenuAction value,
    String label,
  ) {
    return PopupMenuItem<_ControlMenuAction>(
      value: value,
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Text(
        label,
        style: StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
      ),
    );
  }

  Widget _buildWeightIssueBanner(List<ControlEntity> controls) {
    if (!controls.hasControlWeightIssue ||
        !GrcPermission.canOpenControlWeightIssue) {
      return const SizedBox.shrink();
    }
    return customButton(
      title: S.of(context).controlWeightIssue,
      function: () async {
        await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ControlWeightIssuePage(
              module: widget.module,
              policy: widget.policy,
            ),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        widget.onControlsChanged();
      },
      height: 38.h,
      // Mobile: same width as "Policy Weight Issue" so the label fits on one line.
      width: screenSizeOf(context) == ScreenSize.mobile ? 160.w : null,
      color: AppColors.primary,
      // 14.sp on mobile, 16.sp on tablet / desktop.
      textStyle: screenSizeOf(context) == ScreenSize.mobile
          ? StyleText.fontSize14Weight500
              .copyWith(color: AppColors.textButton, fontSize: 14.sp)
          : StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
    );
  }

  Future<void> _openControlDetails(ControlEntity control) async {
    if (control.status == ControlStatus.draft) {
      // Flow-start entry point (editing a draft Control straight from the
      // list, bypassing ControlDetailsPage).
      //
      // OwnerCubit is taken from the ancestor PolicyDetailsPage, NOT created
      // fresh: the control cards on this very list render their "Control
      // Owner" row out of that instance, so an owner reassigned in the
      // editor has to land on it. A throwaway instance here would save
      // correctly and still leave the card behind it showing the old owner
      // until the whole page was rebuilt.
      final ownerCubit = context.read<OwnerCubit>();
      await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider<ControlCubit>(
                create: (_) => GetIt.instance<ControlCubit>(),
              ),
              BlocProvider<ChampionCubit>(
                create: (_) => GetIt.instance<ChampionCubit>()
                  ..getAllChampions(moduleId: widget.module.moduleId),
              ),
              BlocProvider<OwnerCubit>.value(value: ownerCubit),
            ],
            child: AddEditControlPage(
              policy: widget.policy,
              moduleId: widget.module.moduleId,
              policyId: widget.policy.id,
              existingControl: control,
              siblingControls: widget.controls,
              policyStartDate: widget.policy.startDate,
              policyEndDate: widget.policy.endDate,
              policyHasArabic: widget.policy.policyNameAr.trim().isNotEmpty ||
                  widget.policy.policyNumberAr.trim().isNotEmpty ||
                  widget.policy.policyDescriptionAr.trim().isNotEmpty,
            ),
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => ControlDetailsPage(
            module: widget.module,
            policy: widget.policy,
            control: control,
            siblingControls: widget.controls,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
    widget.onControlsChanged();
  }

  /// Renders the visible controls as a single column on phones, and as a
  /// 2-column grid on tablets/desktop — matching the design mock.
  Widget _buildControlsList(List<ControlEntity> controls) {
    // The app's one empty state: the lottie_empty animation, centred, no
    // words (see 89-custom_empty_state.dart). Replaces the "noControlsFound"
    // sentence this branch used to print.
    if (controls.isEmpty) {
      return const Center(child: CustomEmptyState());
    }

    // Width, not shortestSide: the 375 design is one card per row and the
    // 768 / 1024 designs are two, and only width tells those apart.
    final isWide = screenSizeOf(context) != ScreenSize.mobile;

    // Table view, the other half of the toggle. Mobile never gets it (the
    // toggle is not rendered there), so the isWide guard is belt-and-braces
    // against a stale _isGridView after a resize -- the same guard
    // GrcModulePoliciesTab carries.
    if (!_isGridView && isWide) {
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: GrcControlTableView(
          controls: controls,
          onControlTap: _openControlDetails,
        ),
      );
    }

    if (!isWide) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controls.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (_, index) => ControlCardWidget(
          control: controls[index],
          onTap: () => _openControlDetails(controls[index]),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < controls.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ControlCardWidget(
                    control: controls[i],
                    onTap: () => _openControlDetails(controls[i]),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: i + 1 < controls.length
                      ? ControlCardWidget(
                          control: controls[i + 1],
                          onTap: () => _openControlDetails(controls[i + 1]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleControls = _visibleControls();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(top : 15.sp, right: 15.sp, left: 15.sp),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(8.sp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNumberAndLastEditRow(),
              Text(
                S.of(context).policyDescription,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText),
              ),
              Text(
                widget.isArabic
                    ? widget.policy.policyDescriptionAr
                    : widget.policy.policyDescriptionEn,
                style: StyleText.fontSize12Weight500
                    .copyWith(color: AppColors.text),
              ),
              SizedBox(height: 10.h),
              GrcOwnerBadge(
                ownerEmails: widget.module.moduleOwners,
              ),
              SizedBox(height: 10.h),
              _buildWeightAndDatesRow(),
              if (widget.policy.policyDocumentEn != null ||
                  widget.policy.policyDocumentAr != null)
                SizedBox(height: 10.h),
              _buildDocumentsRow(),
            ],
          ),
        ),
        SizedBox(height: 15.h),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // 30.sp, the spacing the Policies tab's identical bar uses.
              spacing: 30.sp,
              children: [
                for (final entry in _controlStatusEntries(widget.controls))
                  FilterBarItem(
                    // entry.key is the FILTER key and stays English --
                    // _selectedControlStatusFilter and _countControlsByStatus
                    // both match on it. Only the visible label is translated,
                    // which is what was missing: the bar read "all / Active /
                    // Draft" in the middle of an Arabic page. 'all' is
                    // lower-case as a key; its grcTr entry is 'All'.
                    title: grcTr(context, entry.key == 'all' ? 'All' : entry.key),
                    numberOfItems: entry.value['num'],
                    color: entry.value['color'],
                    isSelected: entry.key == _selectedControlStatusFilter,
                    onTap: () => setState(
                        () => _selectedControlStatusFilter = entry.key),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _buildControlsToolbar(widget.controls),
        SizedBox(height: 12.h),
        // Control Weight Issue + view-mode icons, laid out exactly like the
        // same row on the Policies tab: banner leading, toggle trailing.
        //
        // On 375 the banner already sits beside the Control button inside the
        // toolbar above, and the table toggle is not offered at all, so the
        // whole row is dropped there.
        if (screenSizeOf(context) != ScreenSize.mobile) ...[
          Row(
            children: [
              _buildWeightIssueBanner(widget.controls),
              const Spacer(),
              customTableButton(
                function: () => setState(() => _isGridView = false),
                isSelected: !_isGridView,
                color: AppColors.card,
                selectedColor: AppColors.primary,
                svgColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.blackButton
                    : AppColors.white,
                selectedSvgColor: AppColors.textButton,
              ),
              SizedBox(width: 8.sp),
              customGridButton(
                function: () => setState(() => _isGridView = true),
                isSelected: _isGridView,
                color: AppColors.card,
                selectedColor: AppColors.primary,
                svgColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.blackButton
                    : AppColors.white,
                selectedSvgColor: AppColors.textButton,
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
        _buildControlsList(visibleControls),
      ],
    );
  }
}
