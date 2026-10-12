/// Module: home/h1_home_page
///
///*************************** FILE INFO ****************************///
/// File Name: board_model.dart
/// Purpose: Declares `BoardModel`.
/// Author: Knowticed Plus team
/// Updated: 12/8/2026 - Moved here from the deleted top-level
///          `features/task_management` module. See the note on
///          `card_model/card_model.dart` for why that module was empty of
///          everything except models.
/// Updated: 11/8/2026 - Added the standard module + FILE INFO header.

import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/board_department.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/board_name.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/messaging_channels.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/card_model/card_model.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/board_description.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/board_image.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/board_tasks.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/models/board_model/board_members.dart';

class BoardModel {
  String? boardId;
  BoardName? boardName;
  BoardDescription? boardDescription;
  BoardDepartment? boardDeparment;
  BoardImage? boardImage;
  BoardTasks? boardTasks;
  BoardMember? boardMember;
  MessagingChannels? messagingChannels;
  String? boardCreator;
  String? status;
  List<CardModel> cards = [];

  BoardModel({
    this.boardId,
    this.boardName,
    this.boardDescription,
    this.boardDeparment,
    this.boardImage,
    this.boardTasks,
    this.boardCreator,
    this.boardMember,
    this.messagingChannels,
    this.status,
  });

  BoardModel.fromMap(dynamic json, String id) {
    boardName = json['Board_Name'] != null
        ? BoardName.fromJson(json['Board_Name'])
        : null;
    boardDescription = json['Board_Description'] != null
        ? BoardDescription.fromJson(json['Board_Description'])
        : null;
    boardDeparment = json['Board_Department'] != null
        ? BoardDepartment.fromJson(json['Board_Department'])
        : null;

    boardImage = json['Board_Image'] != null
        ? BoardImage.fromJson(json['Board_Image'])
        : null;
    boardTasks = json['Board_Tasks'] != null
        ? BoardTasks.fromJson(json['Board_Tasks'])
        : null;
    boardCreator = json['Board_Creator'];
    boardMember = json['Board_Members'] != null
        ? BoardMember.fromJson(json['Board_Members'])
        : null;
    messagingChannels = json['Messaging_Channels'] != null
        ? MessagingChannels.fromJson(json['Messaging_Channels'])
        : null;
    status = json['Status'];
    boardId = id;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (boardName != null) {
      map['Board_Name'] = boardName?.toJson();
    }
    if (boardDescription != null) {
      map['Board_Description'] = boardDescription?.toJson();
    }

    if (boardImage != null) {
      map['Board_Image'] = boardImage?.toJson();
    }

    if (boardDeparment != null) {
      map['Board_Department'] = boardDeparment?.toJson();
    }
    if (boardTasks != null) {
      map['Board_Tasks'] = boardTasks?.toJson();
    }
    if (boardMember != null) {
      map['Board_Members'] = boardMember?.toJson();
    }
    if (messagingChannels != null) {
      map['Messaging-Channels'] = messagingChannels?.toJson();
    }
    map['Board_Creator'] = boardCreator;
    map['Status'] = status;
    return map;
  }
}
