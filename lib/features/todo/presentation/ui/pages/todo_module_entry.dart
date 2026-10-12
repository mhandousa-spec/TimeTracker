/// Module: todo / presentation / ui / pages
///
///*************************** FILE INFO ****************************///
/// File Name: todo_module_entry.dart
/// Purpose: Declares `TodoModuleEntry` — what `Modules.todo.widget` returns —
///          Provides the module's shared cubits and hosts
///          its screens in a nested Navigator.
/// Author: Knowticed Plus team
/// Created at: 7/10/2026
/// Updated: 7/10/2026 - Hosts the nested Navigator (root = TodoListPage) and
///          the View permission gate.
/// Updated: 7/10/2026 - `initialTodoId` (home checklist row → that to-do's
///          details) and the optimistic-tick wiring between the two cubits.
/// Updated: 7/10/2026 - `pendingTodoId`: a notification's View on the
///          desktop / tablet shell opens that to-do's details.
///
/// Every way into the module (drawer, nav bar, More page, notification tap,
/// home "View") ends here, so the cubits are created here and nowhere else.
///
/// WHY A NESTED NAVIGATOR (same pattern as `database_module_entry.dart`)
/// --------------------------------------------------------------------
/// The module is a leaf inside the shell's IndexedStack (tablet: rail +
/// CustomAppBar header; phone: bottom nav bar). Pushing to the root navigator
/// would cover that shell. The nested Navigator keeps the rail/header (tablet)
/// and the bottom nav (phone — Figma 1:33404 keeps it on the form) visible.
///
/// Unlike the database module the Navigator is used on PHONE too, and the
/// MultiBlocProvider sits ABOVE it: the form and details pages are pushed
/// routes and must still find `TodoListCubit` / `TodoActionsCubit`. A route
/// pushed to the root navigator would lose both.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:knowticed_plus/core/custom/89-custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/90-app_scroll_behavior.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/features/todo/data/services/todo_access.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/controller/todo_list_cubit.dart';
import 'package:knowticed_plus/features/todo/t1_todo_list/presentation/ui/pages/todo_list_page.dart';
import 'package:knowticed_plus/features/todo/t2_todo_form/presentation/ui/pages/todo_form_page.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/controller/todo_actions_cubit.dart';
import 'package:knowticed_plus/features/todo/t3_todo_details/presentation/ui/pages/todo_details_page.dart';
import 'package:knowticed_plus/generated/l10n.dart';

// NO GlobalKey on the nested Navigator (fix 8/10/2026): the module is built
// in TWO places at once — the shell's IndexedStack keeps the Todo tab alive,
// and Home / Calendar / Notification push a second TodoModuleEntry on top.
// A shared `todoNavKey` made both Navigators claim the same GlobalKey
// ("Duplicate GlobalKey" every frame), which froze/lagged the screen.

class TodoModuleEntry extends StatelessWidget {
  const TodoModuleEntry({
    super.key,
    this.startInCreate = false,
    this.initialTodoId,
  });

  /// Opens the module with the create form already pushed on top of the list
  /// (home header "Create To Do" icon). Back from the form lands on the list.
  final bool startInCreate;

  /// Opens the module with this to-do's details already pushed on top of the
  /// list (home checklist row tap). Back from details lands on the list.
  /// Ignored when [startInCreate] is set.
  final String? initialTodoId;

  /// One-shot hint from the notification inbox's View (desktop / tablet
  /// shell), where the module is built by the drawer as `Modules.todo.widget`
  /// and cannot be handed [initialTodoId]. Same shape as
  /// `RoleScreenHost.pendingInitialTab`: armed just before the drawer
  /// switches, consumed — and cleared, used or not — when the module's
  /// navigator builds its first routes. [initialTodoId] wins when both are set.
  static String? pendingTodoId;

  /// The list, plus the create form or one to-do's details on top of it.
  List<Route<dynamic>> _initialRoutes() {
    final String? pending = pendingTodoId;
    pendingTodoId = null;
    final String? todoId = initialTodoId ?? pending;
    final bool openCreate =
        startInCreate && GetIt.instance<TodoAccess>().canCreate;
    return <Route<dynamic>>[
      MaterialPageRoute<void>(builder: (_) => const TodoListPage()),
      if (openCreate)
        MaterialPageRoute<void>(builder: (_) => const TodoFormPage())
      else if (todoId != null && todoId.isNotEmpty)
        MaterialPageRoute<void>(
          builder: (_) => TodoDetailsPage(todoId: todoId),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Read here, in build — reading an InheritedWidget inside a provider's
    // `create` callback throws ("listen in a life-cycle never called again").
    final String languageCode = Localizations.localeOf(context).languageCode;
    final bool canView = GetIt.instance<TodoAccess>().canView;
    // No navigator is built without View, so drop the hint here instead.
    if (!canView) pendingTodoId = null;
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<TodoListCubit>(
          create: (_) =>
              GetIt.instance<TodoListCubit>()..init(languageCode: languageCode),
        ),
        BlocProvider<TodoActionsCubit>(
          // Quick actions (done checkbox, checklist ticks) show at once via
          // the list's local overrides; a failed write reverts them.
          create: (BuildContext ctx) {
            final TodoListCubit list = ctx.read<TodoListCubit>();
            return GetIt.instance<TodoActionsCubit>()
              ..bindOptimistic(
                apply: list.applyLocal,
                revert: list.revertLocal,
              );
          },
        ),
      ],
      child: !canView
          ? const _TodoNoAccess()
          : NoScrollbar(
              child: Navigator(
                onGenerateInitialRoutes: (_, __) => _initialRoutes(),
                onGenerateRoute: (RouteSettings settings) =>
                    MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => const TodoListPage(),
                ),
              ),
            ),
    );
  }
}

/// Shown instead of the list when the role lacks `View_To_Do`.
class _TodoNoAccess extends StatelessWidget {
  const _TodoNoAccess();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 24.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CustomEmptyState(),
              SizedBox(height: 12.sp),
              Text(
                S.of(context).todoNoAccess,
                textAlign: TextAlign.center,
                style: StyleText.fontSize14Weight500
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
