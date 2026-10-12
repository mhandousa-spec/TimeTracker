import 'package:equatable/equatable.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';

abstract class FillOutState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FillOutInitial extends FillOutState {}

class FillOutLoading extends FillOutState {}

class FillOutLoaded extends FillOutState {
  final List<PageControllerModel> pages;
  final bool isSubmitted;
  final DateTime timestamp; // ✅ MUST HAVE THIS

  FillOutLoaded({
    required this.pages,
    required this.isSubmitted,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  FillOutLoaded copyWith({
    List<PageControllerModel>? pages,
    bool? isSubmitted,
  }) {
    return FillOutLoaded(
      pages: pages ?? this.pages,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      timestamp: DateTime.now(), // ✅ Always new timestamp
    );
  }

  @override
  List<Object?> get props => [pages, isSubmitted, timestamp]; // ✅ MUST INCLUDE timestamp
}

class FillOutError extends FillOutState {
  final String message;

  FillOutError(this.message);

  @override
  List<Object?> get props => [message];
}