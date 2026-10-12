import 'package:dartz/dartz.dart';

import 'package:get/get.dart';
import 'package:knowticed_plus/features/form_builder_module/f2_create/domain/entity/person_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f1_home/domain/entity/page_entity.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/entity/user_grid_item.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/data/utils/result_constants.dart';
import 'package:knowticed_plus/core/network/failure_model.dart';
import 'package:knowticed_plus/core/helper/role/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/form_builder_module/f4_fillout/data/model/response_model.dart';
import 'package:knowticed_plus/features/form_builder_module/f6_result/domain/base_repository/result_base_repository.dart';

class GetUsersResponsesUseCases {
  final ResultBaseRepository resultRepository;
  GetUsersResponsesUseCases({required this.resultRepository});

  execute({required String formId, required List<String> userIds}) async {
    userIds = userIds.toSet().toList();
    Either<Failure, dynamic> result =
        await resultRepository.getFormResponses(formId: formId);
    if (result.isLeft()) return result;
    List<ResponseModel> responses = result.getOrElse(() => []);
    Map<String, List<UserGridItem>> usersResponses = {};
   usersResponses= _getFilteredResponses(responses, userIds, usersResponses);
    return result = Right(usersResponses);
  }

  /// Method Name: [_getFilteredResponses]
  ///
  /// Purpose: Filters the responses of the users
  ///
  /// Parameters:
  /// [responses][List<ResponseModel>] The list of responses
  ///
  /// Returns a [Map<String, List<UserGridItem>>] of the filtered responses
  Map<String,List<UserGridItem>> _getFilteredResponses(List<ResponseModel> responses, List<String> userIds,
      Map<String, List<UserGridItem>> usersResponses) {
    usersResponses = {};
    usersResponses.putIfAbsent(ResultConstants.pendingGridItemModel, () => []);
    usersResponses.putIfAbsent(
        ResultConstants.submittedGridItemModel, () => []);

    Map<String, ResponseModel> responsesMap = {};
    for (var element in responses) {
      responsesMap[element.submittedBy] = element;
      if(!userIds.contains(element.submittedBy)){
        userIds.add(element.submittedBy);
      }
    }

    for (var userId in userIds) {
      ResponseModel response = _getUserResponse(responsesMap, userId);
      if (response.pages != null && response.pages!.isNotEmpty) {
        usersResponses[ResultConstants.submittedGridItemModel]!
            .add(_convertResponseToUserGridItem(response));
      } else{
        usersResponses[ResultConstants.pendingGridItemModel]!
            .add(_convertResponseToUserGridItem(response));
      }
    }
    return usersResponses;
  }

  /// Method Name: [_getUserResponse]
  ///
  /// Purpose: Gets the response of a user from a map of responses
  ///
  /// Parameters:
  /// [responsesMap][Map<String, ResponseModel>] The map of responses
  /// [userId][String] The id of the user
  ///
  /// Returns a [ResponseModel] of the user
  ResponseModel _getUserResponse(
      Map<String, ResponseModel> responsesMap, String userId) {
    ResponseModel? response;
    if (responsesMap.containsKey(userId)) {
      response = responsesMap[userId];
    } else {
      response = ResponseModel(
          submittedBy: userId, timestamps: [], reminder: [], pages: []);
    }
    return response!;
  }

  /// Method Name: [_convertResponseToUserGridItem]
  ///
  /// Purpose: Converts a response model to a user grid item
  ///
  /// Parameters:
  /// [response][ResponseModel] The response model to be converted
  ///
  /// Returns a [UserGridItem] with the converted response model
  UserGridItem _convertResponseToUserGridItem(ResponseModel response) {
    return UserGridItem(
        person: PersonEntity.fromEmployeeEntity(
            Get.find<MainCoreEmployeeController>()
                .allEmployeesEntities!
                .firstWhere((element) => element.email == response.submittedBy)),
        lastReminderTime: response.reminder.lastOrNull?.toDate(),
        reminderCounter: response.reminder.length,
        page: response.pages?.map((e) => PageEntity.fromModel(e)).toList(),
        submissionTime: response.timestamps.firstOrNull?.toDate());
  }
}
