/// Module: roles / r4_active_directory / data / models / employees_model
///
///*************************** FILE INFO ****************************///
/// File Name: academic_history_current_entity.dart
/// Purpose: Declares `AcademicHistoryEntity`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Added the standard module + FILE INFO header.

/// Flattened, read-only view of [AcademicHistory] (academic_model.dart).
///
/// [AcademicHistory] stores the full audit trail — every field is a
/// `List<String?>` plus `timestamps`. This entity holds only the *current*
/// value of each field (i.e. `.lastOrNull` of each list), which is what the
/// UI and the services module consume. The two are intentionally different
/// shapes, not duplicates: keep this projection for scalar reads and use
/// [AcademicHistory] whenever the history itself matters.
///
/// Lives next to academic_model.dart so the pairing is obvious.
///
/// NOTE: a second class with this exact name and these exact 8 fields also
/// exists at services_management_module/main_controller/data/models/
/// model_employee.dart. That copy is the fully-featured one (it has
/// `fromJson`/`toJson` and Firestore key constants) and serves the services
/// module; this copy's `toJson()` is an empty stub and is never called. The two
/// are unrelated by import, so consolidating them would couple
/// active_directory to services_management_module — worth doing deliberately
/// rather than as a drive-by.
class AcademicHistoryEntity {
  final String? graduateFrom;
  final String? university;
  final String? yearOfGraduation;
  final String? gpa;
  final String? graduateFromStatus;
  final String? universityStatus;
  final String? yearOfGraduationStatus;
  final String? gpaStatus;

  AcademicHistoryEntity({
    this.graduateFrom,
    this.university,
    this.yearOfGraduation,
    this.gpa,
    this.graduateFromStatus,
    this.universityStatus,
    this.yearOfGraduationStatus,
    this.gpaStatus,
  });
  toJson() {}
}
