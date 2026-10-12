import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';

class GroupEntity {
  String groupId;
  String groupName;
  String groupDescription;
  String? groupImage;
  bool isSelected;
  List<PersonEntity> members;

  GroupEntity({
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    required this.members,
    this.isSelected = false,
    this.groupImage,
  });

  List<String> getUsersAvatar() {

    List<String> images = [];
    for (var element in members) {
      
      images.add(element.image);
    }

    
    return images;
  }

  // Add copyWith method
  GroupEntity copyWith({
    String? groupId,
    String? groupName,
    String? groupDescription,
    String? groupImage,
    bool? isSelected,
    List<PersonEntity>? members,
  }) {
    return GroupEntity(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupImage: groupImage ?? this.groupImage,
      isSelected: isSelected ?? this.isSelected,
      members: members ?? this.members,
    );
  }

  // Optional: Add a better way to handle nullable groupImage in copyWith
  GroupEntity copyWithClearImage({
    String? groupId,
    String? groupName,
    String? groupDescription,
    bool clearImage = false,
    bool? isSelected,
    List<PersonEntity>? members,
  }) {
    return GroupEntity(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupImage: clearImage ? null : this.groupImage,
      isSelected: isSelected ?? this.isSelected,
      members: members ?? this.members,
    );
  }
}