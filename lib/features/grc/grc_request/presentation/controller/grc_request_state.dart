part of 'grc_request_cubit.dart';

sealed class GrcRequestState {}

final class GrcRequestInitial extends GrcRequestState {}

final class GrcRequestLoading extends GrcRequestState {}

final class GrcRequestListLoaded extends GrcRequestState {
  final List<GrcRequestEntity> requests;

  GrcRequestListLoaded(this.requests);
}

final class GrcRequestActionSuccess extends GrcRequestState {
  final GrcRequestEntity request;

  GrcRequestActionSuccess(this.request);
}

final class GrcRequestFailure extends GrcRequestState {
  final String message;

  GrcRequestFailure(this.message);
}
