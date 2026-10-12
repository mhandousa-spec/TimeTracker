/// Module: database / db1_create_database / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: database_builder_page.dart
/// Purpose: Declares `DatabaseBuilderPage`.
/// Author: Knowticed Plus team
/// Created at: 15/8/2026
///
/// The module's landing screen — Figma 7398:2492 (iPad H) / 7398:2628 (V).
///
///   title, a row of count chips (All / Open / Restricted / Personal /
///   Drafts / Deleted), search + filter + sort, the yellow "Create Database"
///   button, and a grid of database cards.
///
/// This is the entry point: its button opens [CreateDatabaseFlow] and awaits
/// the created record, inserting it into the list rather than refetching.
///
/// Both orientations share this file. The card grid reflows through
/// `CrossAxisCountHelper`, the same helper every other grid in the app uses.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:knowticed_plus/core/custom/5-custom_button.dart';
import 'package:knowticed_plus/core/custom/6-custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/8-custom_filter_app.dart';
import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/14-custom_filter_icon.dart';
import 'package:knowticed_plus/core/custom/16-custom_card_styles.dart';
import 'package:knowticed_plus/core/custom/32-custom_svg.dart';
import 'package:knowticed_plus/core/custom/35-custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/41-custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/47-custom_sort_button.dart';
import 'package:knowticed_plus/core/custom/51-custom_pop_up.dart';
import 'package:knowticed_plus/core/custom/69-cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/custom/87-responsive_card_grid.dart';
import 'package:knowticed_plus/core/custom/66-circle_progress.dart';
import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/constants/create_database_constants.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_access_type.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/enums/database_sort_option.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/controller/database_list_cubit.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/pages/create_database_flow.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/database_filter_dialog.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/database_details_page.dart';
import 'package:knowticed_plus/features/database/db2_database_details/presentation/ui/pages/edit_database_page.dart';

class DatabaseBuilderPage extends StatefulWidget {
  const DatabaseBuilderPage({super.key, this.createdBy});

  final String? createdBy;

  @override
  State<DatabaseBuilderPage> createState() => _DatabaseBuilderPageState();
}

class _DatabaseBuilderPageState extends State<DatabaseBuilderPage> {
  late final DatabaseListCubit _cubit = DatabaseListCubit()..load();
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Opens the wizard and brings the list back in step with the server.
  ///
  /// TWO steps, not one. The insert is optimistic — the flow hands back the
  /// saved record, so the new card appears the instant the wizard closes with
  /// no spinner over a list the user was just looking at.
  ///
  /// The reload is the one that has to be right. The hand-back only survives
  /// the wizard closing through `onCompleted`; it is null whenever the flow
  /// ends any other way — Save For Later after the write, a back gesture, the
  /// success dialog dismissed by tapping the barrier, or a rebuild that
  /// disposed the route. In every one of those the record IS in Firestore and
  /// the list would have carried on showing "No databases yet" until the
  /// module was rebuilt. One collection read on a screen the user only
  /// reaches by finishing a wizard is a fair price for the list never lying.
  Future<void> _onCreatePressed() async {
    final DatabaseEntity? created = await CreateDatabaseFlow.open(
      context,
      createdBy: widget.createdBy,
    );

    if (created != null) _cubit.insert(created);

    // `load()` replaces the whole list, so the optimistic row above cannot end
    // up duplicated by this.
    await _cubit.load();
  }

  /// Opens the Filter card and applies what comes back.
  ///
  /// A dismissed dialog resolves to null and is ignored; only Apply reaches
  /// the cubit, so tapping outside cannot silently change the list.
  Future<void> _onFilterPressed() async {
    final DatabaseFilterResult? result = await DatabaseFilterDialog.show(
      context,
      initialAccessType: _cubit.state.accessFilter,
    );

    if (result != null) _cubit.accessFilterChanged(result.accessType);
  }

  /// "Delete" on a card's "..." menu: confirm, delete, and only report the
  /// failure — the success is visible, the card has moved to Deleted.
  ///
  /// SOFT since 16/8/2026. Nothing leaves Firestore: the record's status
  /// changes, so the card drops out of whichever chip the user is standing in
  /// and appears under Deleted with the count to match. [_onRestorePressed] is
  /// the way back, and the access grants are untouched throughout — which is
  /// what makes the way back mean anything.
  Future<void> _onDeletePressed(DatabaseEntity database) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final String title =
        FormatHelper.capitalize(database.localizedTitle(isArabic: context.isArabic));

    // showConfirmDialog pops before invoking onConfirm, so this flag is set
    // while the await above is still suspended and is readable here. Cancel
    // and a barrier tap both leave it false.
    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.deleteConfirmTitle,
      subtitle: strings.deleteConfirmSubtitle(title),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );

    if (!confirmed || !mounted) return;

    final bool deleted = await _cubit.delete(database);
    if (deleted || !mounted) return;

    await showErrorDialog(
      context: context,
      title: strings.deleteFailedTitle,
      subtitle: _cubit.state.errorMessage ?? strings.deleteFailed,
      closeLabel: strings.close,
    );
    _cubit.clearMessages();
  }

  /// "Restore" on a deleted card's "..." menu. ADDED 16/8/2026.
  ///
  /// Same shape as delete — confirm, write, report only the failure — because
  /// it is the same kind of action in the other direction, and a success
  /// dialog on top of a card that visibly moved would be one tap of noise.
  ///
  /// The confirmation names WHERE the record is going, and it asks
  /// `restoreTarget` — the same value the cubit writes — so the sentence and
  /// the write cannot drift: a database that was a draft when it was deleted
  /// goes back to Drafts, not into the finished list.
  Future<void> _onRestorePressed(DatabaseEntity database) async {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final String title = database.localizedTitle(isArabic: context.isArabic);

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.restoreConfirmTitle,
      subtitle: strings.restoreConfirmSubtitle(
        title,
        asDraft: database.restoreTarget.isDraft,
      ),
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );

    if (!confirmed || !mounted) return;

    final bool restored = await _cubit.restore(database);
    if (restored || !mounted) return;

    await showErrorDialog(
      context: context,
      title: strings.restoreFailedTitle,
      subtitle: _cubit.state.errorMessage ?? strings.restoreFailed,
      closeLabel: strings.close,
    );
    _cubit.clearMessages();
  }

  /// "Edit" on a card's "..." menu.
  ///
  /// WIRED UP 16/8/2026. This used to raise a "not available yet" dialog
  /// because the wizard has no edit mode — `CreateDatabaseFlow` always starts
  /// on a blank draft, so opening it here would have written a SECOND record
  /// with the same title. db2's `EditDatabasePage` is the real editor: it
  /// opens on the record, updates in place, and excludes the record from its
  /// own duplicate-title check.
  ///
  /// It goes straight to the editing card rather than through the details
  /// screen, because the menu row says "Edit" — a menu item that opened a
  /// different screen with an Edit button on it would be one tap of
  /// misdirection.
  Future<void> _onEditPressed(DatabaseEntity database) async {
    final DatabaseEntity? saved = await EditDatabasePage.open(
      context,
      database: database,
    );

    if (saved == null || !mounted) return;
    _cubit.replace(saved);
  }

  /// Reopens the wizard on a parked draft so the user can finish it. ADDED
  /// 16/8/2026.
  ///
  /// The flow resolves with the SAVED record and the write behind it was an
  /// update — same document, same id — so this swaps the row rather than
  /// inserting one. Finishing a draft turns its status active, which is what
  /// moves the card out of the Drafts chip and into its access type.
  ///
  /// The reload afterwards is the same belt-and-braces `_onCreatePressed`
  /// uses: the hand-back only survives the wizard closing through
  /// `onCompleted` and is null on a back gesture, a "Save For Later", or a
  /// success dialog dismissed by its barrier — and in every one of those the
  /// write has still happened.
  Future<void> _onDraftPressed(DatabaseEntity draft) async {
    final DatabaseEntity? saved = await CreateDatabaseFlow.open(
      context,
      createdBy: widget.createdBy,
      draft: draft,
    );

    if (!mounted) return;
    if (saved != null) _cubit.replace(saved);
    await _cubit.load();
  }

  /// Tapping a card opens the details screen — the Figma's
  /// "INSIDE DATABASE PAGE" section.
  ///
  /// The outcome decides what happens to the card rather than a blanket
  /// reload: a deleted record is marked, an edited one is swapped. Both are
  /// already true on the server by the time this returns, so neither is an
  /// optimistic guess.
  Future<void> _onCardPressed(DatabaseEntity database) async {
    // A DELETED record OPENS, READ-ONLY (16/8/2026). This used to return
    // early, which made every card under the Deleted chip a dead tap: the
    // record is still there in full — its tables, its grants, its dates — and
    // "what was in this before I deleted it?" is the whole reason someone
    // stands in that chip. Refusing to open it answered a reasonable question
    // with nothing at all.
    //
    // What does NOT come with it is the ability to act on it. `readOnly` drops
    // Edit and Delete from the details screen: editing a deleted record would
    // save changes into a row nobody can see, and Delete has nothing left to
    // do. Restore stays where it already is — the card's "..." menu — because
    // that is the one action that makes sense here and it is one tap away.
    //
    // A DRAFT REOPENS THE WIZARD, not the details screen (16/8/2026).
    //
    // The details screen is built around a FINISHED database: granted access,
    // a table list, an access editor. A draft has none of that — it is
    // unfinished work, and the only useful thing to do with it is finish it.
    // Sending it to the details screen made tapping a draft a dead end showing
    // an empty access table, with no way back into the flow that produced it.
    if (database.isDraft) {
      await _onDraftPressed(database);
      return;
    }

    final DatabaseDetailsOutcome? outcome = await DatabaseDetailsPage.open(
      context,
      database: database,
      editedBy: widget.createdBy,
      readOnly: database.isDeleted,
    );

    if (outcome == null || !mounted) return;

    if (outcome.deleted) {
      // Was `removeLocally`. The details screen's Delete is the same soft
      // delete as the menu's, so the record is still there — dropping the row
      // would hide it from the Deleted chip until the next full load, which is
      // exactly where the user goes looking for it.
      _cubit.markDeletedLocally(outcome.database.id);
      return;
    }
    _cubit.replace(outcome.database);
  }

  @override
  Widget build(BuildContext context) {
    final CreateDatabaseStrings strings = CreateDatabaseStrings.of(context);
    final bool isArabic = context.isArabic;

    return BlocBuilder<DatabaseListCubit, DatabaseListState>(
      bloc: _cubit,
      builder: (BuildContext context, DatabaseListState state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 15.h),
                  Text(
                    strings.databaseBuilder,
                    style: StyleText.fontSize24Weight600
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 15.h),

                  // The shared chip row (custom 8). Its key is the enum's
                  // `name`, so the cubit stores a DatabaseListFilter and never
                  // has to know about chip indices.
                  StatusChipFilter(
                    items: _chips(state, strings),
                    selectedKey: state.filterKey,
                    onSelected: _cubit.filterChanged,
                  ),
                  SizedBox(height: 15.h),

                  _Toolbar(
                    searchController: _search,
                    onSearchChanged: _cubit.searchChanged,
                    onCreate: _onCreatePressed,
                    onFilter: _onFilterPressed,
                    isFilterActive: state.hasAccessFilter,
                    sortOption: state.sortOption,
                    onSortChanged: _cubit.sortChanged,
                    isArabic: isArabic,
                    strings: strings,
                  ),
                  SizedBox(height: 15.h),

                  Expanded(
                    child: state.isLoading
                        ? const CircleProgressMaster()
                        : _grid(state, strings, isArabic),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Maps the filter enum onto the shared chip model. Labels come from the
  /// module's string table, counts from the cubit — so the widget stays
  /// generic and this page owns the wording.
  List<StatusChipItem> _chips(
    DatabaseListState state,
    CreateDatabaseStrings strings,
  ) {
    String labelFor(DatabaseListFilter f) {
      switch (f) {
        case DatabaseListFilter.all:
          return strings.all;
        case DatabaseListFilter.open:
          return strings.open;
        case DatabaseListFilter.restricted:
          return strings.restricted;
        case DatabaseListFilter.personal:
          return strings.personal;
        case DatabaseListFilter.drafts:
          return strings.drafts;
        case DatabaseListFilter.deleted:
          return strings.deleted;
      }
    }

    return DatabaseListFilter.values
        .map((DatabaseListFilter f) => StatusChipItem(
              key: f.name,
              label: labelFor(f),
              count: state.countFor(f),
            ))
        .toList(growable: false);
  }

  Widget _grid(
    DatabaseListState state,
    CreateDatabaseStrings strings,
    bool isArabic,
  ) {
    // A FAILED read and an EMPTY collection are different things and must not
    // look the same. `load()` stores its failure in state and nothing rendered
    // it, so a denied Firestore read — or any network error — showed "No
    // databases yet": the screen said the collection was empty when it had
    // simply never been read. That is the one message a user cannot argue
    // with, and it is exactly what a freshly created record disappearing looks
    // like.
    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: StyleText.fontSize14Weight400
                  .copyWith(color: AppColors.red),
            ),
            SizedBox(height: 12.h),
            customButton(
              title: strings.retry,
              function: () => _cubit.load(),
              wrapContent: true,
              color: AppColors.primary,
              textColor: AppColors.textButton,
            ),
          ],
        ),
      );
    }

    final List<DatabaseEntity> items = state.visible(isArabic: isArabic);

    // The shared animation for every chip, Deleted included (16/8/2026). The
    // chip the user is standing in is on screen right above this, so it
    // already says which kind of nothing this is — which is what the two
    // sentences here were spending words on.
    //
    // NOT used for the failure branch above: a denied read is not an empty
    // list, and this is the screen where confusing the two is worst.
    if (items.isEmpty) return const CustomEmptyState();

    // The thumbnail is the tallest thing in the card, so it drives the row
    // height: 80 on the phone frame (card 343 x 100), 60 on tablet.
    final double cardHeight = ResponsiveCardHeight.forListCard(
      context,
      titleSize: 14,
      subtitleSize: 11,
      captionSize: 11,
      gap: 5,
      verticalPadding: 20,
      thumbnailHeight: context.isPhone ? 80 : 60,
    );

    return GridView.builder(
      padding: EdgeInsets.only(bottom: 20.h),
      itemCount: items.length,
      gridDelegate: ResponsiveCardHeight.delegate(
        crossAxisCount:
            CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
        cardHeight: cardHeight,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (BuildContext context, int index) => _DatabaseCard(
        database: items[index],
        strings: strings,
        isArabic: isArabic,
        onTap: () => _onCardPressed(items[index]),
        onEdit: () => _onEditPressed(items[index]),
        onDelete: () => _onDeletePressed(items[index]),
        onRestore: () => _onRestorePressed(items[index]),
      ),
    );
  }
}

/// Search + Filter + Sort + the yellow Create button (Figma 7398:2492).
///
/// Every control here is a shared widget rather than something shaped locally:
/// `CustomFilterIcon` and `CustomSortButton` already carry the app's outlined
/// pill styling and their own SVGs, and `customButtonWithSvg` routes the
/// primary button through `ButtonSizing` so it matches every other button in
/// the app.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreate,
    required this.onFilter,
    required this.isFilterActive,
    required this.sortOption,
    required this.onSortChanged,
    required this.isArabic,
    required this.strings,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCreate;
  final VoidCallback onFilter;

  /// Whether the Filter dialog is currently narrowing the list.
  final bool isFilterActive;

  /// The ordering currently applied, or null for none — which is also what
  /// decides whether the Sort button is tinted.
  final DatabaseSortOption? sortOption;

  final ValueChanged<DatabaseSortOption?> onSortChanged;

  final bool isArabic;

  final CreateDatabaseStrings strings;

  /// The module's own icon for the Create button.
  static const String _createSvg =
      'assets/icons_assets/database_builder_assets/create_data_base.svg';

  @override
  Widget build(BuildContext context) {
    // PHONE (Figma 7398:12797): the toolbar is search + icon buttons + the
    // yellow create icon in a 375 frame, and none of them carry a label.
    // Keeping the tablet row here would put four labelled controls in 345pt
    // and leave the search box about 60pt wide.
    final bool isPhone = context.isPhone;

    return Row(
      children: <Widget>[
        // AppSearchTextField's root IS an Expanded, so it goes straight into
        // the Row — wrapping it in another one throws
        // "Competing ParentDataWidgets".
        AppSearchTextField(
          controller: searchController,
          hintText: strings.search,
          fillColor: AppColors.card,
          onChanged: onSearchChanged,
        ),
        SizedBox(width: 10.w),

        // Filter opens the Filter card (Figma frame 1597883942). While a
        // filter is applied the button carries the brand fill: the dialog
        // closes over the grid, so without this the only evidence that the
        // list is being narrowed is cards being absent — which reads as data
        // loss, not as a filter.
        CustomFilterIcon(
          title: strings.filter,
          color: isFilterActive ? AppColors.primary : AppColors.card,
          svgColor:
              isFilterActive ? AppColors.textButton : AppColors.secondaryText,
          textStyle: StyleText.fontSize14Weight400.copyWith(
            color:
                isFilterActive ? AppColors.textButton : AppColors.secondaryText,
          ),
          onTap: onFilter,
        ),
        SizedBox(width: 10.w),

        // SORT — the Figma's popover next to Filter, live since 16/8/2026.
        //
        // `CustomSortButton` rather than `CustomSortIcon`: the icon variant is
        // a bare button with an onTap, so making it work would have meant
        // hand-rolling the popover, its selected-row highlight and the
        // brand-fill-when-active state that Filter already has. The sort
        // button IS that popover, and it tints its own container from `value`
        // — which is why nothing here has to compute a colour.
        //
        // Deselecting is part of the widget's contract: tapping the selected
        // row hands back null, and `sortChanged` reads that as "back to the
        // repository's order".
        //
        // ICON-ONLY ON PHONE (`showTitle: false`), the same shape the
        // messaging module uses in portrait — a 38pt square, so the phone
        // toolbar keeps three same-sized controls beside the search box rather
        // than losing Sort altogether. The wider overlay offset on phone
        // clears the taller tap target.
        CustomSortButton<DatabaseSortOption>(

          value: sortOption,
          items: DatabaseSortOption.values,
          labelBuilder: (DatabaseSortOption option) =>
              option.label(isArabic: isArabic),
          onChanged: onSortChanged,
          title: strings.sort,
          showTitle: !isPhone,
          // Wider than Filter's 100.sp so the label sits comfortably clear of
          // the icon. The width is FIXED regardless of what is selected — the
          // trigger always reads "Sort" — so the toolbar does not reflow when
          // the user picks an option.
          width: isPhone ? ButtonSizing.iconButtonSize : 100.sp,
          // Same source of truth as the Filter button beside it, rather than a
          // literal that happens to match today.
          height: ButtonSizing.height,
          yOffset: isPhone ? 50 : 16,
        ),
        SizedBox(width: 10.w),

        customButtonWithSvg(
          // An empty title is `customButtonWithSvg`'s own icon-only mode — a
          // 38.sp square — which is exactly the phone frame's yellow create
          // button. Passing '' rather than shaping a square button here keeps
          // the sizing decision inside ButtonSizing.
          title: isPhone ? '' : strings.createDatabase,
          function: onCreate,
          color: AppColors.primary,
          colorBorder: AppColors.transparent,
          image: _createSvg,
          widthImage: isPhone ? 24.r : 18.r,
          heightImage: isPhone ? 24.r : 18.r,
          // The icon is tinted to the button's computed label colour rather
          // than left at its own fill, so it stays legible if the company's
          // brand primary is dark. See AppTheme.contrastColor().
          svgColor: AppColors.textButton,
          textStyle: StyleText.fontSize16Weight500
              .copyWith(color: AppColors.textButton),
        ),
      ],
    );
  }
}

/// One database card — thumbnail, title, table count, creation date, access,
/// and the "..." menu (Figma "3 Dots": Edit, then Delete in red).
class _DatabaseCard extends StatelessWidget {
  const _DatabaseCard({
    required this.database,
    required this.strings,
    required this.isArabic,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onRestore,
  });

  final DatabaseEntity database;
  final CreateDatabaseStrings strings;
  final bool isArabic;

  /// Opens the details screen. The "..." button sits in a `Stack` ABOVE the
  /// card, so it swallows its own taps and the menu cannot be triggered by
  /// this — which is what lets the whole card be tappable without the two
  /// gestures competing.
  final VoidCallback onTap;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Puts a soft-deleted record back. Only reachable while the card IS
  /// deleted — see [_menu].
  final VoidCallback onRestore;

  /// Menu values. Local strings rather than an enum because
  /// `CustomPopupMenuButton` is a `PopupMenuButton<String>` — the shared
  /// widget's contract, not a choice made here.
  static const String _actionEdit = 'edit';
  static const String _actionDelete = 'delete';
  static const String _actionRestore = 'restore';

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: onTap,
          // Opaque so the taps that land on the card's padding and on the gaps
          // between its text rows open the record too — without it only the
          // glyphs themselves would be hittable.
          behavior: HitTestBehavior.opaque,
          child: Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: CardStyles.shadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // The phone card is 343 x 100 with an 80pt thumbnail (Figma
              // 7398:12797); the tablet card is narrower per column, so its
              // thumbnail stays at 60. One card, two sizes — the rest of the
              // layout is identical, which is why this is not a second widget.
              Builder(builder: (BuildContext context) {
                final double thumb = context.isPhone ? 70.sp : 60.sp;
                return Container(
                  width: thumb,
                  height: thumb,
                  decoration: BoxDecoration(
                    color: AppTheme.isDark
                        ? AppColors.colorBlack
                        : AppColors.fieldFillLight,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  alignment: Alignment.center,
                  child: CustomSvgImage(
                    assetPath:
                        'assets/icons_assets/database_builder_assets/create_data_base.svg',
                    width: thumb * 0.625,
                    fit: BoxFit.fill,
                    height: thumb * 0.625,
                    color: AppColors.secondaryText,
                  ),
                );
              }),
              SizedBox(width: 10.w),
              Expanded(
                child: ResponsiveCardContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        FormatHelper.capitalize(
                            database.localizedTitle(isArabic: isArabic)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StyleText.fontSize14Weight500
                            .copyWith(color: AppColors.text),
                      ),
                      // SizedBox(height: 2.h),
                      _line(strings.noOfTables, '${database.tablesCount}'),
                      _line(strings.creation, _date(database.createdAt)),
                      _line(
                        strings.access,
                        isArabic
                            ? database.accessType.labelAr
                            : database.accessType.labelEn,
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
        ),
        Positioned(
            bottom: 45.sp,
            child: _menu()),
      ],
    );
  }

  /// The card's "..." button.
  ///
  /// `CustomPopupMenuButton` (custom 51) with an empty title, which is the
  /// widget's own icon-only mode — a 38.sp square that carries the app's
  /// hover highlight and corner radius. Nothing about the menu is rebuilt
  /// here; Delete is red purely through `PopupOption.labelColor`.
  ///
  /// TWO MENUS, ONE BUTTON (16/8/2026). A deleted record offers Restore and
  /// nothing else — Edit would open the editor on a record that is not in the
  /// list, and Delete on something already deleted has nothing to do. Swapping
  /// the rows rather than disabling them keeps the menu to what is actually
  /// possible from the chip the user is standing in.
  Widget _menu() {
    final bool isDeleted = database.isDeleted;

    return CustomPopupMenuButton(
      title: '',
      iconPath: 'assets/icons_assets/main_icons_assets/dots_horizontal.svg',
      backgroundColor: AppColors.transparent,
      iconColor: AppColors.secondaryText,
      options: isDeleted
          ? <PopupOption>[
              PopupOption(value: _actionRestore, label: strings.restore),
            ]
          : <PopupOption>[
              PopupOption(value: _actionEdit, label: strings.edit),
              PopupOption(
                value: _actionDelete,
                label: strings.delete,
                labelColor: AppColors.red,
              ),
            ],
      onSelected: (String value) {
        if (value == _actionRestore) {
          onRestore();
        } else if (value == _actionDelete) {
          onDelete();
        } else if (value == _actionEdit) {
          onEdit();
        }
      },
    );
  }

  Widget _line(String label, String value) => Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Text.rich(
          TextSpan(
            text: '$label ',
            style: StyleText.fontSize12Weight400
                .copyWith(color: AppColors.secondaryText),
            children: <InlineSpan>[
              TextSpan(
                text: value,
                style: StyleText.fontSize12Weight600
                    .copyWith(color: AppColors.text),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );

  String _date(DateTime? date) {
    if (date == null) return '—';
    const List<String> months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
