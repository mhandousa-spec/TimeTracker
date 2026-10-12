// ******************* FILE INFO *******************
// File Name: responsive_services
// Description: Responsive services. Module composition root — owns the
//              BlocProvider<ServicesManagerCubit> that every screen under
//              the services module resolves via ServicesManagerCubit.get().
// Module: services_management_module / presentation / s1_home_page_services / ui / services_management_module
// *************************************************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/features/services_management_module/s1_home_page_services/presentation/ui/pages/home_page_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/service_repository_impl.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/controller/services_manager_cubit.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
// ADDED 12/9/2026 — the notification deep-link landing. See [pendingSection].
import 'package:knowticed_plus/core/custom/37-custom_navigate.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';
import 'package:knowticed_plus/features/services_management_module/s6_services_requests/presentation/ui/pages/request_services_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s7_approvals/presentation/ui/pages/approval_request_toggle.dart';
import 'package:knowticed_plus/features/services_management_module/s10_services_provider/presentation/ui/pages/employee_services_toggle.dart';

// REMOVED 8/9/2026: the ResponsiveHelper import went with the split branches —
// mobile and tablet now build the same tree. See build().

class ServicesResponsivePage extends StatelessWidget {
  const ServicesResponsivePage({super.key});

  /// The screen to open on top of the services home, left here by the
  /// notification inbox before it selects this module in the drawer.
  ///
  /// ADDED 12/9/2026 with the deep-link router. Requests, Approvals and the
  /// provider dashboard are not tabs — they are `navigateTo(context, X())`
  /// pushes from the home screen's buttons — so a deep link is a push
  /// scheduled after the home page's first frame, which also leaves the reader
  /// a back button to the module.
  ///
  /// Same shape as `RoleScreenHost.pendingInitialTab`.
  ///
  /// ⚠️ Read-and-cleared on the first build, used or not: a hint left armed
  /// would hijack the next unrelated visit to Services.
  static NotificationServicesSection? pendingSection;

  /// Function Name: [_consumeDeepLink]
  ///
  /// Purpose: Open the screen a notification pointed at, once the home page
  /// exists.
  ///
  /// [context] MUST be the one from the route builder below — it is the only
  /// one under this module's Navigator, and the whole point of that Navigator
  /// (see the fix note in [build]) is that pushes stay inside the module and
  /// keep the provider above them.
  ///
  /// Read-and-clear happens synchronously, before the post-frame callback: a
  /// route builder can run again on rebuild, and taking the value out up front
  /// is what stops a second push.
  static void _consumeDeepLink(BuildContext context) {
    final NotificationServicesSection? section = pendingSection;
    pendingSection = null;
    if (section == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      // All three are const, no-argument widgets — the same ones
      // `request_services_button.dart` and `management_widget.dart` push.
      navigateTo(
        context,
        switch (section) {
          NotificationServicesSection.requests =>
            const RequestServicesToggle(),
          NotificationServicesSection.approvals => const ApprovalToggle(),
          // ⚠️ The stored page key is `ServiceProviderDashboard`, which is not
          // a class in this codebase; the provider's screen is this one.
          NotificationServicesSection.providerDashboard =>
            const EmployeeLayoutScreenServices(),
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TEMP DIAGNOSTIC — proves this build of the file is the one running.
    print('PERMDIAG >>> ServicesResponsivePage.build reached');

    // The provider sits above the module's Navigator, so every route pushed
    // inside the module inherits it.
    //
    // FIXED 8/9/2026 — "Could not find the correct Provider<ServicesManagerCubit>".
    //
    // The mobile branch used to be a bare `LayoutScreenServices()` with NO
    // Navigator of its own; only tablet got one. `navigateTo` is
    // `Navigator.push(context, ...)`, which finds the NEAREST navigator:
    //
    //   • tablet — the nearest one was this module's own, created BELOW the
    //     provider, so a pushed page could still resolve
    //     `ServicesManagerCubit.get(context)`;
    //   • mobile — there was none here, so the nearest was the one OUTSIDE
    //     this widget (the bottom-bar tab's). Every page pushed inside the
    //     module therefore landed ABOVE the provider and threw the moment it
    //     built a BlocListener or BlocBuilder for ServicesManagerCubit.
    //
    // RequestServicesPage was just the first one anybody opened; every other
    // pushed screen in this module had the same fault, so fixing it here fixes
    // them all rather than patching one call site at a time.
    //
    // ResponsiveHelper is gone with it: both of its branches now build the
    // identical tree, so it had nothing left to choose between. Dropping it
    // also means the Navigator survives a phone/tablet size change instead of
    // the subtree being swapped out underneath it.
    return BlocProvider<ServicesManagerCubit>(
      create: (_) => ServicesManagerCubit(
        GetServiceRepositoryImpl(firestore: FirebaseFirestore.instance),
        employeeEntity: Get.isRegistered<MainCoreEmployeeController>()
            ? AppControllers.employee.employeeEntity
            : null,
      ),
      child: Navigator(
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute<void>(
            builder: (BuildContext context) {
              _consumeDeepLink(context);
              return const LayoutScreenServices();
            },
          );
        },
      ),
    );
  }
}
