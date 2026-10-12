import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CreateFormHeadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateFormHeadInitial extends CreateFormHeadState {}

class CreateFormHeadLoading extends CreateFormHeadState {}

class CreateFormHeadLoaded extends CreateFormHeadState {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController arTitleController;
  final TextEditingController arDescriptionController;
  final TextEditingController horizontalPaddingController;
  final TextEditingController verticalPaddingController;
  final TextEditingController watermarkOpacityController;
  final TextEditingController watermarkSizeController;

  final String? cover;
  final String? watermark;
  final String? accessManagement;
  final String? orientation;

  // ✅ Version counter for tracking state changes
  final int _version;

  CreateFormHeadLoaded({
    required this.titleController,
    required this.descriptionController,
    required this.arTitleController,
    required this.arDescriptionController,
    required this.horizontalPaddingController,
    required this.verticalPaddingController,
    required this.watermarkOpacityController,
    required this.watermarkSizeController,
    this.cover,
    this.watermark,
    this.accessManagement,
    this.orientation,
    int version = 0,
  }) : _version = version;

  CreateFormHeadLoaded copyWith({
    TextEditingController? titleController,
    TextEditingController? descriptionController,
    TextEditingController? arTitleController,
    TextEditingController? arDescriptionController,
    TextEditingController? horizontalPaddingController,
    TextEditingController? verticalPaddingController,
    TextEditingController? watermarkOpacityController,
    TextEditingController? watermarkSizeController,
    String? cover,
    String? watermark,
    String? accessManagement,
    String? orientation,
    bool clearCover = false,
    bool clearWatermark = false,
  }) {
    return CreateFormHeadLoaded(
      titleController: titleController ?? this.titleController,
      descriptionController: descriptionController ?? this.descriptionController,
      arTitleController: arTitleController ?? this.arTitleController,
      arDescriptionController: arDescriptionController ?? this.arDescriptionController,
      horizontalPaddingController: horizontalPaddingController ?? this.horizontalPaddingController,
      verticalPaddingController: verticalPaddingController ?? this.verticalPaddingController,
      watermarkOpacityController: watermarkOpacityController ?? this.watermarkOpacityController,
      watermarkSizeController: watermarkSizeController ?? this.watermarkSizeController,
      cover: clearCover ? null : (cover ?? this.cover),
      watermark: clearWatermark ? null : (watermark ?? this.watermark),
      accessManagement: accessManagement ?? this.accessManagement,
      orientation: orientation ?? this.orientation,
      version: _version + 1,
    );
  }

  @override
  List<Object?> get props => [

    // ✅ ONLY include things that should trigger full widget rebuilds
    cover,
    watermark,
    accessManagement,
    orientation,
    _version,
  ];
}

class CreateFormHeadError extends CreateFormHeadState {
  final String message;

  CreateFormHeadError(this.message);

  @override
  List<Object?> get props => [message];
}