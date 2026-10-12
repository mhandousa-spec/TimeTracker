/// Module: settings/se2_social
///
///*************************** FILE INFO ****************************///
/// File Name: social_base_repository.dart
/// Purpose: Domain contract for persisting the social section of a profile.
/// Author: Knowticed Plus team
/// Created at: 11/8/2026
///
/// Added for CR-SKEL-SE2-N01. `SocialController.updateAllSocialInformation`
/// called `FirebaseFirestore.instance…update(...)` directly from presentation.

import 'package:dartz/dartz.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';

abstract class SocialBaseRepository {
  /// Function Name: [updateSocialFields]
  ///
  /// Purpose: Append the given social changes to the employee's profile
  ///          document as ONE new revision (CHANGED 9/10/2026 — was "merge",
  ///          which overwrote the history arrays): one entry added to
  ///          `timestamps` and to every history list, the new value for each
  ///          changed field.
  ///
  /// Parameters:
  /// - [employeeId]: Firestore document id.
  /// - [fields]: only the changed fields, field name → new revision value, as
  ///   produced by `BuildSocialUpdate`. Never empty — the caller
  ///   short-circuits on an empty change set rather than issuing a no-op
  ///   write.
  ///
  /// Returns: [Future<Either<Failure, void>>].
  Future<Either<Failure, void>> updateSocialFields({
    required String employeeId,
    required Map<String, dynamic> fields,
  });
}
