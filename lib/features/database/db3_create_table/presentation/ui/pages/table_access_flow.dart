/// Module: database / db3_create_table / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: table_access_flow.dart
/// Purpose: Declares `TableAccessFlow`.
/// Author: Knowticed Plus team
/// Created at: 16/8/2026
///
/// The host that owns "Editing Table Access" and its nested Navigator.
///
///   step 1  pick the people          7398:13651 (H) / 7398:13925 (V)
///   step 2  set the rule and fields   7398:14553 (V) / 7398:14122 (H)
///
/// WHY A NESTED NAVIGATOR
/// ----------------------
/// The two steps push and pop between themselves, but the flow as a whole is
/// one destination from the table list — closing it should return one result,
/// not unwind two routes. A nested Navigator makes "back" inside the flow mean
/// "previous step". Same contract as db1's `CreateDatabaseFlow` and db2's
/// `EditDatabaseAccessFlow`.
///
/// The cubit is created HERE, above that Navigator, which is what lets the
/// picked people survive step 2 being popped. Both screens receive it
/// explicitly rather than reading it from context, so a screen cannot
/// accidentally be used outside the flow that owns its state.

import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/database/db1_create_database/domain/entities/database_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/domain/entities/database_table_entity.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/controller/table_access_cubit.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/table_access_page.dart';
import 'package:knowticed_plus/features/database/db3_create_table/presentation/ui/pages/table_access_review_page.dart';

class TableAccessFlow extends StatefulWidget {
  const TableAccessFlow({
    super.key,
    required this.database,
    required this.table,
    this.editedBy,
    this.editedByNameEn,
    this.editedByNameAr,
  });

  /// Carried whole rather than as an id because the breadcrumb renders its
  /// localized name.
  final DatabaseEntity database;
  final DatabaseTableEntity table;

  /// Stamps the "Access Grantor" columns on every grant written here.
  final String? editedBy;
  final String? editedByNameEn;
  final String? editedByNameAr;

  /// Opens the flow and resolves with the table as it now stands — its
  /// `memberCount` updated — or null if the user backed out without saving.
  static Future<DatabaseTableEntity?> open(
    BuildContext context, {
    required DatabaseEntity database,
    required DatabaseTableEntity table,
    String? editedBy,
    String? editedByNameEn,
    String? editedByNameAr,
  }) {
    return Navigator.of(context).push<DatabaseTableEntity>(
      MaterialPageRoute<DatabaseTableEntity>(
        builder: (_) => TableAccessFlow(
          database: database,
          table: table,
          editedBy: editedBy,
          editedByNameEn: editedByNameEn,
          editedByNameAr: editedByNameAr,
        ),
      ),
    );
  }

  @override
  State<TableAccessFlow> createState() => _TableAccessFlowState();
}

class _TableAccessFlowState extends State<TableAccessFlow> {
  // The database's titles go in so the cubit's §1.7 access notifications can
  // say "access to {{databaseName}} / {{tableName}}". Both sides, not a
  // localized pick — the recipient's language is resolved where the
  // notification is built.
  late final TableAccessCubit _cubit = TableAccessCubit(
    table: widget.table,
    databaseNameEn: widget.database.titleEn,
    databaseNameAr: widget.database.titleAr,
  )..load();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// The table as saved, or null while nothing has been written. Decides what
  /// [_closeFlow] hands back, so a screen that was only looked at does not make
  /// the table list redraw.
  DatabaseTableEntity? _saved;

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// Closes the flow by popping the MODULE's navigator — deliberately
  /// `Navigator.of(context)` and not the inner key, which can only move between
  /// steps.
  void _closeFlow() =>
      Navigator.of(context).pop<DatabaseTableEntity>(_saved);

  void _onSaved(DatabaseTableEntity table) {
    _saved = table;
    _closeFlow();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back at step 1 leaves the flow; at step 2 it means "previous step", so
      // the inner Navigator gets first refusal.
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        final NavigatorState? nav = _navigatorKey.currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
          return;
        }
        _closeFlow();
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => TableAccessPage(
            cubit: _cubit,
            database: widget.database,
            onExit: _closeFlow,
            onReview: () => _navigatorKey.currentState?.push(
              MaterialPageRoute<void>(
                builder: (_) => TableAccessReviewPage(
                  cubit: _cubit,
                  database: widget.database,
                  editedBy: widget.editedBy,
                  editedByNameEn: widget.editedByNameEn,
                  editedByNameAr: widget.editedByNameAr,
                  onExit: _closeFlow,
                  onCompleted: _onSaved,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
