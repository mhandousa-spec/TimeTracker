
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_digital_signature_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/attachment_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/fields/image_field_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/form_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/row_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_cubit.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/result_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/presentation/controller/upload_media_state.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/result_constants.dart';

import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/media_handler.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/enums/field_type.dart';
import 'package:knowticed_plus/generated/l10n.dart';
class UploadMediaCubit extends Cubit<UploadMediaState> {
  final ResultCubit resultCubit;

  UploadMediaCubit({required this.resultCubit}) : super(UploadMediaInitial());

  void initialize() {
    if (resultCubit.state is! ResultLoaded) return;
    final resultState = resultCubit.state as ResultLoaded;

    final formEntity = resultState.formEntity;
    final userGridItems = _createUserGridItems(resultState.submittedUsers);
    final isHasMedia = _checkIfHasMedia(formEntity!);

    emit(UploadMediaLoaded(
      formEntity: formEntity,
      userGridItems: userGridItems,
      filteredUserGridItems: userGridItems,
      searchController: TextEditingController(),
      mediaType: [],
      departmentType: S.current.all,  // ✅ Add .tr
      employeeType: ResultConstants.employeeFilter.first,  // ✅ Use first item with .tr
      isHasMedia: isHasMedia,
    ));
  }

  List<UserGridItem> _createUserGridItems(List<UserGridItem> submissions) {
    List<UserGridItem> userGridItems = [];
    for (UserGridItem submission in submissions) {
      userGridItems.add(UserGridItem(
        person: PersonEntity(
          department: submission.person.department,
          id: submission.person.id,
          isSelected: false,
          image: submission.person.image,
          arabicName: submission.person.arabicName,
          englishName: submission.person.englishName,
          titleEnglish: submission.person.titleEnglish,
          titleArabic: submission.person.titleArabic,
          phone: submission.person.phone,
        ),
        reminderCounter: submission.reminderCounter,
        page: submission.page,
        lastReminderTime: submission.lastReminderTime,
        submissionTime: submission.submissionTime,
      ));
    }
    return userGridItems;
  }

  void applyFilter() {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    List<UserGridItem> filteredUserGridItems = [];
    for (UserGridItem item in currentState.userGridItems) {
      if (item.person.departmentName == currentState.departmentType ||
          currentState.departmentType == 'All') {
        final searchText = currentState.searchController.text.toLowerCase();
        if (item.person.arabicName.contains(searchText) ||
            item.person.englishName.toLowerCase().contains(searchText) ||
            item.person.titleArabic.toLowerCase().contains(searchText) ||
            item.person.titleEnglish.toLowerCase().contains(searchText)) {
          filteredUserGridItems.add(item);
        }
      }
    }

    emit(currentState.copyWith(filteredUserGridItems: filteredUserGridItems));
  }

  void togglePersonSelection(UserGridItem userGridItem) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    userGridItem.person.isSelected = !userGridItem.person.isSelected;
    emit(currentState.copyWith());
  }

  void updateSelectedEmployeeType(String? value) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    final userGridItems = List<UserGridItem>.from(currentState.userGridItems);
    for (int i = 0; i < userGridItems.length; i++) {
      userGridItems[i].person.isSelected = value == S.current.all;
    }

    emit(currentState.copyWith(
      employeeType: value ?? ResultConstants.employeeFilter.first,  // ✅ Change default
      userGridItems: userGridItems,
    ));
  }

  void updateDepartmentType(String? value) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    emit(currentState.copyWith(departmentType: value ?? S.current.all));  // ✅ Add .tr
    applyFilter();
  }

  void selectMediaType(String value) {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    final mediaType = List<String>.from(currentState.mediaType);
    if (mediaType.contains(value)) {
      mediaType.remove(value);
    } else {
      mediaType.add(value);
    }

    emit(currentState.copyWith(mediaType: mediaType));
  }

  Future<void> downloadMedia() async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    for (UserGridItem userGridItem in currentState.filteredUserGridItems) {
      if (userGridItem.person.isSelected) {
        await downloadUserMedia(userGridItem);
      }
    }
  }

  Future<void> downloadUserMedia(UserGridItem userGridItem) async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    

    for (PageEntity page in userGridItem.page!) {
      for (RowEntity rowEntity in page.rows) {
        for (FieldModel fieldModel in rowEntity.fields) {
          await handleImageDownload(fieldModel, userGridItem);
          await handleAttachementDownload(fieldModel, userGridItem);
          await handleSignatureDownload(fieldModel, userGridItem);
        }
      }
    }
  }

  Future<void> handleImageDownload(
      FieldModel fieldModel,
      UserGridItem userGridItem,
      ) async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    if (!(currentState.mediaType.contains(ResultConstants.mediaTypeFilter[0]))) {
      return;
    }

    if (fieldModel.type == FormFieldType.image) {
      if ((fieldModel as ImageFieldModel).images != null) {
        for (int i = 0; i < fieldModel.images!.length; i++) {
          String mediaPath = fieldModel.images![i] ?? '';
          if (mediaPath.isEmpty) continue;
          String mediaName =
          getMediaName(mediaPath, fieldModel.title, userGridItem.person.id);
          await MediaHandler().downloadFile(mediaPath, mediaName);
        }
      }
    }
  }

  Future<void> handleAttachementDownload(
      FieldModel fieldModel,
      UserGridItem userGridItem,
      ) async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    if (!(currentState.mediaType.contains(ResultConstants.mediaTypeFilter[1]))) {
      return;
    }

    if (fieldModel.type == FormFieldType.attachment) {
      
      if ((fieldModel as AttachmentFieldModel).attachmentLink != null) {
        String originalMediaName = fieldModel.attachmentLink!.name;
        String mediaPath = fieldModel.attachmentLink!.path;
        String mediaName =
        getMediaName(originalMediaName, fieldModel.title, userGridItem.person.id);
        await MediaHandler().downloadFile(mediaPath, mediaName);
      }
    }
  }

  Future<void> handleSignatureDownload(
      FieldModel fieldModel,
      UserGridItem userGridItem,
      ) async {
    if (state is! UploadMediaLoaded) return;
    final currentState = state as UploadMediaLoaded;

    if (!(currentState.mediaType.contains(ResultConstants.mediaTypeFilter[2]))) {
      return;
    }

    if (fieldModel.type == FormFieldType.digitalSignature) {
      if ((fieldModel as AttachmentDigitalSignatureFieldModel).attachmentLink !=
          null) {
        String mediaPath = fieldModel.attachmentLink!.path;
        String mediaName =
        getMediaName(mediaPath, fieldModel.title, userGridItem.person.id);
        await MediaHandler().downloadFile(mediaPath, mediaName);
      }
    }
  }

  String getMediaName(String mediaPath, String fieldTitle, String userId) {
    if (state is! UploadMediaLoaded) return '';
    final currentState = state as UploadMediaLoaded;

    String mediaName = mediaPath.split('/').last;
    String name = currentState.formEntity!.formHeadModel.title;
    name += '_$fieldTitle';
    name += '_$userId';
    name += '_$mediaName';
    return name;
  }

  bool _checkIfHasMedia(FormEntity formEntity) {
    for (var page in formEntity.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is ImageFieldModel ||
              field is AttachmentFieldModel ||
              field is AttachmentDigitalSignatureFieldModel) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool hasSignature() {
    if (state is! UploadMediaLoaded) return false;
    final currentState = state as UploadMediaLoaded;

    for (var page in currentState.formEntity!.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is AttachmentDigitalSignatureFieldModel) {
            
            return true;
          }
        }
      }
    }
    return false;
  }

  bool hasAttachment() {
    if (state is! UploadMediaLoaded) return false;
    final currentState = state as UploadMediaLoaded;

    for (var page in currentState.formEntity!.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is AttachmentFieldModel) {
            
            return true;
          }
        }
      }
    }
    return false;
  }

  bool hasImage() {
    if (state is! UploadMediaLoaded) return false;
    final currentState = state as UploadMediaLoaded;

    for (var page in currentState.formEntity!.pages) {
      for (var row in page.rows) {
        for (var field in row.fields) {
          if (field is ImageFieldModel) {
            
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  Future<void> close() {
    if (state is UploadMediaLoaded) {
      final currentState = state as UploadMediaLoaded;
      currentState.searchController.dispose();
    }
    return super.close();
  }
}