/// Module: GRC Module Management
/// Description: Provides the main list page for GRC Modules with status
///              filtering, search, sort, and navigation to the details page.
/// Author: Mohamed Magdy Abdelkhalek
/// Date: 2026-06-28
/// Dependencies: flutter_bloc, GRCModuleCubit, GRCModuleEntity, get_it
/// Revision History: 2026-06-28 - Initial creation
///                    2026-06-30 - Connected to GRCModuleCubit with real data (Mohamed Magdy Abdelkhalek)
library;

/// ************************* FILE INFO *************************** ///
/// File Name: grc_page.dart
/// Purpose: Contains GrcResponsivePage (root shell), GovernanceRiskAndCompliancePage
///          (list page), and _GrcModuleCard (list item card).
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 28/6/2026

import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/43-custom_module_info_card.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/51-custom_pop_up.dart';
import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/grc/action_center/presentation/ui/pages/grc_action_center_page.dart';
import 'package:knowticed_plus/features/grc/dashboard/presentation/ui/pages/grc_dashboard_page.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_entity.dart';
import 'package:knowticed_plus/features/grc/module/domain/entities/grc_module_status.dart';
import 'package:knowticed_plus/features/grc/module/presentation/controller/cubit/grc_module_cubit.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/pages/grc_details_page.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/pages/grc_module_details_page.dart';
import 'package:knowticed_plus/features/grc/module/presentation/ui/pages/grc_previous_module_owners_page.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_assignment_lookup.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_permissions.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/79-filter_bar_item.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/grc/shared/debug/grc_test_tools.dart';
import 'package:knowticed_plus/features/grc/shared/debug/grc_test_tools_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/core/helper/main_helper/localized_number.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/grc/shared/helpers/grc_l10n.dart';

/// class name: [GrcResponsivePageLayout]
///
/// purpose: root shell that provides [GRCModuleCubit] and switches between
///          the mobile and tablet layouts via [ResponsiveHelper].
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GrcResponsivePageLayout extends StatelessWidget {
  const GrcResponsivePageLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<GRCModuleCubit>()..getAllModules(includeDeleted: true),
      child: Builder(
        builder: (ctx) => ResponsiveHelper(
          mobileWidget: const GovernanceRiskAndCompliancePage(),
          tabletWidget: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: ctx.read<GRCModuleCubit>(),
                  child: const GovernanceRiskAndCompliancePage(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// class name: [GovernanceRiskAndCompliancePage]
///
/// purpose: main list page for GRC Modules. Reads from [GRCModuleCubit] and
///          renders a filtered, searchable, sortable list of module cards.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class GovernanceRiskAndCompliancePage extends StatefulWidget {
  const GovernanceRiskAndCompliancePage({super.key});

  @override
  State<GovernanceRiskAndCompliancePage> createState() =>
      _GovernanceRiskAndCompliancePageState();
}

class _GovernanceRiskAndCompliancePageState
    extends State<GovernanceRiskAndCompliancePage> {
  String _selectedStatus = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  /// Active sort, or null for "no sort chosen".
  ///
  /// NULLABLE, and null to start with. It was non-null and seeded with
  /// 'Creation Date', so the Sort button came up already painted as active on
  /// first load and there was no value that could ever put it back — the user
  /// could not see the difference between "I sorted this" and "this is how it
  /// arrived". Newest-first is still the order on screen (see _applyFilters);
  /// it just isn't a *selection* any more.
  String? _sortOrder;

  // ── TEMPORARY: action-bar geometry probe ─────────────────────────────────
  // Layout says these three boxes are already identical, so if they still do
  // not look aligned the difference is in what each widget PAINTS inside its
  // box, not in the box. Measured rather than guessed; remove once settled.
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _createKey = GlobalKey();
  bool _barMeasured = false;

  void _measureActionBar() {
    if (_barMeasured) return;
    _barMeasured = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void report(String name, GlobalKey key) {
        final RenderBox? box =
            key.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) {
          debugPrint('[ACTIONBAR] $name: not laid out');
          return;
        }
        final Offset topLeft = box.localToGlobal(Offset.zero);
        debugPrint('[ACTIONBAR] ${name.padRight(7)} '
            'size=${box.size.width.toStringAsFixed(1)}'
            'x${box.size.height.toStringAsFixed(1)}  '
            'top=${topLeft.dy.toStringAsFixed(1)}  '
            'bottom=${(topLeft.dy + box.size.height).toStringAsFixed(1)}  '
            'left=${topLeft.dx.toStringAsFixed(1)}  '
            'right=${(topLeft.dx + box.size.width).toStringAsFixed(1)}');
      }

      debugPrint('[ACTIONBAR] --- barHeight asked for = '
          '${ButtonSizing.height.toStringAsFixed(1)} '
          '(38.sp)  screenW=${MediaQuery.of(context).size.width} ---');
      report('search', _searchKey);
      report('sort', _sortKey);
      report('create', _createKey);
      debugPrint('[ACTIONBAR] -------------------------------------------');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering logic ───────────────────────────────────────────────────────

  List<GRCModuleEntity> _applyFilters(List<GRCModuleEntity> modules) {
    var result = modules;

    // Status filter — Removed is treated as a status alongside Active/Inactive.
    // "all" shows everything; each other tab filters by its own condition.
    if (_selectedStatus == GrcModuleStatus.active.value) {
      result = result
          .where(
              (m) => !m.isRemoved && m.status == GrcModuleStatus.active.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.inactive.value) {
      result = result
          .where(
              (m) => !m.isRemoved && m.status == GrcModuleStatus.inactive.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.scheduled.value) {
      result = result
          .where((m) =>
              !m.isRemoved && m.status == GrcModuleStatus.scheduled.value)
          .toList();
    } else if (_selectedStatus == GrcModuleStatus.removed.value) {
      result = result.where((m) => m.isRemoved).toList();
    }
    // 'all' → no filter, show everything

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((m) =>
              m.moduleNameEn.toLowerCase().contains(q) ||
              m.moduleNameAr.toLowerCase().contains(q))
          .toList();
    }

    // Sort
    if (_sortOrder == 'ASC') {
      result.sort((a, b) => a.moduleNameEn.compareTo(b.moduleNameEn));
    } else if (_sortOrder == 'DES') {
      result.sort((a, b) => b.moduleNameEn.compareTo(a.moduleNameEn));
    } else if (_sortOrder == 'Last Update') {
      result.sort((a, b) => b.modificationDate.compareTo(a.modificationDate));
    } else {
      // Covers both 'Creation Date' and no selection at all: newest first is
      // the resting order of this list, chosen or not.
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return result;
  }

  Map<String, int> _countByStatus(List<GRCModuleEntity> modules) {
    return {
      'all': modules.length,
      GrcModuleStatus.active.value: modules
          .where(
              (m) => !m.isRemoved && m.status == GrcModuleStatus.active.value)
          .length,
      GrcModuleStatus.inactive.value: modules
          .where(
              (m) => !m.isRemoved && m.status == GrcModuleStatus.inactive.value)
          .length,
      GrcModuleStatus.scheduled.value: modules
          .where((m) =>
              !m.isRemoved && m.status == GrcModuleStatus.scheduled.value)
          .length,
      GrcModuleStatus.removed.value: modules.where((m) => m.isRemoved).length,
    };
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  Future<void> _openDetails(
    BuildContext context,
    GrcPageMode mode, {
    GRCModuleEntity? entity,
    bool autoDelete = false,
  }) async {
    // Share this list page's own GRCModuleCubit with the details page via
    // BlocProvider.value instead of letting the details page resolve a second,
    // disconnected instance from GetIt. The details page performs
    // create/edit/delete/restore on this exact instance. The cubit emits
    // GRCModuleActionSuccess (not a fresh GRCModuleListLoaded) after an action,
    // so the list is still explicitly re-fetched below once the details page
    // pops true — that refetch is what returns the shared cubit to a
    // GRCModuleListLoaded state the list's BlocBuilder can render.
    final cubit = context.read<GRCModuleCubit>();
    final reloaded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: GovernanceRiskAndComplianceDetails(
            mode: mode,
            entity: entity,
            autoDelete: autoDelete,
          ),
        ),
      ),
    );

    // Use the already-captured `cubit` reference here, not `context.read`.
    // On tablet this list page lives inside a nested Navigator while the
    // success/error dialogs shown by the details page open on the root
    // Navigator (Flutter's showDialog defaults to useRootNavigator: true).
    // That cross-Navigator interaction can leave this specific BuildContext
    // reporting unmounted right as the push future resolves, even though the
    // widget is still visibly on screen and its Cubit is very much alive —
    // gating the refresh on `context.mounted` silently dropped it in that
    // case. A Cubit isn't tied to any BuildContext's lifecycle, so calling
    // it directly on the captured reference is always safe here.
    if (reloaded == true) {
      cubit.getAllModules(includeDeleted: true);
    }
  }

  /// Whether this user may do anything at all from a module's "..." menu.
  bool _hasAnyModuleMenuAction(GRCModuleEntity module) {
    if (module.isRemoved) return GrcPermission.canRestoreModule;
    return GrcPermission.canEditModule ||
        GrcPermission.canViewPreviousOwnerHistory ||
        GrcPermission.canDeleteModule;
  }

  /// One row of the card's "..." menu, with this menu's hover treatment.
  HoverablePopupMenuItem _menuItem(String value, String label) {
    return HoverablePopupMenuItem(
      value: value,
      label: label,
      labelColor: AppColors.text,
      hoverColor: AppColors.secondaryPrimary,
      hoverLabelColor: AppColors.secondaryText,
      alignment: AlignmentDirectional.centerStart,
      height: 40.h,
    );
  }

  Future<void> _showModuleMenu(
    BuildContext context,
    GRCModuleEntity module,
    GlobalKey menuButtonKey,
  ) async {
    // Anchor the menu to the "..." button that opened it.
    //
    // This used to be a RelativeRect pinned to the top-RIGHT CORNER OF THE
    // SCREEN (`overlay.size.width - 72.w`, `110.h`) — a constant, with no
    // input from the card that was tapped. So every card's menu opened in the
    // same far corner, which on a wide desktop window is most of a screen away
    // from the button, and over an unrelated card on a phone.
    //
    // Measured against the overlay, the same way `_showPolicyCreationMenu`
    // in grc_module_policies_tab.dart already does it. Starting the rect at
    // the button's BOTTOM edge is what makes the menu drop directly beneath
    // the dots instead of over them, and giving both corners lets
    // `RelativeRect` resolve correctly in RTL as well as LTR.
    final buttonBox =
        menuButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        buttonBox.localToGlobal(
          Offset(0, buttonBox.size.height),
          ancestor: overlayBox,
        ),
        buttonBox.localToGlobal(
          buttonBox.size.bottomRight(Offset.zero),
          ancestor: overlayBox,
        ),
      ),
      Offset.zero & overlayBox.size,
    );

    final List<HoverablePopupMenuItem> menuItems = module.isRemoved
        ? [
            if (GrcPermission.canRestoreModule)
              _menuItem('restore', S.of(context).restore),
          ]
        : [
            if (GrcPermission.canEditModule)
              _menuItem('edit', S.of(context).Edit),
            if (GrcPermission.canViewPreviousOwnerHistory)
              _menuItem(
                'previousModuleOwners',
                S.of(context).previousModuleOwners,
              ),
            if (GrcPermission.canDeleteModule)
              _menuItem('delete', S.of(context).Delete),
          ];

    // Nothing this user may do to this module — open no menu at all rather
    // than an empty popup the user has to dismiss.
    if (menuItems.isEmpty) return;

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      // HoverablePopupMenuItem, not PopupMenuItem: a bare PopupMenuItem takes
      // its hover tint from the ambient theme, which is the pale wash in the
      // screenshot and not something this menu can set per row.
      //
      // Hover fill is AppColors.secondaryPrimary — the same colour the app
      // drawer paints behind its selected item (drawer_menu_item.dart), so a
      // hovered row here reads as the same kind of highlight the rest of the
      // shell uses. It is branding-driven, not a fixed hex: AppTheme's
      // interfaceUpdateBrandingColors rewrites it per company, which is why
      // it renders pink in this deployment rather than the #E5B800 default.
      //
      // The widget's own default is a primary fill with textButton, which the
      // Settings popup still uses; both are opt-in, so that caller is
      // untouched.
      // Each row is gated on its own switch from the admin dashboard. A menu
      // can end up with nothing in it — see the guard in _showModuleMenu's
      // caller, which is why this list is built before the menu is opened.
      items: menuItems,
    );

    if (!context.mounted || selected == null) {
      return;
    }

    if (selected == 'edit') {
      await _openDetails(context, GrcPageMode.view, entity: module);
      return;
    }

    if (selected == 'delete') {
      // CHANGED 13/9/2026 — confirm here, on the list.
      //
      // This used to push the details page with `autoDelete: true`, which
      // opened the same confirm dialog one frame after the page appeared. The
      // user asked to delete from the menu and got a full page they never
      // asked to see, behind a dialog, and on cancel they were left standing
      // on it. The dialog is the whole interaction, so it belongs where the
      // menu is.
      await _confirmDelete(context, module);
      return;
    }

    if (selected == 'previousModuleOwners') {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GrcPreviousModuleOwnersPage(module: module),
        ),
      );
      return;
    }

    if (selected == 'restore') {
      await _openDetails(context, GrcPageMode.restore, entity: module);
    }
  }

  /// Delete a module straight from its "..." menu — confirm, delete, confirm
  /// again, reload. No navigation.
  ///
  /// The cubit is captured before the first await for the reason spelled out
  /// in [_openDetails]: these dialogs open on the ROOT navigator while this
  /// page can live inside a nested one, which can leave this BuildContext
  /// reporting unmounted while the page is still on screen. A Cubit has no
  /// BuildContext lifecycle, so the captured reference is always safe.
  Future<void> _confirmDelete(
      BuildContext context, GRCModuleEntity module) async {
    final GRCModuleCubit cubit = context.read<GRCModuleCubit>();

    await showConfirmDialog(
      context: context,
      title: S.of(context).deletingGrcModule,
      cancelLabel: S.of(context).no,
      confirmLabel: S.of(context).yes,
      lottieAsset: AppAssets.trash,
      subtitle: S.of(context).areYouSureYouWantToDeleteThisGrcModule,
      onConfirm: () async {
        await cubit.deleteModule(id: module.moduleId);

        // deleteModule leaves the cubit on GRCModuleActionSuccess, which this
        // page's BlocBuilder has no list to render from — so the refetch is
        // what puts it back into GRCModuleListLoaded, exactly as the return
        // from the details page used to do.
        await cubit.getAllModules(includeDeleted: true);

        if (!context.mounted) return;
        await showSuccessDialog(
          context: context,
          title: S.of(context).deletedGrcModule,
          subtitle: S.of(context).successfullyDeletedGrc,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GRCModuleCubit, GRCModuleState>(
      builder: (context, state) {
        final allModules =
            state is GRCModuleListLoaded ? state.modules : <GRCModuleEntity>[];
        final counts = _countByStatus(allModules);
        final filtered = _applyFilters(allModules);
        final bool isCompact = ButtonSizing.isMobile(context);

        final statusLabels = {
          'all': 'All',
          GrcModuleStatus.active.value: 'Active',
          GrcModuleStatus.inactive.value: 'Inactive',
          GrcModuleStatus.scheduled.value: 'Scheduled',
          GrcModuleStatus.removed.value: 'Removed',
        };

        final List<MapEntry<String, Map<String, dynamic>>> statusEntries = [
          MapEntry('all', {'num': counts['all'] ?? 0, 'color': AppColors.text}),
          MapEntry(GrcModuleStatus.active.value, {
            'num': counts[GrcModuleStatus.active.value] ?? 0,
            'color': AppColors.green
          }),
          MapEntry(GrcModuleStatus.inactive.value, {
            'num': counts[GrcModuleStatus.inactive.value] ?? 0,
            'color': AppColors.red
          }),
          MapEntry(GrcModuleStatus.scheduled.value, {
            'num': counts[GrcModuleStatus.scheduled.value] ?? 0,
            'color': AppColors.primary
          }),
          MapEntry(GrcModuleStatus.removed.value, {
            'num': counts[GrcModuleStatus.removed.value] ?? 0,
            'color': AppColors.colorGrey
          }),
        ];

        // SideFrameMasterServices replaces the Scaffold + SafeArea + padding +
        // PaginationAppBar this page used to build for itself. The frame owns
        // all four: it supplies the Scaffold on phone (the desktop shell
        // supplies it there), the breadcrumb row, and 15.sp of horizontal
        // padding on BOTH branches — so the local 16.w padding goes with them
        // rather than stacking on top.
        return SideFrameMasterServices(
          // The 375 frame titles this page "GRC" — the full name wraps to
          // three lines at that width.
          titleText: screenSizeOf(context) == ScreenSize.mobile
              ? S.of(context).grc
              : S.of(context).governanceRiskCompliance,
          // This is the root of the section, so there is no second crumb and
          // the frame draws no back chevron — the same as the single-title
          // PaginationAppBar it replaces.
          child: SideFrameBoundedBody(
            // The frame hands its child an UNBOUNDED height on phone (its
            // child sits directly in a SingleChildScrollView). The card list
            // below is an Expanded, which throws "RenderFlex children have
            // non-zero flex but incoming height constraints are unbounded"
            // against that. SideFrameBoundedBody measures the viewport and
            // gives the column a height on the phone branch, and returns the
            // child untouched on tablet/desktop where the frame already
            // bounded it.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Figma 375: Dashboard sits alone, trailing, above the
                  // All / Active / Inactive counters.
                  // Figma: Action Center leading, Dashboard trailing.
                  if (GrcPermission.canOpenMainModuleDashboard) ...[
                    Row(
                      children: [
                        _actionCenterButton(context, isCompact: isCompact),
                        const Spacer(),
                        _dashboardButton(context, isCompact: isCompact),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],

                // Phones draw Dashboard on its own row above the counters (Figma
                // 375 frame), so it only joins this bar on tablet/desktop.

                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 30.sp,
                        children: [
                          for (var entry in statusEntries)
                            FilterBarItem(
                              title: grcTr(context, statusLabels[entry.key]!),
                              numberOfItems: entry.value['num'] as int,
                              color: entry.value['color'] as Color,
                              onTap: () =>
                                  setState(() => _selectedStatus = entry.key),
                              isSelected: _selectedStatus == entry.key,
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildActionBar(context),
                  SizedBox(height: 16.h),

                // ── List ───────────────────────────────────────────────
                Expanded(
                  child: _buildBody(context, state, filtered),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Action Center: every module's errors / recommendations / expired
  /// items. Shown with the Main Dashboard button (same permission).
  Widget _actionCenterButton(BuildContext context, {required bool isCompact}) {
    return customButton(
      title: context.isArabic ? 'مركز الإجراءات' : 'Action Center',
      function: () {
        // Captured before the push — see _openDetails.
        final cubit = context.read<GRCModuleCubit>();
        Navigator.of(context)
            .push(GrcActionCenterPage.route())
            .then((_) => cubit.getAllModules(includeDeleted: true));
      },
      width: (isCompact ? 165 : 170).w,
      color: AppColors.primary,
      textStyle: (isCompact
              ? StyleText.fontSize14Weight500
              : StyleText.fontSize16Weight500)
          .copyWith(color: AppColors.textButton),
    );
  }

  /// Main Dashboard: every module rolled up. Same permission as the
  /// module-level Dashboard button (Main_Module_Dashboard).
  Widget _dashboardButton(BuildContext context, {required bool isCompact}) {
    return customButton(
      title: S.of(context).dashboard,
      function: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const GrcDashboardPage(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      width: (isCompact ? 165 : 135).w,
      color: AppColors.primary,
      textStyle: (isCompact
              ? StyleText.fontSize14Weight500
              : StyleText.fontSize16Weight500)
          .copyWith(color: AppColors.textButton),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    // Read the breakpoint from ButtonSizing, which is what actually
    // decides the 38.sp vs 135.sp button width — a second check keyed
    // differently could put a label in an icon-sized button.
    final bool isCompact = ButtonSizing.isMobile(context);

    final sortButton = CustomSortButton<String>(
      value: _sortOrder,
      items: const ['ASC', 'DES', 'Creation Date', 'Last Update'],
      labelBuilder: (o) =>grcTr(context, o),
      // Takes null. CustomSortButton hands back null when the ACTIVE option is
      // tapped again — that is the deselect — and the old `if (value != null)`
      // guard swallowed exactly that case, so the button could be turned on
      // but never off.
      onChanged: (value) => setState(() => _sortOrder = value),
      // Localised: the label sat as the widget's English default, so the
      // Arabic UI rendered a literal "Sort" next to fully translated
      // surroundings.
      title: S.of(context).sort,
      // Figma labels this button "Sort" at 768 and 1024 and draws it as a
      // bare icon square at 375 — the same rule the Create button beside it
      // follows.
      showTitle: !isCompact,
      svgPath: "assets/icons_assets/data_grc_assets/icons_sort.svg",
      // No explicit width/height: CustomSortButton now defaults to the
      // app-wide ButtonSizing pair (38.sp square on phone, 135.sp x 38.sp
      // otherwise). The 40.w here was a third size, one point off the 38.sp
      // Edit/Delete/Create buttons it shares a row with.
    );

    final createButton = customButtonWithSvg(
      colorBorder: AppColors.primary,
      function: () => _openDetails(context, GrcPageMode.create),
      title: isCompact ? '' : S.of(context).createGrcModule,
      textStyle:
          StyleText.fontSize14Weight500.copyWith(color: AppColors.textButton),
      image: 'assets/icons_assets/data_grc_assets/module.svg',
      widthImage: 16.w,
      heightImage: 16.h,
      color: AppColors.primary,
      width: isCompact ? 38.w : 200.w,
      svgColor: AppColors.textButton,
    );

    // ONE height for the whole bar, imposed from here.
    //
    // All three already ask for 38.sp on their own — ButtonSizing.height for
    // the two buttons, CustomTextField's `height?.sp` for the search box — and
    // they still came out three different heights, because each one applies
    // that number to a different box. customButtonWithSvg sizes its own
    // Container; CustomSortButton puts a SizedBox around a CustomDropdown
    // whose InputDecorator carries 13.sp of vertical padding of its own; the
    // search field hands the number to an InputDecorator too. Asking three
    // widgets to agree on a number is not the same as them agreeing on a box.
    //
    // So: a fixed-height Row with CrossAxisAlignment.stretch. Every child gets
    // a TIGHT height constraint of exactly barHeight, which overrides whatever
    // each one computed internally, and they line up top and bottom by
    // construction. Done at this call site, as asked — no custom widget is
    // touched, so no other screen moves.
    final double barHeight = ButtonSizing.height;

    _measureActionBar();

    return SizedBox(
      height: barHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10.w,
        children: [
          // `expanded: false` because the Expanded is supplied here instead —
          // AppSearchTextField's own one would wrap the field before the
          // stretch constraint could reach it.
          //
          // NO `height:` passed on purpose. AppSearchTextField forwards it to
          // CustomTextField, which applies `widget.height?.sp` — so handing it
          // the already-scaled barHeight would scale it a second time
          // (38.sp.sp). Its own default is a raw 38, which becomes the same
          // 38.sp barHeight is, and the stretch constraint pins it either way.
          Expanded(
            child: KeyedSubtree(
              key: _searchKey,
              child: AppSearchTextField(
                expanded: false,
                onChanged: (value) => setState(() => _searchQuery = value),
                hintText: S.of(context).search,
                controller: _searchController,
              ),
            ),
          ),
          KeyedSubtree(key: _sortKey, child: sortButton),
          // QA: GRC Test Tools (send every notification / seed calendar
          // data). Hidden when kGrcTestToolsEnabled is false.
          if (kGrcTestToolsEnabled)
            SizedBox(
              width: barHeight,
              child: Tooltip(
                message: 'GRC Test Tools',
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  onPressed: () => GrcTestToolsPage.open(context),
                  child: Icon(Icons.science_outlined, size: 20.sp),
                ),
              ),
            ),

          // Create is the only toolbar control behind a permission; search and
          // sort act on what the user can already see.
          if (GrcPermission.canCreateModule)
            KeyedSubtree(key: _createKey, child: createButton),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    GRCModuleState state,
    List<GRCModuleEntity> modules,
  ) {
    if (state is GRCModuleLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state is GRCModuleFailure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.message,
              style:
                  StyleText.fontSize14Weight500.copyWith(color: AppColors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context.read<GRCModuleCubit>().getAllModules(),
              child: Text(S.of(context).retry),
            ),
          ],
        ),
      );
    }

    if (modules.isEmpty) {
      // The app's one empty state: the lottie_empty animation, no sentence.
      // The failure branch above keeps its own message and retry — "there is
      // nothing here" and "we could not find out what is here" are different
      // facts, and only the first one belongs here.
      return const Center(child: CustomEmptyState());
    }

    // Grid geometry, straight off the Figma frames for this section:
    //
    //   375  1 column,  345 wide cards, 10 between rows
    //   768  2 columns, 324 wide cards, 19 across / 15 down
    //  1024  3 columns, 290 wide cards, 15 across / 15 down
    //
    // Figma draws every card 110 tall, but that is NOT pinned here. With this
    // app's type scale [ModuleInfoCard] needs about 121 (10 pad + a 67 title
    // block + 6 + a 28 compliance chip + 10 pad), so a fixed 110 would clip
    // it and a fixed 140 — what this used to hardcode — left dead space under
    // every card. Rows size to their tallest card instead, which matches the
    // design at the default text scale and still can't overflow when the user
    // has larger system text.
    final int columns = responsiveValue(context, mobile: 1, tablet: 2, desktop: 3);
    final double crossGutter =
        responsiveValue(context, mobile: 0.0, tablet: 19.0, desktop: 15.0);
    final double mainGutter =
        responsiveValue(context, mobile: 10.0, tablet: 15.0, desktop: 15.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        GRCModuleEntity moduleAt(int i) => modules[i];

        _GrcModuleCard cardFor(int index) => _GrcModuleCard(
              module: moduleAt(index),
              onTap: () {
                final entity = moduleAt(index);
                if (entity.isRemoved) {
                  _openDetails(context, GrcPageMode.restore, entity: entity);
                } else {
                  // Capture the cubit (not context.read after the await) —
                  // same reasoning as _openDetails above: dialogs shown deep
                  // inside the details page (weight-issue Apply Changes, My
                  // Audits score/approve/reject) use the root Navigator, and
                  // on tablet this list page lives in a nested Navigator, so
                  // this context can spuriously report unmounted right when
                  // the push future resolves.
                  final cubit = context.read<GRCModuleCubit>();
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => GrcModuleDetailsPage(module: entity),
                        ),
                      )
                      .then((_) => cubit.getAllModules(includeDeleted: true));
                }
              },
              // Hide the dots entirely when this user has none of the three
              // actions behind them.
              onMenuTap: _hasAnyModuleMenuAction(moduleAt(index))
                  ? (menuButtonKey) =>
                      _showModuleMenu(context, moduleAt(index), menuButtonKey)
                  : null,
            );

        if (columns == 1) {
          return ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.separated(
              itemCount: modules.length,
              separatorBuilder: (_, __) => SizedBox(height: mainGutter.h),
              itemBuilder: (_, index) => cardFor(index),
            ),
          );
        }

        final int rowCount = (modules.length / columns).ceil();

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.separated(
            itemCount: rowCount,
            separatorBuilder: (_, __) => SizedBox(height: mainGutter.h),
            itemBuilder: (_, row) => IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List<Widget>.generate(columns * 2 - 1, (slot) {
                  // Odd slots are the gutters between cards.
                  if (slot.isOdd) return SizedBox(width: crossGutter.w);

                  final int index = row * columns + slot ~/ 2;
                  if (index >= modules.length) {
                    return const Expanded(child: SizedBox());
                  }
                  return Expanded(child: cardFor(index));
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Module list card ─────────────────────────────────────────────────────────

/// class name: [_GrcModuleCard]
///
/// purpose: private list-item card that displays a single [GRCModuleEntity]
///          with its name, department, and status badge. Tapping navigates
///          to the details page in view or restore mode.
///
/// authors: Mohamed Magdy Abdelkhalek
///
/// created at: 28/6/2026
class _GrcModuleCard extends StatefulWidget {
  final GRCModuleEntity module;
  final VoidCallback onTap;

  /// Called with the key held on this card's own "..." button, so the caller
  /// can position a popup menu against it.
  final ValueChanged<GlobalKey>? onMenuTap;

  const _GrcModuleCard({
    required this.module,
    required this.onTap,
    this.onMenuTap,
  });

  @override
  State<_GrcModuleCard> createState() => _GrcModuleCardState();
}

class _GrcModuleCardState extends State<_GrcModuleCard> {
  /// Stateful purely to own this key. A GlobalKey minted inside `build` would
  /// be a different key on every rebuild, and the one the menu measured could
  /// already be detached by the time it was read.
  final GlobalKey _menuButtonKey = GlobalKey();

  /// Capitalizes only the first character — display formatting, doesn't
  /// touch how the value is stored.
  String _capitalizeFirst(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final GRCModuleEntity module = widget.module;

    // Every number on this card goes through LocalizedNumber. DateFormat and
    // NumberFormat give Arabic month names and separators, but whether their
    // DIGITS come out Arabic-Indic depends on which numbering system CLDR
    // hands a bare `ar`, and that has moved between intl releases — so the
    // dates read "13 سبتمبر 2026" with Latin digits beside Arabic-Indic
    // counts. Mapping here does not depend on the intl version, and is a
    // no-op in English.
    final String locale = context.isArabic ? 'ar' : 'en';
    final DateFormat cardDateFormat = DateFormat('d MMM yyyy', locale);

    return ModuleInfoCard(
      width: double.infinity,
      // Same gap as the policy card: GRCModuleEntity.moduleImage was stored
      // but never reached the tile.
      imageUrl: module.moduleImage,
      onTap: widget.onTap,
      title: _capitalizeFirst(
        module.localizedName(isArabic: context.isArabic),
      ),
      infoRows: [
        if (module.moduleOwners.isNotEmpty)
          CardInfo(
            label: '${S.of(context).owner}:',
            // FIXED 28/9/2026 (GRC bug report p1): a module can have several
            // owners and all of them are saved, but the card only ever showed
            // `moduleOwners.first` — so after picking two owners the card
            // looked as if only the first one had been kept. List them all.
            value: module.moduleOwners
                .where((String email) => email.trim().isNotEmpty)
                .map((String email) =>
                    _capitalizeFirst(employeeDisplayName(context, email)))
                .join(context.isArabic ? '، ' : ', '),
          ),
        CardInfo(
          label: '${S.of(context).creationDate}:',
          value: LocalizedNumber.digits(
            context,
            cardDateFormat.format(module.createdAt),
          ),
        ),
      ],
      complianceLabel: '${S.of(context).complianceScore}:',
      // ModuleInfoCard hides the whole chip when complianceScore is null, so
      // withholding the permission removes the chip rather than blanking it.
      complianceScore: GrcPermission.canSeeComplianceScore
          ? (module.score == 0
              ? '-'
              // NumberFormat for the decimal separator (Arabic uses ٫, not .),
              // LocalizedNumber for the digits themselves.
              : LocalizedNumber.digits(
                  context,
                  NumberFormat('0.00', locale).format(module.score),
                ))
          : null,
      footerLabel: '${S.of(context).lastUpdate}:',
      footerValue: LocalizedNumber.digits(
        context,
        cardDateFormat.format(module.modificationDate),
      ),
      menuButtonKey: _menuButtonKey,
      onMenuTap: widget.onMenuTap == null
          ? null
          : () => widget.onMenuTap!(_menuButtonKey),
    );
  }
}
