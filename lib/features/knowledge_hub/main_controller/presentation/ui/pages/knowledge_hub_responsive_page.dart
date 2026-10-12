/// Module: knowledge_hub_module / presentation/ui/pages/knowledge_hub_responsive_page.dart
///
///*************************** FILE INFO ****************************///
/// File Name: knowledge_hub_responsive_page.dart
/// Purpose: Module entry point — provides every Knowledge Hub cubit and picks
///          the mobile / tablet layout.
/// Author: Knowticed Plus team
/// Updated: 1/9/2026 — became stateful so the module can run its time-driven
///          notification sweep once per session on entry. See below.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/custom/38-custom_responsive.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import '../../../data/notifications/knowledge_hub_notification_scheduler.dart';
import '../../../data/services/approvals_firebase_services.dart';
import '../../../data/services/create_comment_firebase_service.dart';
import '../../../data/services/dashboard_firebase_services.dart';
import '../../../data/services/knowledge_hub_firebase_services.dart';
import '../../../data/services/submissions_firebase_service.dart';
import '../../../../k5_submission_details/presentation/controller/analytics_cubit.dart';
import '../../../../k6_approvals/presentation/controller/approvals_cubit.dart';
import '../../../../k3_view_knowledge_details/presentation/controller/create_comment_cubit.dart';
import '../../../../k1_create_new_knowledge/presentation/controller/create_knowledge_cubit.dart';
import '../../../../k8_dashboard/presentation/controller/dashboard_cubit.dart';
import '../../../../k4_submissions/presentation/controller/submissions_cubit.dart';
import '../../../../k2_view_knowledge_hub/presentation/ui/pages/view_knowledge_hub.dart';
// ADDED 12/9/2026 — the notification deep-link landing. See [pendingSection].
import '../../../../k4_submissions/presentation/ui/pages/submissions_screen.dart';
import '../../../../k6_approvals/presentation/ui/pages/approvals_screen.dart';
import 'package:knowticed_plus/features/notification/domain/routing/notification_deep_link.dart';

/// ─── WHY THIS IS STATEFUL ────────────────────────────────────────────────
///
/// Three of the notifications in §1.1 of "Knowticed Plus — Notification &
/// Validation" are due because of the CLOCK, not because of a user action:
/// the 14-day expiry warning, the archival notice, and the pending-review
/// reminder. This app has no server-side scheduler, so nothing was raising
/// them — the templates existed in Notification Control and no code could
/// ever send them.
///
/// Opening the module is the natural hook: it is the moment Knowledge Hub
/// data is being loaded anyway, so one extra collection read costs little,
/// and it guarantees the sweep runs on a device that is online with a
/// logged-in user. [KnowledgeHubNotificationScheduler] guards itself against
/// running twice in a session and writes a per-document marker so ten people
/// opening the module do not send the same warning ten times.
///
/// It is fire-and-forget: the sweep must never delay the first frame, and a
/// failure is silent to the user — the next module open retries.
class KnowledgeHubPage extends StatefulWidget {
  const KnowledgeHubPage({super.key});

  /// The screen to open on top of the module landing, left here by the
  /// notification inbox before it selects this module in the drawer.
  ///
  /// ADDED 12/9/2026 with the deep-link router. Submissions and Approvals are
  /// not tabs of the landing page — they are separate screens pushed from the
  /// two buttons on `ViewKnowledgeHub`, each with its own `BlocProvider`. So a
  /// deep link cannot be expressed as an index; it is a push scheduled for
  /// after the landing page's first frame, which also gives the reader a back
  /// button to the module rather than stranding them.
  ///
  /// Same shape as `RoleScreenHost.pendingInitialTab`.
  ///
  /// ⚠️ Read-and-cleared on the first build, used or not.
  static NotificationKnowledgeHubSection? pendingSection;

  @override
  State<KnowledgeHubPage> createState() => _KnowledgeHubPageState();
}

class _KnowledgeHubPageState extends State<KnowledgeHubPage> {
  @override
  void initState() {
    super.initState();
    _runNotificationSweep();
  }

  /// Raise anything that fell due since the last time somebody opened the
  /// module. Deliberately not awaited.
  void _runNotificationSweep() {
    String actingUserEmail = '';
    if (Get.isRegistered<MainCoreEmployeeController>()) {
      actingUserEmail =
          Get.find<MainCoreEmployeeController>().employeeEntity?.email ?? '';
    }

    KnowledgeHubNotificationScheduler.sweep(
      actingUserEmail: actingUserEmail,
      isArabic: Get.locale?.languageCode == 'ar',
    );
  }

  /// Function Name: [_consumeDeepLink]
  ///
  /// Purpose: Open the screen a notification pointed at, once the landing page
  /// has been laid out.
  ///
  /// Read-and-clear FIRST, synchronously: this runs from a widget builder,
  /// which can be re-invoked on any rebuild, and taking the value out up front
  /// is what stops a second push. Deliberately post-frame — pushing during
  /// build is a Flutter error, and the landing page has to exist before
  /// something is stacked on it.
  void _consumeDeepLink(BuildContext context) {
    final NotificationKnowledgeHubSection? section =
        KnowledgeHubPage.pendingSection;
    KnowledgeHubPage.pendingSection = null;
    if (section == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Each screen owns its cubit, exactly as `submissions_button.dart` and
      // `approvals_button.dart` build them. Do NOT route to them bare: both
      // read a cubit that the module root does not hand down through a push.
      final Widget target = switch (section) {
        NotificationKnowledgeHubSection.submissions => BlocProvider(
            create: (_) => SubmissionsCubit(SubmissionsFirebaseServices()),
            child: SubmissionsScreen(),
          ),
        NotificationKnowledgeHubSection.approvals => BlocProvider(
            create: (_) => ApprovalsCubit(ApprovalsFirebaseServices()),
            child: ApprovalsScreen(),
          ),
      };

      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => target),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CreateKnowledgeCubit(
            KnowledgeHubFirebaseServices(),
          ),
        ),
        BlocProvider(
          create: (context) => SubmissionsCubit(
            SubmissionsFirebaseServices(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              DashboardCubit(DashboardFirebaseServices()),
        ),
        BlocProvider(
          create: (context) =>
              ApprovalsCubit(ApprovalsFirebaseServices()),
        ),
        BlocProvider(
          create: (context) =>
              AnalyticsCubit(CommentsFirebaseServices()),
        ),
        BlocProvider(
          create: (context) =>
              CommentsCubit(CommentsFirebaseServices()),
        ),
      ],
      child: ResponsiveHelper(
        //  Solve
        //
        // The Builder / route builder are what give `_consumeDeepLink` a
        // context BELOW the MultiBlocProvider above and — on tablet — below
        // this module's own Navigator, so the pushed screen lands inside the
        // module instead of over the whole shell.
          mobileWidget: Builder(builder: (BuildContext context) {
            _consumeDeepLink(context);
            return ViewKnowledgeHub();
          }),
          tabletWidget:  Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) {
                  _consumeDeepLink(context);
                  return  ViewKnowledgeHub();
                },
              );
            },

          )),
    );
  }
}
