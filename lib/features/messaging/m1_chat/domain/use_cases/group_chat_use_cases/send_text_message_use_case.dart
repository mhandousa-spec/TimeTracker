/// Module: messaging / chat / domain/use_cases/group_chat_use_cases/send_text_message_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import 'package:knowticed_plus/core/network/message_module/services/error_handler.dart';
import 'package:knowticed_plus/core/enums/message_module/message_types.dart';
import '../../../../../../core/helper/message_module/interface/controller/messaging_init_controller.dart';
import '../../../../../../core/helper/message_module/interface/entity/base_messaging_interface_parameters.dart';
import '../../../../m3_groups/domain/entities/group_entity.dart';
import '../../../../m3_groups/domain/entities/member_entity.dart';
import '../../../../m4_messaging_home/domain/entities/chat_type_entity.dart';
import '../../entity/new_message_content_entity.dart';
import '../../repository/chat_repository/base_chat_repository.dart';

class GroupSendTextMessageUseCase {
  BaseChatRepository chatRepository;

  GroupSendTextMessageUseCase({required this.chatRepository});

  Future<Either<Failure, dynamic>> execute(
      {required String messageText,
        required BaseMessagingInterfaceParameters currentUser,
        required ChatTypeEntity otherConnectionSide,
        String? repliedMessageId,
        Map<String, MemberEntity>? mentionedMembers,
        String? previewText}) async {

    TextMessageContentEntity messageContent = TextMessageContentEntity(
        messageContent: messageText,
        repliedMessageId: repliedMessageId,
        mentionedMembers: mentionedMembers,
        previewContent: previewText);
    Either<Failure, dynamic> response = await chatRepository.sendNewMessage(
      currentUser: currentUser,
      otherConnectionSide: otherConnectionSide,
      messageContent: messageContent,
    );
    if (response.isLeft()) {
      return response;
    }
    List<String> targetAudienceIds = (otherConnectionSide as GroupEntity)
        .members
        .map((e) => e.memberId)
        .toList();
    targetAudienceIds
        .remove(currentUser.userId); // Exclude the sender from the audience
    Get.find<MessagingInitController>().messagingConfigurations.sendNotification.call(
        targetAudienceIds: targetAudienceIds,
        englishBody:
        '${currentUser.primaryLanguageName} sends a ${MessageTypes.text.messagePrimaryLanguageName} on Group ${otherConnectionSide.primaryLanguageName}',
        englishTitle: 'New Message',
        arabicBody:
        '${currentUser.secondaryLanguageName} أرسل لك ${MessageTypes.text.messageArabicName} في المجموعة ${otherConnectionSide.primaryLanguageName}',
        arabicTitle: 'رسالة جديدة',
        payload: <String, String>{
          "Group_Id": otherConnectionSide.otherSideId,
          "Sender_Id": currentUser.userId,
        });
    return response;
  }
}