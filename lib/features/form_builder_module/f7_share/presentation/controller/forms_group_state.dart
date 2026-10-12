import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/entities/group_entity.dart';

abstract class FormsGroupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FormsGroupInitial extends FormsGroupState {}

class FormsGroupLoading extends FormsGroupState {}

class FormsGroupLoaded extends FormsGroupState {
  final List<GroupEntity> groups;
  final List<GroupEntity> filteredGroups;
  final List<PersonEntity> persons;
  final List<PersonEntity> filteredPersons;
  final List<PersonEntity> selectedPersons;
  final List<PersonEntity> filteredSelectedPersons;
  final TextEditingController searchController;
  final String department;
  final GroupEntity? selectedGroup;
  final TextEditingController descriptionController;
  final TextEditingController groupNameController;
  final File? groupImage;
  final GlobalKey<FormState> createFormKey;

  FormsGroupLoaded({
    required this.groups,
    required this.filteredGroups,
    required this.persons,
    required this.filteredPersons,
    required this.selectedPersons,
    required this.filteredSelectedPersons,
    required this.searchController,
    required this.department,
    this.selectedGroup,
    required this.descriptionController,
    required this.groupNameController,
    this.groupImage,
    required this.createFormKey,
  });

  FormsGroupLoaded copyWith({
    List<GroupEntity>? groups,
    List<GroupEntity>? filteredGroups,
    List<PersonEntity>? persons,
    List<PersonEntity>? filteredPersons,
    List<PersonEntity>? selectedPersons,
    List<PersonEntity>? filteredSelectedPersons,
    String? department,
    GroupEntity? selectedGroup,
    File? groupImage,
    bool clearGroupImage = false,
    bool clearSelectedGroup = false,
  }) {
    return FormsGroupLoaded(
      groups: groups ?? this.groups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      persons: persons ?? this.persons,
      filteredPersons: filteredPersons ?? this.filteredPersons,
      selectedPersons: selectedPersons ?? this.selectedPersons,
      filteredSelectedPersons:
      filteredSelectedPersons ?? this.filteredSelectedPersons,
      searchController: searchController,
      department: department ?? this.department,
      selectedGroup: clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      descriptionController: descriptionController,
      groupNameController: groupNameController,
      groupImage: clearGroupImage ? null : (groupImage ?? this.groupImage),
      createFormKey: createFormKey,
    );
  }

  @override
  List<Object?> get props => [
    groups,
    filteredGroups,
    persons,
    filteredPersons,
    selectedPersons,
    filteredSelectedPersons,
    department,
    selectedGroup,
    groupImage,
  ];
}

class FormsGroupError extends FormsGroupState {
  final String message;

  FormsGroupError(this.message);

  @override
  List<Object?> get props => [message];
}