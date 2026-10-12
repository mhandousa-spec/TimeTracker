/// Module: time_tracker / data / repository
///
///*************************** FILE INFO ****************************///
/// File Name: work_setup_source_resolver.dart
/// Purpose: Declares `WorkSetupSourceResolver` — picks the `WorkSetupSource`
///          (HR-owned or Time Tracker-owned) from the company's licence.
/// Author: Knowticed Plus team
/// Created at: 8/10/2026
///
/// Owner decision 7 (8/10/2026): HR licensed → HR owns locations / shift
/// hours / assignments; otherwise Time Tracker does. Screens ask this class
/// once and then only talk to the `WorkSetupSource` interface.
/// Updated: 9/10/2026 - code review finding 1: [companyWorkingWeek].

import 'package:firebase_core/firebase_core.dart';

import 'package:knowticed_plus/features/time_tracker/data/services/company_modules_service.dart';
import 'package:knowticed_plus/features/time_tracker/domain/base_repository/work_setup_source.dart';
import 'package:knowticed_plus/features/time_tracker/domain/entities/work_location.dart';

class WorkSetupSourceResolver {
  WorkSetupSourceResolver({
    required CompanyModulesService companyModules,
    required WorkSetupSource timeTrackerSource,
    required WorkSetupSource hrSource,
  })  : _companyModules = companyModules,
        _timeTrackerSource = timeTrackerSource,
        _hrSource = hrSource;

  final CompanyModulesService _companyModules;
  final WorkSetupSource _timeTrackerSource;
  final WorkSetupSource _hrSource;

  /// Function Name: [hasHrModule]
  ///
  /// Purpose: Whether the company has HR (clean `Exception` on failure).
  ///
  /// Return type: [Future<bool>]
  Future<bool> hasHrModule() async {
    try {
      return await _companyModules.hasHrModule();
    } catch (error) {
      if (error is FirebaseException) {
        throw Exception('Could not read the company licence (${error.code}).');
      }
      if (error is StateError) throw Exception(error.message);
      if (error is Exception) rethrow;
      throw Exception('Could not read the company licence: $error');
    }
  }

  /// Function Name: [resolve]
  ///
  /// Purpose: The source to use for this company.
  ///
  /// Return type: [Future<WorkSetupSource>]
  Future<WorkSetupSource> resolve() async =>
      await hasHrModule() ? _hrSource : _timeTrackerSource;

  /// Function Name: [companyWorkingWeek]
  ///
  /// Purpose: ADDED 9/10/2026 (code review finding 1) — the working days of
  /// the company's own Time Tracker locations (the most common set among the
  /// ACTIVE ones), used ONLY to count vacation days when an employee's
  /// schedule has no known week (HR shifts). Never throws: unreadable or no
  /// location → null (the caller falls back to Sunday–Thursday).
  ///
  /// Return type: [Future<List<int>?>]
  Future<List<int>?> companyWorkingWeek() async {
    try {
      final Map<String, List<int>> byKey = <String, List<int>>{};
      final Map<String, int> votes = <String, int>{};
      for (final WorkLocation l in await _timeTrackerSource.loadLocations()) {
        if (!l.isActive || l.workingDays.isEmpty) continue;
        final List<int> days = (List<int>.of(l.workingDays)..sort());
        final String key = days.join(',');
        byKey[key] = days;
        votes[key] = (votes[key] ?? 0) + 1;
      }
      if (votes.isEmpty) return null;
      final String best = votes.entries
          .reduce((MapEntry<String, int> a, MapEntry<String, int> b) => b.value > a.value ? b : a)
          .key;
      return byKey[best];
    } catch (_) {
      // Optional hint only: without it the Sunday–Thursday default applies.
      return null;
    }
  }
}
