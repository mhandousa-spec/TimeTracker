/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: icon_selector_dialog_widget.dart
/// Purpose: Dialog that lets the user pick which icons are pinned to the home
///          app bar, plus the catalog of selectable icons.
/// Author: Amr Mesbah
/// Created at: 20/9/2025
/// Updated: 11/8/2026 - HeaderIconItem extracted to data/models/.
/// Updated: 23/8/2026 - Rebuilt against Figma `Frame 1597885454`
///          (MESBAH / node 7464:8017, the iPad-horizontal "Icons" dialog).
///          What changed, and the Figma number each value comes from:
///
///            * a module filter row above the grid — count chip + label, the
///              chip row scrolls horizontally because the design lays it out
///              1104 wide inside a 645-wide content column. Built from the
///              shared `StatusChipFilter` (core/custom/8-custom_filter_app.dart),
///              the same component the add-widget page filters with, rather
///              than a second hand-rolled chip.
///            * 4-column grid of 150x38 tiles, 15 gutters, radius 4 (was a
///              2-column GridView of 60-tall tiles at radius 8).
///            * Discard / Save are 135x38 at radius 8, left-aligned with a 30
///              gap — they were a full-width `Expanded` pair.
///            * the header badge is a 26 circle holding a 14 grid glyph.
///            * every icon is the SVG exported from that Figma node rather
///              than the nearest existing asset (see `assets/icons_assets/
///              home_assets/picker_*.svg`).
///
///          NOT copied from the mock: it repeats "Requested Services",
///          "Light/Dark Mode" and "Check In-Out" as duplicate tiles, which
///          reads as mock filler rather than intent — each appears once here.
///          The alternate glyphs are still exported (`picker_light_mode.svg`,
///          `picker_check_in_out_alt.svg`) if those were meant to be separate
///          entries.
///
///          The mock's chip counts (14 All / 7 Service / 7 Form / 7 Knowledge
///          Hub / 2 Settings...) do not sum to its own total, so they are
///          placeholders. Counts here are derived from the catalog, and the
///          chips are the modules the catalog actually uses.

import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/core/custom/86-removed_module_placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/helper/role/modules_enum.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:knowticed_plus/core/constants/app_constants.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/roles/r1_role_management/presentation/ui/pages/role_screen.dart';
import 'package:knowticed_plus/features/knowledge_hub/k6_approvals/presentation/controller/approvals_cubit.dart';
import 'package:knowticed_plus/features/knowledge_hub/main_controller/data/services/approvals_firebase_services.dart';
import 'package:knowticed_plus/features/knowledge_hub/k6_approvals/presentation/ui/pages/approvals_screen.dart';

import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/header_icon_item.dart';
import 'package:knowticed_plus/features/todo/presentation/ui/pages/todo_module_entry.dart';
// ADDED 9/10/2026 — Time Tracker phase 6 (Check In / Out header icon).
import 'package:knowticed_plus/features/time_tracker/presentation/ui/pages/time_tracker_module_entry.dart';

/// Folder the Figma-exported picker glyphs live in. They are all in
/// `home_assets/`, which pubspec already declares as an asset directory, so
/// adding them needed no pubspec change.
const String _pickerAssets = 'assets/icons_assets/home_assets';

// ── Roles module tabs ────────────────────────────────────────────────────────
// Indices as `RoleScreen._buildVisibleTabs` assigns them.
const int _roleManagementTab = 0;
const int _userManagementTab = 1;
const int _userAccessTab = 2;

/// Function Name: [_rolesModuleAt]
///
/// Purpose: The roles module, opened on one of its tabs.
///
/// FIXED 23/8/2026. Role Management, User Management and User Access were each
/// routed to their own page widget — `PlatFormRoleContainer`,
/// `UserManagementHome`, `UserAccessHomePage`. None of the three can stand
/// alone: every one reads `RoleCubit` (and the first two also
/// `UserManagementAccessCubit` / `UserAccessCubit`) out of the tree, and those
/// providers are installed by `Modules.roles.widget`. Pushed bare from the home
/// app bar they threw
///
///     Could not find the correct Provider<RoleCubit> above this
///     PlatFormRoleContainer Widget
///
/// `Modules.roles.widget` is the same thing the left rail builds — the three
/// providers wrapped around `RoleScreenHost` — so the icons now land exactly
/// where the rail would put them, tab included.
///
/// Parameters:
/// - [tabIndex]: Which tab of the roles module to open on.
///
/// Returns: [Widget] the roles module, providers and all.
Widget _rolesModuleAt(int tabIndex) {
  // Consumed and cleared by RoleScreen on its first build, and honoured only
  // if the user's permissions make that tab visible.
  RoleScreenHost.pendingInitialTab = tabIndex;
  return Modules.roles.widget;
}

/// Function Name: [_applyLanguage]
///
/// Purpose: Switch the app language, the way the Language settings screen does.
///
/// ADDED 23/8/2026. The English and AR icons had no behaviour at all. The three
/// steps are copied from `LanguageScreen.toggleLangSwitch`, which is the only
/// working language switch in the app: GetX needs the locale, the next cold
/// start reads it back out of storage, and the fonts differ per script.
///
/// That method also pins the device to portrait afterwards; deliberately NOT
/// copied — this runs from the tablet home app bar, and locking a tablet to
/// portrait because the user changed language would be a surprise.
///
/// Parameters:
/// - [locale]: The locale to switch to.
void _applyLanguage(Locale locale) {
  Get.updateLocale(locale);
  GetStorage().write(AppConstants.localeStorageKey, locale.languageCode);
  AppControllers.theme.updateFonts();
}

/// A catalog entry plus the module it is filtered under.
///
/// The module lives here rather than on [HeaderIconItem] deliberately:
/// [HeaderIconItem.svgPath] is what gets persisted to Firebase, and the model
/// is consumed by the cubit and the state. Filtering is a concern of this
/// dialog only, so it stays in the presentation layer.
class HeaderIconCatalogEntry {
  const HeaderIconCatalogEntry({required this.item, required this.module});

  final HeaderIconItem item;

  /// Which filter chip this icon counts towards. Never null — an entry with no
  /// module would be reachable only from "All" and would make the chip counts
  /// disagree with the total, which is the bug the add-widget page had.
  final Modules module;
}

/// Function Name: [headerIconCatalogEntries]
///
/// Purpose: Every icon the user may pin to the home app bar, with its module.
///
/// Parameters:
/// - [context]: Build context used to resolve localizations.
///
/// Returns: [List<HeaderIconCatalogEntry>] the selectable icons.
List<HeaderIconCatalogEntry> headerIconCatalogEntries(BuildContext context) {
  return <HeaderIconCatalogEntry>[
    HeaderIconCatalogEntry(
      module: Modules.employees,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_user_management.svg',
        getTitle: (ctx) => S.of(ctx).userManagement,
        // The roles module with its User Management tab selected, NOT
        // `UserManagementHome()` on its own — see [_rolesModuleAt].
        navigateTo: (context) => _rolesModuleAt(_userManagementTab),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.settings,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_english.svg',
        getTitle: (ctx) => S.of(ctx).english,
        navigateTo: (context) => const Placeholder(),
        // An action, not a page (23/8/2026).
        onTap: (context) => _applyLanguage(const Locale('en', 'US')),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.roles,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_roles.svg',
        getTitle: (ctx) => S.of(ctx).roles,
        navigateTo: (context) => _rolesModuleAt(_roleManagementTab),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.roles,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_user_access.svg',
        getTitle: (ctx) => S.of(ctx).userAccess,
        navigateTo: (context) => _rolesModuleAt(_userAccessTab),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.settings,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_dark_mode.svg',
        getTitle: (ctx) => S.of(ctx).lightDarkMode,
        navigateTo: (context) => const Placeholder(),
        // An action, not a page (23/8/2026). One toggle serves both the dark
        // and the light glyph — whichever is pinned flips the theme.
        onTap: (context) => AppControllers.theme.toggleTheme(),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.settings,
      item: HeaderIconItem(
        // The design labels this one "AR" — the Arabic counterpart of the
        // "English" tile. There is no `arabic` key in intl_en.arb (only
        // `english`), so the label is a literal until one is added.
        svgPath: '$_pickerAssets/picker_ar.svg',
        getTitle: (ctx) => 'AR',
        navigateTo: (context) => const Placeholder(),
        onTap: (context) => _applyLanguage(const Locale('ar', 'SA')),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.services,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_service_dashboard.svg',
        getTitle: (ctx) => S.of(ctx).serviceDashboard,
        navigateTo: (context) =>
            RemovedModulePage(moduleName: S.of(context).services),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.services,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_requested_services.svg',
        getTitle: (ctx) => S.of(ctx).requestedServices,
        navigateTo: (context) =>
            RemovedModulePage(moduleName: S.of(context).services),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.services,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_service_approvals.svg',
        getTitle: (ctx) => S.of(ctx).serviceApprovals,
        navigateTo: (context) =>
            RemovedModulePage(moduleName: S.of(context).services),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.inventory,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_inventory_dashboard.svg',
        getTitle: (ctx) => S.of(ctx).inventoryDashboard,
        navigateTo: (context) =>
            RemovedModulePage(moduleName: S.of(context).inventory),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.qiyas,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_qiyas_dashboard.svg',
        getTitle: (ctx) => S.of(ctx).qiyasDashboard,
        navigateTo: (context) => const Placeholder(),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.knowledgeHub,
      item: HeaderIconItem(
        // No `hubApproval` key exists in intl_en.arb — literal until one is
        // added. Every other label here resolves through S.of(ctx).
        svgPath: '$_pickerAssets/picker_hub_approval.svg',
        getTitle: (ctx) => 'Hub Approval',
        // WIRED 23/8/2026 — the page exists (knowledge_hub/k6_approvals) and
        // was simply never connected here. It reads `ApprovalsCubit` from the
        // tree, which normally comes from `KnowledgeHubPage`'s MultiBlocProvider
        // — opened on its own it has to bring its own, or it throws
        // ProviderNotFoundException the moment it builds.
        navigateTo: (context) => BlocProvider<ApprovalsCubit>(
          create: (_) => ApprovalsCubit(ApprovalsFirebaseServices()),
          child: const ApprovalsScreen(),
        ),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.todo,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_create_todo.svg',
        getTitle: (ctx) => S.of(ctx).createToDo,
        // WIRED 7/10/2026 — opens the To-Do module straight on the create
        // form (back lands on the list). TodoModuleEntry provides its cubits.
        navigateTo: (context) => const TodoModuleEntry(startInCreate: true),
      ),
    ),
    HeaderIconCatalogEntry(
      module: Modules.tasks,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_create_task.svg',
        getTitle: (ctx) => S.of(ctx).createTask,
        navigateTo: (context) => const Placeholder(),
      ),
    ),
    HeaderIconCatalogEntry(
      // WIRED 9/10/2026 (Time Tracker phase 6) — was `Modules.tracking` + a
      // Placeholder. The legacy tracking module is no longer in any drawer
      // (Modules.timeTracker took its slot), so the picker never offered this
      // icon. It now opens the Time Tracker main page, whose header holds the
      // Check In / Check Out control. No "New Request" icon: the picker set
      // has no glyph for it.
      module: Modules.timeTracker,
      item: HeaderIconItem(
        svgPath: '$_pickerAssets/picker_check_in_out.svg',
        getTitle: (ctx) => S.of(ctx).checkInOut,
        navigateTo: (context) => const TimeTrackerModuleEntry(),
      ),
    ),
  ];
}

/// Function Name: [headerIconCatalog]
///
/// Purpose: The flat icon list, for callers that do not care about modules.
///          Kept so existing call sites are untouched by the filter work.
///
/// Parameters:
/// - [context]: Build context used to resolve localizations.
///
/// Returns: [List<HeaderIconItem>] the selectable icons.
List<HeaderIconItem> headerIconCatalog(BuildContext context) =>
    headerIconCatalogEntries(context)
        .map((HeaderIconCatalogEntry e) => e.item)
        .toList();

/// Function Name: [headerIconForSvgPath]
///
/// Purpose: The catalog entry a pinned icon came from, so the app bar can find
///          out where that icon goes.
///
/// ADDED 23/8/2026. Only the asset path is persisted, and the item the cubit
/// rebuilds from it (`HeaderIconItem.fromSvgPath`) cannot carry a destination —
/// pages may not be imported from the data layer. So a pinned icon is matched
/// back to THIS catalog, the one place that knows both the path and the page.
///
/// Parameters:
/// - [context]: Build context used to build the catalog.
/// - [svgPath]: The pinned icon's asset path, current or legacy.
///
/// Returns: [HeaderIconItem] the catalog entry, or `null` when the path is not
/// in the catalog at all.
HeaderIconItem? headerIconForSvgPath(BuildContext context, String svgPath) {
  final String canonical = HeaderIconItem.canonicalSvgPath(svgPath);

  for (final HeaderIconCatalogEntry entry
      in headerIconCatalogEntries(context)) {
    if (entry.item.svgPath == canonical) return entry.item;
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// IconSelectorDialog
// ─────────────────────────────────────────────────────────────────────────────
class IconSelectorDialog extends StatefulWidget {
  final Function(HeaderIconItem) onIconSelected;

  const IconSelectorDialog({
    super.key,
    required this.onIconSelected,
  });

  @override
  State<IconSelectorDialog> createState() => _IconSelectorDialogState();
}

class _IconSelectorDialogState extends State<IconSelectorDialog> {
  HeaderIconItem? selectedItem;

  /// Canonical key for the "show everything" chip, matching the convention in
  /// `adding_widget_page.dart` so the two filters behave the same way.
  static const String _allKey = 'All';

  String _selectedModuleKey = _allKey;

  // ── Figma geometry (Frame 1597885454, 675x554) ─────────────────────────────
  // Kept as named constants so the numbers are traceable to the design instead
  // of being scattered through the tree as magic values.
  static const double _dialogWidth = 675;
  static const double _pad = 15;
  static const double _gutter = 15;
  static const double _tileWidth = 150;
  static const double _tileHeight = 38;
  static const double _tileRadius = 4;
  static const double _actionWidth = 135;
  static const double _actionHeight = 38;
  static const double _actionRadius = 8;
  static const double _actionGap = 30;

  // ── Filtering ──────────────────────────────────────────────────────────────

  List<HeaderIconCatalogEntry> get _visibleEntries {
    final List<HeaderIconCatalogEntry> all = headerIconCatalogEntries(context);
    if (_selectedModuleKey == _allKey) return all;
    return all
        .where((HeaderIconCatalogEntry e) => e.module.name == _selectedModuleKey)
        .toList();
  }

  /// Chips are built from the catalog itself, so the counts and the "All" total
  /// always describe the same set — the mismatch the add-widget page had when
  /// its chips and its list were derived from different lists.
  Widget _moduleFilter(List<HeaderIconCatalogEntry> all) {
    final Map<Modules, int> counts = <Modules, int>{};
    for (final HeaderIconCatalogEntry e in all) {
      counts[e.module] = (counts[e.module] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // The design's chip row is 1104 wide inside a 645 content column, so it
      // is meant to scroll rather than wrap.
      child: StatusChipFilter(
        selectedKey: _selectedModuleKey,
        onSelected: (String key) =>
            setState(() => _selectedModuleKey = key),
        items: <StatusChipItem>[
          StatusChipItem(
            key: _allKey,
            label: S.of(context).all,
            count: all.length,
          ),
          ...counts.entries.map(
            (MapEntry<Modules, int> e) => StatusChipItem(
              key: e.key.name,
              label: e.key.getModuleName,
              count: e.value,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tiles ──────────────────────────────────────────────────────────────────

  Widget _iconTile(HeaderIconItem icon) {
    final bool isSelected = selectedItem?.svgPath == icon.svgPath;

    return InkWell(
      borderRadius: BorderRadius.circular(_tileRadius.r),
      onTap: () => setState(() => selectedItem = isSelected ? null : icon),
      child: Container(
        width: _tileWidth.w,
        height: _tileHeight.h,
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(_tileRadius.r),
          border: isSelected
              ? Border.all(color: AppColors.text, width: 2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSvgImage(
              assetPath: icon.svgPath,
              width: 20.w,
              height: 20.h,
              color: AppColors.textButton,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                icon.title(context),
                style: StyleText.fontSize16Weight400.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.textButton,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    bool expand = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(_actionRadius.r),
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : _actionWidth.w,
        height: _actionHeight.sp,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(_actionRadius.r),
        ),
        child: Text(
          label,
          style: StyleText.fontSize16Weight400.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _wrapAction(bool isMobile, Widget child) =>
      isMobile ? Expanded(child: child) : child;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ContextExtension(context).isPhone;
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    final S l = S.of(context);

    final List<HeaderIconCatalogEntry> all = headerIconCatalogEntries(context);
    final List<HeaderIconCatalogEntry> visible = _visibleEntries;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      // Settings bug report p.12: on a phone the dialog grew to the full screen
      // height and Save / Discard were pushed past the bottom edge. The inset
      // keeps a margin round the dialog, and the max height below makes the
      // icon grid (already Flexible + scrollable) shrink instead, so the
      // buttons always stay inside the dialog.
      insetPadding: isMobile
          ? EdgeInsets.symmetric(horizontal: 16, vertical: 40)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        // Phones get the full width; the design's 675 is the tablet dialog.
        width: isMobile ? double.infinity : _dialogWidth.w,
        padding: EdgeInsets.all(_pad.sp),
        decoration: BoxDecoration(
          color: lightMode ? AppColors.white : AppColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: 26 circle + 14 grid glyph, then the title ───────────
            Row(
              children: [
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Center(
                    child: CustomSvgImage(
                      assetPath: '$_pickerAssets/picker_grid.svg',
                      width: 14.sp,
                      height: 14.sp,
                      fit: BoxFit.scaleDown,
                      color: AppColors.textButton,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  l.icons,
                  // 12sp, not the 20sp this used to be: the design sets the
                  // title smaller than the chip labels beside it.
                  style: StyleText.fontSize16Weight400.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // ── Module filter ───────────────────────────────────────────────
            _moduleFilter(all),

            SizedBox(height: 26.h),

            // ── Grid of icons ───────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: _gutter.w,
                  runSpacing: _gutter.h,
                  children: <Widget>[
                    for (final HeaderIconCatalogEntry entry in visible)
                      // A Wrap rather than a GridView: the tiles are a fixed
                      // 150 wide in the design, so the column count falls out
                      // of the available width instead of being forced — 4 on
                      // the tablet dialog, fewer on a phone.
                      SizedBox(
                        width: isMobile
                            ? double.infinity
                            : _tileWidth.w,
                        child: _iconTile(entry.item),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Discard / Save ──────────────────────────────────────────────
            // Left-aligned fixed-width pair, not the full-width Expanded pair
            // this used to be.
            // SWAPPED 21/9/2026 — Settings bug report p.16: Discard on the
            // left, Save on the right, like every other dialog in the app
            // (the Save was on the left). Discard also takes the shared grey +
            // white of the Discard / No buttons.
            // Phone: the pair splits the row with a 12 gap so neither button
            // runs past the dialog edge.
            Row(
              children: [
                _wrapAction(
                  isMobile,
                  _actionButton(
                    expand: isMobile,
                    label: l.discard,
                    color: AppColors.darkGrey,
                    textColor: AppColors.white,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                isMobile ? SizedBox(width: 12.sp) : Spacer(),
                _wrapAction(
                  isMobile,
                  _actionButton(
                  expand: isMobile,
                  label: l.save,
                  color: AppColors.primary,
                  textColor: AppColors.textButton,
                  onTap: () {
                    if (selectedItem == null) return;
                    widget.onIconSelected(selectedItem!);
                    Navigator.of(context).pop();
                  },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
