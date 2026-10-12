import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';

abstract class UploadMediaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UploadMediaInitial extends UploadMediaState {}

class UploadMediaLoaded extends UploadMediaState {
  final FormEntity? formEntity;
  final List<UserGridItem> userGridItems;
  final List<UserGridItem> filteredUserGridItems;
  final List<String> mediaType;
  final String departmentType;
  final String employeeType;
  final TextEditingController searchController;
  final bool isHasMedia;

  UploadMediaLoaded({
    this.formEntity,
    required this.userGridItems,
    required this.filteredUserGridItems,
    required this.mediaType,
    required this.departmentType,
    required this.employeeType,
    required this.searchController,
    required this.isHasMedia,
  });

  UploadMediaLoaded copyWith({
    FormEntity? formEntity,
    List<UserGridItem>? userGridItems,
    List<UserGridItem>? filteredUserGridItems,
    List<String>? mediaType,
    String? departmentType,
    String? employeeType,
    bool? isHasMedia,
  }) {
    return UploadMediaLoaded(
      formEntity: formEntity ?? this.formEntity,
      userGridItems: userGridItems ?? this.userGridItems,
      filteredUserGridItems: filteredUserGridItems ?? this.filteredUserGridItems,
      mediaType: mediaType ?? this.mediaType,
      departmentType: departmentType ?? this.departmentType,
      employeeType: employeeType ?? this.employeeType,
      searchController: searchController,
      isHasMedia: isHasMedia ?? this.isHasMedia,
    );
  }

  @override
  List<Object?> get props => [
    formEntity,
    userGridItems,
    filteredUserGridItems,
    mediaType,
    departmentType,
    employeeType,
    isHasMedia,
  ];
}