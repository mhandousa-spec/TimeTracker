import 'package:dartz/dartz.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/data/models/forms_group_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/entities/group_entity.dart';

import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f7_share/domain/base_repository/group_base_repository.dart';

class GetUserGroupsUseCase {
  final GroupBaseRepository groupRepository;

  GetUserGroupsUseCase({required this.groupRepository});

  /// Method Name: [execute]
  ///
  /// Purpose: Gets all groups of the current user
  ///
  /// Parameters:
  ///            [currentUserId] The id of the current user
  ///            [availablePersons] All available persons to match against
  ///            [previousSelectedPersons] Previously selected persons
  Future<Either<Failure, dynamic>> execute({
    required String currentUserId,
    List<PersonEntity>? availablePersons,
    List<PersonEntity>? previousSelectedPersons,
  }) async {
    Either<Failure, dynamic> result =
    await groupRepository.getGroups(currentUserId: currentUserId);
    List<GroupEntity> groups = [];
    if (result.isLeft()) return result;
    List<FormsGroupModel> formsGroupModels = result.getOrElse(() => []);
    for (FormsGroupModel formsGroupModel in formsGroupModels) {
      groups.add(_convertGroupModelToEntity(
        formsGroupModel,
        availablePersons ?? [],
        previousSelectedPersons ?? [],
      ));
    }

    return result = Right(groups);
  }

  /// Method Name: [_convertGroupModelToEntity]
  ///
  /// Purpose: Converts a [FormsGroupModel] to a [GroupEntity]
  ///
  /// Parameters:
  ///           [formsGroupModel] The model to convert
  ///           [availablePersons] All available persons
  ///           [previousSelectedPersons] Previously selected persons
  /// Method Name: [_convertGroupModelToEntity]
  GroupEntity _convertGroupModelToEntity(
      FormsGroupModel formsGroupModel,
      List<PersonEntity> availablePersons,
      List<PersonEntity> previousSelectedPersons,
      ) {

    

    GroupEntity group = GroupEntity(
      groupId: formsGroupModel.id,
      groupDescription: formsGroupModel.description.last,
      groupName: formsGroupModel.name.last,
      groupImage: formsGroupModel.image.lastOrNull,
      members: [],
    );

    Set<String> membersEmails = Set.from(formsGroupModel.emails);
    for (int i = 0; i < formsGroupModel.status.length; i++) {
      if (formsGroupModel.status[i] == "inactive") {
        
        membersEmails.remove(formsGroupModel.emails[i]);
      }
    }

    // Match against available persons
    for (PersonEntity person in availablePersons) {
      if (membersEmails.contains(person.id)) {
        
        group.members.add(person);
      }
    }

    // Match against previously selected persons
    for (PersonEntity person in previousSelectedPersons) {
      if (membersEmails.contains(person.id) && !group.members.contains(person)) {
        
        group.members.add(person);
      }
    }

    return group;
  }
}