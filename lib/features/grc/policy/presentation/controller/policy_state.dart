part of 'policy_cubit.dart';

/// ************************* FILE INFO *************************** ///
/// File Name: policy_state.dart
/// Purpose: Contains all sealed state classes emitted by [PolicyCubit].
/// Author: Mohamed Magdy Abdelkhalek
/// Created At: 5/7/2026
/// Revision History: 2026-07-14 - Added PolicyActionPartialSuccess
///                   2026-07-28 - Removed PolicyControlActionSuccess/
///                                PolicyControlsListLoaded/
///                                PolicyControlDeleted — moved to
///                                ControlState (ControlCubit extraction)

sealed class PolicyState {}

/// State emitted before any action has been requested.
final class PolicyInitial extends PolicyState {}

/// State emitted while any async operation is in progress.
final class PolicyLoading extends PolicyState {}

/// class name: [PolicyControlsSummary]
///
/// purpose: the two facts the policy list card needs about a policy's
///          Controls that live nowhere on [PolicyEntity] -- how many there
///          are, and which departments they touch.
///
/// Controls are a subcollection under each policy, so this cannot come out of
/// the policies read itself; [PolicyCubit.getAllPolicies] fetches it in a
/// second pass and re-emits. Until that pass lands a policy simply has no
/// entry, and the card draws "-" rather than a wrong zero.
class PolicyControlsSummary {
  const PolicyControlsSummary({
    required this.controlCount,
    required this.departments,
  });

  final int controlCount;

  /// Every distinct department across the policy's controls, in first-seen
  /// order. A department weighted on three controls appears once.
  final List<String> departments;
}

/// State emitted when the full list of policies has been loaded successfully.
final class PolicyListLoaded extends PolicyState {
  final List<PolicyEntity> policies;

  /// Keyed by policy id. Empty on the first emit -- see
  /// [PolicyControlsSummary]. Never null, so the card can read it directly.
  final Map<String, PolicyControlsSummary> controlsSummary;

  PolicyListLoaded(
    this.policies, {
    this.controlsSummary = const <String, PolicyControlsSummary>{},
  });
}

/// State emitted when a single policy has been loaded successfully.
final class PolicySingleLoaded extends PolicyState {
  final PolicyEntity policy;

  PolicySingleLoaded(this.policy);
}

/// State emitted when a create / update / delete / restore action completes
/// successfully. [policy] holds the entity that was affected.
final class PolicyActionSuccess extends PolicyState {
  final PolicyEntity policy;

  PolicyActionSuccess(this.policy);
}

/// State emitted when a Policy was created successfully but one or more of
/// its initial Controls failed to be created. The Policy already exists in
/// Firestore at this point (Policy + Controls creation is not
/// transactional), so this is surfaced distinctly from [PolicyActionSuccess]
/// instead of silently dropping the failed controls.
final class PolicyActionPartialSuccess extends PolicyState {
  final PolicyEntity policy;
  final List<({PendingControlInput input, String message})> failedControls;

  PolicyActionPartialSuccess(this.policy, this.failedControls);
}

/// State emitted when any operation fails.
final class PolicyFailure extends PolicyState {
  final String message;

  PolicyFailure(this.message);
}
