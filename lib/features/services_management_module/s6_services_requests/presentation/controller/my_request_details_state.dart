/// Module: services_management_module
/// Description: State for MyRequestDetailsCubit — owns all data loaded /
///              mutated for a single "my request" details page: reject/
///              approve/cancel comment text, resolved current doc state, and
///              the resolved service name/description/duration shown while
///              the parent-service doc is still loading.
/// Author: Knowticed Team
/// Date: 2026-07-02
/// Dependencies: equatable
/// Revision History: Initial version — extracted from MyRequestDetails
///                    (audit fix #1/#3: split file + move I/O out of UI).

import 'package:equatable/equatable.dart';

class MyRequestDetailsData extends Equatable {
  final String? currentState;
  final String? cancelReason;
  final String rejectCommentText;
  final String approveCommentText;

  final String serviceNameToDisplay;
  final String serviceDescriptionToDisplay;
  final String durationToDisplay;
  final bool isLoadingServiceDetails;

  final int totalServices;
  final int pendingCount;
  final int approvedCount;
  final int cancelCount;
  final int rejectedCount;
  final int inProgressCount;
  final int branchSlaCount;
  final int doneCount;

  const MyRequestDetailsData({
    this.currentState,
    this.cancelReason,
    this.rejectCommentText = '',
    this.approveCommentText = '',
    this.serviceNameToDisplay = '',
    this.serviceDescriptionToDisplay = '',
    this.durationToDisplay = '',
    this.isLoadingServiceDetails = true,
    this.totalServices = 0,
    this.pendingCount = 0,
    this.approvedCount = 0,
    this.cancelCount = 0,
    this.rejectedCount = 0,
    this.inProgressCount = 0,
    this.branchSlaCount = 0,
    this.doneCount = 0,
  });

  MyRequestDetailsData copyWith({
    String? currentState,
    String? cancelReason,
    String? rejectCommentText,
    String? approveCommentText,
    String? serviceNameToDisplay,
    String? serviceDescriptionToDisplay,
    String? durationToDisplay,
    bool? isLoadingServiceDetails,
    int? totalServices,
    int? pendingCount,
    int? approvedCount,
    int? cancelCount,
    int? rejectedCount,
    int? inProgressCount,
    int? branchSlaCount,
    int? doneCount,
  }) {
    return MyRequestDetailsData(
      currentState: currentState ?? this.currentState,
      cancelReason: cancelReason ?? this.cancelReason,
      rejectCommentText: rejectCommentText ?? this.rejectCommentText,
      approveCommentText: approveCommentText ?? this.approveCommentText,
      serviceNameToDisplay: serviceNameToDisplay ?? this.serviceNameToDisplay,
      serviceDescriptionToDisplay:
          serviceDescriptionToDisplay ?? this.serviceDescriptionToDisplay,
      durationToDisplay: durationToDisplay ?? this.durationToDisplay,
      isLoadingServiceDetails:
          isLoadingServiceDetails ?? this.isLoadingServiceDetails,
      totalServices: totalServices ?? this.totalServices,
      pendingCount: pendingCount ?? this.pendingCount,
      approvedCount: approvedCount ?? this.approvedCount,
      cancelCount: cancelCount ?? this.cancelCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      branchSlaCount: branchSlaCount ?? this.branchSlaCount,
      doneCount: doneCount ?? this.doneCount,
    );
  }

  @override
  List<Object?> get props => [
        currentState,
        cancelReason,
        rejectCommentText,
        approveCommentText,
        serviceNameToDisplay,
        serviceDescriptionToDisplay,
        durationToDisplay,
        isLoadingServiceDetails,
        totalServices,
        pendingCount,
        approvedCount,
        cancelCount,
        rejectedCount,
        inProgressCount,
        branchSlaCount,
        doneCount,
      ];
}

abstract class MyRequestDetailsState extends Equatable {
  const MyRequestDetailsState();

  @override
  List<Object?> get props => [];
}

class MyRequestDetailsLoading extends MyRequestDetailsState {
  const MyRequestDetailsLoading();
}

class MyRequestDetailsLoaded extends MyRequestDetailsState {
  final MyRequestDetailsData data;

  const MyRequestDetailsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class MyRequestDetailsCancelling extends MyRequestDetailsState {
  final MyRequestDetailsData data;

  const MyRequestDetailsCancelling(this.data);

  @override
  List<Object?> get props => [data];
}

class MyRequestDetailsCancelError extends MyRequestDetailsState {
  final MyRequestDetailsData data;
  final String message;

  const MyRequestDetailsCancelError(this.data, this.message);

  @override
  List<Object?> get props => [data, message];
}
