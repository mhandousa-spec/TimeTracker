// ****************** FILE INFO ******************
// File Name: crm_screen_host.dart
// Purpose: Host widget with nested Navigator to keep side drawer fixed when navigating within CRM.
// Author: Mohand Adel
// Created At: 03/08/2026

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/helper/crm_helper/routing/crm_routes/crm_router.dart';
import 'package:knowticed_plus/core/helper/crm_helper/routing/crm_routes/crm_routes.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_client_types_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_template_builder_cubit.dart';
import 'package:knowticed_plus/features/crm/crm2_controls/presentation/controller/crm_templates_cubit.dart';

import 'package:knowticed_plus/features/crm/crm_di.dart';

// ---------------------------------------------------------------------------
// NOTE: crmNavigatorKey is intentionally left as a nullable global so that
// CrmNavigationHelper can access it.  The real key lives in State to ensure
// a fresh key is created for each CrmScreenHost instance, preventing the
// "descendant not found" / "_dependents.isEmpty" GlobalKey reuse crashes.
// ---------------------------------------------------------------------------
GlobalKey<NavigatorState>? crmNavigatorKey;

/// CrmScreenHost wraps CRM in a nested Navigator so that sub-page pushes
/// render inside the app shell while keeping the side drawer and header fixed.
class CrmScreenHost extends StatefulWidget {
  const CrmScreenHost({super.key});

  @override
  State<CrmScreenHost> createState() => _CrmScreenHostState();
}

class _CrmScreenHostState extends State<CrmScreenHost> {
  /// Fresh key per widget instance — never reused across Navigator lifetimes.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    crmNavigatorKey = _navigatorKey;
    // Register CRM repositories before any Cubit below (or any route in the
    // nested navigator) resolves them through GetX.
    registerCrmDependencies();
  }

  @override
  void dispose() {
    // Clear the global reference so callers don't hold a stale key.
    if (crmNavigatorKey == _navigatorKey) crmNavigatorKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CrmClientTypesCubit>(
          create: (_) => CrmClientTypesCubit(),
        ),
        BlocProvider<CrmTemplatesCubit>(
          create: (_) => CrmTemplatesCubit(),
        ),
        BlocProvider<CrmTemplateBuilderCubit>(
          create: (_) => CrmTemplateBuilderCubit(),
        ),
      ],
      child: Navigator(
        key: _navigatorKey,
        initialRoute: CrmRoutes.dashboard,
        onGenerateRoute: CrmRouter.onGenerateRoute,
      ),
    );
  }
}
