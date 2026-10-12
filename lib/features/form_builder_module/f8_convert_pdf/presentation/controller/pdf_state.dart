import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class PdfState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PdfInitial extends PdfState {}

class PdfLoaded extends PdfState {
  // ✅ REMOVED widgetKeys - they're now in the cubit
  final List<bool> isExpanded;
  final TextEditingController fileName;
  final int version;

  PdfLoaded({
    required this.isExpanded,
    required this.fileName,
    this.version = 0,
  });

  PdfLoaded copyWith({
    List<bool>? isExpanded,
    TextEditingController? fileName,
  }) {
    return PdfLoaded(
      isExpanded: isExpanded ?? this.isExpanded,
      fileName: fileName ?? this.fileName,
      version: version + 1,
    );
  }

  @override
  List<Object?> get props => [isExpanded, fileName, version];
}