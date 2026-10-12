import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';

abstract class SubmissionsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmissionsInitial extends SubmissionsState {}

class SubmissionsLoading extends SubmissionsState {}

class SubmissionsLoaded extends SubmissionsState {
  final List<PageControllerModel> pages;
  final bool isSubmitted;
  final bool isReadOnly;
  final bool isSubmitting;

  SubmissionsLoaded({
    required this.pages,
    required this.isSubmitted,
    required this.isReadOnly,
    this.isSubmitting = false,  // ✅ Default value for backwards compatibility
  });

  SubmissionsLoaded copyWith({
    List<PageControllerModel>? pages,
    bool? isSubmitted,
    bool? isReadOnly,
    bool? isSubmitting,
  }) {
    return SubmissionsLoaded(
      pages: pages ?? this.pages,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [pages, isSubmitted, isReadOnly, isSubmitting];
}

class SubmissionsError extends SubmissionsState {
  final String message;

  SubmissionsError(this.message);

  @override
  List<Object?> get props => [message];
}