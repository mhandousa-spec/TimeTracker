/// Module: core
///
///*************************** FILE INFO ****************************///
/// File Name: error_handler.dart
/// Purpose: Declares `Failure`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

// Youssef Ashraf
///abstract class for general Failures
abstract class Failure {
  final String errMessage;

  const Failure(this.errMessage);
}

// Server failure
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}


// cach, audio etc...
class FeatureFailure extends Failure {
  FeatureFailure(super.errMessage);
}

class FirebaseFailure extends Failure {

  FirebaseFailure(super.errMessage);
}
