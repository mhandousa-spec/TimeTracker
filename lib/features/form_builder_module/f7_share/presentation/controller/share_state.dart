import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:knowticed_plus/features/form_builder_module/f2_create/data/model/form_privacy_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';

abstract class ShareState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ShareInitial extends ShareState {}

class ShareLoading extends ShareState {}

class ShareLoaded extends ShareState {
  final List<PersonEntity> persons;
  final List<PersonEntity> filteredPersons;
  final bool isEditPermission;
  final DateTime? timeBegin;
  final DateTime? timeEnd;
  final FormEntity? selectedForm;
  final FormPrivacyModel? formPrivacyModel;
  final List<PersonEntity> previousSelectedPersons;
  final List<PersonEntity> filteredPreviousSelectedPersons;
  final List<PersonEntity> newSelectedPersons;
  final List<PersonEntity> filteredNewSelectedPersons;
  final String? department;
  final TextEditingController searchController;

  ShareLoaded({
    required this.persons,
    required this.filteredPersons,
    required this.isEditPermission,
    this.timeBegin,
    this.timeEnd,
    this.selectedForm,
    this.formPrivacyModel,
    required this.previousSelectedPersons,
    required this.filteredPreviousSelectedPersons,
    required this.newSelectedPersons,
    required this.filteredNewSelectedPersons,
    this.department,
    required this.searchController,
  });

  ShareLoaded copyWith({
    List<PersonEntity>? persons,
    List<PersonEntity>? filteredPersons,
    bool? isEditPermission,
    DateTime? timeBegin,
    DateTime? timeEnd,
    FormEntity? selectedForm,
    FormPrivacyModel? formPrivacyModel,
    List<PersonEntity>? previousSelectedPersons,
    List<PersonEntity>? filteredPreviousSelectedPersons,
    List<PersonEntity>? newSelectedPersons,
    List<PersonEntity>? filteredNewSelectedPersons,
    String? department,
    bool clearTimeBegin = false,
    bool clearTimeEnd = false,
    bool clearSelectedForm = false,
    bool clearFormPrivacyModel = false,
    bool clearDepartment = false,
  }) {
    return ShareLoaded(
      persons: persons ?? this.persons,
      filteredPersons: filteredPersons ?? this.filteredPersons,
      isEditPermission: isEditPermission ?? this.isEditPermission,
      timeBegin: clearTimeBegin ? null : (timeBegin ?? this.timeBegin),
      timeEnd: clearTimeEnd ? null : (timeEnd ?? this.timeEnd),
      selectedForm: clearSelectedForm ? null : (selectedForm ?? this.selectedForm),
      formPrivacyModel: clearFormPrivacyModel ? null : (formPrivacyModel ?? this.formPrivacyModel),
      previousSelectedPersons: previousSelectedPersons ?? this.previousSelectedPersons,
      filteredPreviousSelectedPersons: filteredPreviousSelectedPersons ?? this.filteredPreviousSelectedPersons,
      newSelectedPersons: newSelectedPersons ?? this.newSelectedPersons,
      filteredNewSelectedPersons: filteredNewSelectedPersons ?? this.filteredNewSelectedPersons,
      department: clearDepartment ? null : (department ?? this.department),
      searchController: searchController,
    );
  }

  @override
  List<Object?> get props => [
    persons,
    filteredPersons,
    isEditPermission,
    timeBegin,
    timeEnd,
    selectedForm,
    formPrivacyModel,
    previousSelectedPersons,
    filteredPreviousSelectedPersons,
    newSelectedPersons,
    filteredNewSelectedPersons,
    department,
  ];
}

class ShareError extends ShareState {
  final String message;

  ShareError(this.message);

  @override
  List<Object?> get props => [message];
}