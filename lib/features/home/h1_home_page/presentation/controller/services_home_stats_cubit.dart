/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: services_home_stats_cubit.dart
/// Purpose: Declares `ServicesHomeStatsCubit` — the live figures behind the
///          Services cards on the home page and in the Adding Widget picker.
/// Author: Knowticed Plus team
/// Created at: 30/8/2026
///
/// WHY THIS EXISTS
/// ---------------
/// The seven Services cards shipped with the placeholder numbers their Figma
/// frames drew — 32 / 12 / 08, six bars all reading 84, four tiles all reading
/// 10, "Total 100". `home_service_widgets.dart` said so in its own header:
/// "Wiring them to the services cubits is a separate piece of work". This is
/// that work.
///
/// It could not simply read the services cubits, for the same reason
/// [RolesHomeStatsCubit] could not read the roles ones: `ServicesManagerCubit`
/// is provided by `responsive_services.dart`, the services module's own
/// composition root, and `DashboardMasterCubit` is built and disposed by one
/// page. A home widget has neither in scope, so `context.read` for either
/// throws there. This reads the same repository they read and keeps only the
/// numbers.
///
/// Modelled on [RolesHomeStatsCubit] deliberately — same lazy `ensureLoaded`
/// contract, same "one failed source blanks one card, not all of them" rule,
/// same counts-live-on-the-cubit shape. Two of these cubits with one shape is
/// a pattern; two with two shapes is a mess.
///
/// KEEPING THE BUCKETS HONEST
/// -------------------------
/// The status bucketing is [_finalStateOf], a copy of the rule
/// `DashboardMasterCubit.loadServiceStatusData` and
/// `ServicesDashboardCubit._getFinalStateFromModel` both apply: the request's
/// own state when it names one, otherwise a verdict derived from its approval
/// cycle. A card and the dashboard it links to must not be able to disagree
/// about how many requests are "pending".
///
/// It is copied rather than imported because both existing homes for it are
/// private to a cubit that a home widget cannot reach. If it is ever lifted
/// into the services module as shared code, delete this copy and import that.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:knowticed_plus/features/home/h1_home_page/presentation/controller/services_home_stats_state.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/model_employee.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/models/services_history_model.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/data/repository/service_repository_impl.dart';
import 'package:knowticed_plus/features/services_management_module/main_controller/domain/base_repository/service_repository.dart';

/// The status buckets every Services card counts in.
///
/// The literals are the ones the request documents actually carry, lower-cased
/// and space-stripped — `branchsla`, not "Breached SLA". Same keys
/// `DashboardMasterCubit` builds its `statusCounts` map with.
abstract class ServiceStatusKey {
  static const String done = 'done';
  static const String approved = 'approved';
  static const String pending = 'pending';
  static const String inProgress = 'inprogress';
  static const String breachedSla = 'branchsla';
  static const String rejected = 'rejected';
  static const String cancel = 'cancel';

  /// Every bucket, in no particular order — used to zero the maps.
  static const List<String> all = <String>[
    done,
    approved,
    pending,
    inProgress,
    breachedSla,
    rejected,
    cancel,
  ];
}

/// One request, reduced to what a card row shows.
///
/// The cards render a name and a department, nothing else, so the whole
/// `ServicesHistoryModel` does not travel up here.
class ServiceRequestSummary {
  final String nameEnglish;
  final String nameArabic;
  final String departmentEnglish;
  final String departmentArabic;

  const ServiceRequestSummary({
    required this.nameEnglish,
    required this.nameArabic,
    required this.departmentEnglish,
    required this.departmentArabic,
  });

  /// The name in the reader's language, falling back to the other one rather
  /// than to an empty row — a request with only an English name is still a
  /// request an Arabic reader needs to see.
  String name(bool isArabic) {
    final String preferred = isArabic ? nameArabic : nameEnglish;
    if (preferred.trim().isNotEmpty) return preferred;
    return isArabic ? nameEnglish : nameArabic;
  }

  /// As [name], for the department line.
  String department(bool isArabic) {
    final String preferred = isArabic ? departmentArabic : departmentEnglish;
    if (preferred.trim().isNotEmpty) return preferred;
    return isArabic ? departmentEnglish : departmentArabic;
  }
}

class ServicesHomeStatsCubit extends Cubit<ServicesHomeStatsState> {
  ServicesHomeStatsCubit({CreateServicesRepository? repository})
      : _repository = repository ??
            GetServiceRepositoryImpl(firestore: FirebaseFirestore.instance),
        super(ServicesHomeStatsInitial());

  final CreateServicesRepository _repository;

  /// How many rows the two list cards show. Both Figma frames draw two.
  static const int _kRequestRowCount = 2;

  // ── Figures ───────────────────────────────────────────────────────────────
  // Every map is fully populated with zeros before a load runs, so a card can
  // read a bucket without a null check even if that source failed.

  /// Every service REQUEST by status — the Services Status card, and the
  /// Approved / Pending / Rejected tiles.
  Map<String, int> statusCounts = _zeroed();

  /// The signed-in user's OWN requests by status — the My Request card.
  ///
  /// Separate from [statusCounts] on purpose: that one is the whole queue (what
  /// the dashboard shows), this one is "mine". A card titled "My Request" that
  /// showed the company's totals would be lying in its title.
  Map<String, int> myRequestCounts = _zeroed();

  /// Services defined in the catalogue — the Total Services tile. Not requests.
  int totalServices = 0;

  /// Requests raised against them — the Total Requests tile.
  int totalRequests = 0;

  /// The signed-in user's own request total — the My Request card's header.
  int myRequestTotal = 0;

  /// The most recent requests, newest first — the Requested Service card.
  List<ServiceRequestSummary> recentRequests = <ServiceRequestSummary>[];

  /// Requests that have breached their SLA, newest first — the Near Breached
  /// SLA card's rows.
  ///
  /// ⚠️ NAME vs CONTENT: the card says "near breached", these are requests
  /// already IN the `branchsla` bucket. There is no "approaching its SLA"
  /// signal on a request document — the state flips to breached or it does
  /// not — so this is the closest honest reading of the existing data. If a
  /// threshold ("within 20% of the SLA") is wanted, that is a new computation
  /// over the SLA fields and a change of source, not a filter change here.
  List<ServiceRequestSummary> breachedRequests = <ServiceRequestSummary>[];

  /// Share of all requests that have breached SLA, 0..1 — the percentage in
  /// the Near Breached SLA card's header.
  double get breachedSlaRatio {
    if (totalRequests <= 0) return 0;
    return (statusCounts[ServiceStatusKey.breachedSla] ?? 0) / totalRequests;
  }

  /// The largest bucket, used to scale the Services Status bars.
  ///
  /// Fractions are relative to the BIGGEST bucket, not to the total: with six
  /// statuses sharing one queue, dividing by the total leaves every bar a stub
  /// and the card unreadable. Scaling to the largest makes the tallest bar full
  /// and the rest honest against it. Never zero, so the division is safe.
  int get statusPeak {
    int peak = 0;
    for (final int value in statusCounts.values) {
      if (value > peak) peak = value;
    }
    return peak == 0 ? 1 : peak;
  }

  static Map<String, int> _zeroed() =>
      <String, int>{for (final String key in ServiceStatusKey.all) key: 0};

  /// Guards against a second load while one is already in flight — every card
  /// calls [ensureLoaded] from its first build.
  bool _loading = false;

  /// True once a load has finished, however it went.
  bool _loadedOnce = false;

  void emitSafely(ServicesHomeStatsState state) {
    if (isClosed) return;
    emit(state);
  }

  /// Function Name: [ensureLoaded]
  ///
  /// Purpose: Load once, no matter how many Services cards are on screen.
  ///
  /// Each card calls this from `build`, which runs on every rebuild — so this
  /// has to be idempotent, not merely cheap.
  ///
  /// The fetch is deferred to after the frame, and `_loading` is claimed
  /// synchronously so the other cards building in the same frame do not each
  /// queue one. Calling [load] directly would `emit` during the build phase and
  /// mark the BlocBuilder above dirty while it is being built — the
  /// "setState() called during build" assertion.
  void ensureLoaded() {
    if (_loading || _loadedOnce) return;
    _loading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed) return;
      // load() re-checks the flag; release it first so it is not a no-op.
      _loading = false;
      load();
    });
  }

  /// Function Name: [load]
  ///
  /// Purpose: Refresh every figure. Safe to call again to re-read.
  ///
  /// The three sources are independent and read concurrently. A source that
  /// fails leaves its own figures at zero and does NOT take the others with it:
  /// one broken read should blank one card, not all seven. Only a total failure
  /// emits [ServicesHomeStatsError].
  ///
  /// Returns: [Future<void>]
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    emitSafely(ServicesHomeStatsLoading());

    final List<bool> results = await Future.wait(<Future<bool>>[
      _loadRequestFigures(),
      _loadCatalogueTotal(),
      _loadMyRequestFigures(),
    ]);

    _loading = false;
    _loadedOnce = true;

    if (results.every((bool ok) => !ok)) {
      emitSafely(
          ServicesHomeStatsError('Services home stats could not be loaded'));
      return;
    }
    emitSafely(ServicesHomeStatsLoaded());
  }

  /// The request queue: status counts, the total, and the two row lists.
  ///
  /// One read serves all of them — `getAllRequestServiceDocs` is the same call
  /// `DashboardMasterCubit` makes, and splitting this into four reads would put
  /// four passes over the same collection behind one screen.
  ///
  /// Whole-collection scope, matching the services dashboard: these cards
  /// describe the queue, not the reader's own slice of it. The one card that
  /// IS personal, My Request, has its own source below.
  Future<bool> _loadRequestFigures() async {
    return _guard('service requests', () async {
      final List<MapEntry<String, Map<String, dynamic>>> docs =
          await _repository.getAllRequestServiceDocs();

      final Map<String, int> counts = _zeroed();
      final List<ServiceRequestSummary> recent = <ServiceRequestSummary>[];
      final List<ServiceRequestSummary> breached = <ServiceRequestSummary>[];

      for (final MapEntry<String, Map<String, dynamic>> doc in docs) {
        final ServicesHistoryModel model =
            ServicesHistoryModel.fromJson(doc.value, doc.key);
        final String key = _finalStateOf(model);
        if (counts.containsKey(key)) counts[key] = counts[key]! + 1;

        // The lists are capped as they are filled rather than built whole and
        // sublisted — a company with thousands of requests should not
        // materialise thousands of summaries to show two.
        if (recent.length < _kRequestRowCount) {
          recent.add(_summaryOf(model));
        }
        if (key == ServiceStatusKey.breachedSla &&
            breached.length < _kRequestRowCount) {
          breached.add(_summaryOf(model));
        }
      }

      statusCounts = counts;
      totalRequests = docs.length;
      recentRequests = recent;
      breachedRequests = breached;
      return true;
    });
  }

  /// The service catalogue — how many services exist to be requested.
  Future<bool> _loadCatalogueTotal() async {
    return _guard('services catalogue', () async {
      final List<ServicesHistoryModel> services =
          await _repository.getAllServices();
      totalServices = services.length;
      return true;
    });
  }

  /// The signed-in user's own requests.
  ///
  /// `getMyRequestServices` is the same read the My Requests screen makes, so
  /// the card and that screen count the same set.
  Future<bool> _loadMyRequestFigures() async {
    return _guard('my requests', () async {
      final List<ServicesHistoryModel> mine =
          await _repository.getMyRequestServices();

      final Map<String, int> counts = _zeroed();
      for (final ServicesHistoryModel model in mine) {
        final String key = _finalStateOf(model);
        if (counts.containsKey(key)) counts[key] = counts[key]! + 1;
      }

      myRequestCounts = counts;
      myRequestTotal = mine.length;
      return true;
    });
  }

  ServiceRequestSummary _summaryOf(ServicesHistoryModel model) {
    return ServiceRequestSummary(
      nameEnglish: model.currentServiceNameEnglish,
      nameArabic: model.currentServiceNameArabic,
      departmentEnglish: model.currentDepartmentRequester,
      departmentArabic: model.currentDepartmentRequesterArabic,
    );
  }

  /// Which bucket a request belongs in.
  ///
  /// See this file's header: a verbatim copy of the rule the two services
  /// dashboards apply. The request's own state wins when it names a known one;
  /// otherwise the approval cycle decides, and the ORDER of those checks is the
  /// rule — one cancellation or one rejection settles the whole request, while
  /// "approved" requires every approver to have said so.
  String _finalStateOf(ServicesHistoryModel service) {
    final String outerState = service.currentState.toLowerCase().trim();
    const List<String> knownStates = <String>[
      'done',
      'inprogress',
      'branchsla',
      'breached sla',
      'cancel',
      'canceled',
      'pending',
      'approved',
      'rejected',
    ];

    if (knownStates.contains(outerState)) {
      return _normalise(outerState);
    }

    final List<String> states = <String>[];
    for (final EmployeeEntityModell approval in service.currentApprovalCycle) {
      final String state = (approval.state ?? '').toLowerCase();
      if (state.isNotEmpty) states.add(state);
    }

    if (states.isEmpty) return ServiceStatusKey.pending;
    if (states.contains('cancel') || states.contains('canceled')) {
      return ServiceStatusKey.cancel;
    }
    if (states.contains('rejected')) return ServiceStatusKey.rejected;
    if (states.contains('pending')) return ServiceStatusKey.pending;
    if (states.contains('inprogress')) return ServiceStatusKey.inProgress;
    if (states.every((String s) => s == 'approved')) {
      return ServiceStatusKey.approved;
    }

    return ServiceStatusKey.pending;
  }

  /// Folds the spelling variants onto one bucket key.
  ///
  /// `canceled`/`cancel` and `breached sla`/`branchsla` are the same status
  /// written two ways in the data. The dashboards handle this with a
  /// `replaceAll(' ', '')` that silently maps "breached sla" to "breachedsla" —
  /// a key none of their count maps hold, so those documents are dropped from
  /// the totals. Mapping them explicitly here keeps them counted.
  String _normalise(String state) {
    switch (state) {
      case 'canceled':
        return ServiceStatusKey.cancel;
      case 'breached sla':
        return ServiceStatusKey.breachedSla;
      default:
        return state;
    }
  }

  /// Runs [read] and turns any throw into `false` rather than letting it take
  /// down the whole `Future.wait`.
  Future<bool> _guard(String label, Future<bool> Function() read) async {
    try {
      return await read();
    } catch (e, stackTrace) {
      debugPrint('ServicesHomeStatsCubit: $label failed: $e\n$stackTrace');
      return false;
    }
  }
}
