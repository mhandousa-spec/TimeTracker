import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/page_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/department.dart';

abstract class CreateFormDataState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateFormDataInitial extends CreateFormDataState {}

class CreateFormDataLoading extends CreateFormDataState {}

class CreateFormDataLoaded extends CreateFormDataState {
  final List<PageControllerModel> pages;
  final int? expandedPageIndex;
  final List<DepartmentEntity> departmentsShown;
  final List<PersonEntity> personList;
  final List<PersonEntity> shownPersonList;
  final List<PersonEntity> selectedPersonList;
  final DateTime? timeBegin;
  final DateTime? timeEnd;
  final bool isEdit;
  final List<Color> savedColors;
  final String? selectedDepartment;
  final String? currentPersonDepartment;
  final String? textSearch;
  final int version;
  final String? existingFormId; // ✅ ADD THIS - Stores original form ID when editing
  final DateTime? existingCreateDate; // ✅ ADD THIS - Stores original create date when editing

  CreateFormDataLoaded({
    required this.pages,
    this.expandedPageIndex,
    required this.departmentsShown,
    required this.personList,
    required this.shownPersonList,
    required this.selectedPersonList,
    this.timeBegin,
    this.timeEnd,
    required this.isEdit,
    required this.savedColors,
    this.selectedDepartment,
    this.currentPersonDepartment,
    this.textSearch,
    this.version = 0,
    this.existingFormId, // ✅ ADD THIS
    this.existingCreateDate, // ✅ ADD THIS
  });

  CreateFormDataLoaded copyWith({
    List<PageControllerModel>? pages,
    int? expandedPageIndex,
    List<DepartmentEntity>? departmentsShown,
    List<PersonEntity>? personList,
    List<PersonEntity>? shownPersonList,
    List<PersonEntity>? selectedPersonList,
    DateTime? timeBegin,
    DateTime? timeEnd,
    bool? isEdit,
    List<Color>? savedColors,
    String? selectedDepartment,
    String? currentPersonDepartment,
    String? textSearch,
    bool incrementVersion = true,
    String? existingFormId, // ✅ ADD THIS
    DateTime? existingCreateDate, // ✅ ADD THIS
  }) {
    return CreateFormDataLoaded(
      pages: pages ?? this.pages,
      expandedPageIndex: expandedPageIndex ?? this.expandedPageIndex,
      departmentsShown: departmentsShown ?? this.departmentsShown,
      personList: personList ?? this.personList,
      shownPersonList: shownPersonList ?? this.shownPersonList,
      selectedPersonList: selectedPersonList ?? this.selectedPersonList,
      timeBegin: timeBegin ?? this.timeBegin,
      timeEnd: timeEnd ?? this.timeEnd,
      isEdit: isEdit ?? this.isEdit,
      savedColors: savedColors ?? this.savedColors,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      currentPersonDepartment: currentPersonDepartment ?? this.currentPersonDepartment,
      textSearch: textSearch ?? this.textSearch,
      version: incrementVersion ? this.version + 1 : this.version,
      existingFormId: existingFormId ?? this.existingFormId, // ✅ ADD THIS
      existingCreateDate: existingCreateDate ?? this.existingCreateDate, // ✅ ADD THIS
    );
  }

  @override
  List<Object?> get props => [
    pages,
    expandedPageIndex,
    departmentsShown,
    personList,
    shownPersonList,
    selectedPersonList,
    timeBegin,
    timeEnd,
    isEdit,
    savedColors,
    selectedDepartment,
    currentPersonDepartment,
    textSearch,
    version,
    existingFormId, // ✅ ADD THIS
    existingCreateDate, // ✅ ADD THIS
  ];
}

class CreateFormDataError extends CreateFormDataState {
  final String message;

  CreateFormDataError(this.message);

  @override
  List<Object?> get props => [message];
}