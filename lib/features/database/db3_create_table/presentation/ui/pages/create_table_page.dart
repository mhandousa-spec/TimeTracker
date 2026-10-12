/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: create_table_page.dart
/// Purpose: Declares `CreateTablePage`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// "Creating Table" — the first screen of the Figma section
/// "INSIDE DATABASE PAGE: Creating Table + Viewable Fields" (banner 7398:6131).
///
///   iPad HORIZONTAL  1024 x 1142  creating 7398:6533  editing 7398:6934
///   iPad VERTICAL     768 x 1142  creating 7398:6732  editing 7398:7121
///
/// ONE FILE, FOUR FRAMES. The two orientations differ only by the width of the
/// fields inside a column block, and `CreateTableMetrics` owns that. The two
/// MODES differ by three things, all of which read off `state.isEditing`:
///
///   breadcrumb     "Creating Table"  vs  "Editing Table Name"
///   primary button "Create"          vs  "Save"
///   count fields   drawn             vs  absent
///
/// Reached from the "+ Table" button on the database details screen, and from
/// tapping a row of the table list under it.
///
/// WHY THIS PUSHES ONTO THE MODULE'S NAVIGATOR
/// -------------------------------------------
/// [open] uses `Navigator.of(context)`, which from the details screen resolves
/// to the Navigator `DatabaseModuleEntry` hosts — so this screen renders INSIDE
/// the drawer's pane and the nav rail and header stay on screen. Pushing to the
/// root navigator instead is what drew db1's wizard over the whole window.
///
/// There is no nested Navigator here because there is no second step: unlike
/// the create-database wizard, creating a table is one card.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/core/custom/11-custom_confirm_diaolog.dart';
import 'package:knowticed_plus/core/custom/50-custom_side_frame_master.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/helper/main_helper/format_title.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_actions.dart';
import 'package:knowticed_plus/features/database/db1_create_database/presentation/ui/widgets/create_database_metrics.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/constants/create_table_constants.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/table_column.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/create_table_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_form_card.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/widgets/create_table_metrics.dart';

class CreateTablePage extends StatefulWidget {
  const CreateTablePage({
    super.key,
    required this.database,
    this.table,
    this.createdBy,
  });

  /// The database the table belongs to. Carried whole rather than as an id
  /// because the breadcrumb renders its localized name.
  final DatabaseEntity database;

  /// The table being edited, or null to create one. This single argument is
  /// what selects between the two Figma frames.
  final DatabaseTableEntity? table;

  /// Employee id stamped on the created record. Passed in rather than resolved
  /// from a controller here, so the page stays testable and the presentation
  /// layer keeps out of the employee module.
  final String? createdBy;

  /// Opens the screen and resolves with the saved table, or null if the user
  /// backed out. The details screen awaits this to refresh its list without a
  /// full refetch.
  static Future<DatabaseTableEntity?> open(
    BuildContext context, {
    required DatabaseEntity database,
    DatabaseTableEntity? table,
    String? createdBy,
  }) {
    return Navigator.of(context).push<DatabaseTableEntity>(
      MaterialPageRoute<DatabaseTableEntity>(
        builder: (_) => CreateTablePage(
          database: database,
          table: table,
          createdBy: createdBy,
        ),
      ),
    );
  }

  @override
  State<CreateTablePage> createState() => _CreateTablePageState();
}

class _CreateTablePageState extends State<CreateTablePage> {
  // The database's titles go in so the cubit's notifications can name the
  // parent ("the table X within Y", spec §1.7). Both sides are handed over, not
  // a localized pick: the recipient's language is resolved where the
  // notification is built, not where the screen is drawn.
  late final CreateTableCubit _cubit = widget.table == null
      ? CreateTableCubit.creating(
          databaseId: widget.database.id,
          databaseNameEn: widget.database.titleEn,
          databaseNameAr: widget.database.titleAr,
        )
      : CreateTableCubit.editing(
          table: widget.table!,
          databaseNameEn: widget.database.titleEn,
          databaseNameAr: widget.database.titleAr,
        );

  // Controllers are a widget concern, so they live here rather than in the
  // cubit. The cubit holds the values; these hold the cursor.
  late final TextEditingController _nameEn =
      TextEditingController(text: _cubit.state.nameEn);
  late final TextEditingController _nameAr =
      TextEditingController(text: _cubit.state.nameAr);
  late final TextEditingController _descriptionEn =
      TextEditingController(text: _cubit.state.descriptionEn);
  late final TextEditingController _descriptionAr =
      TextEditingController(text: _cubit.state.descriptionAr);
  late final TextEditingController _rowCount =
      TextEditingController(text: _cubit.state.rowCountText);
  late final TextEditingController _columnCount =
      TextEditingController(text: '${_cubit.state.columns.length}');

  /// Needed so the listener can tell whether the user is mid-edit before it
  /// rewrites the column-count box after a duplicate or a remove.
  final FocusNode _columnCountFocus = FocusNode();

  /// One controller per column, keyed by `TableColumn.id`.
  ///
  /// Keyed by id and not by index for the same reason the blocks are: removing
  /// the second of four columns would otherwise hand the third block's text to
  /// the row that used to be fourth.
  final Map<String, TextEditingController> _columnControllers =
      <String, TextEditingController>{};

  /// What [_close] hands back. Set once a write succeeds, so a screen that was
  /// only looked at does not make the details list refetch.
  DatabaseTableEntity? _saved;

  @override
  void dispose() {
    _nameEn.dispose();
    _nameAr.dispose();
    _descriptionEn.dispose();
    _descriptionAr.dispose();
    _rowCount.dispose();
    _columnCount.dispose();
    _columnCountFocus.dispose();
    for (final TextEditingController controller in _columnControllers.values) {
      controller.dispose();
    }
    _cubit.close();
    super.dispose();
  }

  // ── Controllers ──────────────────────────────────────────────────────────

  /// The controller for one column, created on first use.
  ///
  /// Created here rather than in the listener because a block can appear in the
  /// same frame the state changes, and a null controller would throw before the
  /// listener ever ran. Creating a `TextEditingController` notifies nobody, so
  /// doing it during build is safe — writing to one is not, which is why the
  /// text is only ever pushed back from [_resyncControllers].
  TextEditingController _columnControllerFor(TableColumn column) {
    return _columnControllers.putIfAbsent(
      column.id,
      () => TextEditingController(text: column.name),
    );
  }

  /// Pushes the cubit's values back into every box.
  ///
  /// Only two things need this — Discard and a successful save — and both
  /// replace the whole state, so the boxes have to be told. Ordinary typing
  /// must NOT come through here: the controller is already the source of that
  /// text, and rewriting it would move the cursor to the start on every
  /// keystroke.
  void _resyncControllers(CreateTableState state) {
    _nameEn.text = state.nameEn;
    _nameAr.text = state.nameAr;
    _descriptionEn.text = state.descriptionEn;
    _descriptionAr.text = state.descriptionAr;
    _rowCount.text = state.rowCountText;
    _columnCount.text = '${state.columns.length}';

    // COLUMN BOXES ARE UPDATED IN PLACE, NOT REPLACED (16/8/2026).
    //
    // This used to clear the whole map and dispose every column controller
    // after the frame, on the theory that "the column list was replaced so all
    // of them are stale". Two things were wrong with that.
    //
    // A column that SURVIVES the resync keeps its id, so its controller was
    // being thrown away and immediately rebuilt by `_columnControllerFor` for
    // no reason — churning an object a live `TextField` was holding, which is
    // how "A TextEditingController was used after being disposed" got thrown
    // one frame later. And a post-frame callback is not the guarantee the old
    // comment claimed: it fires after the CURRENT frame, which is not
    // necessarily after the rebuild that would have removed the field.
    //
    // Setting `.text` on the controllers that survive keeps the same objects in
    // the same fields, and [_pruneColumnControllers] disposes only the ones
    // whose column genuinely no longer exists — the case it was already written
    // for.
    for (final TableColumn column in state.columns) {
      final TextEditingController? existing = _columnControllers[column.id];
      // Guarded: assigning `.text` rebuilds the editing value and moves the
      // caret, so it must not happen when the text already matches.
      if (existing != null && existing.text != column.name) {
        existing.text = column.name;
      }
    }
    _pruneColumnControllers(state);
  }

  /// Drops controllers whose column no longer exists.
  ///
  /// Disposal is deferred to after the frame: the listener can run before the
  /// rebuild that removes the block, and disposing a controller a live
  /// `TextField` still holds throws. By the post-frame callback the field is
  /// gone.
  ///
  /// Since 16/8/2026 that reasoning no longer has to be airtight on its own.
  /// `CustomTextField.didUpdateWidget` adopts whatever controller it is handed
  /// on each build, so a field whose controller is replaced lets go of the old
  /// one during the rebuild rather than holding a reference into this callback.
  /// The deferral stays as the first line of defence; the field is the second.
  void _pruneColumnControllers(CreateTableState state) {
    final Set<String> live =
        state.columns.map((TableColumn column) => column.id).toSet();
    final List<String> orphans = _columnControllers.keys
        .where((String id) => !live.contains(id))
        .toList(growable: false);
    if (orphans.isEmpty) return;

    final List<TextEditingController> dropped = <TextEditingController>[
      for (final String id in orphans) _columnControllers.remove(id)!,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final TextEditingController controller in dropped) {
        controller.dispose();
      }
    });
  }

  // ── Column count ─────────────────────────────────────────────────────────

  /// Every keystroke: range check only. Resizing happens on commit.
  void _onColumnCountChanged(String raw) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final int? parsed = int.tryParse(raw.trim());

    if (raw.trim().isEmpty) {
      // Mid-edit emptiness is not an error yet — the user is retyping.
      _cubit.clearColumnCountError();
      return;
    }

    final bool valid = parsed != null &&
        parsed >= CreateTableLimits.minColumns &&
        parsed <= CreateTableLimits.maxColumns;

    if (valid) {
      _cubit.clearColumnCountError();
    } else {
      _cubit.columnCountRejected(strings.columnCountRange);
    }
  }

  /// Guards [_onColumnCountCommitted] against running twice for one commit.
  ///
  /// Pressing "done" fires `onSubmitted`, and opening the confirmation dialog
  /// then takes focus off the field, which fires `onFocusChanged(false)` — so
  /// without this the user is asked to confirm the same removal twice.
  bool _committingColumnCount = false;

  /// The user finished with the box: apply the number, asking first when doing
  /// so would delete columns they have already named.
  Future<void> _onColumnCountCommitted(String raw) async {
    if (_committingColumnCount) return;
    _committingColumnCount = true;
    try {
      await _commitColumnCount(raw);
    } finally {
      _committingColumnCount = false;
    }
  }

  Future<void> _commitColumnCount(String raw) async {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final int? parsed = int.tryParse(raw.trim());

    // Nothing usable typed: put the box back to the truth rather than leaving
    // it showing a number the card does not agree with.
    if (parsed == null ||
        parsed < CreateTableLimits.minColumns ||
        parsed > CreateTableLimits.maxColumns) {
      _columnCount.text = '${_cubit.state.columns.length}';
      _cubit.clearColumnCountError();
      return;
    }

    final int lost = _cubit.namedColumnsLostBy(parsed);
    if (lost > 0) {
      bool confirmed = false;
      await showConfirmDialog(
        context: context,
        title: strings.removeColumnsTitle,
        subtitle: strings.removeColumnsSubtitle(lost),
        confirmLabel: strings.yes,
        cancelLabel: strings.no,
        onConfirm: () => confirmed = true,
      );
      if (!mounted) return;

      if (!confirmed) {
        _columnCount.text = '${_cubit.state.columns.length}';
        return;
      }
    }

    _cubit.applyColumnCount(parsed);
  }

  // ── Intents ──────────────────────────────────────────────────────────────

  /// Create / Save.
  ///
  /// The column guards run HERE rather than inside `submit` because they need
  /// to name the offending block ("2nd Column needs a name"), and the ordinal
  /// is a localized string the cubit has no context to resolve.
  Future<void> _onPrimaryPressed() async {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final CreateTableState state = _cubit.state;

    // NOTHING TO SAVE, on the EDIT card only (17/8/2026).
    //
    // Runs before the column guards because it makes them moot: a form that
    // matches the record it was seeded from holds columns that were already
    // accepted once, so complaining about them would send the user to fix
    // something that is not wrong.
    //
    // Not applied when CREATING. There is no record to be unchanged from, and
    // db1's rule — "is anything typed" — would refuse an empty form with
    // "nothing changed", which answers a question nobody asked.
    //
    // The button beside this is already greyed for the same reason; this is
    // what it says when tapped, because `CreateDatabaseActions` deliberately
    // still fires a disabled-but-not-submitting primary.
    if (widgetIsEditing && !state.isDirty) {
      await showWarningDialog(
        context: context,
        title: strings.nothingChangedTitle,
        subtitle: strings.nothingChanged,
        closeLabel: strings.close,
      );
      return;
    }

    // NO COLUMN-NAME GUARDS (17/8/2026).
    //
    // Three checks stood here and all three are gone: "2nd Column needs a
    // name", "2nd Column is set to Number but does not hold a Number value",
    // and "Two columns are both called X".
    //
    // A Column Name is a HEADING, and the type rule was written as though it
    // had to be a VALUE of the column's own type — so a Number column could
    // not be called "Salary". Requiring a name and forbidding duplicates went
    // with it: the card now saves whatever headings were typed, blanks and
    // repeats included.
    //
    // Nothing downstream depends on those guarantees. `TableRowsGrid` draws
    // only the NAMED columns and says so when there are none, `ViewableFields`
    // keys on the column ID rather than its name, and `_sameColumns` compares
    // by position — so duplicate and empty headings are rendered, not
    // mishandled.

    // Creating asks for confirmation the way the create-database card does;
    // saving an edit does not, because the user is looking at a record they
    // already own and a second "are you sure" on every rename is friction.
    if (!state.isEditing) {
      bool confirmed = false;
      await showConfirmDialog(
        context: context,
        title: strings.confirmCreateTitle,
        subtitle: strings.confirmCreateSubtitle,
        confirmLabel: strings.yes,
        cancelLabel: strings.no,
        onConfirm: () => confirmed = true,
      );
      if (!confirmed || !mounted) return;
    }

    await _cubit.submit(
      requiredEnMessage: strings.nameEnRequired,
      requiredArMessage: strings.nameArRequired,
      tooShortMessage: strings.nameTooShort,
      duplicateMessage: strings.duplicateName,
      createdBy: widget.createdBy,
    );
  }

  Future<void> _onDiscardPressed() async {
    final CreateTableStrings strings = CreateTableStrings.of(context);

    // An untouched form does not need a confirmation — the dialog would just be
    // friction on a mis-tap.
    if (!_cubit.state.isDirty) {
      _close();
      return;
    }

    bool confirmed = false;
    await showConfirmDialog(
      context: context,
      title: strings.discardConfirmTitle,
      subtitle: strings.discardConfirmSubtitle,
      confirmLabel: strings.yes,
      cancelLabel: strings.no,
      onConfirm: () => confirmed = true,
    );
    if (!confirmed || !mounted) return;

    // On the EDIT card, Discard means "put it back to what was loaded" and stay
    // — the record is still there to work on. On the CREATE card there is
    // nothing to go back to, so it leaves.
    if (_cubit.state.isEditing) {
      _cubit.discard();
      _resyncControllers(_cubit.state);
      return;
    }
    _close();
  }

  void _close() => Navigator.of(context).pop<DatabaseTableEntity>(_saved);

  /// Runs on every state change: shows the success dialog once, surfaces a
  /// failure once, then clears the flag so a rebuild cannot repeat either.
  Future<void> _onStateChanged(
    BuildContext context,
    CreateTableState state,
  ) async {
    _pruneColumnControllers(state);

    // Duplicate and Remove change the column count without anyone typing into
    // the box, so it has to follow — but never while the user is in it, or a
    // half-typed number would be overwritten under the cursor.
    if (!_columnCountFocus.hasFocus &&
        _columnCount.text != '${state.columns.length}') {
      _columnCount.text = '${state.columns.length}';
    }

    final CreateTableStrings strings = CreateTableStrings.of(context);

    if (state.status == CreateTableStatus.failure &&
        state.errorMessage != null) {
      // The message is read and the flag cleared BEFORE the dialog is awaited:
      // clearing afterwards would leave the failure state live for as long as
      // the dialog is open, and the next emission would re-open it.
      final String message = state.errorMessage!;
      _cubit.clearMessages();
      await showErrorDialog(
        context: context,
        title: strings.errorTitle,
        subtitle: message,
        closeLabel: strings.close,
      );
      return;
    }

    if (state.status == CreateTableStatus.success) {
      final DatabaseTableEntity? saved = state.savedTable;
      if (saved == null) return;

      _saved = saved;
      // The card is now showing what the server returned, so the boxes have to
      // agree with it — a server-trimmed name would otherwise stay untrimmed on
      // screen until the page was reopened.
      _resyncControllers(state);

      await showSuccessDialog(
        context: context,
        title: strings.successTitle,
        subtitle:
            state.isEditing ? strings.savedSubtitle : strings.createdSubtitle,
        closeLabel: strings.close,
      );
      if (!mounted) return;

      // Creating ends the screen; editing stays on it, because the Figma's edit
      // card is somewhere you keep working rather than a one-shot form.
      if (!widgetIsEditing) _close();
    }
  }

  /// Whether this page was OPENED to edit — fixed for the page's life.
  ///
  /// Deliberately not `state.isEditing`: after a successful create the state is
  /// reseeded from the saved record and starts reporting `isEditing == true`,
  /// so reading it there would keep the create card open on a table it had
  /// already made.
  bool get widgetIsEditing => widget.table != null;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final CreateTableStrings strings = CreateTableStrings.of(context);
    final CreateTableMetrics metrics = CreateTableMetrics.of(context);
    final String databaseName =
        FormatHelper.capitalize(
            widget.database.localizedTitle(isArabic: context.isArabic));

    return BlocConsumer<CreateTableCubit, CreateTableState>(
      bloc: _cubit,
      listener: _onStateChanged,
      builder: (BuildContext context, CreateTableState state) {
        return PopScope(
          // The system back gesture has to carry the same result as the
          // breadcrumb, or a table created here would be invisible to the
          // details list until the screen was reopened.
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) return;
            _close();
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SideFrameMasterServices(
              titleText: strings.database,
              secondTitle: databaseName,
              thirdTitle: widgetIsEditing
                  ? strings.editingTableName
                  : strings.creatingTable,
              // "Database" leaves the section entirely; the database's own name
              // is one step back, to its details screen. Different
              // destinations, so different callbacks.
              //
              // The first crumb pops TWICE through one captured NavigatorState.
              // Reading `Navigator.of(context)` again after the first pop would
              // walk a defunct element; holding the state object is what makes
              // the second hop safe. The details route underneath has
              // `canPop: false`, so `maybePop` runs ITS close handler rather
              // than dropping it — which is how the list still receives the
              // table that was made here.
              onFirstTap: () {
                final NavigatorState navigator = Navigator.of(context);
                navigator.pop<DatabaseTableEntity>(_saved);
                navigator.maybePop();
              },
              onSecondTap: _close,
              // SideFrameMasterServices hands its child a BOUNDED height on
              // tablet, so a fixed-height Column overflows the moment the
              // content is one pixel taller than the viewport. This card grows
              // with every column block, so scrolling is the only thing that
              // holds.
              child: CreateDatabaseMetrics.pageScroll(
                context,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: metrics.base.extraHorizontalInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CreateTableFormCard(
                        metrics: metrics,
                        state: state,
                        cubit: _cubit,
                        nameEnController: _nameEn,
                        nameArController: _nameAr,
                        descriptionEnController: _descriptionEn,
                        descriptionArController: _descriptionAr,
                        rowCountController: _rowCount,
                        columnCountController: _columnCount,
                        columnCountFocusNode: _columnCountFocus,
                        columnControllerFor: _columnControllerFor,
                        onColumnCountChanged: _onColumnCountChanged,
                        onColumnCountCommitted: _onColumnCountCommitted,
                      ),
                      SizedBox(height: metrics.base.cardToActions),

                      CreateDatabaseActions(
                        metrics: metrics.base,
                        discardLabel: strings.discard,
                        primaryLabel:
                            widgetIsEditing ? strings.save : strings.create,
                        onDiscard: _onDiscardPressed,
                        onPrimary: _onPrimaryPressed,
                        isSubmitting: state.isSubmitting,
                        // SAVE STAYS GREY UNTIL SOMETHING IS EDITED
                        // (17/8/2026). Only on the edit card: `isDirty` means
                        // "different from the record as loaded" there, and
                        // "anything typed" when creating — gating Create on
                        // that would grey the button on a blank form, which is
                        // the state the user is about to fill in.
                        isPrimaryEnabled: !widgetIsEditing || state.isDirty,
                      ),
                      SizedBox(height: metrics.base.blockGap),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
