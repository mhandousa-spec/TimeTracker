/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: settings_home_widgets.dart
/// Purpose: The two Settings-module cards on the Adding Widget picker —
///          `CommentsAndFeedbacksWidget` and `MySettingsRequestsWidget`.
/// Author: Knowticed Plus team
/// Created at: 25/8/2026
///
/// Built against Figma file BuJXLizpGcK5eHVBqQomXc, Settings > Home Layout >
/// Adding Widget (node 7488:7483). The Settings row sits at y=2229 and holds
/// exactly these two cards:
///
///   • Comments and Feedbacks — node 7488:10588 — Open / Fixed / Closed
///   • My Requests           — node 7488:10489 — Approved / Pending / Rejected
///
/// Both are the standard 265x120 white card with an 8pt radius and a three-tile
/// body, so both are assembled from `HomeWidgetCard` + `HomeStatTileRow` rather
/// than laying anything out by hand — the same shell every other picker card
/// uses, and the reason these two match `MyServices` pixel for pixel.
///
/// ─── THESE TWO READ REAL DATA ────────────────────────────────────────
/// Every other card in this picker previews itself with the placeholder
/// figures lifted from the Figma frames (see the header of
/// `home_service_widgets.dart`). These two do not: they were asked for wired to
/// their sources, so they count live records.
///
///   • Comments and Feedbacks → `FeedbackRepository.countsByStatus`, the read
///     added on 25/8/2026 for this card. The feature had no read path at all
///     before it — `comments_and_feedback_screen.dart` calls `submit` and
///     `uploadAttachment` and nothing else.
///   • My Requests → `RequestsRepository.getRequestsForEmployee`, the same
///     source `request_page.dart` lists from, folded to counts per
///     `RequestStatus`.
///
/// ⚠️ Fixed and Closed will read 0 until something can set them. `submit`
/// writes `status: 'new'`, which `FeedbackStatus.fromWire` folds into `open`,
/// and no triage screen exists to move a submission on. The zero is the honest
/// number, not a bug in this card.
///
/// ─── WHY A FUTUREBUILDER AND NOT A CUBIT ─────────────────────────────
/// A picker card is a self-contained preview that can also be dropped onto the
/// home grid, and it has no lifecycle of its own to hang a cubit off. Both
/// futures are created once in `initState` — never in `build`, which would
/// refire the query on every rebuild — and both degrade to zeros rather than an
/// error state, because a card that cannot reach Firestore should still show
/// its shape.
library;

import 'package:flutter/material.dart';

import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/home_component_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/presentation/ui/home_widgets/home_widget_shell.dart';
import 'package:knowticed_plus/features/settings/se6_requests/data/repository/requests_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/base_repository/requests_base_repository.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/enums/request_status.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/repository/feedback_repository.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/base_repository/feedback_base_repository.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/domain/entities/app_feedback.dart';
import 'package:knowticed_plus/generated/l10n.dart';

/// The signed-in employee's id, or empty when the directory has not loaded.
///
/// Both cards filter on the id rather than the email: the id is exact, while
/// the email is stored in whatever case the employee record carries and every
/// Firestore equality filter is case-sensitive.
String _currentEmployeeId() {
  try {
    return AppControllers.employee.employeeEntity?.id ?? '';
  } catch (_) {
    // The controller is not registered yet — a card built during startup shows
    // zeros rather than throwing out of `initState`.
    return '';
  }
}

/// Figma 7488:10588 — "Comments and Feedbacks", Open / Fixed / Closed.
class CommentsAndFeedbacksWidget extends StatefulWidget {
  /// Carried for parity with every other component widget; the card renders the
  /// same regardless of where it sits.
  final HomeComponentModel model;

  const CommentsAndFeedbacksWidget({super.key, required this.model});

  @override
  State<CommentsAndFeedbacksWidget> createState() =>
      _CommentsAndFeedbacksWidgetState();
}

class _CommentsAndFeedbacksWidgetState
    extends State<CommentsAndFeedbacksWidget> {
  final FeedbackBaseRepository _repository = FeedbackRepository();

  /// Created once. Building the future inside `build` would re-query Firestore
  /// on every rebuild, and this card rebuilds whenever the picker's filter
  /// changes.
  late final Future<Map<FeedbackStatus, int>> _counts = _load();

  Future<Map<FeedbackStatus, int>> _load() async {
    final String employeeId = _currentEmployeeId();
    if (employeeId.isEmpty) return _zeros;

    final result = await _repository.countsByStatus(employeeId);
    return result.fold(
      (_) => _zeros,
      (Map<FeedbackStatus, int> counts) => counts,
    );
  }

  static Map<FeedbackStatus, int> get _zeros => <FeedbackStatus, int>{
        for (final FeedbackStatus s in FeedbackStatus.values) s: 0,
      };

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return FutureBuilder<Map<FeedbackStatus, int>>(
      future: _counts,
      builder: (BuildContext context,
          AsyncSnapshot<Map<FeedbackStatus, int>> snapshot) {
        final Map<FeedbackStatus, int> counts = snapshot.data ?? _zeros;

        return HomeWidgetCard(
          title: l.commentsAndFeedbacks,
          icon: "assets/icons_assets/roles_assets/settings_gear.svg",
          // ADDED 28/8/2026. Neither card passed a width, so both fell back to
          // HomeWidgetCard's default (kHomeWidgetWidth, 320) and came out wider
          // than the three-stat cards beside them. Three tiles, so this takes
          // the compact width — the same one Role Management uses. The stat
          // cards carry only two widths: this for three stats,
          // kHomeWidgetWideWidth for four.
          width: kHomeWidgetCompactWidth,
          child: HomeStatTileRow(
            tiles: <HomeStatTile>[
              HomeStatTile(
                icon: HomeWidgetSvg.open,
                label: l.open,
                value: _format(counts[FeedbackStatus.open]),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.fixed,
                label: l.fixed,
                value: _format(counts[FeedbackStatus.fixed]),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.closed,
                // l10n has no `closed` key and one cannot be added without
                // regenerating from the ARB, so the card reuses `completed` —
                // already translated, and the nearest thing the catalogue has
                // to Figma's "Closed".
                label: l.completed,
                value: _format(counts[FeedbackStatus.closed]),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma 7488:10489 — "My Requests", Approved / Pending / Rejected.
///
/// Named `MySettingsRequests…` because `MyRequestServices` and
/// `MyRequestInventory` already exist for the services and inventory modules;
/// this is the settings change-request one.
class MySettingsRequestsWidget extends StatefulWidget {
  final HomeComponentModel model;

  const MySettingsRequestsWidget({super.key, required this.model});

  @override
  State<MySettingsRequestsWidget> createState() =>
      _MySettingsRequestsWidgetState();
}

class _MySettingsRequestsWidgetState extends State<MySettingsRequestsWidget> {
  final RequestsBaseRepository _repository = RequestsRepository();

  late final Future<Map<RequestStatus, int>> _counts = _load();

  Future<Map<RequestStatus, int>> _load() async {
    final String employeeId = _currentEmployeeId();
    if (employeeId.isEmpty) return _zeros;

    final result = await _repository.getRequestsForEmployee(employeeId);
    return result.fold(
      (_) => _zeros,
      (List<ChangeRequest> requests) {
        final Map<RequestStatus, int> counts = _zeros;
        for (final ChangeRequest request in requests) {
          counts[request.status] = (counts[request.status] ?? 0) + 1;
        }
        return counts;
      },
    );
  }

  static Map<RequestStatus, int> get _zeros => <RequestStatus, int>{
        for (final RequestStatus s in RequestStatus.values) s: 0,
      };

  @override
  Widget build(BuildContext context) {
    final S l = S.of(context);

    return FutureBuilder<Map<RequestStatus, int>>(
      future: _counts,
      builder: (BuildContext context,
          AsyncSnapshot<Map<RequestStatus, int>> snapshot) {
        final Map<RequestStatus, int> counts = snapshot.data ?? _zeros;

        return HomeWidgetCard(
          title: l.myRequests,
          icon: "assets/icons_assets/roles_assets/settings_gear.svg",
          // Three tiles — the compact width, as above.
          width: kHomeWidgetCompactWidth,
          child: HomeStatTileRow(
            tiles: <HomeStatTile>[
              HomeStatTile(
                icon: HomeWidgetSvg.approved,
                label: l.approved,
                value: _format(counts[RequestStatus.approved]),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.pending,
                label: l.pending,
                value: _format(counts[RequestStatus.pending]),
              ),
              HomeStatTile(
                icon: HomeWidgetSvg.rejected,
                label: l.rejected,
                value: _format(counts[RequestStatus.rejected]),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Figma pads single digits — the cards read `08`, not `8`. Anything already
/// two digits or more is left alone.
String _format(int? value) {
  final int count = value ?? 0;
  return count < 10 ? '0$count' : '$count';
}
